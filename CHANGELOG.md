# Larlen Loot Frame Changelog

## v1.2.0
- Added new Font section with font size offset slider - can be configured separately for personal and group feeds
- Added font outline picker for personal and group feeds
- Added colour pickers for row elements (item level, sockets, tertiary stats, owned count, and more) - can be set per feed
- Moved group feed player name colour to the Font section; custom colour can now be set when class colouring is off
- Added scale slider (0–200%) for personal and group feeds
- Row background opacity now also applies to the whisper and offer (G/W) buttons
- Removed "Minimum Rarity to Show" from group loot - rarity is already managed through the Filters tab
- Added "Show upgrade track icon" toggle to the group loot Indicators section, same as personal loot
- Renamed the "Need?" whisper button toggle to "Show message buttons to ask for items you want"
- Reworked message input layout for "Offer in Group" and "Need?" - label and box now on the same line, hints moved next to Reset Message button

## v1.1.3
- Added class colour coding for player names in the group loot feed, with a toggle to disable it

## v1.1.2
- Updated upgrade arrow to use the native WoW bag UI atlas for a cleaner look
- Updated transmog indicator to use the native WoW transmog atlas icon
- Fixed and adjusted test rows behaviour

## v1.1.1
- Fixed gold amounts doubling when world quest rewards merged with other gold events
- Fixed crafted item counts showing 1 instead of the correct quantity when crafting multiple items
- Added AH price display to group loot feed rows, matching personal loot behaviour

## v1.1.0
- Improved performance in heavy loot moments, including faster AH price handling and lower idle CPU usage
- Fixed taint and secret-string related errors in deferred loot, currency, honor, reputation, and encounter processing
- Added personal feed enable/disable handling with clearer feedback when test rows are triggered while a feed is disabled
- Improved group loot controls so party/raid toggles are properly gated and easier to manage
- Added configurable rarity bar width/offset and expanded icon/row border size and offset controls
- Improved options layout around Group Loot and Copy Personal Layout, including clearer placement and tooltip text
- Renamed "Show crafting/gathering quality icon" to "Show quality icon" for clearer wording

## v1.0.9
- Fixed Lua taint errors comprehensively across all files - all string method calls on event-sourced strings replaced with safe global equivalents across Core.lua, Config.lua, and PriceHelper.lua

## v1.0.8
- Fixed Lua taint error in reputation handler (Core.lua:498) - same root cause as the honor fix in 1.0.7, now resolved in both handlers

## v1.0.7
- Fixed gold gains showing in the feed even when Blizzard loot popups were disabled
- Fixed quality icon showing incorrect colour for certain item tiers
- Cleaned up gold value number formatting for better readability
- Fixed Lua taint error when receiving honor (Core.lua:469 secret string)
- Added enable/disable toggle for the personal loot feed independently of the group feed
- Cleaned up Filters and Durations pages - removed inapplicable group loot options (currency, honor) that could never trigger
- Improved wording and labelling clarity across Filters, Durations, and Price options pages

## v1.0.6
- Price lines now use two fixed right-side rows: AH on top, vendor in middle when both are enabled
- When vendor price is disabled, AH price now sits in the middle row for consistent alignment
- Added "Price prefixes" option with four modes: None, AH only, Vendor only, AH + Vendor
- Added vendor prefix support with its own colour styling

## v1.0.5
- Added customisable row border - pick any LibSharedMedia border texture, size, and color

## v1.0.4
- Fixed crafting/gathering quality icon display on loot rows
- Added upgrade track tier display (Explorer/Adventurer/Veteran/Champion/Hero/Myth) on gear rows with toggle
- Both quality icon and upgrade track tier shown on the same line as item subtype
- Renamed "Show bag count" to "Show owned count" - now correctly reflects equipped items
- Currency balance (e.g. Timewarped Badge count) hidden when "Show owned count" is off
- "Show owned count" toggle now updates the feed live without needing test rows locked
- Clear Test button now resets the Lock/Unlock button state correctly on both feeds
- Lock Test no longer replays sound notifications
- AH price no longer flickers when pressing Lock Test

## v1.0.3
- Fixed wishlist sound section being clickable when wishlist filter is disabled
- Fixed error spam from C_HousingCatalog API change requiring a second argument

## v1.0.2
- Added separate wishlist filters for currency and mounts/pets
- Added ESC key support to close options window
- Fixed wishlist/blacklist filtering to apply to test rows live

## v1.0.1
- Fixed icon border layering - borders now render above the icon
- Fixed mount/pet border colors to show actual rarity instead of fixed category colors

## v1.0.0
- Initial release.
- Loot feed overlay for items, gold, currencies, and reputation gains.
- Quality-coloured left edge bar per row for instant rarity identification.
- Item level, socket, and tertiary stat display for gear.
- Vendor sell price display with optional copper/silver sub-units.
- AH price support via Auctionator (v1 API).
- AH price support via TradeSkillMaster - dbmarket and dbminbuyout sources.
- Stack price (count × vendor price) toggle.
- Stack row merging - same item looted multiple times refreshes the existing row.
- Per-rarity display duration settings (Poor through Legendary, Currency, Quest/Heirloom, Gold).
- Per-rarity filter to suppress any quality tier entirely.
- Feed layout controls: width, row height, spacing, max rows, opacity.
- Grow-up / grow-down direction toggle.
- Fade-out animation with configurable duration.
- Row frame pool - zero GC pressure during looting.
- Draggable feed position with drag handle (unlocked via /llf unlock).
- Position auto-saved to SavedVariables on drag-stop.
- Minimap button via LibDataBroker + LibDBIcon with per-character visibility.
- Font picker with LibSharedMedia support for 50+ fonts.
- Full slash command set: /llf, preview, clear, unlock, lock, minimap, enable, disable.
- Taint-free loot processing - all chat event handling deferred to break the WoW taint chain.
- No bundled fonts or textures - uses LibSharedMedia or falls back to WoW defaults.
- Group loot feed with separate layout, dimensions, filters, and positioning for party and raid loot.
- "Need?" whisper button on group loot rows with customisable message template.
- "Offer in Group" button to offer items to your party/raid with a customisable message.
- Item Wishlist with search, add/remove, and optional glow with independent style, colour, and sound settings.
- Item Blacklist - Shift + Right-Click any feed row to permanently hide that item.
- Value-based glow tiers - unlimited custom tiers with per-tier colour and gold threshold.
- Three glow styles: Pixel, AutoCast, and Blizzard (Action Button Glow) via LibCustomGlow.
- Glow target mode: full bar or icon only.
- Glow parameter sliders (lines/particles, speed, thickness) with automatic greying out for unsupported params per style.
- Sound alerts on high-value loot with configurable gold threshold and sound picker.
- Separate wishlist sound alert with its own sound choice.
- LibSharedMedia sound support - all LSM-registered sounds available alongside built-in SOUNDKIT sounds.
- Upgrade indicator (arrow icon) on gear that is an item level upgrade.
- Transmog indicator (wardrobe icon) on uncollected appearances.
- Inventory count display on loot rows.
- Reputation gain display in the loot feed.
- Honor gain display in the loot feed.
- Per-rarity filters for group loot independent of personal loot filters.
- Filter toggles for pets, mounts, housing items, reputation, and guild reputation.
- Row background opacity and feed background opacity controls.
- Icon border thickness setting.
- Max item name length truncation setting.
- Suppress default Blizzard loot window and toasts option.
- Profile system with create, copy, rename, delete, and per-character switching.
- Scalable options window with saved position.
- Test rows with Lock Test button for live preview of all display settings.
- Live update of test rows when changing any display, glow, or layout setting.
- Tracked glow system to prevent glow conflicts between value and wishlist glows.
- Import/export profile settings via encoded strings (LibDeflate).
