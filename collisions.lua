function update_collisions()
    -- check damage to player
    if world.boss then
        if world.boss.current_pattern and world.player then
            for attack in all(world.boss.current_pattern.attacks) do
                if attack:is_active() and attack:check_collision(world.player) then
                    emit({ type = "player_take_damage" })
                end
            end
        end
    end

    -- check damage to boss
    if world.boss and world.player and world.projectiles then
        for projectile in all(world.projectiles) do
            if world.boss:check_collision_with_projectile(projectile) then
                emit({ type = "boss_take_damage" })
            end
        end
    end
end

function circle_collision(x0, y0, r0, x1, y1, r1)
    local dx = x0 - x1
    local dy = y0 - y1
    local length = dx * dx + dy * dy
    local radii = r0 + r1
    return length * length <= radii * radii
end