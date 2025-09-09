local Form_EquipmentSweepReward = class("Form_EquipmentSweepReward", require("UI/UIFrames/Form_EquipmentSweepRewardUI"))
local __MAX_ROUND = 3

function Form_EquipmentSweepReward:SetInitParam(param)
end

function Form_EquipmentSweepReward:AfterInit()
  self.super.AfterInit(self)
  local initItemData = {
    itemClkBackFun = handler(self, self.OnItemClkBackFun)
  }
  for i = 1, __MAX_ROUND do
    self["m_mulItemNormalList" .. i] = self:CreateCloneMulItemList(self["m_pnl_item_normal" .. i], self.m_common_item, "UICloneMulCommonItem", initItemData)
    self["m_mulItemDoubleList" .. i] = self:CreateCloneMulItemList(self["m_pnl_item_double" .. i], self.m_common_item, "UICloneMulCommonItem", initItemData)
  end
  self.mScroll = self.m_Scroll_View:GetComponent("ScrollRect")
  self.vAnimTimerList = {}
  self.vTweeners = {}
end

function Form_EquipmentSweepReward:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_rewardData = tParam.vMopReward or {}
  self.m_bom_node:SetActive(false)
  self:RefreshUI()
  self:ShowAnim()
  self:AddEventListeners()
end

function Form_EquipmentSweepReward:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  for _, timer in ipairs(self.vAnimTimerList) do
    TimeService:KillTimer(timer)
  end
  self.vAnimTimerList = {}
  if self.m_bom_timer then
    TimeService:KillTimer(self.m_bom_timer)
    self.m_bom_timer = nil
  end
  for _, tweener in ipairs(self.vTweeners) do
    if tweener and tweener:IsPlaying() then
      tweener:Kill()
    end
  end
end

function Form_EquipmentSweepReward:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_Level_DailyReset", handler(self, self.OnBtnCloseClicked))
end

function Form_EquipmentSweepReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentSweepReward:RefreshUI()
  for i = 1, __MAX_ROUND do
    local rewards = self.m_rewardData[i]
    if rewards then
      if table.getn(rewards.vReward) > 0 then
        local vReward = rewards.vReward
        local dataList = {}
        for _, v in ipairs(vReward) do
          local processData = ResourceUtil:GetProcessRewardData(v)
          dataList[#dataList + 1] = processData
        end
        local list = self:SortItemByQuality(dataList)
        self["m_mulItemNormalList" .. i]:ShowItemList(list)
        self["m_normal_reward" .. i]:SetActive(true)
      else
        self["m_normal_reward" .. i]:SetActive(false)
      end
      if 0 < table.getn(rewards.vExtraReward) then
        local exRewards = rewards.vExtraReward
        local dataList = {}
        for _, v in ipairs(exRewards) do
          local processData = ResourceUtil:GetProcessRewardData(v, {is_extra = true})
          dataList[#dataList + 1] = processData
        end
        local list = self:SortItemByQuality(dataList)
        self["m_mulItemDoubleList" .. i]:ShowItemList(list)
        self["m_double_reward" .. i]:SetActive(true)
      else
        self["m_double_reward" .. i]:SetActive(false)
      end
    end
    self["m_reward_node" .. i]:SetActive(false)
  end
end

function Form_EquipmentSweepReward:ShowAnim()
  local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_reward_node1, "m_reward_node_in")
  local scrollDuration = 0.3
  local scrollEaseType = Tweening.Ease.OutQuad
  for i = 1, __MAX_ROUND do
    local rewards = self.m_rewardData[i]
    if not rewards then
      return
    end
    if self.vAnimTimerList[i] then
      TimeService:KillTimer(self.vAnimTimerList[i])
      self.vAnimTimerList[i] = nil
    end
    self.vAnimTimerList[i] = TimeService:SetTimer(fAniLength * (i - 1), 1, function()
      if utils.isNull(self["m_reward_node" .. i]) then
        return
      end
      UILuaHelper.SetCanvasGroupAlpha(self["m_reward_node" .. i], 0)
      self["m_reward_node" .. i]:SetActive(true)
      TimeService:SetTimer(0.03333333333333333, 1, function()
        if not utils.isNull(self.mScroll) then
          local tweener = DOTweenModuleUI.DOVerticalNormalizedPos(self.mScroll, 0, scrollDuration)
          tweener:SetEase(scrollEaseType)
          self.vTweeners[i] = tweener
          UILuaHelper.SetCanvasGroupAlpha(self["m_reward_node" .. i], 1)
          local sAnimName = i == 1 and "m_reward_node_in" or "m_reward_node_in2"
          UILuaHelper.PlayAnimationByName(self["m_reward_node" .. i], sAnimName)
        end
      end)
    end)
  end
  local fLength = fAniLength * #self.m_rewardData
  if self.m_bom_timer then
    TimeService:KillTimer(self.m_bom_timer)
    self.m_bom_timer = nil
  end
  self.m_bom_timer = TimeService:SetTimer(fLength, 1, function()
    if utils.isNull(self.m_bom_node) then
      return
    end
    self.m_bom_node:SetActive(true)
  end)
end

function Form_EquipmentSweepReward:SortItemByQuality(rewardList)
  local function sortFunc(a, b)
    if a.data_type == b.data_type then
      if a.quality == b.quality then
        return a.data_id > b.data_id
      else
        return a.quality > b.quality
      end
    else
      return a.data_type > b.data_type
    end
  end
  
  table.sort(rewardList, sortFunc)
  return rewardList
end

function Form_EquipmentSweepReward:OnItemClkBackFun(index, obj, icon, data)
  if data and data.data_id then
    utils.openItemDetailPop({
      iID = data.data_id,
      iNum = ItemManager:GetItemNum(data.data_id)
    })
  end
end

function Form_EquipmentSweepReward:IsOpenGuassianBlur()
  return true
end

function Form_EquipmentSweepReward:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipmentSweepReward:OnDestroy()
  self.super.OnDestroy(self)
  for _, timer in ipairs(self.vAnimTimerList) do
    TimeService:KillTimer(timer)
  end
  self.vAnimTimerList = {}
  if self.m_bom_timer then
    TimeService:KillTimer(self.m_bom_timer)
    self.m_bom_timer = nil
  end
  for _, tweener in ipairs(self.vTweeners) do
    if tweener and tweener:IsPlaying() then
      tweener:Kill()
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentSweepReward", Form_EquipmentSweepReward)
return Form_EquipmentSweepReward
