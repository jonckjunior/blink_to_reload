boss = {}
boss.__index = boss

-- patterns should be a list of functions that instantiate patterns
-- this is because we can't just assign current_pattern to patterns[i]
-- since it will not copy, and will just modify an existing pattern

-- every boss needs to implement:
-- new
-- move_update
-- check_collision_with_projectile
-- check_collision_with_player

function boss:new(hp)
    local p = {
        x = 64,
        y = 80,
        r = 4,
        hp = hp,
        max_hp = hp,
        patterns = {},
        current_pattern = nil,
        special_patterns = {},
        pattern_index = 1
    }
    return setmetatable(p, boss)
end

function boss:update()
    self:move_update()

    for p in all(self.special_patterns) do
        p:update()
    end

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
    local attacks = self:all_attacks()

    -- telegraphs first
    for a in all(attacks) do
        if a:is_telegraph() then
            a:draw()
        end
    end

    -- then actives
    for a in all(attacks) do
        if a:is_active() then
            a:draw()
        end
    end
end

function boss:all_attacks()
    local out = {}

    if self.current_pattern then
        for a in all(self.current_pattern.attacks) do
            add(out, a)
        end
    end

    for p in all(self.special_patterns) do
        for a in all(p.attacks) do
            add(out, a)
        end
    end

    return out
end

function boss:move_update()
    assert(false)
end

function boss:check_collision_with_player(player)
    assert(false)
end

function boss:check_collision_with_projectile(projectile)
    assert(false)
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

-- test_boss for patterns
test_boss = {}
test_boss.__index = test_boss
setmetatable(test_boss, { __index = boss })

function test_boss:new()
    local b = boss.new(self, 30)
    b.patterns = {
        function()
            return pattern.from_attacks(sweep_attacks("left_right", 12, 15))
        end
    }
    b.r = 5
    setmetatable(b, test_boss)
    return b
end

function test_boss:check_collision_with_projectile(projectile)
    return false
end

function test_boss:check_collision_with_player(player)
    return false
end

-- end of test_boss

-- start tutorial_boss
tutorial_boss = {}
tutorial_boss.__index = tutorial_boss
setmetatable(tutorial_boss, { __index = boss })

function tutorial_boss:new()
    local b = boss.new(self, 30)
    b.patterns = self:basic_patterns(16, 30)
    b.extra_patterns = {}
    b.basic_width = 16
    b.basic_active = 30
    b.r = 5
    setmetatable(b, tutorial_boss)
    return b
end

function tutorial_boss:rebuild_patterns()
    self.patterns = self:basic_patterns(self.basic_width, self.basic_active)
    for f in all(self.extra_patterns) do
        add(self.patterns, f)
    end
    self.pattern_index = #self.patterns
end

function tutorial_boss:take_damage()
    boss.take_damage(self)
    if self.hp == 20 then
        self.basic_active = 15
        add(
            self.extra_patterns, function()
                return pattern.from_attacks(
                    sweep_attacks("bottom_up", 16, 15), -- Starts immediately
                    offset_attacks(sweep_attacks("top_down", 16, 15), 60) -- Delayed by 2s (60 frames @ 30fps)
                )
            end
        )
        self:rebuild_patterns()
    end
    if self.hp == 10 then
        self.basic_active = 10
        add(
            self.extra_patterns,
            function()
                -- More complex: Parallel + sequenced combo
                local parallel_left_right = { sweep_attacks("left_right", 12, 15), sweep_attacks("right_left", 12, 15) }
                -- Start together
                local follow_up = offset_attacks(sweep_attacks("bottom_up", 16, 15), 90)
                -- 3s after
                return pattern.from_attacks(parallel_left_right[1], parallel_left_right[2], follow_up)
            end
        )
        self:rebuild_patterns()
    end
end

function tutorial_boss:basic_patterns(width, active)
    return {
        function()
            return pattern.from_attacks(sweep_attacks("bottom_up", width, active))
        end,
        function()
            return pattern.from_attacks(sweep_attacks("left_right", width, active))
        end,
        function()
            return pattern.from_attacks(sweep_attacks("top_down", width, active))
        end,
        function()
            return pattern.from_attacks(sweep_attacks("right_left", width, active))
        end
    }
end

function tutorial_boss:draw()
    boss.draw(self)
    -- base body
    circfill(self.x, self.y, self.r, 8)

    -- hp visualization
    local hp_ratio = self.hp / self.max_hp
    local number_of_rings = flr((1 - hp_ratio) * self.r)

    for i = 1, number_of_rings do
        circfill(self.x, self.y, i, 7)
    end
end

function tutorial_boss:check_collision_with_projectile(projectile)
    return circle_collision(self.x, self.y, self.r, projectile.x, projectile.y, projectile.r)
end

function tutorial_boss:check_collision_with_player(player)
    return circle_collision(self.x, self.y, self.r, player.x, player.y, player.r)
end

function tutorial_boss:move_update()
    self.y = 64 + sin(frame_timer * 0.015) * 8
end

-- end of tutorial_boss