local Form_BattlePassTask = class("Form_BattlePassTask", require("UI/UIFrames/Form_BattlePassTaskUI"))
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus
local TaskIns = ConfigManager:GetConfigInsByName("Task")

function Form_BattlePassTask:SetInitParam(param)
end

function Form_BattlePassTask:AfterInit()
  self.super.AfterInit(self)
  local initQuestGridData = {
    itemClkBackFun = handler(self, self.OnQuestItemClk)
  }
  self.m_questInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "ActBattlePass/UIBattlePassTaskItem", initQuestGridData)
  self.m_stActivity = nil
end

function Form_BattlePassTask:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_BattlePassTask:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
end

function Form_BattlePassTask:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattlePassTask:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self.m_csui.m_param = nil
  end
end

function Form_BattlePassTask:ClearCacheData()
end

function Form_BattlePassTask:FreshTaskDataList()
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
        questCfg = TaskIns:GetValue_ByID(v)
      }
    elseif questStatue.iState == MTTDProto.QuestState_Finish then
      finish[#finish + 1] = {
        iQuestId = v,
        activity = self.m_stActivity,
        questCfg = TaskIns:GetValue_ByID(v)
      }
    else
      normal[#normal + 1] = {
        iQuestId = v,
        activity = self.m_stActivity,
        questCfg = TaskIns:GetValue_ByID(v)
      }
    end
  end
  table.insertto(data, finish)
  table.insertto(data, normal)
  table.insertto(data, over)
  self.m_taskDataList = data
end

function Form_BattlePassTask:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_DailyTaskRefresh", handler(self, self.OnDailyTaskRefresh))
  self:addEventListener("eGameEvent_Activity_BattlePass_TaskUpdate", handler(self, self.OnTaskUpdate))
  self:addEventListener("eGameEvent_Activity_BattlePass_ReceiveTaskReward", handler(self, self.OnReceiveTaskReward))
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.OnBuyExp))
  self:addEventListener("eGameEvent_Activity_BattlePass_CloseMain", handler(self, self.OnBtnCloseClicked))
end

function Form_BattlePassTask:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattlePassTask:OnDailyTaskRefresh()
  self:FreshTaskDataList()
  self:FreshTaskView()
  self:CutDownTime()
  self:FreshButtonsStatus()
end

function Form_BattlePassTask:OnTaskUpdate(data)
  if self.m_isPlayingAnim then
    self.m_isPlayingAnim = false
    return
  end
  self:FreshTaskDataList()
  self:FreshTaskView(true)
end

function Form_BattlePassTask:OnReceiveTaskReward(data)
  if not self.m_stActivity then
    return
  end
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshLevelExpInfo()
  end
end

function Form_BattlePassTask:OnBuyExp(data)
  if not self.m_stActivity then
    return
  end
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshLevelExpInfo()
  end
end

function Form_BattlePassTask:FreshUI()
  self:FreshTaskDataList()
  self:FreshTaskView(true)
  self:FreshLevelExpInfo()
  self:CutDownTime()
  self:FreshButtonsStatus()
  self:CheckShowLevelUp10Panel()
end

function Form_BattlePassTask:FreshTaskView(bAnim)
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

function Form_BattlePassTask:FreshLevelExpInfo()
  if not self.m_stActivity then
    return
  end
  self.m_txt_rank_Text.text = self.m_stActivity:GetCurLevel()
  self:FreshProgress()
end

function Form_BattlePassTask:FreshProgress()
  if not self.m_stActivity then
    return
  end
  local curLevel = self.m_stActivity:GetCurLevel()
  local levelCfg = self.m_stActivity:GetLevelCfg(curLevel)
  if levelCfg then
    local needExp = self.m_stActivity:GetUpLevelExp()
    if curLevel == self.m_stActivity:GetMaxLevel() then
      self.m_slider_level_Image.fillAmount = 1
      self.m_txt_tasklevelnum_Text.text = needExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, false)
    else
      local curExp = self.m_stActivity:GetCurExp()
      if needExp <= curExp then
        self.m_slider_level_Image.fillAmount = 1
      else
        self.m_slider_level_Image.fillAmount = curExp / needExp
      end
      self.m_txt_tasklevelnum_Text.text = curExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, true)
    end
  end
end

function Form_BattlePassTask:CutDownTime()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  local nextResetTimer = TimeUtil:GetServerNextCommonResetTime()
  local curTimer = TimeUtil:GetServerTimeS()
  self.m_activeRefreshTime = nextResetTimer - curTimer
  local timeStr = TimeUtil:SecondsToFormatCNStr(self.m_activeRefreshTime)
  timeStr = string.CS_Format(ConfigManager:GetCommonTextById(220019), timeStr)
  self.m_txt_time_Text.text = timeStr
  self.m_downTimer = TimeService:SetTimer(1, -1, function()
    self.m_activeRefreshTime = self.m_activeRefreshTime - 1
    if self.m_activeRefreshTime < 0 then
      TimeService:KillTimer(self.m_downTimer)
      UILuaHelper.SetActive(self.m_txt_time_Text, false)
    else
      UILuaHelper.SetActive(self.m_txt_time_Text, true)
    end
    local tempTimeStr = TimeUtil:SecondsToFormatCNStr(self.m_activeRefreshTime)
    tempTimeStr = string.CS_Format(ConfigManager:GetCommonTextById(220019), tempTimeStr)
    self.m_txt_time_Text.text = tempTimeStr
  end)
end

function Form_BattlePassTask:FreshButtonsStatus()
  if not self.m_stActivity then
    return
  end
  local hasUnclaimedTask = self.m_stActivity:HasUnclaimedTask()
  UILuaHelper.SetActive(self.m_btn_yes, hasUnclaimedTask)
  UILuaHelper.SetActive(self.m_btn_grey, not hasUnclaimedTask)
end

function Form_BattlePassTask:PlayGetExpAnim()
end

function Form_BattlePassTask:CheckShowLevelUp10Panel()
  if not self.m_stActivity then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  if buyStatus == BattlePassBuyStatus.Advanced then
    return
  end
  if buyStatus == BattlePassBuyStatus.Free then
    local isHavePopBattlePassLimitLv = LocalDataManager:GetIntSimple("PopBattlePassLimitLv", 0) == 1
  elseif buyStatus == BattlePassBuyStatus.Paid then
  end
end

function Form_BattlePassTask:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_BattlePassTask:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_BattlePassTask:OnQuestItemClk(taskCfg, index, item)
  if not self.m_stActivity then
    return
  end
  self.m_isPlayingAnim = true
  self.m_stActivity:RequestReceiveTask({
    taskCfg.m_ID
  }, function()
    self.m_isPlayingAnim = false
    self.m_questInfinityGrid:ReBind(index)
    item:PlayTaskComplateAnim()
    self:PlayGetExpAnim()
    self:FreshLevelExpInfo()
    self:FreshButtonsStatus()
  end)
end

function Form_BattlePassTask:OnBtnyesClicked()
  if not self.m_stActivity then
    return
  end
  self.m_isPlayingAnim = true
  self.m_stActivity:DrawAllTask(function()
    self.m_isPlayingAnim = false
    self.m_questInfinityGrid:ReBindAll()
    local list = self.m_questInfinityGrid:GetAllShownItemList()
    for k, v in ipairs(list) do
      v:PlayTaskComplateAnim()
    end
    self:PlayGetExpAnim()
    self:FreshTaskDataList()
    self:FreshTaskView()
    self:FreshLevelExpInfo()
    self:FreshButtonsStatus()
  end)
end

function Form_BattlePassTask:OnBtngreyClicked()
  if not self.m_stActivity then
    return
  end
  StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 20102)
end

function Form_BattlePassTask:OnBtnaddClicked()
  if not self.m_stActivity then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP, {
    stActivity = self.m_stActivity
  })
end

function Form_BattlePassTask:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattlePassTask", Form_BattlePassTask)
return Form_BattlePassTask
