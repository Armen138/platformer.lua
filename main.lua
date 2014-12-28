require("fizzx/fizz")
console = require("src/console")
ui = require("src/ui")
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

function pause()
    ui.current = 'pause'
end

function help()
    console.log('arrows to move, D for debug drawing, ESCAPE for menu')
end
function love.load() 
    local font = love.graphics.newFont('ui/Font/kenvector_future.ttf')
    love.graphics.setFont(font)
    handlers = {
        escape = pause, --system.exit,
        h = help,
        f1 = help,
        d = toggleDebug
    }
    ui.load()
    map.load(fizz)
    player.load(fizz)
    local center = {
        x = love.window.getWidth() / 2,
        y = love.window.getHeight() / 2
    }
    ui.menu('pause', {
         -- panel = { label = '', sheet = 'grey', x = center.x, y = center.y - 110, style = 'panel', active = 'panel' },
        resume = { label = 'resume', sheet = 'green', x = center.x, y = center.y - 100, style = 'button02', active = 'button03' },
        restart = { label = 'restart', sheet = 'blue', x = center.x, y = center.y - 40, style = 'button02', active = 'button03' },
        quit = { label = 'quit', sheet = 'red', x = center.x, y = center.y + 20, style = 'button01', active = 'button02' }
    })
    ui.on.click.quit = function(btn) 
        system.exit()
    end

    ui.on.click.resume = function(btn)
        ui.current = nil
    end

    ui.on.click.restart = function(btn)
        ui.current = nil
        console.log('TODO: restart')
    end
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
    ui.update(dt)
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
    ui.draw()
    --button.draw()
    --button2.draw()
end
