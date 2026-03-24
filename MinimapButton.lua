local LLF = LarlenLootFrame
LLF.Minimap = {}
local MB = LLF.Minimap

local _ldb_data = {
    type  = "launcher",
    label = "Larlen Loot Frame",
    icon  = 133650,

    OnClick = function(_, btn)
        if btn == "LeftButton" then
            LLF.Options:Toggle()
        elseif btn == "RightButton" then
            LLF.db.showMinimap = false
            MB:ApplyVisibility()
            print("|cff32bff7LLF:|r Minimap icon |cffff4444hidden|r.  Type |cffffff00/llf minimap|r to restore.")
        end
    end,

    OnTooltipShow = function(tt)
        tt:AddLine("Larlen Loot Frame", 0.196, 0.765, 0.765)
        tt:AddLine(" ")
        tt:AddLine("|cffffff00Left-Click|r to open options.", 1, 1, 1)
        tt:AddLine("|cffffff00Right-Click|r to hide this button.", 1, 1, 1)
        tt:AddLine("|cffffff00Drag|r to move around the minimap.", 1, 1, 1)
    end,
}

local ldb = LibStub("LibDataBroker-1.1"):GetDataObjectByName("Larlen Loot Frame")
         or LibStub("LibDataBroker-1.1"):NewDataObject("Larlen Loot Frame", _ldb_data)

if ldb then
    ldb.OnClick       = _ldb_data.OnClick
    ldb.OnTooltipShow = _ldb_data.OnTooltipShow
    ldb.icon          = _ldb_data.icon
end

MB.ldb  = ldb
MB.ldbi = LibStub("LibDBIcon-1.0")

function MB:Register()
    LLF.db.minimapIcon = LLF.db.minimapIcon or {}
    if not LLF.db.minimapIcon.minimapPos then
        LLF.db.minimapIcon.minimapPos = 225
    end
    LLF.db.minimapIcon.hide = not (LLF.db.showMinimap ~= false)
    C_Timer.After(0, function()
        if not MB.ldbi:IsRegistered("Larlen Loot Frame") then
            MB.ldbi:Register("Larlen Loot Frame", MB.ldb, LLF.db.minimapIcon)
        end
        MB:ApplyVisibility()
    end)
end

function MB:ApplyVisibility()
    if not self.ldbi:IsRegistered("Larlen Loot Frame") then return end
    if LLF.db.showMinimap ~= false then
        LLF.db.minimapIcon.hide = false
        self.ldbi:Show("Larlen Loot Frame")
    else
        LLF.db.minimapIcon.hide = true
        self.ldbi:Hide("Larlen Loot Frame")
    end
end

function MB:Toggle()
    LLF.db.showMinimap = not (LLF.db.showMinimap ~= false)
    self:ApplyVisibility()
    if LLF.db.showMinimap ~= false then
        print("|cff32bff7LLF:|r Minimap icon |cff55dd55shown|r.")
    else
        print("|cff32bff7LLF:|r Minimap icon |cffff4444hidden|r.  Type |cffffff00/llf minimap|r to restore.")
    end
end
