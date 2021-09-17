--[[
	Desc: Log module.
	Author: SerDing
	Since: 2021-04-04
	Alter: 2021-04-04
]]

LOG = require("core.class")()

function LOG:Init()

end

function LOG.Debug(content, ...)
	--os.time() os.date()
	print(string.format(content, ...))
end

function LOG.Error(content)
	print("Error: " .. content)
	error(content)
end

return LOG