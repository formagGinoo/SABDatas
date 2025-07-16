local UISubPanelBase = require("UI/Common/UISubPanelBase")
local DailyTaskSubPanel = class("DailyTaskSubPanel", UISubPanelBase)
local DailyTaskRewardIns = ConfigManager:GetConfigInsByName("DailyTaskReward")
local openPanelObjAnim = "ui_task_panel_day_in"

function DailyTaskSubPanel:OnInit()
  self.m_reward_complete:SetActive(false)
  self.m_reward_root:SetActive(true)
  self.m_fx_star:SetActive(false)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "Task/UITaskItem")
  self.m_oldScore = nil
  self.m_curScore = nil
  self.m_showCountDownTime = false
  self.m_taskDataList = {}
  self.m_txt_countdown_Text.text = ""
  self.m_iTimeDurationOneSecond = 1
  self.allAnimTimer = {}
end

function DailyTaskSubPanel:OnFreshData()
  if self.m_TaskListInfinityGrid then
    self:KillAllTimer()
    local dataList = TaskManager:GetTaskData(TaskManager.TaskType.Daily)
    self.m_TaskListInfinityGrid:ShowItemList(dataList)
    self.m_TaskListInfinityGrid:LocateTo(0)
    self.m_taskDataList = dataList
    self:RefreshRewardUI()
    local idList = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Daily)
    self.m_bg_getall_normal:SetActive(0 < #idList)
    self.m_bg_getall_grey:SetActive(#idList == 0)
    self:RefreshTime()
  end
end

function DailyTaskSubPanel:OnActivePanel()
  self:AddEventListeners()
end

function DailyTaskSubPanel:OnHidePanel()
  self:RemoveAllEventListeners()
  if self.m_openTimer then
    TimeService:KillTimer(self.m_openTimer)
    self.m_openTimer = nil
  end
end

function DailyTaskSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Task_Change_State", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_Task_GetReward", handler(self, self.OnEventGetTaskRewards))
  self:addEventListener("eGameEvent_Task_GetRewardFailed", handler(self, self.OnFreshData))
end

function DailyTaskSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function DailyTaskSubPanel:RefreshTime()
  if self.m_showCountDownTime then
    local endTime = TimeUtil:GetServerNextCommonResetTime()
    self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_countdown_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
  else
    self.m_iTimeTick = nil
  end
end

function DailyTaskSubPanel:OnUpdate(dt)
  if not self.m_showCountDownTime then
    return
  end
  if not self.m_txt_countdown_Text then
    return
  end
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    self.m_txt_countdown_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
  end
  if self.m_iTimeTick <= 0 then
    self.m_iTimeTick = nil
    self.m_txt_countdown_Text.text = ""
  end
end

function DailyTaskSubPanel:OnEventGetReward(params)
  if params and params.typeList and table.indexof(params.typeList, TaskManager.TaskType.Daily) then
    local taskScore = TaskManager:GetTaskScoreByType(TaskManager.TaskType.Daily)
    self.m_curScore = taskScore
    if params and params.isGetReward then
      TimeService:SetTimer(0.3, 1, function()
        self:OnFreshData()
      end)
    else
      self:OnFreshData()
    end
  end
end

function DailyTaskSubPanel:OnEventGetTaskRewards(params)
  if params.questType == TaskManager.TaskType.Daily then
    TimeService:SetTimer(0.5, 1, function()
      utils.popUpRewardUI(params.reward)
    end)
  end
end

function DailyTaskSubPanel:RefreshRewardUI()
  local taskScore = TaskManager:GetTaskScoreByType(TaskManager.TaskType.Daily)
  local frontScore = 0
  local integral = 0
  local cfgScore = 0
  for i = 1, 5 do
    local dailyTaskRewardCfg = DailyTaskRewardIns:GetValue_ByID(i)
    if dailyTaskRewardCfg then
      local score = dailyTaskRewardCfg.m_RequiredScore
      cfgScore = i == 5 and score or cfgScore
      local rewardList = utils.changeCSArrayToLuaTable(dailyTaskRewardCfg.m_Reward)
      for m = 1, 3 do
        local itemWidget = self:createCommonItem(self["m_common_item" .. i .. "_" .. m])
        if rewardList[m] then
          local processItemData = ResourceUtil:GetProcessRewardData(rewardList[m])
          itemWidget:SetItemInfo(processItemData)
          itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
            self:OnRewardItemClick(itemID, itemNum, itemCom)
          end)
          itemWidget:SetActive(true)
          if taskScore >= score then
            self["m_icon_check" .. i .. "_" .. m]:SetActive(true)
          else
            self["m_icon_check" .. i .. "_" .. m]:SetActive(false)
          end
        else
          itemWidget:SetActive(false)
          self["m_icon_check" .. i .. "_" .. m]:SetActive(false)
        end
        if m <= score - frontScore then
          integral = integral + 1
        end
        self["m_icon" .. i .. "_" .. m]:SetActive(m <= score - frontScore)
        if taskScore >= integral then
          self["m_icon_complete" .. i .. "_" .. m]:SetActive(true)
          if m <= score - frontScore and self.m_oldScore and self.m_curScore and integral > self.m_oldScore and integral <= self.m_curScore then
            self:ShowFxStar(self["m_icon" .. i .. "_" .. m])
          end
        else
          self["m_icon_complete" .. i .. "_" .. m]:SetActive(false)
        end
      end
      frontScore = score
    end
  end
  if taskScore >= cfgScore then
    self.m_reward_complete:SetActive(true)
  else
    self.m_reward_complete:SetActive(false)
  end
  self.m_showCountDownTime = taskScore >= cfgScore
  self.m_oldScore = taskScore
end

function DailyTaskSubPanel:ShowFxStar(parent)
  local itemObj = GameObject.Instantiate(self.m_fx_star, parent.transform).gameObject
  itemObj:SetActive(true)
  UILuaHelper.SetLocalPosition(itemObj, 0, 0, 0)
  TimeService:SetTimer(2, 1, function()
    if itemObj then
      GameObject.Destroy(itemObj)
    end
  end)
end

function DailyTaskSubPanel:OnRewardItemClick(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function DailyTaskSubPanel:OnBtngetallClicked()
  if self.m_openTimer then
    return
  end
  local idList = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Daily)
  if idList and 0 < #idList then
    TaskManager:ReqTakeReward(TaskManager.TaskType.Daily, idList)
    self:RefreshItemsFx(idList)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20041)
  end
end

function DailyTaskSubPanel:RefreshItemsFx(idList)
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

function DailyTaskSubPanel:ResetInfinityGridLocate()
  self.m_TaskListInfinityGrid:LocateTo(0)
end

function DailyTaskSubPanel:PlayAnimItem()
  self:SetOpenTimer()
  self:ResetInfinityGridLocate()
  self:KillAllTimer()
  local childList = self.m_TaskListInfinityGrid:GetAllShownItemList()
  for i = 1, #childList do
    UILuaHelper.SetCanvasGroupAlpha(childList[i].m_itemRootObj, 0)
  end
  for i = 1, #childList do
    self.allAnimTimer[#self.allAnimTimer + 1] = TimeService:SetTimer(0.05 * i, 1, function()
      UILuaHelper.PlayAnimationByName(childList[i].m_itemRootObj, "m_task_item_begin")
      self.allAnimTimer[#self.allAnimTimer + 1] = nil
    end)
  end
end

function DailyTaskSubPanel:OpenSubAnim()
  if self.m_rootObj then
    UILuaHelper.PlayAnimationByName(self.m_rootObj, openPanelObjAnim)
  end
end

function DailyTaskSubPanel:SetOpenTimer()
  if self.m_openTimer then
    TimeService:KillTimer(self.m_openTimer)
    self.m_openTimer = nil
  end
  self.m_openTimer = TimeService:SetTimer(0.8, 1, function()
    self.m_openTimer = nil
  end)
end

function DailyTaskSubPanel:KillAllTimer()
  if self.allAnimTimer then
    for i = #self.allAnimTimer, 1, -1 do
      TimeService.KillTimer(self.allAnimTimer[i])
    end
    self.allAnimTimer = {}
  end
end

function DailyTaskSubPanel:dispose()
  DailyTaskSubPanel.super.dispose(self)
  self:KillAllTimer()
end

return DailyTaskSubPanel
