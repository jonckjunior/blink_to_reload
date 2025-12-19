function draw_ui()
    if mode == "playing" then
        -- draw borders
        line(0, 0, 0, 127, 7)
        line(0, 0, 127, 0, 7)
        line(0, 127, 127, 127, 7)
        line(127, 0, 127, 127, 7)

        -- draw player hp
        if world.player then
            draw_player_hp()
        end
    end
end

function draw_player_hp()
    local start_x = 127 - 8
    local start_y = 2
    for i = 1, world.player.hp do
        local x = start_x
        local y = start_y + (i - 1) * 8
        spr(1, x, y)
        -- circfill(x, y, 1)
    end
end