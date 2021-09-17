# Gear-Of-Fate

Gear of Fate is an Action Game based on dnf(dungon and fighter), developed by SerDing using love2D game engine. 

## Runtime Object Model Architecture

GOF used Entity-Component architecture, every gameobject is derived from an abstract entity, it owns some components which implement all kinds of features the object need. In other words, the object is just a container that store components and the components decide what is this object and what it can do.

## Render System

GOF has a render system to draw many drawables in game correctly, the system sort drawables in the layer like avatar first, then sort all entites in scene and draw them in order finally. Not only that, the system also merge data about render(like position, scale, color, blendmode etc) in a hierarchy of drawable objects.

## Animation System

GOF has customized frame animation module that play by animation data. Above this, the avatar composite some frame animation objects for present a complex entity(like character, monster).

## Combat System

A complete combat system are composition of many mechanics and elements:
* Animation
* Action 
* Movement
* Collision Detection
* Attack Judgement
* Life Management
* Effects
* Particle
* Flash
* Sound
* ...

As the core mechanic of GOF, it centered on combat compoent, cooperate with many other components(like render, movement, identity, state etc) and other systems(like entity manager, entity factory, audio) to process attack and damage in a battle.

## AI System 
The ai system used following technologies:
* A* path finding algorithm
* Finite State Machine (for decision logic)

## Level System (unfinished)
The level system of GOF is uncompleted, but it's expected that this system will have following features:
* Load Level
* Switching Process 
* PathGraph Constructing √
## UI System
The ui system in GOF used drawable types from render system, so it can have a scene graph management too. Layout manager will load layout of a panel to construct widgets in the panel.Widgets can be linked to game logic by controller to complete some logical interactions, because the pattern of ui system is MVC.

