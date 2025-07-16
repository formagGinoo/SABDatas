local Form_Task = class("Form_Task", require("UI/UIFrames/Form_TaskUI"))
local TaskPanelTab = {
  Daily = TaskManager.TaskType.Daily,
  Weekly = TaskManager.TaskType.Weekly,
  MainTask = TaskManager.TaskType.MainTask,
  Achievement = TaskManager.TaskType.Achievement
}

function Form_Task:SetInitParam(param)
end

function Form_Task:AfterInit()
  self.super.AfterInit(self)
  self.m_subPanelData = {
    [TaskPanelTab.Daily] = {
      panelRoot = self.m_pnl_task_daily,
      imgTab = self.m_btn_daily_Image,
      txtTab = self.m_z_txt_daily_Text,
      subPanelName = "DailyTaskSubPanel",
      selImg = self.m_btn_bg01,
      redDot = self.m_icon_redpoint01,
      txt_sel = self.m_z_txt_daily,
      txt_black = self.m_z_txt_daily_black,
      backFun = function()
      end
    },
    [TaskPanelTab.Weekly] = {
      panelRoot = self.m_pnl_task_weekly,
      imgTab = self.m_btn_weekly_Image,
      txtTab = self.m_z_txt_weekly_Text,
      subPanelName = "WeeklyTaskSubPanel",
      selImg = self.m_btn_bg02,
      redDot = self.m_icon_redpoint02,
      txt_sel = self.m_z_txt_weekly,
      txt_black = self.m_z_txt_weekly_black,
      backFun = function()
      end
    },
    [TaskPanelTab.Achievement] = {
      panelRoot = self.m_pnl_task_achievement,
      imgTab = self.m_btn_achievement_Image,
      txtTab = self.m_z_txt_achievement_Text,
      subPanelName = "AchievementTaskSubPanel",
      selImg = self.m_btn_bg04,
      redDot = self.m_icon_redpoint04,
      txt_sel = self.m_z_txt_achievement,
      txt_black = self.m_z_txt_achievement_black,
      backFun = function()
      end
    },
    [TaskPanelTab.MainTask] = {
      panelRoot = self.m_pnl_task_maintask,
      imgTab = self.m_btn_main_Image,
      txtTab = self.m_z_txt_level_Text,
      subPanelName = "MainTaskSubPanel",
      selImg = self.m_btn_bg03,
      redDot = self.m_icon_redpoint03,
      txt_sel = self.m_z_txt_level,
      txt_black = self.m_z_txt_level_black,
      backFun = nil
    }
  }
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self:CheckRegisterRedDot()
  self.isShowOne = true
end

function Form_Task:OnActive()
  self.isShowOne = true
  self.super.OnActive(self)
  self.m_curChooseTab = TaskPanelTab.Daily
  TaskManager:CheckDailyTaskRedDot()
  TaskManager:CheckWeeklyTaskRedDot()
  TaskManager:CheckAchievementTaskRedDot()
  TaskManager:CheckMainTaskRedDot()
  self:RefreshData()
  self:RefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(79)
end

function Form_Task:OnInactive()
  TaskManager:SetisFirstTakeReward(true)
  TaskManager:StopTakeRewardVoice()
end

function Form_Task:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint01, RedDotDefine.ModuleType.TaskDaily)
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint02, RedDotDefine.ModuleType.TaskWeekly)
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint03, RedDotDefine.ModuleType.TaskMain)
  self:RegisterOrUpdateRedDotItem(self.m_icon_redpoint04, RedDotDefine.ModuleType.TaskAchievement)
end

function Form_Task:RefreshData()
  local tParam = self.m_csui.m_param
  if tParam and tParam.chooseTab then
    self.m_curChooseTab = tParam.chooseTab
  end
end

function Form_Task:RefreshUI()
  self:ChangeTaskTab(self.m_curChooseTab)
end

function Form_Task:OnUpdate(dt)
  for i, v in ipairs(self.m_subPanelData) do
    if v.subPanelLua and v.subPanelLua.OnUpdate then
      v.subPanelLua:OnUpdate(dt)
    end
  end
end

function Form_Task:ChangeTaskTab(index)
  if index then
    self.m_curChooseTab = index
    self:ChangeTaskTabStyle(index)
    local curSubPanelData = self.m_subPanelData[index]
    if curSubPanelData then
      if curSubPanelData.subPanelLua == nil then
        local initData = curSubPanelData.backFun and {
          backFun = curSubPanelData.backFun
        } or nil
        
        local function loadCallBack(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
            if self.isShowOne then
              if subPanelLua.OpenSubAnim then
                subPanelLua:OpenSubAnim()
              end
            elseif subPanelLua.PlayAnimItem then
              subPanelLua:PlayAnimItem()
            end
            if subPanelLua.OnHidePanel then
              subPanelLua:OnHidePanel()
            end
            if subPanelLua.OnActivePanel then
              subPanelLua:OnActivePanel()
            end
            self.isShowOne = false
          end
        end
        
        SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {initData = initData}, loadCallBack)
      else
        self:RefreshCurTabSubPanelInfo()
      end
    end
  end
end

function Form_Task:RefreshCurTabSubPanelInfo()
  if not self.m_curChooseTab then
    return
  end
  for i, v in ipairs(self.m_subPanelData) do
    if v.subPanelLua then
      if i == self.m_curChooseTab then
        if v.subPanelLua.OnHidePanel then
          v.subPanelLua:OnHidePanel()
        end
        if v.subPanelLua.OnActivePanel then
          v.subPanelLua:OnActivePanel()
        end
      elseif v.subPanelLua.OnHidePanel then
        v.subPanelLua:OnHidePanel()
      end
    end
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    subPanelLua:SetActive(true)
    if self.isShowOne == true then
      if subPanelLua.OpenSubAnim then
        subPanelLua:OpenSubAnim()
      end
      self.isShowOne = false
    elseif subPanelLua.PlayAnimItem then
      subPanelLua:PlayAnimItem()
    end
    subPanelLua:OnFreshData()
  end
end

function Form_Task:ChangeTaskTabStyle(index)
  for i, v in ipairs(self.m_subPanelData) do
    if i == index then
      v.selImg:SetActive(true)
      v.txt_sel:SetActive(true)
      v.txt_black:SetActive(false)
    else
      if v.subPanelLua then
        v.subPanelLua:SetActive(false)
      end
      v.selImg:SetActive(false)
      v.txt_sel:SetActive(false)
      v.txt_black:SetActive(true)
    end
  end
end

function Form_Task:OnTabClk(index)
  if not index then
    return
  end
  if index == self.m_curChooseTab then
    return
  end
  self:ChangeTaskTab(index)
end

function Form_Task:OnBtndailyClicked()
  self:OnTabClk(TaskPanelTab.Daily)
end

function Form_Task:OnBtnweeklyClicked()
  self:OnTabClk(TaskPanelTab.Weekly)
end

function Form_Task:OnBtnmainClicked()
  self:OnTabClk(TaskPanelTab.MainTask)
end

function Form_Task:OnBtnachievementClicked()
  self:OnTabClk(TaskPanelTab.Achievement)
end

function Form_Task:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:HideSubPanel()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TASK)
end

function Form_Task:OnBtnhomeClicked()
  self:HideSubPanel()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  if GameSceneManager then
    local curSceneCom = GameSceneManager:GetCurScene()
    if curSceneCom and curSceneCom:GetSceneID() ~= GameSceneManager.SceneID.MainCity then
      GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
    end
  end
end

function Form_Task:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_subPanelData then
    self:HideSubPanel()
    for i, panelData in pairs(self.m_subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
  end
end

function Form_Task:HideSubPanel()
  if table.getn(self.m_subPanelData) > 0 then
    for i, v in ipairs(self.m_subPanelData) do
      if v.subPanelLua and v.subPanelLua.OnHidePanel then
        v.subPanelLua:OnHidePanel()
      end
    end
  end
end

function Form_Task:IsFullScreen()
  return true
end

function Form_Task:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "DailyTaskSubPanel",
    "WeeklyTaskSubPanel",
    "AchievementTaskSubPanel",
    "MainTaskSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Task", Form_Task)
return Form_Task
