local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroTrialRewardItem = class("UIHeroTrialRewardItem", UIItemBase)

function UIHeroTrialRewardItem:OnInit()
end

function UIHeroTrialRewardItem:OnFreshData()
  local itemWidget = self:createCommonItem(self.m_itemRootObj)
  local itemData = self.m_itemData.rewardData
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = tonumber(itemData[1]),
    iNum = tonumber(itemData[2])
  }, {
    is_have_get = self.m_itemData.isHaveGet
  })
  itemWidget:SetItemInfo(processItemData)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    if not itemID then
      return
    end
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

return UIHeroTrialRewardItem
