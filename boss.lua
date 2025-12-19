boss = {}
boss.__index = boss

-- patterns should be a list of functions that instantiate patterns
-- this is because we can't just assign current_pattern to patterns[i]
-- since it will not copy, and will just modify an existing pattern
function boss:new()
    local p = {
        x = 64,
        y = 80,
        r = 4,
        hp = 3,
        patterns = {},
        current_pattern = nil,
        pattern_index = 1
    }
    return setmetatable(p, boss)
end

function boss:update()
    if not self.current_pattern then
        self.current_pattern = self.patterns[self.pattern_index]()
        self.pattern_index += 1
        if self.pattern_index > #self.patterns then
            self.pattern_index = 1
        end
    else
        self.current_pattern:update()
        if self.current_pattern.done then
            self.current_pattern = nil
        end
    end
end

function boss:draw()
    if self.current_pattern then
        self.current_pattern:draw()
    end
    circfill(self.x, self.y, self.r, 8)
end

function boss:check_collision_with_projectile(projectile)
    return circle_collision(self.x, self.y, self.r, projectile.x, projectile.y, projectile.r)
end

function boss:hit_by_projectile(projectile)
    projectile:explode()
    self:take_damage()
end

function boss:take_damage()
    self.hp -= 1

    if self.hp <= 0 then
        world.boss = nil
    end
end

-- boss 1
boss_1 = {}
boss_1.__index = boss_1
setmetatable(boss_1, { __index = boss })

function boss_1:new()
    local b = boss.new(self)
    b.hp = 30
    b.patterns = {
        function()
            return pattern.from_attacks(
                sweep_attacks("bottom_up", 16), -- Starts immediately
                offset_attacks(sweep_attacks("top_down", 16), 60) -- Delayed by 2s (60 frames @ 30fps)
            )
        end,
        function()
            -- More complex: Parallel + sequenced combo
            local parallel_left_right = { sweep_attacks("left_right", 12), sweep_attacks("right_left", 12) }
            -- Start together
            local follow_up = offset_attacks(sweep_attacks("bottom_up", 16), 90)
            -- 3s after
            return pattern.from_attacks(parallel_left_right[1], parallel_left_right[2], follow_up)
        end
    }
    return b
end
-- end of boss 1