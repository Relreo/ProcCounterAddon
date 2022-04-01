-- PCCraftingRecord Object Definition
PCCraftingRecord = {
    crafter = "",
    item = "",
    numCrafts = 1,
    amountCrafted = 0
 }
---------------------------

-- PCCraftingRecord Methods
function PCCraftingRecord:increaseNumCrafts()
    self.numCrafts = self.numCrafts + 1
end

function PCCraftingRecord:increaseAmountCrafted(amount)
    self.amountCrafted = self.amountCrafted + amount
end

function PCCraftingRecord:getPrintableFormat()
    local bonusItems = self.amountCrafted - self.numCrafts
    local procRate = string.format("%.2f",(bonusItems / self.numCrafts) * 100)
    return self.crafter.." made "..self.amountCrafted.." "..self.item.."s in "..self.numCrafts.." crafts.\nProc Rate: "..procRate.."%\nNumber of bonus items: "..bonusItems
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