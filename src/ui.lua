local font
local easing = require('../src/easing')
local menus = {}
local mouse = { x = 0, y = 0 }
local defaultFont
local last = nil
local sheets = {
    blue = require("../ui/blueSheet"),
    red = require("../ui/redSheet"),
    yellow = require("../ui/yellowSheet"),
    grey = require("../ui/greySheet"),
    green = require("../ui/greenSheet")
}

local animation = {
    duration = 0.4,
    start = 0,
    xOffset = 0,
    yOffset = 0
}

local ui = {
    on = {
        click = {}
    }
}

function ui.load() 
    font = love.graphics.newFont('ui/Font/kenvector_future.ttf', 25)
    defaultFont = love.graphics.newFont('ui/Font/kenvector_future_thin.ttf', 10)
    sheets.blue.image = love.graphics.newImage('ui/Spritesheet/blueSheet.png');
    sheets.red.image = love.graphics.newImage('ui/Spritesheet/redSheet.png');
    sheets.yellow.image = love.graphics.newImage('ui/Spritesheet/yellowSheet.png');
    sheets.grey.image = love.graphics.newImage('ui/Spritesheet/greySheet.png');
    sheets.green.image = love.graphics.newImage('ui/Spritesheet/greenSheet.png');
    love.graphics.setFont(defaultFont)
end

function ui.menu(id, elements)
    menus[id] = {}
    for k, v in pairs(elements) do
        if k == 'options' then
            menus[id].options = v
        else
            menus[id][k] = ui.button(v.label, v.sheet, v.x, v.y, v.style, v.active)
        end
    end
end

function love.mousepressed(x, y, button)
    if ui.current then
        for k, v in pairs(menus[ui.current]) do
            if k ~= 'options' then 
                if v.isInside(x, y) then
                    if ui.on.click[k] then
                        ui.on.click[k](button)
                    end
                end
            end
        end
    end
end

function ui.update(dt) 
    local now = love.timer.getTime()
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()
    if ui.current then
        if now - animation.start < animation.duration then
            animation.xOffset = easing.inQuad(now - animation.start, 1000, -1000, animation.duration)
            animation.fadeOut = 1.0 - ((now - animation.start) / animation.duration) 
            if not animation.xOffset then
                console.log('offset easing error')
            end
        else
            animation.xOffset = 0
            animation.fadeOut = 0
            last = nil
        end
        for k, v in pairs(menus[ui.current]) do
            if k ~= 'options' then 
                if v.isInside(mouse.x, mouse.y) then
                    if v.onHover then
                        v.onHover()
                    end
                end
            end
        end
    end
end

function ui.set(current)
    local now = love.timer.getTime()
    last = ui.current
    ui.current = current
    animation.start = now
end

function drawMenu(menu, xOffset, yOffset, opacity)
    if menus[menu].options and
        menus[menu].options.modal then
        love.graphics.setColor(0, 0, 127, 127 * opacity)
        love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
        love.graphics.setColor(255, 255, 255, 255)
    end
    love.graphics.setColor(255, 255, 255, 255 * opacity)
    for k, v in pairs(menus[menu]) do
        if k ~= 'options' then 
            if not animation.xOffset then
                console.log('offset error')
            else
                v.draw(xOffset, yOffset)
            end
        end
    end
    love.graphics.setColor(255, 255, 255, 255)
end

function ui.draw() 
    if ui.current then
        drawMenu(ui.current, animation.xOffset, animation.yOffset, 1.0)
        if last then
            drawMenu(last, 0, 0, animation.fadeOut)
        end
    end
end

function ui.button(text, sheet, left, top, style, active)
    local hover = false
    local function draw(xOffset, yOffset)
        local quad = sheets[sheet][style]
        if hover then
            quad = sheets[sheet][active]
        end
        love.graphics.setFont(font)
        local x, y, w, h = quad:getViewport()
        love.graphics.draw(sheets[sheet].image, quad, xOffset + left - w / 2, yOffset + top - h / 2)            
        love.graphics.printf(text, xOffset + left - w / 2, yOffset + top - h / 2 + 12, w, 'center')
        love.graphics.setFont(defaultFont)
    end
    
    local function isInside(sx, sy)
        local x, y, w, h = sheets[sheet][style]:getViewport()
        tx = left - w / 2
        ty = top - h / 2 + 12
        if sx > tx and
            sx < tx + w and
            sy > ty and
            sy < ty + h then
            hover = true
            return true
        end
        hover = false
        return false
    end

    local button = {
        draw = draw,
        isInside = isInside
    }
    return button
end
return ui
