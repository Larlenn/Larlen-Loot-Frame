local LLF = LarlenLootFrame
LLF.Options = {}
local Opt = LLF.Options

local IsAddonLoaded = LLF.IsAddonLoaded

local ACCENT  = { 0.20, 0.75, 1.00 }
local WHITE   = { 1.00, 1.00, 1.00 }
local GREY    = { 0.55, 0.55, 0.60 }
local DIM     = { 0.38, 0.38, 0.42 }
local DIMMER  = { 0.25, 0.25, 0.28 }

local ROW_OFF = { 0.09, 0.09, 0.12, 0.90 }
local ROW_ON  = { 0.04, 0.18, 0.22, 0.95 }
local ROW_HOV = { 0.15, 0.25, 0.32, 0.95 }

local BTN_BG  = { 0.10, 0.10, 0.14, 1.00 }
local BTN_HOV = { 0.18, 0.28, 0.36, 1.00 }

local ROW_H = 26
local SEP   = 4
local SEC_H = 24

local FLAT_BD = {
    bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8",
    tileEdge = false, edgeSize = 1, insets = { left=1, right=1, top=1, bottom=1 },
}
local WIN_BD = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tileEdge = false, edgeSize = 1,
    insets   = { left=1, right=1, top=1, bottom=1 },
}

local _uid = 0
local function N(b) _uid = _uid + 1; return ("LLF_Opt_%s%d"):format(b, _uid) end

local isRefreshing = false
local allToggles   = {}
local allSliders   = {}
local allPickers   = {}   -- list pickers that need refresh

local function RefreshAll()
    if not LLF.db then return end
    isRefreshing = true
    for _, t in ipairs(allToggles) do if t.Sync   then t:Sync()     end end
    for _, s in ipairs(allSliders) do if s._refresh then s._refresh() end end
    for _, p in ipairs(allPickers) do if p._refresh then p._refresh() end end
    if LLF.Feed and LLF.Feed.RefreshTestRows then LLF.Feed:RefreshTestRows() end
    if LLF.PartyFeed and LLF.PartyFeed.RefreshTestRows then LLF.PartyFeed:RefreshTestRows() end
    isRefreshing = false
end
Opt.RefreshAll = RefreshAll


local function MakeToggle(parent, label, getVal, setVal)
    local b = CreateFrame("Button", N("T"), parent, "BackdropTemplate")
    b:SetHeight(ROW_H); b:SetBackdrop(FLAT_BD)

    local sqBorder = b:CreateTexture(nil, "ARTWORK")
    sqBorder:SetSize(12, 12); sqBorder:SetPoint("RIGHT", b, -8, 0)
    sqBorder:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    local sqFill = b:CreateTexture(nil, "OVERLAY")
    sqFill:SetSize(8, 8); sqFill:SetPoint("CENTER", sqBorder)
    sqFill:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    b._sq = sqFill

    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("LEFT", b, 10, 0); fs:SetPoint("RIGHT", sqBorder, "LEFT", -6, 0)
    fs:SetJustifyH("LEFT"); fs:SetText(label or ""); b._fs = fs

    local function Sync()
        local on = getVal()
        b:SetBackdropColor(on and ROW_ON[1] or ROW_OFF[1], on and ROW_ON[2] or ROW_OFF[2],
                           on and ROW_ON[3] or ROW_OFF[3], on and ROW_ON[4] or ROW_OFF[4])
        b:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], on and 0.70 or 0.22)
        sqFill:SetShown(on)
        sqBorder:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], on and 0.55 or 0.25)
        fs:SetTextColor(on and WHITE[1] or DIM[1], on and WHITE[2] or DIM[2],
                        on and WHITE[3] or DIM[3], 1)
    end
    b:SetScript("OnClick", function() setVal(not getVal()); RefreshAll() end)
    b:SetScript("OnEnter", function()
        b:SetBackdropColor(ROW_HOV[1], ROW_HOV[2], ROW_HOV[3], ROW_HOV[4])
        b:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.55)
    end)
    b:SetScript("OnLeave", Sync)
    Sync(); b.Sync = Sync
    allToggles[#allToggles + 1] = b
    return b
end

local function MakeRadio(parent, labelA, labelB, isASelected, onA, onB)
    local btnA = CreateFrame("Button", N("RA"), parent, "BackdropTemplate")
    local btnB = CreateFrame("Button", N("RB"), parent, "BackdropTemplate")

    local function SyncBoth()
        local aOn = isASelected()
        for _, btn in ipairs({ btnA, btnB }) do
            local on = (btn == btnA) == aOn
            btn:SetBackdropColor(on and ROW_ON[1] or ROW_OFF[1], on and ROW_ON[2] or ROW_OFF[2],
                                 on and ROW_ON[3] or ROW_OFF[3], on and ROW_ON[4] or ROW_OFF[4])
            btn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], on and 0.70 or 0.22)
            if btn._sq then
                btn._sq:SetShown(on)
                btn._sqBorder:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], on and 0.55 or 0.25)
            end
            if btn._fs then
                btn._fs:SetTextColor(on and WHITE[1] or DIM[1], on and WHITE[2] or DIM[2],
                                     on and WHITE[3] or DIM[3], 1)
            end
        end
    end
    for idx, btn in ipairs({ btnA, btnB }) do
        btn:SetHeight(ROW_H); btn:SetBackdrop(FLAT_BD)
        local sqBorder = btn:CreateTexture(nil, "ARTWORK")
        sqBorder:SetSize(12, 12); sqBorder:SetPoint("RIGHT", btn, -8, 0)
        sqBorder:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
        btn._sqBorder = sqBorder
        local sqFill = btn:CreateTexture(nil, "OVERLAY")
        sqFill:SetSize(8, 8); sqFill:SetPoint("CENTER", sqBorder)
        sqFill:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1); btn._sq = sqFill
        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("LEFT", btn, 10, 0); fs:SetPoint("RIGHT", sqBorder, "LEFT", -6, 0)
        fs:SetJustifyH("LEFT"); fs:SetText(idx == 1 and labelA or labelB); btn._fs = fs
        btn:SetScript("OnEnter", function()
            btn:SetBackdropColor(ROW_HOV[1], ROW_HOV[2], ROW_HOV[3], ROW_HOV[4])
            btn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.55)
        end)
        btn:SetScript("OnLeave", SyncBoth)
    end
    btnA:SetScript("OnClick", function() onA(); RefreshAll() end)
    btnB:SetScript("OnClick", function() onB(); RefreshAll() end)
    SyncBoth(); btnA.Sync = SyncBoth; btnB.Sync = SyncBoth
    allToggles[#allToggles + 1] = btnA
    allToggles[#allToggles + 1] = btnB
    return btnA, btnB
end

local function MakeSlider(parent, label, minV, maxV, step, getVal, setVal, suffix)
    local cont = CreateFrame("Frame", N("SC"), parent); cont:SetHeight(44)

    local lbl = cont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", cont, 0, -2); lbl:SetJustifyH("LEFT")
    lbl:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 0.90); lbl:SetText(label or "")

    local valLbl = cont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valLbl:SetPoint("TOPRIGHT", cont, 0, -2); valLbl:SetJustifyH("RIGHT")
    valLbl:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local function FmtVal(v)
        return tostring(v) .. (suffix or "")
    end

    local track = CreateFrame("Frame", nil, cont, "BackdropTemplate")
    track:SetPoint("BOTTOMLEFT", cont, 0, 4); track:SetPoint("BOTTOMRIGHT", cont, 0, 4)
    track:SetHeight(6)
    track:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    track:SetBackdropColor(0.12, 0.12, 0.16, 1)

    local s = CreateFrame("Slider", N("SL"), cont, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL"); s:SetMinMaxValues(minV, maxV); s:SetValueStep(step or 1)
    s:SetAllPoints(track)
    s:SetHitRectInsets(0, 0, -10, -10)  -- expand clickable area 10px above and below track
    s:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    s:SetBackdropColor(0, 0, 0, 0); s:SetBackdropBorderColor(0, 0, 0, 0)

    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    thumb:SetSize(8, 16); s:SetThumbTexture(thumb)

    s:SetScript("OnValueChanged", function(_, v)
        if isRefreshing then return end
        v = math.floor(v / (step or 1) + 0.5) * (step or 1)
        setVal(v); valLbl:SetText(FmtVal(v))
        RefreshAll()
    end)

    local function Refresh()
        local v = getVal(); s:SetValue(v); valLbl:SetText(FmtVal(v))
    end
    Refresh(); cont._refresh = Refresh
    allSliders[#allSliders + 1] = cont
    return cont
end

local function FormatK(n)
    if n >= 1000 then
        local k = n / 1000
        local floored = math.floor(k * 10 + 0.5) / 10
        if floored == math.floor(floored) then
            return tostring(math.floor(floored)) .. "k"
        else
            return tostring(floored) .. "k"
        end
    end
    return tostring(n)
end

local function ParseK(str)
    str = str:gsub("%s", "")
    local k = str:match("^([%d%.]+)[kK]$")
    if k then return tonumber(k) and (tonumber(k) * 1000) or nil end
    return tonumber(str)
end

local function MakeSliderWithInput(parent, label, minV, maxV, step, getVal, setVal, suffix)
    local cont = CreateFrame("Frame", N("SC"), parent); cont:SetHeight(44)

    local lbl = cont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", cont, 0, -2); lbl:SetJustifyH("LEFT")
    lbl:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 0.90); lbl:SetText(label or "")

    local eb = CreateFrame("EditBox", N("SEB"), cont, "BackdropTemplate")
    eb:SetSize(72, 18)
    eb:SetPoint("TOPRIGHT", cont, 0, -1)
    eb:SetBackdrop(FLAT_BD)
    eb:SetBackdropColor(0.08, 0.08, 0.11, 1)
    eb:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    eb:SetFontObject("GameFontNormal")
    eb:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    eb:SetJustifyH("CENTER")
    eb:SetMaxLetters(10)
    eb:SetAutoFocus(false)
    eb:SetNumeric(false)

    local function FmtEB(n)
        if suffix then return FormatK(n) .. suffix end
        return FormatK(n)
    end
    local function ParseEB(raw)
        if suffix then
            local idx = raw:find(suffix, 1, true)
            if idx then raw = raw:sub(1, idx - 1) end
        end
        raw = raw:gsub("%s", "")
        return tonumber(raw)  -- handles 12.5, 5, 0, etc.
    end

    local track = CreateFrame("Frame", nil, cont, "BackdropTemplate")
    track:SetPoint("BOTTOMLEFT", cont, 0, 4); track:SetPoint("BOTTOMRIGHT", cont, 0, 4)
    track:SetHeight(6)
    track:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    track:SetBackdropColor(0.12, 0.12, 0.16, 1)

    local s = CreateFrame("Slider", N("SL"), cont, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL"); s:SetMinMaxValues(minV, maxV); s:SetValueStep(step or 1)
    s:SetAllPoints(track)
    s:SetHitRectInsets(0, 0, -10, -10)
    s:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    s:SetBackdropColor(0, 0, 0, 0); s:SetBackdropBorderColor(0, 0, 0, 0)

    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    thumb:SetSize(8, 16); s:SetThumbTexture(thumb)

    local function Commit(raw)
        local n = ParseEB(raw)
        if not n then eb:SetText(FmtEB(getVal())); return end
        n = math.max(minV, math.min(maxV, math.floor(n / (step or 1) + 0.5) * (step or 1)))
        setVal(n)
        s:SetValue(n)
        eb:SetText(FmtEB(n))
        eb:ClearFocus()
        RefreshAll()
    end

    s:SetScript("OnValueChanged", function(_, v)
        if isRefreshing then return end
        v = math.floor(v / (step or 1) + 0.5) * (step or 1)
        setVal(v); eb:SetText(FmtEB(v))
        RefreshAll()
    end)

    eb:SetScript("OnEnterPressed", function(self) Commit(self:GetText()) end)
    eb:SetScript("OnEscapePressed", function(self)
        self:SetText(FmtEB(getVal())); self:ClearFocus()
    end)
    eb:SetScript("OnEditFocusLost", function(self) Commit(self:GetText()) end)
    eb:SetScript("OnEnter", function()
        eb:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    eb:SetScript("OnLeave", function()
        eb:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)

    local function Refresh()
        local v = getVal(); s:SetValue(v); eb:SetText(FmtEB(v))
    end
    Refresh(); cont._refresh = Refresh
    cont._lbl   = lbl
    cont._eb    = eb
    cont._s     = s
    cont._thumb = thumb
    cont._track = track
    allSliders[#allSliders + 1] = cont
    return cont
end

local function MakeHeader(parent, text)
    local cont = CreateFrame("Frame", N("H"), parent); cont:SetHeight(SEC_H)
    local fs = cont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", cont, 2, -2)
    fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1); fs:SetText(text or "")
    local line = cont:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("BOTTOMLEFT", cont, 0, 2); line:SetPoint("BOTTOMRIGHT", cont, 0, 2)
    line:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
    return cont
end

local function MakeBtn(parent, label, w, h)
    local b = CreateFrame("Button", N("B"), parent, "BackdropTemplate")
    b:SetSize(w or 110, h or ROW_H)
    b:SetBackdrop(FLAT_BD)
    b:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
    b:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("CENTER"); fs:SetText(label or ""); fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    b._fs = fs
    b:SetScript("OnEnter", function(s)
        s:SetBackdropColor(BTN_HOV[1], BTN_HOV[2], BTN_HOV[3], BTN_HOV[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
        fs:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    end)
    b:SetScript("OnLeave", function(s)
        s:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
        fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    end)
    return b
end

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

local activePickerList = nil  -- only one open at a time

local function MakeListPicker(parent, label, h, getVal, setVal, itemsFn)
    local cont = CreateFrame("Frame", N("LP"), parent)
    cont:SetHeight(h or 40)

    local lbl = cont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", cont, 0, -2)
    lbl:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 0.80)
    lbl:SetText(label or "")

    local btn = CreateFrame("Button", N("LPB"), cont, "BackdropTemplate")
    if label and label ~= "" then
        btn:SetHeight(22)
        btn:SetPoint("BOTTOMLEFT",  cont, 0, 0)
        btn:SetPoint("BOTTOMRIGHT", cont, 0, 0)
    else
        btn:SetPoint("TOPLEFT",     cont, 0, 0)
        btn:SetPoint("BOTTOMRIGHT", cont, 0, 0)
    end
    btn:SetBackdrop(FLAT_BD)
    btn:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
    btn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local btnFS = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnFS:SetPoint("LEFT",  btn, 6, 0)
    btnFS:SetPoint("RIGHT", btn, -22, 0)   -- leave room for arrow
    btnFS:SetJustifyH("LEFT")
    btnFS:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)

    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(16, 16)
    arrow:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
    arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    arrow:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.80)

    local list = CreateFrame("Frame", N("LPL"), UIParent, "BackdropTemplate")
    list:SetFrameStrata("TOOLTIP")
    list:SetBackdrop(FLAT_BD)
    list:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
    list:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.55)
    list:Hide()

    local sf = CreateFrame("ScrollFrame", N("LPS"), list, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",    list,  4, -4)
    sf:SetPoint("BOTTOMRIGHT", list, -22, 4)

    local content = CreateFrame("Frame", nil, sf)
    sf:SetScrollChild(content)

    local ITEM_H = 22

    local function BuildList()
        local n = select("#", content:GetChildren())
        for i = 1, n do
            local child = select(i, content:GetChildren())
            if child then child:SetParent(nil); child:Hide() end
        end

        local items = itemsFn()
        local contentW = math.max((list:GetWidth() or 0) - 26, 60)
        content:SetWidth(contentW)

        for i, item in ipairs(items) do
            local row = CreateFrame("Button", nil, content, "BackdropTemplate")
            row:SetHeight(ITEM_H)
            row:SetPoint("TOPLEFT",  content, 0, -(i-1)*ITEM_H)
            row:SetPoint("TOPRIGHT", content, 0, -(i-1)*ITEM_H)
            row:SetBackdrop(FLAT_BD)
            row:SetBackdropColor(0, 0, 0, 0)
            row:SetBackdropBorderColor(0, 0, 0, 0)

            local rfs = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rfs:SetPoint("LEFT", row, 8, 0)
            rfs:SetPoint("RIGHT", row, -6, 0)
            rfs:SetJustifyH("LEFT")
            rfs:SetWordWrap(false)
            local isSelected = (item.value == getVal())
            rfs:SetTextColor(
                isSelected and ACCENT[1] or WHITE[1],
                isSelected and ACCENT[2] or WHITE[2],
                isSelected and ACCENT[3] or WHITE[3], 1)
            rfs:SetText(item.display)

            row:SetScript("OnClick", function()
                setVal(item.value)
                btnFS:SetText(item.display)
                list:Hide()
                activePickerList = nil
                RefreshAll()
            end)
            row:SetScript("OnEnter", function()
                row:SetBackdropColor(ACCENT[1]*0.12, ACCENT[2]*0.12, ACCENT[3]*0.12, 1)
            end)
            row:SetScript("OnLeave", function()
                row:SetBackdropColor(0, 0, 0, 0)
            end)
        end

        local listH = math.min(#items * ITEM_H + 8, 220)
        list:SetHeight(listH)
        content:SetHeight(#items * ITEM_H)
    end

    btn:SetScript("OnClick", function()
        if list:IsShown() then
            list:Hide()
            activePickerList = nil
            return
        end
        if activePickerList and activePickerList ~= list then
            activePickerList:Hide()
        end
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
        list:SetWidth(btn:GetWidth())
        list:Show()
        activePickerList = list
        BuildList()
    end)
    btn:SetScript("OnEnter", function(s)
        s:SetBackdropColor(BTN_HOV[1], BTN_HOV[2], BTN_HOV[3], BTN_HOV[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    btn:SetScript("OnLeave", function(s)
        s:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)

    local function Refresh()
        local val = getVal()
        local items = itemsFn()
        local display = val
        for _, item in ipairs(items) do
            if item.value == val then display = item.display; break end
        end
        btnFS:SetText(display ~= "" and display or "Default (Auto)")
    end
    Refresh()
    cont._refresh = Refresh
    cont._list    = list
    cont._btn     = btn
    allPickers[#allPickers + 1] = cont
    return cont
end

local function FontItems()
    local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
    local items = { { value = "", display = "Default (Auto)" } }
    if lsm then
        local fonts = lsm:HashTable("font")
        local names = {}
        for name in pairs(fonts) do names[#names+1] = name end
        table.sort(names)
        for _, name in ipairs(names) do
            items[#items+1] = { value = name, display = name }
        end
    else
        local builtins = {
            "Friz Quadrata TT", "Arial Narrow", "Skurri",
            "Morpheus", "Adventure Normal", "PT Sans Narrow",
        }
        for _, name in ipairs(builtins) do
            items[#items+1] = { value = name, display = name }
        end
    end
    return items
end

local function SoundItems()
    return LLF:GetSoundList()
end

local function GateSlider(sc, active)
    if sc._lbl then sc._lbl:SetAlpha(active and 1 or 0.35) end
    if sc._track then
        sc._track:SetBackdropColor(active and 0.12 or 0.06, active and 0.12 or 0.06, active and 0.16 or 0.08, 1)
    end
    if sc._thumb then
        sc._thumb:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], active and 0.90 or 0.25)
        sc._thumb:EnableMouse(active)
    end
    if sc._eb then
        sc._eb:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], active and 1 or 0.3)
        sc._eb:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], active and 0.45 or 0.15)
        sc._eb:SetBackdropColor(0.08, 0.08, 0.11, active and 1 or 0.4)
        if not active and sc._eb:HasFocus() then sc._eb:ClearFocus() end
    end
end

local function MakePage(parent, CW)
    local PAD  = 10
    local HALF = math.floor((CW - PAD * 2 - 8) / 2)
    local y    = 0

    local function Sep(x) y = y - (x or SEP) end

    local function Header(text)
        Sep(6)
        local h = MakeHeader(parent, text)
        h:SetPoint("TOPLEFT", parent, PAD, y); h:SetPoint("TOPRIGHT", parent, -PAD, y)
        y = y - SEC_H - 2
    end

    local function Row(label, getVal, setVal)
        local t = MakeToggle(parent, label, getVal, setVal)
        t:SetPoint("TOPLEFT", parent, PAD, y); t:SetPoint("TOPRIGHT", parent, -PAD, y)
        y = y - ROW_H - SEP
        return t
    end

    local function RowL(label, getVal, setVal)
        local t = MakeToggle(parent, label, getVal, setVal)
        t:SetPoint("TOPLEFT", parent, PAD, y); t:SetWidth(HALF)
        return t
    end

    local function RowR(label, getVal, setVal)
        local t = MakeToggle(parent, label, getVal, setVal)
        t:SetPoint("TOPLEFT", parent, PAD + HALF + 8, y); t:SetWidth(HALF)
        y = y - ROW_H - SEP
        return t
    end

    local function Slide(label, minV, maxV, step, getVal, setVal, suffix)
        local s = MakeSlider(parent, label, minV, maxV, step, getVal, setVal, suffix)
        s:SetPoint("TOPLEFT", parent, PAD, y); s:SetPoint("TOPRIGHT", parent, -PAD, y)
        y = y - 44 - SEP
        return s
    end

    local function SlideInput(label, minV, maxV, step, getVal, setVal)
        local s = MakeSliderWithInput(parent, label, minV, maxV, step, getVal, setVal)
        s:SetPoint("TOPLEFT", parent, PAD, y); s:SetPoint("TOPRIGHT", parent, -PAD, y)
        y = y - 44 - SEP
        return s
    end

    local function SlideL(label, minV, maxV, step, getVal, setVal, suffix)
        local s = MakeSlider(parent, label, minV, maxV, step, getVal, setVal, suffix)
        s:SetPoint("TOPLEFT", parent, PAD, y); s:SetWidth(HALF)
        return s
    end

    local function SlideR(label, minV, maxV, step, getVal, setVal, suffix)
        local s = MakeSlider(parent, label, minV, maxV, step, getVal, setVal, suffix)
        s:SetPoint("TOPLEFT", parent, PAD + HALF + 8, y); s:SetWidth(HALF)
        y = y - 44 - SEP
        return s
    end

    local function SlideInputL(label, minV, maxV, step, getVal, setVal, suffix)
        local s = MakeSliderWithInput(parent, label, minV, maxV, step, getVal, setVal, suffix)
        s:SetPoint("TOPLEFT", parent, PAD, y); s:SetWidth(HALF)
        return s
    end

    local function SlideInputR(label, minV, maxV, step, getVal, setVal, suffix)
        local s = MakeSliderWithInput(parent, label, minV, maxV, step, getVal, setVal, suffix)
        s:SetPoint("TOPLEFT", parent, PAD + HALF + 8, y); s:SetWidth(HALF)
        y = y - 44 - SEP
        return s
    end

    local function Label(text, color)
        local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", parent, PAD, y)
        fs:SetTextColor((color or WHITE)[1], (color or WHITE)[2], (color or WHITE)[3], 0.80)
        fs:SetText(text)
        y = y - 20 - SEP
        return fs
    end

    local function Picker(label, hPx, getVal, setVal, itemsFn)
        local lp = MakeListPicker(parent, label, hPx, getVal, setVal, itemsFn)
        lp:SetPoint("TOPLEFT",  parent, PAD,  y)
        lp:SetPoint("TOPRIGHT", parent, -PAD, y)
        y = y - hPx - SEP
        return lp
    end

    local function Finalize()
        parent:SetHeight(math.abs(y) + 16)
    end

    return {
        Sep=Sep, Header=Header, Row=Row, RowL=RowL, RowR=RowR,
        Slide=Slide, SlideInput=SlideInput, SlideL=SlideL, SlideR=SlideR,
        SlideInputL=SlideInputL, SlideInputR=SlideInputR,
        Label=Label, Picker=Picker,
        Finalize=Finalize,
        PAD=PAD, HALF=HALF, SEP=SEP,
        GetY=function() return y end, SetY=function(v) y=v end,
        Parent=parent,
    }
end


local function PageGeneral(parent, CW)
    local p = MakePage(parent, CW)

    p.Header("Feed")
    p.Row("Enable loot feed",
        function() return LLF.db.enabled end,
        function(v) LLF.db.enabled = v; if not v then LLF.Feed:ClearAll() end end)
    p.Row("Hide Blizzard loot window and toasts",
        function() return LLF.db.suppressDefaultLoot end,
        function(v) LLF.db.suppressDefaultLoot = v end)
    p.Row("Shift + Right-Click to blacklist items",
        function() return LLF.db.shiftClickBlacklist end,
        function(v) LLF.db.shiftClickBlacklist = v end)

    p.Header("Minimap")
    p.Row("Show minimap icon",
        function() return LLF.db.showMinimap ~= false end,
        function(v) LLF.db.showMinimap = v; LLF.Minimap:ApplyVisibility() end)

    p.Header("Font")
    p.Picker("", 24,
        function() return LLF.db.feedFont or "" end,
        function(v)
            LLF.db.feedFont = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end,
        FontItems)

    p.Header("Item Info")
    p.RowL("Show item level for gear",
        function() return LLF.db.showIlvl end,
        function(v) LLF.db.showIlvl = v; LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end)
    p.RowR("Show armor / weapon type",
        function() return LLF.db.showSubType end,
        function(v)
            LLF.db.showSubType = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    p.RowL("Show sockets",
        function() return LLF.db.showSockets end,
        function(v) LLF.db.showSockets = v; LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end)
    p.RowR("Show tertiary stats",
        function() return LLF.db.showTertiary end,
        function(v) LLF.db.showTertiary = v; LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end)
    p.RowL("Show stack count",
        function() return LLF.db.showCount end,
        function(v)
            LLF.db.showCount = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    p.RowR("Show bag count",
        function() return LLF.db.showInvCount end,
        function(v) LLF.db.showInvCount = v; LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end)
    p.RowL("Show rarity color bar",
        function() return LLF.db.showRarityBar ~= false end,
        function(v)
            LLF.db.showRarityBar = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    do
        local y0 = p.GetY()
        local rightX = p.PAD + p.HALF + 8

        local borderToggle = MakeToggle(parent, "Icon border",
            function() return LLF.db.showIconBorder == true end,
            function(v)
                LLF.db.showIconBorder = v
                LLF.Feed:ApplyFont()
                if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
                LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
            end)
        borderToggle:SetPoint("TOPLEFT", parent, rightX, y0)
        borderToggle:SetWidth(p.HALF - 62)

        local plusBtn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        plusBtn:SetSize(18, ROW_H - 4)
        plusBtn:SetPoint("TOPLEFT", parent, rightX + p.HALF - 18, y0 - 2)
        plusBtn:SetBackdrop(FLAT_BD)
        plusBtn:SetBackdropColor(0.08, 0.08, 0.11, 1)
        plusBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
        local plusFS = plusBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        plusFS:SetAllPoints(); plusFS:SetJustifyH("CENTER")
        plusFS:SetText("+"); plusFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

        local valFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valFS:SetSize(18, ROW_H)
        valFS:SetPoint("TOPRIGHT", plusBtn, "TOPLEFT", 0, 2)
        valFS:SetJustifyH("CENTER")
        valFS:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
        valFS:SetText(tostring(LLF.db.iconBorderThickness or 2))

        local minusBtn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        minusBtn:SetSize(18, ROW_H - 4)
        minusBtn:SetPoint("TOPRIGHT", valFS, "TOPLEFT", 0, -2)
        minusBtn:SetBackdrop(FLAT_BD)
        minusBtn:SetBackdropColor(0.08, 0.08, 0.11, 1)
        minusBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
        local minusFS = minusBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        minusFS:SetAllPoints(); minusFS:SetJustifyH("CENTER")
        minusFS:SetText("-"); minusFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

        local function SetThick(v)
            v = math.max(1, math.min(6, v))
            LLF.db.iconBorderThickness = v
            valFS:SetText(tostring(v))
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end
        minusBtn:SetScript("OnClick", function() SetThick((LLF.db.iconBorderThickness or 2) - 1) end)
        plusBtn:SetScript("OnClick",  function() SetThick((LLF.db.iconBorderThickness or 2) + 1) end)

        local function SyncBorderDisabled()
            local on = LLF.db.showIconBorder == true
            local a = on and 1 or 0.30
            minusBtn:SetAlpha(a); minusBtn:EnableMouse(on)
            plusBtn:SetAlpha(a);  plusBtn:EnableMouse(on)
            valFS:SetAlpha(a)
        end
        SyncBorderDisabled()
        local sentinel = {}
        sentinel.Sync = function(_self)
            SyncBorderDisabled()
            valFS:SetText(tostring(LLF.db.iconBorderThickness or 2))
        end
        allToggles[#allToggles + 1] = borderToggle
        allToggles[#allToggles + 1] = sentinel
        p.SetY(y0 - ROW_H - p.SEP)
    end
    p.Sep(4)
    p.SlideInput("Max name length", 10, 60, 1,
        function() return LLF.db.maxNameLength or 32 end,
        function(v)
            LLF.db.maxNameLength = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    p.Finalize()
end

local function PageLayout(parent, CW)
    local p = MakePage(parent, CW)

    p.Header("Growth Direction")
    p.Sep(2)
    p.Label("New entries appear:")
    local y0 = p.GetY()
    local btnDown, btnUp = MakeRadio(parent,
        "At top  (grows downward)",
        "At bottom  (grows upward)",
        function() return LLF.db.feedGrowUp ~= true end,
        function() LLF.Feed:SetGrowDirection(false) end,
        function() LLF.Feed:SetGrowDirection(true) end)
    btnDown:SetPoint("TOPLEFT", parent, p.PAD,              y0); btnDown:SetWidth(p.HALF)
    btnUp:SetPoint(  "TOPLEFT", parent, p.PAD + p.HALF + 8, y0); btnUp:SetWidth(p.HALF)
    p.SetY(y0 - ROW_H - SEP)

    p.Header("Dimensions")
    p.SlideInputL("Feed width", 160, 600, 10,
        function() return LLF.db.feedWidth or 280 end,
        function(v) LLF.db.feedWidth = v; LLF.Feed:RefreshRows(); LLF.Feed:ApplyFont(); LLF.Feed:RefreshTestRows() end)
    p.SlideInputR("Row height", 20, 70, 2,
        function() return LLF.db.feedRowHeight or 28 end,
        function(v) LLF.db.feedRowHeight = v; LLF.Feed:RefreshRows(); LLF.Feed:ApplyFont(); LLF.Feed:RefreshTestRows() end)
    p.SlideInputL("Row spacing", 0, 16, 1,
        function() return LLF.db.feedSpacing or 3 end,
        function(v) LLF.db.feedSpacing = v; LLF.Feed:RefreshRows(); LLF.Feed:ApplyFont(); LLF.Feed:RefreshTestRows() end)
    p.SlideInputR("Max rows visible", 1, 20, 1,
        function() return LLF.db.feedMaxRows or 10 end,
        function(v) LLF.db.feedMaxRows = v; LLF.Feed:RefreshRows(); LLF.Feed:ApplyFont() end)

    p.Header("Stack Count Position")
    p.Picker("", 22,
        function() return LLF.db.countCorner or "BOTTOMRIGHT" end,
        function(v)
            LLF.db.countCorner = v
            LLF.Feed:ApplyFont()
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end,
        function()
            return {
                { value="TOPLEFT",     display="Top Left"     },
                { value="TOPRIGHT",    display="Top Right"    },
                { value="BOTTOMLEFT",  display="Bottom Left"  },
                { value="BOTTOMRIGHT", display="Bottom Right" },
            }
        end)

    p.Header("Opacity")
    p.SlideInputL("Feed opacity", 0, 100, 5,
        function() return math.floor((LLF.db.feedAlpha or 1.0) * 100 + 0.5) end,
        function(v) LLF.db.feedAlpha = v / 100; LLF.Feed:ApplyLayout() end)
    p.SlideInputR("Frame background", 0, 100, 5,
        function() return math.floor((LLF.db.feedBgAlpha or 0.85) * 100 + 0.5) end,
        function(v) LLF.db.feedBgAlpha = v / 100; LLF.Feed:ApplyLayout() end)
    p.SlideInputL("Row background", 0, 100, 5,
        function() return math.floor(((LLF.db.rowBgAlpha ~= nil) and LLF.db.rowBgAlpha or 0.80) * 100 + 0.5) end,
        function(v) LLF.db.rowBgAlpha = v / 100; LLF.Feed:ApplyRowStyles(); LLF.Feed:RefreshTestRows() end)
    p.SlideInputR("Fade-out time", 0.1, 3.0, 0.1,
        function() return LLF.db.fadeOutTime or 0.5 end,
        function(v) LLF.db.fadeOutTime = v end)

    p.Header("Position")
    p.Row("Lock position",
        function() return LLF.db.feedLocked end,
        function(v) LLF.db.feedLocked = v end)
    p.Sep(4)

    local y1 = p.GetY()
    local testBtn = MakeBtn(parent, "Test Rows", 110, ROW_H)
    testBtn:SetPoint("TOPLEFT", parent, p.PAD, y1)
    testBtn:SetScript("OnClick", function() LLF.Feed:Preview() end)
    local clearBtn = MakeBtn(parent, "Clear Test", 100, ROW_H)
    clearBtn:SetPoint("LEFT", testBtn, "RIGHT", 6, 0)
    clearBtn:SetScript("OnClick", function()
        LLF.Feed.testLocked = false
        LLF.Feed:ClearAll()
        if lockTestBtn then
            lockTestBtn._fs:SetText("Lock Test")
            lockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
            lockTestBtn:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        end
    end)

    local lockTestBtn = MakeBtn(parent, "Lock Test", 90, ROW_H)
    lockTestBtn:SetPoint("LEFT", clearBtn, "RIGHT", 6, 0)
    local function SyncLockBtn()
        if LLF.Feed.testLocked then
            lockTestBtn._fs:SetText("Unlock Test")
            lockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            lockTestBtn:SetBackdropColor(ACCENT[1]*0.18, ACCENT[2]*0.18, ACCENT[3]*0.18, 1)
        else
            lockTestBtn._fs:SetText("Lock Test")
            lockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
            lockTestBtn:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        end
    end
    lockTestBtn:SetScript("OnClick", function()
        LLF.Feed.testLocked = not LLF.Feed.testLocked
        if LLF.Feed.testLocked then
            LLF.Feed:Preview()
        else
            local now = GetTime()
            for _, r in ipairs(LLF.Feed._rows or {}) do
                if r.entry and r.entry.isPreview then
                    local rar = r.entry.rarity or 1
                    local dur
                    if r.entry.source == 1 then
                        dur = LLF.Config:GetDuration("gold")
                    else
                        dur = LLF.Config:GetDuration(rar)
                    end
                    if not dur or dur <= 0 then dur = 5 end
                    r.expiresAt = now + dur
                    r.fadeStart = nil
                    r.rowFrame:SetAlpha(1)
                end
            end
        end
        SyncLockBtn()
    end)
    SyncLockBtn()
    p.SetY(y1 - ROW_H - SEP)

    p.Header("Indicators")
    p.RowL("Show upgrade indicator",
        function() return LLF.db.showUpgradeIndicator ~= false end,
        function(v)
            LLF.db.showUpgradeIndicator = v
            LLF.Feed:ApplyFont()
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    p.RowR("Show transmog indicator",
        function() return LLF.db.showTransmogIndicator ~= false end,
        function(v)
            LLF.db.showTransmogIndicator = v
            LLF.Feed:ApplyFont()
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)
    p.Row("Show upgrade track icon",
        function() return LLF.db.showUpgradeTrack ~= false end,
        function(v)
            LLF.db.showUpgradeTrack = v
            LLF.Feed:ApplyFont()
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)

    p.Header("Offer in Group")
    local offerToggle = p.Row("Show offer button when in a group",
        function() return LLF.db.offerEnabled ~= false end,
        function(v)
            LLF.db.offerEnabled = v
            LLF.Feed:ApplyFont()
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)

    p.Picker("Min rarity to show button", 24,
        function() return LLF.db.offerMinRarity or 2 end,
        function(v) LLF.db.offerMinRarity = v; LLF.Feed:ApplyFont(); LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end,
        function()
            return {
                { value=0, display="All items" },
                { value=2, display="|cff1eff00Uncommon|r|cffffffff and above|r" },
                { value=3, display="|cff0070ddRare|r|cffffffff and above|r" },
                { value=4, display="|cffa335eeEpic|r|cffffffff and above|r" },
                { value=5, display="|cffff8000Legendary|r|cffffffff only|r" },
            }
        end)

    p.Sep(18)  -- space for hint label above editbox
    local y2 = p.GetY()
    local oCont = CreateFrame("Frame", N("OF_EC"), parent, "BackdropTemplate")
    oCont:SetHeight(26)
    oCont:SetPoint("TOPLEFT",  parent, p.PAD,  y2)
    oCont:SetPoint("TOPRIGHT", parent, -p.PAD, y2)
    oCont:SetBackdrop(FLAT_BD)

    local function UpdateOfferContColors()
        local on = LLF.db.offerEnabled ~= false
        oCont:SetBackdropColor(on and 0.08 or 0.05, on and 0.08 or 0.05, on and 0.11 or 0.08, 1)
        oCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], on and 0.45 or 0.15)
    end
    UpdateOfferContColors()

    local offerHintFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    offerHintFS:SetPoint("BOTTOMLEFT", oCont, "TOPLEFT", 0, 2)
    offerHintFS:SetTextColor(0.55, 0.55, 0.60, 1)
    offerHintFS:SetText("{item} = item link")

    local offerEB = CreateFrame("EditBox", N("OF_EB"), oCont)
    offerEB:SetPoint("TOPLEFT",     oCont, 6,  -4)
    offerEB:SetPoint("BOTTOMRIGHT", oCont, -6,  4)
    offerEB:SetAutoFocus(false)
    offerEB:SetMaxLetters(200)
    offerEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    offerEB:SetText(LLF.db and LLF.db.offerMessage or "Anyone want my {item}?")

    local function SetOfferFont()
        local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
        local fp2
        local chosen = LLF.db and LLF.db.feedFont
        if chosen and chosen ~= "" and lsm then fp2 = lsm:Fetch("font", chosen) end
        if not fp2 and lsm then fp2 = lsm:Fetch("font", "Friz Quadrata TT") end
        if not fp2 then fp2 = "Fonts\\FRIZQT__.TTF" end
        offerEB:SetFont(fp2, 11, "")
    end
    SetOfferFont()

    offerEB:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if val == "" then val = "Anyone want my {item}?" end
        LLF.db.offerMessage = val
        self:ClearFocus()
    end)
    offerEB:SetScript("OnEscapePressed", function(self)
        self:SetText(LLF.db and LLF.db.offerMessage or "Anyone want my {item}?")
        self:ClearFocus()
    end)
    offerEB:SetScript("OnEditFocusGained", function(self)
        if LLF.db.offerEnabled == false then self:ClearFocus() end
    end)
    offerEB:SetScript("OnEditFocusLost", function(self)
        local val = self:GetText()
        if val == "" then val = "Anyone want my {item}?" end
        LLF.db.offerMessage = val
    end)
    offerEB:SetScript("OnEnter", function()
        if LLF.db.offerEnabled ~= false then
            oCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
        end
    end)
    offerEB:SetScript("OnLeave", function() UpdateOfferContColors() end)

    oCont._refresh = function()
        offerEB:SetText(LLF.db and LLF.db.offerMessage or "Anyone want my {item}?")
        SetOfferFont()
        UpdateOfferContColors()
        if LLF.db.offerEnabled == false and offerEB:HasFocus() then offerEB:ClearFocus() end
    end
    allSliders[#allSliders + 1] = oCont

    p.SetY(y2 - 26 - SEP)

    local offerResetBtn = MakeBtn(parent, "Reset Message", 120, ROW_H)
    offerResetBtn:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    offerResetBtn:SetScript("OnClick", function()
        LLF.db.offerMessage = "Anyone want my {item}?"
        offerEB:SetText(LLF.db.offerMessage)
    end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Finalize()
end

local function PageDurations(parent, CW)
    local p = MakePage(parent, CW)

    local RAR = {
        { 0, "|cff9d9d9dPoor|r" },               { 1, "|cffffffffCommon|r"         },
        { 2, "|cff1eff00Uncommon|r" },            { 3, "|cff0070ddRare|r"           },
        { 4, "|cffa335eeEpic|r" },                { 5, "|cffff8000Legendary|r"      },
        { 6, "|cffe6cc80Currency|r" },            { 7, "|cff00ccffQuest / Heirloom|r" },
    }

    p.Header("Personal Loot - Display Duration")
    for i = 1, #RAR, 2 do
        local L, R = RAR[i], RAR[i + 1]
        p.SlideInputL(L[2], 0, 60, 0.5,
            function() return LLF.db.durations[L[1]] or 0 end,
            function(v) LLF.db.durations[L[1]] = v end, " sec")
        if R then
            p.SlideInputR(R[2], 0, 60, 0.5,
                function() return LLF.db.durations[R[1]] or 0 end,
                function(v) LLF.db.durations[R[1]] = v end, " sec")
        else
            p.SetY(p.GetY() - 44 - SEP)
        end
    end
    p.SlideInputL("|cffffff00Gold|r", 0, 60, 0.5,
        function() return LLF.db.durations.gold or 5 end,
        function(v) LLF.db.durations.gold = v end, " sec")
    p.SlideInputR("|cffcc2222Honor|r", 0, 60, 0.5,
        function() return LLF.db.durations[8] or 5 end,
        function(v) LLF.db.durations[8] = v end, " sec")
    p.SlideInputL("|cff00ccffReputation|r", 0, 60, 0.5,
        function() return LLF.db.durations.rep or 5 end,
        function(v) LLF.db.durations.rep = v end, " sec")
    p.SetY(p.GetY() - 44 - SEP)

    p.Sep(12)

    p.Header("Group Loot - Display Duration")
    for i = 1, #RAR, 2 do
        local L, R = RAR[i], RAR[i + 1]
        p.SlideInputL(L[2], 0, 60, 0.5,
            function() return LLF.db.groupDurations[L[1]] or 0 end,
            function(v) LLF.db.groupDurations[L[1]] = v end, " sec")
        if R then
            p.SlideInputR(R[2], 0, 60, 0.5,
                function() return LLF.db.groupDurations[R[1]] or 0 end,
                function(v) LLF.db.groupDurations[R[1]] = v end, " sec")
        else
            p.SetY(p.GetY() - 44 - SEP)
        end
    end
    p.SlideInputL("|cffffff00Gold|r", 0, 60, 0.5,
        function() return LLF.db.groupDurations.gold or 5 end,
        function(v) LLF.db.groupDurations.gold = v end, " sec")
    p.SlideInputR("|cffcc2222Honor|r", 0, 60, 0.5,
        function() return LLF.db.groupDurations[8] or 5 end,
        function(v) LLF.db.groupDurations[8] = v end, " sec")
    p.SetY(p.GetY() - 44 - SEP)

    p.Finalize()
end

local function PagePrice(parent, CW)
    local p = MakePage(parent, CW)

    p.Header("Display")
    local function RefreshTest() LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end
    p.RowL("Show vendor sell price",
        function() return LLF.db.showVendorPrice end,
        function(v) LLF.db.showVendorPrice = v; RefreshTest() end)
    p.RowR("Show stack total price",
        function() return LLF.db.showStackPrice end,
        function(v) LLF.db.showStackPrice = v; RefreshTest() end)
    p.RowL("Show AH price",
        function() return LLF.db.showAHPrice end,
        function(v) LLF.db.showAHPrice = v; RefreshTest() end)
    p.RowR("Show AH price for Poor items",
        function() return LLF.db.showJunkAH end,
        function(v) LLF.db.showJunkAH = v; RefreshTest() end)

    p.Header("Price Format")
    p.Picker("", 24,
        function() return LLF.db.priceFormat or 1 end,
        function(v)
            LLF.db.priceFormat = v
            RefreshTest()
        end,
        function()
            return {
                { value = 1, display = "Full  (1250g 34s 00c)" },
                { value = 2, display = "Gold only  (1250g)" },
                { value = 3, display = "Short  (1.3k  /  2.5M)" },
                { value = 4, display = "Short + g  (1.3kg  /  2.5Mg)" },
            }
        end)

    p.Header("AH Price Source")
    do
        local hasAuc = IsAddonLoaded("Auctionator")
        local hasTSM = IsAddonLoaded("TradeSkillMaster") or IsAddonLoaded("TradeSkillMaster4")
        local noneFound = not hasAuc and not hasTSM

        if noneFound then
            p.Label("|cffff6633No AH addon detected  (Auctionator or TSM required)|r")
        else
            p.Label("|cffaaaaaaAuto-detected on first load. Change anytime.|r")
        end

        local y0 = p.GetY()
        local tAuc = MakeToggle(parent, "Auctionator",
            function() return (LLF.db.auctionAddon or 1) == 1 end,
            function(v) if v then LLF.db.auctionAddon = 1 end end)
        tAuc:SetPoint("TOPLEFT", parent, p.PAD,              y0); tAuc:SetWidth(p.HALF)

        local tTSM = MakeToggle(parent, "TradeSkillMaster  (TSM)",
            function() return (LLF.db.auctionAddon or 1) == 2 end,
            function(v) if v then LLF.db.auctionAddon = 2 end end)
        tTSM:SetPoint("TOPLEFT", parent, p.PAD + p.HALF + 8, y0); tTSM:SetWidth(p.HALF)
        p.SetY(y0 - ROW_H - SEP)

        tAuc:SetAlpha(hasAuc and 1 or 0.30); tAuc:EnableMouse(hasAuc)
        tTSM:SetAlpha(hasTSM and 1 or 0.30); tTSM:EnableMouse(hasTSM)

        allToggles[#allToggles + 1] = tAuc
        allToggles[#allToggles + 1] = tTSM
    end

    p.Header("TSM Price Value")
    do
        local isTSM = function() return (LLF.db.auctionAddon or 1) == 2 end

        local y0 = p.GetY()
        local tA = MakeToggle(parent, "Market value  (dbmarket)",
            function() return (LLF.db.tsmSource or 1) == 1 end,
            function(v) if v and isTSM() then LLF.db.tsmSource = 1 end end)
        tA:SetPoint("TOPLEFT",  parent, p.PAD,              y0); tA:SetWidth(p.HALF)

        local tB = MakeToggle(parent, "Min buyout  (dbminbuyout)",
            function() return (LLF.db.tsmSource or 1) == 2 end,
            function(v) if v and isTSM() then LLF.db.tsmSource = 2 end end)
        tB:SetPoint("TOPLEFT",  parent, p.PAD + p.HALF + 8, y0); tB:SetWidth(p.HALF)
        p.SetY(y0 - ROW_H - SEP)

        local function SyncDisabled()
            local disabled = not isTSM()
            tA:SetAlpha(disabled and 0.30 or 1); tA:EnableMouse(not disabled)
            tB:SetAlpha(disabled and 0.30 or 1); tB:EnableMouse(not disabled)
        end
        SyncDisabled()

        local sentinel = {}
        sentinel.Sync = function(_self) SyncDisabled() end
        allToggles[#allToggles + 1] = sentinel
    end

    p.Header("Row Highlight")
    local glowToggle = p.Row("Enable value-based row glow",
        function() return LLF.db.glowEnabled end,
        function(v) LLF.db.glowEnabled = v; LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end)

    local glowModePicker = p.Picker("Glow target", 40,
        function() return LLF.db.glowMode or 1 end,
        function(v)
            LLF.db.glowMode = v
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end,
        function()
            return {
                { value = 1, display = "Full bar" },
                { value = 2, display = "Icon only" },
            }
        end)

    local function RefreshTest() LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end

    local ApplyGlowGating
    local glowTypePicker = p.Picker("Glow style", 40,
        function() return LLF.db.glowType or 1 end,
        function(v) LLF.db.glowType = v; if ApplyGlowGating then ApplyGlowGating() end; RefreshTest() end,
        function()
            return {
                { value = 1, display = "Pixel" },
                { value = 2, display = "AutoCast" },
                { value = 3, display = "Blizzard" },
            }
        end)

    local glowLinesSlider = p.SlideInput("Lines / particles", 1, 30, 1,
        function() return LLF.db.glowLines or 12 end,
        function(v) LLF.db.glowLines = v; RefreshTest() end)
    local glowSpeedSlider = p.SlideInput("Speed", 0.05, 1.0, 0.05,
        function() return LLF.db.glowSpeed or 0.35 end,
        function(v) LLF.db.glowSpeed = v; RefreshTest() end)
    local glowThickSlider = p.SlideInput("Thickness", 1, 6, 1,
        function() return LLF.db.glowThickness or 2 end,
        function(v) LLF.db.glowThickness = v; RefreshTest() end)

    p.Sep(4)
    p.Label("Glow Tiers", ACCENT)

    local TIER_H = 30
    local tierHost = CreateFrame("Frame", N("GTH"), parent)
    tierHost:SetPoint("TOPLEFT",  parent, p.PAD,  p.GetY())
    tierHost:SetPoint("TOPRIGHT", parent, -p.PAD, p.GetY())
    tierHost:SetHeight(1)

    local tierRows = {}
    local RebuildTierList
    local tierListY

    local function SortTiers()
        local tiers = LLF.db.glowTiers
        if tiers then
            table.sort(tiers, function(a, b) return (a.threshold or 0) < (b.threshold or 0) end)
        end
    end

    local function OpenColorPicker(idx)
        local tier = LLF.db.glowTiers[idx]
        if not tier then return end
        local c = tier.color or { 1, 1, 1 }
        local info = {
            r = c[1], g = c[2], b = c[3],
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                tier.color = { r, g, b }
                RebuildTierList()
                RefreshTest()
            end,
            cancelFunc = function(prev)
                tier.color = { prev.r, prev.g, prev.b }
                RebuildTierList()
                RefreshTest()
            end,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end

    RebuildTierList = function()
        for _, row in ipairs(tierRows) do row:Hide() end
        wipe(tierRows)

        local tiers = LLF.db.glowTiers or {}
        SortTiers()
        local yOff = 0
        for i, tier in ipairs(tiers) do
            local row = CreateFrame("Frame", N("GTR"), tierHost, "BackdropTemplate")
            row:SetHeight(TIER_H)
            row:SetPoint("TOPLEFT",  tierHost, 0,  yOff)
            row:SetPoint("TOPRIGHT", tierHost, 0,  yOff)
            row:SetBackdrop(FLAT_BD)
            row:SetBackdropColor(0.06, 0.06, 0.09, 1)
            row:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

            local swatch = CreateFrame("Button", N("GTS"), row, "BackdropTemplate")
            swatch:SetSize(22, 22)
            swatch:SetPoint("LEFT", row, 6, 0)
            swatch:SetBackdrop(FLAT_BD)
            local c = tier.color or { 1, 1, 1 }
            swatch:SetBackdropColor(c[1], c[2], c[3], 1)
            swatch:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
            local idx = i
            swatch:SetScript("OnClick", function() OpenColorPicker(idx) end)
            swatch:SetScript("OnEnter", function(s) s:SetBackdropBorderColor(1, 1, 1, 1) end)
            swatch:SetScript("OnLeave", function(s) s:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8) end)

            local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lbl:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
            lbl:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 0.80)
            lbl:SetText("Min gold:")

            local eb = CreateFrame("EditBox", N("GTE"), row, "BackdropTemplate")
            eb:SetSize(80, 20)
            eb:SetPoint("LEFT", lbl, "RIGHT", 6, 0)
            eb:SetAutoFocus(false)
            eb:SetFontObject("GameFontNormal")
            eb:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            eb:SetMaxLetters(10)
            eb:SetNumeric(true)
            eb:SetBackdrop(FLAT_BD)
            eb:SetBackdropColor(0.08, 0.08, 0.11, 1)
            eb:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
            eb:SetText(tostring(math.floor(tier.threshold or 0)))
            eb:SetScript("OnEnterPressed", function(self)
                local val = tonumber(self:GetText()) or 0
                tier.threshold = val
                SortTiers()
                RebuildTierList()
                RefreshTest()
                self:ClearFocus()
            end)
            eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            local remBtn = MakeBtn(row, "×", 22, 22)
            remBtn:SetPoint("RIGHT", row, -6, 0)
            remBtn:SetScript("OnClick", function()
                table.remove(LLF.db.glowTiers, idx)
                RebuildTierList()
                RefreshTest()
            end)

            tierRows[#tierRows + 1] = row
            yOff = yOff - TIER_H - 2
        end

        local addBtn = MakeBtn(tierHost, "+ Add Tier", 100, TIER_H - 4)
        addBtn:SetPoint("TOPLEFT", tierHost, 0, yOff - 4)
        tierRows[#tierRows + 1] = addBtn
        addBtn:SetScript("OnClick", function()
            local tiers2 = LLF.db.glowTiers
            tiers2[#tiers2 + 1] = { threshold = 0, color = { 1, 1, 1 } }
            SortTiers()
            RebuildTierList()
            RefreshTest()
        end)

        local totalH = math.abs(yOff) + TIER_H + 8
        tierHost:SetHeight(totalH)
        p.SetY(tierListY - totalH)
        parent:SetHeight(math.abs(p.GetY()) + 16)
        if parent:GetParent() then
            parent:GetParent():SetHeight(parent:GetHeight())
        end
    end

    tierListY = p.GetY()
    RebuildTierList()
    LLF.Options._rebuildGlowTiers = RebuildTierList

    local glowGatedControls = { glowModePicker, glowTypePicker }

    ApplyGlowGating = function()
        local on = LLF.db.glowEnabled == true
        local gt = LLF.db.glowType or 1
                local linesOK = on and (gt ~= 3)
        local speedOK = on
        local thickOK = on and (gt ~= 3)
        for _, ctrl in ipairs(glowGatedControls) do
            if ctrl then ctrl:SetAlpha(on and 1 or 0.35); ctrl:EnableMouse(on) end
        end
        GateSlider(glowLinesSlider, linesOK)
        GateSlider(glowSpeedSlider, speedOK)
        GateSlider(glowThickSlider, thickOK)
        tierHost:SetAlpha(on and 1 or 0.35)
        tierHost:EnableMouse(on)
    end
    ApplyGlowGating()

    if glowToggle then
        local origSync = glowToggle.Sync
        glowToggle.Sync = function(self)
            if origSync then origSync(self) end
            ApplyGlowGating()
        end
    end

    for _, sc in ipairs({ glowLinesSlider, glowSpeedSlider, glowThickSlider }) do
        if sc._eb then
            sc._eb:HookScript("OnEditFocusGained", function(self)
                if not LLF.db.glowEnabled then self:ClearFocus() end
            end)
        end
    end

    p.Finalize()
end

local function PageFilters(parent, CW)
    local p = MakePage(parent, CW)

    local RFILT = {
        { 0, "|cff9d9d9dPoor|r" },               { 1, "|cffffffffCommon|r"           },
        { 2, "|cff1eff00Uncommon|r" },            { 3, "|cff0070ddRare|r"             },
        { 4, "|cffa335eeEpic|r" },                { 5, "|cffff8000Legendary|r"        },
        { 6, "|cffe6cc80Currency|r" },            { 7, "|cff00ccffQuest / Heirloom|r" },
    }

    p.Header("|cff55ff55Personal Loot|r - Rarity")
    for i = 1, #RFILT, 2 do
        local L, R = RFILT[i], RFILT[i + 1]
        p.RowL(L[2],
            function() return LLF.db.personalFilters.filterRarity[L[1]] ~= false end,
            function(v) LLF.db.personalFilters.filterRarity[L[1]] = v end)
        if R then
            p.RowR(R[2],
                function() return LLF.db.personalFilters.filterRarity[R[1]] ~= false end,
                function(v) LLF.db.personalFilters.filterRarity[R[1]] = v end)
        else
            p.SetY(p.GetY() - ROW_H - SEP)
        end
    end
    p.RowL("|cffcc2222Honor|r",
        function() return LLF.db.personalFilters.filterRarity[8] ~= false end,
        function(v) LLF.db.personalFilters.filterRarity[8] = v end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Header("|cff55ff55Personal Loot|r - Reputation")
    p.RowL("Show reputation gains",
        function() return LLF.db.personalFilters.filterRep ~= false end,
        function(v)
            LLF.db.personalFilters.filterRep = v
            local ef = _G["LarlenLootFrameEventFrame"]
            if ef then
                if v then ef:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
                else ef:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE") end
            end
        end)
    p.RowR("Show guild reputation",
        function() return LLF.db.personalFilters.filterGuildRep ~= false end,
        function(v) LLF.db.personalFilters.filterGuildRep = v end)

    p.Header("|cff55ff55Personal Loot|r - Item Types")
    p.RowL("|cff44ddffPets|r",
        function() return LLF.db.personalFilters.filterPets ~= false end,
        function(v) LLF.db.personalFilters.filterPets = v end)
    p.RowR("|cff44ddffMounts|r",
        function() return LLF.db.personalFilters.filterMounts ~= false end,
        function(v) LLF.db.personalFilters.filterMounts = v end)
    p.RowL("|cffcc8844Housing Decor|r",
        function() return LLF.db.personalFilters.filterHousing ~= false end,
        function(v) LLF.db.personalFilters.filterHousing = v end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Sep(20)

    p.Header("|cff55bbffGroup Loot|r - Rarity")
    for i = 1, #RFILT, 2 do
        local L, R = RFILT[i], RFILT[i + 1]
        p.RowL(L[2],
            function() return LLF.db.groupFilters.filterRarity[L[1]] ~= false end,
            function(v) LLF.db.groupFilters.filterRarity[L[1]] = v end)
        if R then
            p.RowR(R[2],
                function() return LLF.db.groupFilters.filterRarity[R[1]] ~= false end,
                function(v) LLF.db.groupFilters.filterRarity[R[1]] = v end)
        else
            p.SetY(p.GetY() - ROW_H - SEP)
        end
    end
    p.RowL("|cffcc2222Honor|r",
        function() return LLF.db.groupFilters.filterRarity[8] ~= false end,
        function(v) LLF.db.groupFilters.filterRarity[8] = v end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Finalize()
end

local function PagePartyFeed(parent, CW)
    local p = MakePage(parent, CW)

    local function pdf() return LLF.db.partyFeed end

    p.Header("Group Loot Feed")
    p.Row("Enable party loot feed",
        function() return pdf().enabled end,
        function(v) pdf().enabled = v
            if not v then LLF.PartyFeed:ClearAll() else LLF.PartyFeed:Refresh() end
        end)
    p.RowL("Show party loot",
        function() return pdf().showParty end,
        function(v) pdf().showParty = v end)
    p.RowR("Show raid loot",
        function() return pdf().showRaid end,
        function(v) pdf().showRaid = v end)

    p.Header("Minimum Rarity to Show")
    p.Picker("", 24,
        function() return pdf().filterMinRarity or 0 end,
        function(v) pdf().filterMinRarity = v end,
        function()
            return {
                { value = 0, display = "All items"                                          },
                { value = 2, display = "|cff1eff00Uncommon|r|cffffffff and above|r"        },
                { value = 3, display = "|cff0070ddRare|r|cffffffff and above|r"            },
                { value = 4, display = "|cffa335eeEpic|r|cffffffff and above|r"            },
                { value = 5, display = "|cffff8000Legendary|r|cffffffff only|r"            },
            }
        end)

    p.Header("Item Types")
    p.RowL("|cff44ddffPets|r",
        function() return pdf().filterPets ~= false end,
        function(v) pdf().filterPets = v end)
    p.RowR("|cff44ddffMounts|r",
        function() return pdf().filterMounts ~= false end,
        function(v) pdf().filterMounts = v end)

    p.Header("Growth Direction")
    p.Sep(2)
    p.Label("New entries appear:")
    local y0 = p.GetY()
    local btnDown, btnUp = MakeRadio(parent,
        "At top  (grows downward)",
        "At bottom  (grows upward)",
        function() return pdf().feedGrowUp ~= true end,
        function() LLF.PartyFeed:SetGrowDirection(false) end,
        function() LLF.PartyFeed:SetGrowDirection(true) end)
    btnDown:SetPoint("TOPLEFT", parent, p.PAD,              y0); btnDown:SetWidth(p.HALF)
    btnUp:SetPoint(  "TOPLEFT", parent, p.PAD + p.HALF + 8, y0); btnUp:SetWidth(p.HALF)
    p.SetY(y0 - ROW_H - SEP)

    p.Header("Dimensions")
    p.SlideInputL("Feed width", 160, 600, 10,
        function() return pdf().feedWidth or 280 end,
        function(v) pdf().feedWidth = v; LLF.PartyFeed:RefreshRows(); LLF.PartyFeed:ApplyFont(); LLF.PartyFeed:RefreshTestRows() end)
    p.SlideInputR("Row height", 20, 70, 2,
        function() return pdf().feedRowHeight or 46 end,
        function(v) pdf().feedRowHeight = v; LLF.PartyFeed:RefreshRows(); LLF.PartyFeed:ApplyFont(); LLF.PartyFeed:RefreshTestRows() end)
    p.SlideInputL("Row spacing", 0, 16, 1,
        function() return pdf().feedSpacing or 4 end,
        function(v) pdf().feedSpacing = v; LLF.PartyFeed:RefreshRows(); LLF.PartyFeed:ApplyFont(); LLF.PartyFeed:RefreshTestRows() end)
    p.SlideInputR("Max rows visible", 1, 20, 1,
        function() return pdf().feedMaxRows or 8 end,
        function(v) pdf().feedMaxRows = v; LLF.PartyFeed:RefreshRows(); LLF.PartyFeed:ApplyFont(); LLF.PartyFeed:RefreshTestRows() end)

    p.Header("Opacity")
    p.SlideInputL("Feed opacity", 0, 100, 5,
        function() return math.floor((pdf().feedAlpha or 1.0) * 100 + 0.5) end,
        function(v) pdf().feedAlpha = v / 100; LLF.PartyFeed:ApplyLayout() end)
    p.SlideInputR("Frame background", 0, 100, 5,
        function() return math.floor((pdf().feedBgAlpha or 0.85) * 100 + 0.5) end,
        function(v) pdf().feedBgAlpha = v / 100; LLF.PartyFeed:ApplyLayout() end)
    p.SlideInputL("Row background", 0, 100, 5,
        function() return math.floor(((pdf().rowBgAlpha ~= nil) and pdf().rowBgAlpha or 0.80) * 100 + 0.5) end,
        function(v) pdf().rowBgAlpha = v / 100; LLF.PartyFeed:ApplyRowStyles(); LLF.PartyFeed:RefreshTestRows() end)
    p.SlideInputR("Fade-out time", 0.1, 3.0, 0.1,
        function() return pdf().fadeOutTime or 0.5 end,
        function(v) pdf().fadeOutTime = v end)

    p.Header("Position")
    p.Row("Lock position",
        function() return pdf().feedLocked end,
        function(v) pdf().feedLocked = v end)
    p.Sep(4)

    local y1 = p.GetY()
    local testBtn = MakeBtn(parent, "Test Rows", 110, ROW_H)
    testBtn:SetPoint("TOPLEFT", parent, p.PAD, y1)
    testBtn:SetScript("OnClick", function() LLF.PartyFeed:Preview() end)
    local clearBtn = MakeBtn(parent, "Clear Test", 100, ROW_H)
    clearBtn:SetPoint("LEFT", testBtn, "RIGHT", 6, 0)
    clearBtn:SetScript("OnClick", function()
        LLF.PartyFeed.testLocked = false
        LLF.PartyFeed:ClearAll()
        if pLockTestBtn then
            pLockTestBtn._fs:SetText("Lock Test")
            pLockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
            pLockTestBtn:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        end
    end)

    local pLockTestBtn = MakeBtn(parent, "Lock Test", 90, ROW_H)
    pLockTestBtn:SetPoint("LEFT", clearBtn, "RIGHT", 6, 0)
    local function SyncPLockBtn()
        if LLF.PartyFeed.testLocked then
            pLockTestBtn._fs:SetText("Unlock Test")
            pLockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            pLockTestBtn:SetBackdropColor(ACCENT[1]*0.18, ACCENT[2]*0.18, ACCENT[3]*0.18, 1)
        else
            pLockTestBtn._fs:SetText("Lock Test")
            pLockTestBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
            pLockTestBtn:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        end
    end
    SyncPLockBtn()
    pLockTestBtn:SetScript("OnClick", function()
        LLF.PartyFeed.testLocked = not LLF.PartyFeed.testLocked
        if LLF.PartyFeed.testLocked then
            LLF.PartyFeed:Preview()
        end
        SyncPLockBtn()
    end)

    local copyBtn = MakeBtn(parent, "Copy Personal Layout", 170, ROW_H)
    copyBtn:SetPoint("LEFT", pLockTestBtn, "RIGHT", 6, 0)
    copyBtn:SetScript("OnClick", function()
        local db  = LLF.db
        local pdf = db.partyFeed
        pdf.feedWidth     = db.feedWidth
        pdf.feedRowHeight = db.feedRowHeight
        pdf.feedSpacing   = db.feedSpacing
        pdf.feedMaxRows   = db.feedMaxRows
        pdf.feedGrowUp    = db.feedGrowUp
        pdf.feedAlpha     = db.feedAlpha
        pdf.feedBgAlpha   = db.feedBgAlpha
        pdf.rowBgAlpha    = db.rowBgAlpha
        pdf.fadeOutTime   = db.fadeOutTime
        LLF.PartyFeed:Refresh()
        LLF.PartyFeed:ApplyLayout()
        RefreshAll()
    end)
    p.SetY(y1 - ROW_H - SEP)

    p.Header("Indicators")
    p.RowL("Show upgrade indicator",
        function() return LLF.db.showUpgradeParty == true end,
        function(v)
            LLF.db.showUpgradeParty = v
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.PartyFeed:RefreshTestRows()
        end)
    p.RowR("Show transmog indicator",
        function() return LLF.db.showTransmogParty == true end,
        function(v)
            LLF.db.showTransmogParty = v
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.PartyFeed:RefreshTestRows()
        end)

    p.Header("Need?")
    local whisperToggle = p.Row("Show message buttons for items others may need",
        function() return LLF.db.showWhisperButtons ~= false end,
        function(v)
            LLF.db.showWhisperButtons = v
            if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
            LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows()
        end)

    p.Sep(2)
    p.Sep(18)  -- space for hint label above editbox
    local y0 = p.GetY()
    local cont = CreateFrame("Frame", N("NB_EC"), parent, "BackdropTemplate")
    cont:SetHeight(26)
    cont:SetPoint("TOPLEFT",  parent, p.PAD,  y0)
    cont:SetPoint("TOPRIGHT", parent, -p.PAD, y0)
    cont:SetBackdrop(FLAT_BD)

    local hintFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hintFS:SetPoint("BOTTOMLEFT",  cont, "TOPLEFT",  0,  2)
    hintFS:SetTextColor(0.55, 0.55, 0.60, 1)
    hintFS:SetText("{name} = player name   {item} = item link")

    local function UpdateContColors()
        local enabled = LLF.db.showWhisperButtons ~= false
        cont:SetBackdropColor(enabled and 0.08 or 0.05, enabled and 0.08 or 0.05, enabled and 0.11 or 0.08, 1)
        cont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], enabled and 0.45 or 0.15)
    end
    UpdateContColors()

    local msgEB = CreateFrame("EditBox", N("NB_EB"), cont)
    msgEB:SetPoint("TOPLEFT",     cont, 6,  -4)
    msgEB:SetPoint("BOTTOMRIGHT", cont, -6,  4)
    msgEB:SetAutoFocus(false)
    msgEB:SetMaxLetters(200)
    msgEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    msgEB:SetText(LLF.db and LLF.db.needMessage or "{name}, do you need {item}?")

    local function SetMsgFont()
        local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
        local fp
        local chosen = LLF.db and LLF.db.feedFont
        if chosen and chosen ~= "" and lsm then fp = lsm:Fetch("font", chosen) end
        if not fp and lsm then fp = lsm:Fetch("font", "Friz Quadrata TT") end
        if not fp then fp = "Fonts\\FRIZQT__.TTF" end
        msgEB:SetFont(fp, 11, "")
    end
    SetMsgFont()

    msgEB:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if val == "" then val = "{name}, do you need {item}?" end
        LLF.db.needMessage = val
        if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
        self:ClearFocus()
    end)
    msgEB:SetScript("OnEscapePressed", function(self)
        self:SetText(LLF.db and LLF.db.needMessage or "{name}, do you need {item}?")
        self:ClearFocus()
    end)
    msgEB:SetScript("OnEditFocusGained", function(self)
        if LLF.db.showWhisperButtons == false then self:ClearFocus() end
    end)
    msgEB:SetScript("OnEditFocusLost", function(self)
        local val = self:GetText()
        if val == "" then val = "{name}, do you need {item}?" end
        LLF.db.needMessage = val
        if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
    end)
    msgEB:SetScript("OnEnter", function()
        if LLF.db.showWhisperButtons ~= false then
            cont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
        end
    end)
    msgEB:SetScript("OnLeave", function()
        UpdateContColors()
    end)

    if whisperToggle then
        local orig = whisperToggle.Sync
        whisperToggle.Sync = function(self)
            if orig then orig(self) end
            SetMsgFont()
            UpdateContColors()
            if LLF.db.showWhisperButtons == false and msgEB:HasFocus() then
                msgEB:ClearFocus()
            end
        end
        allToggles[#allToggles + 1] = whisperToggle
    end

    cont._refresh = function()
        msgEB:SetText(LLF.db and LLF.db.needMessage or "{name}, do you need {item}?")
        SetMsgFont()
        UpdateContColors()
        if LLF.db.showWhisperButtons == false and msgEB:HasFocus() then
            msgEB:ClearFocus()
        end
    end
    allSliders[#allSliders + 1] = cont

    p.SetY(y0 - 26 - SEP)

    local resetBtn = MakeBtn(parent, "Reset Message", 120, ROW_H)
    resetBtn:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    resetBtn:SetScript("OnClick", function()
        LLF.db.needMessage = "{name}, do you need {item}?"
        msgEB:SetText(LLF.db.needMessage)
        if LLF.PartyFeed then LLF.PartyFeed:ApplyFont() end
    end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Finalize()
end

local function PageAudio(parent, CW)
    local p = MakePage(parent, CW)

    p.Header("Valuable Loot Sound")
    local sndToggle = p.Row("Play sound on valuable loot",
        function() return LLF.db.soundEnabled end,
        function(v) LLF.db.soundEnabled = v end)
    local sndSlider = p.SlideInput("Value threshold  (gold)",  1, 10000, 1,
        function() return LLF.db.soundThreshold or 200 end,
        function(v) LLF.db.soundThreshold = v end)
    local y0 = p.GetY()
    local lp = MakeListPicker(parent, "Sound choice:", 40,
        function() return LLF.db.soundChoice or 1 end,
        function(v) LLF.db.soundChoice = v end,
        SoundItems)
    lp:SetPoint("TOPLEFT",  parent, p.PAD,        y0)
    lp:SetPoint("TOPRIGHT", parent, -p.PAD - 90,  y0)

    local playBtn = MakeBtn(parent, "Play", 80, 22)
    playBtn:SetPoint("TOPRIGHT", parent, -p.PAD, y0 - 18)
    playBtn:SetScript("OnClick", function()
        if LLF.db.soundEnabled then
            LLF:PlaySound(LLF.db.soundChoice or 1)
        end
    end)
    p.SetY(y0 - 40 - SEP)

    local function SyncSndEnabled()
        local on = LLF.db.soundEnabled
        if sndSlider then
            if sndSlider._lbl   then sndSlider._lbl:SetAlpha(on and 1 or 0.35) end
            if sndSlider._track then sndSlider._track:SetAlpha(on and 1 or 0.35) end
            if sndSlider._eb    then sndSlider._eb:SetAlpha(on and 1 or 0.35); sndSlider._eb:EnableMouse(on) end
            if sndSlider._thumb then sndSlider._thumb:EnableMouse(on) end
        end
        lp:SetAlpha(on and 1 or 0.35); lp:EnableMouse(on)
        playBtn:SetAlpha(on and 1 or 0.35); playBtn:EnableMouse(on)
    end
    SyncSndEnabled()
    hooksecurefunc(sndToggle, "Sync", SyncSndEnabled)

    p.Sep(12)

    p.Header("Wishlist Sound")
    local wlSndToggle = p.Row("Play sound when wishlisted item drops",
        function() return LLF.db.wishlistSoundEnabled end,
        function(v) LLF.db.wishlistSoundEnabled = v; RefreshAll() end)
    local y1 = p.GetY()
    local lp2 = MakeListPicker(parent, "Sound choice:", 40,
        function() return LLF.db.wishlistSoundChoice or 1 end,
        function(v) LLF.db.wishlistSoundChoice = v end,
        SoundItems)
    lp2:SetPoint("TOPLEFT",  parent, p.PAD,        y1)
    lp2:SetPoint("TOPRIGHT", parent, -p.PAD - 90,  y1)

    local playBtn2 = MakeBtn(parent, "Play", 80, 22)
    playBtn2:SetPoint("TOPRIGHT", parent, -p.PAD, y1 - 18)
    playBtn2:SetScript("OnClick", function()
        if LLF.db.wishlistSoundEnabled then
            LLF:PlaySound(LLF.db.wishlistSoundChoice or 1)
        end
    end)
    p.SetY(y1 - 40 - SEP)

    local function SyncWlSound()
        local on = LLF.db.wishlistSoundEnabled
        lp2:SetAlpha(on and 1 or 0.35)
        lp2:EnableMouse(on)
        if lp2._btn then lp2._btn:EnableMouse(on) end
        playBtn2:SetAlpha(on and 1 or 0.35)
        playBtn2:EnableMouse(on)
    end
    SyncWlSound()
    hooksecurefunc(wlSndToggle, "Sync", SyncWlSound)

    local function SyncWlSndSection()
        local wlOn = LLF.db.wishlistEnabled
        wlSndToggle:EnableMouse(wlOn)
        wlSndToggle:SetAlpha(wlOn and 1 or 0.35)
        if not wlOn then
            lp2:SetAlpha(0.35); lp2:EnableMouse(false)
            if lp2._btn then lp2._btn:EnableMouse(false) end
            playBtn2:SetAlpha(0.35); playBtn2:EnableMouse(false)
        end
    end
    SyncWlSndSection()
    hooksecurefunc(wlSndToggle, "Sync", SyncWlSndSection)
    allToggles[#allToggles + 1] = wlSndToggle

    p.Finalize()
end

local function PageBlacklist(parent, CW)
    local p = MakePage(parent, CW)
    p.Header("Item Blacklist")
    p.Label("|cffaaaaaaAccount-wide blacklist - suppressed items never appear in your loot feed.|r")
    p.Sep(6)

    local blToggle = p.Row("Enable blacklist filter",
        function() return LLF.db.blacklistEnabled == true end,
        function(v) LLF.db.blacklistEnabled = v; RefreshAll() end)

    p.Sep(6)

    local listCont  -- forward declare for SyncBlToggle
    local addCont_ref, addBtn_ref, searchCont_ref
    local function SyncBlToggle()
        local enabled = LLF.db.blacklistEnabled
        if listCont then listCont:SetAlpha(enabled and 1 or 0.35) end
        if addCont_ref then addCont_ref:SetAlpha(enabled and 1 or 0.35) end
        if addBtn_ref then addBtn_ref:SetAlpha(enabled and 1 or 0.35); addBtn_ref:EnableMouse(enabled) end
        if searchCont_ref then searchCont_ref:SetAlpha(enabled and 1 or 0.35) end
    end
    SyncBlToggle()
    hooksecurefunc(blToggle, "Sync", SyncBlToggle)

    local searchStr  = ""
    local pendingID  = nil
    local pendingData = nil

    local RebuildBlacklist
    local searchEB, searchPlaceholder, searchCont
    local prevCont, prevIcon, prevNameFS, addEB

    local yAdd = p.GetY()

    local addCont = CreateFrame("Frame", N("BL_ADC"), parent, "BackdropTemplate")
    addCont_ref = addCont
    addCont:SetHeight(ROW_H)
    addCont:SetPoint("TOPLEFT",  parent,  p.PAD,       yAdd)
    addCont:SetPoint("TOPRIGHT", parent, -p.PAD - 70,  yAdd)
    addCont:SetBackdrop(FLAT_BD)
    addCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local addPlaceholder = addCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlaceholder:SetPoint("LEFT", addCont, 8, 0)
    addPlaceholder:SetTextColor(0.38, 0.38, 0.42, 1)
    addPlaceholder:SetText("Drag an item here or type an item ID to add...")

    addEB = CreateFrame("EditBox", N("BL_AEB"), addCont)
    addEB:SetPoint("LEFT",         addCont,  8,  0)
    addEB:SetPoint("RIGHT",        addCont, -8,  0)
    addEB:SetHeight(ROW_H - 4)
    addEB:SetAutoFocus(false)
    addEB:SetFontObject("GameFontNormal")
    addEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    addEB:SetMaxLetters(500)
    addEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local addBtn = MakeBtn(parent, "Add", 62, ROW_H)
    addBtn_ref = addBtn
    addBtn:SetPoint("TOPLEFT", addCont, "TOPRIGHT", 4, 0)

    p.SetY(yAdd - ROW_H - p.SEP)

    local yPrev = p.GetY()

    prevCont = CreateFrame("Button", N("BL_PRC"), parent, "BackdropTemplate")
    prevCont:SetHeight(ROW_H)
    prevCont:SetPoint("TOPLEFT",  parent, p.PAD,  yPrev)
    prevCont:SetPoint("TOPRIGHT", parent, -p.PAD, yPrev)
    prevCont:SetBackdrop(FLAT_BD)
    prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
    prevCont:SetBackdropBorderColor(0, 0, 0, 0)
    prevCont:EnableMouse(true)

    prevIcon = prevCont:CreateTexture(nil, "ARTWORK")
    prevIcon:SetSize(22, 22)
    prevIcon:SetPoint("LEFT", prevCont, 5, 0)
    prevIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    prevIcon:Hide()

    prevNameFS = prevCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prevNameFS:SetPoint("LEFT",  prevIcon, "RIGHT", 5, 0)
    prevNameFS:SetPoint("RIGHT", prevCont, -5, 0)
    prevNameFS:SetJustifyH("LEFT")
    prevNameFS:SetWordWrap(false)

    p.SetY(yPrev - ROW_H - p.SEP)

    local LIST_H   = 210
    local ITEM_ROW = 28

    local yList = p.GetY()

    listCont = CreateFrame("Frame", N("BL_LC"), parent, "BackdropTemplate")
    listCont:SetHeight(LIST_H)
    listCont:SetPoint("TOPLEFT",  parent, p.PAD,  yList)
    listCont:SetPoint("TOPRIGHT", parent, -p.PAD, yList)
    listCont:SetBackdrop(FLAT_BD)
    listCont:SetBackdropColor(0.04, 0.04, 0.06, 1)
    listCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

    p.SetY(yList - LIST_H - p.SEP)

    local listSF = CreateFrame("ScrollFrame", N("BL_SF"), listCont, "UIPanelScrollFrameTemplate")
    listSF:SetPoint("TOPLEFT",     listCont,  3,  -3)
    listSF:SetPoint("BOTTOMRIGHT", listCont, -22,  3)

    local listContent = CreateFrame("Frame", N("BL_CT"), listSF)
    listSF:SetScrollChild(listContent)

    local emptyFS = listCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyFS:SetPoint("CENTER", listCont, 0, 0)
    emptyFS:SetTextColor(0.38, 0.38, 0.42, 1)
    emptyFS:Hide()

    local activeRows = {}
    local rowPool    = {}

    local function GetOrMakeRow()
        local r = table.remove(rowPool)
        if r then r:Show(); return r end

        r = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
        r:SetHeight(ITEM_ROW)
        r:SetBackdrop(FLAT_BD)

        local icon = r:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", r, 6, 0)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        r._icon = icon

        local hoverRegion = CreateFrame("Frame", nil, r)
        hoverRegion:SetAllPoints(r)
        hoverRegion:SetFrameLevel(r:GetFrameLevel() + 1)
        hoverRegion:EnableMouse(true)
        hoverRegion:SetScript("OnEnter", function()
            if r._tooltipLink then
                GameTooltip:SetOwner(r, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(r._tooltipLink)
                GameTooltip:Show()
            end
            r:SetBackdropColor(ACCENT[1]*0.15, ACCENT[2]*0.15, ACCENT[3]*0.15, 1)
        end)
        hoverRegion:SetScript("OnLeave", function()
            GameTooltip:Hide()
            r:SetBackdropColor(r._bgR or 0.04, r._bgG or 0.04, r._bgB or 0.06, 0.90)
        end)

        local nameFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("LEFT",  icon, "RIGHT", 5, 0)
        nameFS:SetPoint("RIGHT", r, "RIGHT", -72, 0)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetWordWrap(false)
        r._name = nameFS

        local idFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idFS:SetPoint("RIGHT", r, -72, 0)
        idFS:SetJustifyH("RIGHT")
        idFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
        r._idFS = idFS

        local removeBtn = MakeBtn(r, "Remove", 62, ITEM_ROW - 6)
        removeBtn:SetPoint("RIGHT", r, -4, 0)
        removeBtn:SetFrameLevel(r:GetFrameLevel() + 5)
        r._removeBtn = removeBtn

        return r
    end

    local function RecycleRow(r)
        r:Hide()
        r:ClearAllPoints()
        r._removeBtn:SetScript("OnClick", nil)
        r._tooltipLink = nil
        table.insert(rowPool, r)
    end

    RebuildBlacklist = function()
        LLF._rebuildBlacklist = RebuildBlacklist
        for _, r in ipairs(activeRows) do RecycleRow(r) end
        wipe(activeRows)

        local gdb = LLF.db
        if not gdb or not gdb.blacklist then
            emptyFS:SetText("No items blacklisted.")
            emptyFS:Show()
            listContent:SetHeight(LIST_H - 6)
            return
        end

        local items = {}
        local lo = searchStr:lower()
        for id, data in pairs(gdb.blacklist) do
            local name = data.name or ("Item " .. tostring(id))
            if lo == "" or name:lower():find(lo, 1, true) then
                items[#items + 1] = { id = id, data = data, name = name }
            end
        end

        if #items == 0 then
            emptyFS:SetText(lo ~= "" and ("No results for \"" .. searchStr .. "\".") or "No items blacklisted.")
            emptyFS:Show()
            listContent:SetHeight(LIST_H - 6)
            return
        end

        emptyFS:Hide()
        table.sort(items, function(a, b) return a.name:lower() < b.name:lower() end)

        local cw = listSF:GetWidth()
        if cw <= 0 then cw = CW - p.PAD * 2 - 30 end
        listContent:SetWidth(cw)

        local y = 0
        for i, item in ipairs(items) do
            local r = GetOrMakeRow()
            r:SetParent(listContent)
            r:SetWidth(cw)
            r:SetPoint("TOPLEFT", listContent, 0, y)

            local even = (i % 2 == 0)
            local br, bg, bb = even and 0.06 or 0.04, even and 0.06 or 0.04, even and 0.09 or 0.06
            r._bgR, r._bgG, r._bgB = br, bg, bb
            r:SetBackdropColor(br, bg, bb, 0.90)
            r:SetBackdropBorderColor(0, 0, 0, 0)

            r._icon:SetTexture(item.data.icon or 134400)

            local rarity = item.data.rarity or 1
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            r._name:SetText(cc .. item.name .. "|r")
            r._idFS:SetText("|cff555560ID " .. tostring(item.id) .. "|r")
            r._tooltipLink = item.data.link or ("item:" .. tostring(item.id))

            local capturedID = item.id
            r._removeBtn:SetScript("OnClick", function()
                gdb.blacklist[capturedID] = nil
                RebuildBlacklist()
                RefreshAll()
            end)

            y = y - ITEM_ROW
            activeRows[#activeRows + 1] = r
        end

        listContent:SetHeight(math.max(math.abs(y), 1))
    end

    local ySearch = p.GetY()

    searchCont = CreateFrame("Frame", N("BL_SC"), parent, "BackdropTemplate")
    searchCont_ref = searchCont
    searchCont:SetHeight(ROW_H)
    searchCont:SetPoint("TOPLEFT",  parent, p.PAD,  ySearch)
    searchCont:SetPoint("TOPRIGHT", parent, -p.PAD, ySearch)
    searchCont:SetBackdrop(FLAT_BD)
    searchCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    SyncBlToggle()

    searchPlaceholder = searchCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchPlaceholder:SetPoint("LEFT", searchCont, 8, 0)
    searchPlaceholder:SetTextColor(0.38, 0.38, 0.42, 1)
    searchPlaceholder:SetText("Search blacklisted items...")

    searchEB = CreateFrame("EditBox", N("BL_SEB"), searchCont)
    searchEB:SetPoint("LEFT",  searchCont,  8, 0)
    searchEB:SetPoint("RIGHT", searchCont, -8, 0)
    searchEB:SetHeight(ROW_H - 4)
    searchEB:SetAutoFocus(false)
    searchEB:SetFontObject("GameFontNormal")
    searchEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    searchEB:SetMaxLetters(100)
    searchEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    p.SetY(ySearch - ROW_H - p.SEP)

    local function SetPreview(itemID, name, icon, rarity, link, isError)
        if isError then
            prevIcon:Hide()
            prevNameFS:SetText("|cffff4444" .. (name or "Invalid item or ID") .. "|r")
            prevCont:SetBackdropColor(0.10, 0.04, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.60, 0.10, 0.10, 0.40)
            pendingID   = nil
            pendingData = nil
        elseif itemID then
            prevIcon:SetTexture(icon or 134400)
            prevIcon:Show()
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity or 1)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            prevNameFS:SetText(cc .. (name or "Unknown") .. "|r  |cff555560(ID " .. tostring(itemID) .. ")|r")
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
            pendingID   = itemID
            pendingData = { name = name, icon = icon, rarity = rarity, link = link }
        else
            prevIcon:Hide()
            prevNameFS:SetText("")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
            prevCont:SetBackdropBorderColor(0, 0, 0, 0)
            pendingID   = nil
            pendingData = nil
        end
    end

    local function TryParseInput(text)
        if not text or text:gsub("%s", "") == "" then SetPreview(nil); return end
        local itemID = tonumber(text:match("item:(%d+)")) or tonumber(text:match("^%s*(%d+)%s*$"))
        if not itemID then
            SetPreview(nil, "Not a valid item link or item ID.", nil, nil, nil, true)
            return
        end
        local name, link, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        if name then
            SetPreview(itemID, name, icon, rarity, link)
        else
            prevIcon:Hide()
            prevNameFS:SetText("|cff888888Loading item data...|r")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0.60)
            prevCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
            pendingID   = nil
            pendingData = nil
            local captured = itemID
            C_Timer.After(0.4, function()
                local cur = addEB:GetText()
                local curID = tonumber(cur:match("item:(%d+)")) or tonumber(cur:match("^%s*(%d+)%s*$"))
                if curID ~= captured then return end
                local n, l, r2, _, _, _, _, _, _, ic = C_Item.GetItemInfo(captured)
                if n then SetPreview(captured, n, ic, r2, l)
                else SetPreview(nil, "Item not found (ID: " .. tostring(captured) .. ").", nil, nil, nil, true) end
            end)
        end
    end

    local function CommitAdd()
        if not pendingID or not pendingData then return end
        LLF.db.blacklist[pendingID] = pendingData
        addEB:SetText("")
        addPlaceholder:Show()
        SetPreview(nil)
        searchStr = ""
        searchEB:SetText("")
        searchPlaceholder:Show()
        RebuildBlacklist()
        RefreshAll()
    end

    addEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        addPlaceholder:SetShown(t == "")
        TryParseInput(t)
    end)
    addEB:SetScript("OnEnterPressed", CommitAdd)
    addEB:EnableMouse(true)
    local function HandleDrop(self)
        local dtype, id = GetCursorInfo()
        if dtype == "item" then
            local _, link = C_Item.GetItemInfo(id)
            if link then self:SetText(link); TryParseInput(link) end
            ClearCursor()
        end
    end
    addEB:SetScript("OnReceiveDrag", HandleDrop)
    addEB:SetScript("OnMouseDown",   HandleDrop)
    addEB:SetScript("OnEditFocusGained", function()
        addPlaceholder:Hide()
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    addEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then addPlaceholder:Show() end
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)

    addBtn:SetScript("OnClick", CommitAdd)

    prevCont:SetScript("OnClick", function() if pendingID then CommitAdd() end end)
    prevCont:SetScript("OnEnter", function()
        if pendingID then
            prevCont:SetBackdropColor(0.08, 0.16, 0.08, 0.90)
            prevCont:SetBackdropBorderColor(0.15, 0.70, 0.15, 0.60)
            GameTooltip:SetOwner(prevCont, "ANCHOR_TOP")
            GameTooltip:SetText("|cff44ff44Click to add to blacklist|r", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    prevCont:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if pendingID then
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
        end
    end)

    searchEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        searchStr = t
        searchPlaceholder:SetShown(t == "")
        RebuildBlacklist()
    end)
    searchEB:SetScript("OnEditFocusGained", function()
        searchPlaceholder:Hide()
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.70)
    end)
    searchEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then searchPlaceholder:Show() end
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    end)

    LLF.Options._blRebuild = RebuildBlacklist

    p.Finalize()

    C_Timer.After(0, RebuildBlacklist)
end


local function PageWishlist(parent, CW)
    local p = MakePage(parent, CW)
    p.Header("Item Wishlist")
    p.Label("|cffaaaaaaOnly wishlisted items appear in your feed. Gold, currency, rep, and honor are unaffected unless toggled below.|r")
    p.Sep(6)

    local wlToggle = p.RowL("Enable wishlist filter",
        function() return LLF.db.wishlistEnabled == true end,
        function(v) LLF.db.wishlistEnabled = v; RefreshAll() end)
    local grpToggle = p.RowR("Also apply to group loot",
        function() return LLF.db.wishlistGroupLoot == true end,
        function(v) LLF.db.wishlistGroupLoot = v; RefreshAll() end)
    local currencyToggle = p.RowL("Filter gold/currency/rep/honor",
        function() return LLF.db.wishlistFilterCurrency == true end,
        function(v) LLF.db.wishlistFilterCurrency = v; RefreshAll() end)
    local mountsPetsToggle = p.RowR("Filter mounts/pets",
        function() return LLF.db.wishlistFilterMountsPets == true end,
        function(v) LLF.db.wishlistFilterMountsPets = v; RefreshAll() end)
    allToggles[#allToggles + 1] = currencyToggle
    allToggles[#allToggles + 1] = mountsPetsToggle

    local listCont  -- forward declare so SyncGroupToggle can access it
    local function SyncGroupToggle()
        local enabled = LLF.db.wishlistEnabled
        grpToggle:EnableMouse(enabled)
        grpToggle:SetAlpha(enabled and 1 or 0.35)
        if currencyToggle then currencyToggle:EnableMouse(enabled); currencyToggle:SetAlpha(enabled and 1 or 0.35) end
        if mountsPetsToggle then mountsPetsToggle:EnableMouse(enabled); mountsPetsToggle:SetAlpha(enabled and 1 or 0.35) end
        if listCont then listCont:SetAlpha(enabled and 1 or 0.35) end
    end
    SyncGroupToggle()
    hooksecurefunc(wlToggle, "Sync", SyncGroupToggle)

    p.Sep(6)

    local searchStr  = ""
    local pendingID  = nil
    local pendingData = nil

    local RebuildWishlist
    local searchEB, searchPlaceholder, searchCont
    local prevCont, prevIcon, prevNameFS, addEB

    local yAdd = p.GetY()

    local addCont = CreateFrame("Frame", N("WL_ADC"), parent, "BackdropTemplate")
    addCont:SetHeight(ROW_H)
    addCont:SetPoint("TOPLEFT",  parent,  p.PAD,       yAdd)
    addCont:SetPoint("TOPRIGHT", parent, -p.PAD - 70,  yAdd)
    addCont:SetBackdrop(FLAT_BD)
    addCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local addPlaceholder = addCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlaceholder:SetPoint("LEFT", addCont, 8, 0)
    addPlaceholder:SetTextColor(0.38, 0.38, 0.42, 1)
    addPlaceholder:SetText("Drag an item here or type an item ID to add...")

    addEB = CreateFrame("EditBox", N("WL_AEB"), addCont)
    addEB:SetPoint("LEFT",         addCont,  8,  0)
    addEB:SetPoint("RIGHT",        addCont, -8,  0)
    addEB:SetHeight(ROW_H - 4)
    addEB:SetAutoFocus(false)
    addEB:SetFontObject("GameFontNormal")
    addEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    addEB:SetMaxLetters(500)
    addEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local addBtn = MakeBtn(parent, "Add", 62, ROW_H)
    addBtn:SetPoint("TOPLEFT", addCont, "TOPRIGHT", 4, 0)

    p.SetY(yAdd - ROW_H - p.SEP)

    local yPrev = p.GetY()

    prevCont = CreateFrame("Button", N("WL_PRC"), parent, "BackdropTemplate")
    prevCont:SetHeight(ROW_H)
    prevCont:SetPoint("TOPLEFT",  parent, p.PAD,  yPrev)
    prevCont:SetPoint("TOPRIGHT", parent, -p.PAD, yPrev)
    prevCont:SetBackdrop(FLAT_BD)
    prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
    prevCont:SetBackdropBorderColor(0, 0, 0, 0)
    prevCont:EnableMouse(true)

    prevIcon = prevCont:CreateTexture(nil, "ARTWORK")
    prevIcon:SetSize(22, 22)
    prevIcon:SetPoint("LEFT", prevCont, 5, 0)
    prevIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    prevIcon:Hide()

    prevNameFS = prevCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prevNameFS:SetPoint("LEFT",  prevIcon, "RIGHT", 5, 0)
    prevNameFS:SetPoint("RIGHT", prevCont, -5, 0)
    prevNameFS:SetJustifyH("LEFT")
    prevNameFS:SetWordWrap(false)

    p.SetY(yPrev - ROW_H - p.SEP)

    local LIST_H   = 210
    local ITEM_ROW = 28

    local yList = p.GetY()

    listCont = CreateFrame("Frame", N("WL_LC"), parent, "BackdropTemplate")
    listCont:SetHeight(LIST_H)
    listCont:SetPoint("TOPLEFT",  parent, p.PAD,  yList)
    listCont:SetPoint("TOPRIGHT", parent, -p.PAD, yList)
    listCont:SetBackdrop(FLAT_BD)
    listCont:SetBackdropColor(0.04, 0.04, 0.06, 1)
    listCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

    p.SetY(yList - LIST_H - p.SEP)

    local listSF = CreateFrame("ScrollFrame", N("WL_SF"), listCont, "UIPanelScrollFrameTemplate")
    listSF:SetPoint("TOPLEFT",     listCont,  3,  -3)
    listSF:SetPoint("BOTTOMRIGHT", listCont, -22,  3)

    local listContent = CreateFrame("Frame", N("WL_CT"), listSF)
    listSF:SetScrollChild(listContent)

    local emptyFS = listCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyFS:SetPoint("CENTER", listCont, 0, 0)
    emptyFS:SetTextColor(0.38, 0.38, 0.42, 1)
    emptyFS:Hide()

    local activeRows = {}
    local rowPool    = {}

    local function GetOrMakeRow()
        local r = table.remove(rowPool)
        if r then r:Show(); return r end

        r = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
        r:SetHeight(ITEM_ROW)
        r:SetBackdrop(FLAT_BD)

        local icon = r:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", r, 6, 0)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        r._icon = icon

        local hoverRegion = CreateFrame("Frame", nil, r)
        hoverRegion:SetAllPoints(r)
        hoverRegion:SetFrameLevel(r:GetFrameLevel() + 1)
        hoverRegion:EnableMouse(true)
        hoverRegion:SetScript("OnEnter", function()
            if r._tooltipLink then
                GameTooltip:SetOwner(r, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(r._tooltipLink)
                GameTooltip:Show()
            end
            r:SetBackdropColor(ACCENT[1]*0.15, ACCENT[2]*0.15, ACCENT[3]*0.15, 1)
        end)
        hoverRegion:SetScript("OnLeave", function()
            GameTooltip:Hide()
            r:SetBackdropColor(r._bgR or 0.04, r._bgG or 0.04, r._bgB or 0.06, 0.90)
        end)

        local nameFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("LEFT",  icon, "RIGHT", 5, 0)
        nameFS:SetPoint("RIGHT", r, "RIGHT", -72, 0)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetWordWrap(false)
        r._name = nameFS

        local idFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idFS:SetPoint("RIGHT", r, -72, 0)
        idFS:SetJustifyH("RIGHT")
        idFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
        r._idFS = idFS

        local removeBtn = MakeBtn(r, "Remove", 62, ITEM_ROW - 6)
        removeBtn:SetPoint("RIGHT", r, -4, 0)
        removeBtn:SetFrameLevel(r:GetFrameLevel() + 5)
        r._removeBtn = removeBtn

        return r
    end

    local function RecycleRow(r)
        r:Hide()
        r:ClearAllPoints()
        r._removeBtn:SetScript("OnClick", nil)
        r._tooltipLink = nil
        table.insert(rowPool, r)
    end

    RebuildWishlist = function()
        LLF._rebuildWishlist = RebuildWishlist
        for _, r in ipairs(activeRows) do RecycleRow(r) end
        wipe(activeRows)

        local gdb = LLF.db
        if not gdb or not gdb.wishlist then
            emptyFS:SetText("No items wishlisted.")
            emptyFS:Show()
            listContent:SetHeight(LIST_H - 6)
            return
        end

        local items = {}
        local lo = searchStr:lower()
        for id, data in pairs(gdb.wishlist) do
            local name = data.name or ("Item " .. tostring(id))
            if lo == "" or name:lower():find(lo, 1, true) then
                items[#items + 1] = { id = id, data = data, name = name }
            end
        end

        if #items == 0 then
            emptyFS:SetText(lo ~= "" and ("No results for \"" .. searchStr .. "\".") or "No items wishlisted.")
            emptyFS:Show()
            listContent:SetHeight(LIST_H - 6)
            return
        end

        emptyFS:Hide()
        table.sort(items, function(a, b) return a.name:lower() < b.name:lower() end)

        local cw = listSF:GetWidth()
        if cw <= 0 then cw = CW - p.PAD * 2 - 30 end
        listContent:SetWidth(cw)

        local y = 0
        for i, item in ipairs(items) do
            local r = GetOrMakeRow()
            r:SetParent(listContent)
            r:SetWidth(cw)
            r:SetPoint("TOPLEFT", listContent, 0, y)

            local even = (i % 2 == 0)
            local br, bg, bb = even and 0.06 or 0.04, even and 0.06 or 0.04, even and 0.09 or 0.06
            r._bgR, r._bgG, r._bgB = br, bg, bb
            r:SetBackdropColor(br, bg, bb, 0.90)
            r:SetBackdropBorderColor(0, 0, 0, 0)

            r._icon:SetTexture(item.data.icon or 134400)

            local rarity = item.data.rarity or 1
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            r._name:SetText(cc .. item.name .. "|r")
            r._idFS:SetText("|cff555560ID " .. tostring(item.id) .. "|r")
            r._tooltipLink = item.data.link or ("item:" .. tostring(item.id))

            local capturedID = item.id
            r._removeBtn:SetScript("OnClick", function()
                gdb.wishlist[capturedID] = nil
                RebuildWishlist()
                RefreshAll()
            end)

            y = y - ITEM_ROW
            activeRows[#activeRows + 1] = r
        end

        listContent:SetHeight(math.max(math.abs(y), 1))
    end

    local ySearch = p.GetY()

    searchCont = CreateFrame("Frame", N("WL_SC"), parent, "BackdropTemplate")
    searchCont:SetHeight(ROW_H)
    searchCont:SetPoint("TOPLEFT",  parent, p.PAD,  ySearch)
    searchCont:SetPoint("TOPRIGHT", parent, -p.PAD, ySearch)
    searchCont:SetBackdrop(FLAT_BD)
    searchCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    searchPlaceholder = searchCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchPlaceholder:SetPoint("LEFT", searchCont, 8, 0)
    searchPlaceholder:SetTextColor(0.38, 0.38, 0.42, 1)
    searchPlaceholder:SetText("Search wishlisted items...")

    searchEB = CreateFrame("EditBox", N("WL_SEB"), searchCont)
    searchEB:SetPoint("LEFT",  searchCont,  8, 0)
    searchEB:SetPoint("RIGHT", searchCont, -8, 0)
    searchEB:SetHeight(ROW_H - 4)
    searchEB:SetAutoFocus(false)
    searchEB:SetFontObject("GameFontNormal")
    searchEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    searchEB:SetMaxLetters(100)
    searchEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    p.SetY(ySearch - ROW_H - p.SEP)

    local function SetPreview(itemID, name, icon, rarity, link, isError)
        if isError then
            prevIcon:Hide()
            prevNameFS:SetText("|cffff4444" .. (name or "Invalid item or ID") .. "|r")
            prevCont:SetBackdropColor(0.10, 0.04, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.60, 0.10, 0.10, 0.40)
            pendingID   = nil
            pendingData = nil
        elseif itemID then
            prevIcon:SetTexture(icon or 134400)
            prevIcon:Show()
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity or 1)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            prevNameFS:SetText(cc .. (name or "Unknown") .. "|r  |cff555560(ID " .. tostring(itemID) .. ")|r")
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
            pendingID   = itemID
            pendingData = { name = name, icon = icon, rarity = rarity, link = link }
        else
            prevIcon:Hide()
            prevNameFS:SetText("")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
            prevCont:SetBackdropBorderColor(0, 0, 0, 0)
            pendingID   = nil
            pendingData = nil
        end
    end

    local function TryParseInput(text)
        if not text or text:gsub("%s", "") == "" then SetPreview(nil); return end
        local itemID = tonumber(text:match("item:(%d+)")) or tonumber(text:match("^%s*(%d+)%s*$"))
        if not itemID then
            SetPreview(nil, "Not a valid item link or item ID.", nil, nil, nil, true)
            return
        end
        local name, link, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        if name then
            SetPreview(itemID, name, icon, rarity, link)
        else
            prevIcon:Hide()
            prevNameFS:SetText("|cff888888Loading item data...|r")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0.60)
            prevCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
            pendingID   = nil
            pendingData = nil
            local captured = itemID
            C_Timer.After(0.4, function()
                local cur = addEB:GetText()
                local curID = tonumber(cur:match("item:(%d+)")) or tonumber(cur:match("^%s*(%d+)%s*$"))
                if curID ~= captured then return end
                local n, l, r2, _, _, _, _, _, _, ic = C_Item.GetItemInfo(captured)
                if n then SetPreview(captured, n, ic, r2, l)
                else SetPreview(nil, "Item not found (ID: " .. tostring(captured) .. ").", nil, nil, nil, true) end
            end)
        end
    end

    local function CommitAdd()
        if not pendingID or not pendingData then return end
        LLF.db.wishlist[pendingID] = pendingData
        addEB:SetText("")
        addPlaceholder:Show()
        SetPreview(nil)
        searchStr = ""
        searchEB:SetText("")
        searchPlaceholder:Show()
        RebuildWishlist()
    end

    addEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        addPlaceholder:SetShown(t == "")
        TryParseInput(t)
    end)
    addEB:SetScript("OnEnterPressed", CommitAdd)
    addEB:EnableMouse(true)
    local function HandleDrop(self)
        local dtype, id = GetCursorInfo()
        if dtype == "item" then
            local _, link = C_Item.GetItemInfo(id)
            if link then self:SetText(link); TryParseInput(link) end
            ClearCursor()
        end
    end
    addEB:SetScript("OnReceiveDrag", HandleDrop)
    addEB:SetScript("OnMouseDown",   HandleDrop)
    addEB:SetScript("OnEditFocusGained", function()
        addPlaceholder:Hide()
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    addEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then addPlaceholder:Show() end
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)

    addBtn:SetScript("OnClick", CommitAdd)

    prevCont:SetScript("OnClick", function() if pendingID then CommitAdd() end end)
    prevCont:SetScript("OnEnter", function()
        if pendingID then
            prevCont:SetBackdropColor(0.08, 0.16, 0.08, 0.90)
            prevCont:SetBackdropBorderColor(0.15, 0.70, 0.15, 0.60)
            GameTooltip:SetOwner(prevCont, "ANCHOR_TOP")
            GameTooltip:SetText("|cff44ff44Click to add to wishlist|r", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    prevCont:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if pendingID then
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
        end
    end)

    searchEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        searchStr = t
        searchPlaceholder:SetShown(t == "")
        RebuildWishlist()
    end)
    searchEB:SetScript("OnEditFocusGained", function()
        searchPlaceholder:Hide()
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.70)
    end)
    searchEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then searchPlaceholder:Show() end
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    end)

    LLF.Options._wlRebuild = RebuildWishlist

    p.Sep(12)
    p.Header("Wishlist Glow")
    local function WlRefreshTest() LLF.Feed:RefreshTestRows(); LLF.PartyFeed:RefreshTestRows() end
    local wlGlowToggle = p.Row("Enable glow on wishlisted items",
        function() return LLF.db.wishlistGlowEnabled end,
        function(v) LLF.db.wishlistGlowEnabled = v; WlRefreshTest() end)

    local ApplyWlGlowGating
    local wlGlowTypePicker = p.Picker("Glow style", 40,
        function() return LLF.db.wishlistGlowType or 1 end,
        function(v) LLF.db.wishlistGlowType = v; if ApplyWlGlowGating then ApplyWlGlowGating() end; WlRefreshTest() end,
        function()
            return {
                { value = 1, display = "Pixel" },
                { value = 2, display = "AutoCast" },
                { value = 3, display = "Blizzard" },
            }
        end)

    local wlGlowLines = p.SlideInput("Lines / particles", 1, 30, 1,
        function() return LLF.db.wishlistGlowLines or 12 end,
        function(v) LLF.db.wishlistGlowLines = v; WlRefreshTest() end)
    local wlGlowSpeed = p.SlideInput("Speed", 0.05, 1.0, 0.05,
        function() return LLF.db.wishlistGlowSpeed or 0.35 end,
        function(v) LLF.db.wishlistGlowSpeed = v; WlRefreshTest() end)
    local wlGlowThick = p.SlideInput("Thickness", 1, 6, 1,
        function() return LLF.db.wishlistGlowThickness or 2 end,
        function(v) LLF.db.wishlistGlowThickness = v; WlRefreshTest() end)

    local wlGlowGatedControls = { wlGlowTypePicker }

    ApplyWlGlowGating = function()
        local on = LLF.db.wishlistGlowEnabled == true
        local gt = LLF.db.wishlistGlowType or 1
        local linesOK = on and (gt ~= 3)
        local speedOK = on
        local thickOK = on and (gt ~= 3)
        for _, ctrl in ipairs(wlGlowGatedControls) do
            if ctrl then ctrl:SetAlpha(on and 1 or 0.35); ctrl:EnableMouse(on) end
        end
        GateSlider(wlGlowLines, linesOK)
        GateSlider(wlGlowSpeed, speedOK)
        GateSlider(wlGlowThick, thickOK)
    end
    ApplyWlGlowGating()

    if wlGlowToggle then
        local origSync = wlGlowToggle.Sync
        wlGlowToggle.Sync = function(self)
            if origSync then origSync(self) end
            ApplyWlGlowGating()
        end
    end

    for _, sc in ipairs({ wlGlowLines, wlGlowSpeed, wlGlowThick }) do
        if sc._eb then
            sc._eb:HookScript("OnEditFocusGained", function(self)
                if not LLF.db.wishlistGlowEnabled then self:ClearFocus() end
            end)
        end
    end

    p.Finalize()

    C_Timer.After(0, RebuildWishlist)
end


local function PageProfiles(parent, CW)
    local p = MakePage(parent, CW)

    p.Header("Profiles")

    local currentFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentFS:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    currentFS:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    p.SetY(p.GetY() - 20 - SEP)

    local profileStatusFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileStatusFS:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    profileStatusFS:SetText("")
    p.SetY(p.GetY() - 16 - SEP)

    local function UpdateProfileDisplay()
        currentFS:SetText("Active profile: |cff32bff7" .. LLF.Config:GetCurrentProfileName() .. "|r")
        profileStatusFS:SetText("")
    end
    UpdateProfileDisplay()

    local switchY = p.GetY()
    local switchLP = MakeListPicker(parent, "Switch profile:", 40,
        function()
            local cur = LLF.Config:GetCurrentProfileName()
            local list = LLF.Config:GetProfileList()
            for i, name in ipairs(list) do
                if name == cur then return i end
            end
            return 1
        end,
        function(v)
            local list = LLF.Config:GetProfileList()
            local name = list[v]
            if name then
                LLF.Config:SetProfile(name)
                LLF.Config:Init()
                UpdateProfileDisplay()
                RefreshAll()
                profileStatusFS:SetText("|cff44ff44Switched to profile: " .. name .. "|r")
            end
        end,
        function()
            local items = {}
            for i, name in ipairs(LLF.Config:GetProfileList()) do
                items[#items + 1] = { value = i, display = name }
            end
            return items
        end)
    switchLP:SetPoint("TOPLEFT",  parent, p.PAD,       switchY)
    switchLP:SetPoint("TOPRIGHT", parent, -p.PAD,      switchY)
    p.SetY(switchY - 40 - SEP)

    p.Sep(4)

    local btnY = p.GetY()

    local newCont = CreateFrame("Frame", N("PR_NC"), parent, "BackdropTemplate")
    newCont:SetHeight(ROW_H)
    newCont:SetPoint("TOPLEFT", parent, p.PAD, btnY)
    newCont:SetWidth(200)
    newCont:SetBackdrop(FLAT_BD)
    newCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    newCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local newPlaceholder = newCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newPlaceholder:SetPoint("LEFT", newCont, 8, 0)
    newPlaceholder:SetTextColor(0.38, 0.38, 0.42, 1)
    newPlaceholder:SetText("New profile name...")

    local newEB = CreateFrame("EditBox", N("PR_NEB"), newCont)
    newEB:SetPoint("LEFT",  newCont, 8, 0)
    newEB:SetPoint("RIGHT", newCont, -8, 0)
    newEB:SetHeight(ROW_H - 4)
    newEB:SetAutoFocus(false)
    newEB:SetFontObject("GameFontNormal")
    newEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    newEB:SetMaxLetters(40)
    newEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    newEB:SetScript("OnEnterPressed", function(self)
        local name = self:GetText():match("^%s*(.-)%s*$")
        if not name or name == "" then
            profileStatusFS:SetText("|cffff4444Enter a profile name.|r"); return
        end
        if LLF.Config:CreateProfile(name) then
            self:SetText("")
            profileStatusFS:SetText("|cff44ff44Profile '" .. name .. "' created.|r")
            RefreshAll()
        else
            profileStatusFS:SetText("|cffff4444Profile '" .. name .. "' already exists.|r")
        end
        self:ClearFocus()
    end)
    newEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        newPlaceholder:SetShown(self:GetText() == "")
    end)
    newEB:SetScript("OnEditFocusGained", function() newPlaceholder:Hide() end)
    newEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then newPlaceholder:Show() end
    end)

    local newBtn = MakeBtn(parent, "Create", 70, ROW_H)
    newBtn:SetPoint("LEFT", newCont, "RIGHT", 4, 0)
    newBtn:SetScript("OnClick", function()
        local name = newEB:GetText():match("^%s*(.-)%s*$")
        if not name or name == "" then
            profileStatusFS:SetText("|cffff4444Enter a profile name.|r"); return
        end
        if LLF.Config:CreateProfile(name) then
            newEB:SetText("")
            profileStatusFS:SetText("|cff44ff44Profile '" .. name .. "' created.|r")
            RefreshAll()
        else
            profileStatusFS:SetText("|cffff4444Profile '" .. name .. "' already exists.|r")
        end
    end)

    local copyBtn = MakeBtn(parent, "Copy From...", 100, ROW_H)
    copyBtn:SetPoint("LEFT", newBtn, "RIGHT", 6, 0)

    local deleteBtn = MakeBtn(parent, "Delete", 70, ROW_H)
    deleteBtn:SetPoint("LEFT", copyBtn, "RIGHT", 6, 0)

    local resetBtn = MakeBtn(parent, "Reset", 70, ROW_H)
    resetBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 6, 0)

    p.SetY(btnY - ROW_H - SEP)

    if not StaticPopupDialogs["LLF_COPY_PROFILE"] then
        StaticPopupDialogs["LLF_COPY_PROFILE"] = {
            text = "Copy settings from profile '%s' into your current profile?\n\n|cffff4444This will overwrite your current settings.|r",
            button1 = "Copy",
            button2 = "Cancel",
            OnAccept = function(self)
                local srcName = self.data.srcName
                if LLF.Config:CopyProfile(srcName) then
                    if self.data.statusFS then
                        self.data.statusFS:SetText("|cff44ff44Copied settings from '" .. srcName .. "'.|r")
                    end
                    RefreshAll()
                end
            end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end

    local popupMenu, popupBtns = nil, {}
    local MENU_BTN_H = 22

    local function ShowSimpleMenu(anchorFrame, entries)
        if not popupMenu then
            popupMenu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            popupMenu:SetFrameStrata("FULLSCREEN_DIALOG")
            popupMenu:SetBackdrop(FLAT_BD)
            popupMenu:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
            popupMenu:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.60)
            popupMenu:SetClampedToScreen(true)
            popupMenu:EnableMouse(true)
            popupMenu:Hide()
            popupMenu:SetScript("OnUpdate", function(self)
                if not self:IsShown() then return end
                if IsMouseButtonDown("LeftButton") and not self:IsMouseOver() then
                    self:Hide()
                end
            end)
        end
        popupMenu:Hide()

        for _, b in ipairs(popupBtns) do b:Hide(); b:SetParent(nil) end
        table.wipe(popupBtns)

        for i, entry in ipairs(entries) do
            local b = CreateFrame("Button", nil, popupMenu)
            b:SetHeight(MENU_BTN_H)
            b:SetNormalFontObject("GameFontNormal")
            b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
            b:GetHighlightTexture():SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.15)
            local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fs:SetPoint("LEFT", b, 8, 0)
            fs:SetText(entry.text)
            b:SetFontString(fs)
            b:SetScript("OnClick", function() popupMenu:Hide(); entry.onClick() end)
            popupBtns[i] = b
        end

        local maxW = 120
        for _, b in ipairs(popupBtns) do
            local w = b:GetFontString():GetStringWidth() + 20
            if w > maxW then maxW = w end
        end
        popupMenu:SetSize(maxW, #popupBtns * MENU_BTN_H + 4)
        for i, b in ipairs(popupBtns) do
            b:SetPoint("TOPLEFT", popupMenu, 2, -(i - 1) * MENU_BTN_H - 2)
            b:SetPoint("TOPRIGHT", popupMenu, -2, -(i - 1) * MENU_BTN_H - 2)
            b:Show()
        end

        popupMenu:ClearAllPoints()
        popupMenu:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2)
        popupMenu:Show()
    end

    copyBtn:SetScript("OnClick", function()
        local list = LLF.Config:GetProfileList()
        local cur  = LLF.Config:GetCurrentProfileName()
        local entries = {}
        for _, name in ipairs(list) do
            if name ~= cur then
                entries[#entries + 1] = {
                    text = name,
                    onClick = function()
                        local dialog = StaticPopup_Show("LLF_COPY_PROFILE", name)
                        if dialog then
                            dialog.data = { srcName = name, statusFS = profileStatusFS }
                        end
                    end,
                }
            end
        end
        if #entries == 0 then
            profileStatusFS:SetText("|cffff4444No other profiles to copy from.|r")
            return
        end
        ShowSimpleMenu(copyBtn, entries)
    end)

    if not StaticPopupDialogs["LLF_DELETE_PROFILE"] then
        StaticPopupDialogs["LLF_DELETE_PROFILE"] = {
            text = "Delete profile '%s'?\n\n|cffff4444This cannot be undone.|r",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function(self)
                local name = self.data.name
                LLF.Config:SetProfile("Default")
                LLF.Config:Init()
                LLF.Config:DeleteProfile(name)
                if self.data.statusFS then
                    self.data.statusFS:SetText("|cff44ff44Profile '" .. name .. "' deleted. Switched to Default.|r")
                end
                if self.data.updateFn then self.data.updateFn() end
                RefreshAll()
            end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end

    deleteBtn:SetScript("OnClick", function()
        local cur = LLF.Config:GetCurrentProfileName()
        if cur == "Default" then
            profileStatusFS:SetText("|cffff4444Cannot delete the Default profile.|r")
            return
        end
        local dialog = StaticPopup_Show("LLF_DELETE_PROFILE", cur)
        if dialog then
            dialog.data = { name = cur, statusFS = profileStatusFS, updateFn = UpdateProfileDisplay }
        end
    end)

    if not StaticPopupDialogs["LLF_RESET_PROFILE"] then
        StaticPopupDialogs["LLF_RESET_PROFILE"] = {
            text = "Reset profile '%s' to default settings?\n\n|cffff4444This cannot be undone.|r",
            button1 = "Reset",
            button2 = "Cancel",
            OnAccept = function(self)
                LLF.Config:ResetProfile()
                if self.data.statusFS then
                    self.data.statusFS:SetText("|cff44ff44Profile reset to defaults.|r")
                end
                RefreshAll()
            end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end

    resetBtn:SetScript("OnClick", function()
        local cur = LLF.Config:GetCurrentProfileName()
        local dialog = StaticPopup_Show("LLF_RESET_PROFILE", cur)
        if dialog then
            dialog.data = { statusFS = profileStatusFS }
        end
    end)

    p.Sep(6)

    local LD = LibStub and LibStub("LibDeflate", true)

    local function Export()
        local function Serialize(t, indent)
            indent = indent or ""
            local out = "{\n"
            local ni  = indent .. "  "
            for k, v in pairs(t) do
                local key = type(k) == "number" and ("[" .. k .. "]") or k
                local val
                if     type(v) == "table"   then val = Serialize(v, ni)
                elseif type(v) == "string"  then val = string.format("%q", v)
                elseif type(v) == "boolean" then val = tostring(v)
                elseif type(v) == "number"  then val = tostring(v)
                end
                if val then out = out .. ni .. key .. "=" .. val .. ",\n" end
            end
            return out .. indent .. "}"
        end
        local str = Serialize(LLF.db)
        if not LD then return str end
        local compressed = LD:CompressDeflate(str)
        return LD:EncodeForPrint(compressed)
    end

    local function Import(encoded)
        local function ParseValue(s, pos)
            while pos <= #s and s:sub(pos,pos):match("%s") do pos = pos + 1 end
            local c = s:sub(pos, pos)
            if c == "{" then
                local t = {}; pos = pos + 1
                while true do
                    while pos <= #s and s:sub(pos,pos):match("[%s,]") do pos = pos + 1 end
                    if s:sub(pos,pos) == "}" then pos = pos + 1; break end
                    local key, val
                    if s:sub(pos,pos) == "[" then
                                                local numStr = s:match("^%[([%d%.%-]+)%]", pos)
                        if numStr then
                            key = tonumber(numStr)
                            pos = pos + #numStr + 2
                            while pos <= #s and s:sub(pos,pos):match("[%s=]") do pos = pos + 1 end
                        end
                    else
                        local k = s:match("^([%w_]+)%s*=", pos)
                        if k then key = k; pos = pos + #k; while pos <= #s and s:sub(pos,pos):match("[%s=]") do pos = pos + 1 end end
                    end
                    if key == nil then break end
                    val, pos = ParseValue(s, pos)
                    t[key] = val
                end
                return t, pos
            elseif c == '"' then
                                local result = {}; pos = pos + 1
                while pos <= #s do
                    local ch = s:sub(pos, pos)
                    if ch == "\\" then
                        pos = pos + 1
                        local esc = s:sub(pos, pos)
                        if     esc == "n"  then result[#result+1] = "\n"
                        elseif esc == "t"  then result[#result+1] = "\t"
                        elseif esc == "r"  then result[#result+1] = "\r"
                        elseif esc == "\\" then result[#result+1] = "\\"
                        elseif esc == '"'  then result[#result+1] = '"'
                        else result[#result+1] = esc end
                    elseif ch == '"' then
                        pos = pos + 1; break
                    else
                        result[#result+1] = ch
                    end
                    pos = pos + 1
                end
                return table.concat(result), pos
            elseif s:sub(pos):match("^%-?[%d%.]+") then
                local numStr = s:match("^%-?[%d%.]+", pos)
                return tonumber(numStr), pos + #numStr
            elseif s:sub(pos):match("^true") then
                return true, pos + 4
            elseif s:sub(pos):match("^false") then
                return false, pos + 5
            elseif s:sub(pos):match("^nil") then
                return nil, pos + 3
            else
                return nil, pos + 1
            end
        end

        if not LD then return nil, "LibDeflate not loaded" end
        local compressed = LD:DecodeForPrint(encoded)
        if not compressed then return nil, "Failed to decode" end
        local str = LD:DecompressDeflate(compressed)
        if not str then return nil, "Failed to decompress" end
        local ok, result = pcall(ParseValue, str, 1)
        if not ok or type(result) ~= "table" then return nil, "Failed to parse" end
        return result
    end

    local function ApplyImported(src, dst)
        for k, v in pairs(src) do
            if type(v) == "table" and type(dst[k]) == "table" then
                ApplyImported(v, dst[k])
            elseif type(v) == type(dst[k]) or dst[k] == nil then
                dst[k] = v
            end
        end
    end

    p.Header("Export Settings")
    p.Label("|cffaaaaaaCopy this string to share your settings with others.|r")
    p.Sep(2)

    local BOX_H = 80

    local function MakeScrolledEditBox(parentFrame, yPos, readOnly)
        local container = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
        container:SetHeight(BOX_H)
        container:SetPoint("TOPLEFT",  parentFrame, p.PAD,  yPos)
        container:SetPoint("TOPRIGHT", parentFrame, -p.PAD, yPos)
        container:SetBackdrop(FLAT_BD)
        container:SetBackdropColor(0.06, 0.06, 0.09, 1)
        container:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
        container:SetClipsChildren(true)

        local sf = CreateFrame("ScrollFrame", N("ESF"), container, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT",     container, 4,  -4)
        sf:SetPoint("BOTTOMRIGHT", container, -24, 4)

        local eb = CreateFrame("EditBox", N("EB"), sf)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetFontObject("GameFontNormalSmall")
        eb:SetWidth(sf:GetWidth())
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        eb:SetScript("OnTextChanged", function(self)
            sf:SetScrollChild(self)
            self:SetWidth(sf:GetWidth())
        end)
        sf:SetScrollChild(eb)
        return container, eb
    end

    local exportContainer, exportBox = MakeScrolledEditBox(parent, p.GetY())
    p.SetY(p.GetY() - BOX_H - SEP)

    local exportBtn = MakeBtn(parent, "Generate Export String", 180, ROW_H)
    exportBtn:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    exportBtn:SetScript("OnClick", function()
        local str = Export()
        exportBox:SetText(str); exportBox:SetFocus(); exportBox:HighlightText()
    end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Sep(6)
    p.Header("Import Settings")
    p.Label("|cffaaaaaaPaste an export string below, then click Import.|r")
    p.Sep(2)

    local importContainer, importBox = MakeScrolledEditBox(parent, p.GetY())
    p.SetY(p.GetY() - BOX_H - SEP)

    local statusFS = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusFS:SetPoint("TOPLEFT", parent, p.PAD, p.GetY()); statusFS:SetText("")

    if not StaticPopupDialogs["LLF_IMPORT_CONFIRM"] then
        StaticPopupDialogs["LLF_IMPORT_CONFIRM"] = {
            text = "Import settings?\n\n|cffff4444This will overwrite your current settings.|r",
            button1 = "Import",
            button2 = "Cancel",
            OnAccept = function(self)
                local raw = self.data.raw
                local statusFS = self.data.statusFS
                local importBox = self.data.importBox
                local data, err = Import(raw)
                if not data then
                    statusFS:SetText("|cffff4444Import failed: " .. tostring(err) .. "|r"); return
                end
                ApplyImported(data, LLF.db)
                importBox:SetText("")
                statusFS:SetText("|cff44ff44Settings imported! Reload UI to apply all changes fully.|r")
                RefreshAll()
                if LLF.Feed then LLF.Feed:ApplyLayout(); LLF.Feed:ApplyFont() end
                if LLF.PartyFeed then LLF.PartyFeed:ApplyLayout(); LLF.PartyFeed:ApplyFont() end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    local importBtn = MakeBtn(parent, "Import", 100, ROW_H)
    importBtn:SetPoint("TOPLEFT", parent, p.PAD, p.GetY())
    importBtn:SetScript("OnClick", function()
        local raw = importBox:GetText()
        if not raw or raw:gsub("%s", "") == "" then
            statusFS:SetText("|cffff4444No string to import.|r"); return
        end
        local data, err = Import(raw)
        if not data then
            statusFS:SetText("|cffff4444Import failed: " .. tostring(err) .. "|r"); return
        end
        local dialog = StaticPopup_Show("LLF_IMPORT_CONFIRM")
        if dialog then
            dialog.data = { raw=raw, statusFS=statusFS, importBox=importBox }
        end
    end)
    p.SetY(p.GetY() - ROW_H - SEP)

    p.Finalize()
end

local function BuildBlizzardPanel()
    if _G["LarlenLootFrameBlizzPanel"] then return end
    local GOLD = { 1.00, 0.82, 0.00 }
    local panel = CreateFrame("Frame")
    panel.name = "Larlen Loot Frame"

    local titleFS = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    titleFS:SetPoint("TOPLEFT", 15, -15)
    titleFS:SetText("Larlen Loot Frame"); titleFS:SetTextColor(GOLD[1], GOLD[2], GOLD[3])

    local verFS = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    verFS:SetPoint("TOPLEFT", titleFS, "BOTTOMLEFT", 0, -2)
    verFS:SetText("v" .. (LLF.VERSION or "1.0.0")); verFS:SetTextColor(GREY[1], GREY[2], GREY[3])

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("LEFT", panel, 15, 0); divider:SetPoint("RIGHT", panel, -15, 0)
    divider:SetPoint("TOP", verFS, "BOTTOM", 0, -8)
    divider:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.40)

    local sf = CreateFrame("ScrollFrame", N("SF"), panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     divider, "BOTTOMLEFT",  2,   -6)
    sf:SetPoint("BOTTOMRIGHT", panel,   "BOTTOMRIGHT", -30,  10)

    local CW = 560
    local content = CreateFrame("Frame", N("C"), sf)
    content:SetWidth(CW); sf:SetScrollChild(content)

    local yOff = 0
    local pageFns = { PageGeneral, PageLayout, PagePartyFeed, PageDurations, PagePrice, PageFilters, PageAudio, PageBlacklist, PageWishlist, PageProfiles }
    for _, fn in ipairs(pageFns) do
        local sub = CreateFrame("Frame", N("PS"), content)
        sub:SetPoint("TOPLEFT",  content, 0, yOff)
        sub:SetPoint("TOPRIGHT", content, 0, yOff)
        fn(sub, CW)
        sub:SetHeight(sub:GetHeight() > 0 and sub:GetHeight() or 100)
        yOff = yOff - (sub:GetHeight() + 8)
    end
    content:SetHeight(math.abs(yOff) + 20)
    panel:HookScript("OnShow", RefreshAll)

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Larlen Loot Frame")
    Opt.category = category
    Settings.RegisterAddOnCategory(category)
    _G["LarlenLootFrameBlizzPanel"] = true
end



local floatWin

local function BuildFloatWindow()
    if floatWin then return end

    local WIN_W  = 780
    local WIN_H  = 640
    local SIDE_W = 136

    floatWin = CreateFrame("Frame", "LarlenLootFrameOptions", UIParent, "BackdropTemplate")
    floatWin:SetSize(WIN_W, WIN_H)
    floatWin:SetPoint("CENTER")
    floatWin:SetFrameStrata("DIALOG")
    floatWin:SetMovable(true)
    floatWin:SetResizable(true)
    floatWin:SetResizeBounds(520, 400, 1200, 960)
    floatWin:EnableMouse(true)
    floatWin:RegisterForDrag("LeftButton")
    floatWin:SetScript("OnDragStart", function(f) f:StartMoving() end)
    floatWin:SetScript("OnDragStop",  function(f) f:StopMovingOrSizing() end)
    floatWin:SetBackdrop(WIN_BD)
    floatWin:SetBackdropColor(0.06, 0.06, 0.08, 0.97)
    floatWin:SetBackdropBorderColor(ACCENT[1]*0.35, ACCENT[2]*0.35, ACCENT[3]*0.35, 0.80)
    floatWin:Hide()

    floatWin:HookScript("OnHide", function()
        if activePickerList then activePickerList:Hide(); activePickerList = nil end
    end)

    local headerBar = floatWin:CreateTexture(nil, "BACKGROUND")
    headerBar:SetHeight(52)
    headerBar:SetPoint("TOPLEFT",  floatWin, "TOPLEFT",  1, -1)
    headerBar:SetPoint("TOPRIGHT", floatWin, "TOPRIGHT", -1, -1)
    headerBar:SetColorTexture(0.09, 0.09, 0.13, 1)

    local titleFS = floatWin:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleFS:SetPoint("TOPLEFT", floatWin, "TOPLEFT", 14, -14)
    titleFS:SetText("Larlen Loot Frame")
    titleFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local verFS = floatWin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    verFS:SetPoint("TOPLEFT", titleFS, "BOTTOMLEFT", 0, -1)
    verFS:SetText("v" .. (LLF.VERSION or "1.0.0"))
    verFS:SetTextColor(DIMMER[1], DIMMER[2], DIMMER[3], 1)

    local headerLine = floatWin:CreateTexture(nil, "ARTWORK")
    headerLine:SetHeight(1)
    headerLine:SetPoint("TOPLEFT",  floatWin, "TOPLEFT",  1,  -53)
    headerLine:SetPoint("TOPRIGHT", floatWin, "TOPRIGHT", -1, -53)
    headerLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.40)

    local closeBtn = CreateFrame("Button", nil, floatWin, "BackdropTemplate")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", floatWin, "TOPRIGHT", -10, -14)
    closeBtn:SetBackdrop(FLAT_BD)
    closeBtn:SetBackdropColor(0.10, 0.10, 0.14, 1)
    closeBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    local xFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    xFS:SetPoint("CENTER"); xFS:SetText("×"); xFS:SetTextColor(GREY[1], GREY[2], GREY[3], 1)
    closeBtn:SetScript("OnClick", function() floatWin:Hide() end)
    closeBtn:SetScript("OnEnter", function(s)
        s:SetBackdropColor(0.22, 0.08, 0.08, 1)
        s:SetBackdropBorderColor(0.90, 0.30, 0.30, 0.80)
        xFS:SetTextColor(1, 0.4, 0.4, 1)
    end)
    closeBtn:SetScript("OnLeave", function(s)
        s:SetBackdropColor(0.10, 0.10, 0.14, 1)
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
        xFS:SetTextColor(GREY[1], GREY[2], GREY[3], 1)
    end)

    local sidebar = CreateFrame("Frame", nil, floatWin)
    sidebar:SetPoint("TOPLEFT",    floatWin, "TOPLEFT",    1, -54)
    sidebar:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", 1,   1)
    sidebar:SetWidth(SIDE_W)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints()
    sidebarBg:SetColorTexture(0.07, 0.07, 0.10, 1)

    local sideDiv = floatWin:CreateTexture(nil, "ARTWORK")
    sideDiv:SetWidth(1)
    sideDiv:SetPoint("TOPLEFT",    sidebar, "TOPRIGHT",    0, 0)
    sideDiv:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMRIGHT", 0, 0)
    sideDiv:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.18)

    local sf = CreateFrame("ScrollFrame", N("SF"), floatWin, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     sideDiv,  "TOPRIGHT",    6,    0)
    sf:SetPoint("BOTTOMRIGHT", floatWin, "BOTTOMRIGHT", -22, 42)

    local CONTENT_W = WIN_W - SIDE_W - 1 - 6 - 22 - 12
    local contentHost = CreateFrame("Frame", N("CH"), sf)
    contentHost:SetWidth(CONTENT_W)
    sf:SetScrollChild(contentHost)

    local PAGES = {
        { id="general",      label="General",        fn=PageGeneral        },
        { id="layout",       label="Personal Loot",  fn=PageLayout         },
        { id="partyfeed",    label="Group Loot",     fn=PagePartyFeed      },
        { id="filters",      label="Filters",        fn=PageFilters        },
        { id="durations",    label="Durations",      fn=PageDurations      },
        { id="price",        label="Price",          fn=PagePrice          },
        { id="audio",        label="Audio",           fn=PageAudio          },
        { id="blacklist",    label="Blacklist",       fn=PageBlacklist      },
        { id="wishlist",     label="Wishlist",        fn=PageWishlist       },
        { id="profiles",     label="Profiles",       fn=PageProfiles       },
    }

    local pageFrames  = {}
    local navButtons  = {}
    local currentPage = nil

    for _, pg in ipairs(PAGES) do
        local f = CreateFrame("Frame", N("PF"), contentHost)
        f:SetPoint("TOPLEFT",  contentHost, 0, 0)
        f:SetPoint("TOPRIGHT", contentHost, 0, 0)
        pg.fn(f, CONTENT_W)
        f:Hide()
        pageFrames[pg.id] = f
    end

    local function ShowPage(id)
        if activePickerList then activePickerList:Hide(); activePickerList = nil end
        for _, f in pairs(pageFrames) do f:Hide() end
        local f = pageFrames[id]
        if f then
            f:Show()
            contentHost:SetHeight(f:GetHeight())
            sf:SetVerticalScroll(0)
        end
        currentPage = id
        for _, nb in ipairs(navButtons) do
            local sel = (nb._pageId == id)
            nb._bg:SetColorTexture(
                sel and ACCENT[1]*0.18 or 0.00,
                sel and ACCENT[2]*0.18 or 0.00,
                sel and ACCENT[3]*0.18 or 0.00,
                sel and 1 or 0)
            nb._bar:SetShown(sel)
            nb._fs:SetTextColor(
                sel and WHITE[1] or GREY[1],
                sel and WHITE[2] or GREY[2],
                sel and WHITE[3] or GREY[3], 1)
        end
        RefreshAll()
    end

    local BTN_X = SIDE_W + 1 + 6 + 10

    local durResetBtn = MakeBtn(floatWin, "Reset to Defaults", 130, ROW_H)
    durResetBtn:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", BTN_X, 10)
    durResetBtn:SetScript("OnClick", function()
        local defs = LLF.Config.DEFAULTS
        for k, v in pairs(defs.durations) do LLF.db.durations[k] = v end
        for k, v in pairs(defs.groupDurations) do LLF.db.groupDurations[k] = v end
        RefreshAll()
    end)
    durResetBtn:Hide()

    local filtResetBtn = MakeBtn(floatWin, "Reset to Defaults", 130, ROW_H)
    filtResetBtn:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", BTN_X, 10)
    filtResetBtn:SetScript("OnClick", function()
        local defs = LLF.Config.DEFAULTS
        for k, v in pairs(defs.personalFilters.filterRarity) do LLF.db.personalFilters.filterRarity[k] = v end
        LLF.db.personalFilters.filterRep      = defs.personalFilters.filterRep
        LLF.db.personalFilters.filterGuildRep = defs.personalFilters.filterGuildRep
        LLF.db.personalFilters.filterPets     = defs.personalFilters.filterPets
        LLF.db.personalFilters.filterMounts   = defs.personalFilters.filterMounts
        LLF.db.personalFilters.filterHousing  = defs.personalFilters.filterHousing
        for k, v in pairs(defs.groupFilters.filterRarity) do LLF.db.groupFilters.filterRarity[k] = v end
        local pdf = LLF.db.partyFeed
        local dpdf = defs.partyFeed
        if pdf and dpdf then
            pdf.filterPets   = dpdf.filterPets
            pdf.filterMounts = dpdf.filterMounts
        end
        local ef = _G["LarlenLootFrameEventFrame"]
        if ef then
            if defs.personalFilters.filterRep then ef:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
            else ef:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE") end
        end
        RefreshAll()
    end)
    filtResetBtn:Hide()

    local priceResetBtn = MakeBtn(floatWin, "Reset to Defaults", 130, ROW_H)
    priceResetBtn:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", BTN_X, 10)
    priceResetBtn:SetScript("OnClick", function()
        local defs = LLF.Config.DEFAULTS
        LLF.db.showVendorPrice  = defs.showVendorPrice
        LLF.db.showStackPrice   = defs.showStackPrice
        LLF.db.showAHPrice      = defs.showAHPrice
        LLF.db.showJunkAH       = defs.showJunkAH
        LLF.db.priceFormat      = defs.priceFormat
        LLF.db.glowEnabled   = defs.glowEnabled
        LLF.db.glowMode      = defs.glowMode
        LLF.db.glowType      = defs.glowType
        LLF.db.glowLines     = defs.glowLines
        LLF.db.glowSpeed     = defs.glowSpeed
        LLF.db.glowThickness = defs.glowThickness
        LLF.db.glowTiers = {}
        for _, t in ipairs(LLF.Config.DEFAULT_GLOW_TIERS) do
            LLF.db.glowTiers[#LLF.db.glowTiers + 1] = {
                threshold = t.threshold,
                color = { t.color[1], t.color[2], t.color[3] },
            }
        end
        if LLF.Options._rebuildGlowTiers then LLF.Options._rebuildGlowTiers() end
        if ApplyGlowGating then ApplyGlowGating() end
        RefreshAll()
    end)
    priceResetBtn:Hide()

    local blClearAllBtn = MakeBtn(floatWin, "Clear All", 80, ROW_H)
    blClearAllBtn:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", BTN_X, 10)
    blClearAllBtn:SetScript("OnClick", function()
        if LLF.db and LLF.db.blacklist then
            wipe(LLF.db.blacklist)
            
            if LLF.Options._blRebuild then LLF.Options._blRebuild() end
            RefreshAll()
        end
    end)
    blClearAllBtn:Hide()

    local wlClearAllBtn = MakeBtn(floatWin, "Clear All", 80, ROW_H)
    wlClearAllBtn:SetPoint("BOTTOMLEFT", floatWin, "BOTTOMLEFT", BTN_X, 10)
    wlClearAllBtn:SetScript("OnClick", function()
        if LLF.db and LLF.db.wishlist then
            wipe(LLF.db.wishlist)
            
            if LLF.Options._wlRebuild then LLF.Options._wlRebuild() end
            RefreshAll()
        end
    end)
    wlClearAllBtn:Hide()

    local _origShowPage = ShowPage
    ShowPage = function(id)
        _origShowPage(id)
        durResetBtn:SetShown(id == "durations")
        filtResetBtn:SetShown(id == "filters")
        priceResetBtn:SetShown(id == "price")
        blClearAllBtn:SetShown(id == "blacklist")
        wlClearAllBtn:SetShown(id == "wishlist")
    end

    local NAV_H = 36
    for i, pg in ipairs(PAGES) do
        local btn = CreateFrame("Button", N("NB"), sidebar)
        btn:SetHeight(NAV_H)
        btn:SetPoint("TOPLEFT",  sidebar, "TOPLEFT",  0, -(i-1)*NAV_H)
        btn:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, -(i-1)*NAV_H)
        btn._pageId = pg.id

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(0, 0, 0, 0); btn._bg = bg

        local bar = btn:CreateTexture(nil, "ARTWORK")
        bar:SetWidth(3)
        bar:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0, 0)
        bar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        bar:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        bar:Hide(); btn._bar = bar

        local sep = btn:CreateTexture(nil, "ARTWORK")
        sep:SetHeight(1)
        sep:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  0, 0)
        sep:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
        sep:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.08)

        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("LEFT", btn, 16, 0)
        fs:SetJustifyH("LEFT"); fs:SetText(pg.label)
        fs:SetTextColor(GREY[1], GREY[2], GREY[3], 1)
        btn._fs = fs

        btn:SetScript("OnClick", function() ShowPage(pg.id) end)
        btn:SetScript("OnEnter", function()
            if currentPage ~= pg.id then
                bg:SetColorTexture(ACCENT[1]*0.10, ACCENT[2]*0.10, ACCENT[3]*0.10, 1)
                fs:SetTextColor(WHITE[1]*0.85, WHITE[2]*0.85, WHITE[3]*0.85, 1)
            end
        end)
        btn:SetScript("OnLeave", function()
            if currentPage ~= pg.id then
                bg:SetColorTexture(0, 0, 0, 0)
                fs:SetTextColor(GREY[1], GREY[2], GREY[3], 1)
            end
        end)

        navButtons[i] = btn
    end

    local grip = CreateFrame("Button", nil, floatWin)
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", floatWin, "BOTTOMRIGHT", -4, 4)
    grip:EnableMouse(true)
    grip:RegisterForDrag("LeftButton")
    for row = 1, 3 do
        for col = 1, (4 - row) do
            local dot = grip:CreateTexture(nil, "OVERLAY")
            dot:SetSize(2, 2)
            dot:SetPoint("BOTTOMRIGHT", grip, "BOTTOMRIGHT",
                -1 - (col-1)*5, 1 + (row-1)*5)
            dot:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.50)
        end
    end
    grip:SetScript("OnDragStart", function() floatWin:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnDragStop",  function() floatWin:StopMovingOrSizing() end)

    floatWin:HookScript("OnShow", function()
        ShowPage(currentPage or "general")
    end)
    floatWin:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)
    floatWin:EnableKeyboard(true)
end


function Opt:Init()
    BuildBlizzardPanel()
    BuildFloatWindow()
end

function Opt:Open()
    if self.category then Settings.OpenToCategory(self.category.ID) end
end

function Opt:Toggle()
    BuildFloatWindow()
    if floatWin:IsShown() then floatWin:Hide() else floatWin:Show() end
end

function Opt:Close()
    if floatWin then floatWin:Hide() end
end
