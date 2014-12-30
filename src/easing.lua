local easing = {}

function easing.outBounce(t, b, c, d)
    t = t / d
    if t < 1.0/2.75 then
        return c * (7.5625 * t * t) + b
    elseif t < 2.0/2.75 then
        t = t - 1.5 / 2.75
        return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5/2.75 then
        t = t - 2.25/2.75
        return c * (7.5625 * t * t + 0.9375) + b;
    end
end

function easing.inQuad(t, b, c, d)
    t = t / d
    return c*t*t + b;
end


return easing
