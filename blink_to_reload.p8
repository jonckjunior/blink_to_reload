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

    -- while we don't have a menu
    set_mode("playing")
end

function _update()
    if mode == "playing" then
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
    if world.player != nil then
        print(world.player.hp)
    end
    if world.boss != nil then
        print(world.boss.hp)
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
        world.boss = boss:new()
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
