-- PCCraftingRecord Object Definition
PCCraftingRecord = {
    crafter = "",
    item = "",
    numCrafts = 1,
    amountCrafted = 0
 }
---------------------------

-- PCCraftingRecord Methods
function PCCraftingRecord:getCrafter()
    return self.crafter
end

function PCCraftingRecord:increaseNumCrafts()
    self.numCrafts = self.numCrafts + 1
end

function PCCraftingRecord:increaseAmountCrafted(amount)
    self.amountCrafted = self.amountCrafted + amount
end

function PCCraftingRecord:getPrintableFormat()
    local bonusItems = self.amountCrafted - self.numCrafts
    local procRate = string.format("%.2f",(bonusItems / self.numCrafts) * 100)
    return self.crafter.." made "..self.amountCrafted.." "..self.item.." in "..self.numCrafts.." crafts.\nProc Rate: "..procRate.."%\nNumber of bonus items: "..bonusItems
end

function PCCraftingRecord:printToParty()
    local bonusItems = self.amountCrafted - self.numCrafts
    local procRate = string.format("%.2f",(bonusItems / self.numCrafts) * 100)
    SendChatMessage(self.crafter.." made "..self.amountCrafted.." "..self.item.." in "..self.numCrafts.." crafts.", "PARTY")
    SendChatMessage("Proc Rate: "..procRate.."%", "PARTY")
    SendChatMessage("Number of bonus items: "..bonusItems, "PARTY")
end

function PCCraftingRecord:printToRaid()
    local bonusItems = self.amountCrafted - self.numCrafts
    local procRate = string.format("%.2f",(bonusItems / self.numCrafts) * 100)
    SendChatMessage(self.crafter.." made "..self.amountCrafted.." "..self.item.." in "..self.numCrafts.." crafts.", "RAID")
    SendChatMessage("Proc Rate: "..procRate.."%", "RAID")
    SendChatMessage("Number of bonus items: "..bonusItems, "RAID")
end
---------------------------

-- PCCraftingRecord Constructor
function PCCraftingRecord:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
    return t
end
--------------------------------