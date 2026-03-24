local LLF = {}
LLF.VERSION = "1.0.3"
LarlenLootFrame = LLF

function LLF.IsAddonLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    return _G.IsAddOnLoaded and _G.IsAddOnLoaded(name) or false
end

function LarlenLootFrame_OnCompartmentClick(_, btn)
    if btn == "LeftButton" then LarlenLootFrame.Options:Toggle() end
end
