# CurseForge Project Submission

## Name

Priority Marker Icons

## Summary

Automatically highlights priority dungeon enemies with local icons above their nameplates.

## Description

Priority Marker Icons is a lightweight World of Warcraft Retail addon that places
clear, local icons above the nameplates of important enemies in supported
dungeons. It helps players identify priority targets, dangerous casters,
summons, and totems at a glance without requiring mouseover actions, target
changes, macros, or additional combat key presses.

Unlike traditional auto-marking addons, Priority Marker Icons does not assign or
modify Blizzard raid markers. Its icons are rendered locally and are visible
only to the player running the addon, so they cannot interfere with party or
raid marker assignments.

The addon includes predefined priority targets for:

- Den of Nalorakk
- King's Rest
- Murder Row
- The Blinding Vale
- Voidscar Arena
- Altar of Fangs
- Ruby Life Pools
- Temple of Sethraliss

Priority Marker Icons uses familiar marker shapes such as Skull, Cross, Diamond,
Moon, Square, Star, Circle, and Triangle. Each supported NPC is assigned a
consistent marker that appears automatically when its nameplate becomes
available.

Features:

- Automatic local icons above configured enemy nameplates
- No targeting, mouseover, macros, or extra combat keybinds required
- Does not consume or overwrite shared Blizzard raid markers
- Lightweight filesystem-based NPC database
- Separate NPC definitions for each supported dungeon
- Test mode for checking icon placement
- Mouseover diagnostic command for troubleshooting

Commands:

- `/pmi` or `/prioritymarkericons` displays addon instructions.
- `/pmi test` toggles test icons above visible nameplates.
- `/pmi inspect` reports identity information available for the unit under the
  cursor.

The legacy `/am` and `/automarker` aliases are also supported.

The included NPC database currently uses English NPC names and is intended for
the English World of Warcraft client. Icons are local and require enemy
nameplates to be enabled.

## Project License

All Rights Reserved

This option allows players to download and use the addon while keeping control
over redistribution, modified releases, and reuse of the source code or project
assets. If open-source contributions and forks are preferred later, MIT License
is a suitable alternative.

## Class

Addons

## Main category

Unit Frames

## Additional categories

- Combat
- Boss Encounters

## Logo Image

Upload `branding/Priority-Marker-Icons-logo-400.png`.

The full-resolution source is available as
`branding/Priority-Marker-Icons-logo.png`.
