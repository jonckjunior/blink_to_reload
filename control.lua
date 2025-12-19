events = {}

function update_control()
    process_events()
end

function emit(event)
    add(events, event)
end

function process_events()
    for event in all(events) do
        if event.type == "move" then
            world.player:move(event.dx, event.dy)
        end
        if event.type == "try_blink" then
            world.player:try_blink(event.target_x, event.target_y)
        end
        if event.type == "try_shoot" then
            world.player:try_shoot(event.target_x, event.target_y)
        end
        if event.type == "player_take_damage" and world.player != nil then
            world.player:take_damage()
        end
        if event.type == "boss_take_damage" and world.player != nil then
            world.boss:take_damage()
        end
    end
    events = {}
end