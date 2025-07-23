local UIItemBase = require("UI/Common/UIItemBase")
local Act10DaySignItem = class("Act10DaySignItem", UIItemBase)

function Act10DaySignItem:OnInit()
end

function Act10DaySignItem:OnFreshData()
  self.m_day = self.m_itemData.day
  self.m_itemInfo = self.m_itemData.rewardInfo
  self.m_rewardState = self.m_itemData.state
  self.m_maxDay = self.m_itemData.maxRewardDay
  self.m_iSignNum = self.m_itemData.iSignNum
  self:RefreshUI()
end

function Act10DaySignItem:RefreshUI()
  UILuaHelper.SetActive(self.m_img_bg_lock, self.m_rewardState == ActivityManager.SignCannotTaken)
  UILuaHelper.SetActive(self.m_img_bg_unlock, self.m_rewardState == ActivityManager.SignTaken)
  UILuaHelper.SetActive(self.m_mask_skin, self.m_day == self.m_maxDay)
  UILuaHelper.SetActive(self.m_pnl_left, self.m_day ~= 1)
  UILuaHelper.SetActive(self.m_img_bg_unlockline_l, self.m_day ~= 1 and self.m_day <= self.m_iSignNum)
  self.m_txt_receivenum_Text.text = tostring(self.m_day)
  local itemWidgetIcon = self:createCommonItem(self.m_item_reward)
  itemWidgetIcon:SetItemInfo(self.m_itemInfo)
  itemWidgetIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
end

function Act10DaySignItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return Act10DaySignItem
