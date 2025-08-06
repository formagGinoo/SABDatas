local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local HuntingRaidManager = class("HuntingRaidManager", BaseLevelManager)
HuntingRaidManager.AchieveType = {Damage = 1, Time = 2}
HuntingRaidManager.RankType = {All = 0}

function HuntingRaidManager:OnCreate()
  self.m_haveTakenIds = {}
  self.m_huntingBossData = {}
  self.m_battleResult = {}
  self.m_myRankDataList = {}
  self.m_totalRankDataList = {}
  self.m_chooseEnterStageBossId = nil
end

function HuntingRaidManager:OnInitNetwork()
  RPCS():Listen_Push_Hunting_Boss(handler(self, self.OnPushHuntingBoss), "HuntingRaidManager")
  RPCS():Listen_Push_Hunting_RankUpdate(handler(self, self.OnPushHuntingRankUpdate), "HuntingRaidManager")
end

function HuntingRaidManager:OnInitMustRequestInFetchMore()
end

function HuntingRaidManager:OnAfterInitConfig()
  HuntingRaidManager.FightType_Hunting = MTTDProto.FightType_Hunting
  self.m_huntingRaidEffectMax = tonumber(ConfigManager:GetGlobalSettingsByKey("HuntingRaidEffectMax")) or 0
  self.m_huntingRaidTimeMax = tonumber(ConfigManager:GetGlobalSettingsByKey("HuntingRaidTimeMax")) or 0
  self.m_RanklPercentStr = ConfigManager:GetGlobalSettingsByKey("RanklPercent")
end

function HuntingRaidManager:OnDailyReset()
  self:ReqHuntingRaidGetInitDataCS()
  self:broadcastEvent("eGameEvent_HuntingRaid_DailyRefresh")
end

function HuntingRaidManager:OnPushHuntingBoss(stData, msg)
  if self.m_huntingBossData and self.m_huntingBossData.mBoss then
    local isOld = false
    for i, v in pairs(self.m_huntingBossData.mBoss) do
      if v.iBossId == stData.iBossId then
        if string.compare_numeric_strings(tostring(stData.iCurDamage), tostring(stData.iDamage)) then
          v.iDamage = stData.iCurDamage
        else
          v.iDamage = stData.iDamage
        end
        isOld = true
      end
    end
    if not isOld then
      self.m_huntingBossData.mBoss[stData.iBossId] = stData.stBoss
    end
  end
  self.m_battleResult = stData
end

function HuntingRaidManager:OnPushHuntingRankUpdate(stData, msg)
  if stData.iGroupId and stData.iGroupId ~= 0 then
    self.m_huntingBossData.iRankGroupId = stData.iGroupId
  end
  if stData.iBossId ~= 0 then
    self.m_myRankDataList[stData.iBossId] = {
      iActivityId = stData.iActivityId,
      iBossId = stData.iBossId,
      iNewRank = stData.iNewRank,
      iRankSize = stData.iRankSize
    }
  end
end

function HuntingRaidManager:ReqHuntingRaidGetInitDataCS()
  local openRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Hunting) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen and openRaid and activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_GetData_CS()
    getDataCSMsg.iActivityId = activity:getID()
    RPCS():Hunting_GetData(getDataCSMsg, handler(self, self.OnHuntingRaidGetInitDataSC))
  end
end

function HuntingRaidManager:OnHuntingRaidGetInitDataSC(stData, msg)
  self.m_huntingBossData = stData.stHunting
  self.m_battleResult = {}
  self:SetHaveTakenIds(self.m_huntingBossData.mBoss)
end

function HuntingRaidManager:ReqEnterGameHuntingRaidGetDataCS(iActivityId)
  if not iActivityId then
    return
  end
  local getDataCSMsg = MTTDProto.Cmd_Hunting_GetData_CS()
  getDataCSMsg.iActivityId = iActivityId
  RPCS():Hunting_GetData(getDataCSMsg, handler(self, self.OnEnterGameHuntingRaidGetDataSC))
end

function HuntingRaidManager:OnEnterGameHuntingRaidGetDataSC(stData, msg)
  self.m_huntingBossData = stData.stHunting
  self.m_battleResult = {}
  self:SetHaveTakenIds(self.m_huntingBossData.mBoss)
end

function HuntingRaidManager:ReqHuntingRaidDataCS()
  local openRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Hunting) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen and openRaid and activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_GetData_CS()
    getDataCSMsg.iActivityId = activity:getID()
    RPCS():Hunting_GetData(getDataCSMsg, handler(self, self.OnHuntingRaidDataSC))
  end
end

function HuntingRaidManager:OnHuntingRaidDataSC(stData, msg)
  self.m_huntingBossData = stData.stHunting
  self.m_battleResult = {}
  self:SetHaveTakenIds(self.m_huntingBossData.mBoss)
  StackFlow:Push(UIDefines.ID_FORM_HUNTINGNIGHT)
end

function HuntingRaidManager:ReqHuntingGetMyRankCS(iBossId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_GetMyRank_CS()
    getDataCSMsg.iActivityId = activity:getID()
    getDataCSMsg.iBossId = iBossId
    RPCS():Hunting_GetMyRank(getDataCSMsg, handler(self, self.OnHuntingGetMyRankSC))
  else
    log.error("can not get ActivityType_Hunting !!!")
  end
end

function HuntingRaidManager:OnHuntingGetMyRankSC(stData, msg)
  if stData.iBossId ~= 0 then
    self.m_myRankDataList[stData.iBossId] = stData
  end
  self:broadcastEvent("eGameEvent_HuntingRaid_GetMyRank")
end

function HuntingRaidManager:ReqHuntingGetRankListCS(iBeginRank, iEndRank)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local dataCSMsg = MTTDProto.Cmd_Hunting_GetRankList_CS()
    dataCSMsg.iBeginRank = iBeginRank
    dataCSMsg.iEndRank = iEndRank
    dataCSMsg.iBossId = HuntingRaidManager.RankType.All
    dataCSMsg.iActivityId = activity:getID()
    RPCS():Hunting_GetRankList(dataCSMsg, handler(self, self.OnHuntingGetRankListSC))
  else
    log.error("RankManager can not get ActivityType_Hunting !!!")
  end
end

function HuntingRaidManager:OnHuntingGetRankListSC(stData, msg)
  self.m_totalRankDataList = stData
  self:broadcastEvent("eGameEvent_HuntingRaid_GetTotalRank")
end

function HuntingRaidManager:ReqHuntingRaidGetPlayerRecordCS(stTargetId, iBossId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_GetPlayerRecord_CS()
    getDataCSMsg.iActivityId = activity:getID()
    getDataCSMsg.iBossId = iBossId
    getDataCSMsg.stTargetId = stTargetId
    RPCS():Hunting_GetPlayerRecord(getDataCSMsg, handler(self, self.OnHuntingRaidGetPlayerRecordSC))
  else
    log.error("can not get ActivityType_Hunting !!!")
  end
end

function HuntingRaidManager:OnHuntingRaidGetPlayerRecordSC(stData, msg)
  self:broadcastEvent("eGameEvent_HuntingRaid_GetPlayerRecord", stData)
end

function HuntingRaidManager:ReqHuntingTakeBossRewardCS(iBossId, vTakeReward)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_TakeBossReward_CS()
    getDataCSMsg.iActivityId = activity:getID()
    getDataCSMsg.iBossId = iBossId
    getDataCSMsg.vTakeReward = vTakeReward
    RPCS():Hunting_TakeBossReward(getDataCSMsg, handler(self, self.OnHuntingTakeBossRewardSC))
  else
    log.error("can not get ActivityType_Hunting !!!")
  end
end

function HuntingRaidManager:OnHuntingTakeBossRewardSC(stData, msg)
  if not stData then
    return
  end
  if stData.vItem and next(stData.vItem) then
    utils.popUpRewardUI(stData.vItem)
  end
  self.m_haveTakenIds[stData.iBossId] = stData.vTaken
  if self.m_huntingBossData and self.m_huntingBossData.mBoss then
    for i, v in pairs(self.m_huntingBossData.mBoss) do
      if v.iBossId == stData.iBossId then
        v.vTaken = stData.vTaken
      end
    end
  end
  self:broadcastEvent("eGameEvent_Hunting_TakeBossReward")
end

function HuntingRaidManager:ReqHuntingRaidChooseBuffCS(iBossId, vBuff)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local getDataCSMsg = MTTDProto.Cmd_Hunting_ChooseBuff_CS()
    getDataCSMsg.iActivityId = activity:getID()
    getDataCSMsg.iBossId = iBossId
    getDataCSMsg.vBuff = vBuff
    RPCS():Hunting_ChooseBuff(getDataCSMsg, handler(self, self.OnHuntingChooseBuffSC))
  else
    log.error("can not get ActivityType_Hunting !!!")
  end
end

function HuntingRaidManager:OnHuntingChooseBuffSC(stData, msg)
  if not stData then
    return
  end
  if self.m_huntingBossData and self.m_huntingBossData.mBoss then
    local isHave = false
    for i, v in pairs(self.m_huntingBossData.mBoss) do
      if v.iBossId == stData.iBossId then
        v.vBuff = stData.vBuff
        isHave = true
      end
    end
    if not isHave then
      self.m_huntingBossData.mBoss[stData.iBossId] = {
        iBossId = stData.iBossId,
        vBuff = stData.vBuff
      }
    end
  end
  self:broadcastEvent("eGameEvent_Hunting_ChooseBuff")
end

function HuntingRaidManager:GetTotalRankListData()
  return self.m_totalRankDataList.vRankList
end

function HuntingRaidManager:GetTotalRankOwnerDate()
  return self.m_totalRankDataList
end

function HuntingRaidManager:SetHaveTakenIds(mBoss)
  self.m_haveTakenIds = {}
  for i, v in pairs(mBoss) do
    self.m_haveTakenIds[v.iBossId] = v.vTaken
  end
end

function HuntingRaidManager:CheckHaveReceiveAward()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if not activity then
    return 0
  end
  local bossList = activity:GetHuntingRaidBossList()
  for i, v in pairs(bossList) do
    local list = self:CheckHaveReceiveAwardByBossId(v.iBossId)
    if 0 < table.getn(list) then
      return 1
    end
  end
  return 0
end

function HuntingRaidManager:CheckHaveReceiveAwardByBossId(bossId)
  local canReceiveIds = {}
  local damage = self:GetBossDamageById(bossId)
  if not damage or damage == "0" or damage == 0 then
    return canReceiveIds
  end
  local achieveIns = ConfigManager:GetConfigInsByName("HuntingRaidAchieve")
  local cfgList = achieveIns:GetValue_ByBOSSID(bossId)
  if cfgList then
    for i, v in pairs(cfgList) do
      if not self:CheckAchieveIsTaken(bossId, v.m_Sequence) then
        if v.m_AchieveType == HuntingRaidManager.AchieveType.Damage then
          if string.compare_numeric_strings(damage, v.m_GoalNum) or damage == tostring(v.m_GoalNum) then
            canReceiveIds[#canReceiveIds + 1] = v.m_Sequence
          end
        elseif v.m_AchieveType == HuntingRaidManager.AchieveType.Time then
          damage = damage or 0
          local time = self.m_huntingRaidTimeMax - tonumber(damage)
          if time <= v.m_GoalNum then
            canReceiveIds[#canReceiveIds + 1] = v.m_Sequence
          end
        end
      end
    end
  end
  return canReceiveIds
end

function HuntingRaidManager:GetHuntingRaidRewardByRank(rank, rankCountMax)
  local configInstance = ConfigManager:GetConfigInsByName("HuntingRaidReward")
  local rankAllCfg = configInstance:GetAll()
  for i, v in pairs(rankAllCfg) do
    local minStr = 0
    local maxStr = 0
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      if rank >= minStr and rank <= maxStr then
        return utils.changeCSArrayToLuaTable(v.m_Award)
      end
    elseif rankCountMax ~= 0 and v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 10000
      maxStr = v.m_RankPercent[1] / 10000
      local num = rank / rankCountMax
      if minStr < num and maxStr >= num then
        return utils.changeCSArrayToLuaTable(v.m_Award)
      end
    end
  end
  return {}
end

function HuntingRaidManager:CheckAchieveIsTaken(bossId, sequence)
  if not self.m_haveTakenIds[bossId] then
    return false
  end
  return table.indexof(self.m_haveTakenIds[bossId], sequence)
end

function HuntingRaidManager:GetHuntingMayRankByBossId(bossId)
  return self.m_myRankDataList[bossId]
end

function HuntingRaidManager:GetMyRankGroupId()
  return self.m_huntingBossData.iRankGroupId
end

function HuntingRaidManager:GetBossDamageById(bossId)
  local damage = "0"
  if self.m_huntingBossData and self.m_huntingBossData.mBoss then
    for i, v in pairs(self.m_huntingBossData.mBoss) do
      if v.iBossId == bossId then
        return v.iDamage
      end
    end
  end
  return damage
end

function HuntingRaidManager:GetBossRealDamageById(bossId)
  local damage = self:GetBossDamageById(bossId)
  local realDamage = damage or "0"
  local cfg = self:GetHuntingRaidAchieveById(bossId, 1)
  if cfg and cfg.m_AchieveType == HuntingRaidManager.AchieveType.Time then
    local time = self.m_huntingRaidTimeMax - tonumber(realDamage)
    realDamage = tonumber(realDamage) == 0 and 0 or time / 1000
  end
  return tostring(realDamage)
end

function HuntingRaidManager:GetBossRealDamageByIdAndServerDamage(bossId, serverDamage)
  local realDamage = serverDamage or "0"
  local cfg = self:GetHuntingRaidAchieveById(bossId, 1)
  if cfg and cfg.m_AchieveType == HuntingRaidManager.AchieveType.Time then
    local time = self.m_huntingRaidTimeMax - tonumber(realDamage)
    realDamage = tonumber(realDamage) == 0 and 0 or time / 1000
  end
  return tostring(realDamage)
end

function HuntingRaidManager:CompareDamage(bossId, damage, recordDamage)
  local cfg = self:GetHuntingRaidAchieveById(bossId, 1)
  if cfg and cfg.m_AchieveType == HuntingRaidManager.AchieveType.Time then
    local time = tonumber(damage) - tonumber(recordDamage)
    return 0 < time
  else
    return string.compare_numeric_strings(tostring(damage), tostring(recordDamage))
  end
end

function HuntingRaidManager:GetBossBuffById(bossId)
  local buffList = {}
  if self.m_huntingBossData and self.m_huntingBossData.mBoss then
    for i, v in pairs(self.m_huntingBossData.mBoss) do
      if v.iBossId == bossId then
        return v.vBuff
      end
    end
  end
  return buffList
end

function HuntingRaidManager:GetShowHeroSpineId()
  local dataTab = {}
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if not activity then
    return dataTab
  end
  local bossList = activity:GetHuntingRaidBossList()
  for i, v in ipairs(bossList) do
    local cfg = self:GetHuntingRaidBossCfgById(v.iBossId) or {}
    dataTab[#dataTab + 1] = {
      heroId = cfg.m_HeroID,
      iBossId = v.iBossId
    }
  end
  return dataTab
end

function HuntingRaidManager:GetHuntingRaidRankStrAndPointsByRank(rank, rankCountMax)
  if rank == nil or rankCountMax == nil then
    log.error("GetHuntingRaidRankStrAndPointsByRank rankCountMax or rank == nil")
    return 0
  end
  if rank == 0 then
    return 0
  end
  local configInstance = ConfigManager:GetConfigInsByName("HuntingRaidRank")
  local rankAllCfg = configInstance:GetAll()
  local rankStr = ""
  local point = 0
  for i, v in pairs(rankAllCfg) do
    local minStr = 0
    local maxStr = 0
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      if rank >= minStr and rank <= maxStr then
        rankStr = rank
        point = v.m_Points
        return rankStr, point
      end
    elseif rankCountMax ~= 0 and v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 10000
      maxStr = v.m_RankPercent[1] / 10000
      local num = rank / rankCountMax
      if minStr <= num and maxStr >= num then
        local tempNum = math.floor(rank * 10000 / rankCountMax) / 100
        rankStr = string.format(ConfigManager:GetCommonTextById(100009), tempNum)
        point = v.m_Points
        return rankStr, point
      end
    end
  end
  return rankStr, point
end

function HuntingRaidManager:GetHuntingRaidBossCfgById(id)
  local ChapterIns = ConfigManager:GetConfigInsByName("HuntingRaidBoss")
  local chapterInfo = ChapterIns:GetValue_ByBOSSID(id)
  if chapterInfo:GetError() then
    log.error("HuntingRaidManager GetHuntingRaidBossCfgById  id  " .. tostring(id))
    return
  end
  return chapterInfo
end

function HuntingRaidManager:GetHuntingRaidLevelCfgById(levelId)
  local LevelIns = ConfigManager:GetConfigInsByName("HuntingRaidLevel")
  local levelInfo = LevelIns:GetValue_ByLevelID(levelId)
  if levelInfo:GetError() then
    log.error("HuntingRaidManager GetHuntingRaidLevelCfgById  id  " .. tostring(levelId))
    return
  end
  return levelInfo
end

function HuntingRaidManager:GetHuntingRaidAchieveById(bossId, sequence)
  local AchieveIns = ConfigManager:GetConfigInsByName("HuntingRaidAchieve")
  local cfg = AchieveIns:GetValue_ByBOSSIDAndSequence(bossId, sequence)
  if cfg:GetError() then
    log.error("HuntingRaidManager GetHuntingRaidAchieveById  bossId  sequence " .. tostring(bossId))
    return
  end
  return cfg
end

function HuntingRaidManager:GetBattleGlobalEffectCfgById(id)
  local BattleGlobalEffectIns = ConfigManager:GetConfigInsByName("BattleGlobalEffect")
  local cfg = BattleGlobalEffectIns:GetValue_ByID(id)
  if cfg:GetError() then
    log.error("HuntingRaidManager GetBattleGlobalEffectCfgById  id  " .. tostring(id))
    return
  end
  return cfg
end

function HuntingRaidManager:GetSkillEffectDesByEffectId(id)
  local desStr = ""
  local cfg = self:GetBattleGlobalEffectCfgById(id)
  if cfg then
    desStr = HeroManager:GetSkillDescribeByParam(cfg.m_mDesc, cfg.m_Param)
  end
  return desStr
end

function HuntingRaidManager:GetHuntingLevelCfgListByBossId(bossId)
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

function HuntingRaidManager:OpenHuntingRaidUI()
  local openRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Hunting) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  local formStr = "Form_Hall"
  if isOpen then
    if openRaid and activity then
      if not self.m_huntingBossData or activity:getID() ~= self.m_huntingBossData.iActivityId then
        self:ReqHuntingRaidDataCS()
        log.warn("ActivityId is change !!!")
      else
        formStr = "Form_HuntingNight"
        StackFlow:Push(UIDefines.ID_FORM_HUNTINGNIGHT)
      end
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13010)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
  return formStr
end

function HuntingRaidManager:GetFightSubTypeByLevelId(levelId)
  local levelSubType
  local cfg = self:GetHuntingRaidLevelCfgById(levelId)
  if cfg then
    levelSubType = cfg.m_FightSubType
  end
  return levelSubType
end

function HuntingRaidManager:SetEnterStageBossId(bossId)
  self.m_chooseEnterStageBossId = bossId
end

function HuntingRaidManager:GetEnterStageBossId()
  return self.m_chooseEnterStageBossId
end

function HuntingRaidManager:StartEnterBattle(levelType, levelID, bossId)
  levelType = levelType or HuntingRaidManager.FightType_Hunting
  self.m_battleError = nil
  self.m_battleResult = {}
  self.m_battleLevelId = levelID
  self:BeforeEnterBattle(levelType, levelID, bossId)
  local mapID = self:GetLevelMapID(levelType, levelID)
  self:EnterPVEBattle(mapID)
end

function HuntingRaidManager:BeforeEnterBattle(levelType, levelID, bossId)
  local m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local levelSubType = self:GetFightSubTypeByLevelId(levelID)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = levelSubType or 0,
    levelID = levelID,
    heroList = HeroManager:GetHeroServerList(),
    buffList = self:GetBossBuffById(bossId),
    activeId = m_activity:getID(),
    bossId = bossId,
    damageRecord = self:GetBossRealDamageById(bossId)
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function HuntingRaidManager:GetLevelMapID(levelType, levelID)
  local LevelIns = ConfigManager:GetConfigInsByName("HuntingRaidLevel")
  local cfg = LevelIns:GetValue_ByLevelID(levelID)
  if cfg:GetError() then
    log.error("HuntingRaidManager GetLevelMapID  id  " .. tostring(levelID))
    return
  end
  return cfg.m_MapID
end

function HuntingRaidManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID, fightingMonster)
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
    StackFlow:Push(UIDefines.ID_FORM_HUNTINGNIGHTVICTORY, {
      levelType = levelType,
      levelID = levelID,
      showHeroID = randomShowHeroID,
      battleResult = self.m_battleResult
    })
  end
end

function HuntingRaidManager:OnBackLobby(fCB)
  local formStr
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      formStr = "Form_Hall"
      if self.m_battleError == 0 or not self.m_battleError then
        formStr = self:OpenHuntingRaidUI()
      else
        local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
        if isOpen then
          self:ReqHuntingRaidGetInitDataCS()
        else
          StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
        end
      end
      if formStr == "Form_Hall" then
        StackFlow:Push(UIDefines.ID_FORM_HALL)
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end, true)
end

function HuntingRaidManager:EnterNextBattle(levelType, ...)
end

function HuntingRaidManager:FromBattleToHall()
  self:ExitBattle()
end

function HuntingRaidManager:GetAssignLevelParams(levelType, levelId)
  local levelSubType
  if levelId then
    levelSubType = self:GetFightSubTypeByLevelId(levelId)
  else
    levelSubType = self:GetFightSubTypeByLevelId(self.m_battleLevelId)
  end
  return {
    HuntingRaidManager.FightType_Hunting,
    levelSubType,
    0,
    0
  }
end

function HuntingRaidManager:IsHaveRedDot()
  local openRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Hunting) ~= nil
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen and openRaid and activity then
    local redDot = self:CheckDailyRedPoint()
    if 0 < redDot then
      return redDot
    end
    return self:CheckHaveReceiveAward()
  end
  return 0
end

function HuntingRaidManager:CheckDailyRedPoint()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if not openFlag or TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Red_Point_HuntingRaid", 0) then
    return 0
  end
  return 1
end

function HuntingRaidManager:SetDailyRedPointFlag()
  LocalDataManager:SetIntSimple("Red_Point_HuntingRaid", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
end

return HuntingRaidManager
