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
    _, e = string.find(message, "x%d")
    if e then
        return tonumber(string.sub(message, e, e))
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
--local test = extractMultiplierFromLoot("You create: [Super Mana Potion]x2.")
--print(test)
--print(test+5)
--EventHandler: Where Data is taken from the game
local frame = CreateFrame('Frame', 'ProcCounterFrame', UIParent)
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_TRADESKILLS")
frame:SetScript("OnEvent", function (self, event, ...) 
    local text, playerName, itemName, searchResult, procMultiplier
    if event == "CHAT_MSG_LOOT" then
        text, _, _, _, playerName = ...
        if (not string.find(text, "create")) then return
        end
        if string.find(text, "Elixir") or string.find(text, "Flask") or string.find(text, "Potion") or string.find(text, "Bandage") or string.find(text, "Arthas") then
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
            searchResult:increaseNumCrafts()
        end
    else
        return
    end
end)

local errorText = "Invalid Command. Target someone or use /pcr [Player Name] or /pcreport [Player Name]."
-- Slash command to report results in chat for user. If a player name is included it filters results to only that player's crafts
SLASH_PROCCOUNTER1 = "/pcreport"
SLASH_PROCCOUNTER2 = "/pcr"
SlashCmdList["PROCCOUNTER"] = function (msg) 
    local target = UnitName("target")
    numRecords = table.getn(records)
    if numRecords > 0 then
        local matchFound = false
        for i = 1, numRecords do
            if msg ~= '' and string.lower(records[i]:getCrafter()) == string.lower(msg) then 
                matchFound = true
                print(records[i]:getPrintableFormat())
            elseif target and msg == '' and string.lower(records[i]:getCrafter()) == string.lower(target) then
                matchFound = true
                print(records[i]:getPrintableFormat())
            elseif msg == '' and not target then
                matchFound = true
                print(records[i]:getPrintableFormat())
            else
            end
        end

        if not matchFound then print(errorText) end

    else
        print("Proc Counter: NO DATA FOUND")
    end
end