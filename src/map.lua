local data = require("../map/testmap3")
local map = {}
local tiles = {}
local physical = {}
local layers = {}

map.width = data.width * 70
map.height = data.height * 70

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
                        console.log('adding tile ' .. tile)
                        local t = fizz.addStatic('rect', ((x - 1) * tiles.size) + 35, ((y - 1) * tiles.size) + 35, 70, 70)
                        t.quad = quad --love.graphics.newQuad(left, top, 70, 70, tiles.image:getWidth(), tiles.image:getHeight())
                        table.insert(layers[layer.name], t)
                    else
                        local d = {
                            quad = quad,
                            x = (x - 1) * tiles.size + 35,
                            y = (y - 1) * tiles.size + 35,
                            hh = 35,
                            hw = 35
                        }   
                        table.insert(layers[layer.name], d)
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
                love.graphics.setColor(0, 255, 0, 127)
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
