local Form_EuipCrossTask = class("Form_EuipCrossTask", require("UI/UIFrames/Form_EuipCrossTaskUI"))
local taskCfgIns = ConfigManager:GetConfigInsByName("Task")

function Form_EuipCrossTask:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    OnReceiveReward = function(vQuestId)
      self:OnReceiveReward(vQuestId)
    end
  }
  self.m_task_list_Grid = self:CreateInfinityGrid(self.m_task_list_InfinityGrid, "PartDungeonWelfare/UIEuipCrossTaskItem", initGridData)
end

function Form_EuipCrossTask:OnActive()
  self.super.OnActive(self)
  self.m_activity = self.m_csui.m_param
  self:AddEventListeners()
  self:Refresh()
end

function Form_EuipCrossTask:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_EuipCrossTask:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_PartDungeonWelfare_QuestStatuChange", handler(self, self.OnQuestStatuChange))
end

function Form_EuipCrossTask:OnQuestStatuChange()
  self:Refresh()
end

function Form_EuipCrossTask:Refresh()
  if self.m_activity then
    self.m_quests = self.m_activity:GetQuestStatus()
    self.m_overQuests = self.m_activity:GetOverQuests()
    if self.m_task_list_Grid then
      local data = self:GeneratedData()
      self.m_task_list_Grid:ShowItemList(data, true)
      self.m_task_list_Grid:LocateTo(0)
    end
  end
end

function Form_EuipCrossTask:GeneratedData()
  local data = {}
  for i, v in pairs(self.m_quests) do
    local cfg = taskCfgIns:GetValue_ByID(i)
    table.insert(data, {
      id = v.iId,
      state = v.iState,
      rewards = utils.changeCSArrayToLuaTable(cfg.m_Reward),
      content = cfg.m_mTaskName
    })
  end
  for _, v in pairs(self.m_overQuests) do
    local cfg = taskCfgIns:GetValue_ByID(v)
    table.insert(data, {
      id = v,
      state = MTTDProto.QuestState_Over,
      condStep = cfg.m_ObjectiveCount,
      objectiveCount = cfg.m_ObjectiveCount,
      rewards = utils.changeCSArrayToLuaTable(cfg.m_Reward)
    })
  end
  local statePriority = {
    [MTTDProto.QuestState_Finish] = 1,
    [MTTDProto.QuestState_Doing] = 2,
    [MTTDProto.QuestState_Over] = 3
  }
  table.sort(data, function(a, b)
    if statePriority[a.state] ~= statePriority[b.state] then
      return statePriority[a.state] < statePriority[b.state]
    end
    return a.id < b.id
  end)
  return data
end

function Form_EuipCrossTask:OnReceiveReward(vQuestId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_PartDungeonWelfare)
  if activity and activity:checkCondition() then
    activity:RequestReceiveTask(vQuestId)
  end
end

local fullscreen = true
ActiveLuaUI("Form_EuipCrossTask", Form_EuipCrossTask)
return Form_EuipCrossTask
