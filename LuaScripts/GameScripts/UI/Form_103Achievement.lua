local Form_103Achievement = class("Form_103Achievement", require("UI/UIFrames/Form_103AchievementUI"))

function Form_103Achievement:SetInitParam(param)
end

function Form_103Achievement:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_TaskListInfinityGrid1 = require("UI/Common/UIInfinityGrid").new(self.m_scrollView1_InfinityGrid, "HeroActivity/UIHeroAct103DailyTaskItem")
  self.m_TaskListInfinityGrid2 = require("UI/Common/UIInfinityGrid").new(self.m_scrollView2_InfinityGrid, "HeroActivity/UIHeroAct103TaskItem")
  self.m_DailyTaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_dailytasklist_InfinityGrid, "HeroActivity/UIHeroAct103DailyTaskRewardItem")
  self.TabEnum = {DailyTask = 1, NormalTask = 2}
  self.iCurSelectTab = self.TabEnum.DailyTask
end

function Form_103Achievement:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_103Achievement:OnInactive()
  self.super.OnInactive(self)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

function Form_103Achievement:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

function Form_103Achievement:AddEventListeners()
  self:addEventListener("eGameEvent_ActTask_GetReward", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_ActTask_GetAllReward", handler(self, self.RefreshUI))
end

function Form_103Achievement:InitData()
  self.iActId = self.m_csui.m_param.main_id
  self.iSubActId = self.m_csui.m_param.sub_id
  self.iDailySubActId = self.m_csui.m_param.iDailySubActId
  self.m_cfgList, self.m_pinCfgList = HeroActivityManager:GetActTaskCfgByActiveId(self.iActId)
  self.m_DailyCfgList, self.m_DailyPinCfgList = HeroActivityManager:GetActDailyTaskCfgByActiveId(self.iActId)
end

function Form_103Achievement:RefreshUI()
  local cfgList, pinCfgList, InfinityGrid
  if self.iCurSelectTab == self.TabEnum.DailyTask then
    cfgList = self.m_DailyCfgList
    pinCfgList = self.m_DailyPinCfgList
    InfinityGrid = self.m_TaskListInfinityGrid1
    self.m_pnl_dailytask:SetActive(true)
    self.m_pnl_dailylist:SetActive(true)
    self.m_pnl_achive:SetActive(false)
    self.m_pnl_achivelist:SetActive(false)
    self.m_pnl_toggle_daygrey:SetActive(false)
    self.m_pnl_toggle_daylight:SetActive(true)
    self.m_pnl_toggle_achivegrey:SetActive(true)
    self.m_pnl_toggle_achivelight:SetActive(false)
  else
    cfgList = self.m_cfgList
    pinCfgList = self.m_pinCfgList
    InfinityGrid = self.m_TaskListInfinityGrid2
    self.m_pnl_dailytask:SetActive(false)
    self.m_pnl_dailylist:SetActive(false)
    self.m_pnl_achive:SetActive(true)
    self.m_pnl_achivelist:SetActive(true)
    self.m_pnl_toggle_daygrey:SetActive(true)
    self.m_pnl_toggle_daylight:SetActive(false)
    self.m_pnl_toggle_achivegrey:SetActive(false)
    self.m_pnl_toggle_achivelight:SetActive(true)
  end
  local taskDataList = HeroActivityManager:GetActTaskData(self.iActId, cfgList)
  local pinTaskDataList = HeroActivityManager:GetActTaskData(self.iActId, pinCfgList)
  if pinTaskDataList and 0 < #pinTaskDataList then
    local function sortFun(data1, data2)
      local cfg1 = data1.cfg
      
      local cfg2 = data2.cfg
      local sort1 = cfg1.m_Sort
      local sort2 = cfg2.m_Sort
      if sort1 == sort2 then
        return cfg1.m_UID < cfg2.m_UID
      else
        return sort1 < sort2
      end
    end
    
    table.sort(pinTaskDataList, sortFun)
    self.m_pinTaskData = nil
    for i, v in ipairs(pinTaskDataList) do
      local preTaskState = HeroActivityManager:CheckTaskStateByTaskId(self.iActId, v.cfg.m_PreTask)
      if (v.serverData.iState ~= TaskManager.TaskState.Completed or v.serverData.iState == TaskManager.TaskState.Completed and v.cfg.m_Invisible ~= 1) and preTaskState == TaskManager.TaskState.Completed then
        self.m_pinTaskData = v
      end
    end
    if self.m_pinTaskData then
      table.insert(taskDataList, 1, self.m_pinTaskData)
    end
  end
  InfinityGrid:ShowItemList(taskDataList)
  InfinityGrid:LocateTo(0)
  self:CheckShowEnterAnim()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  if self.iCurSelectTab == self.TabEnum.DailyTask then
    local cfgs = HeroActivityManager:GetActTaskDailyRewardCfg()
    local list = {}
    for _, v in ipairs(cfgs) do
      table.insert(list, {
        cfg = v,
        iActId = self.iActId
      })
    end
    self.m_DailyTaskListInfinityGrid:ShowItemList(list)
    self.m_DailyTaskListInfinityGrid:LocateTo(0)
    local data = HeroActivityManager:GetActTaskServerData(self.iActId)
    local isAllCompleted = data and data.iDaiyQuestActive and data.iDaiyQuestActive >= cfgs[#cfgs].m_RequiredScore
    if isAllCompleted then
      self:ShowCutDownTime()
      self.m_img_maskdaily:SetActive(true)
    else
      self.m_img_maskdaily:SetActive(false)
    end
  end
  local flag = HeroActivityManager:CheckTaskCanReceive(self.iActId, self.iCurSelectTab == self.TabEnum.DailyTask)
  self.m_bg_getall_normal:SetActive(flag)
  self.m_bg_getall_grey:SetActive(not flag)
  self.m_reddot1:SetActive(HeroActivityManager:CheckTaskCanReceive(self.iActId, true))
  self.m_reddot2:SetActive(HeroActivityManager:CheckTaskCanReceive(self.iActId))
end

function Form_103Achievement:CheckShowEnterAnim()
  local grid = self.iCurSelectTab == self.TabEnum.DailyTask and self.m_TaskListInfinityGrid1 or self.m_TaskListInfinityGrid2
  local ItemList = grid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  if self.m_isInit then
    TimeService:SetTimer(0.6, 1, function()
      self:ShowItemListAnim()
    end)
    self.m_isInit = false
  elseif self.m_isActive then
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
    self.m_isActive = false
  else
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
  end
end

function Form_103Achievement:ShowItemListAnim()
  local grid = self.iCurSelectTab == self.TabEnum.DailyTask and self.m_TaskListInfinityGrid1 or self.m_TaskListInfinityGrid2
  local ItemList = grid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  for i, Item in ipairs(ItemList) do
    local tempObj = Item:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.051 * (i - 1), 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, "luoleilai_achievement_task_in")
    end)
  end
end

function Form_103Achievement:ShowCutDownTime()
  local curTimer = TimeUtil:GetServerTimeS()
  local left_time = TimeUtil:GetServerNextCommonResetTime() - curTimer
  if left_time <= 0 then
    self.m_txt_time_Text.text = ""
    return
  end
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  self.m_timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.m_timer)
      self:OnBackClk()
    end
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  end)
end

function Form_103Achievement:OnBtngetallClicked()
  if self.iCurSelectTab == self.TabEnum.DailyTask then
    local flag = HeroActivityManager:CheckTaskCanReceive(self.iActId, self.iCurSelectTab == self.TabEnum.DailyTask)
    if flag then
      local vQuestId = HeroActivityManager:GetDailyTaskCanReceiveList(self.iActId)
      HeroActivityManager:ReqLamiaDailyQuestGetAwardCS(self.iActId, vQuestId)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20018))
    end
  else
    local flag = HeroActivityManager:CheckTaskCanReceive(self.iActId, self.iCurSelectTab == self.TabEnum.DailyTask)
    if flag then
      HeroActivityManager:ReqLamiaQuestGetAllAwardCS(self.iActId)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20018))
    end
  end
end

function Form_103Achievement:OnBtnswitch1Clicked()
  if self.iCurSelectTab == self.TabEnum.DailyTask then
    return
  end
  self.iCurSelectTab = self.TabEnum.DailyTask
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_103Achievement:OnBtnswitch2Clicked()
  if self.iCurSelectTab == self.TabEnum.NormalTask then
    return
  end
  self.iCurSelectTab = self.TabEnum.NormalTask
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(303)
end

function Form_103Achievement:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_103Achievement", Form_103Achievement)
return Form_103Achievement
