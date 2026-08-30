# Priority Marker Icons

Priority Marker Icons is a standalone World of Warcraft Retail addon that automatically
displays local icons above important enemy nameplates. It does not set Blizzard
raid markers, change your target, or require extra key presses. The icons are
visible only to the player running the addon.

## Features

- Automatically highlights configured dungeon NPCs as soon as their nameplates
  appear.
- Uses familiar Star, Circle, Diamond, Triangle, Moon, Square, Cross, and Skull
  symbols.
- Requires no mouseover, targeting, macros, or combat keybinds.
- Does not modify shared raid markers or affect other players.
- Includes an optional test mode and mouseover diagnostic command.
- Organizes NPC textures in separate folders for each dungeon.
- Includes persistent options for icon size, position, opacity, combat visibility,
  and enabled dungeons.
- Detects the active supported dungeon and only checks its texture folder.
- Provides a draggable `PMI` minimap button for opening the addon options.

## Installation

1. Copy the `PriorityMarkerIcons` folder into
   `_retail_\Interface\AddOns\PriorityMarkerIcons`.
2. Start World of Warcraft or type `/reload` if the game is already running.
3. Make sure enemy nameplates are enabled.
4. Enter a supported dungeon. Configured NPCs will display an icon above their
   nameplates automatically.

## Supported dungeons

### Den of Nalorakk

- `Earthwhisper Tender` — NPC ID `241814`: Green Triangle
- `Keen-Eyed Striker` — NPC ID `245752`: Purple Diamond
- `Starvation Effigy` — NPC ID `245567`: Skull
- `Territorial Matriarch` — NPC ID `241808`: Skull
- `Spirit of Hunger` — NPC ID `245855`: Moon
- `Frigid Mauler` — NPC ID `241872`: Cross
- `Stormbound Mystic` — NPC ID `245139`: Square

### King's Rest

- `Risen Hexer` — NPC ID `134174`: Skull
- `Shadow-Borne Champion` — NPC ID `134158`: Skull
- `King A'akul` — NPC ID `137484`: Skull
- `King Rahu'ai` — NPC ID `134331`: Skull
- `Seneschal M'bara` — NPC ID `134251`: Diamond
- `Half-Finished Mummy` — NPC ID `270502`: Triangle
- `Phantom Hex Priest` — NPC ID `135204`: Moon
- `Healing Tide Totem` — NPC ID `137591`: Skull

### Murder Row

- `Felonious Mage` — NPC ID `236084`: Diamond
- `Bribed Guard` — NPC ID `236071`: Skull
- `Bribed Captain` — NPC ID `252529`: Skull
- `Seductive Sayaad` — NPC IDs `255604` and `236082`: Star
- `Shivan Punisher` — NPC ID `235465`: Skull
- `Fel Invoker` — NPC ID `235268`: Moon
- `Wrathguard Flayer` — NPC ID `235267`: Cross
- `Corrupted Warlock` — NPC ID `235265`: Square
- `Felmaster Lucsei` — NPC ID `236905`: Skull

Both `Seductive Sayaad` variants use the same marker because they share the
same name. Secret values prevent the addon from reading their NPC IDs to tell
them apart.

### The Blinding Vale

- `Radiant Spellsower` — NPC ID `245336`: Diamond
- `Virid Grovekeeper` — NPC ID `245346`: Skull
- `Sporeblight Belcher` — NPC ID `254850`: Skull
- `Lightfeather Petalwing` — NPC ID `245484`: Star
- `Leafy Grovecrawler` — NPC ID `245460`: Square

### Voidscar Arena

- `Dominated Brawler` — NPC ID `238883`: Cross
- `Enthralled Shaman` — NPC ID `241496`: Diamond
- `Voidtouched Magi` — NPC ID `252072`: Skull
- `Protective Turtle` — NPC ID `249603`: Square
- `Angry Krolusk` — NPC ID `249590`: Circle
- `Chitigoth` — NPC ID `244260`: Skull
- `Kilivore Screamer` — NPC ID `243766`: Star
- `Brutal Overseer` — NPC ID `252053`: Triangle
- `Voidminder` — NPC ID `244708`: Moon
- `Devouring Brutalizer` — NPC ID `268184`: Skull

### Altar of Fangs

- `Twinfang Harrower` — NPC ID `261554`: Skull
- `Primal Serpent` — NPC ID `261560`: Circle
- `Ritual Chieftain` — NPC ID `270306`: Skull
- `Rattling Writhe` — NPC ID `262011`: Skull
- `High Evolutionist` — NPC ID `261557`: Diamond
- `Ula'tek's Chosen` — NPC ID `263109`: Skull

### Ruby Life Pools

- `Primal Juggernaut` — NPC ID `188244`: Skull
- `Flashfrost Chillweaver` — NPC ID `188067`: Diamond
- `Defier Draghar` — NPC ID `187897`: Skull
- `Primalist Cinderweaver` — NPC ID `190207`: Square
- `Blazebound Destroyer` — NPC ID `190034`: Skull
- `Tempest Channeler` — NPC ID `198047`: Skull
- `High Channeler Ryvati` — NPC ID `197535`: Skull

### Temple of Sethraliss

- `Storm Adept` — NPC ID `134990`: Diamond
- `Sandfury Stonefist` — NPC ID `134991`: Skull
- `Sand-Sworn Rider` — NPC ID `134629`: Skull
- `Faithless Subjugator` — NPC ID `134364`: Square
- `Brood Tender` — NPC ID `139425`: Moon

## Commands

- `/pmi` or `/prioritymarkericons` — Display addon instructions.
- `/pmi options` — Open the addon settings panel.
- `/pmi on` / `/pmi off` — Enable or disable automatic icons.
- `/pmi test` — Toggle all eight marker symbols above visible nameplates to test
  positioning, size, opacity, and compatibility.
- `/pmi status` — Report the current instance, matched texture folder, map ID,
  visible nameplate count, and active settings.
- `/pmi inspect` — Report the identity information available for the unit under
  the cursor, including the detected nameplate anchor.
- `/pmi size 36` — Set icon size from 16 to 64 pixels.
- `/pmi offset 6` — Set the vertical offset from -20 to 60 pixels.
- `/pmi alpha 1` — Set icon opacity from 0.2 to 1.
- `/pmi dungeononly` — Toggle display outside supported dungeons.
- `/pmi combatonly` — Toggle display only while in combat.
- `/pmi minimap` — Show or hide the minimap options button.
- `/pmi debug` — Toggle diagnostic event messages.
- `/pmi reset` — Restore default settings.

The legacy `/am` and `/automarker` aliases are also supported.

Optional Triangle and Square mouseover keybinds remain available in the game's
Key Bindings menu as manual fallbacks. They are not required for automatic
icons.

## Settings

Enter `/pmi options` to open the panel under the game's AddOns settings. The
panel can enable or disable the addon, restrict icons to supported dungeons or
combat, change icon size, vertical offset and opacity, enable diagnostics, and
enable individual dungeon databases. It can also show or hide the draggable
`PMI` minimap button. Clicking that button opens this panel directly. Settings,
including the minimap position, are saved account-wide in
`PriorityMarkerIconsDB`.

## How it works

Recent WoW versions can mark NPC names, GUIDs, and NPC IDs as secret values
inside instances. Priority Marker Icons never reads or compares the secret NPC name.
Instead, it passes that value directly to `FontString:SetFormattedText` as part
of a texture path.

The database is stored in the filesystem:

```text
Media\Den of Nalorakk\Earthwhisper Tender.tga
Media\Kings Rest\Risen Hexer.tga
Media\Murder Row\Bribed Guard.tga
```

Inside a supported dungeon, the addon attempts only that dungeon's texture path
for every visible nameplate. If dungeon-only mode is disabled in an unsupported
area, all enabled dungeon paths are attempted as a fallback. Only a texture
whose filename matches the NPC name can be rendered. Missing textures remain
invisible. The NPC IDs listed above are documentation only.

The dungeon folder is detected and cached as the player enters the instance,
before a Mythic+ challenge begins. When `CHALLENGE_MODE_START` fires, the addon
keeps using that cached folder. If the instance name or ID later becomes secret,
zone updates preserve the cache instead of falling back to all dungeon folders.
The cache is cleared after leaving the instance or when a different readable
instance ID is detected.

## Adding or changing NPC markers

The `Media` directory contains a complete set of marker templates:

- `_star.tga`
- `_circle.tga`
- `_diamond.tga`
- `_triangle.tga`
- `_moon.tga`
- `_square.tga`
- `_cross.tga`
- `_skull.tga`

To add an NPC:

1. Copy the desired template into the appropriate dungeon folder.
2. Rename it to the NPC's exact in-game name, preserving spaces, hyphens, and
   apostrophes. For example:

   ```text
   Media\Den of Nalorakk\Stormbound Mystic.tga
   ```

3. If adding a new dungeon, add its folder name to `DUNGEON_FOLDERS` near the
   top of `Core.lua`.
4. Type `/reload` after adding or replacing textures.

## Limitations

- Markers are local and cannot be seen by party members unless they also run
  the addon.
- The current database uses English NPC filenames and therefore targets the
  English game client. Localized clients require files named exactly as the
  localized NPC names.
- NPCs with the same name always receive the same icon, even if their NPC IDs
  differ.
- Individual NPC toggles are not available because secret names cannot safely
  be compared or used as Lua table keys; dungeon databases can be toggled as a
  whole in the settings panel.
- Icons require the NPC's nameplate to be available.
