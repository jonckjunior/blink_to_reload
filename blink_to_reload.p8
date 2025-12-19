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

function _init()
    -- allows keyboard and mouse
    poke(0x5f2d, 0x1 | 0x2)

    frame_timer = 0
    mode = "menu"
    transition = { active = false }
    world = {
        player = nil,
        boss = nil,
        projectiles = {}
    }
    telegraph_timer = 30 * 2
    shake = 0
    debug_list = {}

    -- while we don't have a menu
    set_mode("playing")
end

function _update()
    if shake > 0 then
        shake -= 1
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
    debug()
end

function debug()
    for d in all(debug_list) do
        print(d)
    end
    debug_list = {}
    if world.boss then
        print(world.boss.hp, 2, 2)
        print(#world.boss.patterns, 2, 8)
    end
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
        world.boss = boss_1:new()
    end
end

__gfx__
00000000066066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
