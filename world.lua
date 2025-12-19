function update_world()
    if world.player then
        world.player:update()
    end
    if world.boss then
        world.boss:update()
    end
    for p in all(world.projectiles) do
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
end