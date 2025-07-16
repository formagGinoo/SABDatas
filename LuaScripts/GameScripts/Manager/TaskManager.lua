local BaseManager = require("Manager/Base/BaseManager")
local TaskManager = class("TaskManager", BaseManager)
TaskManager.TaskType = {
  Daily = 1,
  Weekly = 2,
  MainTask = 3,
  Achievement = 4,
  ChapterProgress = 5,
  RogueAchievement = 6
}
TaskManager.TaskTypeEnum = {
  [TaskManager.TaskType.Daily] = true,
  [TaskManager.TaskType.Weekly] = true,
  [TaskManager.TaskType.MainTask] = true,
  [TaskManager.TaskType.Achievement] = true,
  [TaskManager.TaskType.ChapterProgress] = true,
  [TaskManager.TaskType.RogueAchievement] = true
}
TaskManager.TaskCollection = {
  TaskManager.TaskType.Daily,
  TaskManager.TaskType.Weekly,
  TaskManager.TaskType.MainTask,
  TaskManager.TaskType.Achievement
}
TaskManager.TaskState = {
  Doing = 1,
  Finish = 2,
  Completed = 3
}
TaskManager.TaskStepOver = 999

function TaskManager:OnCreate()
  self.m_mainTaskGroupId = 1
  self.m_dailyTaskList = {}
  self.m_weeklyTaskList = {}
  self.m_mainTaskList = {}
  self.m_achievementTaskList = {}
  self.m_chapterProgressTaskList = {}
  self.m_rogueachievementTaskList = {}
  self.m_taskAll = {
    [TaskManager.TaskType.Daily] = self.m_dailyTaskList,
    [TaskManager.TaskType.Weekly] = self.m_weeklyTaskList,
    [TaskManager.TaskType.MainTask] = self.m_mainTaskList,
    [TaskManager.TaskType.Achievement] = self.m_achievementTaskList,
    [TaskManager.TaskType.ChapterProgress] = self.m_chapterProgressTaskList,
    [TaskManager.TaskType.RogueAchievement] = self.m_rogueachievementTaskList
  }
  self.m_taskOverList = {
    [TaskManager.TaskType.Daily] = {},
    [TaskManager.TaskType.Weekly] = {},
    [TaskManager.TaskType.MainTask] = {},
    [TaskManager.TaskType.Achievement] = {},
    [TaskManager.TaskType.ChapterProgress] = {},
    [TaskManager.TaskType.RogueAchievement] = {}
  }
  self.m_mainTaskGroupOverList = {}
  self.m_achievementScore = 0
  self.m_achievementReceivedRewardIdList = {}
  self.m_mainTaskIdGroup = {}
  self.m_dailyRewardCfgScore = 0
  self.m_weeklyRewardCfgScore = 0
  self.isEnterTaskTakeReward = true
  self.m_rogueachievementScore = 0
  self.m_rogueachievementReceivedRewardIdList = {}
end

function TaskManager:OnInitNetwork()
  RPCS():Listen_Push_SetQuestDataBatch(handler(self, self.OnPushSetQuestDataBatch), "TaskManager")
  RPCS():Listen_Push_DailyRefresh(handler(self, self.OnPushDailyRefresh), "TaskManager")
  RPCS():Listen_Push_Quest_AchieveScore(handler(self, self.OnPushQuestAchieveScore), "TaskManager")
end

function TaskManager:OnAfterInitConfig()
  self:InitTaskMainIdGroup()
  self:InitRogueAchievementTaskIdGroup()
end

function TaskManager:InitTaskMainIdGroup()
  self.m_mainTaskIdGroup = {}
  local taskMainRewardIns = CS.CData_TaskMainReward.GetInstance()
  local cfgAll = taskMainRewardIns:GetAll()
  for groupId, v in pairs(cfgAll) do
    local taskList = v.m_TaskList
    if taskList then
      for i = 0, taskList.Length - 1 do
        self.m_mainTaskIdGroup[taskList[i]] = groupId
      end
    end
  end
end

function TaskManager:InitRogueAchievementTaskIdGroup()
  self.m_rogueachievementLastTaskList = {}
  local t = {}
  local RogueTaskAchieveIns = ConfigManager:GetConfigInsByName("RogueTaskAchieve")
  local cfgAll = RogueTaskAchieveIns:GetAll()
  for _, v in pairs(cfgAll) do
    if v.m_TaskGroup and v.m_TaskGroup > 0 then
      t[v.m_TaskGroup] = t[v.m_TaskGroup] or {}
      t[v.m_TaskGroup][v.m_Sequence] = v.m_TaskID
    end
  end
  for k, v in pairs(t) do
    self.m_rogueachievementLastTaskList[v[#v]] = true
  end
end

function TaskManager:OnDailyReset()
end

function TaskManager:OnPushDailyRefresh(stData, msg)
  local bWeekChange = stData.bWeekChange
  if bWeekChange and self.m_taskOverList and self.m_taskOverList[TaskManager.TaskType.Weekly] then
    self.m_taskOverList[TaskManager.TaskType.Weekly] = {}
    self:ResetTaskDataByType(TaskManager.TaskType.Weekly)
    self:CheckWeeklyTaskRedDot()
  end
  if self.m_taskOverList and self.m_taskOverList[TaskManager.TaskType.Daily] then
    self.m_taskOverList[TaskManager.TaskType.Daily] = {}
    self:ResetTaskDataByType(TaskManager.TaskType.Daily)
    self:CheckDailyTaskRedDot()
  end
end

function TaskManager:OnPushQuestAchieveScore(stData, msg)
  if stData and stData.iQuestType == MTTDProto.QuestType_Achievement then
    self.m_achievementScore = stData.iScore
  elseif stData and stData.iQuestType == MTTDProto.QuestType_RogueAchieve then
    self.m_rogueachievementScore = stData.iScore
  end
end

function TaskManager:ReqTakeReward(taskType, taskIds)
  if self:GetisFirstTakeReward() then
    local closeVoice = ConfigManager:GetGlobalSettingsByKey("TaskVoice")
    CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
      self.m_playingId = playingId
    end, function()
      self.m_playingId = nil
    end)
    self:SetisFirstTakeReward(false)
  end
  if type(taskIds) == "number" then
    taskIds = {taskIds}
  end
  if not taskIds or #taskIds == 0 then
    return
  end
  local questCSMsg = MTTDProto.Cmd_Quest_TakeReward_CS()
  questCSMsg.iQuestType = taskType
  questCSMsg.vQuestId = taskIds
  RPCS():Quest_TakeReward(questCSMsg, handler(self, self.OnTakeRewardSC), handler(self, self.OnTakeRewardFailedSC))
end

function TaskManager:GetisFirstTakeReward()
  return self.isEnterTaskTakeReward
end

function TaskManager:SetisFirstTakeReward(isFirst)
  self.isEnterTaskTakeReward = isFirst
end

function TaskManager:StopTakeRewardVoice()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function TaskManager:ReqTakeMainGroupReward()
  local questCSMsg = MTTDProto.Cmd_Quest_TakeMainGroupReward_CS()
  RPCS():Quest_TakeMainGroupReward(questCSMsg, handler(self, self.OnTakeMainGroupRewardSC), handler(self, self.OnTakeMainGroupRewardFailedSC))
end

function TaskManager:OnTakeMainGroupRewardSC(data, msg)
  local reward = data.vReward
  table.insert(self.m_mainTaskGroupOverList, data.iOldMainGroup)
  self.m_mainTaskGroupId = data.iNewMainGroup
  if reward and next(reward) then
    utils.popUpRewardUI(reward)
  end
  self:broadcastEvent("eGameEvent_Group_Main_Task_Reward", {isGroupTask = true})
end

function TaskManager:OnTakeMainGroupRewardFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  self:broadcastEvent("eGameEvent_Task_GetRewardFailed")
  NetworkManager:OnRpcCallbackFail(msg)
end

function TaskManager:OnTakeRewardSC(data, msg)
  local reward = data.vReward
  local activeReward = data.vActiveReward
  local iQuestType = data.iQuestType
  
  local function callBack()
    if iQuestType == TaskManager.TaskType.Achievement then
      self:broadcastEvent("eGameEvent_Task_AchieveTakeReward")
    end
  end
  
  if reward and next(reward) then
    utils.popUpRewardUI(reward, callBack)
  end
  if activeReward and next(activeReward) then
    self:broadcastEvent("eGameEvent_Task_GetReward", {
      reward = activeReward,
      questType = data.iQuestType
    })
  end
end

function TaskManager:OnTakeRewardFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  self:broadcastEvent("eGameEvent_Task_GetRewardFailed")
  NetworkManager:OnRpcCallbackFail(msg)
end

function TaskManager:ReqTakeAchieveRewardReward(iRewardId, vQuestId, iQuestType)
  local questCSMsg = MTTDProto.Cmd_Quest_TakeAchieveReward_CS()
  questCSMsg.iRewardId = iRewardId
  questCSMsg.vQuestId = vQuestId
  questCSMsg.iQuestType = iQuestType
  RPCS():Quest_TakeAchieveReward(questCSMsg, handler(self, self.OnTakeAchieveRewardSC), handler(self, self.OnTakeRewardFailedSC))
end

function TaskManager:OnTakeAchieveRewardSC(data, msg)
  local reward = data.vReward
  local callBack
  if data and data.iQuestType == MTTDProto.QuestType_Achievement then
    self.m_achievementReceivedRewardIdList[#self.m_achievementReceivedRewardIdList + 1] = data.iRewardId
    
    function callBack()
      self:broadcastEvent("eGameEvent_Task_TakeAchieveReward")
    end
    
    self:CheckAchievementTaskRedDot()
    self:broadcastEvent("eGameEvent_Task_Change_State")
  elseif data and data.iQuestType == MTTDProto.QuestType_RogueAchieve then
    self.m_rogueachievementReceivedRewardIdList[#self.m_rogueachievementReceivedRewardIdList + 1] = data.iRewardId
    
    function callBack()
      self:CheckRogueAchievementReddot()
      self:broadcastEvent("eGameEvent_RogueStage_TakeAchieveReward")
    end
    
    self:broadcastEvent("eGameEvent_RogueAchievement_TaskUpdate")
  end
  if reward and next(reward) then
    utils.popUpRewardUI(reward, callBack)
  end
end

function TaskManager:OnTaskGetInitSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_mainTaskGroupId = taskData.iMainGroup
  self.m_mainTaskGroupOverList = taskData.vOverMainGroup
  self.m_achievementScore = taskData.iAchieveScore
  self.m_achievementReceivedRewardIdList = taskData.vTakenAchieveReward
  self.m_rogueachievementScore = taskData.iRogueAchieveScore
  self.m_rogueachievementReceivedRewardIdList = taskData.vTakenRogueAchieveReward
end

function TaskManager:OnDailyTaskSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_dailyTaskList = {}
  self:SetTaskDataListByType(TaskManager.TaskType.Daily, self.m_dailyTaskList)
  for i, v in pairs(taskData.vQuest) do
    self.m_dailyTaskList[#self.m_dailyTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.Daily)
  end
  self.m_taskOverList[TaskManager.TaskType.Daily] = taskData.vOver
  self:CheckDailyTaskRedDot()
end

function TaskManager:OnWeeklyTaskSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_weeklyTaskList = {}
  self:SetTaskDataListByType(TaskManager.TaskType.Weekly, self.m_weeklyTaskList)
  for i, v in pairs(taskData.vQuest) do
    self.m_weeklyTaskList[#self.m_weeklyTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.Weekly)
  end
  self.m_taskOverList[TaskManager.TaskType.Weekly] = taskData.vOver
  self:CheckWeeklyTaskRedDot()
end

function TaskManager:OnMainTaskSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_mainTaskList = {}
  self:SetTaskDataListByType(TaskManager.TaskType.MainTask, self.m_mainTaskList)
  for i, v in pairs(taskData.vQuest) do
    self.m_mainTaskList[#self.m_mainTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.MainTask)
  end
  self.m_taskOverList[TaskManager.TaskType.MainTask] = taskData.vOver
  self:CheckMainTaskRedDot()
end

function TaskManager:OnChapterProgressTaskSC(taskData, msg)
  if not taskData then
    return
  end
  for i, v in pairs(taskData.vQuest) do
    self.m_chapterProgressTaskList[#self.m_chapterProgressTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.MainTask)
  end
  self.m_taskOverList[TaskManager.TaskType.ChapterProgress] = taskData.vOver
end

function TaskManager:OnAchievementTaskSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_achievementTaskList = {}
  self:SetTaskDataListByType(TaskManager.TaskType.Achievement, self.m_achievementTaskList)
  for i, v in pairs(taskData.vQuest) do
    self.m_achievementTaskList[#self.m_achievementTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.Achievement)
  end
  self.m_taskOverList[TaskManager.TaskType.Achievement] = taskData.vOver
  self:CheckAchievementTaskRedDot()
end

function TaskManager:OnRogueAchievementTaskSC(taskData, msg)
  if not taskData then
    return
  end
  self.m_rogueachievementTaskList = {}
  self:SetTaskDataListByType(TaskManager.TaskType.RogueAchievement, self.m_rogueachievementTaskList)
  for i, v in pairs(taskData.vQuest) do
    self.m_rogueachievementTaskList[#self.m_rogueachievementTaskList + 1] = v
  end
  for i, taskId in ipairs(taskData.vOver) do
    self:CreateOverTaskInfo(taskId, TaskManager.TaskType.RogueAchievement)
  end
  self.m_taskOverList[TaskManager.TaskType.RogueAchievement] = taskData.vOver
  self:CheckRogueAchievementReddot()
end

function TaskManager:OnPushSetQuestDataBatch(stTaskData, msg)
  local taskList = stTaskData.vCmdQuestInfo
  self.m_mainTaskGroupId = stTaskData.iMainGroup or self.m_mainTaskGroupId
  local isGetReward = false
  local typeList = {}
  if taskList then
    for i, taskServerInfo in pairs(taskList) do
      if TaskManager.TaskTypeEnum[taskServerInfo.iType] then
        local list = self:GetTaskDataListByType(taskServerInfo.iType)
        local isHave = false
        for m, taskInfo in pairs(list) do
          if taskInfo.iId == taskServerInfo.iId then
            if taskServerInfo.iState == TaskManager.TaskState.Completed then
              self:SetTaskOverDataListByType(taskServerInfo.iType, taskServerInfo.iId)
              isGetReward = true
              taskServerInfo.vCondStep[1] = taskServerInfo.vCondStep[1] == nil and TaskManager.TaskStepOver or taskServerInfo.vCondStep[1]
            end
            self:UpdateTaskDataByType(taskServerInfo.iType, taskServerInfo)
            isHave = true
            break
          end
        end
        if not isHave then
          self:UpdateTaskDataByType(taskServerInfo.iType, taskServerInfo)
        end
        typeList[#typeList + 1] = taskServerInfo.iType
      end
    end
    self:broadcastEvent("eGameEvent_Task_Change_State", {isGetReward = isGetReward, typeList = typeList})
  end
  self:CheckDailyTaskRedDot()
  self:CheckWeeklyTaskRedDot()
  self:CheckAchievementTaskRedDot()
  self:CheckMainTaskRedDot()
  self:CheckRogueAchievementReddot()
end

function TaskManager:CreateOverTaskInfo(taskId, taskType)
  local list = self:GetTaskDataListByType(taskType)
  local info = {
    iState = TaskManager.TaskState.Completed,
    iType = taskType,
    iId = taskId,
    vCondStep = {
      TaskManager.TaskStepOver
    }
  }
  table.insert(list, info)
end

function TaskManager:GetMainTaskDataList()
  return self.m_mainTaskList
end

function TaskManager:GetMainTaskDataById(taskId)
  local taskData
  for i, v in pairs(self.m_mainTaskList) do
    if v.iId == taskId then
      taskData = v
      break
    end
  end
  return taskData
end

function TaskManager:GetTaskDataListByType(taskType)
  if self.m_taskAll[taskType] == nil then
    self.m_taskAll[taskType] = {}
  end
  return self.m_taskAll[taskType]
end

function TaskManager:SetTaskDataListByType(taskType, taskDataList)
  self.m_taskAll[taskType] = taskDataList
end

function TaskManager:GetTaskOverDataListByType(taskType)
  if self.m_taskOverList[taskType] == nil then
    self.m_taskOverList[taskType] = {}
  end
  return self.m_taskOverList[taskType]
end

function TaskManager:SetTaskOverDataListByType(taskType, taskId)
  if self.m_taskOverList[taskType] == nil then
    self.m_taskOverList[taskType] = {}
  end
  table.insert(self.m_taskOverList[taskType], taskId)
end

function TaskManager:UpdateTaskDataByType(taskType, taskInfo)
  local taskList = self:GetTaskDataListByType(taskType)
  if taskInfo then
    local isHave = false
    for i, v in pairs(taskList) do
      if v.iId == taskInfo.iId then
        taskList[i].iState = taskInfo.iState
        taskList[i].vCondStep = taskInfo.vCondStep
        isHave = true
      end
    end
    if not isHave then
      taskList[#taskList + 1] = taskInfo
    end
  end
end

function TaskManager:ResetTaskDataByType(taskType)
  local taskList = self:GetTaskDataListByType(taskType)
  for i, v in pairs(taskList) do
    taskList[i].iState = TaskManager.TaskState.Doing
    taskList[i].vCondStep = {0}
  end
end

function TaskManager:RemoveTaskDataByTypeAndId(taskType, taskId)
  local taskList = self:GetTaskDataListByType(taskType)
  if taskId then
    for i, v in pairs(taskList) do
      if v.iId == taskId then
        taskList[i] = nil
      end
    end
  end
end

function TaskManager:GetTaskDataByTypeAndId(taskType, taskId)
  local taskList = self:GetTaskDataListByType(taskType)
  local taskData
  for i, v in pairs(taskList) do
    if v.iId == taskId then
      taskData = v
      break
    end
  end
  return taskData
end

function TaskManager:GetTaskCfgByType(taskType)
  local taskIns = ConfigManager:GetConfigInsByName("Task")
  local taskCfg = taskIns:GetAll()
  local taskCfgList = {}
  for i, v in pairs(taskCfg) do
    if v.m_TaskType == taskType then
      taskCfgList[#taskCfgList + 1] = v
    end
  end
  
  local function sortFun(a1, a2)
    return a1.m_ID < a2.m_ID
  end
  
  table.sort(taskCfgList, sortFun)
  return taskCfgList
end

function TaskManager:GetTaskData(taskType)
  local dataList = {}
  local cfgList = self:GetTaskCfgByType(taskType)
  for i, v in pairs(cfgList) do
    local taskData = self:GetTaskDataByTypeAndId(taskType, v.m_ID)
    if taskData then
      dataList[#dataList + 1] = {cfg = v, serverData = taskData}
    end
  end
  
  local function sortFun(a1, a2)
    local serverData1 = a1.serverData
    local serverData2 = a2.serverData
    if serverData1.iState == serverData2.iState then
      return serverData1.iId < serverData2.iId
    else
      local stateA = TaskManager:GetTaskStateSortNum(serverData1.iState)
      local stateB = TaskManager:GetTaskStateSortNum(serverData2.iState)
      return stateA < stateB
    end
  end
  
  table.sort(dataList, sortFun)
  return dataList
end

function TaskManager:GetTaskStateSortNum(taskState)
  local state = 1
  if taskState == TaskManager.TaskState.Completed then
    state = 3
  elseif taskState == TaskManager.TaskState.Doing then
    state = 2
  elseif taskState == TaskManager.TaskState.Finish then
    state = 1
  end
  return state
end

function TaskManager:GetTaskScoreByType(taskType)
  local score = 0
  local taskIns = ConfigManager:GetConfigInsByName("Task")
  local taskIdList = self:GetTaskOverDataListByType(taskType)
  for i, taskId in pairs(taskIdList) do
    local cfg = taskIns:GetValue_ByID(taskId)
    score = score + (cfg.m_Score or 0)
  end
  return score
end

function TaskManager:GetTaskCfgById(taskId)
  local taskIns = ConfigManager:GetConfigInsByName("Task")
  local cfg = taskIns:GetValue_ByID(taskId)
  if cfg:GetError() then
    log.error("GetTaskCfgById is error taskId = " .. tostring(taskId))
    return
  end
  return cfg
end

function TaskManager:GetDailyTaskRewardCfgScore()
  local score = 0
  local rewardIns = ConfigManager:GetConfigInsByName("DailyTaskReward")
  local rewardCfg = rewardIns:GetAll()
  if rewardCfg then
    for i, cfg in pairs(rewardCfg) do
      if score < cfg.m_RequiredScore then
        score = cfg.m_RequiredScore
      end
    end
  end
  return score
end

function TaskManager:GetWeeklyTaskRewardCfgScore()
  local score = 0
  local rewardIns = ConfigManager:GetConfigInsByName("WeeklyTaskReward")
  local rewardCfg = rewardIns:GetAll()
  if rewardCfg then
    for i, cfg in pairs(rewardCfg) do
      if score < cfg.m_RequiredScore then
        score = cfg.m_RequiredScore
      end
    end
  end
  return score
end

function TaskManager:GetTaskGroupIdByTaskId(taskId)
  return self.m_mainTaskIdGroup[taskId]
end

function TaskManager:GetMainTaskOverByGroup(groupId)
  local serverTaskList = self:GetTaskDataListByType(TaskManager.TaskType.MainTask)
  local count = 0
  for i, taskData in pairs(serverTaskList) do
    if groupId == self.m_mainTaskIdGroup[taskData.iId] and taskData.iState == TaskManager.TaskState.Completed then
      count = count + 1
    end
  end
  return count
end

function TaskManager:GetMainTaskGroupData()
  local mainTaskRewardIns = ConfigManager:GetConfigInsByName("MainTaskReward")
  local cfg = mainTaskRewardIns:GetValue_ByID(self.m_mainTaskGroupId)
  local taskIdList = utils.changeCSArrayToLuaTable(cfg.m_TaskList) or {}
  local state = TaskManager.TaskState.Finish
  local mainTaskOverIdList = self:GetTaskOverDataListByType(TaskManager.TaskType.MainTask)
  local taskStep = 0
  for i, taskId in pairs(taskIdList) do
    local flag = false
    for m, n in pairs(mainTaskOverIdList) do
      if taskId == n then
        taskStep = taskStep + 1
        flag = true
      end
    end
    if not flag then
      state = TaskManager.TaskState.Doing
    end
  end
  for i, v in pairs(self.m_mainTaskGroupOverList) do
    if self.m_mainTaskGroupId == v then
      state = TaskManager.TaskState.Completed
    end
  end
  return {
    cfg = cfg,
    state = state,
    step = math.floor(taskStep / math.max(#taskIdList, 1) * 100)
  }
end

function TaskManager:GetMainTaskRewardCfgById(id)
  local mainTaskRewardIns = ConfigManager:GetConfigInsByName("MainTaskReward")
  return mainTaskRewardIns:GetValue_ByID(id)
end

function TaskManager:CheckMainTaskGroupIsOver(mainTaskGroupId)
  for i, v in pairs(self.m_mainTaskGroupOverList) do
    if mainTaskGroupId == v then
      return true
    end
  end
  return false
end

function TaskManager:GetMainTaskGroupItemData()
  local serverTaskList = self:GetTaskDataListByType(TaskManager.TaskType.MainTask)
  local taskGroupFlagTab = {}
  local taskDataList = {}
  for i, v in pairs(serverTaskList) do
    if v.iState ~= TaskManager.TaskState.Completed then
      local taskCfg = self:GetTaskCfgById(v.iId)
      local groupId = self:GetTaskGroupIdByTaskId(v.iId)
      local rewardCfg = self:GetMainTaskRewardCfgById(groupId)
      if not taskCfg:GetError() and not rewardCfg:GetError() and groupId then
        if not taskGroupFlagTab[groupId] then
          taskGroupFlagTab[groupId] = true
        end
        taskDataList[#taskDataList + 1] = {
          groupId = groupId,
          cfg = taskCfg,
          serverData = v,
          rewardCfg = rewardCfg
        }
      else
        log.error("GetMainTaskGroupItemData  can not find taskId = " .. tostring(v.iId))
      end
    end
  end
  if #taskDataList == 0 then
    local rewardCfg = self:GetMainTaskRewardCfgById(self.m_mainTaskGroupId)
    local overFlag = self:CheckMainTaskGroupIsOver(self.m_mainTaskGroupId)
    if not rewardCfg:GetError() and not overFlag and not taskGroupFlagTab[self.m_mainTaskGroupId] then
      local taskIdList = utils.changeCSArrayToLuaTable(rewardCfg.m_TaskList)
      if taskIdList[1] then
        local taskCfg = self:GetTaskCfgById(taskIdList[1])
        local groupId = self:GetTaskGroupIdByTaskId(taskIdList[1])
        if not taskCfg:GetError() and not rewardCfg:GetError() and groupId then
          local showGroup = false
          if not taskGroupFlagTab[groupId] then
            showGroup = true
            taskGroupFlagTab[groupId] = true
          end
          taskDataList[#taskDataList + 1] = {
            showGroup = showGroup,
            cfg = taskCfg,
            groupId = groupId,
            receiveMainGroupReward = true,
            rewardCfg = rewardCfg
          }
        end
      end
    end
  end
  if self.m_mainTaskGroupId then
    for i = 1, 2 do
      local cfg = self:GetMainTaskRewardCfgById(self.m_mainTaskGroupId + i)
      if not cfg:GetError() and not taskGroupFlagTab[self.m_mainTaskGroupId + i] then
        local taskIdList = utils.changeCSArrayToLuaTable(cfg.m_TaskList)
        for m, taskId in ipairs(taskIdList) do
          local taskCfg = self:GetTaskCfgById(taskId)
          local groupId = self:GetTaskGroupIdByTaskId(taskId)
          local rewardCfg = self:GetMainTaskRewardCfgById(groupId)
          if not taskCfg:GetError() and not rewardCfg:GetError() and groupId then
            if not taskGroupFlagTab[groupId] then
              taskGroupFlagTab[groupId] = true
            end
            taskDataList[#taskDataList + 1] = {
              cfg = taskCfg,
              groupId = groupId,
              rewardCfg = rewardCfg
            }
          end
        end
      end
    end
  end
  
  local function sortFun(a1, a2)
    local cfg1 = a1.cfg
    local cfg2 = a2.cfg
    if a1.groupId == a2.groupId then
      if a1.serverData and a2.serverData then
        if a1.serverData.iState == a2.serverData.iState then
          return cfg1.m_Priority > cfg2.m_Priority
        else
          return a1.serverData.iState > a2.serverData.iState
        end
      else
        return cfg1.m_ID < cfg2.m_ID
      end
    else
      return a1.groupId < a2.groupId
    end
  end
  
  table.sort(taskDataList, sortFun)
  local taskData = taskDataList[1]
  if taskData and taskData.serverData then
    taskData.showGroup = true
  end
  local groupAndIdTab = {}
  for i, v in ipairs(taskDataList) do
    if not v.serverData and not v.receiveMainGroupReward then
      if not groupAndIdTab[v.groupId] then
        v.showGroup = true
        groupAndIdTab[v.groupId] = v.cfg.m_ID
      else
        v.showGroup = false
      end
    end
  end
  return taskDataList
end

function TaskManager:GetCurMainGroupRewardCfg()
  local cfg = self:GetMainTaskRewardCfgById(self.m_mainTaskGroupId)
  local overFlag = self:CheckMainTaskGroupIsOver(self.m_mainTaskGroupId)
  return cfg, overFlag
end

function TaskManager:GetCurMainTaskGroupId()
  return self.m_mainTaskGroupId
end

function TaskManager:GetCurMainTaskCfg()
  local cfg, state
  local tempList = {}
  local taskList = self:GetTaskDataListByType(TaskManager.TaskType.MainTask)
  for i, v in pairs(taskList) do
    if v.iState == TaskManager.TaskState.Finish then
      local taskId = v.iId
      local taskIns = ConfigManager:GetConfigInsByName("Task")
      cfg = taskIns:GetValue_ByID(taskId)
      state = v.iState
      break
    elseif v.iState == TaskManager.TaskState.Doing then
      tempList[#tempList + 1] = v
    end
  end
  if cfg == nil and 0 < #tempList then
    local taskIns = ConfigManager:GetConfigInsByName("Task")
    
    local function sortFun(data1, data2)
      if taskIns then
        local cfg1 = taskIns:GetValue_ByID(data1.iId)
        local cfg2 = taskIns:GetValue_ByID(data2.iId)
        if not cfg1:GetError() and not cfg2:GetError() then
          return cfg1.m_Priority > cfg2.m_Priority
        else
          return data1.iId < data2.iId
        end
      else
        return data1.iId < data2.iId
      end
    end
    
    table.sort(tempList, sortFun)
    local taskId = tempList[1].iId
    cfg = taskIns:GetValue_ByID(taskId)
    state = tempList[1].iState
  end
  return cfg, state
end

function TaskManager:GetCanCollectedTaskIdsByType(taskType)
  local idList = {}
  local canGetMainGroupTaskReward = false
  local taskList = self:GetTaskDataListByType(taskType)
  local taskIdTab = {}
  local taskErrorIdStr = ""
  if taskList then
    for i, v in pairs(taskList) do
      if v.iState == TaskManager.TaskState.Finish then
        if not taskIdTab[v.iId] then
          taskIdTab[v.iId] = true
          idList[#idList + 1] = v.iId
        else
          taskErrorIdStr = taskErrorIdStr .. v.iId .. ","
        end
      end
    end
  end
  if taskType == TaskManager.TaskType.MainTask and #idList == 0 then
    local taskGroupData = self:GetMainTaskGroupData()
    if taskGroupData and taskGroupData.state == TaskManager.TaskState.Finish then
      canGetMainGroupTaskReward = true
    end
  end
  if taskErrorIdStr and taskErrorIdStr ~= "" then
    if TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("task_id_repeated_error", 0) then
      local reportData = {sRepeatedTaskId = taskErrorIdStr, taskType = taskType}
      ReportManager:ReportTaskIdReperted(reportData)
    end
    LocalDataManager:SetIntSimple("task_id_repeated_error", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
  end
  return idList, canGetMainGroupTaskReward
end

function TaskManager:CheckDailyTaskRedDot()
  local haveRedDot = 1
  local noRedDot = 0
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    return noRedDot
  end
  local taskScore = self:GetTaskScoreByType(TaskManager.TaskType.Daily)
  if not self.m_dailyRewardCfgScore or self.m_dailyRewardCfgScore == 0 then
    self.m_dailyRewardCfgScore = self:GetDailyTaskRewardCfgScore()
  end
  if self.m_dailyRewardCfgScore ~= 0 and taskScore >= self.m_dailyRewardCfgScore then
    self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
      redDotKey = RedDotDefine.ModuleType.TaskDaily,
      count = 0
    })
    return noRedDot
  end
  local taskIdList = self:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Daily)
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.TaskDaily,
    count = #taskIdList
  })
  if taskIdList and 0 < #taskIdList then
    return haveRedDot
  end
  return noRedDot
end

function TaskManager:CheckWeeklyTaskRedDot()
  local haveRedDot = 1
  local noRedDot = 0
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    return noRedDot
  end
  local taskScore = self:GetTaskScoreByType(TaskManager.TaskType.Weekly)
  if not self.m_weeklyRewardCfgScore or self.m_weeklyRewardCfgScore == 0 then
    self.m_weeklyRewardCfgScore = self:GetWeeklyTaskRewardCfgScore()
  end
  if self.m_weeklyRewardCfgScore ~= 0 and taskScore >= self.m_weeklyRewardCfgScore then
    self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
      redDotKey = RedDotDefine.ModuleType.TaskWeekly,
      count = 0
    })
    return noRedDot
  end
  local taskIdList = self:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Weekly)
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.TaskWeekly,
    count = #taskIdList
  })
  if taskIdList and 0 < #taskIdList then
    return haveRedDot
  end
  return noRedDot
end

function TaskManager:CheckAchievementTaskRedDot()
  local haveRedDot = 1
  local noRedDot = 0
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    return noRedDot
  end
  local taskIdList = self:GetCanCollectedTaskIdsByType(TaskManager.TaskType.Achievement)
  local flag = self:CheckAchievementStepRewardCollected()
  local count = (0 < #taskIdList or flag) and 1 or 0
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.TaskAchievement,
    count = count
  })
  if taskIdList and 0 < #taskIdList then
    return haveRedDot
  end
  return noRedDot
end

function TaskManager:CheckMainTaskRedDot()
  local haveRedDot = 1
  local noRedDot = 0
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    return noRedDot
  end
  local taskIdList = self:GetCanCollectedTaskIdsByType(TaskManager.TaskType.MainTask)
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.TaskMain,
    count = #taskIdList
  })
  if taskIdList and 0 < #taskIdList then
    return haveRedDot
  end
  local taskGroupData = self:GetMainTaskGroupData()
  if taskGroupData then
    local state = taskGroupData.state
    if state == TaskManager.TaskState.Finish then
      self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
        redDotKey = RedDotDefine.ModuleType.TaskMain,
        count = 1
      })
      return haveRedDot
    end
  end
  return noRedDot
end

function TaskManager:CheckTaskEnterRedDot()
  local noRedDot = 0
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    return noRedDot
  end
  for i, taskType in pairs(TaskManager.TaskCollection) do
    local taskIdList, mainTaskGroupFlag = self:GetCanCollectedTaskIdsByType(taskType)
    if 0 < #taskIdList then
      local taskScore = self:GetTaskScoreByType(taskType)
      if taskType == TaskManager.TaskType.Daily then
        if not self.m_dailyRewardCfgScore or self.m_dailyRewardCfgScore == 0 then
          self.m_dailyRewardCfgScore = self:GetDailyTaskRewardCfgScore()
        end
        if self.m_dailyRewardCfgScore ~= 0 and taskScore < self.m_dailyRewardCfgScore then
          return taskType
        end
      elseif taskType == TaskManager.TaskType.Weekly then
        if not self.m_weeklyRewardCfgScore or self.m_weeklyRewardCfgScore == 0 then
          self.m_weeklyRewardCfgScore = self:GetWeeklyTaskRewardCfgScore()
        end
        if self.m_weeklyRewardCfgScore ~= 0 and taskScore < self.m_weeklyRewardCfgScore then
          return taskType
        end
      else
        return taskType
      end
    end
    if self:CheckAchievementStepRewardCollected() then
      return TaskManager.TaskType.Achievement
    end
    if mainTaskGroupFlag then
      return TaskManager.TaskType.MainTask
    end
  end
  return noRedDot
end

function TaskManager:CheckTaskIsCanJump(taskId)
  local cfg = self:GetTaskCfgById(taskId)
  if cfg and cfg.m_Jump and cfg.m_Jump ~= 0 then
    return true
  end
  return false
end

function TaskManager:CheckMainTaskIsOver()
  local isOver = false
  local taskGroupData = self:GetMainTaskGroupData()
  local cfg = taskGroupData.cfg
  local state = taskGroupData.state
  if cfg and (not cfg.m_NextMainTaskID or cfg.m_NextMainTaskID == 0) and TaskManager.TaskState.Completed == state then
    isOver = true
  end
  return isOver
end

function TaskManager:GetAchievementTasksData()
  local taskList = self:GetTaskDataListByType(TaskManager.TaskType.Achievement)
  local taskDataList = {}
  local taskIdTab = {}
  for i, v in pairs(taskList) do
    if v.iState ~= TaskManager.TaskState.Completed then
      local taskCfg = self:GetTaskCfgById(v.iId)
      if not taskCfg:GetError() then
        if not taskIdTab[v.iId] then
          taskDataList[#taskDataList + 1] = {cfg = taskCfg, serverData = v}
          taskIdTab[v.iId] = true
        end
      else
        log.error("GetAchievementTasksData  can not find taskId = " .. tostring(v.iId))
      end
    end
  end
  
  local function sortFun(a1, a2)
    local serverData1 = a1.serverData
    local serverData2 = a2.serverData
    local taskCfg1 = a1.cfg
    local taskCfg2 = a2.cfg
    if serverData1.iState == serverData2.iState then
      if taskCfg1.m_Jump == taskCfg2.m_Jump then
        return taskCfg1.m_Jump > taskCfg2.m_Jump
      else
        return serverData1.iId < serverData2.iId
      end
    else
      local stateA = TaskManager:GetTaskStateSortNum(serverData1.iState)
      local stateB = TaskManager:GetTaskStateSortNum(serverData2.iState)
      return stateA < stateB
    end
  end
  
  table.sort(taskDataList, sortFun)
  return taskDataList
end

function TaskManager:GetAchievementStepCfg()
  local lastReceivedId = 0
  if self.m_achievementReceivedRewardIdList then
    for i, v in pairs(self.m_achievementReceivedRewardIdList) do
      if v > lastReceivedId then
        lastReceivedId = v
      end
    end
  end
  local taskAchieveRewardIns = ConfigManager:GetConfigInsByName("TaskAchieveReward")
  local cfg = taskAchieveRewardIns:GetValue_ByID(lastReceivedId + 1)
  if cfg:GetError() then
    return
  end
  return cfg
end

function TaskManager:CheckAchievementStepRewardCollected()
  local flag = false
  local cfg = self:GetAchievementStepCfg()
  if cfg then
    local requiredCount = cfg.m_RequiredCount or 0
    flag = requiredCount <= self.m_achievementScore
  end
  return flag
end

function TaskManager:GetAchievementScore()
  return self.m_achievementScore, self.m_rogueachievementScore
end

function TaskManager:GetRogueAchievementScore()
  return self.m_rogueachievementReceivedRewardIdList
end

function TaskManager:GetAchieveRewardCfgs()
  if self.m_AchieveRewardCfgs then
    return self.m_AchieveRewardCfgs
  end
  local RogueTaskAchieveRewardIns = ConfigManager:GetConfigInsByName("RogueTaskAchieveReward")
  local all_config_dic = RogueTaskAchieveRewardIns:GetAll()
  local configs = {}
  for k, v in pairs(all_config_dic) do
    if v.m_ID then
      configs[v.m_ID] = v
    end
  end
  self.m_AchieveRewardCfgs = configs
  return configs
end

function TaskManager:GetRogueSortedQuests()
  local taskList = self:GetTaskDataListByType(TaskManager.TaskType.RogueAchievement)
  if not taskList then
    return false
  end
  local temp = {}
  for k, v in pairs(taskList) do
    if v.iState ~= MTTDProto.QuestState_Over or self.m_rogueachievementLastTaskList[v.iId] then
      temp[#temp + 1] = v
    end
  end
  table.sort(temp, function(a, b)
    if a.iState == b.iState then
      return a.iId < b.iId
    else
      if a.iState == MTTDProto.QuestState_Over then
        return false
      end
      if b.iState == MTTDProto.QuestState_Over then
        return true
      end
      return a.iState > b.iState
    end
  end)
  return temp
end

function TaskManager:GetRogueQuestCanReceiveRewardIDList()
  local taskList = self:GetTaskDataListByType(TaskManager.TaskType.RogueAchievement)
  if not taskList then
    return false
  end
  local t = {}
  for _, quest in pairs(taskList) do
    if quest.iState == MTTDProto.QuestState_Finish then
      t[#t + 1] = quest.iId
    end
  end
  return t
end

function TaskManager:CheckRogueAchievementReddot()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueAchievementEntry,
    count = self:CheckRogueAchievementEntryReddot()
  })
end

function TaskManager:CheckRogueAchievementEntryReddot()
  local taskList = self:GetTaskDataListByType(TaskManager.TaskType.RogueAchievement)
  if not taskList then
    return 0
  end
  local t = self:GetRogueQuestCanReceiveRewardIDList()
  if t and 0 < #t then
    return 1
  end
  local cfgs = self:GetAchieveRewardCfgs()
  if not cfgs then
    return 0
  end
  local lastTakeAwardId = self.m_rogueachievementReceivedRewardIdList[#self.m_rogueachievementReceivedRewardIdList] or 0
  local curRewardCfg = cfgs[lastTakeAwardId + 1]
  if not curRewardCfg then
    return 0
  end
  local cur_Point = self.m_rogueachievementScore
  local max_Point = tonumber(curRewardCfg.m_RequiredCount)
  if cur_Point >= max_Point then
    return 1
  end
  return 0
end

function TaskManager:GetTaskNameById(taskId, taskCfg)
  local name = ""
  taskCfg = taskCfg or self:GetTaskCfgById(taskId)
  local param = utils.changeCSArrayToLuaTable(taskCfg.m_DescParam)
  name = string.CS_Format(taskCfg.m_mTaskName, param)
  return name
end

return TaskManager
