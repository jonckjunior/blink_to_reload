boss = {}
boss.__index = boss

function boss:new()
    local p = {
        x = 64,
        y = 80,
        r = 4,
        patterns = {},
        current_pattern = nil,
        pattern_index = 0
    }
    return setmetatable(p, boss)
end

function boss:update()
    if not self.current_pattern then
        if frame_timer == 0 then
            -- local attacks = create_vertical_attack(0, 32, 0, 50)
            self.current_pattern = pattern:new(
                self,
                -- create_top_down_horizontal_attack(8)
                create_left_right_vertical_attack(16)
            )
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