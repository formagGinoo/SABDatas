local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local PvpReplaceManager = class("PvpReplaceManager", BaseLevelManager)
PvpReplaceManager.BattleTeamNum = 3
local tonumber = _ENV.tonumber
local math_floor = math.floor
local TimeTriggerLimitTimes = 20

function PvpReplaceManager:OnCreate()
  self.m_timerTriggerTimes = 0
  self.m_curSeasonID = nil
  self.m_arenaMineInfo = {}
  self.m_arenaEnemyDic = {}
  self.m_curArenaEnemyDetail = {}
  self.m_curBattleType = nil
  self.m_curBattleSubType = nil
  self.m_curEnemyIndex = nil
  self.m_cfgSeasonStartTimer = nil
  self.m_cfgPVPNewCompeteTime = nil
  self.m_cfgPVPNewSettleTime = nil
  self.m_allReplaceArenaRewardCfg = nil
  self.m_resultData = nil
  self.m_replaceArenaAfk = nil
  self.m_afkTimer = nil
  self:AddEventListener()
end

function PvpReplaceManager:OnInitNetwork()
  RPCS():Listen_Push_ReplaceArena_BattleEndUpdate(handler(self, self.OnPushReplaceArenaBattleEndInfo), "PvpReplaceManager")
  RPCS():Listen_Push_ReplaceArena_RankChange(handler(self, self.OnPushReplaceArenaRankChange), "PvpReplaceManager")
end

function PvpReplaceManager:OnAfterFreshData()
  self:InitGlobalCfg()
  self:CheckReqSeasonInit()
end

function PvpReplaceManager:OnDailyReset()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if not openFlag then
    return
  end
  if self.m_curSeasonID then
    self:ReqReplaceArenaGetInit()
  elseif self:IsInSeasonGameTime() == true then
    self:ReqReplaceArenaGetInit()
  end
end

function PvpReplaceManager:OnUpdate(dt)
end

function PvpReplaceManager:ClearCacheMineSeasonInfo()
  self.m_timerTriggerTimes = 0
  self.m_curSeasonID = nil
  self.m_arenaMineInfo = {}
  if self.m_seasonTimer then
    TimeService:KillTimer(self.m_seasonTimer)
    self.m_seasonTimer = nil
  end
end

function PvpReplaceManager:AddEventListener()
end

function PvpReplaceManager:OnPushReplaceArenaBattleEndInfo(stPushReplaceArenaInfo, msg)
  if not stPushReplaceArenaInfo then
    return
  end
  if self.m_arenaMineInfo and stPushReplaceArenaInfo.iRank ~= 0 then
    self.m_arenaMineInfo.iGradeRank = stPushReplaceArenaInfo.iRank
    self.m_arenaMineInfo.iFreeFightTimes = stPushReplaceArenaInfo.iFreeFightTimes
    if self.m_arenaMineInfo.iReplaceArenaPlaySeason == nil or self.m_arenaMineInfo.iReplaceArenaPlaySeason == 0 then
      self:ReqReplaceArenaSeeAfk()
    end
    self.m_arenaMineInfo.iReplaceArenaPlaySeason = stPushReplaceArenaInfo.iReplaceArenaPlaySeason
  end
  if stPushReplaceArenaInfo.stAfk and stPushReplaceArenaInfo.stAfk.iLastCalcTime ~= 0 and stPushReplaceArenaInfo.stAfk.iTakeRewardTime ~= 0 then
    self:FreshArenaAFKInfo(stPushReplaceArenaInfo.stAfk)
  end
  self.m_resultData = stPushReplaceArenaInfo
end

function PvpReplaceManager:OnPushReplaceArenaRankChange(stPushReplaceArenaRankChange, msg)
  if not stPushReplaceArenaRankChange then
    return
  end
  if self.m_arenaMineInfo and stPushReplaceArenaRankChange.iRank ~= 0 then
    self.m_arenaMineInfo.iGradeRank = stPushReplaceArenaRankChange.iRank
    self:broadcastEvent("eGameEvent_ReplaceArena_RankChange")
  end
  if stPushReplaceArenaRankChange.stAfk and stPushReplaceArenaRankChange.stAfk.iLastCalcTime ~= 0 and stPushReplaceArenaRankChange.stAfk.iTakeRewardTime ~= 0 then
    self:FreshArenaAFKInfo(stPushReplaceArenaRankChange.stAfk)
  end
end

function PvpReplaceManager:ReqReplaceArenaGetInit()
  local msg = MTTDProto.Cmd_ReplaceArena_GetInit_CS()
  RPCS():ReplaceArena_GetInit(msg, handler(self, self.OnReplaceArenaGetInitSC))
end

function PvpReplaceManager:OnReplaceArenaGetInitSC(stReplaceArenaInitData, msg)
  if not stReplaceArenaInitData then
    return
  end
  self:InitFreshArenaSeason(stReplaceArenaInitData)
  self:broadcastEvent("eGameEvent_ReplaceArena_SeasonInit")
end

function PvpReplaceManager:ReqReplaceArenaRefreshEnemy()
  if not self.m_arenaMineInfo then
    return
  end
  local lastFreshTime = self.m_arenaMineInfo.iLastRefreshTime
  local curServerTime = TimeUtil:GetServerTimeS()
  local limitReqFreshTime = lastFreshTime + tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaManualRefreshCD"))
  if curServerTime < limitReqFreshTime then
    return
  end
  local msg = MTTDProto.Cmd_ReplaceArena_RefreshEnemy_CS()
  RPCS():ReplaceArena_RefreshEnemy(msg, handler(self, self.OnReplaceArenaRefreshEnemySC))
end

function PvpReplaceManager:OnReplaceArenaRefreshEnemySC(stReplaceArenaRefreshEnemy, msg)
  if not stReplaceArenaRefreshEnemy then
    return
  end
  self:OnArenaReFreshEnemy(stReplaceArenaRefreshEnemy)
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceRefreshEnemy")
end

function PvpReplaceManager:ReqReplaceArenaGetEnemyDetail(enemyIndex)
  if not enemyIndex then
    return
  end
  local msg = MTTDProto.Cmd_ReplaceArena_GetEnemyDetail_CS()
  msg.iEnemyIndex = enemyIndex
  RPCS():ReplaceArena_GetEnemyDetail(msg, handler(self, self.OnReplaceArenaGetEnemyDetailSC))
end

function PvpReplaceManager:OnReplaceArenaGetEnemyDetailSC(stReplaceArenaEnemyDetail, msg)
  if not stReplaceArenaEnemyDetail then
    return
  end
  self.m_curArenaEnemyDetail = stReplaceArenaEnemyDetail.stEnemyDetail
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceGetEnemyDetail", self.m_curArenaEnemyDetail)
end

function PvpReplaceManager:ReqReplaceArenaGetBattleRecord()
  local msg = MTTDProto.Cmd_ReplaceArena_GetBattleRecord_CS()
  RPCS():ReplaceArena_GetBattleRecord(msg, handler(self, self.OnReplaceArenaGetBattleRecordSC))
end

function PvpReplaceManager:OnReplaceArenaGetBattleRecordSC(stReplaceArenaGetArenaReport, msg)
  if not stReplaceArenaGetArenaReport then
    return
  end
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceGetArenaReport", stReplaceArenaGetArenaReport.vBattleRecord)
end

function PvpReplaceManager:ReqReplaceArenaBuyTicket()
  local msg = MTTDProto.Cmd_ReplaceArena_BuyTicket_CS()
  RPCS():ReplaceArena_BuyTicket(msg, handler(self, self.OnReplaceArenaBuyTicketSC))
end

function PvpReplaceManager:OnReplaceArenaBuyTicketSC(stReplaceArenaBuyTicket, msg)
  if not stReplaceArenaBuyTicket then
    return
  end
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceBuyTicket")
end

function PvpReplaceManager:ReqReplaceArenaSeeAfk()
  local msg = MTTDProto.Cmd_ReplaceArena_SeeAfk_CS()
  RPCS():ReplaceArena_SeeAfk(msg, handler(self, self.OnReplaceArenaSeeAfkSC))
end

function PvpReplaceManager:OnReplaceArenaSeeAfkSC(stReplaceArenaSeeAfk, msg)
  if not stReplaceArenaSeeAfk then
    return
  end
  local tempAfk = stReplaceArenaSeeAfk.stAfk
  if tempAfk then
    self:FreshArenaAFKInfo(tempAfk)
  end
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceSeeAfk", tempAfk)
end

function PvpReplaceManager:ReqReplaceArenaTakeAfk()
  local msg = MTTDProto.Cmd_ReplaceArena_TakeAfk_CS()
  RPCS():ReplaceArena_TakeAfk(msg, handler(self, self.OnReplaceArenaTakeAfkSc))
end

function PvpReplaceManager:OnReplaceArenaTakeAfkSc(stReplaceArenaTakeAfk, msg)
  if not stReplaceArenaTakeAfk then
    return
  end
  local rewardList = stReplaceArenaTakeAfk.vReward
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList)
  end
  self:FreshArenaAFKInfo(stReplaceArenaTakeAfk.stAfk)
end

function PvpReplaceManager:InitGlobalCfg()
  PvpReplaceManager.LevelType = {
    ReplacePVP = MTTDProto.FightType_ReplaceArena
  }
  PvpReplaceManager.LevelSubType = {
    ReplaceArenaSubType_Attack_1 = MTTDProto.ReplaceArenaSubType_Attack_1,
    ReplaceArenaSubType_Attack_2 = MTTDProto.ReplaceArenaSubType_Attack_2,
    ReplaceArenaSubType_Attack_3 = MTTDProto.ReplaceArenaSubType_Attack_3,
    ReplaceArenaSubType_Defence_1 = MTTDProto.ReplaceArenaSubType_Defence_1,
    ReplaceArenaSubType_Defence_2 = MTTDProto.ReplaceArenaSubType_Defence_2,
    ReplaceArenaSubType_Defence_3 = MTTDProto.ReplaceArenaSubType_Defence_3
  }
  PvpReplaceManager.BattleEnterSubType = {Attack = 1, Defense = 2}
  PvpReplaceManager.BattleLevelSubTypeList = {
    [PvpReplaceManager.BattleEnterSubType.Attack] = {
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Attack_1,
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Attack_2,
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Attack_3
    },
    [PvpReplaceManager.BattleEnterSubType.Defense] = {
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_1,
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_2,
      PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_3
    }
  }
end

function PvpReplaceManager:CheckReqSeasonInit()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if openFlag and self:IsInSeasonGameTime() == true then
    self:ReqReplaceArenaGetInit()
  end
end

function PvpReplaceManager:InitFreshArenaSeason(seasonData)
  if not seasonData then
    return
  end
  self.m_arenaMineInfo = seasonData.stMine
  self.m_curSeasonID = self.m_arenaMineInfo.iSeasonId
  self.m_arenaEnemyDic = seasonData.mEnemy
  self:FreshArenaAFKInfo(seasonData.stAfk)
  self:CheckStartSeasonTimer()
end

function PvpReplaceManager:CheckStartSeasonTimer()
  if self.m_seasonTimer then
    TimeService:KillTimer(self.m_seasonTimer)
    self.m_seasonTimer = nil
  end
  if self.m_timerTriggerTimes > TimeTriggerLimitTimes then
    self.m_timerTriggerTimes = 0
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonEndTime, nextSeasonStartTime = self:GetSeasonTimeByCfg()
  if seasonEndTime and curServerTime < seasonEndTime then
    local leftSec = seasonEndTime - curServerTime + TimeUtil:GetRandomDailyDelay()
    self.m_seasonTimer = TimeService:SetTimer(leftSec, 1, function()
      self:ReqReplaceArenaGetInit()
      self.m_timerTriggerTimes = self.m_timerTriggerTimes + 1
    end)
  elseif nextSeasonStartTime and curServerTime < nextSeasonStartTime then
    local leftSec = nextSeasonStartTime - curServerTime + TimeUtil:GetRandomDailyDelay()
    self.m_seasonTimer = TimeService:SetTimer(leftSec, 1, function()
      self:ReqReplaceArenaGetInit()
      self.m_timerTriggerTimes = self.m_timerTriggerTimes + 1
    end)
  end
end

function PvpReplaceManager:OnArenaReFreshEnemy(stReplaceArenaRefreshEnemy)
  if not stReplaceArenaRefreshEnemy then
    return
  end
  self.m_arenaMineInfo.iLastRefreshTime = stReplaceArenaRefreshEnemy.iLastRefreshTime
  self.m_arenaEnemyDic = stReplaceArenaRefreshEnemy.mEnemy
end

function PvpReplaceManager:FreshArenaAFKInfo(replaceArenaAFKData)
  if not replaceArenaAFKData then
    return
  end
  if self.m_afkTimer then
    TimeService:KillTimer(self.m_afkTimer)
    self.m_afkTimer = nil
  end
  self.m_replaceArenaAfk = replaceArenaAFKData
  local curServerTime = TimeUtil:GetServerTimeS()
  local lastTakeTime = self.m_replaceArenaAfk.iTakeRewardTime
  local nextFullTime = lastTakeTime + tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
  if curServerTime < nextFullTime then
    local deltaTimeSec = nextFullTime - curServerTime
    self.m_afkTimer = TimeService:SetTimer(deltaTimeSec, 1, function()
      self.m_afkTimer = nil
      self:broadcastEvent("eGameEvent_Level_ArenaReplaceAFKFull")
    end)
  end
  self:broadcastEvent("eGameEvent_Level_ArenaReplaceAFKFresh")
end

function PvpReplaceManager:GetDownloadResourceExtra()
  local vPackage = {}
  local heroIDTab = {}
  if self.m_curArenaEnemyDetail then
    local battleFormTab = self.m_curArenaEnemyDetail.mBattleForm
    if battleFormTab then
      for i, battleForm in pairs(battleFormTab) do
        local cmdHeroList = battleForm.mCmdHero
        if cmdHeroList and next(cmdHeroList) then
          for _, heroData in pairs(cmdHeroList) do
            local heroID = heroData.iHeroId
            if heroID then
              heroIDTab[heroID] = true
            end
          end
        end
      end
    end
  end
  if heroIDTab and next(heroIDTab) then
    for heroID, _ in pairs(heroIDTab) do
      if heroID then
        vPackage[#vPackage + 1] = {
          sName = tostring(heroID),
          eType = DownloadManager.ResourcePackageType.Character
        }
        vPackage[#vPackage + 1] = {
          sName = tostring(heroID),
          eType = DownloadManager.ResourcePackageType.Level_Character
        }
      end
    end
  end
  return vPackage, nil
end

function PvpReplaceManager:GetSeasonID()
  return self.m_curSeasonID
end

function PvpReplaceManager:GetSeasonRank()
  return self.m_arenaMineInfo.iGradeRank
end

function PvpReplaceManager:GetSeasonTicketFreeCount()
  return self.m_arenaMineInfo.iFreeFightTimes
end

function PvpReplaceManager:GetSeasonLastEnemyFreshTime()
  return self.m_arenaMineInfo.iLastRefreshTime
end

function PvpReplaceManager:IsGetSeasonArenPlay()
  if self.m_arenaMineInfo.iReplaceArenaPlaySeason == nil or self.m_arenaMineInfo.iReplaceArenaPlaySeason == 0 or not self.m_curSeasonID then
    return false
  end
  local groupId = self:GetRegroupIndexId(self.m_arenaMineInfo.iReplaceArenaPlaySeason)
  local curGroupId = self:GetRegroupIndexId(self.m_curSeasonID)
  return groupId == curGroupId
end

function PvpReplaceManager:GetSeasonArenPlay()
  return self.m_arenaMineInfo.iReplaceArenaPlaySeason
end

function PvpReplaceManager:GetEnemyDic()
  return self.m_arenaEnemyDic
end

function PvpReplaceManager:GetCurBattleEnemy()
  if not self.m_curEnemyIndex then
    return
  end
  if not self.m_arenaEnemyDic then
    return
  end
  return self.m_arenaEnemyDic[self.m_curEnemyIndex]
end

function PvpReplaceManager:GetLevelType()
  return self.m_curBattleType
end

function PvpReplaceManager:GetLevelSubType()
  return self.m_curBattleSubType
end

function PvpReplaceManager:GetSeasonStartTimer()
  local seasonStartTimer = self.m_cfgSeasonStartTimer
  if seasonStartTimer == nil then
    local startTimerStr = ConfigManager:GetGlobalSettingsByKey("ReplaceArenaStartTime")
    seasonStartTimer = TimeUtil:TimeStringToTimeSec2(startTimerStr)
    self.m_cfgSeasonStartTimer = seasonStartTimer
  end
  return seasonStartTimer
end

function PvpReplaceManager:GetSeasonCompeteTime()
  local seasonCompeteTime = self.m_cfgPVPNewCompeteTime
  if not seasonCompeteTime then
    seasonCompeteTime = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaCompeteTime"))
    self.m_cfgPVPNewCompeteTime = seasonCompeteTime
  end
  return seasonCompeteTime
end

function PvpReplaceManager:GetSeasonSettleTime()
  local seasonSettleTime = self.m_cfgPVPNewSettleTime
  if not seasonSettleTime then
    seasonSettleTime = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaSettleTime"))
    self.m_cfgPVPNewSettleTime = seasonSettleTime
  end
  return seasonSettleTime
end

function PvpReplaceManager:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonStartTimer = self:GetSeasonStartTimer()
  if curServerTime < seasonStartTimer then
    return 0, seasonStartTimer
  end
  local competeTime = self:GetSeasonCompeteTime()
  local seasonStageLen = competeTime + self:GetSeasonSettleTime()
  local deltaTime = math_floor(curServerTime - seasonStartTimer)
  local seasonOffSetSec = deltaTime % seasonStageLen
  local deltaSeasonEndTime = competeTime - seasonOffSetSec
  local deltaNextSeasonStartTime = seasonStageLen - seasonOffSetSec
  local seasonEndTimer = curServerTime + deltaSeasonEndTime
  local nextSeasonStartTimer = curServerTime + deltaNextSeasonStartTime
  return seasonEndTimer, nextSeasonStartTimer
end

function PvpReplaceManager:IsInSeasonGameTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonEndTimer, _ = self:GetSeasonTimeByCfg()
  return curServerTime < seasonEndTimer
end

function PvpReplaceManager:GetAssignLevelParams(levelType, battleSubType, enemyIndex)
  if levelType == nil then
    levelType = self.m_curBattleType
  end
  if battleSubType == nil then
    battleSubType = self.m_curBattleSubType
  end
  return {
    levelType,
    battleSubType,
    0,
    0
  }
end

function PvpReplaceManager:IsSeasonStart()
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonStartTimer = self:GetSeasonStartTimer()
  return curServerTime > seasonStartTimer
end

function PvpReplaceManager:GetAllReplaceRankCfg()
  if not self.m_allReplaceArenaRewardCfg then
    self.m_allReplaceArenaRewardCfg = {}
    local allCfg = ConfigManager:GetConfigInsByName("ReplaceArenaRank"):GetAll()
    for _, tempCfg in pairs(allCfg) do
      self.m_allReplaceArenaRewardCfg[tempCfg.m_ID] = tempCfg
    end
  end
  return self.m_allReplaceArenaRewardCfg
end

function PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum, iReplaceArenaPlaySeason)
  if not rankNum then
    return
  end
  if iReplaceArenaPlaySeason then
    local groupId = self:GetRegroupIndexId(iReplaceArenaPlaySeason)
    local seasonGroupId = self:GetRegroupIndexId(self.m_curSeasonID)
    if groupId ~= seasonGroupId then
      return self:GetReplaceRankCfgNew()
    end
  end
  local allRewardCfgList = self:GetAllReplaceRankCfg()
  for i, tempCfg in ipairs(allRewardCfgList) do
    if rankNum >= tempCfg.m_RankMin and (tempCfg.m_RankMax == 0 or rankNum <= tempCfg.m_RankMax) then
      return tempCfg
    end
  end
  return allRewardCfgList[#allRewardCfgList]
end

function PvpReplaceManager:GetReplaceRankCfgByGradeNum(gradeNum)
  if not gradeNum then
    return
  end
  if not self.m_allReplaceArenaRewardCfg then
    self:GetAllReplaceRankCfg()
  end
  return self.m_allReplaceArenaRewardCfg[gradeNum]
end

function PvpReplaceManager:GetBattleResultData()
  return self.m_resultData
end

function PvpReplaceManager:GetReplaceArenaAfkInfo()
  return self.m_replaceArenaAfk
end

function PvpReplaceManager:IsBattleResultSuc()
  if not self.m_resultData then
    return
  end
  local resultList = self.m_resultData.vResult
  if not resultList then
    return
  end
  if not next(resultList) then
    return
  end
  local sucNum = 0
  local defNum = 0
  for i, v in ipairs(resultList) do
    if v == 1 then
      sucNum = sucNum + 1
    else
      defNum = defNum + 1
    end
  end
  return sucNum > defNum
end

function PvpReplaceManager:GetRegroupIndexId(iReplaceArenaPlaySeason)
  if not iReplaceArenaPlaySeason then
    return -1
  end
  if iReplaceArenaPlaySeason < 1 then
    return 1
  end
  local iNeedSeason = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaRegroup"))
  if iNeedSeason < 1 then
    return iReplaceArenaPlaySeason + 1
  end
  return math.floor((iReplaceArenaPlaySeason - 1) / iNeedSeason) + 2
end

function PvpReplaceManager:IsAfkRankCanReward()
  if not self.m_replaceArenaAfk then
    return
  end
  local rankNum = self.m_replaceArenaAfk.iRank
  if rankNum == 0 then
    return
  end
  if not self:IsGetSeasonArenPlay() then
    return
  end
  if self.m_replaceArenaAfk.iLastCalcTime == 0 or self.m_replaceArenaAfk.iTakeRewardTime == 0 then
    return
  end
  local rankCfg = self:GetReplaceRankCfgByRankNum(rankNum)
  if not rankCfg then
    return
  end
  local rankRewardArray = rankCfg.m_PVPAFKReward
  if not rankRewardArray then
    return
  end
  local curSeasonEndTime, nextSeasonStartTime = self:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  local isCurSeason
  if curSeasonEndTime > curServerTime then
    isCurSeason = true
  elseif curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
    isCurSeason = false
  else
    isCurSeason = false
  end
  if not isCurSeason then
    return
  end
  local rewardLen = rankRewardArray.Length
  if 0 < rewardLen then
    return true
  end
  return false
end

function PvpReplaceManager:GetEnemyDetail()
  return self.m_curArenaEnemyDetail
end

function PvpReplaceManager:IsHangUpHaveRedDot()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if not openFlag then
    return 0
  end
  if not self.m_replaceArenaAfk then
    return 0
  end
  local curRankNum = self.m_replaceArenaAfk.iRank
  if curRankNum == 0 then
    return 0
  end
  local lastTakeTime = self.m_replaceArenaAfk.iTakeRewardTime
  if lastTakeTime == 0 then
    return 0
  end
  local lastCalcTime = self.m_replaceArenaAfk.iLastCalcTime
  if lastCalcTime == 0 then
    return 0
  end
  local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
  local fullTime = lastTakeTime + limitTimeSecNum
  local curServerTime = TimeUtil:GetServerTimeS()
  if fullTime <= curServerTime then
    return 1
  else
    return 0
  end
end

function PvpReplaceManager:StartEnterBattle(levelType, battleSubType, enemyIndex)
  if not battleSubType then
    return
  end
  self.m_curBattleType = levelType
  self.m_curBattleSubType = battleSubType
  self.m_curEnemyIndex = enemyIndex or 0
  local enemyOld = self:GetCurBattleEnemy()
  local curRank = self:GetSeasonRank()
  if curRank and enemyOld and enemyOld.iRank and curRank <= 3 and curRank < enemyOld.iRank then
    self.isOpenEnemyTips = true
  end
  local levelSubTypeList = PvpReplaceManager.BattleLevelSubTypeList[battleSubType]
  self:BeforeEnterBattle(levelType, levelSubTypeList, enemyIndex)
  local mapID = self:GetLevelMapID()
  self:EnterPVPBattle(mapID)
end

function PvpReplaceManager:EnterPVPBattle(mapID)
  BattleFlowManager:ChangeBattleStage(BattleFlowManager.BattleStage.InBattle)
  BattleGlobalManager:EnterPVPBattle(mapID)
end

function PvpReplaceManager:BeforeEnterBattle(levelType, levelSubTypeList, enemyIndex)
  PvpReplaceManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = levelSubTypeList or {},
    levelID = 0,
    heroList = HeroManager:GetHeroServerList(),
    enemyIndex = enemyIndex or 0,
    enemyDetail = self.m_curArenaEnemyDetail,
    seasonId = self.m_curSeasonID
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function PvpReplaceManager:GetLevelMapID()
  local mapID = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplacePVPMapid") or 0)
  return mapID
end

function PvpReplaceManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID)
  log.info("PvpReplaceManager OnBattleEnd")
  local battleResultErrorCode = finishErrorCode
  if self.m_resultData and self.m_resultData.iRet > 1 then
    battleResultErrorCode = self.m_resultData.iRet
  end
  if battleResultErrorCode ~= nil and battleResultErrorCode ~= 0 and battleResultErrorCode ~= MTTD.Error_ReplaceArena_SeasonChange and battleResultErrorCode ~= MTTD.Error_ReplaceArena_EnemyRankLow then
    local msg = {rspcode = battleResultErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  elseif battleResultErrorCode == MTTD.Error_ReplaceArena_SeasonChange then
    utils.CheckAndPushCommonTips({
      tipsID = 1225,
      bLockBack = true,
      func1 = function()
        BattleFlowManager:ExitBattle()
      end
    })
  else
    local isBattleSuc = self:IsBattleResultSuc()
    local levelType = self.m_curBattleType
    local levelSubType = self.m_curBattleSubType
    if isBattleSuc then
      StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEBATTLEVICTORY, {
        levelType = levelType,
        levelSubType = levelSubType,
        finishErrorCode = battleResultErrorCode,
        showHeroID = randomShowHeroID,
        isOpenEnemyTips = self.isOpenEnemyTips
      })
    else
      StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEBATTLEDEFEAT, {
        levelType = levelType,
        levelSubType = levelSubType,
        finishErrorCode = battleResultErrorCode
      })
    end
  end
end

function PvpReplaceManager:EnterNextBattle(levelType, ...)
end

function PvpReplaceManager:OnBackLobby(fCB)
  local formStr = "Form_PvpReplaceMain"
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      if self.m_curBattleSubType == PvpReplaceManager.BattleEnterSubType.Attack or self.m_curBattleSubType == PvpReplaceManager.BattleEnterSubType.Defense then
        if self:IsInSeasonGameTime() == true then
          StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEMAIN)
          formStr = "Form_PvpReplaceMain"
        else
          StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN, {openPvp = true})
          formStr = "Form_HallActivityMain"
        end
      else
        StackFlow:Push(UIDefines.ID_FORM_HALL)
        formStr = "Form_Hall"
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end)
end

function PvpReplaceManager:ClearCurBattleInfo()
  self.m_curBattleType = nil
  self.m_curBattleSubType = nil
  self.m_curEnemyIndex = nil
  self.m_curArenaEnemyDetail = nil
  self.m_resultData = nil
end

function PvpReplaceManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  self:ExitBattle()
end

function PvpReplaceManager:GetReplaceRankCfgNew()
  local allRewardCfgList = self:GetAllReplaceRankCfg()
  for i, tempCfg in ipairs(allRewardCfgList) do
    if tempCfg.m_New == 1 then
      return tempCfg
    end
  end
end

return PvpReplaceManager
