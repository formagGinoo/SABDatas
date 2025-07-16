local LevelGoblinHelper = class("LevelGoblinHelper")
local GoblinLevelIns = ConfigManager:GetConfigInsByName("GoblinLevel")
local GoblinRewardIns = ConfigManager:GetConfigInsByName("GoblinReward")
local pairs = _ENV.pairs
local next = _ENV.next
local table_sort = table.sort

function LevelGoblinHelper:ctor()
  self.m_curStageData = {}
  self.m_dailyTimes = {}
  self.m_goblinLevelDic = {}
  self.m_goblinMaxTimes = nil
  self.m_stageDetails = {}
  self:InitGoblinLevelData()
end

function LevelGoblinHelper:SetStageData(stageData)
  if not stageData then
    return
  end
  self.m_curStageData = stageData
end

function LevelGoblinHelper:FreshPassStageInfo(stPushPassStage)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  if levelType ~= LevelManager.LevelType.Goblin then
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
  local score = stPushPassStage.iScore or 0
  if 0 < score then
    self:FreshLevelDetailScore(levelID, score)
  end
end

function LevelGoblinHelper:SetLevelDailyTimes(dailyTimes)
  self.m_dailyTimes = dailyTimes or {}
end

function LevelGoblinHelper:FreshLevelDailyTimes(levelSubType, passTimes)
  if not levelSubType then
    return
  end
  if not passTimes then
    return
  end
  self.m_dailyTimes[levelSubType] = passTimes
end

function LevelGoblinHelper:GetDailyTimesBySubLevelType(levelSubType)
  if not levelSubType then
    return
  end
  return self.m_dailyTimes[levelSubType] or 0
end

function LevelGoblinHelper:FreshLevelDetail(levelStageDetails)
  if not levelStageDetails or not next(levelStageDetails) then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  for key, value in pairs(levelStageDetails) do
    self.m_stageDetails[key] = value
  end
end

function LevelGoblinHelper:FreshLevelDetailScore(levelID, score)
  if not score then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  local detailData = self.m_stageDetails[levelID] or {}
  detailData.iScore = score
  self.m_stageDetails[levelID] = detailData
end

function LevelGoblinHelper:GetLevelDetailDataByLevelID(levelID)
  if not levelID then
    return
  end
  return self.m_stageDetails[levelID]
end

function LevelGoblinHelper:GetGoblinLevelData()
  return self.m_goblinLevelDic
end

function LevelGoblinHelper:GetGoblinLevelList(levelSubType)
  if not levelSubType then
    return
  end
  local subLevelData = self.m_goblinLevelDic[levelSubType]
  if not subLevelData then
    return
  end
  return subLevelData.levelList
end

function LevelGoblinHelper:IsLevelHavePass(levelID)
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

function LevelGoblinHelper:GetLastPassLevelIDBySubType(levelSubType)
  if not levelSubType then
    return
  end
  if self.m_curStageData[levelSubType] then
    return self.m_curStageData[levelSubType].iLastPassStageId
  end
end

function LevelGoblinHelper:IsLevelUnLock(levelID)
  local levelCfg = GoblinLevelIns:GetValue_ByLevelID(levelID)
  local unlockSystemID = levelCfg.m_SystemID
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(unlockSystemID)
  return openFlag, tips_id
end

function LevelGoblinHelper:IsLevelSubTypeUnlock(levelSubType)
  if not levelSubType then
    return
  end
  return true
end

function LevelGoblinHelper:GetNextShowLevelCfg(levelSubType)
  if not levelSubType then
    return
  end
  local levelSubTypeData = self.m_goblinLevelDic[levelSubType]
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
  local levelMainCfg = GoblinLevelIns:GetValue_ByLevelID(lastPassLevelID)
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

function LevelGoblinHelper:GetGoblinMaxTimes()
  if self.m_goblinMaxTimes == nil then
    self.m_goblinMaxTimes = tonumber(ConfigManager:GetGlobalSettingsByKey("GoblinDailyLimit"))
  end
  return self.m_goblinMaxTimes
end

function LevelGoblinHelper:IsLevelDailyHavePassOne(levelID)
  if not levelID then
    return
  end
  local levelDetailData = self.m_stageDetails[levelID] or {}
  local score = levelDetailData.iScore or 0
  return 0 < score
end

function LevelGoblinHelper:GetGoblinRewardIndex(levelCfg)
  if not levelCfg then
    return
  end
  local rewardGroupID = levelCfg.m_RewardGroupID
  if not rewardGroupID then
    return
  end
  local groupRewardCfgList = {}
  local groupRewardCfgArray = GoblinRewardIns:GetValue_ByRewardGroupID(rewardGroupID)
  if not groupRewardCfgArray then
    return
  end
  for _, v in pairs(groupRewardCfgArray) do
    local tempReward = {
      rewardCfg = v,
      stageID = v.m_StageID
    }
    groupRewardCfgList[#groupRewardCfgList + 1] = tempReward
  end
  table.sort(groupRewardCfgList, function(a, b)
    return a.stageID < b.stageID
  end)
  local stageDetail = self:GetLevelDetailDataByLevelID(levelCfg.m_LevelID) or {}
  local scoreNum = stageDetail.iScore or 0
  local rewardStageNum = #groupRewardCfgList
  local curStageIndex = 0
  for i, v in ipairs(groupRewardCfgList) do
    local minScoreNum = v.rewardCfg.m_CountMin
    local upScoreNum
    if i < rewardStageNum then
      upScoreNum = groupRewardCfgList[i + 1].rewardCfg.m_CountMin
    else
      upScoreNum = v.rewardCfg.m_CountMin
    end
    if scoreNum < minScoreNum then
      break
    end
    curStageIndex = i
    if scoreNum >= minScoreNum and scoreNum < upScoreNum then
      break
    end
  end
  return curStageIndex, rewardStageNum, scoreNum
end

function LevelGoblinHelper:GetAssignLevelParams(levelSubType, levelID)
  return {
    LevelManager.LevelType.Goblin,
    levelSubType,
    0,
    levelID
  }
end

function LevelGoblinHelper:InitGoblinLevelData()
  for _, v in pairs(LevelManager.GoblinSubType) do
    local subType = v
    self.m_goblinLevelDic[subType] = {
      levelSubType = subType,
      levelList = {}
    }
  end
  local allLevelDic = GoblinLevelIns:GetAll()
  for _, levelCfg in pairs(allLevelDic) do
    if levelCfg then
      local levelSubType = levelCfg.m_LevelSubType
      local subTypeLevelDic = self.m_goblinLevelDic[levelSubType]
      if subTypeLevelDic then
        subTypeLevelDic.levelList[#subTypeLevelDic.levelList + 1] = levelCfg
      end
    end
  end
  for _, subLevelDic in pairs(self.m_goblinLevelDic) do
    if subLevelDic and next(subLevelDic) then
      subLevelDic.levelList = self:ChangeLevelListToSort(subLevelDic.levelList)
    end
  end
end

function LevelGoblinHelper:ChangeLevelListToSort(levelList)
  if not levelList then
    return
  end
  if not next(levelList) then
    return {}
  end
  table_sort(levelList, function(a, b)
    return a.m_LevelID < b.m_LevelID
  end)
  return levelList
end

function LevelGoblinHelper:IsAllLevelPass()
  if not self.m_goblinLevelDic and not next(self.m_goblinLevelDic) then
    return true
  end
  for _, levelSubTypeData in pairs(self.m_goblinLevelDic) do
    local levelList = levelSubTypeData.levelList
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

function LevelGoblinHelper:IsSubLevelAllLevelPass(subType)
  if not subType then
    return
  end
  if not self.m_goblinLevelDic and not next(self.m_goblinLevelDic) then
    return true
  end
  local levelSubTypeData = self.m_goblinLevelDic[subType]
  if not levelSubTypeData then
    return
  end
  local levelList = levelSubTypeData.levelList
  if levelList and next(levelList) then
    for _, temCfg in ipairs(levelList) do
      if self:IsLevelHavePass(temCfg.m_LevelID) ~= true then
        return false
      end
    end
  end
  return true
end

function LevelGoblinHelper:IsSubLevelHaveTimes(subLevelType)
  if not subLevelType then
    return
  end
  local levelSubTypeData = self.m_goblinLevelDic[subLevelType]
  if not levelSubTypeData then
    return
  end
  local maxTimes = self:GetGoblinMaxTimes()
  local curTimes = self:GetDailyTimesBySubLevelType(subLevelType) or 0
  local leftTimes = maxTimes - curTimes
  return 0 < leftTimes, curTimes, maxTimes
end

function LevelGoblinHelper:IsLevelHaveRedDot(levelSubType, levelID)
  if not levelID then
    return 0
  end
  local isHaveTimes = self:IsSubLevelHaveTimes(levelSubType)
  if not isHaveTimes then
    return 0
  end
  local isUnlock = self:IsLevelUnLock(levelID)
  if isUnlock == true then
    return 1
  end
  return 0
end

function LevelGoblinHelper:IsHaveRedDot(levelSubType)
  local isHaveTimes = self:IsSubLevelHaveTimes(levelSubType)
  if not isHaveTimes then
    return 0
  end
  local levelList = self:GetGoblinLevelList(levelSubType)
  if not levelList then
    return 0
  end
  local unlockNum = 0
  for _, levelCfg in ipairs(levelList) do
    unlockNum = unlockNum + self:IsLevelHaveRedDot(levelSubType, levelCfg.m_LevelID)
  end
  return unlockNum
end

return LevelGoblinHelper
