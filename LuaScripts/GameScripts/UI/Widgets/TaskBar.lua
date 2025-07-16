local TaskBar = class("TaskBar")
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function TaskBar:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_rootTrans = self.m_goRoot.transform
  UILuaHelper.BindViewObjectsManual(self, self.m_goRoot, "TaskBar")
  self.m_curMainTaskCfg = nil
  self.m_canReceiveTaskType = 0
  self:RefreshShowTaskUI()
  self:AddListener()
end

function TaskBar:OnUpdate(dt)
end

function TaskBar:AddListener()
  self.m_handleId = EventCenter.AddListener(EventDefine.eGameEvent_Task_Change_State, handler(self, self.RefreshShowTaskUI))
  self.m_handleId2 = EventCenter.AddListener(EventDefine.eGameEvent_Group_Main_Task_Reward, handler(self, self.OnLastTaskGroupGetReward))
end

function TaskBar:RemoveListener()
  if self.m_handleId then
    EventCenter.RemoveListener(EventDefine.eGameEvent_Task_Change_State, self.m_handleId)
    self.m_handleId = nil
  end
  if self.m_handleId2 then
    EventCenter.RemoveListener(EventDefine.eGameEvent_Task_Change_State, self.m_handleId2)
    self.m_handleId2 = nil
  end
end

function TaskBar:RefreshShowTaskUI()
  if utils.isNull(self.m_goRoot) then
    if self and self.RemoveListener then
      self:RemoveListener()
    end
    return
  end
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  self.m_goRoot:SetActive(openFlag)
  if not openFlag then
    return
  end
  local isOver = TaskManager:CheckMainTaskIsOver()
  self.m_canReceiveTaskType = TaskManager:CheckTaskEnterRedDot()
  if isOver then
    self.m_txt_task_content_Text.text = self.m_canReceiveTaskType > 0 and ConfigManager:GetCommonTextById(20107) or ConfigManager:GetCommonTextById(20106)
    self.m_btn_go:SetActive(false)
  else
    self.m_curMainTaskCfg = TaskManager:GetCurMainTaskCfg()
    if self.m_curMainTaskCfg then
      self.m_txt_task_content_Text.text = tostring(TaskManager:GetTaskNameById(self.m_curMainTaskCfg.m_ID, self.m_curMainTaskCfg))
    else
      local rewardCfg, mainGroupIsOver = TaskManager:GetCurMainGroupRewardCfg()
      if not mainGroupIsOver and not rewardCfg:GetError() then
        self.m_txt_task_content_Text.text = rewardCfg.m_mRewardDes
      end
    end
    if self.m_curMainTaskCfg and (not self.m_curMainTaskCfg.m_Jump or self.m_curMainTaskCfg.m_Jump == 0) then
      self.m_btn_go:SetActive(false)
    else
      self.m_btn_go:SetActive(true)
    end
  end
  self.m_task_redpoint:SetActive(self.m_canReceiveTaskType > 0)
end

function TaskBar:OnLastTaskGroupGetReward()
  local isOver = TaskManager:CheckMainTaskGroupIsOver(TaskManager:GetCurMainTaskGroupId())
  if isOver then
    self:RefreshShowTaskUI()
  end
end

function TaskBar:OnOpenTaskMainUI()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local chooseTab = self.m_canReceiveTaskType ~= 0 and self.m_canReceiveTaskType or nil
  StackFlow:Push(UIDefines.ID_FORM_TASK, {chooseTab = chooseTab})
end

function TaskBar:OnTaskGoUI()
  if self.m_curMainTaskCfg and self.m_curMainTaskCfg.m_Jump ~= 0 then
    QuickOpenFuncUtil:OpenFunc(self.m_curMainTaskCfg.m_Jump)
  end
end

function TaskBar:OnBtntaskClicked()
  self:OnOpenTaskMainUI()
end

function TaskBar:OnBtngoClicked()
  self:OnTaskGoUI()
end

function TaskBar:OnDestroy()
  self:RemoveListener()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_goRoot, "TaskBar")
end

return TaskBar
