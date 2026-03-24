# Larlen Loot Frame Changelog

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
