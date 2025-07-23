local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local PersonalRaidManager = class("PersonalRaidManager", BaseLevelManager)

function PersonalRaidManager:OnCreate()
  self.m_normalDailyTimes = 0
  self.m_challengeDailyTimes = 0
  self.m_curBossId = 1
  self.m_allPassChapterStagesIds = {}
  self.m_dailyChallengePassIds = {}
  self.m_stSoloRaid = {}
  self.m_selLevelId = 0
  self.m_battleReward = {}
  self.m_nextNewStageCfg = nil
  self.m_rankUpData = nil
  self.m_curBattleTimes = 0
  self:addEventListener("eGameEvent_SoloRaid_DailyRefreshGetData", handler(self, self.OnDailyRefreshGetData))
end

function PersonalRaidManager:OnInitNetwork()
  RPCS():Listen_Push_SoloRaid_FinishRaid(handler(self, self.OnPushSoloRaidFinishRaid), "PersonalRaidManager")
  RPCS():Listen_Push_SoloRaid_CurRaid(handler(self, self.OnPushSoloRaidCurRaid), "PersonalRaidManager")
  RPCS():Listen_Push_SoloRaid_RankUpdate(handler(self, self.OnPushSoloRaidRankUpdate), "PersonalRaidManager")
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnGetActiveListCB))
end

function PersonalRaidManager:OnAfterInitConfig()
  self:InitGlobalCfg()
end

function PersonalRaidManager:OnGetActiveListCB()
  local openSoloRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_SoloRaid) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen and openSoloRaid and activity and activity.GetPersonalRaidBattleEndTime then
    local endTime = activity:GetPersonalRaidBattleEndTime()
    if endTime - TimeUtil:GetServerTimeS() > 0 then
      self:ReqSoloRaidLoginGetDataCS()
    end
  end
end

function PersonalRaidManager:OnDailyReset()
  self.m_allPassChapterStagesIds = {}
  self.m_dailyChallengePassIds = {}
  self:broadcastEvent("eGameEvent_SoloRaid_DailyRefresh")
end

function PersonalRaidManager:OnPushSoloRaidFinishRaid(data, msg)
  if data.bFirstPass and self.m_stSoloRaid and self.m_stSoloRaid.stCurRaid then
    local cfg = self:CheckIsLastStage(self.m_stSoloRaid.stCurRaid.iRaidId)
    if cfg then
      self.m_nextNewStageCfg = cfg
    end
  else
    self.m_nextNewStageCfg = nil
  end
  self.m_stSoloRaid = data.stSoloRaid
  if data.bPass then
    for i, v in pairs(self.m_stSoloRaid.vPassRaid) do
      self.m_allPassChapterStagesIds[v] = 1
    end
    for i, v in pairs(self.m_stSoloRaid.vDailyPassRaid) do
      self.m_dailyChallengePassIds[v] = 1
    end
  end
  self.m_normalDailyTimes = data.iNormalTimes
  self.m_challengeDailyTimes = data.iHardTimes
  self.m_battleReward = data.vReward
end

function PersonalRaidManager:OnPushSoloRaidCurRaid(data, msg)
  self.m_stSoloRaid.stCurRaid = data.stCurRaid
end

function PersonalRaidManager:OnPushSoloRaidRankUpdate(data, msg)
  self.m_rankUpData = data
end

function PersonalRaidManager:SetCurBattleTimes(times)
  self.m_curBattleTimes = times
end

function PersonalRaidManager:GetCurBattleTimes()
  return self.m_curBattleTimes
end

function PersonalRaidManager:InitGlobalCfg()
  PersonalRaidManager.FightType_SoloRaid = MTTDProto.FightType_SoloRaid
  PersonalRaidManager.SoloRaidSubType_Fight = MTTDProto.SoloRaidSubType_Fight
  PersonalRaidManager.SoloRaidMode = {SoloRaidMode_Normal = 1, SoloRaidMode_Hard = 2}
  self.m_normalChallengeDailyCfgNum = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidNormalTimes"))
  self.m_challengeDailyCfgNum = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidChallengeTimes"))
  self.m_challengeCfgTimes = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidBattleTimes"))
end

function PersonalRaidManager:ReqSoloRaidGetDataCS()
  local stageGetListCSMsg = MTTDProto.Cmd_SoloRaid_GetData_CS()
  RPCS():SoloRaid_GetData(stageGetListCSMsg, handler(self, self.OnSoloRaidGetDataSC))
end

function PersonalRaidManager:OnSoloRaidGetDataSC(stStageData, msg)
  self.m_stSoloRaid = stStageData.stSoloRaid
  self.m_normalDailyTimes = stStageData.iNormalTimes
  self.m_challengeDailyTimes = stStageData.iHardTimes
  self.m_allPassChapterStagesIds = {}
  self.m_dailyChallengePassIds = {}
  self.m_curBossId = self.m_stSoloRaid.iBossId
  for i, v in pairs(self.m_stSoloRaid.vPassRaid) do
    self.m_allPassChapterStagesIds[v] = 1
  end
  for i, v in pairs(self.m_stSoloRaid.vDailyPassRaid) do
    self.m_dailyChallengePassIds[v] = 1
  end
  self:broadcastEvent("eGameEvent_SoloRaid_GetData")
end

function PersonalRaidManager:ReqDailyRefreshSoloRaidGetDataCS()
  local stageGetListCSMsg = MTTDProto.Cmd_SoloRaid_GetData_CS()
  RPCS():SoloRaid_GetData(stageGetListCSMsg, handler(self, self.OnDailyRefreshSoloRaidGetDataSC))
end

function PersonalRaidManager:OnDailyRefreshSoloRaidGetDataSC(stStageData, msg)
  self.m_stSoloRaid = stStageData.stSoloRaid
  self.m_normalDailyTimes = stStageData.iNormalTimes
  self.m_challengeDailyTimes = stStageData.iHardTimes
  self.m_allPassChapterStagesIds = {}
  self.m_dailyChallengePassIds = {}
  for i, v in pairs(self.m_stSoloRaid.vPassRaid) do
    self.m_allPassChapterStagesIds[v] = 1
  end
  for i, v in pairs(self.m_stSoloRaid.vDailyPassRaid) do
    self.m_dailyChallengePassIds[v] = 1
  end
  self:broadcastEvent("eGameEvent_SoloRaid_DailyRefreshGetData")
end

function PersonalRaidManager:ReqSoloRaidLoginGetDataCS()
  local stageGetListCSMsg = MTTDProto.Cmd_SoloRaid_GetData_CS()
  RPCS():SoloRaid_GetData(stageGetListCSMsg, handler(self, self.OnSoloRaidLoginGetDataSC))
end

function PersonalRaidManager:OnSoloRaidLoginGetDataSC(stStageData, msg)
  self.m_stSoloRaid = stStageData.stSoloRaid
  self.m_normalDailyTimes = stStageData.iNormalTimes
  self.m_challengeDailyTimes = stStageData.iHardTimes
  self.m_allPassChapterStagesIds = {}
  self.m_dailyChallengePassIds = {}
  self.m_curBossId = self.m_stSoloRaid.iBossId
  for i, v in pairs(self.m_stSoloRaid.vPassRaid) do
    self.m_allPassChapterStagesIds[v] = 1
  end
  for i, v in pairs(self.m_stSoloRaid.vDailyPassRaid) do
    self.m_dailyChallengePassIds[v] = 1
  end
end

function PersonalRaidManager:ReqSoloRaidChooseRaidCS(iRaidId)
  local stageGetListCSMsg = MTTDProto.Cmd_SoloRaid_ChooseRaid_CS()
  stageGetListCSMsg.iRaidId = iRaidId
  RPCS():SoloRaid_ChooseRaid(stageGetListCSMsg, handler(self, self.OnSoloRaidChooseRaidSC))
end

function PersonalRaidManager:OnSoloRaidChooseRaidSC(stStageData, msg)
  self.m_stSoloRaid.stCurRaid = stStageData.stCurRaid
  self:ResetNewStageAndDamage()
  self:broadcastEvent("eGameEvent_SoloRaid_ChooseRaid")
end

function PersonalRaidManager:ReqSoloRaidMopUpCS(iRaidId)
  local stageGetListCSMsg = MTTDProto.Cmd_SoloRaid_MopUp_CS()
  stageGetListCSMsg.iRaidId = iRaidId
  RPCS():SoloRaid_MopUp(stageGetListCSMsg, handler(self, self.OnSoloRaidMopUpSC))
end

function PersonalRaidManager:OnSoloRaidMopUpSC(stData, msg)
  if self:CheckLevelModeById(stData.iRaidId) == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal then
    self.m_normalDailyTimes = stData.iFightTimes
  elseif self:CheckLevelModeById(stData.iRaidId) == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard then
    self.m_challengeDailyTimes = stData.iFightTimes
  end
  local vReward = stData.vReward
  if vReward and next(vReward) then
    utils.popUpRewardUI(vReward)
  end
  self:broadcastEvent("eGameEvent_SoloRaid_RefreshRaidData")
end

function PersonalRaidManager:ReqSoloRaidResetCS(iRaidId)
  local dataCSMsg = MTTDProto.Cmd_SoloRaid_Reset_CS()
  dataCSMsg.iRaidId = iRaidId
  RPCS():SoloRaid_Reset(dataCSMsg, handler(self, self.OnSoloRaidResetSC))
end

function PersonalRaidManager:OnSoloRaidResetSC(stStageData, msg)
  self.m_stSoloRaid.stCurRaid = stStageData.stCurRaid
  self:broadcastEvent("eGameEvent_SoloRaid_Reset")
end

function PersonalRaidManager:ReqSoloRaidPlayerRecordCS(stTargetId)
  local Msg = MTTDProto.Cmd_SoloRaid_GetPlayerRecord_CS()
  Msg.stTargetId = stTargetId
  RPCS():SoloRaid_GetPlayerRecord(Msg, handler(self, self.OnSoloRaidGetPlayerRecordSC))
end

function PersonalRaidManager:OnSoloRaidGetPlayerRecordSC(data)
  self:broadcastEvent("eGameEvent_SoloRaid_GetPlayerRecord", data)
end

function PersonalRaidManager:ReqSoloRaidGetMyRankCS()
  local Msg = MTTDProto.Cmd_SoloRaid_GetMyRank_CS()
  RPCS():SoloRaid_GetMyRank(Msg, handler(self, self.OnSoloRaidGetMyRankSC))
end

function PersonalRaidManager:OnSoloRaidGetMyRankSC(data)
  self:broadcastEvent("eGameEvent_SoloRaid_GetMyRank", data)
end

function PersonalRaidManager:GetChallengeDailyNum()
  return self.m_challengeDailyTimes
end

function PersonalRaidManager:GetNormalDailyNum()
  return self.m_normalDailyTimes
end

function PersonalRaidManager:GetOnceBattleTimes()
  return self.m_challengeCfgTimes
end

function PersonalRaidManager:GetCurStageBattleNum()
  local m_stSoloRaid = self:GetPersonalRaidData()
  return table.getn(m_stSoloRaid.stCurRaid.vUseHero)
end

function PersonalRaidManager:GetBossId()
  return self.m_curBossId
end

function PersonalRaidManager:GetPersonalRaidData()
  return self.m_stSoloRaid
end

function PersonalRaidManager:GetCurRaidData()
  return self.m_stSoloRaid.stCurRaid
end

function PersonalRaidManager:GetSoloRaidmUseHero()
  local temp = {}
  local vUseHero = self.m_stSoloRaid.stCurRaid.vUseHero
  if vUseHero then
    for _, v in ipairs(vUseHero) do
      for _, vv in ipairs(v) do
        temp[vv] = vv
      end
    end
  end
  return temp
end

function PersonalRaidManager:GetCurRaidId()
  return self.m_stSoloRaid.stCurRaid.iRaidId
end

function PersonalRaidManager:IsLevelHavePass(stageId)
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

function PersonalRaidManager:IsLevelDailyHavePass(stageId)
  local passTime = 0
  if stageId then
    if stageId == 0 then
      return true
    end
    passTime = self.m_dailyChallengePassIds[stageId]
    if self.m_dailyChallengePassIds[stageId] and self.m_dailyChallengePassIds[stageId] ~= 0 then
      return true, passTime
    end
  end
  return false, passTime
end

function PersonalRaidManager:IsHaveRedDot()
  local openSoloRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_SoloRaid) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen and openSoloRaid and activity and activity.GetPersonalRaidBattleEndTime then
    local endTime = activity:GetPersonalRaidBattleEndTime()
    if endTime - TimeUtil:GetServerTimeS() > 0 then
      return self.m_normalChallengeDailyCfgNum - self.m_normalDailyTimes
    end
  end
  return 0
end

function PersonalRaidManager:IsPersonalRaidOpen()
  local openSoloRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_SoloRaid) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen and openSoloRaid and activity and activity.GetPersonalRaidBattleEndTime then
    local endTime = activity:GetPersonalRaidBattleEndTime() or 0
    if 0 < endTime - TimeUtil:GetServerTimeS() then
      return true
    end
  end
  return false
end

function PersonalRaidManager:GetNormalStageChallengeCfgNum()
  return self.m_normalChallengeDailyCfgNum
end

function PersonalRaidManager:GetHardStageChallengeCfgNum()
  return self.m_challengeDailyCfgNum
end

function PersonalRaidManager:CheckLevelModeById(levelId)
  local cfg = self:GetSoloRaidLevelCfgById(levelId)
  if cfg then
    return cfg.m_LevelMode
  end
end

function PersonalRaidManager:FreshPassStageInfo(stPushPassStage)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  if levelType ~= PersonalRaidManager.FightType_SoloRaid then
    return
  end
  self.m_allPassChapterStagesIds[stPushPassStage.iStageId] = 1
end

function PersonalRaidManager:IsLevelUnLock(levelID)
  local LevelIns = ConfigManager:GetConfigInsByName("SoloRaidLevel")
  local levelCfg = LevelIns:GetValue_ByLevelID(levelID)
  local unlockLevelID = levelCfg.m_LevelUnlock
  local levelSubType = levelCfg.m_LevelSubType
  if levelSubType == LevelManager.PersonalRaidSubType.Normal and self.m_normalChallengeDailyCfgNum - self.m_normalDailyTimes <= 0 then
    return false, 0
  elseif levelSubType == LevelManager.PersonalRaidSubType.Challenge and 0 >= self.m_challengeDailyCfgNum - self.m_challengeDailyTimes then
    return false, 0
  end
  return self:IsLevelHavePass(unlockLevelID)
end

function PersonalRaidManager:CheckRaidModeIsOpenBySubType(levelSubType)
  local cfgList = self:GetSoloRaidLevelCfgListByBossId(self:GetBossId())
  for i, v in ipairs(cfgList) do
    if v.m_LevelSubType == levelSubType then
      return self:IsLevelHavePass(v.m_LevelUnlock)
    end
  end
  return false, 0
end

function PersonalRaidManager:GetSoloRaidBossCfgById(id)
  local ChapterIns = ConfigManager:GetConfigInsByName("SoloRaidBoss")
  local chapterInfo = ChapterIns:GetValue_ByBOSSID(id)
  if chapterInfo:GetError() then
    log.error("PersonalRaidManager GetSoloRaidBossCfgById  id  " .. tostring(id))
    return
  end
  return chapterInfo
end

function PersonalRaidManager:GetSoloRaidLevelCfgById(levelId)
  local LevelIns = ConfigManager:GetConfigInsByName("SoloRaidLevel")
  local levelInfo = LevelIns:GetValue_ByLevelID(levelId)
  if levelInfo:GetError() then
    log.error("PersonalRaidManager GetSoloRaidLevelCfgById  id  " .. tostring(levelId))
    return
  end
  return levelInfo
end

function PersonalRaidManager:GetSoloRaidLevelCfgListByBossId(bossId)
  local LevelIns = ConfigManager:GetConfigInsByName("SoloRaidLevel")
  local LevelAllCfg = LevelIns:GetAll()
  local cfgList = {}
  for i, v in pairs(LevelAllCfg) do
    if v.m_BOSSID == bossId then
      cfgList[#cfgList + 1] = v
    end
  end
  
  local function sortFun(a1, a2)
    return a1.m_Sort < a2.m_Sort
  end
  
  table.sort(cfgList, sortFun)
  return cfgList
end

function PersonalRaidManager:GetBossHp(fightingMonster, iRaidId)
  local data = self:GetPersonalRaidData()
  local curHpTab = {}
  local curHp = 0
  local maxHp = 0
  if data then
    iRaidId = iRaidId or data.stCurRaid.iRaidId
    local cfg = self:GetSoloRaidLevelCfgById(iRaidId)
    local fightData = fightingMonster or data.stCurRaid.mFightingMonster
    local mainTargetIDList = utils.changeCSArrayToLuaTable(cfg.m_MainTargetID)
    local maxHpTab = self:GetBossMaxHp(iRaidId)
    for i, v in pairs(fightData) do
      for m, n in pairs(mainTargetIDList) do
        if v.iID == n then
          curHpTab[v.iID] = v.iHp
        end
      end
    end
    for heroId, v in pairs(maxHpTab) do
      if not curHpTab[heroId] then
        curHpTab[heroId] = v
      end
    end
    for i, v in pairs(curHpTab) do
      curHp = curHp + v
    end
    for i, v in pairs(maxHpTab) do
      maxHp = maxHp + v
    end
  end
  return curHp, maxHp
end

function PersonalRaidManager:GetBossMaxHp(iRaidId)
  local maxHp = {}
  if iRaidId then
    local cfg = self:GetSoloRaidLevelCfgById(iRaidId)
    local mainTargetIDList = utils.changeCSArrayToLuaTable(cfg.m_MainTargetID)
    local attrList = CS.BattleGlobalManager.Instance:GetLevelMonstersMaxHP(cfg.m_MapID)
    for i, v in pairs(attrList) do
      for m, n in pairs(mainTargetIDList) do
        if n == i then
          maxHp[n] = v
        end
      end
    end
  end
  return maxHp
end

function PersonalRaidManager:CheckIsLastStage(levelId)
  local newStageCfg
  local cfg = self:GetSoloRaidLevelCfgById(levelId)
  if cfg then
    local cfgList = self:GetSoloRaidLevelCfgListByBossId(cfg.m_BOSSID)
    local lastCfg = cfgList[#cfgList]
    if lastCfg.m_Sort > cfg.m_Sort then
      newStageCfg = cfgList[cfg.m_Sort + 1]
    end
  end
  return newStageCfg
end

function PersonalRaidManager:OpenPersonalRaidUI()
  local openSoloRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_SoloRaid) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen then
    if openSoloRaid and activity and activity.GetPersonalRaidBattleEndTime then
      local data = self:GetCurRaidData()
      local endTime = activity:GetPersonalRaidBattleEndTime()
      if data and data.iRaidId == 0 or 0 >= endTime - TimeUtil:GetServerTimeS() then
        StackFlow:Push(UIDefines.ID_FORM_PERSONALRAIDMAIN)
        local newStageCfg = self.m_nextNewStageCfg
        local rankData = self.m_rankUpData
        if rankData then
          StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDSCOUTCOMPLETED, {newStageCfg = newStageCfg, rankData = rankData})
        end
        if not rankData and newStageCfg then
          log.error("OpenPersonalRaidUI error  rankData == nil ")
        end
      elseif 0 >= self.m_normalChallengeDailyCfgNum - self.m_normalDailyTimes then
        StackFlow:Push(UIDefines.ID_FORM_PERSONALRAIDBOSS)
        local rankData = self.m_rankUpData
        if rankData then
          StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDSCOUTCOMPLETED, {rankData = rankData})
        end
      else
        StackFlow:Push(UIDefines.ID_FORM_PERSONALRAIDBOSS)
      end
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13010)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
  self:ResetNewStageAndDamage()
end

function PersonalRaidManager:ResetNewStageAndDamage()
  self.m_nextNewStageCfg = nil
  self.m_rankUpData = nil
end

function PersonalRaidManager:GetRankNameByRankAndTotal(rank, total)
  if not rank or rank == 0 then
    return ConfigManager:GetCommonTextById(100308)
  end
  if not self.m_maxRankNum then
    self.m_maxRankNum = self:GetMaxRankNum()
  end
  if rank <= self.m_maxRankNum then
    return rank
  end
  if not total or total == 0 then
    return ConfigManager:GetCommonTextById(100308)
  end
  local num = math.floor(rank * 10000 / total) / 100
  return string.gsubNumberReplace(ConfigManager:GetCommonTextById(100307), tostring(num))
end

function PersonalRaidManager:GetMaxRankNum()
  local configInstance = ConfigManager:GetConfigInsByName("SoloRaidReward")
  local pvpRankAll = configInstance:GetAll()
  local maxRank = 0
  for i, v in pairs(pvpRankAll) do
    if v.m_Rank and 0 < v.m_Rank.Length then
      if v.m_Rank[0] and maxRank < v.m_Rank[0] then
        maxRank = v.m_Rank[0]
      end
      if v.m_Rank[1] and maxRank < v.m_Rank[1] then
        maxRank = v.m_Rank[1]
      end
    end
  end
  return maxRank
end

function PersonalRaidManager:OnDailyRefreshGetData()
  self:OpenPersonalRaidUI()
end

function PersonalRaidManager:StartEnterBattle(levelType, levelID)
  if not levelType then
    levelType = PersonalRaidManager.FightType_SoloRaid
    return
  end
  self:BeforeEnterBattle(levelType, levelID)
  local mapID = self:GetLevelMapID(levelType, levelID)
  self:EnterPVEBattle(mapID)
end

function PersonalRaidManager:EnterBattleBefore(simFlag)
  local raidData = self:GetCurRaidData()
  local vUseHero = {}
  if raidData.vUseHero and table.getn(raidData.vUseHero) > 0 then
    for i, v in pairs(raidData.vUseHero) do
      for m, n in pairs(v) do
        vUseHero[#vUseHero + 1] = n
      end
    end
  end
  if simFlag == nil then
    simFlag = false
  end
  self.m_simFlag = simFlag
  local data = {
    vUseHero = vUseHero,
    mFightingMonster = raidData.mFightingMonster,
    mapId = raidData.iRaidId,
    simFlag = simFlag
  }
  BattlePersonalRaidManager:EnterBattleBefore(data)
end

function PersonalRaidManager:BeforeEnterBattle(levelType, levelID)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = PersonalRaidManager.SoloRaidSubType_Fight or 0,
    levelID = levelID,
    heroList = HeroManager:GetHeroServerList()
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function PersonalRaidManager:GetLevelMapID(levelType, levelID)
  local levelCfg = ConfigManager:GetConfigInsByName("SoloRaidLevel")
  local cfg = levelCfg:GetValue_ByLevelID(levelID)
  if cfg:GetError() then
    log.error("PersonalRaidManager GetLevelMapID  id  " .. tostring(levelID))
    return
  end
  return cfg.m_MapID
end

function PersonalRaidManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID, fightingMonster)
  self.m_battleError = 0
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    self.m_battleError = finishErrorCode
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    stageFinishChallengeSc = stageFinishChallengeSc or {}
    local levelType = stageFinishChallengeSc.iFightType
    local levelID = stageFinishChallengeSc.iStageId
    local mFightingMonster = stageFinishChallengeSc.mFightingMonster
    local iScore = stageFinishChallengeSc.iScore
    local reward = table.deepcopy(self.m_battleReward)
    StackFlow:Push(UIDefines.ID_FORM_PERSONALRAIDMAIN_BATTLERESULT, {
      levelType = levelType,
      levelID = levelID,
      rewardData = reward,
      showHeroID = randomShowHeroID,
      fightingMonster = mFightingMonster,
      iScore = iScore,
      simFlag = self.m_simFlag
    })
    self.m_battleReward = {}
  end
end

function PersonalRaidManager:OnBackLobby(fCB)
  local formStr
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      formStr = "Form_Hall"
      StackFlow:Push(UIDefines.ID_FORM_HALL)
      if self.m_battleError == 0 then
        self:OpenPersonalRaidUI()
      else
        local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
        if isOpen then
          self:ReqDailyRefreshSoloRaidGetDataCS()
        else
          StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
        end
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end, true)
end

function PersonalRaidManager:EnterNextBattle(levelType, ...)
end

function PersonalRaidManager:FromBattleToHall()
  self:ExitBattle()
end

function PersonalRaidManager:GetAssignLevelParams()
  return {
    PersonalRaidManager.FightType_SoloRaid,
    PersonalRaidManager.SoloRaidSubType_Fight,
    0,
    0
  }
end

return PersonalRaidManager
