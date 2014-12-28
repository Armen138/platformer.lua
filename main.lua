require("fizzx/fizz")
version = require("version")
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
    if ui.current == 'play' then
        ui.current = 'pause'
    else
        ui.current = 'play'
    end
end

function help()
    console.log('platformer.lua ' .. version)
    console.log('arrows to move, D for debug drawing, ESCAPE for menu')
end
function love.load() 
    love.window.setMode(800, 600, { fullscreen = true, fullscreentype = 'desktop' })
    local font = love.graphics.newFont('ui/Font/kenvector_future.ttf')
    love.graphics.setFont(font)
    console.log('platformer.lua ' .. version)
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
    ui.menu('landing', {
        options = { modal = true },
        play = { 
            label  = 'play',
            sheet  = 'green',
            x      = center.x,
            y      = center.y - 100,
            style  = 'button02',
            active = 'button03'
        },
        quit = { 
            label  = 'quit',
            sheet  = 'red',
            x      = center.x,
            y      = center.y - 40,
            style  = 'button01',
            active = 'button02'
        }
    })
    ui.menu('pause', {
        options = { modal = true },
        resume = { 
            label  = 'resume',
            sheet  = 'green',
            x      = center.x,
            y      = center.y - 100,
            style  = 'button02',
            active = 'button03'
        },
        restart = { 
            label  = 'restart',
            sheet  = 'blue',
            x      = center.x,
            y      = center.y - 40,
            style  = 'button02',
            active = 'button03'
        },
        quit = { 
            label  = 'quit',
            sheet  = 'red',
            x      = center.x,
            y      = center.y + 20,
            style  = 'button01',
            active = 'button02'
        }
    })
    ui.menu('play', {
        ingameRestart = { 
            label  = 'r',
            sheet  = 'red',
            x      = love.window.getWidth() - 50,
            y      = 50,
            style  = 'button04',
            active = 'button05'
        }
    })
    ui.on.click.quit = function(btn) 
        system.exit()
    end

    ui.on.click.resume = function(btn)
        ui.current = 'play'
    end

    ui.on.click.restart = function(btn)
        ui.current = 'play'
        console.log('TODO: restart')
    end

    ui.on.click.ingameRestart = function(btn)
        console.log('TODO: ingame restart')
    end
    ui.on.click.play = function(btn)
        ui.current = 'play'
    end
    ui.current = 'landing'
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
    if ui.current == 'play' then 
        fizz.gravity = 1200
        accum = accum + dt
        while(accum > step) do
            player.update(dt)
           fizz.update(step) 
           accum = accum - step
        end
    end
end

function love.draw() 
    map.draw()
    player.draw()
    console.draw()
    ui.draw()
end
