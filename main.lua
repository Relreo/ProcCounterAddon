print("ProcCounter by Relreo loaded.")

local maxNumRecords = 100
local records = {}

----------------- Helper functions
-- MESSAGE FORMAT ---> {Name} create(s): [{ItemName}]{multiplier}.
-- Examples: 
-- Deathwind creates: [Elixir of Draenic Wisdom]x3.
-- You create: [Haste Potion]x5.
local function extractUsername(message)
    i, _ = string.find(message, " ")
    return string.sub(message, 1, i-1)
end

local function extractItemFromLoot(message)
    s, _ = string.find(message, "%[")
    e, _ = string.find(message, "%]")
    return string.sub(message, s+1, e-1)
end

local function extractMultiplierFromLoot(message)
    _, e = string.find(message, "%]x")
    if e then
        return tonumber(string.sub(message, e+1, e+1))
    else
        return 1
    end
end

local function extractItemFromTradeskill(message)
    _, e = string.find(message, "creates")
    if e then
        return string.sub(message, e+2, string.len(message)-1)
    else
        _, e = string.find(message, "create")
        return string.sub(message, e+2, string.len(message)-1)
    end
end

local function searchRecords(playerName, itemName)
    local numRecords = table.getn(records)
    if numRecords > 0 then
        local record
        for i = 1, numRecords do
            record = records[i]
            if record and record.crafter == playerName and record.item == itemName then
                return record
            end
        end
    end
    return nil
end

local function addRecord(record)
    local numRecords = table.getn(records)
    if numRecords < maxNumRecords then
        table.insert(records, record)
    else
        table.remove(records, 1)
        table.insert(records, record)
    end
end

local function clearRecords()
    for k in pairs (records) do
        table.remove(records, k)
    end
end
-------------------

--EventHandler: Where Data is taken from the game
local frame = CreateFrame('Frame', 'ProcCounterFrame', UIParent)
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_TRADESKILLS")
frame:SetScript("OnEvent", function (self, event, ...) 
    local text, playerName, itemName, searchResult, procMultiplier
    if event == "CHAT_MSG_LOOT" then
        text, _, _, _, playerName = ...
        if string.find(text, "Elixir") or string.find(text, "Flask") or string.find(text, "Bandage") then
            itemName = extractItemFromLoot(text)
            procMultiplier = extractMultiplierFromLoot(text)
            searchResult = searchRecords(playerName, itemName)
            if searchResult then
                searchResult:increaseAmountCrafted(procMultiplier)
            else
                addRecord(PCCraftingRecord:new({
                    crafter = playerName,
                    item = itemName,
                    amountCrafted = procMultiplier
                }))
            end
        end
    elseif event == "CHAT_MSG_TRADESKILLS" then
        text = ...
        playerName = extractUsername(text)
        if playerName == "You" then
            playerName = UnitName('player')
        end
        itemName = extractItemFromTradeskill(text)
        searchResult = searchRecords(playerName, itemName)
        if searchResult then
            print("Search Result Found. Increasing Number of Crafts")
            searchResult:increaseNumCrafts()
        end
    else
        return
    end
end)

SLASH_PROCCOUNTER1 = "/pcreport"
SlashCmdList["PROCCOUNTER"] = function (msg) 
    numRecords = table.getn(records)
    if numRecords > 0 then
        for i = 1, numRecords do
            print(records[i]:getPrintableFormat())
        end
    end
end