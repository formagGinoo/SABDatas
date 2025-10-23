local UIItemBase = require("UI/Common/UIItemBase")
local UIRechargeCommonItem = class("UIRechargeCommonItem", UIItemBase)

function UIRechargeCommonItem:OnInit()
  self.m_itemWidget = self:createCommonItem(self.m_common_item)
  self.m_itemWidget:SetItemIconClickCB(handler(self, self.OnCommonItemClick))
end

function UIRechargeCommonItem:OnFreshData()
  self.m_rewardItemData = self.m_itemData
  if not self.m_rewardItemData then
    return
  end
  self:FreshItemUI()
end

function UIRechargeCommonItem:FreshItemUI()
  if not self.m_rewardItemData then
    return
  end
  local itemID = self.m_rewardItemData.iID
  local itemNum = self.m_rewardItemData.iNum
  local processData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = itemNum})
  self.m_itemWidget:SetItemInfo(processData)
  local itemType = ResourceUtil:GetResourceTypeById(itemID)
  local isSkin = itemType == ResourceUtil.RESOURCE_TYPE.Fashion
  UILuaHelper.SetActive(self.m_img_skin, isSkin)
end

function UIRechargeCommonItem:FreshStatus(isHaveGet, isCanGet)
  if not self.m_rewardItemData then
    return
  end
  UILuaHelper.SetActive(self.m_item_can_get, isCanGet == true and isHaveGet == false)
  UILuaHelper.SetActive(self.m_item_have_get, isHaveGet == true)
end

function UIRechargeCommonItem:OnCommonItemClick()
  if not self.m_rewardItemData then
    return
  end
  utils.openItemDetailPop({
    iID = self.m_rewardItemData.iID,
    iNum = self.m_rewardItemData.iNum
  })
end

return UIRechargeCommonItem
