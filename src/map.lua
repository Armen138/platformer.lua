local data = require("../map/level1")
local easing = require('../src/easing')
local map = {}
local tiles = {}
local physical = {}
local layers = {}
local drawOrder = {}
local bg
local bumpStart = 0
local triggers = {
    ladder = { 177, 178 },
    lockboxes = { 173, 174, 175, 176 },
    doors = { 133 },
	coin = { 8 }
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

function ignoreSensors(p, b, nx, ny, pen)
    if ny < 0 then
        p.grounded = true
        p.nx = nx
        p.ny = ny
    else
        p.grounded = false
    end
    if b.type == 'sensor' then
        --if b.trigger == 'ladder' then
            --console.log('this is a ladder, suspending gravity')
            --fizz.gravity = 0
        --end
        return false
    end
    return true
end

function map.load(fizz)
    tiles.image = love.graphics.newImage('map/' .. data.tilesets[1].image) 
    tiles.size = data.tilesets[1].tilewidth
    tiles.spacing = data.tilesets[1].spacing        
    tiles.margin = data.tilesets[1].margin 
    tiles.row = math.floor(data.tilesets[1].imagewidth / (tiles.size + tiles.spacing))
    bg = love.graphics.newImage('map/bg_shroom.png')

    for i, layer in ipairs(data.layers) do
        layers[layer.name] = {}
        table.insert(drawOrder, 1, layer.name)
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
                        d.onCollide = ignoreSensors
                        table.insert(layers[layer.name], d)
					elseif layer.name == 'collectibles' then
                        local d = fizz.addStatic('rect', ((x - 1) * tiles.size) + 35, ((y - 1) * tiles.size) + 35, 70, 70)
                        d.quad = quad
                        d.type = 'sensor'
                        if hasId('coin', tile) then
                            d.trigger = 'coin'
                        else
                            d.trigger = 'bullshit'
                        end
						d.collectible = true;
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
    love.graphics.setColor(109, 164, 26, 255)
    love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    local now = love.timer.getTime()
	if now - bumpStart > 500 then
		bumpStart = now
	end
    local bump = 0;
    for w = 0, love.window.getWidth(), bg:getWidth() do
        love.graphics.draw(bg, w, 0)
    end
    for i, name in ipairs(drawOrder) do
    --for name, layer in pairs(layers) do
        local layer = layers[name]
        for i, v in ipairs(layer) do
			if v.collectible == true then
				bump = easing.inQuad(now - bumpStart, -15, 30, 500)
			end
            love.graphics.draw(tiles.image, 
                                v.quad, 
                                math.floor(v.x - v.hw - scroll.x), 
                                math.floor(v.y - v.hh - scroll.y + bump)
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
