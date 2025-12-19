player = {}
player.__index = player

function player:new()
    local p = {
        i_frames = 0,
        hp = 3,
        x = 64,
        y = 64,
        r = 3,
        aim_x = 64,
        aim_y = 64,
        has_ammo = true,
        reload_t = 0,
        reload_max_t = 15, -- 0.5s, number of frames
        cooldown_t = 0,
        cooldown_max_t = 30, -- 1s, number of frames
        max_dash_length = 50,
        min_dash_length = 20
    }
    return setmetatable(p, player)
end

function player:update()
    self:check_keyboard()
    self:check_mouse()

    if self.reload_t > 0 then
        self.reload_t -= 1
        if self.reload_t == 0 then
            self.has_ammo = true
        end
    end

    if self.cooldown_t > 0 then
        self.cooldown_t -= 1
    end

    if self.i_frames > 0 then
        self.i_frames -= 1
    end
end

function player:draw()
    draw_crosshair()

    if self.has_ammo then
        circfill(self.x, self.y, self.r, 7)
    else
        -- outline
        circ(self.x, self.y, self.r, 7)

        if self.reload_t == 0 then
            return
        end

        local progress = (self.reload_max_t - self.reload_t) / self.reload_max_t
        local y_cutoff = self.y + self.r - flr(progress * 2 * self.r)
        for x = -self.r, self.r do
            for y = -self.r, self.r do
                if self.y + y >= y_cutoff and x * x + y * y <= self.r * self.r then
                    pset(self.x + x, self.y + y, 7)
                end
            end
        end
    end
end

function draw_crosshair()
    if world.player then
        local dx = world.player.aim_x - world.player.x
        local dy = world.player.aim_y - world.player.y
        local length = sqrt(dx * dx + dy * dy)
        local xn = dx / length
        local yn = dy / length
        local step = 10
        length = max(length, world.player.min_dash_length)
        length = min(length, world.player.max_dash_length)
        -- guiding line
        for i = 1, flr(length / step) do
            local col = 5
            local cur_dx = xn * step * i
            local cur_dy = yn * step * i
            local cur_length = step * i
            if world.player.min_dash_length <= cur_length and cur_length <= world.player.max_dash_length then
                local progress = (world.player.cooldown_max_t - world.player.cooldown_t) / world.player.cooldown_max_t
                local progress_step = flr(progress / 0.25)
                if progress_step >= i - 1 then
                    col = 1
                end
            end
            circfill(world.player.x + cur_dx, world.player.y + cur_dy, 1, col)
        end
        -- croshair
        circfill(world.player.aim_x, world.player.aim_y, 1, 8)
    end
end

function player:set_movement(x, y)
    x = min(x, 127 - self.r - 1)
    x = max(self.r + 1, x)
    y = min(y, 127 - self.r - 1)
    y = max(self.r + 1, y)
    self.x = x
    self.y = y
end

function player:move(dx, dy)
    dx += self.x
    dy += self.y
    self:set_movement(dx, dy)
end

function player:check_keyboard()
    local dx, dy = 0, 0
    if btn(2, 1) then dy -= 1.5 end
    if btn(3, 1) then dy += 1.5 end
    if btn(0, 1) then dx -= 1.5 end
    if btn(1, 1) then dx += 1.5 end

    if dx != 0 and dy != 0 then
        dx *= 0.75
        dy *= 0.75
    end
    emit({ type = "move", dx = dx, dy = dy })
end

function player:check_mouse()
    self.aim_x = stat(32)
    self.aim_y = stat(33)

    if stat(34) == 1 then
        -- left click, player is shooting
        emit({ type = "try_shoot", target_x = self.aim_x, target_y = self.aim_y })
    elseif stat(34) == 2 then
        emit({ type = "try_blink", target_x = self.aim_x, target_y = self.aim_y })
        -- right click, player is blinking
    end
end

function player:try_blink(tx, ty)
    if self.cooldown_t == 0 then
        self:blink(tx, ty)
    end
end

function player:blink(tx, ty)
    local dx = tx - self.x
    local dy = ty - self.y
    local length = sqrt(dx * dx + dy * dy)
    dx /= length
    dy /= length
    local dash_length = min(length, self.max_dash_length)
    dash_length = max(dash_length, self.min_dash_length)

    local x = self.x + dx * dash_length
    local y = self.y + dy * dash_length
    self:set_movement(x, y)
    self.reload_t = self.reload_max_t
    self.cooldown_t = self.cooldown_max_t
    self.i_frames = max(self.i_frames, 5)
end

function player:try_shoot(tx, ty)
    if self.has_ammo then
        self:shoot(tx, ty)
    end
end

function player:shoot(tx, ty)
    local dx = tx - self.x
    local dy = ty - self.y
    local length = sqrt(dx * dx + dy * dy)
    if length <= 0.1 then
        dx = 1
        dy = 0
        length = 1
    end
    dx /= length
    dy /= length

    local ps = player_shot:new(
        self.x,
        self.y,
        dx,
        dy
    )
    self.has_ammo = false
end

function player:take_damage()
    if self.i_frames > 0 then
        return
    end

    self.hp -= 1
    self.i_frames = 30
end

-- player_shot

player_shot = {}
player_shot.__index = player_shot

function player_shot:new(x, y, dx, dy)
    local ps = {
        x = x,
        y = y,
        r = 1,
        dx = dx,
        dy = dy
    }
    setmetatable(ps, player_shot)
    add(world.projectiles, ps)
    return ps
end

function player_shot:update()
    self.x += self.dx * 10
    self.y += self.dy * 10

    if abs(self.x) > 140 or abs(self.y) > 140 then
        del(world.projectiles, self)
    end
end

function player_shot:draw()
    circfill(self.x, self.y, self.r, 7)
end