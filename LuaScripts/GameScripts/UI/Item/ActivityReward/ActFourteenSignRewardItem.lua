local UIItemBase = require("UI/Common/UIItemBase")
local ActFourteenSignRewardItem = class("ActFourteenSignRewardItem", UIItemBase)

function ActFourteenSignRewardItem:OnInit()
  self.c_img_bg_normal = self.m_itemTemplateCache:GameObject("c_img_bg_normal")
  self.c_txt_receivenum = self.m_itemTemplateCache:TMPPro("c_txt_receivenum")
  self.c_img_bg_fourteennormal = self.m_itemTemplateCache:GameObject("c_img_bg_fourteennormal")
  self.c_txt_receivenum02 = self.m_itemTemplateCache:TMPPro("c_txt_receivenum02")
  self.c_item_reward = self.m_itemTemplateCache:GameObject("c_item_reward")
  self.c_img_bg_received_mask = self.m_itemTemplateCache:GameObject("c_img_bg_received_mask")
  self.c_txt_receivenumObj = self.m_itemTemplateCache:GameObject("c_txt_receivenum")
  self.c_txt_receivenum02Obj = self.m_itemTemplateCache:GameObject("c_txt_receivenum02")
end

function ActFourteenSignRewardItem:OnFreshData()
  self.day = self.m_itemData.Day
  self.itemInfo = self.m_itemData.rewardInfo
  self.rewardState = self.m_itemData.state
  self.maxDay = self.m_itemData.maxRewarDay
  self:RefreshUI()
end

function ActFourteenSignRewardItem:RefreshUI()
  local tempNorBg = self.c_img_bg_normal
  if self.day == self.maxDay then
    tempNorBg = self.c_img_bg_fourteennormal
  end
  UILuaHelper.SetActive(self.c_txt_receivenumObj, self.day ~= self.maxDay)
  UILuaHelper.SetActive(self.c_txt_receivenum02Obj, self.day == self.maxDay)
  UILuaHelper.SetActive(tempNorBg, true)
  UILuaHelper.SetActive(self.c_img_bg_received_mask, self.rewardState == ActivityManager.SignTaken)
  self.c_txt_receivenum.text = tostring(self.day)
  self.c_txt_receivenum02.text = tostring(self.day)
  local itemWidgetIcon = self:createCommonItem(self.c_item_reward)
  itemWidgetIcon:SetItemInfo(self.itemInfo)
  itemWidgetIcon:SetItemHaveGetActive(false)
  itemWidgetIcon:SetItemIconClickCB(handler(self, self.ShowItemTips))
end

function ActFourteenSignRewardItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function ActFourteenSignRewardItem:OnItemClicked()
end

return ActFourteenSignRewardItem
