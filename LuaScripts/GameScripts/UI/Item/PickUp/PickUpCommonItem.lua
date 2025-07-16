local UIItemBase = require("UI/Common/UIItemBase")
local PickUpCommonItem = class("PickUpCommonItem", UIItemBase)

function PickUpCommonItem:OnInit()
  self.m_itemIcon = self:createCommonItem(self.m_itemTemplateCache:GameObject("c_common_item"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_itemIcon:SetItemIconLongPress(handler(self, self.OnItemLongClk))
end

function PickUpCommonItem:OnFreshData()
  local cfg = self.m_itemData
  local processData = ResourceUtil:GetProcessRewardData(cfg)
  self.m_itemIcon:SetItemInfo(processData)
  local isChoose = false
  if cfg.chooseIdx then
    isChoose = cfg.chooseIdx + 1 == self.m_itemIndex
  end
  self.m_itemIcon:SetItemHaveGetActive(isChoose)
end

function PickUpCommonItem:OnItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemRootObj, self.m_itemIcon)
  end
end

function PickUpCommonItem:OnItemLongClk(itemID, itemNum)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return PickUpCommonItem
