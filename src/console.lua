local out = {}
local console = {}

function console.log(msg) 
    table.insert(out, msg)
end

function console.draw() 
    local start = 0
    if(#out > 10) then
        start = #out - 10
    end
    for line = start, start + 10, 1 do
        if out[line] then
            love.graphics.print(out[line], 20, 20 * (line - start))
        end
    end
end

return console
