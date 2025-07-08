local LevelEquipmentHelper = class("LevelEquipmentHelper")

function LevelEquipmentHelper:ctor()
  self.m_dailyTimes = 0
  self.m_dailyBossIdMap = 0
  self.m_allPassChapterStagesIds = {}
  self.m_challengeDailyNum = tonumber(ConfigManager:GetGlobalSettingsByKey("DungeonLevelChallengetimes"))
  self.m_bossObjTab = {}
  self.m_bossCameraTab = {}
  self.m_bossPosObjTab = {}
  self.m_bossAnimatorTab = {}
  self:ReqStageGetDungeonChapterMopCS()
  self.m_dungeonLevelPhaseListDic = {}
  self.m_residentBossIdList = self:GetResidentBossIdTab()
end

function LevelEquipmentHelper:ReqStageGetDungeonChapterMopCS()
  local stageGetListCSMsg = MTTDProto.Cmd_Stage_GetDungeonChapterMop_CS()
  RPCS():Stage_GetDungeonChapterMop(stageGetListCSMsg, handler(self, self.OnGetDungeonChapterMopSC))
end

function LevelEquipmentHelper:OnGetDungeonChapterMopSC(stStageData, msg)
  self.m_dailyTimes = stStageData.iTimes
  self.m_dailyBossIdMap = stStageData.mRotationLevelSubType
end

function LevelEquipmentHelper:GetChallengeDailyNum()
  return self.m_challengeDailyNum
end

function LevelEquipmentHelper:SetStageData(stageDataTab)
  if stageDataTab and stageDataTab then
    for i, v in pairs(stageDataTab) do
      local dataTab = v.mStageFirstFinishTime
      if dataTab then
        for id, time in pairs(dataTab) do
          self.m_allPassChapterStagesIds[id] = time
        end
      end
    end
  end
end

function LevelEquipmentHelper:IsLevelHavePass(stageId)
  local passTime = 0
  if stageId then
    if stageId == 0 then
      return true
    end
    passTime = self.m_allPassChapterStagesIds[stageId]
    if self.m_allPassChapterStagesIds[stageId] and self.m_allPassChapterStagesIds[stageId] ~= 0 then
      return true, passTime
    end
  end
  return false, passTime
end

function LevelEquipmentHelper:IsHaveRedDot()
  local redpoint = self.m_challengeDailyNum - self.m_dailyTimes
  return redpoint
end

function LevelEquipmentHelper:GetChapterIndexByLevelID(levelID)
  local levelCfg = self:GetDunLevelCfgById(levelID)
  if not levelCfg then
    return
  end
  local subLevelType = levelCfg.m_LevelSubType
  local chapterCfg = self:GetDunChapterById(subLevelType)
  if not chapterCfg then
    return
  end
  return chapterCfg.m_Order
end

function LevelEquipmentHelper:FreshPassStageInfo(stPushPassStage)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  if levelType ~= LevelManager.LevelType.Dungeon then
    return
  end
  local levelID = stPushPassStage.iStageId
  self.m_allPassChapterStagesIds[levelID] = 1
  local score = stPushPassStage.iScore or 0
  if 0 < score then
    self:FreshLevelDetailScore(levelID, score)
  end
  local damage = stPushPassStage.iDamage or 0
  if 0 < damage then
    self:FreshLevelDetailDamage(levelID, damage)
  end
  local finishNum = stPushPassStage.iFinishNum or 0
  if 0 < finishNum then
    self:FreshLevelDetailFinishNum(levelID, finishNum)
  end
  local topDamage = stPushPassStage.iTopDamage or 0
  if 0 < topDamage then
    self:FreshLevelDetailTopDamage(levelID, topDamage)
  end
end

function LevelEquipmentHelper:FreshLevelDetail(levelStageDetails)
  if not levelStageDetails or not next(levelStageDetails) then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  for key, value in pairs(levelStageDetails) do
    local iTopDamageNum = value.iDamage
    value.iTopDamage = iTopDamageNum
    value.iDamage = nil
    self.m_stageDetails[key] = value
  end
end

function LevelEquipmentHelper:FreshLevelDetailScore(levelID, score)
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

function LevelEquipmentHelper:FreshLevelDetailDamage(levelID, damage)
  if not damage then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  local detailData = self.m_stageDetails[levelID] or {}
  detailData.iDamage = damage
  self.m_stageDetails[levelID] = detailData
end

function LevelEquipmentHelper:FreshLevelDetailTopDamage(levelID, topDamage)
  if not topDamage then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  local detailData = self.m_stageDetails[levelID] or {}
  detailData.iTopDamage = topDamage
  self.m_stageDetails[levelID] = detailData
end

function LevelEquipmentHelper:FreshLevelDetailFinishNum(levelID, finishNum)
  if not finishNum then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  local detailData = self.m_stageDetails[levelID] or {}
  detailData.iFinishNum = finishNum
  self.m_stageDetails[levelID] = detailData
end

function LevelEquipmentHelper:GetLevelDetailDataByLevelID(levelID)
  if not levelID then
    return
  end
  if not self.m_stageDetails then
    self.m_stageDetails = {}
  end
  return self.m_stageDetails[levelID]
end

function LevelEquipmentHelper:GetLevelScoreByLevelID(levelID)
  if not levelID then
    return
  end
  local tempDetail = self:GetLevelDetailDataByLevelID(levelID) or {}
  local tempScore = tempDetail.iScore
  if tempScore == nil or tempScore == 0 then
    if self.m_dailyTimes == 0 then
      return -1
    else
      return 0
    end
  end
  return tempDetail.iScore
end

function LevelEquipmentHelper:GetLevelDamageByLevelID(levelID)
  if not levelID then
    return
  end
  local tempDetail = self:GetLevelDetailDataByLevelID(levelID) or {}
  local tempDamage = tempDetail.iDamage
  local finishNum = self:GetLevelFinishNumByLevelID(levelID)
  if tempDamage == nil or tempDamage == 0 then
    if finishNum == 0 then
      return -1
    else
      return 0
    end
  end
  return tonumber(tempDetail.iDamage)
end

function LevelEquipmentHelper:GetLevelTopDamageByLevelID(levelID)
  if not levelID then
    return
  end
  local tempDetail = self:GetLevelDetailDataByLevelID(levelID) or {}
  local tempTopDamage = tonumber(tempDetail.iTopDamage or 0)
  local finishNum = self:GetLevelFinishNumByLevelID(levelID)
  if tempTopDamage == nil or tempTopDamage == 0 then
    if finishNum == 0 then
      return -1
    else
      return 0
    end
  end
  return tonumber(tempDetail.iTopDamage)
end

function LevelEquipmentHelper:GetLevelFinishNumByLevelID(levelID)
  if not levelID then
    return
  end
  local tempDetail = self:GetLevelDetailDataByLevelID(levelID) or {}
  local tempFinishNum = tempDetail.iFinishNum or 0
  return tempFinishNum
end

function LevelEquipmentHelper:SetLevelDailyData(dailyTimes, mRotationLevelSubType)
  self.m_dailyTimes = dailyTimes or 0
  self.m_dailyBossIdMap = mRotationLevelSubType
end

function LevelEquipmentHelper:GetLevelDailyData()
  return self.m_dailyTimes, self.m_dailyBossIdMap
end

function LevelEquipmentHelper:IsLevelHavePass(stageId)
  local passTime = 0
  if stageId then
    if stageId == 0 then
      return true
    end
    passTime = self.m_allPassChapterStagesIds[stageId]
    if self.m_allPassChapterStagesIds[stageId] and self.m_allPassChapterStagesIds[stageId] ~= 0 then
      return true, passTime
    end
  end
  return false, passTime
end

function LevelEquipmentHelper:IsChapterSubTypeUnlock(chapterID)
  if not chapterID then
    return
  end
  local DunChapterIns = ConfigManager:GetConfigInsByName("DunChapter")
  local chapterCfg = DunChapterIns:GetValue_ByLevelSubType(chapterID)
  local unlockTypeArray = chapterCfg.m_UnlockConditionType
  local unlockConditionArray = chapterCfg.m_UnlockConditionData
  local unlockTypeList = utils.changeCSArrayToLuaTable(unlockTypeArray)
  local unlockConditionDataList = utils.changeCSArrayToLuaTable(unlockConditionArray)
  return ConditionManager:IsMulConditionUnlock(unlockTypeList, unlockConditionDataList)
end

function LevelEquipmentHelper:IsLevelUnLock(levelID)
  local DunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")
  local levelCfg = DunLevelIns:GetValue_ByLevelID(levelID)
  local unlockLevelID = levelCfg.m_LevelUnlock
  local levelSubType = levelCfg.m_LevelSubType
  local isChapterUnlock, unlockType, unlockStr = self:IsChapterSubTypeUnlock(levelSubType)
  if isChapterUnlock == false then
    return isChapterUnlock, unlockType, unlockStr
  end
  if self.m_challengeDailyNum - self.m_dailyTimes <= 0 then
    return false, nil, nil, 0
  end
  return self:IsLevelHavePass(unlockLevelID)
end

function LevelEquipmentHelper:GetDunChapterById(id)
  local DunChapterIns = ConfigManager:GetConfigInsByName("DunChapter")
  local chapterInfo = DunChapterIns:GetValue_ByLevelSubType(id)
  if chapterInfo:GetError() then
    log.error("LevelEquipmentHelper GetDunChapterById  id  " .. tostring(id))
    return
  end
  return chapterInfo
end

function LevelEquipmentHelper:GetDunChapterByOrderId(orderId)
  local cfgList = self:GetTodayAllBossCfg()
  if table.getn(cfgList) > 0 then
    for i, v in pairs(cfgList) do
      if v.m_Order == orderId then
        return v
      end
    end
  end
  return nil
end

function LevelEquipmentHelper:GetDunChapterByJumpId(jumpId)
  local DunChapterIns = ConfigManager:GetConfigInsByName("DunChapter")
  local chapterInfoAll = DunChapterIns:GetAll()
  for i, v in pairs(chapterInfoAll) do
    if v.m_Jump == jumpId then
      return v
    end
  end
  log.error("LevelEquipmentHelper GetDunChapterByJumpId  jumpId  " .. tostring(jumpId))
  return nil
end

function LevelEquipmentHelper:GetDunLevelCfgById(levelId)
  local DunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")
  local levelInfo = DunLevelIns:GetValue_ByLevelID(levelId)
  if levelInfo:GetError() then
    log.error("LevelEquipmentHelper GetDunLevelById  id  " .. tostring(levelId))
    return
  end
  return levelInfo
end

function LevelEquipmentHelper:GetDunLevelCfgListByLevelSubType(levelSubType)
  local DunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")
  local DunLevelAllCfg = DunLevelIns:GetAll()
  local cfgList = {}
  for i, v in pairs(DunLevelAllCfg) do
    if v.m_LevelSubType == levelSubType then
      cfgList[#cfgList + 1] = v
    end
  end
  
  local function sortFun(a1, a2)
    return a1.m_Difficulty < a2.m_Difficulty
  end
  
  table.sort(cfgList, sortFun)
  return cfgList
end

function LevelEquipmentHelper:GetDungeonBossResById(id)
  local cfg = self:GetDunChapterById(id)
  if cfg then
    return cfg.m_Point, cfg.m_Model
  end
end

function LevelEquipmentHelper:CheckIsTodayBossByLevelID(levelID)
  local levelCfg = self:GetDunLevelCfgById(levelID)
  if not levelCfg then
    return
  end
  local subLevelType = levelCfg.m_LevelSubType
  local chapterCfg = self:GetDunChapterById(subLevelType)
  local isTrue = self:CheckTodayBossIsTrue(subLevelType)
  if not chapterCfg then
    return
  end
  return isTrue, chapterCfg.m_Order
end

function LevelEquipmentHelper:GetDunLevelDataListByLevelSubType(levelSubType)
  local dataList = {}
  local cfgList = self:GetDunLevelCfgListByLevelSubType(levelSubType)
  for i, v in ipairs(cfgList) do
    dataList[#dataList + 1] = {cfg = v, is_selected = false}
  end
  
  local function sortFun(data1, data2)
    local cfg1 = data1.cfg
    local cfg2 = data2.cfg
    return cfg1.m_LevelID < cfg2.m_LevelID
  end
  
  table.sort(dataList, sortFun)
  return dataList
end

function LevelEquipmentHelper:CheckTodayBossIsTrue(levelSubType)
  local flag = false
  if not levelSubType then
    return flag
  end
  local _, bossChapterIdTab = self:GetLevelDailyData()
  if table.getn(bossChapterIdTab) > 0 and 0 < table.getn(self.m_residentBossIdList) then
    local isHave = table.keyof(bossChapterIdTab, levelSubType)
    if isHave ~= nil then
      return true
    end
    isHave = table.keyof(self.m_residentBossIdList, levelSubType)
    return isHave ~= nil
  end
  return flag
end

function LevelEquipmentHelper:GetResidentBossIdTab()
  local cfgList = {}
  local DunChapterIns = ConfigManager:GetConfigInsByName("DunChapter")
  local chapterInfoAll = DunChapterIns:GetAll()
  for i, v in pairs(chapterInfoAll) do
    if v.m_Rotation == 0 then
      cfgList[v.m_Order] = v.m_LevelSubType
    end
  end
  return cfgList
end

function LevelEquipmentHelper:GetTodayAllBossCfg()
  local cfgList = {}
  local _, bossChapterIdTab = self:GetLevelDailyData()
  local DunChapterIns = ConfigManager:GetConfigInsByName("DunChapter")
  local chapterInfoAll = DunChapterIns:GetAll()
  for i, v in pairs(chapterInfoAll) do
    if v.m_Rotation == 0 then
      cfgList[v.m_Order] = v
    end
  end
  if 0 < table.getn(bossChapterIdTab) then
    for order, levelSubType in pairs(bossChapterIdTab) do
      local cfg = self:GetDunChapterById(levelSubType)
      if cfg and cfg.m_Rotation ~= 0 and cfg.m_Order == order then
        cfgList[order] = cfg
      end
    end
  end
  return cfgList
end

function LevelEquipmentHelper:GetTodayBossResName()
  local posNameList = {}
  local bossNameList = {}
  local animNameList = {}
  local cfgList = self:GetTodayAllBossCfg()
  for i, cfg in pairs(cfgList) do
    posNameList[cfg.m_Order] = cfg.m_Point
    bossNameList[cfg.m_Order] = cfg.m_Model
    animNameList[cfg.m_Order] = cfg.m_Animator
  end
  return posNameList, bossNameList, animNameList
end

function LevelEquipmentHelper:GetDungeonLevelPhaseCfgListByID(levelID)
  if not levelID then
    return
  end
  local tempList
  if self.m_dungeonLevelPhaseListDic[levelID] then
    tempList = self.m_dungeonLevelPhaseListDic[levelID]
  else
    tempList = {}
    local DungeonLevelPhaseIns = ConfigManager:GetConfigInsByName("DungeonLevelPhase")
    local dungeonLevelPhaseDic = DungeonLevelPhaseIns:GetValue_ByLevelID(levelID)
    for _, v in pairs(dungeonLevelPhaseDic) do
      tempList[v.m_Phase] = v
    end
    self.m_dungeonLevelPhaseListDic[levelID] = tempList
  end
  return tempList
end

function LevelEquipmentHelper:GetLevelStageByDamage(levelID, score)
  if not levelID then
    return
  end
  if not score then
    return
  end
  local levelCfg = self:GetDunLevelCfgById(levelID)
  if not levelCfg then
    return
  end
  local mapID = levelCfg.m_MapID
  local maxHpDic = BattleGlobalManager:GetLevelMonstersMaxHP(mapID, true)
  local maxHpCount = maxHpDic.Count
  if maxHpCount <= 0 then
    return
  end
  local maxHp = 0
  for _, tempHp in pairs(maxHpDic) do
    if tempHp > maxHp then
      maxHp = tempHp
    end
  end
  if not maxHp then
    return
  end
  local thousandsRatNum = 0
  if score <= 0 then
    thousandsRatNum = score
  else
    thousandsRatNum = math.floor(score / maxHp * 10000 + 0.5)
  end
  local dungeonLevelPhaseCfgList = self:GetDungeonLevelPhaseCfgListByID(levelID)
  if not dungeonLevelPhaseCfgList then
    return
  end
  local stageNum = 0
  for i, v in ipairs(dungeonLevelPhaseCfgList) do
    if thousandsRatNum >= v.m_DamageLevel then
      stageNum = i
    else
      break
    end
  end
  return stageNum
end

return LevelEquipmentHelper
