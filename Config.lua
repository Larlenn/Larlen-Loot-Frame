local LLF = LarlenLootFrame
LLF.Config = {}
local Config = LLF.Config

Config.DEFAULTS = {
    enabled          = true,
    feedX            = 350,
    feedY            = 300,
    feedWidth        = 400,
    feedRowHeight    = 46,
    feedMaxRows      = 10,
    feedSpacing      = 4,
    feedGrowUp       = false,
    feedAlpha        = 1.0,
    feedBackground   = true,
    feedBgAlpha      = 0.75,
    rowBgAlpha       = 0.80,
    feedLocked       = false,
    feedFont         = "",
    durations = {
        [0] = 3,  [1] = 5,  [2] = 5,  [3] = 7,
        [4] = 10, [5] = 15, [6] = 5,  [7] = 7,
        [8] = 5,
        gold = 5,
        rep  = 5,
    },
    groupDurations = {
        [0] = 3,  [1] = 5,  [2] = 5,  [3] = 7,
        [4] = 10, [5] = 15, [6] = 5,  [7] = 7,
        [8] = 5,
        gold = 5,
    },
    fadeOutTime      = 0.5,
    showVendorPrice  = true,
    showAHPrice      = false,
    auctionAddon     = 1,
    tsmSource        = 1,
    showStackPrice   = true,
    showJunkAH       = true,
    pricePrefixMode  = 4,
    showCopperSilver = true,
    priceFormat      = 1,
    showIlvl         = true,
    showSubType      = true,
    showSockets      = true,
    showTertiary     = true,
    showCount        = true,
    countCorner      = "BOTTOMRIGHT",
    showRarityBar    = true,
    showIconBorder   = false,
    showUpgradeIndicator = true,
    showUpgradeParty     = false,
    showTransmogIndicator = true,
    showTransmogParty    = false,
    showUpgradeTrack     = true,
    showCraftingQuality  = true,
    iconBorderThickness = 2,
    rowBgTexture   = "",
    rowBorderStyle = "None",
    rowBorderSize  = 1,
    rowBorderColor = { 1, 1, 1, 1 },
    showRep          = true,
    showInvCount     = false,
    needMessage      = "{name}, do you need {item}?",
    offerEnabled     = true,
    offerMinRarity   = 2,
    offerMessage     = "Anyone want my {item}?",
    maxNameLength    = 32,
    personalFilters = {
        filterRarity = {
            [0]=true,[1]=true,[2]=true,[3]=true,
            [4]=true,[5]=true,[6]=true,[7]=true,[8]=true,
        },
        filterRep      = true,
        filterGuildRep = false,
        filterPets     = true,
        filterMounts   = true,
        filterHousing  = true,
    },
    groupFilters = {
        filterRarity = {
            [0]=true,[1]=true,[2]=true,[3]=true,
            [4]=true,[5]=true,[6]=false,[7]=false,[8]=false,
        },
    },
    suppressDefaultLoot = false,
    suppressTransmogToast = false,
    shiftClickBlacklist = true,
    blacklistEnabled = true,
    blacklist   = {},
    wishlist    = {},
    wishlistEnabled   = false,
    wishlistGroupLoot = false,
    showMinimap = true,
    minimapIcon = {},

    glowEnabled    = true,
    glowMode       = 1,
    glowType       = 1,
    glowLines      = 12,
    glowSpeed      = 0.35,
    glowThickness  = 2,
    glowLength     = nil,
    glowTiers = false,

    wishlistGlowEnabled = false,
    wishlistGlowType    = 1,
    wishlistGlowLines   = 12,
    wishlistGlowSpeed   = 0.35,
    wishlistGlowThickness = 2,
    wishlistGlowColor   = { 1, 0.84, 0, 1 },

    soundEnabled   = false,
    soundThreshold = 200,
    soundChoice    = 1,
    wishlistSoundEnabled = false,
    wishlistSoundChoice  = 1,

    partyFeed = {
        enabled        = true,
        feedX          = -450,
        feedY          = 300,
        feedWidth      = 400,
        feedRowHeight  = 46,
        feedMaxRows    = 8,
        feedSpacing    = 4,
        feedGrowUp     = false,
        feedAlpha      = 1.0,
        feedBackground = true,
        feedBgAlpha    = 0.75,
        rowBgAlpha     = 0.80,
        feedLocked     = false,
        fadeOutTime    = 0.5,
        showParty      = true,
        showRaid       = true,
        filterMinRarity = 0,
        filterPets   = true,
        filterMounts = true,
    },
}

Config.DEFAULT_GLOW_TIERS = {
    { threshold = 20,    color = { 0.13, 1.00, 0.33 } },
    { threshold = 200,   color = { 0.20, 0.60, 1.00 } },
    { threshold = 2000,  color = { 0.80, 0.00, 1.00 } },
    { threshold = 20000, color = { 1.00, 0.55, 0.00 } },
}

local function ApplyDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if t[k] == nil then
            t[k] = type(v) == "table" and {} or v
            if type(v) == "table" then ApplyDefaults(t[k], v) end
        elseif type(v) == "table" and type(t[k]) == "table" then
            ApplyDefaults(t[k], v)
        end
    end
end

local function DeepCopy(src)
    if type(src) ~= "table" then return src end
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

local PROFILE_META_KEYS = { _profileVersion=true, _profilesMigrated=true, profileKeys=true, profiles=true }

local charKey

function Config:InitProfiles()
    local sv = _G.LarlenLootFrameDB
    if not sv then sv = {}; _G.LarlenLootFrameDB = sv end

    charKey = UnitName("player") .. " - " .. GetRealmName()

    if not sv._profileVersion then
        local legacy = {}
        for k, v in pairs(sv) do
            if not PROFILE_META_KEYS[k] then
                legacy[k] = v
            end
        end
        for k in pairs(sv) do
            if not PROFILE_META_KEYS[k] then
                sv[k] = nil
            end
        end
        sv._profileVersion = 1
        sv.profileKeys = sv.profileKeys or {}
        sv.profiles    = sv.profiles    or {}
        sv.profiles["Default"] = legacy
        sv.profileKeys[charKey] = "Default"
    end

    if not sv.profileKeys then sv.profileKeys = {} end
    if not sv.profiles    then sv.profiles    = {} end

    if not sv.profileKeys[charKey] then
        sv.profileKeys[charKey] = "Default"
    end

    local profileName = sv.profileKeys[charKey]
    if not sv.profiles[profileName] then
        sv.profiles[profileName] = DeepCopy(self.DEFAULTS)
    end

    LLF.db = sv.profiles[profileName]
end

function Config:Init()
    ApplyDefaults(LLF.db, self.DEFAULTS)

    if not LLF.db.glowTiers or LLF.db.glowTiers == false then
        LLF.db.glowTiers = DeepCopy(self.DEFAULT_GLOW_TIERS)
    end

    if LLF.db.glowThreshold1 then
        LLF.db.glowTiers = {
            { threshold = LLF.db.glowThreshold1 or 20,    color = { 0.13, 1.00, 0.33 } },
            { threshold = LLF.db.glowThreshold2 or 200,   color = { 0.20, 0.60, 1.00 } },
            { threshold = LLF.db.glowThreshold3 or 2000,  color = { 0.80, 0.00, 1.00 } },
            { threshold = LLF.db.glowThreshold4 or 20000, color = { 1.00, 0.55, 0.00 } },
        }
        LLF.db.glowThreshold1 = nil
        LLF.db.glowThreshold2 = nil
        LLF.db.glowThreshold3 = nil
        LLF.db.glowThreshold4 = nil
    end

    if LLF.db.filterRarity and not LLF.db._filtersMigrated then
        local pf = LLF.db.personalFilters
        local gf = LLF.db.groupFilters
        for k, v in pairs(LLF.db.filterRarity) do
            pf.filterRarity[k] = v
            gf.filterRarity[k] = v
        end
        if LLF.db.filterRep ~= nil then
            pf.filterRep = LLF.db.filterRep
        end
        if LLF.db.filterGuildRep ~= nil then
            pf.filterGuildRep = LLF.db.filterGuildRep
        end
        LLF.db._filtersMigrated = true
    end
end

function Config:GetCharKey()
    return charKey
end

function Config:GetCurrentProfileName()
    local sv = _G.LarlenLootFrameDB
    return sv.profileKeys[charKey] or "Default"
end

function Config:GetProfileList()
    local sv = _G.LarlenLootFrameDB
    local list = {}
    for name in pairs(sv.profiles or {}) do
        list[#list + 1] = name
    end
    table.sort(list)
    return list
end

function Config:SetProfile(name)
    local sv = _G.LarlenLootFrameDB
    if not sv.profiles[name] then
        sv.profiles[name] = DeepCopy(self.DEFAULTS)
    end
    sv.profileKeys[charKey] = name
    LLF.db = sv.profiles[name]
    ApplyDefaults(LLF.db, self.DEFAULTS)
    if not LLF.db.glowTiers or LLF.db.glowTiers == false then
        LLF.db.glowTiers = DeepCopy(self.DEFAULT_GLOW_TIERS)
    end
end

function Config:CopyProfile(srcName)
    local sv = _G.LarlenLootFrameDB
    local src = sv.profiles[srcName]
    if not src then return false end
    local curName = self:GetCurrentProfileName()
    local dst = sv.profiles[curName]
    local copy = DeepCopy(src)
    for k in pairs(dst) do dst[k] = nil end
    for k, v in pairs(copy) do dst[k] = v end
    ApplyDefaults(dst, self.DEFAULTS)
    return true
end

function Config:DeleteProfile(name)
    local sv = _G.LarlenLootFrameDB
    if name == self:GetCurrentProfileName() then return false end
    sv.profiles[name] = nil
    for ch, pn in pairs(sv.profileKeys) do
        if pn == name then
            sv.profileKeys[ch] = "Default"
        end
    end
    return true
end

function Config:ResetProfile()
    local sv = _G.LarlenLootFrameDB
    local name = sv.profileKeys[charKey]
    local profile = sv.profiles[name]
    for k in pairs(profile) do profile[k] = nil end
    ApplyDefaults(profile, self.DEFAULTS)
    return true
end

function Config:CreateProfile(name)
    local sv = _G.LarlenLootFrameDB
    if sv.profiles[name] then return false end
    sv.profiles[name] = DeepCopy(self.DEFAULTS)
    return true
end

function Config:RenameProfile(oldName, newName)
    local sv = _G.LarlenLootFrameDB
    if not sv.profiles[oldName] or sv.profiles[newName] then return false end
    sv.profiles[newName] = sv.profiles[oldName]
    sv.profiles[oldName] = nil
    for ch, pn in pairs(sv.profileKeys) do
        if pn == oldName then
            sv.profileKeys[ch] = newName
        end
    end
    return true
end

function Config:InitBlacklist()
    local bl = LLF.db.blacklist
    if type(bl) == "table" then
        if bl[1] ~= nil and type(bl[1]) == "table" and bl[1].type ~= nil then
            local migrated = {}
            for _, e in ipairs(bl) do
                if e.type == 1 and e.link then
                    local itemID = tonumber(e.link:match("item:(%d+)"))
                    if itemID then
                        local name, _, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
                        migrated[itemID] = { name = name or e.link, icon = icon, rarity = rarity, link = e.link }
                    end
                end
            end
            LLF.db.blacklist = migrated
        end
        return
    end
    LLF.db.blacklist = {}
end

function Config:IsItemBlacklisted(link)
    if not link then return false end
    local itemID = tonumber(link:match("item:(%d+)"))
    if itemID and LLF.db.blacklist and LLF.db.blacklist[itemID] then
        return true
    end
    return false
end

function Config:AddItemToBlacklist(link)
    if not link then return false end
    local itemID = tonumber(link:match("item:(%d+)"))
    if not itemID then return false end
    if LLF.db.blacklist[itemID] then return false end
    local name, _, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(link)
    LLF.db.blacklist[itemID] = { name = name or link, icon = icon, rarity = rarity, link = link }
    local rc = rarity and select(4, C_Item.GetItemQualityColor(rarity))
    local coloredName = rc and ("|c" .. rc .. (name or "Unknown") .. "|r") or (name or "Unknown")
    print("|cff32bff7LLF:|r " .. coloredName .. " |cffaaaaaa[" .. itemID .. "]|r was |cffff4444blacklisted|r.")
    if LLF._rebuildBlacklist then LLF._rebuildBlacklist() end
    return true
end

function Config:IsItemWishlisted(link)
    if not link then return false end
    local itemID = tonumber(link:match("item:(%d+)"))
    if itemID and LLF.db.wishlist and LLF.db.wishlist[itemID] then
        return true
    end
    return false
end

function Config:AddItemToWishlist(link)
    if not link then return false end
    local itemID = tonumber(link:match("item:(%d+)"))
    if not itemID then return false end
    if LLF.db.wishlist[itemID] then return false end
    local name, _, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(link)
    LLF.db.wishlist[itemID] = { name = name or link, icon = icon, rarity = rarity, link = link }
    local rc = rarity and select(4, C_Item.GetItemQualityColor(rarity))
    local coloredName = rc and ("|c" .. rc .. (name or "Unknown") .. "|r") or (name or "Unknown")
    print("|cff32bff7LLF:|r " .. coloredName .. " |cffaaaaaa[" .. itemID .. "]|r added to |cff44ff44wishlist|r.")
    if LLF._rebuildWishlist then LLF._rebuildWishlist() end
    return true
end

function Config:GetDuration(key, feedType)
    local tbl = (feedType == "group" and LLF.db.groupDurations) or LLF.db.durations
    local v = tbl and tbl[key]
    return v ~= nil and v or 5
end

function Config:IsCurrencyBlacklisted(id)
    return false
end

function Config:IsRepBlacklisted(name)
    return false
end
