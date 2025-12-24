function update_world()
    if shake > 0 then
        shake -= 1
    end
    if red_frame > 0 then
        red_frame -= 1
    end
    if white_frame > 0 then
        white_frame -= 1
    end

    if world.player then
        world.player:update()
    end
    if world.boss then
        world.boss:update()
    end

    for i = #world.projectiles, 1, -1 do
        local p = world.projectiles[i]
        p:update()
    end

    for i = #world.particles, 1, -1 do
        local p = world.particles[i]
        p:update()
    end
end

function draw_world()
    if world.boss then
        world.boss:draw()
    end
    if world.player then
        world.player:draw()
    end
    for p in all(world.projectiles) do
        p:draw()
    end
    for p in all(world.particles) do
        p:draw()
    end
end