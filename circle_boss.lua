circle_boss = {}
circle_boss.__index = circle_boss
setmetatable(circle_boss, { __index = boss })

function circle_boss:new()
    local b = boss.new(self, 30)
    b.patterns = {
        function()
            return circle_boss_pattern_1()
        end,
        function()
            return circle_boss_pattern_2()
        end,
        function()
            return circle_boss_pattern_3()
        end
    }
    b.extra_patterns = {}
    b.special_patterns = {}

    b.path_idx = 1
    b.idle_time = 30 * 2
    b.idle_t = 0
    b.speed = 1
    b.r = 5
    setmetatable(b, circle_boss)
    return b
end

function circle_boss:take_damage()
    boss.take_damage(self)
    if self.hp == 20 then
        local r = 6
        local atk = ring_attack:new(0, 0, r, 0, 30 * 60 * 5):with_movement(function(a)
            a._t = (a._t or 0) + 0.01
            a.r = r + sin(a._t) * 15
            if world.boss then
                a.x = world.boss.x
                a.y = world.boss.y
            end
        end)
        add(self.special_patterns, pattern.from_attacks({ atk }))
    end
    if self.hp == 15 then
        add(self.special_patterns, pattern.from_attacks(following_circles(1200, 15, 15)))
    end
end

function circle_boss:move_update()
    self.t = (self.t or 0) + 0.005
    local cx, cy = 64, 64
    local r = 40

    self.x = cx + cos(self.t) * r
    self.y = cy + sin(self.t) * r
end

function circle_boss:check_collision_with_projectile(projectile)
    return circle_collision(self.x, self.y, self.r, projectile.x, projectile.y, projectile.r)
end

function circle_boss:check_collision_with_player(player)
    return circle_collision(self.x, self.y, self.r + 1, player.x, player.y, player.r)
end

function circle_boss:draw_boss()
    circfill(self.x, self.y, self.r, 8)
    -- hp visualization
    local hp_ratio = self.hp / self.max_hp
    local number_of_rings = flr((1 - hp_ratio) * self.r)

    for i = 1, number_of_rings do
        circ(self.x, self.y, self.r - i, 7)
    end
    circ(self.x, self.y, self.r, 7)
end

-- patterns

function following_circles(steps, delay, active)
    local attacks = {}
    for i = 0, steps - 1 do
        add(
            attacks,
            ring_attack:new(rnd(127), rnd(127), 7, delay * i, active):with_startup(attack:on_player())
        )
    end
    return attacks
end

function pulse_rings(n, delay, active)
    local attacks = {}
    for i = 0, n - 1 do
        add(
            attacks,
            ring_attack:new(0, 0, 3 + i * 2, delay * i, active):with_movement(attack:on_boss())
        )
    end
    return attacks
end

function breathing_rings(active, r)
    local attacks = {}
    add(attacks, breathing_ring(r, 0, 0, active))
    add(attacks, breathing_ring(r, SCREEN.w, SCREEN.h, active))
    add(attacks, breathing_ring(r, SCREEN.w, 0, active))
    add(attacks, breathing_ring(r, 0, SCREEN.h, active))
    return attacks
end

function breathing_rings_diagonal(active, r)
    local attacks = {}
    add(attacks, breathing_ring(r, SCREEN.w / 2, 0, active))
    add(attacks, breathing_ring(r, SCREEN.w / 2, SCREEN.h, active))
    add(attacks, breathing_ring(r, 0, SCREEN.h / 2, active))
    add(attacks, breathing_ring(r, SCREEN.w, SCREEN.h / 2, active))
    return attacks
end

function breathing_ring(r, x, y, active)
    local atk = ring_attack:new(x, y, r, 0, active)
    atk:with_movement(function(a)
        a._t = (a._t or 0) + 0.03
        a.r = r + sin(a._t) * 10
    end)
    return atk
end

function swinging_circles(n, r, spacing, dist, speed)
    local x = 2
    local y = 2
    local attacks = {}

    for i = 1, n do
        local rect

        if i % 2 == 1 then
            -- move down: start at top
            rect = ring_attack:new(x, y, r, 0, 240)
            rect:move_down(dist, speed)
        else
            -- move up: start at bottom of swing
            local y_start = y + dist
            rect = ring_attack:new(x, y_start, r, 0, 240)
            rect:move_up(dist, speed)
        end

        add(attacks, rect)

        -- move x for the next rectangle
        x = x + r + spacing
    end

    return attacks
end

function swinging_rings(n, r, spacing, dist, speed)
    local x = 10
    local y = 10
    local attacks = {}

    for i = 1, n do
        local atk

        if i % 2 == 1 then
            -- move down: start at top
            atk = ring_attack:new(x, y, r, 0, 240)
            atk:move_down(dist, speed)
        else
            -- move up: start at bottom of swing
            local y_start = y + dist
            atk = ring_attack:new(x, y_start, r, 0, 240)
            atk:move_up(dist, speed)
        end

        add(attacks, atk)

        -- move x for next ring
        x = x + r + spacing
    end

    return attacks
end

function circle_boss_pattern_1()
    local r = 10
    local duration = 30 * 12
    return pattern.from_attacks(
        breathing_rings(duration, 50),
        { ring_attack:new(r, SCREEN.h / 2, r, 0, duration):move_right(SCREEN.w - r - r, 0.1) },
        { ring_attack:new(SCREEN.w / 2, r, r, 0, duration):move_down(SCREEN.h - r - r, 0.1) }
    )
end

function circle_boss_pattern_2()
    return pattern.from_attacks(rain_ball())
end

function circle_boss_pattern_3()
    local r = 10
    local duration = 30 * 12
    local dist = SCREEN.w - r - r
    local speed = 0.1
    return pattern.from_attacks(
        breathing_rings_diagonal(duration, 30),
        { ring_attack:new(r, r, r, 0, duration):with_movement(movement_out_and_back(1, 1, dist, speed)) },
        { ring_attack:new(r, SCREEN.h - r, r, 0, duration):with_movement(movement_out_and_back(1, -1, dist, speed)) }
    )
end

function create_falling_ball_targetting_player(n, delay)
    local r = 5
    local attacks = {}
    for i = 0, n - 1 do
        local ra = ring_attack:new(
            0, -r, r, delay * i, 30 * 4
        ):with_movement(function(a)
            a.y += 1.0
        end):with_startup(function(a)
            if world.player != nil then
                a.x = world.player.x
            end
        end)
        add(attacks, ra)
    end
    return attacks
end

function rain_ball()
    local attacks = {}
    local r = 3
    local delay = 45
    for j = 1, 10 do
        for i = 1, flr(SCREEN.w / (r * 4)) do
            local delta = flr(rnd(30))
            local attack = ring_attack:new(
                i * r * 4, -r, r, j * delay + delta, 30 * 5
            ):with_movement(function(a)
                a._t = (a._t or 0) + 0.03
                a.r = r + sin(a._t) * 3
                if a.phase == "active" then
                    a.y += 1.0
                end
            end)

            add(attacks, attack)
        end
    end
    return attacks
end

function create_falling_balls(delay)
    return {
        ring_attack:new(0, -25, 25, delay, 30 * 15):with_movement(function(a)
            a.y += 0.4
        end),
        ring_attack:new(SCREEN.w, -25, 25, delay, 30 * 15):with_movement(function(a)
            a.y += 0.4
        end),
        ring_attack:new(SCREEN.w / 2, -25, 25, delay, 30 * 15):with_movement(function(a)
            a.y += 0.4
        end)
    }
end

function create_lateral_balls(delay)
    return {
        ring_attack:new(-5, 25, 5, delay, 30 * 15):with_movement(function(a)
            a.x += 0.8
        end),
        ring_attack:new(-5, SCREEN.h - 25, 5, delay, 30 * 15):with_movement(function(a)
            a.x += 0.8
        end)
    }
end