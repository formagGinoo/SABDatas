local UIItemBase = require("UI/Common/UIItemBase")
local UIFirstRechargeRewardItem = class("UIFirstRechargeRewardItem", UIItemBase)

function UIFirstRechargeRewardItem:OnInit()
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

function UIFirstRechargeRewardItem:OnFreshData()
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

function UIFirstRechargeRewardItem:FreshItemUI()
  if not self.m_rewardCfgData then
    return
  end
  if not self.m_activity then
    return
  end
  local conditionDayNum = self.m_rewardCfgData.iNeedLoginDays
  self.m_txt_day_Text.text = "0" .. conditionDayNum
  self.m_rewardMulItemList:ShowItemList(self.m_rewardCfgData.vReward)
  self:FreshStatus()
end

function UIFirstRechargeRewardItem:FreshStatus()
  if not self.m_rewardCfgData then
    return
  end
  if not self.m_activity then
    return
  end
  local id = self.m_rewardCfgData.iId
  local isHaveGet = self.m_activity:CheckRewardIsGet(id)
  local isCanGet = self.m_activity:IsFirstRewardCanGet(id)
  UILuaHelper.SetActive(self.m_node_have_get, isHaveGet == true)
  UILuaHelper.SetActive(self.m_node_can_get, isCanGet == true)
  UILuaHelper.SetActive(self.m_btn_First_Reward, isCanGet == true and isHaveGet ~= true)
  local curLoginDay = RoleManager:GetTotalLoginDays()
  local conditionDayNum = self.m_rewardCfgData.iNeedLoginDays
  local isNotLock = curLoginDay >= conditionDayNum
  UILuaHelper.SetActive(self.m_node_lock, isNotLock == false)
  local allShowItemList = self.m_rewardMulItemList:GetAllShownItemList()
  for i, v in ipairs(allShowItemList) do
    v:FreshStatus(isHaveGet, isCanGet)
  end
end

function UIFirstRechargeRewardItem:OnBtnFirstRewardClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIFirstRechargeRewardItem
