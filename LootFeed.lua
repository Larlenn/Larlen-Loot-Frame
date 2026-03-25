local LLF = LarlenLootFrame
LLF.Feed = {}
local Feed = LLF.Feed

LLF.PartyFeed = {}
local PFeed = LLF.PartyFeed

local WHITE_TEX = "Interface\\Buttons\\WHITE8x8"

local FEED_BACKDROP = {
    bgFile   = WHITE_TEX,
    edgeFile = WHITE_TEX,
    tileEdge = false, edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

local function GetBorderFile(style)
    if not style or style == "None" or style == "" then return nil end
    local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
    if lsm then
        local f = lsm:Fetch("border", style, true)
        if type(f) == "string" and f ~= "" then return f end
    end
    return nil
end

local function EnsureBackdrop(frame)
    if frame and not frame.SetBackdrop and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
end

local function GetBgTexFile(name)
    if not name or name == "" then return WHITE_TEX end
    local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
    if lsm then
        local f = lsm:Fetch("statusbar", name, true) or lsm:Fetch("background", name, true)
        if type(f) == "string" and f ~= "" then return f end
    end
    return WHITE_TEX
end

local function GetRowBorderTarget(f)
    return (f and f._rowBorder) or f
end

local function ApplyRowBorderColor(f)
    if not f then return end
    local db    = LLF.db
    local bFile = GetBorderFile(db and db.rowBorderStyle or "None")
    if bFile then
        local c = (db and db.rowBorderColor) or { 1, 1, 1, 1 }
        f:SetBackdropBorderColor(c[1], c[2], c[3], c[4] or 1)
    else
        f:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

local function ApplyRowBorder(f)
    EnsureBackdrop(f)
    local db    = LLF.db
    local style = db and db.rowBorderStyle or "None"
    local sz    = (db and db.rowBorderSize) or 1
    local bFile = GetBorderFile(style)
    local bgTex = GetBgTexFile(db and db.rowBgTexture)
    f:SetBackdrop({
        bgFile   = bgTex,
        edgeFile = WHITE_TEX,
        edgeSize = 1,
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    f:SetBackdropBorderColor(0, 0, 0, 0)
    local bgA = (db and db.rowBgAlpha ~= nil) and db.rowBgAlpha or 0.80
    if db and db.rowBgTexture and db.rowBgTexture ~= "" then
        f:SetBackdropColor(1, 1, 1, bgA)
    else
        f:SetBackdropColor(0.05, 0.05, 0.07, bgA)
    end
    local border = f._rowBorder
    if not border then
        border = CreateFrame("Frame", nil, f, "BackdropTemplate")
        border:SetFrameLevel(f:GetFrameLevel() + 1)
        f._rowBorder = border
    end
    EnsureBackdrop(border)
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    if bFile then
        border:SetBackdrop({ edgeFile = bFile, edgeSize = sz })
    else
        border:SetBackdrop({ edgeFile = WHITE_TEX, edgeSize = 1 })
    end
    border:SetBackdropColor(0, 0, 0, 0)
    ApplyRowBorderColor(border)
end

local RARITY_COLOR = {
    [0] = { 0.62, 0.62, 0.62 },
    [1] = { 1.00, 1.00, 1.00 },
    [2] = { 0.12, 1.00, 0.00 },
    [3] = { 0.00, 0.44, 0.87 },
    [4] = { 0.64, 0.21, 0.93 },
    [5] = { 1.00, 0.50, 0.00 },
    [6] = { 0.90, 0.80, 0.50 },
    [7] = { 0.00, 0.80, 1.00 },
    [8] = { 0.90, 0.18, 0.18 },
}
local DEFAULT_COLOR = { 1.00, 1.00, 1.00 }
local SUBTEXT_COLOR = { 0.70, 0.70, 0.75, 1.00 }
local RARITY_HEX = {}

local UPGRADE_TRACK_TEXT = {
    [1] = "|cff9d9d9dExpl|r",
    [2] = "|cff1eff00Adv|r",
    [3] = "|cff0070ddVet|r",
    [4] = "|cffa335eeChamp|r",
    [5] = "|cffff8000Hero|r",
    [6] = "|cffe6cc80Myth|r",
}

local CATEGORY_COLOR = {
    pet   = { 0.25, 0.88, 0.68 },
    mount = { 0.85, 0.70, 0.25 },
}

local ICON_SIZE = 36
local PAD_SIDE  = 6
local PAD_TOP   = 4
local PAD_BOT   = 6
local ROW_H     = 40
local ROW_SPACE = 2

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local LCG = LibStub and LibStub("LibCustomGlow-1.0", true)

local _subParts   = {}
local _stParts    = {}
local _priceLines = {}
local _glowColor  = { 1, 1, 1, 0.9 }
local _wlColor    = { 1, 0.84, 0, 1 }

local SUBTYPE_SHORT = {
    ["One-Handed Sword"]   = "1H Sword",
    ["Two-Handed Sword"]   = "2H Sword",
    ["One-Handed Axe"]     = "1H Axe",
    ["Two-Handed Axe"]     = "2H Axe",
    ["One-Handed Mace"]    = "1H Mace",
    ["Two-Handed Mace"]    = "2H Mace",
    ["Fist Weapon"]        = "Fist",
    ["Miscellaneous"]      = "Misc",
}

local BUILTIN_FONTS = {
    ["Friz Quadrata TT"]  = "Fonts\\FRIZQT__.TTF",
    ["Arial Narrow"]      = "Fonts\\ARIALN.TTF",
    ["Skurri"]            = "Fonts\\skurri.ttf",
    ["Morpheus"]          = "Fonts\\MORPHEUS.ttf",
    ["Adventure Normal"]  = "Fonts\\MORPHEUS.ttf",
    ["Expressway"]        = "Fonts\\ARIALN.TTF",
    ["PT Sans Narrow"]    = "Fonts\\ARIALN.TTF",
}

local _fontCache, _fontCacheKey
local function GetFontPath()
    local chosen = LLF.db and LLF.db.feedFont
    local key = chosen or ""
    if _fontCacheKey == key and _fontCache then return _fontCache end
    local path
    if chosen and chosen ~= "" then
        path = (LSM and LSM:Fetch("font", chosen))
            or BUILTIN_FONTS[chosen]
    end
    if not path then
        path = (LSM and LSM:Fetch("font", "Friz Quadrata TT"))
            or BUILTIN_FONTS["Friz Quadrata TT"]
    end
    _fontCache, _fontCacheKey = path, key
    return path
end

local pool = {}

local CD_SECS = 3

local function GetGroupChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT", "Instance"
    elseif IsInRaid() then
        return "RAID", "Raid"
    elseif IsInGroup() then
        return "PARTY", "Party"
    end
    return nil, nil
end

local function GetCleanLink(link)
    if not link then return nil end
    return select(2, C_Item.GetItemInfo(link)) or link
end

local function BuildMsg(template, name, itemDisplay)
    return template
        :gsub("{name}", function() return name end)
        :gsub("{item}", function() return itemDisplay end)
end

local function GetNeedTemplate()
    return (LLF.db and LLF.db.needMessage) or "{name}, do you need {item}?"
end

local function SendGroupMessage(target, display, link)
    local channel = GetGroupChannel()
    if not channel then return end
    local msg = BuildMsg(GetNeedTemplate(), display or target or "", tostring(GetCleanLink(link)))
    C_ChatInfo.SendChatMessage(msg, channel)
end

local function SendWhisperMessage(target, display, link)
    local msg = BuildMsg(GetNeedTemplate(), display or target or "", tostring(GetCleanLink(link)))
    C_ChatInfo.SendChatMessage(msg, "WHISPER", nil, target)
end

local function MakeActionBtn(label)
    local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
    btn:SetSize(16, 13)
    btn:SetText(label)
    btn:SetFrameStrata("HIGH")
    btn._lastSent = 0
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return btn
end

local EQUIPLOC_TO_SLOT = {
    INVTYPE_HEAD        = 1,  INVTYPE_NECK        = 2,  INVTYPE_SHOULDER    = 3,
    INVTYPE_CHEST       = 5,  INVTYPE_ROBE        = 5,  INVTYPE_WAIST       = 6,
    INVTYPE_LEGS        = 7,  INVTYPE_FEET        = 8,  INVTYPE_WRIST       = 9,
    INVTYPE_HAND        = 10, INVTYPE_FINGER      = 11, INVTYPE_TRINKET     = 13,
    INVTYPE_CLOAK       = 15, INVTYPE_WEAPON       = 16, INVTYPE_SHIELD      = 17,
    INVTYPE_2HWEAPON    = 16, INVTYPE_WEAPONMAINHAND = 16, INVTYPE_WEAPONOFFHAND = 17,
    INVTYPE_RANGED      = 18, INVTYPE_RANGEDRIGHT  = 18,
}

local function IsItemUpgrade(entry)
    if not entry.isGear or not entry.link then return false end
    if PawnShouldItemLinkHaveUpgradeArrow then
        return PawnShouldItemLinkHaveUpgradeArrow(entry.link, true) == true
    end
    if not entry.ilvl or not entry.equipLoc then return false end
    local slotID = EQUIPLOC_TO_SLOT[entry.equipLoc]
    if not slotID then return false end
    local equippedID = GetInventoryItemID("player", slotID)
    if not equippedID then return true end
    local equippedLink = GetInventoryItemLink("player", slotID)
    if not equippedLink then return true end
    local equippedIlvl = C_Item.GetDetailedItemLevelInfo(equippedLink)
    if not equippedIlvl then return false end
    return entry.ilvl > equippedIlvl
end

local function IsNewTransmog(entry)
    if not entry.isGear or not entry.link then return false end
    if CanIMogIt and CanIMogIt.GetTooltipText then
        local text = CanIMogIt:GetTooltipText(entry.link)
        if text ~= nil and text ~= "" then
            return text == CanIMogIt.UNKNOWN
        end
    end
    if C_TransmogCollection then
        local sourceID = C_TransmogCollection.GetItemInfo(entry.link)
        if sourceID then
            return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) == false
        end
    end
    return false
end

local function AcquireRow(parent)
    local f = table.remove(pool)
    if f then
        f:SetParent(parent)
        ApplyRowBorder(f)
        return f
    end

    f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    ApplyRowBorder(f)

    local edge = f:CreateTexture(nil, "OVERLAY")
    edge:SetPoint("TOPLEFT",    f, 0, 0)
    edge:SetPoint("BOTTOMLEFT", f, 0, 0)
    edge:SetWidth(4)
    edge:SetColorTexture(1, 1, 1, 1)
    f._edge = edge

    local iconFrame = CreateFrame("Frame", nil, f)
    iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
    iconFrame:SetPoint("LEFT", f, 7, 0)
    f._iconFrame = iconFrame

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(iconFrame)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    f._icon = icon

    local function MakeEdgeLine()
        local t = f:CreateTexture(nil, "OVERLAY")
        t:SetColorTexture(1, 1, 1, 1)
        t:SetSize(1, 1)
        return t
    end
    f._ib_top    = MakeEdgeLine()
    f._ib_bottom = MakeEdgeLine()
    f._ib_left   = MakeEdgeLine()
    f._ib_right  = MakeEdgeLine()
    f._iconBorderLines = { f._ib_top, f._ib_bottom, f._ib_left, f._ib_right }
    for _, l in ipairs(f._iconBorderLines) do l:Hide() end

    local upArrow = iconFrame:CreateTexture(nil, "OVERLAY")
    upArrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
    upArrow:SetVertexColor(0.0, 1.0, 0.2, 1)
    upArrow:SetSize(26, 26)
    upArrow:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 2)
    upArrow:Hide()
    f._upgradeArrow = upArrow

    local tmogIcon = iconFrame:CreateTexture(nil, "OVERLAY")
    tmogIcon:SetSize(20, 20)
    tmogIcon:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 1, 2)
    tmogIcon:Hide()
    f._tmogIcon = tmogIcon
    local countFS = iconFrame:CreateFontString(nil, "OVERLAY")
    countFS:SetTextColor(1, 1, 1, 1)
    f._count = countFS

    local nameFS = f:CreateFontString(nil, "OVERLAY")
    nameFS:SetPoint("TOPLEFT",  icon, "TOPRIGHT",  6,  -3)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    f._name = nameFS

    local subTypeFS = f:CreateFontString(nil, "OVERLAY")
    subTypeFS:SetJustifyH("LEFT")
    subTypeFS:SetWordWrap(false)
    f._subType = subTypeFS

    local subFS = f:CreateFontString(nil, "OVERLAY")
    subFS:SetPoint("BOTTOMLEFT",  icon, "BOTTOMRIGHT",  6,  3)
    subFS:SetPoint("BOTTOMRIGHT", f,    "BOTTOMRIGHT", -130,  3)
    subFS:SetJustifyH("LEFT")
    subFS:SetTextColor(SUBTEXT_COLOR[1], SUBTEXT_COLOR[2], SUBTEXT_COLOR[3], SUBTEXT_COLOR[4])
    subFS:SetWordWrap(false)
    f._sub = subFS

    local priceBox = CreateFrame("Frame", nil, f)
    priceBox:SetPoint("TOPRIGHT",    f, "TOPRIGHT",    -4,  0)
    priceBox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4,  0)
    priceBox:SetWidth(124)
    f._priceBox = priceBox

    local priceFS = priceBox:CreateFontString(nil, "OVERLAY")
    priceFS:SetAllPoints(priceBox)
    priceFS:SetJustifyH("RIGHT")
    priceFS:SetJustifyV("MIDDLE")
    priceFS:SetWordWrap(false)
    f._price = priceFS

    icon:EnableMouse(true)
    icon:SetScript("OnEnter", function(self)
        local link = self:GetParent()._itemLink
        if link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            if GameTooltip_ShowCompareItem then
                GameTooltip_ShowCompareItem(GameTooltip)
            end
            GameTooltip:Show()
        end
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if GameTooltip_HideShoppingTooltips then
            GameTooltip_HideShoppingTooltips(GameTooltip)
        end
    end)
    icon:SetScript("OnMouseUp", function(self, btn)
        if btn == "LeftButton" and IsShiftKeyDown() then
            local link = self:GetParent()._itemLink
            if link and ChatEdit_GetActiveWindow() then
                ChatEdit_InsertLink(link)
            elseif link then
                ChatFrame_OpenChat(link)
            end
        elseif btn == "RightButton" then
            local feedParent = self:GetParent():GetParent()
            if feedParent then
                local handler = feedParent:GetScript("OnMouseUp")
                if handler then handler(feedParent, btn) end
            end
        end
    end)

    local gBtn = MakeActionBtn("G")
    gBtn:SetScript("OnEnter", function(self)
        if self._whisperTarget and self._whisperLink then
            local channel, label = GetGroupChannel()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if channel then
                GameTooltip:SetText("Send to " .. label, 1, 1, 1, 1, true)
            else
                GameTooltip:SetText("|cffff4444Not in a group|r", 1, 1, 1, 1, true)
            end
            GameTooltip:AddLine(BuildMsg(GetNeedTemplate(), self._whisperDisplay or self._whisperTarget or "", "[item]"), 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    gBtn:SetScript("OnClick", function(self)
        if self._whisperTarget and self._whisperLink then
            local now = GetTime()
            if now - self._lastSent < CD_SECS then return end
            if not GetGroupChannel() then return end
            self._lastSent = now
            SendGroupMessage(self._whisperTarget, self._whisperDisplay, self._whisperLink)
        end
    end)
    gBtn:Hide()

    local wBtn = MakeActionBtn("W")
    wBtn:SetScript("OnEnter", function(self)
        if self._whisperTarget and self._whisperLink then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Whisper |cffffff00" .. (self._whisperDisplay or self._whisperTarget or "") .. "|r", 1, 1, 1, 1, true)
            GameTooltip:AddLine(BuildMsg(GetNeedTemplate(), self._whisperDisplay or self._whisperTarget or "", "[item]"), 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    wBtn:SetScript("OnClick", function(self)
        if self._whisperTarget and self._whisperLink then
            local now = GetTime()
            if now - self._lastSent < CD_SECS then return end
            self._lastSent = now
            SendWhisperMessage(self._whisperTarget, self._whisperDisplay, self._whisperLink)
        end
    end)
    wBtn:Hide()

    f._instanceBtn = gBtn
    f._whisperBtn  = wBtn

    local oBtn = MakeActionBtn("G")
    oBtn:SetScript("OnEnter", function(self)
        if self._offerLink then
            local channel, label = GetGroupChannel()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if channel then
                GameTooltip:SetText("Offer to " .. label, 1, 1, 1, 1, true)
            else
                GameTooltip:SetText("|cffff4444Not in a group|r", 1, 1, 1, 1, true)
            end
            local db = LLF.db
            local tmpl = (db and db.offerMessage) or "Anyone want my {item}?"
            local preview = tmpl:gsub("{item}", function() return "[item]" end)
            GameTooltip:AddLine(preview, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    oBtn:SetScript("OnClick", function(self)
        if self._offerLink then
            local channel = GetGroupChannel()
            if not channel then return end
            local now = GetTime()
            if now - self._lastSent < CD_SECS then return end
            self._lastSent = now
            local db = LLF.db
            local tmpl = (db and db.offerMessage) or "Anyone want my {item}?"
            local cleanLink = GetCleanLink(self._offerLink)
            local msg = tmpl:gsub("{item}", function() return tostring(cleanLink) end)
            C_ChatInfo.SendChatMessage(msg, channel)
        end
    end)
    oBtn:Hide()
    f._offerBtn = oBtn

    return f
end

local _glowFieldKeys = {
    _v  = { target = "_vGlowTarget",  type = "_vGlowType",  key = "_vGlowKey"  },
    _wl = { target = "_wlGlowTarget", type = "_wlGlowType", key = "_wlGlowKey" },
}

local function StopTrackedGlow(f, prefix)
    local fk  = _glowFieldKeys[prefix]
    local tgt = f[fk.target]
    local gt  = f[fk.type]
    local key = f[fk.key]
    if tgt and gt and LCG then
        if gt == 3 then
            LCG.ButtonGlow_Stop(tgt)
        elseif gt == 2 then
            LCG.AutoCastGlow_Stop(tgt, key)
        else
            LCG.PixelGlow_Stop(tgt, key)
        end
    end
    f[fk.target] = nil
    f[fk.type]   = nil
    f[fk.key]    = nil
end

local function ReleaseRow(f)
    f:SetAlpha(1)
    f:Hide()
    f._itemLink = nil
    if f._iconFrame then f._iconFrame._itemLink = nil end
    StopTrackedGlow(f, "_v")
    StopTrackedGlow(f, "_wl")
    f:SetBackdropBorderColor(0, 0, 0, 0)
    if f._rowBorder then
        f._rowBorder:SetBackdropBorderColor(0, 0, 0, 0)
    end
    if f._instanceBtn then
        f._instanceBtn._whisperTarget  = nil
        f._instanceBtn._whisperLink    = nil
        f._instanceBtn._whisperDisplay = nil
        f._instanceBtn:Hide()
    end
    if f._whisperBtn then
        f._whisperBtn._whisperTarget  = nil
        f._whisperBtn._whisperLink    = nil
        f._whisperBtn._whisperDisplay = nil
        f._whisperBtn:Hide()
    end
    if f._offerBtn then
        f._offerBtn._offerLink = nil
        f._offerBtn:Hide()
    end
    table.insert(pool, f)
end

local function StartGlow(target, color, glowType, lines, speed, thickness, length, key)
    if not LCG or not target then return end
    glowType = glowType or 1
    if glowType == 3 then
        LCG.ButtonGlow_Start(target, color, speed)
    elseif glowType == 2 then
        LCG.AutoCastGlow_Start(target, color, lines or 4, speed or 0.125, thickness or 1, 0, 0, key)
    else
        LCG.PixelGlow_Start(target, color, lines or 12, speed or 0.35, length, thickness or 2, 0, 0, false, key)
    end
end

local function ApplyRowGlow(f, entry)
    local db = LLF.db
    local iconMode = (db and db.glowMode or 1) == 2
    local barTarget  = f
    local borderTarget = GetRowBorderTarget(f)
    local iconTarget = f._iconFrame

    ApplyRowBorderColor(borderTarget)

    if not db.glowEnabled then
        StopTrackedGlow(f, "_v")
    else
        local maxGold = 0
        if entry.price and entry.price > 0 then
            maxGold = math.max(maxGold, (entry.price * (entry.count or 1)) / 10000)
        end
        if entry.ahPrice and entry.ahPrice > 0 then
            maxGold = math.max(maxGold, entry.ahPrice / 10000)
        end
        local tiers = db.glowTiers
        local matched
        if tiers then
            for i = #tiers, 1, -1 do
                if maxGold >= (tiers[i].threshold or 0) then
                    matched = tiers[i]; break
                end
            end
        end
        if matched then
            local gc = matched.color or DEFAULT_COLOR
            _glowColor[1] = gc[1]; _glowColor[2] = gc[2]; _glowColor[3] = gc[3]; _glowColor[4] = 0.9
            local color = _glowColor
            local gt = db.glowType or 1
            local gl = db.glowLines or 12
            local gs = db.glowSpeed or 0.35
            local gth = db.glowThickness or 2
            local glen = db.glowLength
            if LCG then
                StopTrackedGlow(f, "_v")
                if iconMode and iconTarget then
                    StartGlow(iconTarget, color, gt, gl, gs, gth, glen, "llficon")
                    f._vGlowTarget = iconTarget
                    f._vGlowType   = gt
                    f._vGlowKey    = "llficon"
                else
                    StartGlow(barTarget, color, gt, gl, gs, gth, glen, "llf")
                    f._vGlowTarget = barTarget
                    f._vGlowType   = gt
                    f._vGlowKey    = "llf"
                end
            else
                borderTarget:SetBackdropBorderColor(gc[1], gc[2], gc[3], 0.90)
            end
        else
            StopTrackedGlow(f, "_v")
        end
    end

    if db.wishlistGlowEnabled and entry.link and LLF.Config:IsItemWishlisted(entry.link) then
        local wc = db.wishlistGlowColor or _wlColor
        _wlColor[1] = wc[1]; _wlColor[2] = wc[2]; _wlColor[3] = wc[3]; _wlColor[4] = wc[4] or 1
        local color = _wlColor
        local gt = db.wishlistGlowType or 1
        local gl = db.wishlistGlowLines or 12
        local gs = db.wishlistGlowSpeed or 0.35
        local gth = db.wishlistGlowThickness or 2
        if LCG then
            StopTrackedGlow(f, "_wl")
            if iconMode and iconTarget then
                StartGlow(iconTarget, color, gt, gl, gs, gth, nil, "llfwlicon")
                f._wlGlowTarget = iconTarget
                f._wlGlowType   = gt
                f._wlGlowKey    = "llfwlicon"
            else
                StartGlow(barTarget, color, gt, gl, gs, gth, nil, "llfwl")
                f._wlGlowTarget = barTarget
                f._wlGlowType   = gt
                f._wlGlowKey    = "llfwl"
            end
        end
    else
        StopTrackedGlow(f, "_wl")
    end
end

local function PopulateRow(f, entry)
    local db    = LLF.db
    local count = entry.count or 1

    local rh     = db.feedRowHeight or ROW_H
    local iconSz = math.max(math.floor(rh - 4), 16)
    f._iconFrame:SetSize(iconSz, iconSz)
    f._iconFrame:SetPoint("LEFT", f, 7, 0)
    f._edge:SetWidth(4)

    local nameSz  = math.max(math.floor(rh * 0.30), 9)
    local subSz   = math.max(math.floor(rh * 0.25), 8)
    local priceSz = math.max(math.floor(rh * 0.25), 8)

    local fp = GetFontPath()
    local countSz = math.max(math.floor(iconSz * 0.26), 7)
    f._count:SetFont(fp, countSz, "OUTLINE")
    local corner = db.countCorner or "BOTTOMRIGHT"
    local offX  = (corner == "TOPLEFT" or corner == "BOTTOMLEFT") and 2 or -2
    local offY  = (corner == "TOPLEFT" or corner == "TOPRIGHT")   and -2 or 2
    local justH = (corner == "TOPLEFT" or corner == "BOTTOMLEFT") and "LEFT" or "RIGHT"
    f._count:ClearAllPoints()
    f._count:SetPoint(corner, f._iconFrame, corner, offX, offY)
    f._count:SetJustifyH(justH)
    local subTypeSz = math.max(math.floor(rh * 0.22), 7)
    f._name:SetFont(fp,  nameSz,  "")
    f._subType:SetFont(fp, subTypeSz, "")
    f._sub:SetFont(fp,   subSz,   "")
    f._price:SetFont(fp, priceSz, "")

    f._name:ClearAllPoints()
    f._name:SetPoint("TOPLEFT",  f._iconFrame, "TOPRIGHT",  6, -2)
    f._subType:ClearAllPoints()
    f._subType:SetPoint("TOPLEFT", f._name, "BOTTOMLEFT", 0, -1)
    f._sub:ClearAllPoints()
    f._sub:SetPoint("BOTTOMLEFT",  f._iconFrame, "BOTTOMRIGHT",  6,  2)
    f._sub:SetPoint("BOTTOMRIGHT", f,       "BOTTOMRIGHT", -130,  2)

    local displayIcon = entry.icon or 134400
    if entry.link and not entry._iconResolved then
        local _, _, _, _, _, _, _, _, _, linkIcon = C_Item.GetItemInfo(entry.link)
        if linkIcon then displayIcon = linkIcon; entry.icon = linkIcon; entry._iconResolved = true end
    end
    f._icon:SetTexture(displayIcon)
    f._itemLink = entry.link
    f._iconFrame._itemLink = entry.link

    if f._upgradeArrow then
        local showUpgradeForParty = db.showUpgradeParty == true
        local isOwnLoot = not entry.playerName
        if db.showUpgradeIndicator ~= false and (isOwnLoot or showUpgradeForParty)
           and (entry.isUpgrade or IsItemUpgrade(entry)) then
            local arrowSz = math.max(math.floor(iconSz * 0.55), 18)
            f._upgradeArrow:SetSize(arrowSz, arrowSz)
            local stackAtTop = corner == "TOPLEFT" or corner == "TOPRIGHT"
            f._upgradeArrow:ClearAllPoints()
            if stackAtTop then
                f._upgradeArrow:SetPoint("BOTTOMLEFT", f._iconFrame, "BOTTOMLEFT", -1, -2)
            else
                f._upgradeArrow:SetPoint("TOPLEFT", f._iconFrame, "TOPLEFT", -1, 2)
            end
            f._upgradeArrow:Show()
        else
            f._upgradeArrow:Hide()
        end
    end

    if f._tmogIcon then
        local showForParty = db.showTransmogParty == true
        local isOwnLoot = not entry.playerName
        if db.showTransmogIndicator ~= false and (isOwnLoot or showForParty)
           and (entry.isTransmog or IsNewTransmog(entry)) then
            local tmogSz = math.max(math.floor(iconSz * 0.45), 14)
            f._tmogIcon:SetSize(tmogSz, tmogSz)
            local stackAtTop = corner == "TOPLEFT" or corner == "TOPRIGHT"
            f._tmogIcon:ClearAllPoints()
            if stackAtTop then
                f._tmogIcon:SetPoint("BOTTOMRIGHT", f._iconFrame, "BOTTOMRIGHT", 1, -2)
            else
                f._tmogIcon:SetPoint("TOPRIGHT", f._iconFrame, "TOPRIGHT", 1, 2)
            end
            f._tmogIcon:SetTexture(7344439)
            f._tmogIcon:SetTexCoord(0.65771484375, 0.71240234375, 0.61669921875, 0.67138671875)
            f._tmogIcon:SetVertexColor(1, 1, 1, 1)
            f._tmogIcon:Show()
        else
            f._tmogIcon:Hide()
        end
    end

    local rc = (entry.itemCategory and CATEGORY_COLOR[entry.itemCategory])
            or RARITY_COLOR[entry.rarity or 1] or DEFAULT_COLOR

    if db.showRarityBar ~= false then
        f._edge:SetColorTexture(rc[1], rc[2], rc[3], 0.85)
        f._edge:Show()
        f._iconFrame:SetPoint("LEFT", f, 7, 0)
    else
        f._edge:Hide()
        f._iconFrame:SetPoint("LEFT", f, 3, 0)
    end

    if db.showIconBorder then
        local r, g, b = rc[1], rc[2], rc[3]
        local sz = iconSz
        local t = math.max(db.iconBorderThickness or 2, 1)
        f._ib_top:ClearAllPoints();    f._ib_top:SetPoint("TOPLEFT", f._iconFrame, "TOPLEFT", 0, 0);         f._ib_top:SetSize(sz, t);    f._ib_top:SetColorTexture(r,g,b,1);    f._ib_top:Show()
        f._ib_bottom:ClearAllPoints(); f._ib_bottom:SetPoint("BOTTOMLEFT", f._iconFrame, "BOTTOMLEFT", 0, 0); f._ib_bottom:SetSize(sz, t); f._ib_bottom:SetColorTexture(r,g,b,1); f._ib_bottom:Show()
        f._ib_left:ClearAllPoints();   f._ib_left:SetPoint("TOPLEFT", f._iconFrame, "TOPLEFT", 0, 0);         f._ib_left:SetSize(t, sz);   f._ib_left:SetColorTexture(r,g,b,1);   f._ib_left:Show()
        f._ib_right:ClearAllPoints();  f._ib_right:SetPoint("TOPRIGHT", f._iconFrame, "TOPRIGHT", 0, 0);      f._ib_right:SetSize(t, sz);  f._ib_right:SetColorTexture(r,g,b,1);  f._ib_right:Show()
    else
        for _, l in ipairs(f._iconBorderLines) do l:Hide() end
    end

    f._count:SetText((db.showCount and count > 1) and (count .. "x") or "")

    local nameColor = "|cffffffff"
    if entry.rarity and entry.rarity >= 0 and entry.rarity <= 8 then
        local hex = RARITY_HEX[entry.rarity]
        if not hex then
            local _, _, _, h = C_Item.GetItemQualityColor(entry.rarity)
            if h then hex = "|c" .. h; RARITY_HEX[entry.rarity] = hex end
        end
        if hex then nameColor = hex end
    end
    local name = entry.name or "Unknown"
    if db.maxNameLength and #name > db.maxNameLength then
        name = name:sub(1, db.maxNameLength) .. "..."
    end
    f._name:SetText(nameColor .. name .. "|r")

    local subParts = _subParts
    wipe(subParts)
    if entry.playerName then
        subParts[#subParts+1] = "|cff99ccff" .. entry.playerName .. "|r"
    end
    do
        local stParts = _stParts
        wipe(stParts)
        if db.showSubType and entry.subType and #entry.subType > 0 and (entry.isGear or entry.itemCategory) then
            local color = entry.itemCategory and "|cff44ddff" or "|cffddaa55"
            stParts[#stParts+1] = color .. (SUBTYPE_SHORT[entry.subType] or entry.subType) .. "|r"
        end
        if entry.isGear and db.showUpgradeTrack ~= false and entry.upgradeTrackTier then
            local txt = UPGRADE_TRACK_TEXT[entry.upgradeTrackTier]
            if txt then stParts[#stParts+1] = txt end
        end
        if db.showCraftingQuality ~= false and entry.craftingQuality and entry.craftingQuality > 0 then
            local t = math.min(entry.craftingQuality, 5)
            stParts[#stParts+1] = CreateAtlasMarkup("Professions-ChatIcon-Quality-Tier" .. t, 16, 16)
        end
        f._subType:SetText(table.concat(stParts, "  "))
    end
    if entry.isGear then
        if db.showIlvl    and entry.ilvl     and entry.ilvl > 0     then subParts[#subParts+1] = "ilvl " .. entry.ilvl end
        if db.showTertiary and entry.tertiary and #entry.tertiary > 0 then subParts[#subParts+1] = entry.tertiary end
        if db.showSockets  and entry.sockets  and #entry.sockets  > 0 then subParts[#subParts+1] = entry.sockets  end
    elseif entry.append and #entry.append > 0 then
        if entry.rarity ~= 6 or db.showInvCount then
            subParts[#subParts+1] = entry.append
        end
    end
    if db.showInvCount and not entry.playerName and entry.invCount and entry.invCount > 0 then
        subParts[#subParts+1] = "|cffaaaaaa" .. entry.invCount .. " owned|r"
    end
    f._sub:SetText(table.concat(subParts, "  "))
    local priceLines = _priceLines
    wipe(priceLines)
    if db.showAHPrice and entry.ahPrice and entry.ahPrice > 0 then
        priceLines[#priceLines+1] = "|cff32bff7AH: " .. LLF.Price:FormatAuto(entry.ahPrice * count) .. "|r"
    end
    if db.showVendorPrice and entry.price and entry.price > 0 then
        local venAmt = db.showStackPrice and (entry.price * count) or entry.price
        priceLines[#priceLines+1] = "|cffffff00" .. LLF.Price:FormatAuto(venAmt) .. "|r"
    end
    f._price:SetText(table.concat(priceLines, "\n"))

    local target  = entry.playerNameFull or entry.playerName
    local display = entry.playerName
    if db.showWhisperButtons ~= false and target and entry.link then
        local btnSz = math.max(math.floor(rh * 0.24), 7)
        local gBtn, wBtn = f._instanceBtn, f._whisperBtn
        gBtn._whisperTarget = target; gBtn._whisperLink = entry.link; gBtn._whisperDisplay = display
        gBtn:SetSize(16, 13); do local bfs = gBtn:GetFontString(); if bfs then bfs:SetFont(fp, btnSz, "OUTLINE") end end
        wBtn._whisperTarget = target; wBtn._whisperLink = entry.link; wBtn._whisperDisplay = display
        wBtn:SetSize(16, 13); do local bfs = wBtn:GetFontString(); if bfs then bfs:SetFont(fp, btnSz, "OUTLINE") end end
        gBtn:ClearAllPoints(); gBtn:SetPoint("BOTTOMRIGHT", f._priceBox, "BOTTOMRIGHT", -18, 1); gBtn:Show()
        wBtn:ClearAllPoints(); wBtn:SetPoint("BOTTOMRIGHT", f._priceBox, "BOTTOMRIGHT",   0, 1); wBtn:Show()
    else
        local gBtn, wBtn = f._instanceBtn, f._whisperBtn
        if gBtn then gBtn._whisperTarget = nil; gBtn._whisperLink = nil; gBtn._whisperDisplay = nil; gBtn:Hide() end
        if wBtn then wBtn._whisperTarget = nil; wBtn._whisperLink = nil; wBtn._whisperDisplay = nil; wBtn:Hide() end
    end

    if f._offerBtn then
        local db2 = LLF.db
        local oBtn = f._offerBtn
        local minRar = (db2 and db2.offerMinRarity) or 2
        local rar    = entry.rarity or 1
        local tradeable = (entry.canAH ~= false)
            or (entry.canAH == false and (entry.source == 3 or entry.source == 4))
        local shouldOffer = (db2 and db2.offerEnabled ~= false)
            and entry.link
            and rar >= minRar
            and tradeable
            and not entry.playerName
        if shouldOffer then
            oBtn._offerLink = entry.link
            oBtn:SetSize(16, 13)
            local ofs2 = oBtn:GetFontString()
            if ofs2 then ofs2:SetFont(fp, math.max(math.floor(rh * 0.24), 7), "OUTLINE") end
            oBtn:ClearAllPoints()
            oBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
            if IsInGroup() or entry.isPreview then oBtn:Show() else oBtn:Hide() end
        else
            oBtn._offerLink = nil
            oBtn:Hide()
        end
    end

    ApplyRowGlow(f, entry)
end

local rows      = {}
Feed._rows = rows
local feedFrame = nil

local function ResizeFeedFrame()
    if not feedFrame then return end
    local db = LLF.db
    local n  = 0
    for _, r in ipairs(rows) do
        if r.rowFrame:IsShown() then n = n + 1 end
    end
    if n == 0 then feedFrame:Hide(); return end
    local rh = db.feedRowHeight or ROW_H
    local sp = db.feedSpacing   or ROW_SPACE
    local w  = db.feedWidth     or 280
    feedFrame:SetSize(w, PAD_TOP + n * rh + (n - 1) * sp + PAD_BOT)
    feedFrame:Show()
end

local function ReanchorFeedFrame()
    if not feedFrame then return end
    local db = LLF.db
    feedFrame:ClearAllPoints()
    if db.feedGrowUp then
        feedFrame:SetPoint("BOTTOM", UIParent, "CENTER", db.feedX or 200, db.feedY or 100)
    else
        feedFrame:SetPoint("TOP",    UIParent, "CENTER", db.feedX or 200, db.feedY or 100)
    end
end

local function PositionAllRows()
    if not feedFrame then return end
    local db     = LLF.db
    local rh     = db.feedRowHeight or ROW_H
    local sp     = db.feedSpacing   or ROW_SPACE
    local w      = db.feedWidth     or 280
    local growUp = db.feedGrowUp == true
    local slot = 0
    for _, r in ipairs(rows) do
        local f = r.rowFrame
        f:SetWidth(w - PAD_SIDE * 2)
        f:SetHeight(rh)
        f:ClearAllPoints()
        if not f:IsShown() then
            f:SetPoint("TOPLEFT", feedFrame, "TOPLEFT", -9999, 0)
        elseif growUp then
            f:SetPoint("BOTTOMLEFT", feedFrame, "BOTTOMLEFT", PAD_SIDE, PAD_BOT + slot*(rh+sp))
            slot = slot + 1
        else
            f:SetPoint("TOPLEFT",    feedFrame, "TOPLEFT",    PAD_SIDE, -(PAD_TOP + slot*(rh+sp)))
            slot = slot + 1
        end
    end
    ResizeFeedFrame()
end

local function BuildFeedFrame()
    if feedFrame then return end
    feedFrame = CreateFrame("Frame", "LarlenLootFrameFeed", UIParent, "BackdropTemplate")
    feedFrame:SetClampedToScreen(true)
    feedFrame:SetMovable(true)
    feedFrame:EnableMouse(true)
    feedFrame:RegisterForDrag("LeftButton")
    feedFrame:SetFrameStrata("MEDIUM")
    feedFrame:SetBackdrop(FEED_BACKDROP)
    feedFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.85)
    feedFrame:SetBackdropBorderColor(0.20, 0.20, 0.22, 0.90)
    feedFrame:SetScript("OnDragStart", function(f)
        if not LLF.db.feedLocked then f:StartMoving() end
    end)
    feedFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local db = LLF.db
        local cx = UIParent:GetCenter()
        local sh = UIParent:GetHeight()
        db.feedX = math.floor(f:GetLeft() + f:GetWidth()/2 - cx + 0.5)
        if db.feedGrowUp then
            db.feedY = math.floor(f:GetBottom() - sh/2 + 0.5)
        else
            db.feedY = math.floor(f:GetTop() - sh/2 + 0.5)
        end
    end)
    feedFrame:SetScript("OnMouseUp", function(_, btn)
        if btn ~= "RightButton" then return end
        for i, r in ipairs(rows) do
            if r.rowFrame:IsMouseOver() then
                if IsShiftKeyDown() and LLF.db.shiftClickBlacklist and r.entry.link then
                    LLF.Config:AddItemToBlacklist(r.entry.link)
                end
                ReleaseRow(r.rowFrame)
                table.remove(rows, i)
                PositionAllRows()
                return
            end
        end
    end)
    feedFrame:SetScript("OnUpdate", function(_, elapsed)
        Feed:OnUpdate(elapsed)
    end)
    feedFrame:Hide()
end

function Feed:ApplyLayout()
    if not feedFrame then return end
    local db = LLF.db
    feedFrame:SetAlpha(db.feedAlpha or 1.0)
    if db.feedBackground ~= false then
        feedFrame:SetBackdropColor(0.04, 0.04, 0.06, db.feedBgAlpha or 0.85)
        feedFrame:SetBackdropBorderColor(0.20, 0.20, 0.22, db.feedBgAlpha or 0.85)
    else
        feedFrame:SetBackdropColor(0, 0, 0, 0)
        feedFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end
    self:ApplyRowStyles()
end

function Feed:ApplyRowStyles()
    for _, r in ipairs(rows) do
        ApplyRowBorder(r.rowFrame)
    end
end

function Feed:ApplyFont()
    for _, r in ipairs(rows) do PopulateRow(r.rowFrame, r.entry) end
end

function Feed:SetLocked(locked)
    LLF.db.feedLocked = locked
    if feedFrame then feedFrame:EnableMouse(not locked) end
end

function Feed:AddEntry(entry)
    local db = LLF.db
    if not db or not db.enabled then return end
    if not feedFrame then self:Init() end

    local rar = entry.rarity or 1
    local pf = db.personalFilters
    if pf and pf.filterRarity and pf.filterRarity[rar] == false then return end

    if not entry.isPreview and db.wishlistEnabled and entry.link then
        if not LLF.Config:IsItemWishlisted(entry.link) then return end
    end

    local dur = (entry.source == 1) and LLF.Config:GetDuration("gold") or LLF.Config:GetDuration(rar)
    if not dur or dur <= 0 then return end

    local maxR = db.feedMaxRows or 10
    while #rows >= maxR do
        ReleaseRow(table.remove(rows).rowFrame)
    end

    if entry.mergeKey then
        for _, r in ipairs(rows) do
            if r.entry.mergeKey == entry.mergeKey then
                local newCount = (r.entry.count or 1) + (entry.count or 1)
                if r.entry.isGear or r.entry.canAH == false then newCount = 1 end
                r.entry.count = newCount
                if entry.isGear and entry.ilvl and entry.ilvl > (r.entry.ilvl or 0) then
                    r.entry.ilvl = entry.ilvl
                    r.entry.upgradeTrackTier = entry.upgradeTrackTier
                end
                r.expiresAt   = GetTime() + dur
                r.fadeStart   = nil
                r.rowFrame:SetAlpha(1)
                PopulateRow(r.rowFrame, r.entry)
                return
            end
        end
    end

    local f = AcquireRow(feedFrame)
    f:SetWidth((db.feedWidth or 280) - PAD_SIDE * 2)
    f:SetHeight(db.feedRowHeight or ROW_H)
    f:SetAlpha(1); f:Show()
    entry.count = entry.count or 1
    if entry.isPreview and db.showAHPrice and entry.link and not entry.ahPrice then
        local skipAH = (entry.canAH == false) or (not db.showJunkAH and (entry.rarity or 1) == 0)
        if not skipAH then
            local ahv = LLF.Price:GetAHValue(entry.link)
            if ahv then entry.ahPrice = ahv end
        end
    end
    PopulateRow(f, entry)

    local record = { entry=entry, rowFrame=f, expiresAt=GetTime()+dur, fadeStart=nil }
    table.insert(rows, 1, record)
    PositionAllRows()

    if db.showAHPrice and entry.link and not entry.ahPrice then
        local skipAH = (entry.canAH == false)
            or (not db.showJunkAH and (entry.rarity or 1) == 0)
            or entry.isPreview
        if not skipAH then
            C_Timer.After(0.05, function()
                local ahv = LLF.Price:GetAHValue(entry.link)
                if ahv then
                    record.entry.ahPrice = ahv
                    if record.rowFrame:IsShown() then PopulateRow(record.rowFrame, record.entry) end
                end
            end)
        end
    end

    if db.soundEnabled then
        local maxGold = 0
        if entry.price and entry.price > 0 then
            maxGold = math.max(maxGold, (entry.price * (entry.count or 1)) / 10000)
        end
        if entry.ahPrice and entry.ahPrice > 0 then
            maxGold = math.max(maxGold, entry.ahPrice / 10000)
        end
        if maxGold >= (db.soundThreshold or 200) then
            if not entry.isPreview or not Feed._previewSoundPlayed then
                if entry.isPreview then Feed._previewSoundPlayed = true end
                LLF:PlaySound(db.soundChoice or 1)
            end
        end
    end

    if db.wishlistSoundEnabled and entry.link and LLF.Config:IsItemWishlisted(entry.link) then
        LLF:PlaySound(db.wishlistSoundChoice or 1)
    end
end

function Feed:OnUpdate(_elapsed)
    if #rows == 0 then return end
    local db = LLF.db
    if not db or not db.enabled then return end
    local now      = GetTime()
    local fadeTime = db.fadeOutTime or 0.5
    local dirty    = false
    local inGroup  = IsInGroup()
    local i        = 1
    while i <= #rows do
        local r = rows[i]
        if r.rowFrame._offerBtn and r.rowFrame._offerBtn._offerLink then
            if inGroup or r.entry.isPreview then r.rowFrame._offerBtn:Show() else r.rowFrame._offerBtn:Hide() end
        end
        if r.entry.isPreview and Feed.testLocked then
            local rar = r.entry.rarity or 1
            local pf = db.personalFilters
            local filtered = (pf and pf.filterRarity and pf.filterRarity[rar] == false)
            if not filtered and r.entry.itemCategory then
                if r.entry.itemCategory == "pet"     and pf and pf.filterPets    == false then filtered = true end
                if r.entry.itemCategory == "mount"   and pf and pf.filterMounts  == false then filtered = true end
                if r.entry.itemCategory == "housing" and pf and pf.filterHousing == false then filtered = true end
            end
            if not filtered and db.blacklistEnabled and r.entry.link then
                if LLF.Config:IsItemBlacklisted(r.entry.link) then filtered = true end
            end
            if not filtered and db.wishlistEnabled and r.entry.link then
                if not LLF.Config:IsItemWishlisted(r.entry.link) then filtered = true end
            end
            if filtered then
                if r.rowFrame:IsShown() then r.rowFrame:Hide(); dirty = true end
            else
                if not r.rowFrame:IsShown() then r.rowFrame:Show(); dirty = true end
                r.rowFrame:SetAlpha(1)
            end
            r.expiresAt = now + 60
            r.fadeStart = nil
            i = i + 1
        elseif r.rowFrame:IsMouseOver() then
            local dur = (r.entry.source == 1)
                and LLF.Config:GetDuration("gold")
                or  LLF.Config:GetDuration(r.entry.rarity or 1)
            r.expiresAt = now + (dur or 5)
            r.fadeStart = nil
            r.rowFrame:SetAlpha(1)
            i = i + 1
        elseif now >= r.expiresAt then
            ReleaseRow(r.rowFrame)
            table.remove(rows, i)
            dirty = true
        elseif now >= r.expiresAt - fadeTime then
            r.fadeStart = r.fadeStart or now
            local alpha = math.max(0, 1 - ((now - r.fadeStart) / (fadeTime + 0.01)))
            r.rowFrame:SetAlpha(alpha)
            i = i + 1
        else
            if r.fadeStart then r.fadeStart = nil; r.rowFrame:SetAlpha(1) end
            i = i + 1
        end
    end
    if dirty then PositionAllRows() end
end

function Feed:ClearAll()
    for _, r in ipairs(rows) do ReleaseRow(r.rowFrame) end
    table.wipe(rows)
    if feedFrame then feedFrame:Hide() end
end

function Feed:Init()
    BuildFeedFrame()
    self:Refresh()
end

function Feed:Refresh()
    ReanchorFeedFrame()
    PositionAllRows()
    self:ApplyLayout()
end

function Feed:SetGrowDirection(growUp)
    local db = LLF.db
    local rh = db.feedRowHeight or ROW_H
    if growUp and not db.feedGrowUp then
        db.feedY = (db.feedY or 100) - PAD_TOP - PAD_BOT - rh
    elseif not growUp and db.feedGrowUp then
        db.feedY = (db.feedY or 100) + PAD_BOT + rh + PAD_TOP
    end
    db.feedGrowUp = growUp
    self:Refresh()
end

function Feed:RefreshRows()
    PositionAllRows()
    self:ApplyLayout()
end

function Feed:RefreshTestRows()
    if not Feed.testLocked then return end
    PositionAllRows()
    for _, r in ipairs(rows) do
        if r.entry.isPreview and r.rowFrame:IsShown() then
            PopulateRow(r.rowFrame, r.entry)
        end
    end
end

function Feed:Preview()
    self:ClearAll()
    local samples = {
        { icon=135274,  name="Thunderfury, Blessed Blade", rarity=5, source=4, ilvl=650,  isGear=true,  price=987654,  ahPrice=12500000, canAH=true,  tertiary="|cFF00FFFFLeech|r", subType="One-Handed Sword", mergeKey="pv1", isPreview=true,
          link="|cffff8000|Hitem:19019::::::::60:::::|h[Thunderfury, Blessed Blade]|h|r" },
        { icon=133765,  name="Thornwood Wristguards",        rarity=3, source=3, ilvl=285,  isGear=true,  price=1234,    isTransmog=true,  subType="Leather",            mergeKey="pv2", isPreview=true, upgradeTrackTier=2, craftingQuality=3,
          link="item:57232" },
        { icon=133784,  name="Money",                       rarity=1, source=1,            isGear=false, price=2345678,                                                  mergeKey="pv3", isPreview=true },
        { icon=463446,  name="Timewarped Badge",            rarity=6, source=2, count=40,  isGear=false, price=0,       append=" (2000)",                                mergeKey="pv4", isPreview=true },
        { icon=1455894, name="Honor",                       rarity=8, source=7, count=250, isGear=false, price=0,                                                        mergeKey="pv5", isPreview=true },
        { icon=4638563, name="Void-Touched Wristguard",    rarity=4, source=3, ilvl=639,  isGear=true,  price=85000,   isUpgrade=true,   subType="Plate",               mergeKey="pv6", isPreview=true, upgradeTrackTier=4,
          link="item:133632" },
        { icon=132261,  name="Reins of the Raven Lord",      rarity=4, source=3, count=1,   isGear=false, price=0,                           subType="Mount",               mergeKey="pv7", isPreview=true, itemCategory="mount",
          link="item:32768" },
        { icon=656558,  name="Disgusting Oozeling",         rarity=3, source=4, count=1,   isGear=false, price=0,                           subType="Pet",                 mergeKey="pv8", isPreview=true, itemCategory="pet",
          link="item:20769" },
    }
    local ids = {}
    for _, item in ipairs(samples) do
        if item.link then
            local id = tonumber(item.link:match("item:(%d+)"))
            if id and C_Item.RequestLoadItemDataByID then ids[#ids + 1] = id end
        end
    end
    local pending = #ids
    if pending == 0 then
        for _, item in ipairs(samples) do self:AddEntry(item) end
    else
        local fired = false
        local function TryShow()
            pending = pending - 1
            if pending <= 0 and not fired then
                fired = true
                for _, item in ipairs(samples) do self:AddEntry(item) end
            end
        end
        for _, id in ipairs(ids) do
            local itemObj = Item:CreateFromItemID(id)
            itemObj:ContinueOnItemLoad(TryShow)
        end
    end
end

local partyRows      = {}
local partyFeedFrame = nil

local function ResizePartyFeedFrame()
    if not partyFeedFrame then return end
    local pdf = LLF.db.partyFeed
    local n   = #partyRows
    if n == 0 then partyFeedFrame:Hide(); return end
    local rh = pdf.feedRowHeight or ROW_H
    local sp = pdf.feedSpacing   or ROW_SPACE
    local w  = pdf.feedWidth     or 280
    partyFeedFrame:SetSize(w, PAD_TOP + n * rh + (n-1) * sp + PAD_BOT)
    partyFeedFrame:Show()
end

local function ReanchorPartyFeedFrame()
    if not partyFeedFrame then return end
    local pdf    = LLF.db.partyFeed
    local growUp = pdf.feedGrowUp == true
    partyFeedFrame:ClearAllPoints()
    if growUp then
        partyFeedFrame:SetPoint("BOTTOM", UIParent, "CENTER", pdf.feedX or -250, pdf.feedY or 100)
    else
        partyFeedFrame:SetPoint("TOP",    UIParent, "CENTER", pdf.feedX or -250, pdf.feedY or 100)
    end
end

local function PositionAllPartyRows()
    if not partyFeedFrame then return end
    local pdf    = LLF.db.partyFeed
    local rh     = pdf.feedRowHeight or ROW_H
    local sp     = pdf.feedSpacing   or ROW_SPACE
    local w      = pdf.feedWidth     or 280
    local growUp = pdf.feedGrowUp == true
    for i, r in ipairs(partyRows) do
        local f = r.rowFrame
        f:SetWidth(w - PAD_SIDE * 2)
        f:SetHeight(rh)
        f:ClearAllPoints()
        if growUp then
            f:SetPoint("BOTTOMLEFT", partyFeedFrame, "BOTTOMLEFT", PAD_SIDE, PAD_BOT + (i-1)*(rh+sp))
        else
            f:SetPoint("TOPLEFT",    partyFeedFrame, "TOPLEFT",    PAD_SIDE, -(PAD_TOP + (i-1)*(rh+sp)))
        end
    end
    ResizePartyFeedFrame()
end

local function BuildPartyFeedFrame()
    if partyFeedFrame then return end
    partyFeedFrame = CreateFrame("Frame", "LarlenLootFramePartyFeed", UIParent, "BackdropTemplate")
    partyFeedFrame:SetClampedToScreen(true)
    partyFeedFrame:SetMovable(true)
    partyFeedFrame:EnableMouse(true)
    partyFeedFrame:RegisterForDrag("LeftButton")
    partyFeedFrame:SetFrameStrata("MEDIUM")
    partyFeedFrame:SetBackdrop(FEED_BACKDROP)
    partyFeedFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.85)
    partyFeedFrame:SetBackdropBorderColor(0.28, 0.16, 0.40, 0.90)
    partyFeedFrame:SetScript("OnDragStart", function(f)
        if not LLF.db.partyFeed.feedLocked then f:StartMoving() end
    end)
    partyFeedFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local pdf    = LLF.db.partyFeed
        local growUp = pdf.feedGrowUp == true
        local cx     = UIParent:GetCenter()
        local sh     = UIParent:GetHeight()
        if growUp then
            pdf.feedX = math.floor(f:GetLeft() + f:GetWidth()/2 - cx + 0.5)
            pdf.feedY = math.floor(f:GetBottom() - sh/2 + 0.5)
        else
            pdf.feedX = math.floor(f:GetLeft() + f:GetWidth()/2 - cx + 0.5)
            pdf.feedY = math.floor(f:GetTop() - sh/2 + 0.5)
        end
    end)
    partyFeedFrame:SetScript("OnMouseUp", function(_, btn)
        if btn ~= "RightButton" then return end
        for i, r in ipairs(partyRows) do
            if r.rowFrame:IsMouseOver() then
                if IsShiftKeyDown() and LLF.db.shiftClickBlacklist and r.entry.link then
                    LLF.Config:AddItemToBlacklist(r.entry.link)
                end
                ReleaseRow(r.rowFrame)
                table.remove(partyRows, i)
                PositionAllPartyRows()
                return
            end
        end
    end)
    partyFeedFrame:SetScript("OnUpdate", function(_, elapsed)
        PFeed:OnUpdate(elapsed)
    end)
    partyFeedFrame:Hide()
end

function PFeed:ApplyLayout()
    if not partyFeedFrame then return end
    local pdf = LLF.db.partyFeed
    partyFeedFrame:SetAlpha(pdf.feedAlpha or 1.0)
    if pdf.feedBackground ~= false then
        partyFeedFrame:SetBackdropColor(0.04, 0.04, 0.06, pdf.feedBgAlpha or 0.85)
        partyFeedFrame:SetBackdropBorderColor(0.28, 0.16, 0.40, pdf.feedBgAlpha or 0.85)
    else
        partyFeedFrame:SetBackdropColor(0, 0, 0, 0)
        partyFeedFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end
    self:ApplyRowStyles()
end

function PFeed:ApplyRowStyles()
    for _, r in ipairs(partyRows) do
        ApplyRowBorder(r.rowFrame)
    end
end

function PFeed:ApplyFont()
    for _, r in ipairs(partyRows) do PopulateRow(r.rowFrame, r.entry) end
end

function PFeed:SetLocked(locked)
    LLF.db.partyFeed.feedLocked = locked
    if partyFeedFrame then partyFeedFrame:EnableMouse(not locked) end
end

function PFeed:AddEntry(entry)
    local db  = LLF.db
    local pdf = db and db.partyFeed
    if not pdf or not pdf.enabled then return end
    if not partyFeedFrame then self:Init() end

    local rar = entry.rarity or 1
    local gf = db.groupFilters
    if gf and gf.filterRarity and gf.filterRarity[rar] == false then return end
    if rar < (pdf.filterMinRarity or 0) then return end

    if not entry.isPreview and db.wishlistEnabled and db.wishlistGroupLoot and entry.link then
        if not LLF.Config:IsItemWishlisted(entry.link) then return end
    end

    local dur = LLF.Config:GetDuration(rar, "group")
    if not dur or dur <= 0 then return end

    local maxR = pdf.feedMaxRows or 8
    while #partyRows >= maxR do
        ReleaseRow(table.remove(partyRows).rowFrame)
    end

    if entry.mergeKey then
        for _, r in ipairs(partyRows) do
            if r.entry.mergeKey == entry.mergeKey then
                local newCount = (r.entry.count or 1) + (entry.count or 1)
                if r.entry.isGear or r.entry.canAH == false then newCount = 1 end
                r.entry.count = newCount
                if entry.isGear and entry.ilvl and entry.ilvl > (r.entry.ilvl or 0) then
                    r.entry.ilvl = entry.ilvl
                    r.entry.upgradeTrackTier = entry.upgradeTrackTier
                end
                r.expiresAt   = GetTime() + dur
                r.fadeStart   = nil
                r.rowFrame:SetAlpha(1)
                PopulateRow(r.rowFrame, r.entry)
                return
            end
        end
    end

    local f = AcquireRow(partyFeedFrame)
    local pw = pdf.feedWidth or 280
    local prh = pdf.feedRowHeight or ROW_H
    f:SetWidth(pw - PAD_SIDE * 2)
    f:SetHeight(prh)
    f:SetAlpha(1); f:Show()
    entry.count = entry.count or 1
    PopulateRow(f, entry)

    local record = { entry=entry, rowFrame=f, expiresAt=GetTime()+dur, fadeStart=nil }
    table.insert(partyRows, 1, record)
    PositionAllPartyRows()

    if db.showAHPrice and entry.link and not entry.ahPrice then
        local skipAH = (entry.canAH == false)
            or (not db.showJunkAH and (entry.rarity or 1) == 0)
            or entry.isPreview
        if not skipAH then
            C_Timer.After(0.05, function()
                local ahv = LLF.Price:GetAHValue(entry.link)
                if ahv then
                    record.entry.ahPrice = ahv
                    if record.rowFrame:IsShown() then PopulateRow(record.rowFrame, record.entry) end
                end
            end)
        end
    end
end

function PFeed:OnUpdate(_elapsed)
    if #partyRows == 0 then return end
    local pdf = LLF.db.partyFeed
    if not pdf or not pdf.enabled then return end
    local now      = GetTime()
    local fadeTime = pdf.fadeOutTime or LLF.db.fadeOutTime or 0.5
    local dirty    = false
    local i        = 1
    local db = LLF.db
    while i <= #partyRows do
        local r = partyRows[i]
        if r.entry.isPreview and PFeed.testLocked then
            local rar = r.entry.rarity or 1
            local gf = db.groupFilters
            local filtered = (gf and gf.filterRarity and gf.filterRarity[rar] == false)
            if not filtered and r.entry.itemCategory then
                local pff = db.partyFeed
                if r.entry.itemCategory == "pet"   and pff and pff.filterPets   == false then filtered = true end
                if r.entry.itemCategory == "mount" and pff and pff.filterMounts == false then filtered = true end
            end
            if not filtered and db.blacklistEnabled and r.entry.link then
                if LLF.Config:IsItemBlacklisted(r.entry.link) then filtered = true end
            end
            if not filtered and db.wishlistEnabled and db.wishlistGroupLoot and r.entry.link then
                if not LLF.Config:IsItemWishlisted(r.entry.link) then filtered = true end
            end
            if filtered then
                if r.rowFrame:IsShown() then r.rowFrame:Hide(); dirty = true end
            else
                if not r.rowFrame:IsShown() then r.rowFrame:Show(); dirty = true end
                r.rowFrame:SetAlpha(1)
            end
            r.expiresAt = now + 60
            r.fadeStart = nil
            i = i + 1
        elseif r.rowFrame:IsMouseOver() then
            local dur = LLF.Config:GetDuration(r.entry.rarity or 1, "group")
            r.expiresAt = now + (dur or 5)
            r.fadeStart = nil
            r.rowFrame:SetAlpha(1)
            i = i + 1
        elseif now >= r.expiresAt then
            ReleaseRow(r.rowFrame)
            table.remove(partyRows, i)
            dirty = true
        elseif now >= r.expiresAt - fadeTime then
            r.fadeStart = r.fadeStart or now
            local alpha = math.max(0, 1 - ((now - r.fadeStart) / (fadeTime + 0.01)))
            r.rowFrame:SetAlpha(alpha)
            i = i + 1
        else
            if r.fadeStart then r.fadeStart = nil; r.rowFrame:SetAlpha(1) end
            i = i + 1
        end
    end
    if dirty then PositionAllPartyRows() end
end

function PFeed:ClearAll()
    for _, r in ipairs(partyRows) do ReleaseRow(r.rowFrame) end
    table.wipe(partyRows)
    if partyFeedFrame then partyFeedFrame:Hide() end
end

function PFeed:Init()
    BuildPartyFeedFrame()
    self:Refresh()
end

function PFeed:Refresh()
    ReanchorPartyFeedFrame()
    PositionAllPartyRows()
    self:ApplyLayout()
end

function PFeed:SetGrowDirection(growUp)
    local pdf = LLF.db.partyFeed
    local rh = pdf.feedRowHeight or ROW_H
    if growUp and not pdf.feedGrowUp then
        pdf.feedY = (pdf.feedY or 100) - PAD_TOP - PAD_BOT - rh
    elseif not growUp and pdf.feedGrowUp then
        pdf.feedY = (pdf.feedY or 100) + PAD_BOT + rh + PAD_TOP
    end
    pdf.feedGrowUp = growUp
    self:Refresh()
end

function PFeed:RefreshRows()
    PositionAllPartyRows()
    self:ApplyLayout()
end

function PFeed:RefreshTestRows()
    if not PFeed.testLocked then return end
    PositionAllPartyRows()
    for _, r in ipairs(partyRows) do
        if r.entry.isPreview and r.rowFrame:IsShown() then
            PopulateRow(r.rowFrame, r.entry)
        end
    end
end

function PFeed:Preview()
    self:ClearAll()
    local samples = {
        { icon=135274,  name="Thunderfury, Blessed Blade",   rarity=5, source=4, ilvl=650, isGear=true,  price=987654,
          playerName="Grimveil", playerNameFull="Grimveil", subType="One-Handed Sword", mergeKey="ppvWHISPER_TEST", isPreview=true,
          link="|cffff8000|Hitem:19019::::::::60:::::|h[Thunderfury, Blessed Blade]|h|r" },
        { icon=136243,  name="Dreadful Gladiator's Blade",  rarity=4, source=3, ilvl=398, isGear=true,  price=50000,  subType="Two-Handed Sword", playerName="Stormwrath", mergeKey="ppv1", isPreview=true, upgradeTrackTier=3,
          link="item:19364" },
        { icon=133784,  name="Money",                        rarity=1, source=1,           isGear=false, price=123456,                             playerName="Thalor",    mergeKey="ppv2", isPreview=true },
        { icon=463446,  name="Timewarped Badge",             rarity=6, source=2, count=15, isGear=false, price=0,      append=" (500)",            playerName="Frostfell", mergeKey="ppv3", isPreview=true },
        { icon=133765,  name="Thornwood Wristguards",        rarity=3, source=3, ilvl=285, isGear=true,  price=1234,   subType="Leather",          playerName="Vaelos",    mergeKey="ppv4", isPreview=true, isTransmog=true, upgradeTrackTier=2, craftingQuality=3,
          link="item:57232" },
        { icon=4638563, name="Void-Touched Wristguard",      rarity=4, source=3, ilvl=639, isGear=true,  price=0,      subType="Plate",            playerName="Nightfall", mergeKey="ppv5", isPreview=true, isUpgrade=true, upgradeTrackTier=5,
          link="item:133632" },
        { icon=132261,  name="Reins of the Raven Lord",       rarity=4, source=3, count=1,  isGear=false, price=0,      subType="Mount",            playerName="Aetheron",  mergeKey="ppv6", isPreview=true, itemCategory="mount",
          link="item:32768" },
        { icon=656558,  name="Disgusting Oozeling",          rarity=3, source=4, count=1,  isGear=false, price=0,      subType="Pet",              playerName="Cinderfall", mergeKey="ppv7", isPreview=true, itemCategory="pet",
          link="item:20769" },
    }
    local ids = {}
    for _, item in ipairs(samples) do
        if item.link then
            local id = tonumber(item.link:match("item:(%d+)"))
            if id and C_Item.RequestLoadItemDataByID then ids[#ids + 1] = id end
        end
    end
    local pending = #ids
    if pending == 0 then
        for _, item in ipairs(samples) do self:AddEntry(item) end
    else
        local fired = false
        local function TryShow()
            pending = pending - 1
            if pending <= 0 and not fired then
                fired = true
                for _, item in ipairs(samples) do self:AddEntry(item) end
            end
        end
        for _, id in ipairs(ids) do
            local itemObj = Item:CreateFromItemID(id)
            itemObj:ContinueOnItemLoad(TryShow)
        end
    end
end
