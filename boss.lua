boss = {}
boss.__index = boss

function boss:new()
    local p = {
        x = 64,
        y = 80,
        r = 4,
        hp = 3,
        patterns = {
            function()
                return create_bottom_up_horizontal_attack(32)
            end,
            function()
                return create_left_right_vertical_attack(32)
            end,
            function()
                return create_top_down_horizontal_attack(32)
            end,
            function()
                return create_right_left_vertical_attack(32)
            end
        },
        current_pattern = nil,
        pattern_index = 1
    }
    return setmetatable(p, boss)
end

function boss:update()
    if not self.current_pattern then
        local attacks = self.patterns[self.pattern_index]()
        self.current_pattern = pattern:new(attacks)
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
    local is_colliding = circle_collision(self.x, self.y, self.r, projectile.x, projectile.y, projectile.r)

    return is_colliding
end

function boss:take_damage()
    self.hp -= 1
end