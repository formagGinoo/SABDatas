local Form_HuntingNightReward = class("Form_HuntingNightReward", require("UI/UIFrames/Form_HuntingNightRewardUI"))
local __HuntingNightRewardState = {
  Default = 1,
  IsTaken = 2,
  IsArrive = 3
}

function Form_HuntingNightReward:SetInitParam(param)
end

function Form_HuntingNightReward:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnTabItemClk)
  }
  self.m_TabInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_tab_list_InfinityGrid, "HuntingRaid/UHuntingRaidRewardTabItem", initGridData)
  self.m_TabInfinityGrid:RegisterButtonCallback("c_item_tab", handler(self, self.OnTabItemClk))
end

function Form_HuntingNightReward:OnActive()
  self.super.OnActive(self)
  self.m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if not self.m_activity then
    return
  end
  self.m_TabData = self:GenerateTabData()
  self.m_iBossIndex = 1
  local tParam = self.m_csui.m_param
  if tParam and tParam.bossId then
    self.m_iBossIndex = self:GetStageOpenIndex(tParam.bossId)
  end
  self.m_selBossId = nil
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_HuntingNightReward:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HuntingNightReward:GetStageOpenIndex(bossId)
  for i, v in ipairs(self.m_TabData) do
    if v.iBossId == bossId then
      local showTime = self.m_activity:CheckBossInShowAndChallengeTime(bossId)
      if showTime ~= 0 then
        return i
      end
    end
  end
  return 1
end

function Form_HuntingNightReward:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_Hunting_TakeBossReward", handler(self, self.OnTakeBossReward))
end

function Form_HuntingNightReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HuntingNightReward:GenerateTabData()
  local dataTab = {}
  local bossList = self.m_activity:GetHuntingRaidBossList()
  for i, v in ipairs(bossList) do
    local canReceiveIds = HuntingRaidManager:CheckHaveReceiveAwardByBossId(v.iBossId)
    local cfg = HuntingRaidManager:GetHuntingRaidBossCfgById(v.iBossId) or {}
    dataTab[#dataTab + 1] = {
      iBossId = v.iBossId,
      title = cfg.m_mName,
      canReceiveIds = canReceiveIds,
      index = i
    }
  end
  return dataTab
end

function Form_HuntingNightReward:RefreshUI()
  self.m_selBossId = self.m_TabData[self.m_iBossIndex].iBossId
  self.m_TabData[self.m_iBossIndex].isSelect = true
  self.m_TabInfinityGrid:ShowItemList(self.m_TabData)
  self.m_TabInfinityGrid:LocateTo(self.m_iBossIndex - 1)
  self:refreshLoopScroll()
end

function Form_HuntingNightReward:GenerateRewardData()
  if not self.m_selBossId then
    return
  end
  local taskList = {}
  local canGetReward = false
  local achieveIns = ConfigManager:GetConfigInsByName("HuntingRaidAchieve")
  local cfgList = achieveIns:GetValue_ByBOSSID(self.m_selBossId)
  local canReceiveIds = HuntingRaidManager:CheckHaveReceiveAwardByBossId(self.m_selBossId)
  if cfgList then
    for i, v in pairs(cfgList) do
      local state = __HuntingNightRewardState.Default
      local isTaken = HuntingRaidManager:CheckAchieveIsTaken(self.m_selBossId, v.m_Sequence)
      if isTaken then
        state = __HuntingNightRewardState.IsTaken
      elseif table.indexof(canReceiveIds, v.m_Sequence) then
        state = __HuntingNightRewardState.IsArrive
        canGetReward = true
      end
      taskList[#taskList + 1] = {
        state = state,
        index = v.m_Sequence,
        cfg = v
      }
    end
    
    local function sortFun(data1, data2)
      return data1.index < data2.index
    end
    
    table.sort(taskList, sortFun)
  end
  return taskList, canGetReward
end

function Form_HuntingNightReward:refreshLoopScroll()
  local damage = HuntingRaidManager:GetBossRealDamageById(self.m_selBossId)
  local cfg = HuntingRaidManager:GetHuntingRaidBossCfgById(self.m_selBossId)
  if cfg then
    self.m_txt_damagenum_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20333), tostring(cfg.m_mTitle1), damage)
  end
  local data, canGet = self:GenerateRewardData()
  UILuaHelper.SetActive(self.m_btn_yes, canGet)
  UILuaHelper.SetActive(self.m_btn_grey, not canGet)
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_task_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "m_btn_receive" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
          HuntingRaidManager:ReqHuntingTakeBossRewardCS(self.m_selBossId, {
            cell_data.index
          })
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_HuntingNightReward:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local cfg = cell_data.cfg
  local text = ""
  if cfg and cfg.m_AchieveType == HuntingRaidManager.AchieveType.Time then
    text = string.gsubnumberreplace(cfg.m_mText, cfg.m_GoalNum / 1000)
  else
    text = string.gsubnumberreplace(cfg.m_mText, cfg.m_GoalNum)
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_content", text)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_receive", cell_data.state == __HuntingNightRewardState.IsArrive)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_Incomplete", cell_data.state == __HuntingNightRewardState.Default)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_complete", cell_data.state == __HuntingNightRewardState.IsTaken)
  local rewardList = utils.changeCSArrayToLuaTable(cfg.m_Reward)
  for i = 1, 2 do
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_item" .. i, rewardList[i])
    if rewardList[i] then
      local common_item = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_common_item" .. i)
      local item = self:createCommonItem(common_item)
      item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
      local processData = ResourceUtil:GetProcessRewardData(rewardList[i], {
        is_have_get = cell_data.state == __HuntingNightRewardState.IsTaken
      })
      item:SetItemInfo(processData)
    end
  end
end

function Form_HuntingNightReward:OnTakeBossReward()
  self.m_TabData = self:GenerateTabData()
  self:refreshLoopScroll()
  if self.m_TabInfinityGrid then
    self.m_TabInfinityGrid:ShowItemList(self.m_TabData, true)
  end
end

function Form_HuntingNightReward:OnTabItemClk(idx)
  local index = idx + 1
  if index == self.m_iBossIndex then
    return
  end
  self.m_TabData[self.m_iBossIndex].isSelect = false
  self.m_TabData[index].isSelect = true
  self.m_TabInfinityGrid:ReBind(self.m_iBossIndex)
  self.m_TabInfinityGrid:ReBind(index)
  self.m_iBossIndex = index
  self.m_selBossId = self.m_TabData[self.m_iBossIndex].iBossId
  CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
  self:refreshLoopScroll()
end

function Form_HuntingNightReward:OnBtnyesClicked()
  local list = HuntingRaidManager:CheckHaveReceiveAwardByBossId(self.m_selBossId)
  HuntingRaidManager:ReqHuntingTakeBossRewardCS(self.m_selBossId, list)
end

function Form_HuntingNightReward:OnBtngreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54001)
end

function Form_HuntingNightReward:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HuntingNightReward:IsOpenGuassianBlur()
  return true
end

function Form_HuntingNightReward:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNightReward", Form_HuntingNightReward)
return Form_HuntingNightReward
