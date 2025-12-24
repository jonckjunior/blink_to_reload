function update_menu()
    menu.t += 1
    menu.aim_x = stat(32)
    menu.aim_y = stat(33)

    -- left / right
    if circle_collision(menu.square.x0 + 2, menu.square.y0 + 2, 6, menu.aim_x, menu.aim_y, 3) then
        select_square()
    elseif circle_collision(menu.circle.x, menu.circle.y, 6, menu.aim_x, menu.aim_y, 3) then
        select_circle()
    end

    -- confirm
    if stat(34) == 1 then
        start_game(menu.selected)
    end
end

function draw_menu()
    cls(0)
    local txt = "select your challenger"
    local txt_x = (SCREEN.w - #txt * 4) / 2
    print(txt, txt_x + 5, 20)

    -- subtle pulse
    local pulse = sin(menu.t * 0.05)
    if pulse > 0.5 then
        pulse = 1
    else
        pulse = 0
    end

    -- square
    local sq_col = (menu.selected == "square") and 8 or 5

    if menu.selected == "square" then
        rectfill(
            menu.square.x0 + pulse,
            menu.square.y0 + pulse,
            menu.square.x1 - pulse,
            menu.square.y1 - pulse,
            8
        )
    else
        rectfill(
            menu.square.x0,
            menu.square.y0,
            menu.square.x1,
            menu.square.y1,
            sq_col
        )
    end

    if pulse == 1 then
        pulse = -1
    end
    -- circle
    local c_col = (menu.selected == "circle") and 8 or 5
    circfill(
        menu.circle.x,
        menu.circle.y,
        menu.circle.r + (menu.selected == "circle" and pulse or 0),
        c_col
    )

    -- selector brackets
    print("[", menu.p1.x, menu.p1.y, 7)
    print("]", menu.p2.x, menu.p2.y, 7)

    print(" e", menu.square.x0, 96 - 6, 6)
    print("sdf", menu.square.x0, 96, 6)
    print("+", menu.square.x0 + 20, 96 - 3, 6)
    spr(2, menu.square.x0 + 20 + 10, 96 - 6)
    spr(3, menu.square.x0 + 30 + 10, 96 - 6)

    circfill(menu.aim_x, menu.aim_y, 1, 8)
end

function select_square()
    menu.p1 = {
        x = menu.square.x0 - 3,
        y = menu.square.y0
    }
    menu.p2 = {
        x = menu.square.x0 + 5,
        y = menu.square.y0
    }
    menu.selected = "square"
end

function select_circle()
    menu.p1 = {
        x = menu.circle.x - 5,
        y = menu.circle.y - 2
    }
    menu.p2 = {
        x = menu.circle.x + 3,
        y = menu.circle.y - 2
    }
    menu.selected = "circle"
end

function start_game(boss_id)
    next_boss = boss_id
    transition:start(
        function()
            set_mode("playing")
        end,
        nil,
        "into_playing"
    )
end