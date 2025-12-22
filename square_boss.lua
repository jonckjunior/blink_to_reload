square_boss = {}
square_boss.__index = square_boss
setmetatable(square_boss, { __index = boss })

function square_boss:new()
    local b = boss.new(self, 30)
    b.patterns = {
        function()
            return pattern.from_attacks(
                square_halves_vertical(45, 30),
                offset_attacks(square_halves_horizontal(45, 30), 45 + 30 + 30)
            )
        end,
        function()
            return pattern.from_attacks(
                square_sweep(30, 45),
                offset_attacks(square_sweep(30, 45), 30 * 3 + 45)
            )
        end,
        function()
            return pattern.from_attacks(square_checker(30, 15))
        end
    }
    b.extra_patterns = {}

    b.l = 20
    b.path = {
        { x = 20, y = 20 },
        { x = 127 - 20, y = 20 },
        { x = 127 - 20, y = 127 - 20 },
        { x = 20, y = 127 - 20 }
    }
    b.path_idx = 1
    b.idle_time = 30 * 2
    b.idle_t = 0
    b.speed = 1
    b.x = b.path[1].x
    b.y = b.path[1].y
    setmetatable(b, square_boss)
    return b
end

function square_boss:move_update()
    -- will be idle for a second
    if self.idle_t > 0 then
        self.idle_t -= 1
        self.y += sin(frame_timer * 0.02) * 0.2
        return
    end

    local dir = unitary_vector(
        self.path[self.path_idx].x - self.x,
        self.path[self.path_idx].y - self.y
    )

    self.x += dir.x * self.speed
    self.y += dir.y * self.speed

    if point_distance({ x = self.x, y = self.y }, self.path[self.path_idx]) < 0.5 then
        self.path_idx = (self.path_idx % #self.path) + 1
        self.idle_t = self.idle_time
    end
end

function square_boss:check_collision_with_projectile(projectile)
    local x0 = self.x - self.l / 2
    local y0 = self.y - self.l / 2
    local x1 = self.x + self.l / 2
    local y1 = self.y + self.l / 2
    return square_circle_collision(
        x0,
        y0,
        x1,
        y1,
        projectile.x,
        projectile.y,
        projectile.r
    )
end

function square_boss:check_collision_with_player(player)
    local x0 = self.x - self.l / 2
    local y0 = self.y - self.l / 2
    local x1 = self.x + self.l / 2
    local y1 = self.y + self.l / 2
    return square_circle_collision(
        x0,
        y0,
        x1,
        y1,
        player.x,
        player.y,
        player.r
    )
end

function square_boss:draw()
    boss.draw(self)
    local x0 = self.x - self.l / 2
    local y0 = self.y - self.l / 2
    local x1 = self.x + self.l / 2
    local y1 = self.y + self.l / 2
    rectfill(x0, y0, x1, y1, 8)
    rect(x0, y0, x1, y1, 7)
end

function square_boss:take_damage()
    boss.take_damage(self)
    if self.hp == 20 then
        add(
            self.patterns, function()
                return pattern.from_attacks(
                    square_checker(30, 15),
                    offset_attacks(inverted_square_checker(30, 15), 45)
                )
            end
        )
    end
    if self.hp == 10 then
        self.special_patterns = {
            pattern.from_attacks(all_corners_increasing_squares(10, 5, 2, 30 * 60 * 5))
        }
    end
end

-- patterns

function square_sweep(delay, duration)
    return {
        rect_quadrant("tl", 0, duration),
        rect_quadrant("tr", delay, duration),
        rect_quadrant("br", delay * 2, duration),
        rect_quadrant("bl", delay * 3, duration)
    }
end

function rect_quadrant(q, delay, duration)
    local x0, y0, x1, y1

    if q == "tl" then
        x0, y0, x1, y1 = 0, 0, SCREEN.hw, SCREEN.hh
    elseif q == "tr" then
        x0, y0, x1, y1 = SCREEN.hw, 0, SCREEN.w, SCREEN.hh
    elseif q == "br" then
        x0, y0, x1, y1 = SCREEN.hw, SCREEN.hh, SCREEN.w, SCREEN.h
    elseif q == "bl" then
        x0, y0, x1, y1 = 0, SCREEN.hh, SCREEN.hw, SCREEN.h
    end

    return rectangle_attack:new(x0, y0, x1, y1, delay, duration)
end

function square_halves_horizontal(delay, duration)
    return {
        rectangle_attack:new(0, 0, SCREEN.w, SCREEN.hh, 0, duration),
        rectangle_attack:new(0, SCREEN.hh, SCREEN.w, SCREEN.h, delay, duration)
    }
end

function square_halves_vertical(delay, duration)
    return {
        rectangle_attack:new(0, 0, SCREEN.hw, SCREEN.h, 0, duration),
        rectangle_attack:new(SCREEN.hw, 0, SCREEN.w, SCREEN.h, delay, duration)
    }
end

function square_checker(delay, duration)
    return {
        rect_quadrant("tl", 0, duration),
        rect_quadrant("br", 0, duration),
        rect_quadrant("tr", delay, duration),
        rect_quadrant("bl", delay, duration)
    }
end

function inverted_square_checker(delay, duration)
    return {
        rect_quadrant("tl", delay, duration),
        rect_quadrant("br", delay, duration),
        rect_quadrant("tr", 0, duration),
        rect_quadrant("bl", 0, duration)
    }
end

function all_corners_increasing_squares(width, steps, delay, duration)
    local attacks = {}
    for atk in all(increasing_squares(0, 0, width, steps, delay, duration)) do
        add(attacks, atk)
    end
    for atk in all(increasing_squares(SCREEN.w - width, 0, width, steps, delay, duration)) do
        add(attacks, atk)
    end
    for atk in all(increasing_squares(0, SCREEN.h - width, width, steps, delay, duration)) do
        add(attacks, atk)
    end
    for atk in all(increasing_squares(SCREEN.w - width, SCREEN.h - width, width, steps, delay, duration)) do
        add(attacks, atk)
    end
    return attacks
end

function increasing_squares(x0, y0, width, steps, delay, duration)
    local attacks = {}
    local x1 = x0 + width
    local y1 = y0 + width
    for i = 0, steps - 1 do
        add(
            attacks,
            rectangle_attack:new(x0 - i * width, y0 - i * width, x1 + i * width, y1 + i * width, delay * i, duration)
        )
    end
    return attacks
end

function swinging_squares(n, width, spacing, dist, speed)
    local x0 = 2
    local y0 = 2
    local attacks = {}

    for i = 1, n do
        local x1 = x0 + width
        local rect

        if i % 2 == 1 then
            -- move down: start at top
            local y1 = y0 + width
            rect = rectangle_attack:new(x0, y0, x1, y1, 0, 240)
            rect:move_down(dist, speed)
        else
            -- move up: start at bottom of swing
            local y_start = y0 + dist
            local y1 = y_start + width
            rect = rectangle_attack:new(x0, y_start, x1, y1, 0, 240)
            rect:move_up(dist, speed)
        end

        add(attacks, rect)

        -- move x0 for the next rectangle
        x0 = x0 + width + spacing
    end

    return attacks
end