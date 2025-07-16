local LevelHeroActivityLamiaHelper = class("LevelHeroActivityLamiaHelper")
local ActivityMainInfoIns = ConfigManager:GetConfigInsByName("ActivityMainInfo")
local ActLamiaLevelIns = ConfigManager:GetConfigInsByName("ActLamiaLevel")
local ActivitySubInfoIns = ConfigManager:GetConfigInsByName("ActivitySubInfo")
local pairs = _ENV.pairs
local next = _ENV.next
local table_sort = table.sort

function LevelHeroActivityLamiaHelper:ctor()
  self.m_curStageData = {}
  self.m_levelDic = {}
  self.m_cacheLevelCfgDic = {}
  self.m_cacheSpecialRewardLevelList = {}
end

function LevelHeroActivityLamiaHelper:ChangeLevelListToSort(levelList)
  if not levelList then
    return
  end
  if not next(levelList) then
    return {}
  end
  local tempLevelDic = {}
  local startLevelID
  for _, tempLevelCfg in ipairs(levelList) do
    if tempLevelCfg then
      if tempLevelCfg.m_PreLevel == 0 then
        startLevelID = tempLevelCfg.m_LevelID
      end
      tempLevelDic[tempLevelCfg.m_LevelID] = {levelCfg = tempLevelCfg, nextID = nil}
    end
  end
  for _, tempLevelCfg in ipairs(levelList) do
    if tempLevelCfg and tempLevelCfg.m_PreLevel ~= 0 then
      local unlockLevelID = tempLevelCfg.m_PreLevel
      if tempLevelDic[unlockLevelID] then
        tempLevelDic[unlockLevelID].nextID = tempLevelCfg.m_LevelID
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

function LevelHeroActivityLamiaHelper:CreateLevelDataByActivityID(activityID)
  if not activityID then
    return
  end
  local actMainInfoCfg = ActivityMainInfoIns:GetValue_ByActivityID(activityID)
  if actMainInfoCfg:GetError() == true then
    return
  end
  local activityLevelData = {
    activityMainInfoCfg = actMainInfoCfg,
    activitySubLevelInfo = {}
  }
  local allLamiaLevelCfgDic = ActLamiaLevelIns:GetAll()
  for _, levelCfg in pairs(allLamiaLevelCfgDic) do
    if levelCfg.m_ActivityID == activityID then
      local subActivitySubID = levelCfg.m_ActivitySubID
      local tempActSubLevelInfo = activityLevelData.activitySubLevelInfo[subActivitySubID]
      if tempActSubLevelInfo == nil then
        local activitySubLevelInfoCfg = ActivitySubInfoIns:GetValue_ByActivitySubID(subActivitySubID)
        tempActSubLevelInfo = {
          activitySubInfoCfg = activitySubLevelInfoCfg,
          levelCfgList = {}
        }
        activityLevelData.activitySubLevelInfo[subActivitySubID] = tempActSubLevelInfo
      end
      local levelCfgList = tempActSubLevelInfo.levelCfgList
      levelCfgList[#levelCfgList + 1] = levelCfg
    end
  end
  local activitySubLevelInfo = activityLevelData.activitySubLevelInfo
  for _, tempActSubLevelInfo in pairs(activitySubLevelInfo) do
    local levelList = tempActSubLevelInfo.levelCfgList
    tempActSubLevelInfo.levelCfgList = self:ChangeLevelListToSort(levelList)
  end
  return activityLevelData
end

function LevelHeroActivityLamiaHelper:CheckCacheLastPassSpecialLevel(lastStageInfo, curStageInfo)
  if not lastStageInfo then
    return
  end
  if not curStageInfo then
    return
  end
  if lastStageInfo.iLastPassedStage ~= curStageInfo.iLastPassedStage then
    local lastPassLevelCfg = self:GetLevelCfgByID(curStageInfo.iLastPassedStage)
    if lastPassLevelCfg and lastPassLevelCfg.m_Special and lastPassLevelCfg.m_Special.Length > 0 then
      self:InsertSpecialRewardLevelCache(curStageInfo.iLastPassedStage)
    end
  end
end

function LevelHeroActivityLamiaHelper:InsertSpecialRewardLevelCache(lastPassSpecialLevelID)
  if not lastPassSpecialLevelID then
    return
  end
  self.m_cacheSpecialRewardLevelList[#self.m_cacheSpecialRewardLevelList + 1] = lastPassSpecialLevelID
end

function LevelHeroActivityLamiaHelper:GetLevelUnlockStr(levelCfg)
  if not levelCfg then
    return
  end
  local openTimeStr = levelCfg.m_OpenTime
  local unlockLevelID = levelCfg.m_PreLevel
  local unlockLevelCfg = self:GetLevelCfgByID(unlockLevelID) or {}
  local unlockLevelStr = unlockLevelCfg.m_LevelRef or ""
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.Level, levelCfg)
  if is_corved then
    openTimeStr = TimeUtil:TimerToString3(t1)
  end
  local formatUnlockStr
  if openTimeStr ~= "" then
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40039)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr, openTimeStr)
  else
    formatUnlockStr = ConfigManager:GetClientMessageTextById(40036)
    formatUnlockStr = string.CS_Format(formatUnlockStr, unlockLevelStr)
  end
  return formatUnlockStr
end

function LevelHeroActivityLamiaHelper:GetLevelDataByID(activityID)
  if not activityID then
    return
  end
  local actLevelData = self.m_levelDic[activityID]
  if actLevelData == nil then
    actLevelData = self:CreateLevelDataByActivityID(activityID)
    self.m_levelDic[activityID] = actLevelData
  end
  return actLevelData
end

function LevelHeroActivityLamiaHelper:GetLevelUnlockNameStr(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  return levelCfg.m_LevelRef
end

function LevelHeroActivityLamiaHelper:GetLevelDataByActAndSubID(activityID, activitySubID)
  if not activityID then
    return
  end
  if not activitySubID then
    return
  end
  local actLeveData = self:GetLevelDataByID(activityID)
  if not actLeveData then
    return
  end
  local tempActSubLevelInfo = actLeveData.activitySubLevelInfo[activitySubID]
  if not tempActSubLevelInfo then
    return
  end
  return tempActSubLevelInfo
end

function LevelHeroActivityLamiaHelper:GetLevelCfgByID(levelID)
  if not levelID then
    return
  end
  local levelCfg = self.m_cacheLevelCfgDic[levelID]
  if not levelCfg then
    levelCfg = ActLamiaLevelIns:GetValue_ByLevelID(levelID)
    if levelCfg:GetError() == true then
      return
    end
    self.m_cacheLevelCfgDic[levelID] = levelCfg
  end
  return levelCfg
end

function LevelHeroActivityLamiaHelper:FreshStageInfo(activityID, subActivityID, stageInfo)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local actTab = self.m_curStageData[activityID]
  if not actTab then
    actTab = {}
    self.m_curStageData[activityID] = actTab
  end
  local lastSubStageInfo = actTab[subActivityID]
  if lastSubStageInfo ~= nil then
    self:CheckCacheLastPassSpecialLevel(lastSubStageInfo, stageInfo)
  end
  actTab[subActivityID] = stageInfo
end

function LevelHeroActivityLamiaHelper:CheckPopUpLastSpecialRewardLevel()
  if not self.m_cacheSpecialRewardLevelList then
    return
  end
  if not next(self.m_cacheSpecialRewardLevelList) then
    return
  end
  local maxIndex = #self.m_cacheSpecialRewardLevelList
  local lastPassLevelID = self.m_cacheSpecialRewardLevelList[maxIndex]
  table.remove(self.m_cacheSpecialRewardLevelList, maxIndex)
  return lastPassLevelID
end

function LevelHeroActivityLamiaHelper:FreshStageTimes(activityID, subActivityID, times)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local actTab = self.m_curStageData[activityID]
  if not actTab then
    actTab = {}
    self.m_curStageData[activityID] = actTab
  end
  local subStageInfo = actTab[subActivityID]
  if subStageInfo == nil then
    subStageInfo = {}
    actTab[subActivityID] = subStageInfo
  end
  subStageInfo.iPassedTimesDaily = times
end

function LevelHeroActivityLamiaHelper:GetSubActLevelList(activityID, subActivityID)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local actLevelData = self.m_levelDic[activityID]
  if not actLevelData then
    return
  end
  local subLevelData = actLevelData.activitySubLevelInfo
  if not subLevelData then
    return
  end
  return subLevelData.levelCfgList
end

function LevelHeroActivityLamiaHelper:GetDailyTimesBySubActivityAndSubID(activityID, subActivityID)
  if not activityID then
    return
  end
  local actSubLevelInfoDic = self.m_curStageData[activityID] or {}
  local subLevelStageInfo = actSubLevelInfoDic[subActivityID] or {}
  return subLevelStageInfo.iPassedTimesDaily or 0
end

function LevelHeroActivityLamiaHelper:GetLeftFreeTimes(activityID, subActivityID)
  local subCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
  if not subCfg then
    return
  end
  local subFunType = subCfg.m_ActivitySubType
  local curUseTimes = self:GetDailyTimesBySubActivityAndSubID(activityID, subActivityID) or 0
  local totalFreeNum
  if subFunType == HeroActivityManager.SubActTypeEnum.ChallengeLevel then
    totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaChallengeDailyLimit") or 0)
  else
    totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaPassDailyLimit") or 0)
  end
  return totalFreeNum - curUseTimes, totalFreeNum
end

function LevelHeroActivityLamiaHelper:IsHaveActDataBylevelId(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local activityID = levelCfg.m_ActivityID
  if self.m_curStageData and self.m_curStageData[activityID] then
    return true
  end
  return false
end

function LevelHeroActivityLamiaHelper:IsLevelHavePass(levelID)
  if not levelID then
    return
  end
  if levelID == 0 then
    return true
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local activityID = levelCfg.m_ActivityID
  local subActivityID = levelCfg.m_ActivitySubID
  if not self.m_curStageData[activityID] then
    return
  end
  local stageInfo = self.m_curStageData[activityID][subActivityID]
  if not stageInfo then
    return
  end
  local stageState = stageInfo.mStageStat
  if not stageState then
    return
  end
  if stageState[levelID] ~= nil and stageState[levelID] ~= 0 then
    return true
  end
  return false
end

function LevelHeroActivityLamiaHelper:GetLastPassLevelIDByActIDAndSubID(activityID, subActivityID)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local subActivityStageInfoDic = self.m_curStageData[activityID]
  if not subActivityStageInfoDic then
    return
  end
  local subActivityStageInfo = subActivityStageInfoDic[subActivityID]
  if not subActivityStageInfo then
    return
  end
  return subActivityStageInfo.iLastPassedStage
end

function LevelHeroActivityLamiaHelper:IsLevelUnLock(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local activityID = levelCfg.m_ActivityID
  local subActivityID = levelCfg.m_ActivitySubID
  local isUnlock, unlockType, lockStr = HeroActivityManager:IsSubActIsOpenByID(activityID, subActivityID)
  if isUnlock ~= true then
    return isUnlock, unlockType, lockStr
  end
  local openTimeStr = levelCfg.m_OpenTime
  local unlockLevelID = levelCfg.m_PreLevel
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.Level, levelCfg)
  if is_corved then
    openTimeStr = TimeUtil:TimerToString3(t1)
  end
  local openTimer = TimeUtil:TimeStringToTimeSec2(openTimeStr) or 0
  local serverTimer = TimeUtil:GetServerTimeS()
  if openTimer > serverTimer then
    return false, _, self:GetLevelUnlockStr(levelCfg)
  end
  isUnlock = self:IsLevelHavePass(unlockLevelID)
  if isUnlock ~= true then
    return false, _, self:GetLevelUnlockStr(levelCfg)
  end
  return isUnlock
end

function LevelHeroActivityLamiaHelper:GetNextShowLevelCfg(activityID, subActivityID)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local levelData = self:GetLevelDataByActAndSubID(activityID, subActivityID)
  if not levelData then
    return
  end
  local levelList = levelData.levelCfgList
  if not levelList then
    return
  end
  local lastPassLevelID = self:GetLastPassLevelIDByActIDAndSubID(activityID, subActivityID)
  if not lastPassLevelID or lastPassLevelID == 0 then
    return levelList[1]
  end
  local lastPassLevelCfg = self:GetLevelCfgByID(lastPassLevelID)
  if not lastPassLevelCfg then
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

function LevelHeroActivityLamiaHelper:GetCurLevel(activityID, subActivityID)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local levelData = self:GetLevelDataByActAndSubID(activityID, subActivityID)
  if not levelData then
    return
  end
  local levelList = levelData.levelCfgList
  if not levelList then
    return
  end
  local levelIndex = 0
  for i, levelCfg in ipairs(levelList) do
    if self:IsLevelHavePass(levelCfg.m_LevelID) then
      levelIndex = i
    else
      break
    end
  end
  if levelIndex >= #levelList then
    return levelList[#levelList]
  end
  return levelList[levelIndex + 1]
end

function LevelHeroActivityLamiaHelper:IsAllLevelPassByActivityID(activityID)
  if not activityID then
    return
  end
  local activityLevelData = self:GetLevelDataByID(activityID)
  if activityLevelData then
    return
  end
  local subLamiaLevelStageInfoDic = activityLevelData.activitySubLevelInfo
  if not subLamiaLevelStageInfoDic then
    return
  end
  for _, v in pairs(subLamiaLevelStageInfoDic) do
    local levelList = v.levelCfgList
    if levelList and next(levelList) then
      for _, temCfg in ipairs(levelList) do
        if self:IsLevelHavePass(temCfg.m_LevelID) ~= true then
          return false
        end
      end
    end
  end
  return true
end

function LevelHeroActivityLamiaHelper:IsSubActAllLevelPassByActIDAndSubID(activityID, subActivityID)
  if not activityID then
    return
  end
  if not subActivityID then
    return
  end
  local subLamiaLevelStageInfoDic = self:GetLevelDataByActAndSubID(activityID, subActivityID)
  if not subLamiaLevelStageInfoDic then
    return
  end
  for _, v in pairs(subLamiaLevelStageInfoDic) do
    local levelList = v.levelCfgList
    if levelList and next(levelList) then
      for _, temCfg in ipairs(levelList) do
        if self:IsLevelHavePass(temCfg.m_LevelID) ~= true then
          return false
        end
      end
    end
  end
  return true
end

return LevelHeroActivityLamiaHelper
