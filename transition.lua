transition = { active = false, t = 0, active_t = 60 }

function transition:start(on_startup, on_finish, phase, delay)
    self.running = true
    self.active = false
    self.t = 0
    self.delay = delay or 0
    self.phase = phase
    self.on_finish = on_finish

    if on_startup then on_startup() end
end

function transition:update()
    if not self.running then return end

    if self.delay > 0 then
        self.delay -= 1
        if self.delay == 0 then
            self.active = true
            self.t = 0
        end
        return
    else
        self.active = true
    end

    -- visuals phase
    self.t += 1

    if self.t >= self.active_t then
        self.running = false
        self.active = false
        if self.on_finish then
            self.on_finish()
        end
    end
end
-- 30 -> 1s
-- 15 -> 0.5s
-- 8 -> 0.25s

function transition:draw()
    if not self.active then return end
    if self.phase == "into_playing" then
        -- 0.5 - 0.75s
        if self:is_in_between(15, 15 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("blink")
        elseif self:is_in_between(30, 30 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("to")
        elseif self:is_in_between(45, 45 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("reload")
        end
    end

    if self.phase == "into_menu" then
        -- 0.5 - 0.75s
        if self:is_in_between(15, 15 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("good")
        elseif self:is_in_between(30, 30 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("job")
        else
            rectfill(0, 0, 127, 127, 0)
        end
    end

    if self.phase == "into_menu_player_death" then
        -- 0.5 - 0.75s
        if self:is_in_between(15, 15 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("try")
        elseif self:is_in_between(30, 30 + 8) then
            rectfill(0, 0, 127, 127, 0)
            self:print_centered("again")
        end
    end
end

function transition:is_in_between(x, y)
    return x <= self.t and self.t <= y
end

function transition:print_centered(txt)
    local len = #txt
    local start_x = (SCREEN.w - len * 4) / 2
    local start_y = SCREEN.h / 2
    print(txt, start_x, start_y, 7)
    shake = 4
    sfx(1)
end