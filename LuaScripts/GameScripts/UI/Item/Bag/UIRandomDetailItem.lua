local UIItemBase = require("UI/Common/UIItemBase")
local UIRandomDetailItem = class("UIRandomDetailItem", UIItemBase)

function UIRandomDetailItem:OnInit()
end

function UIRandomDetailItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIRandomDetailItem:SetItemInfo(itemData)
  if not itemData.isLock and itemData.iHeroId ~= 0 then
    if self.m_itemIcon == nil then
      self.m_itemIcon = self:createCommonItem(self.m_common_item)
    end
    local processItemData = ResourceUtil:GetProcessRewardData(itemData)
    self.m_itemIcon:SetItemInfo(processItemData)
    self.m_itemIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClick(itemID, itemNum, itemCom)
    end)
  end
  self.m_txt_rate_Text.text = string.format(ConfigManager:GetCommonTextById(100009), math.floor(itemData.iWeight * 10000) / 100)
end

function UIRandomDetailItem:OnItemClick(itemId, itemNum)
end

return UIRandomDetailItem
