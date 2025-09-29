local UIItemBase = require("UI/Common/UIItemBase")
local Activity110_DetailItem = class("Activity110_DetailItem", UIItemBase)

function Activity110_DetailItem:OnInit()
end

function Activity110_DetailItem:OnFreshData()
  local itemWidget = self:createCommonItem(self.m_itemRootObj)
  local itemData = self.m_itemData.rewardData
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = tonumber(itemData[1]),
    iNum = tonumber(itemData[2])
  })
  processItemData.is_have_get = self.m_itemData.is_have_get
  itemWidget:SetItemInfo(processItemData)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    if not itemID then
      return
    end
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

return Activity110_DetailItem
