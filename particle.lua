particle = {}
particle.__index = particle
function particle:new(x, y, start, life, col)
    col = col or 7
    local p = {
        x = x,
        y = y,
        r = 0,
        t = 0,
        start_t = start,
        life = life,
        col = col
    }
    add(world.particles, p)
    setmetatable(p, particle)
    return p
end

function particle:update()
    if self.t < self.start_t then
        self.t += 1
        return
    end

    if self.life <= 0 then
        del(world.particles, self)
    end

    self.r += 0.5
    self.life -= 0.5
end

function particle:draw()
    if self.t >= self.start_t then
        circfill(self.x, self.y, self.r, self.col)
    end
end