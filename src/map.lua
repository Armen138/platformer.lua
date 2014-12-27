local data = require("../map/testmap3")
local map = {}
local tiles = {}
local physical = {}
local layers = {}

local triggers = {
    ladder = { 177, 178 },
    lockboxes = { 173, 174, 175, 176 },
    doors = { 133 }
}
map.width = data.width * 70
map.height = data.height * 70

function hasId(trigger, id)
    for i, v in ipairs(triggers[trigger]) do
        if v == id then
            return true
        end
    end
    return false
end

function map.load(fizz)
    tiles.image = love.graphics.newImage(data.tilesets[1].image) 
    tiles.size = data.tilesets[1].tilewidth
    tiles.spacing = data.tilesets[1].spacing        
    tiles.margin = data.tilesets[1].margin 
    tiles.row = math.floor(data.tilesets[1].imagewidth / (tiles.size + tiles.spacing))

    for i, layer in ipairs(data.layers) do
        layers[layer.name] = {}
        for x = 1, data.width, 1 do
            for y = 1, data.height, 1 do
                idx = (y - 1) * data.width + (x)
                tile = layer.data[idx] - 1
                if tile >= 0 then
                    local left = (tile % tiles.row) * (tiles.size + tiles.spacing) + tiles.margin
                    local top = math.floor(tile / tiles.row) * (tiles.size + tiles.spacing) + tiles.margin
                    local quad = love.graphics.newQuad(left, top, 70, 70, tiles.image:getWidth(), tiles.image:getHeight())
                    if layer.name == 'platforms' then 
                        local t = fizz.addStatic('rect', ((x - 1) * tiles.size) + 35, ((y - 1) * tiles.size) + 35, 70, 70)
                        t.quad = quad --love.graphics.newQuad(left, top, 70, 70, tiles.image:getWidth(), tiles.image:getHeight())
                        table.insert(layers[layer.name], t)
                    elseif layer.name == 'triggers' then
                        local d = fizz.addStatic('rect', ((x - 1) * tiles.size) + 35, ((y - 1) * tiles.size) + 35, 70, 70)
                        d.quad = quad
                        d.type = 'sensor'
                        if hasId('ladder', tile) then
                            d.trigger = 'ladder'
                        else
                            d.trigger = 'bullshit'
                        end
                        table.insert(layers[layer.name], d)
                    elseif layer.name == 'dynamics' then
                        local d = fizz.addDynamic('rect', ((x - 1) * tiles.size) + 35, ((y - 1) * tiles.size) + 35, 70, 70)
                        d.quad = quad
                        d.type = 'box'
                        d.bounce = 0.3
                        d.friction = 0.3
                        table.insert(layers[layer.name], d)
                    else 
                        local ni = {
                            quad = quad,
                            hw = 35,
                            hh = 35,
                            x = (x - 1) * tiles.size + 35,
                            y = (y - 1) * tiles.size + 35,
                            type = 'sensor',
                            trigger = 'non interactive'
                        }
                        table.insert(layers[layer.name], ni)
                    end
                end
            end
        end
    end
end

function map.draw()
    for name, layer in pairs(layers) do
        for i, v in ipairs(layer) do
            love.graphics.draw(tiles.image, 
                                v.quad, 
                                math.floor(v.x - v.hw - scroll.x), 
                                math.floor(v.y - v.hh - scroll.y)
                                )
            if DEBUG then
                if v.type == 'sensor' then
                    if v.trigger == 'non interactive' then
                        love.graphics.setColor(255, 255, 255, 127)
                    else
                        love.graphics.setColor(0, 0, 255, 127)
                    end
                else
                    love.graphics.setColor(0, 255, 0, 127)
                end
                love.graphics.rectangle('fill', 
                                        math.floor(v.x - v.hw - scroll.x), 
                                        math.floor(v.y - v.hh - scroll.y), 
                                        v.hw * 2, 
                                        v.hh * 2)
                love.graphics.setColor(255, 255, 255, 255)
            end
        end
    end
end

return map
