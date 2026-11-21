# Blink to Reload

A PICO-8 boss rush where you have one bullet, and the only way to reload is to blink.

**[Play it in the browser on Lexaloffle](https://www.lexaloffle.com/bbs/?tid=153709)**

<!-- TODO: GIF of a boss fight, showing a shot followed by a blink-reload -->

## The idea

You carry a single shot. Firing empties it, and the only way to get it back is to **blink**: a short teleport toward your cursor that starts a one-second reload. Blinking also gives a few frames of invulnerability, so the same move that reloads your gun is also how you slip through attacks. Blinks have a one-second cooldown, so every shot becomes a decision about where you'll be safe to blink next.

## Bosses

Two bosses, each changing its attack patterns as its health drops:

- **Square:** sweeps, screen quadrants, halves, checkerboards, growing and swinging squares.
- **Circle:** chasing circles, pulsing rings and breathing rings.

## Controls

PICO-8 with mouse and keyboard enabled:

| Action | Input |
|---|---|
| Move | E S D F |
| Aim | Mouse |
| Shoot | Left click |
| Blink (reloads when empty) | Right click |

Clicks are buffered for a few frames, so a blink or shot pressed slightly early still happens.

## Code

The cart is split into plain Lua modules pulled in with `#include` (player, bosses, attack patterns, collisions, particles, menu, transitions, UI), so it can be edited in any editor. Open `blink_to_reload.p8` in PICO-8 to run it.

Project page: [jonck.dev/projects/blink-to-reload](https://jonck.dev/projects/blink-to-reload/)
