
local scroll = {}
local window = love.window
scroll.x = 0
scroll.y = 0
function scroll.right() 
    scroll.x = scroll.x + 1
end

function scroll.left()
    scroll.x = scroll.x - 1
end

function scroll.down() 
    scroll.y = scroll.y + 1
end

function scroll.center(x, y)
    local center = {}
    center.x = window.getWidth() / 2
    center.y = window.getHeight() / 2
    scroll.x = x - center.x
    scroll.y = y - center.y
    if scroll.x > map.width - window.getWidth() then
        scroll.x = map.width - window.getWidth()
    end
    if scroll.y > map.height - window.getHeight() then
        scroll.y = map.height - window.getHeight()
    end
    if scroll.x < 0 then
        scroll.x = 0
    end
    if scroll.y < 0 then
        scroll.y = 0
    end
end
return scroll
