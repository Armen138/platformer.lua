require("fizzx/fizz")
console = require("src/console")
map = require("src/map")
scroll = require("src/scroll")
system = require("src/system")
player = require("src/player")

DEBUG = false

fizz.maxVelocity = 300
fizz.gravity = 1200

local handlers

function toggleDebug()
    DEBUG = not DEBUG
    debugStatus = 'off'
    if DEBUG then
        debugStatus = 'on'
    end
    console.log('setting DEBUG mode ' .. debugStatus)
end

function love.load() 
    handlers = {
        escape = system.exit,
        d = toggleDebug
    }
    map.load(fizz)
    player.load(fizz)
end

function love.keypressed(key)
    if(handlers[key]) then
        console.log("handling key: " .. key)
        handlers[key]()
    end
    if(player.keypress[key]) then
        player.keypress[key]()
    end
end

function love.keydown(key) 
    if(player.keydown[key]) then
        player.keydown[key]()
    end
end

function love.keyup(key) 
    if(player.keyup[key]) then
        player.keyup[key]()
    end
end

step = 0.016
accum = 0

function love.update(dt)
    fizz.gravity = 1200
    accum = accum + dt
    while(accum > step) do
        player.update(dt)
       fizz.update(step) 
       accum = accum - step
    end
end

function love.draw() 
    map.draw()
    player.draw()
    console.draw()
end
