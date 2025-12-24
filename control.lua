events = {}

function update_control()
    process_events()
end

function emit(event)
    add(events, event)
end

function process_events()
    if not transition.active then
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
            if event.type == "boss_hit_by_projectile" and world.player != nil then
                world.boss:hit_by_projectile(event.projectile)
            end
            if event.type == "player_death" and world.boss then
                world.player.die()
                transition:start(
                    nil,
                    function()
                        set_mode("menu")
                    end,
                    "into_menu_player_death",
                    60
                )
            end
            if event.type == "boss_death" and world.player then
                world.boss:die()
                transition:start(
                    nil,
                    function()
                        set_mode("menu")
                    end,
                    "into_menu",
                    60
                )
            end
        end
    end
    events = {}
end