local Form_Activity110_Warmup_Task = class("Form_Activity110_Warmup_Task", require("UI/UIFrames/Form_Activity110_Warmup_TaskUI"))
local MiniGameFlopClueRewardsIns = ConfigManager:GetConfigInsByName("MiniGameFlopClueRewards")

function Form_Activity110_Warmup_Task:SetInitParam(param)
end

function Form_Activity110_Warmup_Task:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaTaskListInfinityGrid = self:CreateInfinityGrid(self.m_task_list_InfinityGrid, "ActTask/Act110TaskItem", initGridData)
end

function Form_Activity110_Warmup_Task:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_MiniGameTaskGetReward", handler(self, self.OnDealGetRewardFresh))
end

function Form_Activity110_Warmup_Task:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Activity110_Warmup_Task:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_Activity110_Warmup_Task:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activity = tParam.act
  end
  if not self.m_activity then
    self:CloseForm()
    return
  end
  self.m_showTaskListCfg = {}
  local groupIdList = self.m_activity:GetClueGroupTaskList()
  for _, groupId in pairs(groupIdList) do
    local taskCfg = MiniGameFlopClueRewardsIns:GetValue_ByGroupID(groupId)
    table.insert(self.m_showTaskListCfg, {
      cfg = taskCfg,
      act = self.m_activity
    })
  end
  
  local function getPriority(task)
    if task.act:IsTaskPendingReward(task.cfg.m_GroupID) then
      return 1
    elseif not task.act:IsTaskPendingReward(task.cfg.m_GroupID) and not task.act:IsRewardClaimed(task.cfg.m_GroupID) then
      return 2
    elseif task.act:IsRewardClaimed(task.cfg.m_GroupID) then
      return 3
    end
  end
  
  table.sort(self.m_showTaskListCfg, function(a, b)
    local priorityA = getPriority(a)
    local priorityB = getPriority(b)
    if priorityA ~= priorityB then
      return priorityA < priorityB
    end
    return a.cfg.m_GroupID < b.cfg.m_GroupID
  end)
end

function Form_Activity110_Warmup_Task:FreshUI()
  self.m_luaTaskListInfinityGrid:ShowItemList(self.m_showTaskListCfg)
  local isCanShowGetBtn = self.m_activity:GetPendingRewardTasks()
  self.m_btn_get:SetActive(isCanShowGetBtn)
  self.m_btn_get_grey:SetActive(not isCanShowGetBtn)
end

function Form_Activity110_Warmup_Task:OnDealGetRewardFresh(param)
  if param and param.actId == self.m_activity:getID() and table.getn(param.reward) > 0 then
    utils.popUpRewardUI(param.reward, function()
      self:FreshData()
      self:FreshUI()
    end)
  end
end

function Form_Activity110_Warmup_Task:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_Activity110_Warmup_Task:OnBtngetClicked()
  local isCanShowGetBtn, taskIdList = self.m_activity:GetPendingRewardTasks()
  self.m_activity:RequestGroupRewardCS(taskIdList)
end

function Form_Activity110_Warmup_Task:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_Warmup_Task", Form_Activity110_Warmup_Task)
return Form_Activity110_Warmup_Task
