# CurseForge Project Submission

## Name

Priority Marker Icons

## Summary

Automatically highlights priority dungeon enemies with local icons above their nameplates.

## Description

Priority Marker Icons (PMI) is a lightweight World of Warcraft Retail addon that
places clear, local icons above important enemy nameplates in supported
dungeons. It helps identify priority targets, dangerous casters, summons, and
totems without changing targets or requiring additional actions during combat.

PMI does not assign or modify Blizzard raid markers. Its icons are rendered
locally and are visible only to the player running the addon, so they do not
consume party markers or interfere with the group's marker assignments.

## Key features

- Automatic local icons above configured enemy nameplates
- Familiar Skull, Cross, Diamond, Moon, Square, Star, Circle, and Triangle icons
- No targeting, mouseover, macros, or extra key presses required for automatic icons
- Does not consume or overwrite shared Blizzard raid markers
- Detects the active dungeon before Mythic+ starts and loads only its NPC folder
- Keeps the detected folder cached if NPC identity information becomes secret
- Persistent settings for icon size, vertical position, opacity, and visibility
- Optional combat-only mode and per-dungeon database toggles
- Per-NPC marker toggles with icon previews for every supported dungeon
- Per-NPC selection of any of the eight standard marker icons
- Clipboard-safe per-dungeon import/export strings with recognizable dungeon codes
- Clickable in-game chat links for sharing one dungeon's marks with other PMI users
- NPC search plus enabled, disabled, and marker filters
- Multi-selection and bulk marker assignment
- Live per-dungeon summaries with marker usage notices
- Optional NPC additions remain disabled until the player enables them (156
  configured NPCs in the current database)
- Draggable `PMI` minimap button that opens the addon settings
- Test, status, mouseover inspection, and debug tools
- No background communication, account connection, or data collection

## Supported dungeons

- Den of Nalorakk
- King's Rest
- Murder Row
- The Blinding Vale
- Voidscar Arena
- Altar of Fangs
- Ruby Life Pools
- Temple of Sethraliss

## Mythic+ behavior

PMI detects the dungeon when the player enters the instance, before the
Mythic+ challenge begins. It stores the matching dungeon folder and continues
using it after `CHALLENGE_MODE_START`, even if identity-related values later
become unavailable to addon code. The cache is cleared when the player leaves
the instance or enters a different one.

This allows PMI to check only the relevant dungeon folder instead of scanning
the complete database on every nameplate update.

## Configuration

Click the draggable `PMI` minimap button or enter `/pmi options` to open the
settings panel. Available options include:

- Enable or disable automatic icons
- Show icons only in supported dungeons
- Show icons only during combat
- Change icon size, vertical offset, and opacity
- Enable or disable individual dungeon databases
- Enable or disable the marker for each configured NPC
- Choose a different marker for any configured NPC
- Search and filter NPC lists
- Select multiple NPCs and assign their marker in one action
- Export or import an individual dungeon
- Share one dungeon's marks as a clickable chat link with import confirmation
- Reset an individual dungeon without affecting the rest of the configuration
- Show or hide the minimap button
- Enable diagnostic messages
- Restore the default configuration

Settings, individual NPC visibility, and the minimap button position are saved
account-wide.

## Commands

- `/pmi` or `/prioritymarkericons` displays addon instructions.
- `/pmi options` opens the in-game settings panel.
- `/pmi test` displays all marker symbols above visible nameplates.
- `/pmi status` reports the active instance, cached folder, map, and settings.
- `/pmi inspect` reports available information for the mouseover unit.
- `/pmi size 36` changes icon size from 16 to 64 pixels.
- `/pmi offset 6` changes the vertical offset from -20 to 60 pixels.
- `/pmi alpha 1` changes opacity from 0.2 to 1.
- `/pmi dungeononly` toggles supported-dungeon-only mode.
- `/pmi combatonly` toggles combat-only mode.
- `/pmi minimap` shows or hides the minimap shortcut.
- `/pmi debug` toggles diagnostic messages.
- `/pmi export KR` exports King's Rest; other supported codes are DN, MR, BV,
  VA, AF, RL, and TS.
- `/pmi import` opens the dungeon import dialog.
- `/pmi share KR` prepares a King's Rest marks message that PMI converts into a
  clickable link after it is sent; other supported codes are DN, MR, BV, VA,
  AF, RL, and TS.
- `/pmi reset` restores default settings.

The legacy `/am` and `/automarker` aliases are also supported.

## Installation

1. Extract the `PriorityMarkerIcons` folder into
   `_retail_\Interface\AddOns\`.
2. Start World of Warcraft or enter `/reload` if the game is already running.
3. Make sure enemy nameplates are enabled.
4. Enter a supported dungeon. Configured priority icons appear automatically.

## Important notes

- Enemy nameplates must be enabled.
- Icons are local; party members need their own copy of PMI to see them.
- The current NPC database uses English NPC filenames and is intended for the
  English game client.
- NPCs that share the same name also share the same icon because secret NPC IDs
  cannot be compared safely during Mythic+.

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
