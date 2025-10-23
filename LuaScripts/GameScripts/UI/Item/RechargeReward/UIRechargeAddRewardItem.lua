local UIItemBase = require("UI/Common/UIItemBase")
local UIRechargeAddRewardItem = class("UIRechargeAddRewardItem", UIItemBase)

function UIRechargeAddRewardItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  local buttonExtension = self.m_btn_First_Reward:GetComponent("ButtonExtensions")
  if buttonExtension then
    buttonExtension.Clicked = handler(self, self.OnBtnFirstRewardClicked)
  end
  self.m_rewardMulItemList = self:CreateCloneMulItemList(self.m_mul_Reward_Root, self.m_reward_base, "RechargeReward/UIRechargeCommonItem")
  self.m_activity = nil
end

function UIRechargeAddRewardItem:OnFreshData()
  self.m_rewardCfgData = self.m_itemData
  if not self.m_rewardCfgData then
    return
  end
  self.m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_CountConsume)
  if not self.m_activity then
    return
  end
  self:FreshItemUI()
end

function UIRechargeAddRewardItem:FreshItemUI()
  if not self.m_rewardCfgData then
    return
  end
  if not self.m_activity then
    return
  end
  self.m_rewardMulItemList:ShowItemList(self.m_rewardCfgData.vReward)
  self:FreshStatus()
end

function UIRechargeAddRewardItem:FreshStatus()
  if not self.m_rewardCfgData then
    return
  end
  if not self.m_activity then
    return
  end
  local id = self.m_rewardCfgData.iId
  local isHaveGet = self.m_activity:CheckRewardIsGet(id)
  local isCanGet = self.m_activity:IsPointRewardCanGet(id)
  UILuaHelper.SetActive(self.m_img_itembg_add, isHaveGet ~= true and isCanGet ~= true)
  UILuaHelper.SetActive(self.m_node_have_get, isHaveGet == true)
  UILuaHelper.SetActive(self.m_node_can_get, isCanGet == true)
  UILuaHelper.SetActive(self.m_btn_First_Reward, isCanGet == true and isHaveGet ~= true)
  local allShowItemList = self.m_rewardMulItemList:GetAllShownItemList()
  for i, v in ipairs(allShowItemList) do
    v:FreshStatus(isHaveGet, isCanGet)
  end
  local conditionScore = self.m_rewardCfgData.iNeedPoint
  self.m_txt_limit_score_Text.text = conditionScore
  UILuaHelper.SetActive(self.m_img_thumb, isHaveGet ~= true and isCanGet ~= true)
  UILuaHelper.SetActive(self.m_img_thumbsel, isCanGet == true or isHaveGet == true)
  local colorIndex = isCanGet ~= true and isHaveGet ~= true and 0 or 1
  UILuaHelper.SetColorByMultiIndex(self.m_txt_limit_score_Text, colorIndex)
  UILuaHelper.SetActive(self.m_fx_rechargereward, false)
end

function UIRechargeAddRewardItem:FreshLineStatus(isShow, isMax)
  if not self.m_rewardCfgData then
    return
  end
  if not self.m_activity then
    return
  end
  UILuaHelper.SetActive(self.m_img_stage_get, isShow and not isMax)
  UILuaHelper.SetActive(self.m_img_stage_bg, not isMax)
end

function UIRechargeAddRewardItem:ShowRechargeRewardEffect()
  UILuaHelper.SetActive(self.m_fx_rechargereward, false)
  UILuaHelper.SetActive(self.m_fx_rechargereward, true)
end

function UIRechargeAddRewardItem:OnBtnFirstRewardClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIRechargeAddRewardItem
