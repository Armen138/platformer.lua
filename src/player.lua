local player = {}
local p
local chr
local frame
local last = love.timer.getTime()
local direction = 1

local animations = {
    fps     = 4,
    idle    = { 'idle', 'stand', 'stand', 'stand', 'stand', 'stand' },
    walk    = { 'walk1', 'walk2' },
    jump    = { 'jump' },
    current = 'idle'
}

function player.setAnimation(ani) 
    if animations.current ~= ani then
        frame = 1
        animations.current = ani
    end
end

function player.draw() 
    local now = love.timer.getTime()
    local frameTime = (1 / animations.fps);
    if (now - last > frameTime) then
        frame = frame + 1
        if(animations[animations.current][frame] == nil) then
            frame = 1
        end
        last = now
    end
    local currentFrame = animations[animations.current][frame]
    if not chr[currentFrame] then
        console.log("frame error: " .. frame)
    else
        local height = chr[currentFrame]:getHeight()
        local remainder = (100 - height)
        local correction = 0
        if direction == -1 then
            correction = 70
        end
        love.graphics.draw(chr[currentFrame], 
                            p.x - p.hw + correction - scroll.x,
                            p.y - p.hh + remainder - scroll.y, 
                            0, 
                            direction, 
                            1)
    end
    if DEBUG then
        love.graphics.setColor(255, 0, 0, 127)
        love.graphics.rectangle('fill', 
                                p.x - p.hw - scroll.x, 
                                p.y - p.hh - scroll.y, 
                                p.hw * 2, 
                                p.hh * 2)
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function player.load(fizz) 
    chr = {
        idle  = love.graphics.newImage('chars/Blue/Alpha/idle.png'),
        stand = love.graphics.newImage('chars/Blue/Alpha/stand.png'),
        walk1 = love.graphics.newImage('chars/Blue/Alpha/walk_1.png'),
        walk2 = love.graphics.newImage('chars/Blue/Alpha/walk_2.png'),
        jump  = love.graphics.newImage('chars/Blue/Alpha/jump.png'),
    }
    console.log('loading player')
    frame = 1
    pos = {
        x = 2 * 70,
        y = 48 * 70
    }
    p = fizz.addDynamic('rect', pos.x, pos.y, 70, 100)
    p.damping = 5
    p.friction = 0.15
    p.onCollide = function (p, b, nx, ny, pen)
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
end

function player.update(dt) 
    local move = 0
    local jump = 0
    if(love.keyboard.isDown('left')) then
        move = -2000
        direction = -1
    end
    if(love.keyboard.isDown('right')) then
        move = 2000
        direction = 1
    end
    if(love.keyboard.isDown('up')) then
        if p.grounded then
            p.jumptime = 0
            p.jumping = true
        end
    else
        if p.grounded then
            p.jumping = false
        end
    end
    if p.jumping then
        p.jumptime = p.jumptime + dt
        if p.jumptime < 0.75 then
            local c = math.cos(p.jumptime / 0.75 * (math.pi / 2))
            jump = 5000 * c
        end
    end
    if p.jumping then
        player.setAnimation('jump')
    else
        if move ~= 0 then
            player.setAnimation('walk')
        else
            player.setAnimation('idle')
        end
    end
    p.xv = p.xv + move * dt
    p.yv = p.yv - jump * dt
    if p.yv ~= 0 then
        p.grounded = false
    end
    scroll.center(p.x, p.y)
end

player.keypress = {
}
player.keydown = {}
player.keyup = {}

return player

