pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include player.lua
#include boss.lua
#include world.lua
#include control.lua
#include menu.lua
#include transition.lua
#include ui.lua
#include pattern.lua
#include attack.lua
#include collisions.lua
#include particle.lua
#include square_boss.lua
#include circle_boss.lua

function _init()
    -- allows keyboard and mouse
    poke(0x5f2d, 0x1 | 0x2)
    SCREEN = {
        w = 127,
        h = 127,
        hw = 63.5,
        hh = 63.5
    }

    frame_timer = 0
    mode = "menu"
    transition = { active = false }
    world = {
        player = nil,
        boss = nil,
        projectiles = {},
        particles = {}
    }
    telegraph_timer = 30 * 2
    shake = 0
    debug_list = {}
    red_frame = 0
    white_frame = 0

    -- while we don't have a menu
    set_mode("playing")
end

function _update()
    if shake > 0 then
        shake -= 1
    end
    if red_frame > 0 then
        red_frame -= 1
    end
    if white_frame > 0 then
        white_frame -= 1
    end

    if mode == "playing" then
        -- projectiles are being deleted in the update_world which isn't ideal
        update_world()
        update_collisions()
        update_control()
    elseif mode == "menu" then
        update_menu()
    end

    update_transition()
    frame_timer += 1
end

function _draw()
    cls()
    if shake > 0 then
        camera(rnd(3) - 1.5, rnd(3) - 1.5)
    else
        camera(0, 0)
    end

    if mode == "playing" then
        draw_world()
        draw_ui()
    elseif mode == "menu" then
        draw_menu()
    end

    if transition.active then draw_transition() end
    if red_frame > 0 then rectfill(0, 0, 127, 127, 8) end
    if white_frame > 0 then rectfill(0, 0, 127, 127, 6) end
    debug()
end

function debug()
    for d in all(debug_list) do
        print(d)
    end
    debug_list = {}
end

function set_mode(new_mode)
    if mode == new_mode then return end

    -- exit logic
    if mode == "playing" then
        -- Cleanup playing mode
    end

    mode = new_mode

    -- startup logic
    if mode == "menu" then
        -- Setup menu mode
    elseif mode == "playing" then
        world.player = player:new()
        world.boss = circle_boss:new()
    end
end

__gfx__
00000000066066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
