function draw_ui()
    if mode == "playing" then
        -- draw borders
        local border_col = 7
        if world.player and world.player.hp == 2 then border_col = 9 end
        if world.player and world.player.hp == 1 then border_col = 8 end
        line(0, 0, 0, 127, border_col)
        line(0, 0, 127, 0, border_col)
        line(0, 127, 127, 127, border_col)
        line(127, 0, 127, 127, border_col)
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