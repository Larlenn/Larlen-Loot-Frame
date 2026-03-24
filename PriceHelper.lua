local LLF = LarlenLootFrame
LLF.Price = {}
local Price = LLF.Price

local IsAddonLoaded = LLF.IsAddonLoaded

local _parts = {}

local function FormatSmall(copper)
    local s = math.floor(copper / 100) % 100
    local c = copper % 100
    if s > 0 then
        return "|cffb0b0b0" .. s .. "s|r |cffd17c4b" .. string.format("%02d", c) .. "c|r"
    elseif c > 0 then
        return "|cffd17c4b" .. c .. "c|r"
    end
    return ""
end

local function FormatFull(copper)
    local g = math.floor(copper / 10000)
    local s = math.floor(copper / 100) % 100
    local c = copper % 100
    local parts = _parts; wipe(parts)
    if g > 0 then
        parts[#parts+1] = "|cffffff00" .. g .. "g|r"
        if g < 1000 then
            parts[#parts+1] = "|cffb0b0b0" .. string.format("%02d", s) .. "s|r"
            parts[#parts+1] = "|cffd17c4b" .. string.format("%02d", c) .. "c|r"
        end
    else
        return FormatSmall(copper)
    end
    return table.concat(parts, " ")
end

local function FormatGoldOnly(copper)
    local g = math.floor(copper / 10000)
    if g > 0 then return "|cffffff00" .. g .. "g|r" end
    return FormatSmall(copper)
end

local function FormatShort(copper, suffix)
    local g = copper / 10000
    local su = suffix or ""
    if g >= 1000000 then
        return "|cffffff00" .. string.format("%.1fM", g / 1000000) .. su .. "|r"
    elseif g >= 1000 then
        return "|cffffff00" .. string.format("%.1fk", g / 1000) .. su .. "|r"
    elseif g >= 1 then
        return "|cffffff00" .. math.floor(g) .. su .. "|r"
    end
    return FormatSmall(copper)
end

function Price:FormatAuto(copper)
    if type(copper) ~= "number" or copper <= 0 then return "" end
    local fmt = LLF.db and LLF.db.priceFormat or 1
    if fmt == 2 then return FormatGoldOnly(copper) end
    if fmt == 3 then return FormatShort(copper, "")  end
    if fmt == 4 then return FormatShort(copper, "g") end
    return FormatFull(copper)
end

function Price:HasAHData()
    local db = LLF.db
    if not db or not db.showAHPrice then return false end
    local addon = db.auctionAddon or 1
    if addon == 1 then
        return IsAddonLoaded("Auctionator") and Auctionator ~= nil and Auctionator.API ~= nil
    elseif addon == 2 then
        return IsAddonLoaded("TradeSkillMaster")
            and TSM_API and TSM_API.GetCustomPriceValue ~= nil
    end
    return false
end

function Price:GetAHValue(link)
    if not link or not self:HasAHData() then return nil end
    local db    = LLF.db
    local addon = db.auctionAddon or 1

    local cleanLink = select(2, C_Item.GetItemInfo(link)) or link

    if addon == 1 then
        local api = Auctionator.API.v1
        if not api then return nil end
        local fn = api.GetAuctionPriceByItemLink
        if not fn then return nil end
        local ok, val = pcall(fn, "LarlenLootFrame", cleanLink)
        return (ok and type(val) == "number" and val > 0) and val or nil

    elseif addon == 2 then
        local id = cleanLink:match("item:(%d+)")
        if not id then return nil end
        local key = (db.tsmSource == 2) and "dbminbuyout" or "dbmarket"
        local ok, val = pcall(function()
            return TSM_API.GetCustomPriceValue(key, "i:" .. id)
        end)
        return (ok and type(val) == "number" and val > 0) and val or nil
    end
end

function Price:DebugAH(link)
    local db = LLF.db
    local p = "|cff32bff7LLF AH Debug:|r "
    print(p .. "showAHPrice=" .. tostring(db.showAHPrice) .. " auctionAddon=" .. tostring(db.auctionAddon))
    print(p .. "Auctionator global=" .. tostring(Auctionator ~= nil))
    if Auctionator then
        print(p .. "Auctionator.API=" .. tostring(Auctionator.API ~= nil))
        if Auctionator.API then
            print(p .. "Auctionator.API.v1=" .. tostring(Auctionator.API.v1 ~= nil))
            if Auctionator.API.v1 then
                local fn = Auctionator.API.v1.GetAuctionPriceByItemLink
                print(p .. "GetAuctionPriceByItemLink=" .. tostring(fn ~= nil))
                if fn and link then
                    local cleanLink = select(2, C_Item.GetItemInfo(link)) or link
                    print(p .. "raw link:   " .. tostring(link))
                    print(p .. "clean link: " .. tostring(cleanLink))
                    local ok, val = pcall(fn, "LarlenLootFrame", cleanLink)
                    print(p .. "pcall(fn, name, cleanLink): ok=" .. tostring(ok) .. " val=" .. tostring(val))
                end
            end
        end
    end
    print(p .. "HasAHData=" .. tostring(self:HasAHData()))
    if link then
        print(p .. "GetAHValue result=" .. tostring(self:GetAHValue(link)))
    end
end
