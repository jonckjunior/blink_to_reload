attack = {}
attack.__index = attack

-- once an attack is started, it starts with the telegraph phase
-- it stays there for a fixed (telegraph_timer) amount of frames
-- after that it will start being active. it will stay active for
-- active_t frames and then will be marked as done.
-- the pattern that uses the attack will then clean up all done attacks

-- start_t: the frame where the attack should start once a pattern is chosen for the boss
-- active_t: the number of frames the attack should be active for
-- example: attack:new(30, 60)
-- the attack will start after 30 frames of the pattern being activated
-- after 30 frames (1s) it will start the telegraph phase and stay there for telegraph_timer
-- once that is done, it will begin it's active phase for 60 frames (2s)

function attack:new(start_t, active_t)
    local a = {
        start_t = start_t,
        t = 0,
        active_t = active_t,
        done = false,
        movement = nil,
        phase = "telegraph"
    }
    setmetatable(a, self)
    return a
end

function attack:with_movement(movement)
    assert(movement != nil)
    self.movement = movement
    return self
end

function attack:move_down(dist, speed)
    return self:with_movement(movement_out_and_back(0, 1, dist, speed))
end

function attack:move_up(dist, speed)
    return self:with_movement(movement_out_and_back(0, -1, dist, speed))
end

function attack:move_right(dist, speed)
    return self:with_movement(movement_out_and_back(1, 0, dist, speed))
end

function attack:move_left(dist, speed)
    return self:with_movement(movement_out_and_back(-1, 0, dist, speed))
end

function movement_out_and_back(dx, dy, dist, speed)
    return function(a)
        if not a._move then
            a._move = {
                t = 0,
                base = {
                    x0 = a.x0, y0 = a.y0,
                    x1 = a.x1, y1 = a.y1
                }
            }
        end

        local m = a._move
        m.t += speed

        local offset = (1 - cos(m.t * 0.1)) / 2 * dist

        a.x0 = m.base.x0 + dx * offset
        a.y0 = m.base.y0 + dy * offset
        a.x1 = m.base.x1 + dx * offset
        a.y1 = m.base.y1 + dy * offset
    end
end

function attack:update()
    self:update_movement()

    if self.phase == "telegraph" and self.t >= telegraph_timer then
        self.phase = "active"
        self.t = 0
    elseif self.phase == "active" and self.t >= self.active_t then
        self.phase = "done"
        self.done = true
    end

    self.t += 1
end

-- for attacks that require movement
function attack:update_movement()
    if self.movement then
        self.movement(self)
    end
end

function attack:is_telegraph() return self.phase == "telegraph" end
function attack:is_active() return self.phase == "active" end
function attack:is_done() return self.phase == "done" end

function attack:start_draw()
    -- this is just to flicker the drawing
    if frame_timer % 16 <= 8 then
        fillp(0xa5a5)
    else
        fillp(0x85a5)
    end
    local col = 1
    -- default telegraph color

    -- change color if it's not telegraphed anymore
    if self:is_active() then
        col = 8
    end

    return col
end

function attack:end_draw()
    -- clear the pattern so it doesn't affect other things
    fillp()
end

-- each attack should implement its own draw and collision checks
function attack:draw()
    assert(false)
end
function attack:check_collision(player)
    assert(false)
end

function oscillate(axis, amplitude, speed)
    return function(a)
        if not a.phase then
            a.phase = 0
            a.base_x0 = a.x0
            a.base_x1 = a.x1
            a.base_y0 = a.y0
            a.base_y1 = a.y1
        end

        a.phase += speed
        local offset = sin(a.phase) * amplitude

        if axis == "y" then
            a.y0 = a.base_y0 + offset
            a.y1 = a.base_y1 + offset
        else
            a.x0 = a.base_x0 + offset
            a.x1 = a.base_x1 + offset
        end
    end
end

-- ring attack

ring_attack = {}
ring_attack.__index = ring_attack
setmetatable(ring_attack, { __index = attack })

-- ring has x and y coordinates with a radius of r
function ring_attack:new(x, y, r, start_t, active_t)
    local ra = attack.new(self, start_t, active_t)
    ra.x = x
    ra.y = y
    ra.r = r
    return ra
end

-- same as father
function ring_attack:update()
    attack.update(self)
end

-- start_draw is just setting the pattern and color
-- to see if it's a telegraph or active attack
-- end draw cleans up everything
function ring_attack:draw()
    local col = self:start_draw()
    circfill(self.x, self.y, self.r, col)
    self:end_draw()
end

-- basic two circle collision
function ring_attack:check_collision(player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = dx * dx + dy * dy
    local radius = (self.r + player.r) * (self.r + player.r)
    return dist < radius
end

-- rectangle attack

rectangle_attack = {}
rectangle_attack.__index = rectangle_attack
setmetatable(rectangle_attack, { __index = attack })

function rectangle_attack:new(x0, y0, x1, y1, start_t, active_t)
    local ra = attack.new(self, start_t, active_t)
    assert(x1 > x0)
    assert(y1 > y0)
    ra.x0 = x0
    ra.y0 = y0
    ra.x1 = x1
    ra.y1 = y1
    return ra
end

function rectangle_attack:update()
    attack.update(self)
end

function rectangle_attack:draw()
    local col = self:start_draw()
    rectfill(self.x0, self.y0, self.x1, self.y1, col)
    self:end_draw()
end

function rectangle_attack:check_collision(player)
    return square_circle_collision(
        self.x0,
        self.y0,
        self.x1,
        self.y1,
        player.x,
        player.y,
        player.r
    )
end

function create_horizontal_attack(y, width, start_t, active_t)
    return rectangle_attack:new(0, y, 127, y + width, start_t, active_t)
end

function create_vertical_attack(x, width, start_t, active_t)
    return rectangle_attack:new(x, 0, x + width, 127, start_t, active_t)
end

function create_top_down_horizontal_attack(width, active)
    local attacks = {}
    for i = 0, 127, width do
        local t = flr(i / width) * active
        local attack = create_horizontal_attack(i, width - 2, t, active)
        add(attacks, attack)
    end
    return attacks
end

function create_bottom_up_horizontal_attack(width, active)
    local attacks = {}
    for i = 0, 127, width do
        local t = flr((127 - i) / width) * active
        local attack = create_horizontal_attack(i, width - 2, t, active)
        add(attacks, attack)
    end
    return attacks
end

function create_left_right_vertical_attack(width, active)
    local attacks = {}
    for i = 0, 127, width do
        local t = flr(i / width) * active
        local attack = create_vertical_attack(i, width - 2, t, active)
        add(attacks, attack)
    end
    return attacks
end

function create_right_left_vertical_attack(width, active)
    local attacks = {}
    for i = 0, 127, width do
        local t = flr((127 - i) / width) * active
        local attack = create_vertical_attack(i, width - 2, t, active)
        add(attacks, attack)
    end
    return attacks
end

function create_non_fill_rectangle(x0, y0, x1, y1, width)
    return {
        -- top line
        rectangle_attack:new(x0, y0, x1, y0 + width, 0, 60),
        -- left line
        rectangle_attack:new(x0, y0, x0 + width, y1, 0, 60),
        -- right line
        rectangle_attack:new(x1 - width, y0, x1, y1, 0, 60),
        -- bottom line
        rectangle_attack:new(x0, y1 - width, x1, y1, 0, 60)
    }
end