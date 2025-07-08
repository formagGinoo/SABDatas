local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AchievementTaskSubPanel = class("AchievementTaskSubPanel", UISubPanelBase)

function AchievementTaskSubPanel:OnInit()
  self.m_reward_complete:SetActive(false)
  self.m_reward_root:SetActive(true)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "Task/UIAchievementTaskItem")
  self.m_widgetItemIcon = self:createCommonItem(self.m_big_item)
  self.m_widgetItemIcon:SetItemIconClickCB(handler(self, self.OnRewardItemClick))
  self.m_oldScore = nil
  self.m_curScore = nil
  self.m_taskDataList = {}
  self.m_achievementStepId = 0
end

function AchievementTaskSubPanel:OnFreshData()
  if self.m_TaskListInfinityGrid then
    local dataList = TaskManager:GetAchievementTasksData()
    self.m_TaskListInfinityGrid:ShowItemList(dataList)
    if #dataList == 0 then
      self.m_empty_achievement:SetActive(true)
      self.m_task_list:SetActive(false)
    else
      self.m_empty_achievement:SetActive(false)
      self.m_task_list:SetActive(true)
    end
    if dataList and 0 < #dataList then
      self.m_TaskListInfinityGrid:LocateTo(0)
    end
    self.m_taskDataList = dataList
    self.m_UIFX_star:SetActive(false)
    self:RefreshLeftUI()
  end
end

function AchievementTaskSubPanel:OnActivePanel()
  self:AddEventListeners()
end

function AchievementTaskSubPanel:OnHidePanel()
  self:RemoveAllEventListeners()
end

function AchievementTaskSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Task_Change_State", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_Task_AchieveTakeReward", handler(self, self.OnEventGetTaskRewards))
  self:addEventListener("eGameEvent_Task_TakeAchieveReward", handler(self, self.RefreshTaskRewardCB))
  self:addEventListener("eGameEvent_Task_GetRewardFailed", handler(self, self.OnFreshData))
end

function AchievementTaskSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function AchievementTaskSubPanel:RefreshTaskRewardCB()
  self:RefreshLeftUI()
end

function AchievementTaskSubPanel:RefreshLeftUI()
  local rewardCfg = TaskManager:GetAchievementStepCfg()
  if not rewardCfg then
    self.m_achievementStepId = 0
    self.m_pnl_normal:SetActive(false)
    self.m_reward_complete:SetActive(true)
    return
  end
  self.m_pnl_normal:SetActive(true)
  local taskScore = TaskManager:GetAchievementScore()
  local requiredCount = rewardCfg.m_RequiredCount
  local score = math.min(taskScore / requiredCount, 1)
  self.m_img_taskbg2_Image.fillAmount = score
  self.m_img_taskbg1:SetActive(1 <= score)
  local reward = utils.changeCSArrayToLuaTable(rewardCfg.m_Reward)
  if reward and reward[1] and reward[1][1] then
    local itemData = ResourceUtil:GetProcessRewardData({
      iID = reward[1][1],
      iNum = reward[1][2]
    })
    self.m_widgetItemIcon:SetItemInfo(itemData)
  end
  self.m_z_txt_normal_tips:SetActive(score < 1)
  self.m_reward_complete:SetActive(false)
  self.m_txt_big_num_Text.text = string.format(ConfigManager:GetCommonTextById(20048), taskScore, requiredCount)
  self.m_btn_step_receive:SetActive(1 <= score)
  if 1 <= score then
    self.m_achievementStepId = rewardCfg.m_ID
  else
    self.m_achievementStepId = 0
  end
  local idList = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Achievement)
  self.m_bg_getall_normal:SetActive(0 < #idList or self.m_achievementStepId ~= 0)
  self.m_bg_getall_grey:SetActive(#idList == 0 and self.m_achievementStepId == 0)
end

function AchievementTaskSubPanel:OnEventGetReward(params)
  local taskScore = TaskManager:GetTaskScoreByType(TaskManager.TaskType.Achievement)
  self.m_curScore = taskScore
  if params and params.isGetReward then
    TimeService:SetTimer(0.3, 1, function()
      self:OnFreshData()
    end)
  else
    self:OnFreshData()
  end
end

function AchievementTaskSubPanel:OnEventGetTaskRewards(params)
  self.m_UIFX_star:SetActive(true)
  GlobalManagerIns:TriggerWwiseBGMState(80)
  self:RefreshLeftUI()
end

function AchievementTaskSubPanel:OnRewardItemClick(itemID, itemNum, itemCom)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function AchievementTaskSubPanel:OnBtngetallClicked()
  self.m_UIFX_star:SetActive(false)
  local idList = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Achievement)
  if self.m_achievementStepId ~= 0 then
    self:RefreshItemsFx(idList)
    TaskManager:ReqTakeAchieveRewardReward(self.m_achievementStepId, idList, MTTDProto.QuestType_Achievement)
  elseif self.m_achievementStepId == 0 and idList and 0 < #idList then
    TaskManager:ReqTakeReward(TaskManager.TaskType.Achievement, idList)
    self:RefreshItemsFx(idList)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20041)
  end
end

function AchievementTaskSubPanel:RefreshItemsFx(idList)
  for i, taskId in ipairs(idList) do
    if self.m_taskDataList then
      for m, taskData in ipairs(self.m_taskDataList) do
        if taskData.cfg and taskData.cfg.m_ID == taskId then
          local item = self.m_TaskListInfinityGrid:GetItemByData(taskData)
          if item then
            item:RefreshItemFx()
          end
        end
      end
    end
  end
end

function AchievementTaskSubPanel:OnBtnstepreceiveClicked()
  TaskManager:ReqTakeAchieveRewardReward(self.m_achievementStepId, nil, MTTDProto.QuestType_Achievement)
end

return AchievementTaskSubPanel
