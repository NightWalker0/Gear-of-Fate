--[[
	Desc: Animator
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2017-07-30 23:36:07
]]
local _RESOURCE = require("engine.resource")
local _Collider = require("entity.collider")
local _Base = require("engine.graphics.drawable.frameani")

---@class Entity.Drawable.Frameani:Engine.Graphics.Drawable.Frameani
---@field protected _aniName string
---@field protected _collider Entity.Collider
---@field protected _colliderGroup table<int, Entity.Collider>
---@field protected _colliderGroupPool table<string, table<int, Entity.Collider>>
local _Frameani = require('core.class')(_Base)

function _Frameani.HandleData(data)
    if data.path then
        data.aniData = _RESOURCE.LoadAnimData(data.path)
    end
end

---@param aniData Engine.Resource.AnimData
local function _NewColliderGroup(aniData)
    local colliderData = aniData.colliderData
    if colliderData then
        local colliderGroup = {}
        for i=1,#colliderData do
            colliderGroup[i] = _Collider.New(colliderData[i])
        end

        return colliderGroup 
    end

    return nil
end

function _Frameani:Ctor(data)
    self._aniName = ""
    self._colliderGroup = {}
    self._colliderGroupPool = {}

    _Base.Ctor(self, data and data.aniData or nil)

    self.eventMap.setPosition:AddListener(self, self.UpdateCollider)
    self.eventMap.setScale:AddListener(self, self.UpdateCollider)

    self.focus = {
        focus = false,
        max = 1.0,
        min = 0.0,
        dir = -1,
        speed = 6,
        ARGB = {A = 255, R = 255, G = 0, B = 0},
        scale = {x = 1.5, y = 1.5, spd = 0.048},
        shaderCode = [[
                extern number green;
                vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
                {
                    vec4 GlowColor = vec4(255, 0, 0, 0);		// 发光色
                    vec4 GlowColor2 = vec4(0, 150, 0, 0);
                    vec2 TextureSize = vec2(800, 600); 			// 纹理尺寸
                    number samplerPre = 1.0;					// 采样器
                    number radiusX = 0.5 / TextureSize.x;		// 半径x
                    number radiusY = 0.5 / TextureSize.y;		// 半径y
                    number glowAlpha = 0.0;						// 背景发光透明度
                    number count = 0.0;							// 计数
                    number GlowRange = 12;						// 发光范围
                    number GlowExpand = 255;						// 发光强度 0 - 255

                    for( number i = -GlowRange; i <= GlowRange; i += samplerPre){
                        for(number j = -GlowRange; j <= GlowRange; j += samplerPre){
                            vec2 samplerTexCoord = vec2(texture_coords.x + j * radiusX, texture_coords.y + i * radiusY);

                            if(samplerTexCoord.x < 0.0 || samplerTexCoord.x > 1.0 || samplerTexCoord.y < 0.0 || samplerTexCoord.y > 1.0){
                                glowAlpha += 0.0;
                            }else{
                                glowAlpha += Texel(texture, samplerTexCoord).a;
                            }

                            glowAlpha += Texel(texture, samplerTexCoord).a;
                            count += 1.0;
                        }
                    }

                    glowAlpha = glowAlpha / (count + 100);
                    GlowColor.a = glowAlpha * GlowExpand;
                    GlowColor.g = green;
                    return GlowColor;
                }
        ]]
    }
    
end

function _Frameani:Draw()
    _Base.Draw(self)
    if self._collider then
        self._collider:Draw()
    end
end

function _Frameani:Play(aniData, aniName)
    if aniData then
        if not self._colliderGroupPool then
            self._colliderGroupPool = {}
        end
        self._colliderGroupPool[aniData] = self._colliderGroupPool[aniData] or _NewColliderGroup(aniData)
        self._colliderGroup = self._colliderGroupPool[aniData]
    end
    
    _Base.Play(self, aniData)
    self._aniName = aniName or self._aniName
end

---@param main Entity.Drawable.Frameani
function _Frameani:Sync(main)
    _Base.SetFrame(self, main._frame)
    self._timer._count = main._timer._count
end

function _Frameani:SetData(data)
    _Base.SetData(self, data)
    if not self._colliderGroup then
        self:SetCollider()
    else
        self:SetCollider(self._colliderGroup[self._frame])
    end
end

function _Frameani:SetCollider(collider)
    self._collider = collider
    self:UpdateCollider()
end

function _Frameani:UpdateCollider()
    if not self._collider then
        return 
    end

    local x, y, z = self:GetRenderValue("position")
    local sx, sy = self:GetRenderValue("scale")
    self._collider:Set(x, y, z, sx, sy)
end

---@return Entity.Collider
function _Frameani:GetCollider()
    return self._collider
end

function _Frameani:GetAniName()
    return self._aniName
end

return _Frameani
