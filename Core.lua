local LLF        = LarlenLootFrame
local ADDON_NAME = "LarlenLootFrame"

local IsAddonLoaded = LLF.IsAddonLoaded

LLF.SOUNDS = {
    { name = "Loot Toast",        key = "UI_EPICLOOT_TOAST"         },
    { name = "Coin Chime",        key = "AUCTION_WINDOW_OPEN"       },
    { name = "Raid Warning",      key = "RAID_WARNING"              },
    { name = "Quest Done",        key = "IG_QUEST_LIST_COMPLETE"    },
    { name = "Level Up",          key = "LEVEL_UP"                  },
    { name = "Ready Check",       key = "READY_CHECK"               },
    { name = "Alarm Clock",       key = "ALARM_CLOCK_WARNING_3"     },
    { name = "LFG Chime",         key = "LFG_ROLE_CHECK"            },
    { name = "PVP Through Queue", key = "PVP_THROUGH_QUEUE"         },
    { name = "Map Ping",          key = "MAP_PIN_PING"              },
    { name = "Auction Close",     key = "AUCTION_WINDOW_CLOSE"      },
    { name = "Quest Accept",      key = "IG_QUEST_LIST_OPEN"        },
    { name = "GM Chat Warning",   key = "GM_CHAT_WARNING"           },
    { name = "Power Aura",        key = "POWER_AURA_EXPIRE_WARNING" },
    { name = "Bonus Roll",        key = "UI_BONUS_LOOT_ROLL_END"    },
    { name = "Rare Loot",         key = "UI_RARELOOT_TOAST"         },
    { name = "Wardrobe Toast",    key = "UI_WARDROBE_TOAST"         },
}

function LLF:PlaySound(choiceIndex)
    local list = self:GetSoundList()
    local entry = list and list[choiceIndex or 1]
    if not entry then return false end
    if entry.soundkitKey then
        if SOUNDKIT and SOUNDKIT[entry.soundkitKey] then
            PlaySound(SOUNDKIT[entry.soundkitKey], "Master")
            return true
        end
    elseif entry.lsmKey then
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local path = LSM:Fetch("sound", entry.lsmKey)
            if path then PlaySoundFile(path, "Master"); return true end
        end
    end
    return false
end

function LLF:GetSoundList()
    local items = {}
    for i, s in ipairs(self.SOUNDS) do
        items[#items + 1] = { value = i, display = s.name, soundkitKey = s.key }
    end
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local sounds = LSM:List("sound")
        if sounds then
            for _, name in ipairs(sounds) do
                if name ~= "None" then
                    items[#items + 1] = { value = #items + 1, display = "LSM: " .. name, lsmKey = name }
                end
            end
        end
    end
    return items
end

local factionIDCache = {}

local function GetFactionProgress(facName)
    if not C_Reputation or not C_Reputation.GetFactionDataByID then return "" end

    local factionID = factionIDCache[facName]
    if not factionID then
        local n = C_Reputation.GetNumFactions and C_Reputation.GetNumFactions() or 0
        for i = 1, n do
            local d = C_Reputation.GetFactionDataByIndex(i)
            if d and d.name and d.factionID then
                factionIDCache[d.name] = d.factionID
            end
        end
        factionID = factionIDCache[facName]
    end
    if not factionID then return "" end

    local data = C_Reputation.GetFactionDataByID(factionID)
    if not data then return "" end

    if C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID) then
        local mf = C_MajorFactions and C_MajorFactions.GetMajorFactionData and C_MajorFactions.GetMajorFactionData(factionID)
        if mf then
            local cur = mf.renownReputationEarned or 0
            local max = mf.renownLevelThreshold or 2500
            return " (" .. cur .. " / " .. max .. ")"
        end
    end

    local cur = (data.currentStanding or 0) - (data.currentReactionThreshold or 0)
    local max = (data.nextReactionThreshold or 0) - (data.currentReactionThreshold or 0)
    if max <= 0 then return "" end
    return " (" .. cur .. " / " .. max .. ")"
end

local SOCKET_TEXTURES = {
    EMPTY_SOCKET_META      = "|T136257:0|t",
    EMPTY_SOCKET_RED       = "|T136258:0|t",
    EMPTY_SOCKET_YELLOW    = "|T136259:0|t",
    EMPTY_SOCKET_BLUE      = "|T136256:0|t",
    EMPTY_SOCKET_PRISMATIC = "|T458977:0|t",
}

local TERTIARY_KEYS = {
    ITEM_MOD_CR_AVOIDANCE_SHORT  = "|cFF00FFFFAvoidance|r",
    ITEM_MOD_CR_LIFESTEAL_SHORT  = "|cFF00FFFFLeech|r",
    ITEM_MOD_CR_SPEED_SHORT      = "|cFF00FFFFSpeed|r",
    ITEM_MOD_CR_STURDINESS_SHORT = "|cFF00FFFFIndestructible|r",
}

local function ParseItemStats(link)
    if not link then return "", "" end
    local stats = (C_Item.GetItemStats or GetItemStats)(link)
    if not stats then return "", "" end
    local sockText, tertText = "", ""
    for key, tex in pairs(SOCKET_TEXTURES) do
        local n = stats[key]
        if n and n > 0 then
            for _ = 1, n do sockText = sockText .. tex end
        end
    end
    if #sockText > 0 then sockText = sockText .. "|cFFFF00FFSocket|r" end
    for key, label in pairs(TERTIARY_KEYS) do
        if stats[key] then tertText = tertText .. " " .. label end
    end
    return sockText, tertText:gsub("^ ", "")
end

local function GetItemCategory(link, classID, subClassID)
    if classID == 17 then return "pet" end
    if classID == 15 and subClassID == 5 then return "mount" end
    if classID == 15 and subClassID == 2 then return "pet" end
    if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem then
        local itemID = tonumber(link:match("item:(%d+)"))
        if itemID and C_HousingCatalog.GetCatalogEntryInfoByItem(itemID, false) then return "housing" end
    end
    return nil
end

local CATEGORY_LABELS = { pet = "Pet", mount = "Mount", housing = "Housing Decor" }

local UPGRADE_TRACK_TIER = {}
do
    local defs = {
        { "Explorer",   1 }, { "Adventurer", 2 }, { "Veteran", 3 },
        { "Champion",   4 }, { "Hero",       5 }, { "Myth",    6 },
    }
    for _, d in ipairs(defs) do
        UPGRADE_TRACK_TIER[d[1]] = d[2]
    end
end

local _upgradePattern
local function GetUpgradeTrackTier(link)
    if not link then return nil end
    if not C_TooltipInfo or not C_TooltipInfo.GetHyperlink then return nil end
    if not _upgradePattern then
        local fmt = _G.ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
                 or _G.ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT_STRING
        if not fmt then return nil end
        _upgradePattern = fmt:gsub("%%%%", "%%"):gsub("%%s", "(.+)"):gsub("%%d", "%%d+")
    end
    local ok, info = pcall(C_TooltipInfo.GetHyperlink, link)
    if not ok or not info or not info.lines then return nil end
    for _, line in ipairs(info.lines) do
        if line.leftText then
            local track = line.leftText:match(_upgradePattern)
            if track then
                track = track:gsub("^%s+", ""):gsub("%s+$", "")
                return UPGRADE_TRACK_TIER[track] or nil
            end
        end
    end
    return nil
end

local function EntryFromLink(link, count, source)
    if not link then return nil end
    local name, _, rarity, _, _, itemType, itemSubType, _, equipLoc, icon, price, _, iClass, bindType =
        C_Item.GetItemInfo(link)
    if not name then return nil end
    if LLF.db.blacklistEnabled and LLF.Config:IsItemBlacklisted(link) then return nil end

    local classID, subClassID
    if GetItemInfoInstant then
        local _, _, _, _, _, _, _, cID, scID = GetItemInfoInstant(link)
        classID, subClassID = cID, scID
    end

    local category = GetItemCategory(link, classID or 0, subClassID or 0)
    local isGear            = itemType == "Armor" or itemType == "Weapon"
    local ilvl              = isGear and C_Item.GetDetailedItemLevelInfo(link) or nil
    local sockets, tertiary = ParseItemStats(link)
    local canAH = (bindType ~= 1 and bindType ~= 4)
    local itemID = link:match("item:(%d+)") or link

    local displaySubType = CATEGORY_LABELS[category] or (isGear and itemSubType or nil)
    local trackTier = isGear and GetUpgradeTrackTier(link) or nil

    return {
        icon     = icon,
        name     = name,
        rarity   = (iClass == "Quest") and 7 or rarity,
        source   = source,
        count    = count or 1,
        price    = price or 0,
        link     = link,
        ilvl     = ilvl,
        equipLoc = isGear and equipLoc or nil,
        subType  = displaySubType,
        sockets  = (#sockets  > 0) and sockets  or nil,
        tertiary = (#tertiary > 0) and tertiary or nil,
        isGear   = isGear,
        canAH    = canAH,
        mergeKey = "item:" .. itemID,
        itemCategory = category,
        upgradeTrackTier = trackTier,
    }
end

local function ShouldFilterCategory(category, isParty)
    if not category then return false end
    local db = LLF.db
    if not db then return false end
    if isParty then
        if category == "housing" then return true end
        local pdf = db.partyFeed
        if pdf then
            if category == "pet"   and pdf.filterPets   == false then return true end
            if category == "mount" and pdf.filterMounts  == false then return true end
        end
    else
        local pf = db.personalFilters
        if pf then
            if category == "pet"     and pf.filterPets    == false then return true end
            if category == "mount"   and pf.filterMounts   == false then return true end
            if category == "housing" and pf.filterHousing  == false then return true end
        end
    end
    return false
end

local function IsGroupMember(name)
    if not IsInGroup() then return false end
    local inRaid = IsInRaid()
    local prefix = inRaid and "raid" or "party"
    local max    = inRaid and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, max do
        local unit = prefix .. i
        if UnitExists(unit) then
            local uname = UnitName(unit)
            if uname and uname == name then return true end
        end
    end
    return false
end

local lastMoney = nil

local function HandleMoney()
    local current = GetMoney()
    if lastMoney == nil then lastMoney = current; return end
    local delta = current - lastMoney
    lastMoney = current
    if delta <= 0 then return end
    if LLF.Config:GetDuration("gold") <= 0 then return end
    local icon = delta >= 10000 and 133784 or delta >= 100 and 133786 or 133788
    LLF.Feed:AddEntry({ icon=icon, name="Money", rarity=1, source=1, count=1, price=delta, mergeKey="money" })
end

local recentLoot = {}
local lastLootEventAt = 0

local function HandleChatMsgLoot(msg, _, _, _, sender)
    local receiver = type(sender) == "string" and (sender .. "") or ""
    local dash = receiver:find("-", 1, true)
    if dash then receiver = receiver:sub(1, dash - 1) end

    local isMe = msg:match("^You receive") ~= nil
              or (receiver ~= "" and receiver == UnitName("player"))

    if not isMe then
        local pdf = LLF.db and LLF.db.partyFeed
        if pdf and pdf.enabled then
            if receiver == "" then
                local parsed = msg:match("^([^%s]+) receives ")
                if parsed then receiver = parsed end
            end
            if receiver ~= "" and IsGroupMember(receiver) then
                local inRaid  = IsInRaid()
                local inParty = IsInGroup() and not inRaid
                if (inParty and pdf.showParty) or (inRaid and pdf.showRaid) then
                    if (GetTime() - lastLootEventAt) > 5 then return end
                    local link = msg:match("(|c%x%x%x%x%x%x%x%x|Hitem:.-|h%[.-%]|h|r)")
                              or msg:match("(|Hitem:.-|h%[.-%]|h)")
                    if link then
                        local entry = EntryFromLink(link, tonumber(msg:match("x(%d+)%s*$")) or 1, 4)
                        if entry and not ShouldFilterCategory(entry.itemCategory, true) then
                            entry.playerName     = receiver
                            entry.playerNameFull = tostring(sender)
                            entry.mergeKey       = "party_chat:" .. receiver .. ":" .. entry.mergeKey
                            LLF.PartyFeed:AddEntry(entry)
                        end
                    end
                end
            end
        end
        return
    end

    local link = msg:match("(|c%x%x%x%x%x%x%x%x|Hitem:.-|h%[.-%]|h|r)")
              or msg:match("(|Hitem:.-|h%[.-%]|h)")
    if not link then return end
    local itemID = link:match("item:(%d+)") or link
    if recentLoot[itemID] then return end
    local entry = EntryFromLink(link, tonumber(msg:match("x(%d+)%s*$")) or 1, 4)
    if entry and not ShouldFilterCategory(entry.itemCategory, false) then LLF.Feed:AddEntry(entry) end
end

local function HandleEncounterLoot(_, _, link, count, playerName)
    if not link then return end
    lastLootEventAt = GetTime()
    local isMe = (playerName == UnitName("player"))
    if not isMe then return end
    local itemID = link:match("item:(%d+)") or link
    recentLoot[itemID] = true
    C_Timer.After(1, function() recentLoot[itemID] = nil end)
    local entry = EntryFromLink(link, tonumber(count) or 1, 3)
    if entry and not ShouldFilterCategory(entry.itemCategory, false) then LLF.Feed:AddEntry(entry) end
end

local function HandleCurrency(msg)
    local cLink = msg:match("(|c%x%x%x%x%x%x%x%x|Hcurrency:%d+|h%[.-%]|h|r)")
    if not cLink then return end
    local info = C_CurrencyInfo.GetCurrencyInfoFromLink(cLink)
    if not info then return end
    if LLF.Config:IsCurrencyBlacklisted(info.currencyID or 0) then return end
    if LLF.Config:GetDuration(6) <= 0 then return end
    local count  = tonumber(msg:match("x(%d+)%s*$")) or 1
    local append = ""
    if info.quantity then
        local cur, cap = info.quantity, info.maxQuantity
        if cap and cap > 0 then
            append = " |r|cffffffff(|r" .. cur .. " / " .. cap .. "|cffffffff)|r"
        else
            append = " |r|cffffffff(|r" .. cur .. "|cffffffff)|r"
        end
    end
    LLF.Feed:AddEntry({
        icon=info.iconFileID, name=info.name, rarity=6, source=2,
        count=count, price=0, link=cLink,
        append=append, mergeKey="currency:" .. cLink,
    })
end

local honorAccum = 0
local honorTimer = nil

local function HandleHonor(msg)
    if LLF.Config:GetDuration(8) <= 0 then return end
    local pf = LLF.db.personalFilters
    if pf and pf.filterRarity and pf.filterRarity[8] == false then return end
    local gained = tonumber(msg:match("awarded (%d+) honor")) or
                   tonumber(msg:match("Estimated Honor Points: (%d+)")) or 0
    if gained <= 0 then return end
    honorAccum = honorAccum + gained
    if honorTimer then honorTimer:Cancel() end
    honorTimer = C_Timer.NewTimer(0.3, function()
        local total = honorAccum
        honorAccum  = 0
        honorTimer  = nil
        LLF.Feed:AddEntry({
            icon=1455894, name="Honor", rarity=8, source=7,
            count=total, price=0, mergeKey="honor",
        })
    end)
end

local REP_PATTERNS = {
    enUS = {
        incName = ".*with ([%w %-',%(%):]+) increased by.*",
        decName = ".*with ([%w %-',%(%):]+) decreased by.*",
        incVal  = ".*increased by (%d+)%.?",
        decVal  = ".*decreased by (%d+)%.?",
    },
    deDE = {
        incName = ".*der Fraktion '([%w %-',%(%):]+)' hat sich um.*",
        decName = ".*der Fraktion '([%w %-',%(%):]+)' hat sich um.*",
        incVal  = ".-(%d+) verbessert%.?",
        decVal  = ".-(%d+) verschlechtert%.?",
    },
}

local function HandleRepChange(msg)
    local pf = LLF.db.personalFilters
    if not pf or not pf.filterRep then return end
    if LLF.Config:GetDuration("rep") <= 0 then return end
    local ok, clean = pcall(tostring, msg)
    if not ok or not clean then return end
    msg = clean
    local pat     = REP_PATTERNS[GetLocale()] or REP_PATTERNS["enUS"]
    local faction = msg:match(pat.incName) or msg:match(pat.decName) or ""
    if #faction == 0 then return end
    if LLF.Config:IsRepBlacklisted(faction) then return end
    if not pf.filterGuildRep then
        if faction == "Guild" or faction == "Gilde" or faction == "Guilde" then return end
        local guildName = GetGuildInfo("player")
        if guildName and faction == guildName then return end
    end
    local gained = tonumber(msg:match(pat.incVal)) or 0
    local lost   = tonumber(msg:match(pat.decVal)) or 0
    LLF.Feed:AddEntry({
        icon=236681, name=faction .. " Rep", rarity=7, source=5,
        count=(gained > 0 and gained or -lost), price=0,
        append=GetFactionProgress(faction), mergeKey="rep:" .. faction,
    })
end

local function HandleQuestLoot(_, itemID, count)
    if not itemID then return end
    local _, link = C_Item.GetItemInfo(itemID)
    if not link then return end
    local entry = EntryFromLink(link, tonumber(count) or 1, 3)
    if entry then entry.rarity = 7; LLF.Feed:AddEntry(entry) end
end

local lootSuppressHooked    = false
local lootFrameHooksSetup   = false

local function HideActiveLootAlerts()
    if not AlertFrame then return end
    local n = AlertFrame:GetNumChildren()
    for i = 1, n do
        local child = select(i, AlertFrame:GetChildren())
        if child and child.lootItem then
            if AlertFrame.RemoveAlertFrame then
                AlertFrame:RemoveAlertFrame(child)
            end
            child:Hide()
        end
    end
end

local function HideDefaultLootWindow()
    local lf = _G["LootFrame"]
    if lf and lf:IsShown() then lf:Hide() end
    local blf = _G["BasicLootFrame"]
    if blf and blf:IsShown() then blf:Hide() end
    HideActiveLootAlerts()
end

local function SetupLootSuppression()
    if lootSuppressHooked then return end
    lootSuppressHooked = true
    local f = CreateFrame("Frame")
    f:RegisterEvent("LOOT_OPENED")
    f:RegisterEvent("LOOT_READY")
    f:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
    f:RegisterEvent("QUEST_LOOT_RECEIVED")
    f:RegisterEvent("SHOW_LOOT_TOAST")
    f:SetScript("OnEvent", function()
        if LLF.db and LLF.db.suppressDefaultLoot then
            C_Timer.After(0.05, HideDefaultLootWindow)
        end
    end)
end

local function SetupLootSuppressionFrameHooks()
    if lootFrameHooksSetup then return end
    lootFrameHooksSetup = true
    if not AlertFrame or not AlertFrame.AddAlertFrame then return end
    hooksecurefunc(AlertFrame, "AddAlertFrame", function(_, frame)
        if not frame then return end
        if not (LLF.db and LLF.db.suppressDefaultLoot) then return end
        if frame.lootItem then
            C_Timer.After(0, function()
                if AlertFrame.RemoveAlertFrame then
                    AlertFrame:RemoveAlertFrame(frame)
                end
                frame:Hide()
            end)
        end
    end)
end

local eventFrame = CreateFrame("Frame", "LarlenLootFrameEventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if (...) ~= ADDON_NAME then return end
        if not _G.LarlenLootFrameDB then _G.LarlenLootFrameDB = {} end
        LLF.Config:InitProfiles()
        LLF.Config:Init()

        if LLF.db.showAHPrice == nil then
            local hasAuc = IsAddonLoaded("Auctionator")
            local hasTSM = IsAddonLoaded("TradeSkillMaster") or IsAddonLoaded("TradeSkillMaster4")
            if hasAuc or hasTSM then
                LLF.db.showAHPrice  = true
                LLF.db.auctionAddon = hasAuc and 1 or 2
            else
                LLF.db.showAHPrice = false
            end
        end
        LLF.Feed:Init()
        LLF.PartyFeed:Init()
        LLF.Options:Init()
        LLF.Minimap:Register()
        eventFrame:RegisterEvent("PLAYER_MONEY")
        eventFrame:RegisterEvent("CHAT_MSG_LOOT")
        eventFrame:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
        eventFrame:RegisterEvent("LOOT_READY")
        eventFrame:RegisterEvent("LOOT_OPENED")
        eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
        eventFrame:RegisterEvent("QUEST_LOOT_RECEIVED")
        eventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
        if LLF.db.personalFilters and LLF.db.personalFilters.filterRep then
            eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
        end
        lastMoney = GetMoney()
        SetupLootSuppression()
        print("|cff32bff7Larlen Loot Frame|r v" .. LLF.VERSION .. " loaded.  /llf for options.")

    elseif event == "PLAYER_LOGIN" then
        LLF.Minimap:ApplyVisibility()
        SetupLootSuppressionFrameHooks()

    elseif event == "PLAYER_MONEY" then
        HandleMoney()

    elseif event == "CHAT_MSG_LOOT" then
        local a1, a2, a3, a4, a5 = ...
        C_Timer.After(0, function() HandleChatMsgLoot(a1, a2, a3, a4, a5) end)

    elseif event == "LOOT_READY" or event == "LOOT_OPENED" then
        lastLootEventAt = GetTime()

    elseif event == "ENCOUNTER_LOOT_RECEIVED" then
        HandleEncounterLoot(...)

    elseif event == "CHAT_MSG_CURRENCY" then
        local msg = ...
        C_Timer.After(0, function() HandleCurrency(msg) end)

    elseif event == "QUEST_LOOT_RECEIVED" then
        HandleQuestLoot(...)

    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        local msg = ...
        C_Timer.After(0, function() HandleRepChange(msg) end)

    elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
        local msg = ...
        C_Timer.After(0, function() HandleHonor(msg) end)
    end
end)

SLASH_LARLENLOOTFRAME1 = "/llf"
SLASH_LARLENLOOTFRAME2 = "/larlenlootframe"

SlashCmdList["LARLENLOOTFRAME"] = function(msg)
    msg = msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" or msg == "options" or msg == "config" then
        LLF.Options:Toggle()
    elseif msg == "clear" then
        LLF.Feed:ClearAll()
        LLF.PartyFeed:ClearAll()
        print("|cff32bff7LLF:|r Feed cleared.")
    elseif msg == "preview" then
        LLF.Feed:Preview()
    elseif msg == "unlock" then
        LLF.Feed:SetLocked(false)
        print("|cff32bff7LLF:|r Feed |cff55dd55unlocked|r - drag to reposition.  /llf lock when done.")
    elseif msg == "lock" then
        LLF.Feed:SetLocked(true)
        print("|cff32bff7LLF:|r Feed |cffaaaaaalocked|r.")
    elseif msg == "minimap" then
        LLF.Minimap:Toggle()
    elseif msg == "enable" then
        LLF.db.enabled = true
        print("|cff32bff7LLF:|r |cff55dd55Enabled|r.")
    elseif msg == "disable" then
        LLF.db.enabled = false
        LLF.Feed:ClearAll()
        print("|cff32bff7LLF:|r |cffff4444Disabled|r.")
    elseif msg == "testah" or msg == "ah" then
        local testLink = nil
        if LLF.Feed._rows and LLF.Feed._rows[1] then
            testLink = LLF.Feed._rows[1].entry.link
        end
        if testLink then
            print("|cff32bff7LLF:|r Testing AH price for: " .. testLink)
        else
            print("|cff32bff7LLF:|r No recent loot to test. Loot something first, then run /llf testah")
        end
        LLF.Price:DebugAH(testLink)
    else
        print("|cff32bff7Larlen Loot Frame|r commands:")
        print("  |cffffff00/llf|r               - open options")
        print("  |cffffff00/llf preview|r        - show sample rows")
        print("  |cffffff00/llf clear|r          - clear both feeds")
        print("  |cffffff00/llf unlock|r         - drag handle to reposition")
        print("  |cffffff00/llf lock|r           - lock position")
        print("  |cffffff00/llf minimap|r        - toggle minimap icon")
        print("  |cffffff00/llf testah|r         - debug AH price lookup")
        print("  |cffffff00/llf enable|r / |cffffff00disable|r")
    end
end
