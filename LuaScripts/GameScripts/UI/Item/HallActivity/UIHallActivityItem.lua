local UIItemBase = require("UI/Common/UIItemBase")
local UIHallActivityItem = class("UIHallActivityItem", UIItemBase)

function UIHallActivityItem:OnInit()
  self.m_stageRewardList = {}
end

function UIHallActivityItem:OnFreshData()
  self:SetStageInfo(self.m_itemData)
end

function UIHallActivityItem:SetStageInfo(itemData)
  local systemInfo = itemData.systemInfo
  local activityInfo = itemData.activityInfo
  local redPoint = itemData.redPoint
  self.m_txt_activity_name_Text.text = systemInfo.m_mName
  UILuaHelper.SetAtlasSprite(self.m_img_card_activity_Image, activityInfo.m_Img)
  local isOpen = UnlockSystemUtil:IsSystemOpen(activityInfo.m_SystemID)
  UILuaHelper.SetActive(self.m_pnl_name_b, not isOpen)
  UILuaHelper.SetActive(self.m_red_dot, redPoint and 0 < redPoint)
  UILuaHelper.SetActive(self.m_pnl_name_a, isOpen)
end

return UIHallActivityItem
