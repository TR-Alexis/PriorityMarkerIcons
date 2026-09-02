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
- Allows each configured NPC marker to be enabled or disabled individually.
- Allows every configured NPC to switch between the eight standard marker
  icons directly from its in-game settings row.

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
- `Thronclaw Gatherer` — Triangle (disabled by default)
- `Curious Yerling` — Star (disabled by default)
- `Terra Rumbler` — Cross (disabled by default)
- `Glacial Revenant` — Moon (disabled by default)
- `Avatar of Determination` — Diamond (disabled by default)
- `The Winter Squall` — Square (disabled by default)
- `Ruthless Totemcaller` — Purple Diamond (disabled by default)
- `Bonded Beasttamer` — Green Triangle (disabled by default)
- `Loyal Saberfang` — Circle (disabled by default)
- `Grizzled Warbringer` — Cross (disabled by default)
- `Loa Speaker Nanea` — Moon (disabled by default)

### King's Rest

- `Risen Hexer` — NPC ID `134174`: Skull
- `Shadow-Borne Champion` — NPC ID `134158`: Skull
- `King A'akul` — NPC ID `137484`: Skull
- `King Rahu'ai` — NPC ID `134331`: Skull
- `Seneschal M'bara` — NPC ID `134251`: Diamond (disabled by default)
- `Half-Finished Mummy` — NPC ID `270502`: Triangle
- `Phantom Hex Priest` — NPC ID `135204`: Moon
- `Healing Tide Totem` — NPC ID `137591`: Skull
- `Animated Guardian` — Square (disabled by default)
- `Minion of Zul` — Cross (disabled by default)
- `Umbral Warrior` — Triangle (disabled by default)
- `Queen Wasi` — Star (disabled by default)
- `King Timalji` — Diamond (disabled by default)
- `Bloodsworn Assassin` — Circle (disabled by default)
- `Guard Captain Atu` — Square (disabled by default)
- `Queen Patiaa` — Star (disabled by default)
- `Skeletal Hunting Raptor` — Circle (disabled by default)
- `Purification Construct` — Purple Diamond (disabled by default)
- `Interment Construct` — Square (disabled by default)
- `Embalming Fluid` — Moon (disabled by default)
- `Spectral Shaman` — Diamond (disabled by default)
- `Royal Berserker` — Cross (disabled by default)
- `Honored Raptor` — Green Triangle (disabled by default)
- `Ghostly Brute` — Triangle (disabled by default)
- `Shadow of Zul` — Purple Diamond (disabled by default)

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
- `Row Hooligan` — Cross (disabled by default)
- `Felwyrm` — Circle (disabled by default)
- `Street Sneak` — Triangle (disabled by default)
- `Massive Felwyrm` — Square (disabled by default)
- `Nibbles` — Star (disabled by default)
- `Kystia Manaheart` — Diamond (disabled by default)
- `Warehouse Worker` — Green Triangle (disabled by default)
- `Keen Taskmaster` — Purple Diamond (disabled by default)
- `Zaen Bladesorrow` — Cross (disabled by default)
- `Trained Felhunter` — Circle (disabled by default)
- `Unleashed Imp` — Star (disabled by default)
- `Demon Fly` — Triangle (disabled by default)
- `Xathuux the Annihilator` — Purple Diamond (disabled by default)
- `Defiled Golem` — Square (disabled by default)

Both `Seductive Sayaad` variants use the same marker because they share the
same name. Secret values prevent the addon from reading their NPC IDs to tell
them apart.

### The Blinding Vale

- `Radiant Spellsower` — NPC ID `245336`: Diamond
- `Virid Grovekeeper` — NPC ID `245346`: Skull
- `Sporeblight Belcher` — NPC ID `254850`: Skull
- `Lightfeather Petalwing` — NPC ID `245484`: Star (disabled by default)
- `Leafy Grovecrawler` — NPC ID `245460`: Square (disabled by default)
- `Lightgorged Lasher` — Diamond (disabled by default)
- `Lasher` — Green Triangle (disabled by default)
- `Underbrush Stalker` — Triangle (disabled by default)
- `Thorny Saptor` — Cross (disabled by default)
- `Overgrown Hydra` — Square (disabled by default)
- `Spineshield Beetle` — Circle (disabled by default)
- `Luminous Thornmaw` — Star (disabled by default)
- `Potatoad Matriarch` — Purple Diamond (disabled by default)

### Voidscar Arena

- `Dominated Brawler` — NPC ID `238883`: Cross
- `Enthralled Shaman` — NPC ID `241496`: Diamond
- `Voidtouched Magi` — NPC ID `252072`: Skull
- `Protective Turtle` — NPC ID `249603`: Square (disabled by default)
- `Angry Krolusk` — NPC ID `249590`: Circle (disabled by default)
- `Chitigoth` — NPC ID `244260`: Skull
- `Kilivore Screamer` — NPC ID `243766`: Star
- `Brutal Overseer` — NPC ID `252053`: Triangle
- `Voidminder` — NPC ID `244708`: Moon
- `Devouring Brutalizer` — NPC ID `268184`: Skull
- `Longtooth Tuskarr` — Circle (disabled by default)
- `Feral Saberon` — Cross (disabled by default)
- `Lost Sethrak` — Moon (disabled by default)
- `Raj'kess the Spellstorm` — Diamond (disabled by default)
- `Aegyra the Unyielding` — Purple Diamond (disabled by default)
- `Sycophantic Tarasek` — Triangle (disabled by default)
- `Raging Raptor` — Cross (disabled by default)
- `Abducted Drakonid` — Square (disabled by default)
- `Brutok` — Star (disabled by default)
- `Savage Shredclaw` — Cross (disabled by default)
- `Watchful Harrower` — Diamond (disabled by default)
- `Agitated Voidscythe` — Purple Diamond (disabled by default)
- `Blistercreep` — Circle (disabled by default)
- `Scavenging Siphoid` — Green Triangle (disabled by default)
- `Toxic Creeper` — Moon (disabled by default)

### Altar of Fangs

- `Twinfang Harrower` — NPC ID `261554`: Skull
- `Primal Serpent` — NPC ID `261560`: Circle
- `Ritual Chieftain` — NPC ID `270306`: Skull
- `Rattling Writhe` — NPC ID `262011`: Skull
- `High Evolutionist` — NPC ID `261557`: Diamond
- `Ula'tek's Chosen` — NPC ID `263109`: Skull
- `Venom Leech` — Circle (disabled by default)
- `Ravenous Descendant` — Cross (disabled by default)
- `Rav'i` — Star (disabled by default)
- `Bloodletter` — Diamond (disabled by default)
- `The Writhing Coil` — Moon (disabled by default)
- `Blade of the Altar` — Purple Diamond (disabled by default)

### Ruby Life Pools

- `Primal Juggernaut` — NPC ID `188244`: Skull
- `Flashfrost Chillweaver` — NPC ID `188067`: Diamond
- `Defier Draghar` — NPC ID `187897`: Skull
- `Primalist Cinderweaver` — NPC ID `190207`: Square
- `Blazebound Destroyer` — NPC ID `190034`: Skull
- `Tempest Channeler` — NPC ID `198047`: Skull
- `High Channeler Ryvati` — NPC ID `197535`: Skull
- `Earthbound Guardian` — Square (disabled by default)
- `Deepstone Earthshaper` — Diamond (disabled by default)
- `Infused Whelp` — Star (disabled by default)
- `Thunderhead` — Circle (disabled by default)
- `Ruinous Stormbringer` — Purple Diamond (disabled by default)
- `Ashseer Flamelasher` — Moon (disabled by default)
- `Flamegullet` — Cross (disabled by default)
- `Blazebound Firestorm` — Square (disabled by default)
- `Storm Warrior` — Triangle (disabled by default)
- `Primal Thundercloud` — Diamond (disabled by default)

### Temple of Sethraliss

- `Storm Adept` — NPC ID `134990`: Diamond
- `Sandfury Stonefist` — NPC ID `134991`: Skull
- `Sand-Sworn Rider` — NPC ID `134629`: Skull
- `Faithless Subjugator` — NPC ID `134364`: Square
- `Brood Tender` — NPC ID `139425`: Moon
- `Barbed Krolusk` — Circle (disabled by default)
- `Sandswept Hunter` — Triangle (disabled by default)
- `Shrouded Fang` — Moon (disabled by default)
- `Lightning Serpent` — Diamond (disabled by default)
- `Poisonous Viper` — Green Triangle (disabled by default)
- `Krolusk Matriarch` — Square (disabled by default)
- `Dutiful Tamer` — Star (disabled by default)
- `Agitated Nimbus` — Circle (disabled by default)
- `Spark Channeler` — Diamond (disabled by default)
- `Imbued Stormcaller` — Purple Diamond (disabled by default)
- `Static Anomaly` — Square (disabled by default)
- `Orb Watcher` — Star (disabled by default)
- `Temple Disruptor` — Cross (disabled by default)
- `Faithless Conscript` — Triangle (disabled by default)
- `Twisted Hexxer` — Moon (disabled by default)
- `Faithless Tormentor` — Cross (disabled by default)
- `Corrupted Guardian` — Square (disabled by default)
- `Essence Defiler` — Purple Diamond (disabled by default)

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
enable individual dungeon databases. Each dungeon has its own settings
subcategory with an icon preview and checkbox for every configured NPC, plus
Enable All and Disable All controls. The panel can also show or hide the
draggable `PMI` minimap button. Clicking that button opens this panel directly.
Settings, including NPC visibility and the minimap position, are saved
account-wide in `PriorityMarkerIconsDB`.

Every dungeon displays a marker selector beside each NPC checkbox. Click it to
choose Star, Circle, Diamond, Triangle, Moon, Square, Cross, or Skull. The
choice is applied immediately and saved account-wide.

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

For per-NPC visibility, every marker also has a dedicated matching path:

```text
Media\NPCs\Den of Nalorakk\01\Earthwhisper Tender.tga
```

Every supported dungeon has one matching path for each selectable marker:

```text
Media\NPCs\Murder Row\04\moon\Fel Invoker.tga
Media\NPCs\Murder Row\04\skull\Fel Invoker.tga
Media\NPCs\Altar of Fangs\01\diamond\High Evolutionist.tga
```

The checkbox enables or disables that known path. The secret unit name is still
passed directly into the filename placeholder and is never compared or used as
a Lua table key. The file exists only for its matching NPC, so disabled paths
cannot render and enabled paths retain the original filesystem matching behavior.

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
- Individual NPC toggles apply when the addon has detected a supported dungeon.
  The optional all-folders fallback outside a detected dungeon uses the legacy
  flat database and does not apply individual NPC choices.
- Icons require the NPC's nameplate to be available.
