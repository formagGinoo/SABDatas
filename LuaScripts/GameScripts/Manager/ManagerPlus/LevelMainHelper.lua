local LevelMainHelper = class("LevelMainHelper")
local MainLevelIns = ConfigManager:GetConfigInsByName("MainLevel")
local MainChapterIns = ConfigManager:GetConfigInsByName("MainChapter")
local TaskIns = ConfigManager:GetConfigInsByName("Task")
local pairs = _ENV.pairs
local ipairs = _ENV.ipairs
local table_insert = table.insert
local table_sort = table.sort
local next = _ENV.next
local tostring = _ENV.tostring

function LevelMainHelper:ctor()
  self.m_cacheChapterNewUnlockList = {}
  self.m_cacheLevelNewUnlockData = {}
  self.m_allLevelCfgCacheDic = {}
  self.m_curStageData = {}
  self.m_dailyTimes = {}
  self.m_storyChapterList = {}
  self.m_storyChapterDic = {}
  self.m_hardChapterList = {}
  self.m_hardChapterDic = {}
  self.m_mainLevelDic = {
    [LevelManager.MainLevelSubType.MainStory] = self.m_storyChapterList,
    [LevelManager.MainLevelSubType.HardLevel] = self.m_hardChapterList
  }
  self.m_allChapterDic = {}
  self.m_cacheChapterProgressTaskData = {}
  self:InitMainLevelData()
end

function LevelMainHelper:GetAllChapterDic()
  return self.m_allChapterDic
end

function LevelMainHelper:SetStageData(stageData)
  if not stageData then
    return
  end
  self.m_curStageData = stageData
end

function LevelMainHelper:FreshPassStageInfo(stPushPassStage)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  if levelType ~= LevelManager.LevelType.MainLevel then
    return
  end
  local levelSubType = stPushPassStage.iStageSubType
  if not levelSubType then
    return
  end
  if not self.m_curStageData then
    return
  end
  local subTypeStageData = self.m_curStageData[levelSubType]
  if not subTypeStageData then
    subTypeStageData = {}
    self.m_curStageData[levelSubType] = subTypeStageData
  end
  local lastPassStageId = stPushPassStage.iLastPassStageId
  if lastPassStageId and lastPassStageId ~= 0 then
    subTypeStageData.iLastPassStageId = lastPassStageId
  end
  local levelID = stPushPassStage.iStageId
  local firstFinishTime = stPushPassStage.iFirstFinishTime
  if firstFinishTime and firstFinishTime ~= 0 and levelID ~= 0 then
    if subTypeStageData.mStageFirstFinishTime == nil then
      subTypeStageData.mStageFirstFinishTime = {}
    end
    subTypeStageData.mStageFirstFinishTime[levelID] = firstFinishTime
  end
  if levelSubType == LevelManager.MainLevelSubType.MainStory or levelSubType == LevelManager.MainLevelSubType.HardLevel then
    self:CheckCacheLastPassMainChapterOrLevel(levelSubType)
  end
end

function LevelMainHelper:SetLevelDailyTimes(dailyTimes)
  self.m_dailyTimes = dailyTimes or {}
end

function LevelMainHelper:FreshLevelDailyTimes(levelSubType, passTimes)
  if not levelSubType then
    return
  end
  if not passTimes then
    return
  end
  self.m_dailyTimes[levelSubType] = passTimes
end

function LevelMainHelper:GetDailyTimesBySubLevelType(levelSubType)
  if not levelSubType then
    return
  end
  return self.m_dailyTimes[levelSubType] or 0
end

function LevelMainHelper:GetMainLevelData()
  return self.m_mainLevelDic
end

function LevelMainHelper:IsLevelHavePass(levelID)
  if not levelID then
    return
  end
  if levelID == 0 then
    return true
  end
  for _, subTypeStageData in pairs(self.m_curStageData) do
    if subTypeStageData.mStageFirstFinishTime[levelID] ~= nil and subTypeStageData.mStageFirstFinishTime[levelID] ~= 0 then
      return true
    end
  end
  return false
end

function LevelMainHelper:GetLastPassLevelIDBySubType(levelSubType)
  if not levelSubType then
    return
  end
  if self.m_curStageData[levelSubType] then
    return self.m_curStageData[levelSubType].iLastPassStageId
  end
end

function LevelMainHelper:IsChapterUnlock(chapterID)
  if not chapterID then
    return
  end
  local chapterCfg = MainChapterIns:GetValue_ByChapterID(chapterID)
  local unlockTypeArray = chapterCfg.m_UnlockConditionType
  local unlockConditionArray = chapterCfg.m_UnlockConditionData
  local unlockTypeList = utils.changeCSArrayToLuaTable(unlockTypeArray)
  local unlockConditionDataList = utils.changeCSArrayToLuaTable(unlockConditionArray)
  return ConditionManager:IsMulConditionUnlock(unlockTypeList, unlockConditionDataList)
end

function LevelMainHelper:IsLevelUnLock(levelID)
  if not levelID then
    local params = {
      LogInfo = "LevelMainHelper_IsLevelUnLock_levelID_nil_" .. tostring(levelID)
    }
    ReportManager:ReportMessage(CS.ReportDataDefines.Flog_report, params)
    return
  end
  local levelMainCfg = self:GetLevelCfgByID(levelID)
  if not levelMainCfg then
    local params = {
      LogInfo = "LevelMainHelper_IsLevelUnLock_levelMainCfg_nil_" .. tostring(levelID)
    }
    ReportManager:ReportMessage(CS.ReportDataDefines.Flog_report, params)
    return
  end
  local unlockLevelID = levelMainCfg.m_LevelUnlock
  local chapterID = levelMainCfg.m_ChapterID
  local isChapterUnlock, unlockType, unlockStr = self:IsChapterUnlock(chapterID)
  if isChapterUnlock == false then
    return isChapterUnlock, unlockType, unlockStr
  end
  return self:IsLevelHavePass(unlockLevelID)
end

function LevelMainHelper:IsLevelSubTypeUnlock(levelSubType)
  if not levelSubType then
    return
  end
  local chapterList = self.m_mainLevelDic[levelSubType]
  if not chapterList then
    return
  end
  local firstChapterData = chapterList[1]
  if not firstChapterData then
    return
  end
  local chapterCfg = firstChapterData.chapterCfg
  if not chapterCfg then
    return
  end
  return self:IsChapterUnlock(chapterCfg.m_ChapterID)
end

function LevelMainHelper:GetNextShowLevelCfg(levelSubType)
  if not levelSubType then
    return
  end
  if levelSubType ~= LevelManager.MainLevelSubType.MainStory and levelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  local chapterList = self.m_mainLevelDic[levelSubType]
  if not chapterList then
    return
  end
  local lastPassLevelID = self:GetLastPassLevelIDBySubType(levelSubType)
  if not lastPassLevelID or lastPassLevelID == 0 then
    local firstChapterData = chapterList[1]
    if not firstChapterData then
      return
    end
    return firstChapterData.storyLevelList[1]
  end
  local levelMainCfg = self:GetLevelCfgByID(lastPassLevelID)
  if not levelMainCfg then
    log.error("LevelMainHelper GetNextShowLevelCfg lastPassLevelID: " .. tostring(lastPassLevelID))
    return
  end
  local chapterID = levelMainCfg.m_ChapterID
  local chapterIndex
  for i, chapterData in ipairs(chapterList) do
    if chapterData.chapterCfg.m_ChapterID == chapterID then
      chapterIndex = i
      break
    end
  end
  if not chapterIndex then
    return
  end
  local chapterData = chapterList[chapterIndex]
  local levelList = chapterData.storyLevelList
  if not levelList then
    return
  end
  local levelIndex
  for i, levelCfg in ipairs(levelList) do
    if levelCfg.m_LevelID == lastPassLevelID then
      levelIndex = i
      break
    end
  end
  if chapterIndex >= #chapterList and levelIndex >= #levelList then
    return
  end
  if levelIndex >= #levelList then
    local nextChapterData = chapterList[chapterIndex + 1]
    return nextChapterData.storyLevelList[1]
  end
  return levelList[levelIndex + 1]
end

function LevelMainHelper:GetCurrentLevelCfg(levelSubType)
  if not levelSubType then
    return
  end
  if levelSubType ~= LevelManager.MainLevelSubType.MainStory and levelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  local chapterList = self.m_mainLevelDic[levelSubType]
  if not chapterList then
    return
  end
  local lastPassLevelID = self:GetLastPassLevelIDBySubType(levelSubType)
  if not lastPassLevelID or lastPassLevelID == 0 then
    local firstChapterData = chapterList[1]
    if not firstChapterData then
      return
    end
    return firstChapterData.storyLevelList[1]
  end
  local levelMainCfg = self:GetLevelCfgByID(lastPassLevelID)
  if not levelMainCfg then
    log.error("LevelMainHelper GetNextShowLevelCfg lastPassLevelID: " .. tostring(lastPassLevelID))
    return
  end
  return levelMainCfg
end

function LevelMainHelper:GetCurChapterIndex(levelSubType)
  if not levelSubType then
    return
  end
  if levelSubType ~= LevelManager.MainLevelSubType.MainStory and levelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  local chapterList = self.m_mainLevelDic[levelSubType]
  if not chapterList then
    return
  end
  local lastPassLevelID = self:GetLastPassLevelIDBySubType(levelSubType)
  if not lastPassLevelID or lastPassLevelID == 0 then
    return 1
  end
  local levelMainCfg = self:GetLevelCfgByID(lastPassLevelID)
  if not levelMainCfg or levelMainCfg:GetError() then
    return
  end
  local chapterID = levelMainCfg.m_ChapterID
  local chapterIndex
  for i, chapterData in ipairs(chapterList) do
    if chapterData.chapterCfg.m_ChapterID == chapterID then
      chapterIndex = i
      break
    end
  end
  if not chapterIndex then
    return
  end
  local chapterData = chapterList[chapterIndex]
  local levelList = chapterData.storyLevelList
  if not levelList then
    return
  end
  local levelIndex
  for i, levelCfg in ipairs(levelList) do
    if levelCfg.m_LevelID == lastPassLevelID then
      levelIndex = i
      break
    end
  end
  if chapterIndex >= #chapterList and levelIndex >= #levelList then
    return chapterIndex
  end
  if levelIndex >= #levelList then
    return chapterIndex + 1
  end
  return chapterIndex
end

function LevelMainHelper:GetChapterIndexBySubType(levelSubType, chapterID)
  if not chapterID then
    return
  end
  if not levelSubType then
    return
  end
  if levelSubType ~= LevelManager.MainLevelSubType.MainStory and levelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  local chapterList = self.m_mainLevelDic[levelSubType]
  if not chapterList then
    return
  end
  for i, chapterData in ipairs(chapterList) do
    if chapterData.chapterCfg.m_ChapterID == chapterID then
      return i
    end
  end
end

function LevelMainHelper:GetChapterProgress(chapterData)
  if not chapterData then
    return
  end
  local levelList = chapterData.storyLevelList
  local levelLen = 0
  local passNum = 0
  for _, levelCfg in ipairs(levelList) do
    local levelID = levelCfg.m_LevelID
    if self:IsLevelHavePass(levelID) == true then
      passNum = passNum + 1
    end
    levelLen = levelLen + 1
  end
  local exLevelList = chapterData.exLevelList
  local exPassNum, exLevelLen = 0, 0
  for i, levelCfg in ipairs(exLevelList) do
    local levelID = levelCfg.m_LevelID
    if self:IsLevelHavePass(levelID) == true then
      exPassNum = exPassNum + 1
    end
  end
  exLevelLen = #exLevelList
  return passNum, levelLen, exPassNum, exLevelLen
end

function LevelMainHelper:GetTopPassChangeChapter()
  if not next(self.m_cacheChapterNewUnlockList) then
    return
  end
  local maxIndex = #self.m_cacheChapterNewUnlockList
  local topNewUnlock = self.m_cacheChapterNewUnlockList[maxIndex]
  table.remove(self.m_cacheChapterNewUnlockList, maxIndex)
  return topNewUnlock
end

function LevelMainHelper:CacheNewUnlockChapter(newChapterID, lastChapterID)
  if not newChapterID then
    return
  end
  self.m_cacheChapterNewUnlockList[#self.m_cacheChapterNewUnlockList + 1] = {lastChapterID = lastChapterID, newChapterID = newChapterID}
end

function LevelMainHelper:GetPassChangeLevel()
  if not self.m_cacheLevelNewUnlockData then
    return
  end
  local topNewUnlock = self.m_cacheLevelNewUnlockData
  self.m_cacheLevelNewUnlockData = nil
  return topNewUnlock
end

function LevelMainHelper:CacheNewUnlockLevel(newLevelID, lastLevelID)
  if not newLevelID then
    return
  end
  self.m_cacheLevelNewUnlockData = {lastLevelID = lastLevelID, newLevelID = newLevelID}
end

function LevelMainHelper:IsFirstLevelHavePass()
  local mainChapterList = self.m_mainLevelDic[LevelManager.MainLevelSubType.MainStory]
  if not mainChapterList then
    return
  end
  local firstChapterData = mainChapterList[1]
  if not firstChapterData then
    return
  end
  local firstStoryLevelCfg = firstChapterData.storyLevelList[1]
  if not firstStoryLevelCfg then
    return
  end
  local firstLevelID = firstStoryLevelCfg.m_LevelID
  if self:IsLevelHavePass(firstLevelID) == true then
    return true, firstLevelID
  else
    return false, firstLevelID
  end
end

function LevelMainHelper:IsChapterAllStoryLevelHavePass(chapterID)
  if not chapterID then
    return
  end
  local chapterData = self.m_allChapterDic[chapterID]
  if not chapterData then
    return
  end
  local storyLevelList = chapterData.storyLevelList
  if not next(storyLevelList) then
    return
  end
  for _, mainLvCfg in ipairs(storyLevelList) do
    local levelID = mainLvCfg.m_LevelID
    local isHavePass = self:IsLevelHavePass(levelID)
    if isHavePass ~= true then
      return false
    end
  end
  return true, chapterData.chapterCfg.m_mChapterName
end

function LevelMainHelper:GetChapterFirstExLevel(chapterID)
  if not chapterID then
    return
  end
  local chapterData = self.m_allChapterDic[chapterID]
  if not chapterData then
    return
  end
  local levelList = chapterData.exLevelList
  for _, levelCfg in ipairs(levelList) do
    local isHavePass = self:IsLevelHavePass(levelCfg.m_LevelID)
    if isHavePass ~= true then
      return levelCfg.m_LevelID
    end
  end
end

function LevelMainHelper:GetLevelCfgByID(levelID)
  if not levelID then
    return
  end
  local levelCfg = self.m_allLevelCfgCacheDic[levelID]
  if not levelCfg then
    levelCfg = MainLevelIns:GetValue_ByLevelID(levelID)
    if levelCfg:GetError() then
      return
    end
    self.m_allLevelCfgCacheDic[levelID] = levelCfg
  end
  return levelCfg
end

function LevelMainHelper:GetChapterDataByLevelID(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local chapterID = levelCfg.m_ChapterID
  if not chapterID then
    return
  end
  return self.m_allChapterDic[chapterID]
end

function LevelMainHelper:GetChapterDataByID(chapterID)
  if not chapterID then
    return
  end
  return self.m_allChapterDic[chapterID]
end

function LevelMainHelper:GetChapterProgressTaskList(chapterID)
  if not chapterID then
    return
  end
  local chapterTaskList = {}
  local chapterData = self.m_allChapterDic[chapterID]
  if chapterData then
    local chapterCfg = chapterData.chapterCfg
    local chapterTaskIDArray = chapterCfg.m_ChapterTaskID
    if chapterTaskIDArray and chapterTaskIDArray.Length > 0 then
      local taskArrayLen = chapterTaskIDArray.Length
      for i = 1, taskArrayLen do
        local taskID = chapterTaskIDArray[i - 1]
        local taskCfg = TaskIns:GetValue_ByID(taskID)
        if taskCfg:GetError() ~= true then
          local taskServerData = TaskManager:GetTaskDataByTypeAndId(TaskManager.TaskType.ChapterProgress, taskID)
          if taskServerData then
            chapterTaskList[#chapterTaskList + 1] = {cfg = taskCfg, serverData = taskServerData}
          end
        end
      end
    end
  end
  return chapterTaskList
end

function LevelMainHelper:IsChapterProgressTaskCanReceive(chapterID)
  if not chapterID then
    return
  end
  local chapterTaskList = self:GetChapterProgressTaskList(chapterID)
  if not chapterTaskList then
    return
  end
  local isHaveCanReceive = false
  for i, chapterTaskData in ipairs(chapterTaskList) do
    if chapterTaskData.serverData.iState == TaskManager.TaskState.Finish then
      isHaveCanReceive = true
      break
    end
  end
  return isHaveCanReceive
end

function LevelMainHelper:GetAssignLevelParams(levelSubType, levelID)
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local chapterID = levelCfg.m_ChapterID
  return {
    LevelManager.LevelType.MainLevel,
    levelSubType,
    chapterID,
    levelID
  }
end

function LevelMainHelper:CheckCacheLastPassMainChapterOrLevel(levelSubType)
  if not next(self.m_curStageData) then
    return
  end
  local newChapterID, storyLastChapterID
  local curUnlockStoryLevelCfg = self:GetNextShowLevelCfg(levelSubType)
  if curUnlockStoryLevelCfg then
    newChapterID = curUnlockStoryLevelCfg.m_ChapterID
    local mainStageData = self.m_curStageData[levelSubType] or {}
    local lastPassLevelId = mainStageData.iLastPassStageId or 0
    storyLastChapterID = 0
    if lastPassLevelId ~= 0 then
      local lastMainLevelCfg = self:GetLevelCfgByID(lastPassLevelId)
      if not lastMainLevelCfg:GetError() then
        storyLastChapterID = lastMainLevelCfg.m_ChapterID
      end
    end
    if storyLastChapterID ~= 0 and newChapterID ~= storyLastChapterID then
      self:CacheNewUnlockChapter(newChapterID, storyLastChapterID)
    else
      local newLevelID = curUnlockStoryLevelCfg.m_LevelID
      self:CacheNewUnlockLevel(newLevelID, lastPassLevelId)
    end
  end
  if levelSubType == LevelManager.MainLevelSubType.MainStory then
    local hardLastPassID = self:GetLastPassLevelIDBySubType(LevelManager.MainLevelSubType.HardLevel)
    local isHardLevelUnlock = self:IsLevelSubTypeUnlock(LevelManager.MainLevelSubType.HardLevel)
    if (hardLastPassID == nil or hardLastPassID == 0) and isHardLevelUnlock == true then
      local firstHardChapter = self.m_hardChapterList[1]
      local unlockChapterID = firstHardChapter.chapterCfg.m_UnlockConditionData[0]
      if unlockChapterID == storyLastChapterID then
        self:CacheNewUnlockChapter(firstHardChapter.chapterCfg.m_ChapterID, 0)
      end
    end
  end
end

function LevelMainHelper:InitMainLevelData()
  local allMainLevelDic = MainLevelIns:GetAll()
  for key, mainLvCfg in pairs(allMainLevelDic) do
    if mainLvCfg then
      local chapterID = mainLvCfg.m_ChapterID
      local chapterData = self.m_allChapterDic[chapterID]
      if chapterData == nil then
        local chapterCfg = MainChapterIns:GetValue_ByChapterID(chapterID)
        chapterData = {
          chapterCfg = chapterCfg,
          levelList = {},
          storyLevelList = {},
          exLevelList = {}
        }
        if chapterCfg.m_ChapterType == LevelManager.ChapterType.Normal then
          self.m_storyChapterDic[chapterID] = chapterData
        elseif chapterCfg.m_ChapterType == LevelManager.ChapterType.Hard then
          self.m_hardChapterDic[chapterID] = chapterData
        end
        self.m_allChapterDic[chapterID] = chapterData
      end
      if mainLvCfg.m_LevelSubType == LevelManager.MainLevelSubType.MainStory or mainLvCfg.m_LevelSubType == LevelManager.MainLevelSubType.HardLevel then
        chapterData.storyLevelList[#chapterData.storyLevelList + 1] = mainLvCfg
      elseif mainLvCfg.m_LevelSubType == LevelManager.MainLevelSubType.ExLevel then
        chapterData.exLevelList[#chapterData.exLevelList + 1] = mainLvCfg
      end
      table_insert(chapterData.levelList, mainLvCfg)
    end
  end
  self:FreshChapterListToSort()
end

function LevelMainHelper:FreshChapterListToSort()
  for _, chapterData in pairs(self.m_storyChapterDic) do
    if chapterData.chapterCfg.m_IsClose == 1 then
      local chapterID = chapterData.chapterCfg.m_ChapterID
      self.m_allChapterDic[chapterID] = nil
      self.m_storyChapterDic[chapterID] = nil
    else
      chapterData.storyLevelList = self:ChangeLevelListToSort(chapterData.storyLevelList, 0)
      self:CheckFreshExToSort(chapterData)
      table_insert(self.m_storyChapterList, chapterData)
    end
  end
  table_sort(self.m_storyChapterList, function(a, b)
    return a.chapterCfg.m_Order < b.chapterCfg.m_Order
  end)
  for _, chapterData in pairs(self.m_hardChapterDic) do
    if chapterData.chapterCfg.m_IsClose == 1 then
      local chapterID = chapterData.chapterCfg.m_ChapterID
      self.m_allChapterDic[chapterID] = nil
      self.m_hardChapterDic[chapterID] = nil
    else
      chapterData.storyLevelList = self:ChangeLevelListToSort(chapterData.storyLevelList, 0)
      table_insert(self.m_hardChapterList, chapterData)
    end
  end
  table_sort(self.m_hardChapterList, function(a, b)
    return a.chapterCfg.m_Order < b.chapterCfg.m_Order
  end)
end

function LevelMainHelper:CheckFreshExToSort(chapterData)
  if chapterData and next(chapterData.exLevelList) then
    table_sort(chapterData.exLevelList, function(a, b)
      local aIndex = self:GetChapterLevelIndex(chapterData, a.m_LevelUnlock)
      local bIndex = self:GetChapterLevelIndex(chapterData, b.m_LevelUnlock)
      return aIndex < bIndex
    end)
  end
end

function LevelMainHelper:ChangeLevelListToSort(levelList, startCheckID)
  if not levelList or not next(levelList) then
    return {}
  end
  local startLen = #levelList
  startCheckID = startCheckID or 0
  local tempLevelDic = {}
  local startLevelID
  for _, mainLevelCfg in ipairs(levelList) do
    if mainLevelCfg then
      if mainLevelCfg.m_LevelUnlock == startCheckID then
        startLevelID = mainLevelCfg.m_LevelID
      end
      tempLevelDic[mainLevelCfg.m_LevelID] = {levelCfg = mainLevelCfg, nextID = nil}
    end
  end
  for _, mainLevelCfg in ipairs(levelList) do
    if mainLevelCfg and mainLevelCfg.m_LevelUnlock ~= startCheckID then
      local unlockLevelID = mainLevelCfg.m_LevelUnlock
      if tempLevelDic[unlockLevelID] then
        tempLevelDic[unlockLevelID].nextID = mainLevelCfg.m_LevelID
      end
    end
  end
  local sortLevelList = {}
  local tempLevelID = startLevelID
  local tempStartLevelData = tempLevelDic[tempLevelID]
  if not tempStartLevelData then
    log.error("LevelMainHelper cannot to a list startLevelID: " .. tostring(tempLevelID) .. " startCheckID: " .. tostring(startCheckID))
    return
  end
  sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
  while tempLevelDic[tempLevelID].nextID ~= nil do
    tempLevelID = tempLevelDic[tempLevelID].nextID
    if tempLevelDic[tempLevelID] then
      sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
    end
  end
  local endLevelLen = #sortLevelList
  if startLen ~= endLevelLen then
    log.error("LevelMainHelper after sort have reduce level startLen: " .. tostring(startLen) .. " endLevelLen: " .. tostring(endLevelLen) .. " firstLevelID: " .. sortLevelList[1].m_LevelID)
  end
  return sortLevelList
end

function LevelMainHelper:GetChapterLevelIndex(chapterData, levelID)
  if not chapterData then
    return 0
  end
  if not chapterData.storyLevelList then
    return 0
  end
  local storyLevelList = chapterData.storyLevelList
  for i, v in ipairs(storyLevelList) do
    if v.m_LevelID == levelID then
      return i
    end
  end
  return 0
end

function LevelMainHelper:IsAllLevelPass()
  if not self.m_storyChapterList or not next(self.m_storyChapterList) then
    return true
  end
  local maxChapterData = self.m_storyChapterList[#self.m_storyChapterList]
  if not maxChapterData then
    return true
  end
  local storyLevelList = maxChapterData.storyLevelList
  if not storyLevelList or not next(storyLevelList) then
    return true
  end
  local maxStoryLevelCfg = storyLevelList[#storyLevelList]
  if not maxStoryLevelCfg then
    return true
  end
  return self:IsLevelHavePass(maxStoryLevelCfg.m_LevelID)
end

return LevelMainHelper
