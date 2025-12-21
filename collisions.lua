function update_collisions()
    -- check damage to player
    if world.boss and world.player then
        if world.boss.current_pattern then
            for attack in all(world.boss.current_pattern.attacks) do
                if attack:is_active() and attack:check_collision(world.player) then
                    emit({ type = "player_take_damage" })
                end
            end
        end

        if world.boss:check_collision_with_player(world.player) then
            emit({ type = "player_take_damage" })
        end
    end

    -- check damage to boss
    if world.boss and world.player and world.projectiles then
        for projectile in all(world.projectiles) do
            if world.boss:check_collision_with_projectile(projectile) then
                emit({ type = "boss_hit_by_projectile", projectile = projectile })
            end
        end
    end
end

function circle_collision(x0, y0, r0, x1, y1, r1)
    local dx = x0 - x1
    local dy = y0 - y1
    local dist_sq = dx * dx + dy * dy
    local radii = r0 + r1
    return dist_sq <= radii * radii
end

function square_circle_collision(x0, y0, x1, y1, x2, y2, r2)
    -- clamp player center to rectangle
    local cx = mid(x0, x2, x1)
    local cy = mid(y0, y2, y1)

    -- distance from closest point
    local dx = x2 - cx
    local dy = y2 - cy

    return dx * dx + dy * dy <= r2 * r2
end