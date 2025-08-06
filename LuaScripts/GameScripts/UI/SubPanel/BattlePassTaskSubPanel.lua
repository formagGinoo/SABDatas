local UISubPanelBase = require("UI/Common/UISubPanelBase")
local BattlePassTaskSubPanel = class("BattlePassTaskSubPanel", UISubPanelBase)
local TaskIns = ConfigManager:GetConfigInsByName("Task")

function BattlePassTaskSubPanel:OnInit()
  self.m_stActivity = nil
  self.m_isFull = false
  self.m_isFirstInit = false
end

function BattlePassTaskSubPanel:OnActive(activityId)
  if not activityId then
    log.error("Bp Task Tab ActivityId is nil")
    return
  end
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    log.error("Bp Task Tab Activity is nil")
    return
  end
  if not self.m_isFirstInit then
    self.m_scrollRect = self.m_task_list:GetComponent("ScrollRect")
    if self.m_item_task and self.m_scrollRect then
      self.content = self.m_scrollRect.content:GetComponent("RectTransform")
      if self.content then
        local height = self.m_item_task:GetComponent("RectTransform").rect.height
        self.m_item_task:GetComponent("RectTransform").sizeDelta = Vector2.New(self.content.rect.width, height)
      end
    end
    local initQuestGridData = {
      itemClkBackFun = handler(self, self.OnQuestItemClk)
    }
    self.m_questInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "ActBattlePass/UIBattlePassTaskItem", initQuestGridData)
  end
  self:AddEventListeners()
  self:FreshUI()
end

function BattlePassTaskSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_DailyTaskRefresh", handler(self, self.OnDailyTaskRefresh))
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.FreshUI))
  self:addEventListener("eGameEvent_Activity_BattlePass_TaskUpdate", handler(self, self.OnTaskUpdate))
end

function BattlePassTaskSubPanel:OnDailyTaskRefresh()
  self:FreshTaskDataList()
  self:FreshTaskView()
  self:CutDownTime()
  self:FreshButtonsStatus()
end

function BattlePassTaskSubPanel:OnTaskUpdate(data)
  if not self.m_stActivity or self.m_stActivity:getID() ~= data.iActivityID then
    return
  end
  if self.m_isPlayingAnim then
    self.m_isPlayingAnim = false
    return
  end
  self:FreshTaskDataList()
  self:FreshTaskView(true)
end

function BattlePassTaskSubPanel:FreshUI()
  self:FreshFinishMask()
  self:FreshTaskDataList()
  self:FreshTaskView(true)
  self:CutDownTime()
  self:FreshButtonsStatus()
end

function BattlePassTaskSubPanel:FreshFinishMask()
  if not self.m_stActivity then
    return
  end
  local curLevel = self.m_stActivity:GetCurLevel()
  local maxLevel = self.m_stActivity:GetMaxLevel()
  self.m_isFull = curLevel >= maxLevel
  UILuaHelper.SetActive(self.m_pnl_mask, curLevel >= maxLevel)
end

function BattlePassTaskSubPanel:FreshTaskDataList()
  if not self.m_stActivity then
    return
  end
  local vQuest = self.m_stActivity:GetQuests()
  local data = {}
  local normal = {}
  local finish = {}
  local over = {}
  for k, v in ipairs(vQuest) do
    local questStatue = self.m_stActivity:GetQuestStatus(v)
    if questStatue == nil or questStatue.iState == MTTDProto.QuestState_Over then
      over[#over + 1] = {
        iQuestId = v,
        activity = self.m_stActivity,
        questCfg = TaskIns:GetValue_ByID(v),
        isFull = self.m_isFull
      }
    elseif questStatue.iState == MTTDProto.QuestState_Finish then
      finish[#finish + 1] = {
        iQuestId = v,
        activity = self.m_stActivity,
        questCfg = TaskIns:GetValue_ByID(v),
        isFull = self.m_isFull
      }
    else
      normal[#normal + 1] = {
        iQuestId = v,
        activity = self.m_stActivity,
        questCfg = TaskIns:GetValue_ByID(v),
        isFull = self.m_isFull
      }
    end
  end
  table.insertto(data, finish)
  table.insertto(data, normal)
  table.insertto(data, over)
  self.m_taskDataList = data
end

function BattlePassTaskSubPanel:FreshButtonsStatus()
  if not self.m_stActivity then
    return
  end
  local hasUnclaimedTask = self.m_stActivity:HasUnclaimedTask()
  UILuaHelper.SetActive(self.m_btn_yes, hasUnclaimedTask and not self.m_isFull)
  UILuaHelper.SetActive(self.m_btn_grey, not hasUnclaimedTask or self.m_isFull)
end

function BattlePassTaskSubPanel:FreshTaskView(bAnim)
  if not self.m_taskDataList then
    return
  end
  self.m_questInfinityGrid:ShowItemList(self.m_taskDataList)
  self.m_questInfinityGrid:LocateTo(0)
  if bAnim then
    local list = self.m_questInfinityGrid:GetAllShownItemList()
    for k, v in ipairs(list) do
      v:RefreshItemFx((k - 1) * 0.1)
    end
  end
end

function BattlePassTaskSubPanel:CutDownTime()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_isFull then
    self.m_txtTask_time:SetActive(false)
    return
  end
  self.m_txtTask_time:SetActive(true)
  local nextResetTimer = TimeUtil:GetServerNextCommonResetTime()
  local curTimer = TimeUtil:GetServerTimeS()
  self.m_activeRefreshTime = nextResetTimer - curTimer
  local timeStr = TimeUtil:SecondsToFormatCNStr4(self.m_activeRefreshTime)
  timeStr = string.CS_Format(ConfigManager:GetCommonTextById(220019), timeStr)
  self.m_txtTask_time_Text.text = timeStr
  self.m_downTimer = TimeService:SetTimer(1, -1, function()
    self.m_activeRefreshTime = self.m_activeRefreshTime - 1
    if self.m_activeRefreshTime < 0 then
      TimeService:KillTimer(self.m_downTimer)
      UILuaHelper.SetActive(self.m_txtTask_time_Text, false)
    else
      UILuaHelper.SetActive(self.m_txtTask_time_Text, true)
    end
    local tempTimeStr = TimeUtil:SecondsToFormatCNStr4(self.m_activeRefreshTime)
    tempTimeStr = string.CS_Format(ConfigManager:GetCommonTextById(220019), tempTimeStr)
    self.m_txtTask_time_Text.text = tempTimeStr
  end)
end

function BattlePassTaskSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function BattlePassTaskSubPanel:OnInActive()
  self:RemoveAllEventListeners()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
end

function BattlePassTaskSubPanel:OnQuestItemClk(taskCfg, index, item)
  if not self.m_stActivity then
    return
  end
  self.m_isPlayingAnim = true
  self.m_stActivity:RequestReceiveTask({
    taskCfg.m_ID
  }, function()
    self.m_questInfinityGrid:ReBind(index)
    item:PlayTaskComplateAnim()
    self:FreshButtonsStatus()
  end)
end

function BattlePassTaskSubPanel:OnBtnyesClicked()
  if not self.m_stActivity then
    return
  end
  self.m_isPlayingAnim = true
  self.m_stActivity:DrawAllTask(function()
    self.m_questInfinityGrid:ReBindAll()
    local list = self.m_questInfinityGrid:GetAllShownItemList()
    for k, v in ipairs(list) do
      v:PlayTaskComplateAnim()
    end
    self:FreshTaskDataList()
    self:FreshTaskView()
    self:FreshButtonsStatus()
  end)
end

function BattlePassTaskSubPanel:OnBtngreyClicked()
  if not self.m_stActivity then
    return
  end
  StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 20102)
end

function BattlePassTaskSubPanel:OnBtnaddClicked()
  if not self.m_stActivity then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP, {
    stActivity = self.m_stActivity
  })
end

function BattlePassTaskSubPanel:OnRefreshUI()
end

return BattlePassTaskSubPanel
