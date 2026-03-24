# Larlen Loot Frame

## What Does It Do?

The default Blizzard loot display is bare-bones. You get a tiny popup, no price info, no way to tell what just dropped in your group, and zero customisation. Larlen Loot Frame replaces all of that with a proper loot feed you can actually make your own.

Every item, gold pickup, currency, reputation gain, and honor reward flows into a clean scrolling feed with rarity-coloured bars, inline item levels, AH prices, and animated glow effects based on value. There is a completely separate feed for group loot so you can see what your party or raid is picking up without it cluttering your personal drops. See something you like or an upgrade someone else looted? Click the icon to ask for it in party, instance, or raid chat - or whisper them directly for that specific item. Add items to a wishlist so you never miss a target drop, blacklist junk you never want to see again, set up sound alerts for valuable loot, and filter by rarity, item type, or category.

Don't like a feature? Turn it off. Every single element is toggleable and adjustable through the options panel - the addon works the way you want it to. Want animated glows, sound alerts, and all the quality of life? Go ahead. Prefer a clean, minimal information feed with nothing extra? That works too. It is your loot frame, set it up however you like.

It is also lightweight. No bundled textures or fonts, no bloat, no taint errors, no lag. Just install it and loot something.

> **No hard dependencies.** Works out of the box with just the base game. Optionally reads AH prices from [Auctionator](https://www.curseforge.com/wow/addons/auctionator) or [TradeSkillMaster](https://www.curseforge.com/wow/addons/tradeskill-master) if installed - otherwise shows vendor prices only.

---

### Why use this over the default loot frame or other loot addons?

The built-in Blizzard loot display gives you a popup with an item name and that's about it. No prices, no item level, no way to see what your group looted, no glow, no sound, no filtering, no customisation. It does the bare minimum and nothing else.

Other loot feed addons improve on that, but most of them only go so far. You typically get a basic scrolling feed with a few toggles, maybe a price column, and that's where the options end. If you want per-rarity durations, value-based glow tiers with custom colours, a separate group loot feed, wishlist tracking with its own glow and sound, a blacklist, category filters for pets and mounts, or the ability to adjust row height, spacing, opacity, and fonts independently for each feed - you are usually out of luck.

Larlen Loot Frame was built to cover all of that without the performance cost. It uses frame pooling, deferred event processing, and zero bundled assets so it stays lightweight no matter how much you customise it. If you just want a better loot display that works out of the box, it does that. If you want to fine-tune every detail, it lets you do that too.

---

## Core Features

* **Personal Loot Feed:** Items, gold, currency, honor, and reputation gains show up as timed rows with colour-coded edge bars so you can tell rarity at a glance. Pets, mounts, and quest items each get their own distinct colour too.
* **Group Loot Feed:** A fully separate feed for party and raid loot with its own layout, size, position, and filters. You always know what your group picked up without it mixing into your personal feed.
* **AH Price Display:** Vendor price is always shown. If you have Auctionator or TSM installed, the AH price appears right next to it. TSM supports both dbmarket and dbminbuyout.
* **Gear Details:** Item level, armor type, sockets, and tertiary stats like Leech or Speed are shown inline on each row - no tooltip hovering needed.
* **Stack Merging:** Looting the same item multiple times refreshes the existing row and updates the count instead of creating duplicates. Keeps things clean during mass farming.

---

## Glow Effects & Sound Alerts

* **Value-Based Glow Tiers:** Set up as many glow tiers as you want, each with its own colour and gold threshold. Cheap drops can glow green, expensive ones purple, jackpots orange - totally up to you.
* **Three Glow Styles:** Pixel (animated pixel border), AutoCast (orbiting sparkles), and Blizzard (the classic action button glow). You can apply the glow to the full bar or just the icon.
* **Adjustable Parameters:** Tweak the number of lines or particles, animation speed, and thickness for each style. Sliders automatically grey out when a parameter does not apply to the selected style.
* **Sound Alerts:** Play a sound when something valuable drops. Set a gold threshold so it only triggers on the good stuff. Wishlisted items can have their own separate sound. Works with all built-in WoW sounds and any LibSharedMedia sounds from your other addons.

---

## Wishlist & Blacklist

* **Item Wishlist:** Add the specific items you are farming for. When one drops, it gets its own independent glow effect with separate style, colour, and sound alert - completely independent from the value-based glow. Great for mount farming, transmog hunting, or tracking specific crafting materials.
* **Item Blacklist:** Shift + Right-Click any row in the feed to instantly blacklist that item so it never shows up again. You can also manage the full blacklist from the options panel. Useful for hiding grey vendor trash, low-value crafting mats, or anything else you just don't care about.
* **Wishlist-Only Mode:** When enabled, the feed only shows items on your wishlist. Everything else gets filtered out. Perfect for target farming sessions where you only want to see the drops that matter.

---

## Group Loot Tools

* **"Need?" Whisper Button:** One click to whisper a party member and ask if they need an item. The message template is customisable and the item link gets inserted automatically.
* **"Offer in Group" Button:** Announce an item to your party or raid channel with a single click using a customisable message.
* **Upgrade & Transmog Indicators:** An arrow shows up on gear that is an item level upgrade for you. A wardrobe icon appears on uncollected appearances. Great for spotting trade opportunities at a glance.

---

## Full Customisation

Most loot addons give you a handful of toggles and call it a day. Larlen Loot Frame lets you adjust pretty much everything:

* **Layout:** Feed width, row height, spacing, max visible rows, grow direction, feed opacity, row background opacity, fade-out time - all adjustable independently for both the personal and group feeds.
* **Per-Rarity Durations:** Set exactly how long each quality tier stays on screen. Poor, Common, Uncommon, Rare, Epic, Legendary, Currency, Quest, Gold, Honor, and Reputation each have their own timer.
* **Per-Rarity Filters:** Hide any rarity tier entirely. Personal and group feeds have independent filter sets so you can show everything in your personal feed but only Rare+ in group, for example.
* **Category Filters:** Toggle pets, mounts, housing items, reputation, and guild reputation on or off individually.
* **Font Picker:** Supports all LibSharedMedia fonts. If you use ElvUI, DBM, or any addon that registers fonts, they all show up here. Otherwise it falls back to the default WoW font.
* **Profiles:** Create, copy, rename, and delete profiles. Switch per character. Import and export settings as encoded strings to share your setup with friends or between accounts.

---

## Lightweight & Taint-Free

This addon was designed to be as light as possible. Row frames are recycled from a pool so nothing gets created or destroyed while you are looting. All loot event processing is deferred to avoid the taint errors and "secret string value" crashes that break similar addons. There are no bundled textures or font files - everything uses LibSharedMedia and in-game assets. Auctionator and TSM are completely optional; the addon works fine without either.

---

## Chat Commands

* `/llf` - Open the settings window
* `/llf preview` - Show sample loot rows
* `/llf clear` - Clear all rows from both feeds
* `/llf unlock` - Unlock the feed for repositioning
* `/llf lock` - Lock the feed in place
* `/llf minimap` - Toggle the minimap icon on or off
* `/llf enable` / `/llf disable` - Enable or disable the addon

---

## How To Use

1. Install the addon and reload your UI.
2. Loot something - the feed appears automatically.
3. Type `/llf` to open settings and tweak everything to your liking.
4. Optionally install **Auctionator** or **TSM** if you want AH prices shown.

---

## Credits & Inspiration

This addon was heavily inspired by the [Loot Frame](https://wago.io/-IWPKK1il) WeakAura created by **Hypocrit#11396**. I used it extensively while playing WoW Classic and enjoyed it so much that I decided to build a bigger, standalone version from the ground up for Retail.