local font
local menus = {}
local mouse = { x = 0, y = 0 }
local defaultFont
local sheets = {
    blue = require("../ui/blueSheet"),
    red = require("../ui/redSheet"),
    yellow = require("../ui/yellowSheet"),
    grey = require("../ui/greySheet"),
    green = require("../ui/greenSheet")
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
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()
    if ui.current then
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

function ui.draw() 
    if ui.current then
        if menus[ui.current].options and
            menus[ui.current].options.modal then
            love.graphics.setColor(0, 0, 127, 127)
            love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
            love.graphics.setColor(255, 255, 255, 255)
        end
        for k, v in pairs(menus[ui.current]) do
            if k ~= 'options' then 
                v.draw()
            end
        end
    end
end

function ui.button(text, sheet, left, top, style, active)
    local hover = false
    local function draw()
        local quad = sheets[sheet][style]
        if hover then
            quad = sheets[sheet][active]
        end
        love.graphics.setFont(font)
        local x, y, w, h = quad:getViewport()
        love.graphics.draw(sheets[sheet].image, quad, left - w / 2, top - h / 2)            
        love.graphics.printf(text, left - w / 2, top - h / 2 + 12, w, 'center')
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
