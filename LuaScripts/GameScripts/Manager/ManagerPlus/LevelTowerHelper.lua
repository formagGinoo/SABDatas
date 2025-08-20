local LevelTowerHelper = class("LevelTowerHelper")
local TribeTowerLevelIns = ConfigManager:GetConfigInsByName("TribeTowerLevel")
local TowerIns = ConfigManager:GetConfigInsByName("Tower")
local pairs = _ENV.pairs
local next = _ENV.next

function LevelTowerHelper:ctor()
  self.m_curStageData = {}
  self.m_dailyTimes = {}
  self.m_towerLevelDic = {}
  self:InitTowerLevelData()
end

function LevelTowerHelper:SetStageData(stageData)
  if not stageData then
    return
  end
  self.m_curStageData = stageData
end

function LevelTowerHelper:FreshPassStageInfo(stPushPassStage)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  if levelType ~= LevelManager.LevelType.Tower then
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
end

function LevelTowerHelper:SetLevelDailyTimes(dailyTimes)
  self.m_dailyTimes = dailyTimes or {}
end

function LevelTowerHelper:FreshLevelDailyTimes(levelSubType, passTimes)
  if not levelSubType then
    return
  end
  if not passTimes then
    return
  end
  self.m_dailyTimes[levelSubType] = passTimes
end

function LevelTowerHelper:GetDailyTimesBySubLevelType(levelSubType)
  if not levelSubType then
    return
  end
  return self.m_dailyTimes[levelSubType] or 0
end

function LevelTowerHelper:GetTowerLevelData()
  return self.m_towerLevelDic
end

function LevelTowerHelper:GetTowerLevelList(levelSubType)
  if not levelSubType then
    return
  end
  local subLevelData = self.m_towerLevelDic[levelSubType]
  if not subLevelData then
    return
  end
  return subLevelData.levelList
end

function LevelTowerHelper:IsLevelHavePass(levelID)
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

function LevelTowerHelper:GetLastPassLevelIDBySubType(levelSubType)
  if not levelSubType then
    return
  end
  if self.m_curStageData[levelSubType] then
    return self.m_curStageData[levelSubType].iLastPassStageId
  end
end

function LevelTowerHelper:IsLevelUnLock(levelID)
  local levelCfg = TribeTowerLevelIns:GetValue_ByLevelID(levelID)
  local unlockLevelID = levelCfg.m_LevelUnlock
  local levelSubType = levelCfg.m_LevelSubType
  local isSubTypeUnlock, unlockType, unlockStr = self:IsLevelSubTypeUnlock(levelSubType)
  if isSubTypeUnlock == false then
    return isSubTypeUnlock, unlockType, unlockStr
  end
  return self:IsLevelHavePass(unlockLevelID)
end

function LevelTowerHelper:IsLevelSubTypeUnlock(levelSubType)
  if not levelSubType then
    return
  end
  local subLevelData = self.m_towerLevelDic[levelSubType]
  if not subLevelData then
    return
  end
  local towerCfg = subLevelData.towerCfg
  local unlockTypeArray = towerCfg.m_UnlockConditionType
  local unlockConditionArray = towerCfg.m_UnlockConditionData
  local unlockTypeList = utils.changeCSArrayToLuaTable(unlockTypeArray)
  local unlockConditionDataList = utils.changeCSArrayToLuaTable(unlockConditionArray)
  return ConditionManager:IsMulConditionUnlock(unlockTypeList, unlockConditionDataList)
end

function LevelTowerHelper:IsLevelSubTypeInOpen(subType)
  if not subType then
    return
  end
  local towerCfg = TowerIns:GetValue_ByLevelSubType(subType)
  if towerCfg:GetError() then
    return
  end
  local openDateArray = towerCfg.m_OpenDate
  local isAllOpen = false
  local isOpen = false
  if openDateArray.Length == 7 then
    isAllOpen = true
    isOpen = true
  else
    local curW = TimeUtil:GetServerTimeWeekDayHaveCommonOffset()
    local openDateLen = openDateArray.Length
    for i = 0, openDateLen - 1 do
      local openDateNum = openDateArray[i]
      if openDateNum == curW then
        isOpen = true
      end
    end
  end
  return isOpen, isAllOpen
end

function LevelTowerHelper:GetNextShowLevelCfg(levelSubType)
  if not levelSubType then
    return
  end
  local levelSubTypeData = self.m_towerLevelDic[levelSubType]
  if not levelSubTypeData then
    return
  end
  local levelList = levelSubTypeData.levelList
  if not levelList then
    return
  end
  local lastPassLevelID = self:GetLastPassLevelIDBySubType(levelSubType)
  if not lastPassLevelID or lastPassLevelID == 0 then
    return levelList[1]
  end
  local levelMainCfg = TribeTowerLevelIns:GetValue_ByLevelID(lastPassLevelID)
  if levelMainCfg:GetError() then
    return
  end
  local levelIndex
  for i, levelCfg in ipairs(levelList) do
    if levelCfg.m_LevelID == lastPassLevelID then
      levelIndex = i
      break
    end
  end
  if levelIndex >= #levelList then
    return levelList[#levelList]
  end
  return levelList[levelIndex + 1]
end

function LevelTowerHelper:GetAssignLevelParams(levelSubType, levelID)
  return {
    LevelManager.LevelType.Tower,
    levelSubType,
    0,
    levelID
  }
end

function LevelTowerHelper:InitTowerLevelData()
  for _, v in pairs(LevelManager.TowerLevelSubType) do
    local towerSubType = v
    local subTowerCfg = TowerIns:GetValue_ByLevelSubType(towerSubType)
    self.m_towerLevelDic[towerSubType] = {
      towerCfg = subTowerCfg,
      levelList = {}
    }
  end
  local allTowerLevelDic = TribeTowerLevelIns:GetAll()
  for _, towerLvCfg in pairs(allTowerLevelDic) do
    if towerLvCfg then
      local levelSubType = towerLvCfg.m_LevelSubType
      local subTypeLevelDic = self.m_towerLevelDic[levelSubType]
      if subTypeLevelDic then
        subTypeLevelDic.levelList[#subTypeLevelDic.levelList + 1] = towerLvCfg
      end
    end
  end
  for _, subLevelDic in pairs(self.m_towerLevelDic) do
    if subLevelDic and next(subLevelDic) then
      subLevelDic.levelList = self:ChangeLevelListToSort(subLevelDic.levelList)
    end
  end
end

function LevelTowerHelper:ChangeLevelListToSort(levelList)
  if not levelList then
    return
  end
  if not next(levelList) then
    return {}
  end
  local tempLevelDic = {}
  local startLevelID
  for _, mainLevelCfg in ipairs(levelList) do
    if mainLevelCfg then
      if mainLevelCfg.m_LevelUnlock == 0 then
        startLevelID = mainLevelCfg.m_LevelID
      end
      tempLevelDic[mainLevelCfg.m_LevelID] = {levelCfg = mainLevelCfg, nextID = nil}
    end
  end
  for _, mainLevelCfg in ipairs(levelList) do
    if mainLevelCfg and mainLevelCfg.m_LevelUnlock ~= 0 then
      local unlockLevelID = mainLevelCfg.m_LevelUnlock
      if tempLevelDic[unlockLevelID] then
        tempLevelDic[unlockLevelID].nextID = mainLevelCfg.m_LevelID
      end
    end
  end
  local sortLevelList = {}
  local tempLevelID = startLevelID
  sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
  while tempLevelDic[tempLevelID].nextID ~= nil do
    tempLevelID = tempLevelDic[tempLevelID].nextID
    if tempLevelDic[tempLevelID] then
      sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
    end
  end
  return sortLevelList
end

function LevelTowerHelper:IsAllLevelPass()
  if not self.m_towerLevelDic and not next(self.m_towerLevelDic) then
    return true
  end
  local isAllMainTowerPass = true
  for _, levelSubTypeData in pairs(self.m_towerLevelDic) do
    local levelList = levelSubTypeData.levelList
    if levelList and next(levelList) then
      local maxLevelCfg = levelList[#levelList]
      if maxLevelCfg and self:IsLevelHavePass(maxLevelCfg.m_LevelID) ~= true then
        isAllMainTowerPass = false
        break
      end
    end
  end
  return isAllMainTowerPass
end

function LevelTowerHelper:IsSubTowerAllLevelPass(subTowerType)
  if not subTowerType then
    return
  end
  if not self.m_towerLevelDic and not next(self.m_towerLevelDic) then
    return true
  end
  local isAllPass = true
  local levelSubTypeData = self.m_towerLevelDic[subTowerType]
  if not levelSubTypeData then
    return
  end
  local levelList = levelSubTypeData.levelList
  if levelList and next(levelList) then
    local maxLevelCfg = levelList[#levelList]
    if maxLevelCfg and self:IsLevelHavePass(maxLevelCfg.m_LevelID) ~= true then
      isAllPass = false
    end
  end
  return isAllPass
end

function LevelTowerHelper:IsSubTowerHaveTimes(subTowerType)
  if not subTowerType then
    return
  end
  local levelSubTypeData = self.m_towerLevelDic[subTowerType]
  if not levelSubTypeData then
    return
  end
  local towerCfg = levelSubTypeData.towerCfg
  if not towerCfg then
    return
  end
  local maxTimes = towerCfg.m_Times or 0
  local curTimes = self:GetDailyTimesBySubLevelType(subTowerType) or 0
  local leftTimes = maxTimes - curTimes
  return 0 < leftTimes, curTimes, maxTimes
end

function LevelTowerHelper:CheckSetSubTowerDailyEnterTime(levelSubType)
  if not levelSubType then
    return
  end
  local isOpen = self:IsLevelSubTypeInOpen(levelSubType)
  if isOpen ~= true then
    return
  end
  local isSubTypeUnlock = self:IsLevelSubTypeUnlock(levelSubType)
  if isSubTypeUnlock ~= true then
    return
  end
  local enterTimerStr = self:GetSubTowerDailyEnterTime(levelSubType) or "0"
  if enterTimerStr == nil or enterTimerStr == "0" then
    self:SetSubTowerDailyEnterTime(levelSubType)
  else
    local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
    if TimeUtil:IsCurDayTime(enterTimer) == true then
      return
    end
    self:SetSubTowerDailyEnterTime(levelSubType)
  end
end

function LevelTowerHelper:SetSubTowerDailyEnterTime(levelSubType)
  if not levelSubType then
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local curServerTimeStr = TimeUtil:ServerTimerToServerString(curServerTime)
  LocalDataManager:SetStringSimple("SubTowerEnterTime_" .. levelSubType, curServerTimeStr)
end

function LevelTowerHelper:GetSubTowerDailyEnterTime(levelSubType)
  if not levelSubType then
    return
  end
  return LocalDataManager:GetStringSimple("SubTowerEnterTime_" .. levelSubType, "0")
end

function LevelTowerHelper:IsSubTowerHaveRedDot(levelSubType)
  if not levelSubType then
    return 0
  end
  local isSubTypeUnlock = self:IsLevelSubTypeUnlock(levelSubType)
  if isSubTypeUnlock ~= true then
    return 0
  end
  local isOpen = self:IsLevelSubTypeInOpen(levelSubType)
  if isOpen ~= true then
    return 0
  end
  if levelSubType == LevelManager.TowerLevelSubType.Main then
    local mainEnterTimeStr = self:GetSubTowerDailyEnterTime(levelSubType)
    if mainEnterTimeStr == nil or mainEnterTimeStr == "0" then
      return 1
    else
      return 0
    end
  else
    local subEnterTimeStr = self:GetSubTowerDailyEnterTime(levelSubType)
    if subEnterTimeStr == nil or subEnterTimeStr == "0" then
      return 1
    else
      local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(subEnterTimeStr) or 0
      if TimeUtil:IsCurDayTime(enterTimer) == true then
        return 0
      else
        return 1
      end
    end
  end
end

function LevelTowerHelper:IsHaveRedDot()
  local levelType = LevelManager.LevelType.Tower
  local clientDataKey = LevelManager:GetEnterClientDataKeyByLevelType(levelType)
  if not clientDataKey then
    return
  end
  local enterTimerStr = ClientDataManager:GetClientValueStringByKey(clientDataKey)
  local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
  local redDotNum = 0
  if TimeUtil:IsCurDayTime(enterTimer) ~= true then
    redDotNum = redDotNum + 1
  end
  redDotNum = redDotNum + self:IsSubTowerHaveRedDot(LevelManager.TowerLevelSubType.Main)
  for i = 1, LevelManager.TowerTribeMaxNum do
    local subLevelType = LevelManager.TowerLevelSubType["Tribe" .. i]
    local isSubTypeUnlock = self:IsLevelSubTypeUnlock(subLevelType)
    if isSubTypeUnlock == true then
      local isOpen = self:IsLevelSubTypeInOpen(subLevelType)
      if isOpen == true then
        redDotNum = redDotNum + self:IsSubTowerHaveRedDot(subLevelType)
      end
    end
  end
  return redDotNum
end

function LevelTowerHelper:GetTowerCfgByLevelSubType(levelSubType)
  if not levelSubType then
    return
  end
  local subLevelData = self.m_towerLevelDic[levelSubType]
  if not subLevelData then
    return
  end
  return subLevelData.towerCfg
end

return LevelTowerHelper
