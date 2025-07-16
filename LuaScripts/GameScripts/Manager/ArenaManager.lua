local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local ArenaManager = class("ArenaManager", BaseLevelManager)
local tonumber = _ENV.tonumber
local math_floor = math.floor
local TimeTriggerLimitTimes = 20

function ArenaManager:OnCreate()
  self.m_timerTriggerTimes = 0
  self.m_mineSeasonEndTime = nil
  self.m_curSeasonID = nil
  self.m_curSeasonEndTime = nil
  self.m_nextSeasonStartTime = nil
  self.m_oldRank = nil
  self.m_oldScore = nil
  self.m_arenaMineInfo = {}
  self.m_arenaEnemyDic = {}
  self.m_curArenaEnemyDetail = {}
  self.m_curArenaType = nil
  self.m_curArenaSubType = nil
  self.m_curEnemyIndex = nil
  self.m_cfgSeasonStartTimer = nil
  self.m_cfgPVPNewCompeteTime = nil
  self.m_cfgPVPNewSettleTime = nil
  self.m_PvpHeroModifyCfg = nil
  self:AddEventListener()
end

function ArenaManager:OnInitNetwork()
  RPCS():Listen_Push_OriginalArenaMineInfo(handler(self, self.OnPushArenaMineInfo), "ArenaManager")
end

function ArenaManager:OnAfterFreshData()
  self:InitGlobalCfg()
end

function ArenaManager:InitGlobalCfg()
  local PVPNewHeroModify = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewHeroModify")) or 0
  if PVPNewHeroModify ~= 0 then
    self.m_PvpHeroModifyCfg = LevelManager:GetHeroModifyCfg(PVPNewHeroModify)
  end
end

function ArenaManager:OnDailyReset()
  if self.m_curSeasonID then
    self:ReqOriginalArenaGetInit()
  end
end

function ArenaManager:OnUpdate(dt)
end

function ArenaManager:ClearCacheMineSeasonInfo()
  self.m_timerTriggerTimes = 0
  self.m_mineSeasonEndTime = nil
  self.m_curSeasonID = nil
  self.m_curSeasonEndTime = nil
  self.m_nextSeasonStartTime = nil
  self.m_arenaMineInfo = {}
  if self.m_seasonTimer then
    TimeService:KillTimer(self.m_seasonTimer)
    self.m_seasonTimer = nil
  end
end

function ArenaManager:AddEventListener()
end

function ArenaManager:OnPushArenaMineInfo(stMineInfo, msg)
  if not stMineInfo then
    return
  end
  self.m_curSeasonID = stMineInfo.iSeasonId
  if self.m_arenaMineInfo then
    self.m_arenaMineInfo.iSeasonId = stMineInfo.iSeasonId
    self.m_arenaMineInfo.iGroupId = stMineInfo.iGroupId
    self.m_arenaMineInfo.iRank = stMineInfo.iRank
    self.m_arenaMineInfo.iScore = stMineInfo.iScore
    self.m_arenaMineInfo.iTicketFreeCount = stMineInfo.iTicketFreeCount
    self.m_oldRank = stMineInfo.iOldRank or 0
    self.m_oldScore = stMineInfo.iOldScore or 0
  end
end

function ArenaManager:ReqOriginalArenaGetInit()
  local msg = MTTDProto.Cmd_OriginalArena_GetInit_CS()
  RPCS():OriginalArena_GetInit(msg, handler(self, self.OnOriginalArenaGetInitSC))
end

function ArenaManager:OnOriginalArenaGetInitSC(stOriginalArenaInitData, msg)
  if not stOriginalArenaInitData then
    return
  end
  self:InitFreshArenaSeason(stOriginalArenaInitData)
  self:broadcastEvent("eGameEvent_Arena_SeasonInit")
end

function ArenaManager:ReqOriginalArenaRefreshEnemy(isFreeRefresh)
  local msg = MTTDProto.Cmd_OriginalArena_RefreshEnemy_CS()
  msg.bFreeRefresh = isFreeRefresh
  RPCS():OriginalArena_RefreshEnemy(msg, handler(self, self.OnOriginalArenaRefreshEnemySC))
end

function ArenaManager:OnOriginalArenaRefreshEnemySC(stOriginalArenaRefreshEnemy, msg)
  if not stOriginalArenaRefreshEnemy then
    return
  end
  self:OnArenaReFreshEnemy(stOriginalArenaRefreshEnemy)
  self:broadcastEvent("eGameEvent_Level_ArenaRefreshEnemy")
end

function ArenaManager:ReqOriginalArenaGetEnemyDetail(enemyIndex)
  if not enemyIndex then
    return
  end
  local msg = MTTDProto.Cmd_OriginalArena_GetEnemyDetail_CS()
  msg.iEnemyId = enemyIndex
  RPCS():OriginalArena_GetEnemyDetail(msg, handler(self, self.OnOriginalArenaGetEnemyDetailSC), handler(self, self.OnOriginalArenaGetEnemyDetailFail))
end

function ArenaManager:OnOriginalArenaGetEnemyDetailSC(stOriginalArenaEnemyDetail, msg)
  if not stOriginalArenaEnemyDetail then
    return
  end
  self.m_curArenaEnemyDetail = stOriginalArenaEnemyDetail.stEnemyDetail
  self:broadcastEvent("eGameEvent_Level_ArenaGetEnemyDetail", self.m_curArenaEnemyDetail)
end

function ArenaManager:OnOriginalArenaGetEnemyDetailFail(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  if iErrorCode == MTTDProto.Error_OriginalArena_UnkownEnemy then
    self:broadcastEvent("eGameEvent_Level_ArenaUnknown")
  else
    NetworkManager:OnRpcCallbackFail(msg)
  end
end

function ArenaManager:ReqOriginalArenaTakeSeasonReward()
  local msg = MTTDProto.Cmd_OriginalArena_TakeSeasonReward_CS()
  RPCS():OriginalArena_TakeSeasonReward(msg, handler(self, self.OnOriginalArenaTakeSeasonRewardSC))
end

function ArenaManager:OnOriginalArenaTakeSeasonRewardSC(stTakeSeasonReward)
  if not stTakeSeasonReward then
    return
  end
end

function ArenaManager:ReqOriginalArenaGetArenaReport()
  local msg = MTTDProto.Cmd_OriginalArena_GetArenaReport_CS()
  RPCS():OriginalArena_GetArenaReport(msg, handler(self, self.OnOriginalArenaGetArenaReportSC))
end

function ArenaManager:OnOriginalArenaGetArenaReportSC(stArenaGetArenaReport, msg)
  if not stArenaGetArenaReport then
    return
  end
  self:broadcastEvent("eGameEvent_Level_ArenaGetArenaReport", stArenaGetArenaReport)
end

function ArenaManager:ReqOriginalArenaBuyTicket()
  local msg = MTTDProto.Cmd_OriginalArena_BuyTicket_CS()
  RPCS():OriginalArena_BuyTicket(msg, handler(self, self.OnOriginalArenaBuyTicketSC))
end

function ArenaManager:OnOriginalArenaBuyTicketSC(stArenaBuyTicket, msg)
  if not stArenaBuyTicket then
    return
  end
  self.m_arenaMineInfo.iTicketBuyCount = stArenaBuyTicket.iTicketBuyCount
  self:broadcastEvent("eGameEvent_Level_ArenaBuyTicket")
end

function ArenaManager:InitFreshArenaSeason(seasonData)
  if not seasonData then
    return
  end
  self.m_arenaMineInfo = seasonData.stMine
  self.m_curSeasonID = self.m_arenaMineInfo.iSeasonId
  self.m_mineSeasonEndTime = self.m_arenaMineInfo.iEndTime
  self.m_nextSeasonStartTime = self.m_arenaMineInfo.iCurEndTime
  self.m_curSeasonEndTime = self.m_nextSeasonStartTime - tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewSettleTime"))
  self.m_arenaEnemyDic = seasonData.mEnemy
  self:CheckStartSeasonTimer()
end

function ArenaManager:CheckStartSeasonTimer()
  if self.m_seasonTimer then
    TimeService:KillTimer(self.m_seasonTimer)
    self.m_seasonTimer = nil
  end
  if self.m_timerTriggerTimes > TimeTriggerLimitTimes then
    self.m_timerTriggerTimes = 0
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  if self.m_curSeasonEndTime and curServerTime < self.m_curSeasonEndTime then
    local leftSec = self.m_curSeasonEndTime - curServerTime + TimeUtil:GetRandomDailyDelay()
    self.m_seasonTimer = TimeService:SetTimer(leftSec, 1, function()
      self:ReqOriginalArenaGetInit()
      self.m_timerTriggerTimes = self.m_timerTriggerTimes + 1
    end)
  elseif self.m_nextSeasonStartTime and curServerTime < self.m_nextSeasonStartTime then
    local leftSec = self.m_nextSeasonStartTime - curServerTime + TimeUtil:GetRandomDailyDelay()
    self.m_seasonTimer = TimeService:SetTimer(leftSec, 1, function()
      self:ReqOriginalArenaGetInit()
      self.m_timerTriggerTimes = self.m_timerTriggerTimes + 1
    end)
  end
end

function ArenaManager:OnArenaReFreshEnemy(stOriginalArenaRefreshEnemy)
  if not stOriginalArenaRefreshEnemy then
    return
  end
  self.m_arenaMineInfo.iEnemyRefreshCount = stOriginalArenaRefreshEnemy.iEnemyRefreshCount
  self.m_arenaMineInfo.iLastRefreshTime = stOriginalArenaRefreshEnemy.iLastRefreshTime
  self.m_arenaEnemyDic = stOriginalArenaRefreshEnemy.mEnemy
end

function ArenaManager:GetSeasonID()
  return self.m_curSeasonID
end

function ArenaManager:GetSeasonRank()
  return self.m_arenaMineInfo.iRank
end

function ArenaManager:GetSeasonPoint()
  return self.m_arenaMineInfo.iScore
end

function ArenaManager:GetCurSeasonEndTime()
  return self.m_curSeasonEndTime
end

function ArenaManager:GetNextSeasonStartTime()
  return self.m_nextSeasonStartTime
end

function ArenaManager:GetMineSeasonEndTime()
  return self.m_mineSeasonEndTime
end

function ArenaManager:GetSeasonTicketBuyCount()
  return self.m_arenaMineInfo.iTicketBuyCount or 0
end

function ArenaManager:GetSeasonTicketFreeCount()
  return self.m_arenaMineInfo.iTicketFreeCount
end

function ArenaManager:GetFreeCountMaxNum()
  local totalFreeNum = ConfigManager:GetGlobalSettingsByKey("PVPNewDailyFreeTime") or 3
  totalFreeNum = totalFreeNum + (StatueShowroomManager:GetStatueEffectValue("StatueEffect_PVPFreeCount") or 0)
  return math_floor(totalFreeNum)
end

function ArenaManager:GetSeasonLastEnemyFreshTime()
  return self.m_arenaMineInfo.iLastRefreshTime or 0
end

function ArenaManager:GetEnemyDic()
  return self.m_arenaEnemyDic
end

function ArenaManager:GetLevelType()
  return self.m_curArenaType
end

function ArenaManager:GetLevelSubType()
  return self.m_curArenaSubType
end

function ArenaManager:GetOldInfo()
  return self.m_oldRank, self.m_oldScore
end

function ArenaManager:ClearOldInfo()
  self.m_oldRank = nil
  self.m_oldScore = nil
end

function ArenaManager:IsLevelEntryHaveRedDot(levelType)
  if not levelType then
    return
  end
  if levelType ~= BattleFlowManager.ArenaType.Arena then
    return
  end
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena)
  if not openFlag then
    return 0
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonEndTimer, nextSeasonStartTimer = self:GetSeasonTimeByCfg()
  if seasonEndTimer == 0 or seasonEndTimer == nil then
    return 0
  end
  if curServerTime > seasonEndTimer and curServerTime < nextSeasonStartTimer then
    return 0
  end
  local enterTimerStr = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Level_ArenaEnter)
  local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
  if TimeUtil:IsCurDayTime(enterTimer) == true then
    return 0
  else
    return 1
  end
end

function ArenaManager:CheckSetEnterTimer(levelType)
  if not levelType then
    return
  end
  if levelType ~= BattleFlowManager.ArenaType.Arena then
    return
  end
  local enterTimerStr = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Level_ArenaEnter)
  local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
  if TimeUtil:IsCurDayTime(enterTimer) == true then
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local curServerTimeStr = TimeUtil:ServerTimerToServerString(curServerTime)
  ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.Level_ArenaEnter, curServerTimeStr)
end

function ArenaManager:GetSeasonStartTimer()
  local seasonStartTimer = self.m_cfgSeasonStartTimer
  if seasonStartTimer == nil then
    local startTimerStr = ConfigManager:GetGlobalSettingsByKey("PVPNewStartTime")
    seasonStartTimer = TimeUtil:TimeStringToTimeSec2(startTimerStr)
    self.m_cfgSeasonStartTimer = seasonStartTimer
  end
  return seasonStartTimer
end

function ArenaManager:GetPVPNewCompeteTime()
  local seasonCompeteTime = self.m_cfgPVPNewCompeteTime
  if not seasonCompeteTime then
    seasonCompeteTime = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewCompeteTime"))
    self.m_cfgPVPNewCompeteTime = seasonCompeteTime
  end
  return seasonCompeteTime
end

function ArenaManager:GetPVPNewSettleTime()
  local seasonSettleTime = self.m_cfgPVPNewSettleTime
  if not seasonSettleTime then
    seasonSettleTime = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewSettleTime"))
    self.m_cfgPVPNewSettleTime = seasonSettleTime
  end
  return seasonSettleTime
end

function ArenaManager:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonStartTimer = self:GetSeasonStartTimer()
  if curServerTime < seasonStartTimer then
    return 0, seasonStartTimer
  end
  local competeTime = self:GetPVPNewCompeteTime()
  local seasonStageLen = competeTime + self:GetPVPNewSettleTime()
  local deltaTime = math_floor(curServerTime - seasonStartTimer)
  local seasonOffSetSec = deltaTime % seasonStageLen
  local deltaSeasonEndTime = competeTime - seasonOffSetSec
  local deltaNextSeasonStartTime = seasonStageLen - seasonOffSetSec
  local seasonEndTimer = curServerTime + deltaSeasonEndTime
  local nextSeasonStartTimer = curServerTime + deltaNextSeasonStartTime
  return seasonEndTimer, nextSeasonStartTimer
end

function ArenaManager:IsInSeasonGameTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local seasonEndTimer, _ = self:GetSeasonTimeByCfg()
  return curServerTime < seasonEndTimer
end

function ArenaManager:GetAssignLevelParams(levelType, arenaSubType)
  if levelType == nil then
    levelType = self.m_curArenaType
  end
  if arenaSubType == nil then
    arenaSubType = self.m_curArenaSubType
  end
  return {
    levelType,
    arenaSubType,
    0,
    0
  }
end

function ArenaManager:GetPvpHeroModifyCfg()
  return self.m_PvpHeroModifyCfg
end

function ArenaManager:GeneratePvpHeroModifyData(heroData)
  local heroModifyCfg = self:GetPvpHeroModifyCfg()
  if heroModifyCfg then
    local tempData = {}
    tempData.iPower = heroData.iPower
    tempData.mHeroAttr = heroData.mHeroAttr
    tempData.iBaseId = heroData.iBaseId
    tempData.iOriLevel = heroData.iOriLevel
    tempData.bLove = heroData.bLove
    tempData.iFashion = heroData.iFashion
    tempData.iHeroId = heroData.iHeroId
    tempData.iTime = heroData.iTime
    tempData.mSkill = heroData.mSkill
    tempData.iAttractRank = heroModifyCfg.m_ForceAttractRank == 0 and heroData.iAttractRank or 0
    tempData.iBreak = heroModifyCfg.m_ForceBreak == 0 and heroData.iBreak or 0
    tempData.iLevel = heroModifyCfg.m_ForceLevel == 0 and heroData.iLevel or heroModifyCfg.m_ForceLevel
    tempData.mEquip = heroModifyCfg.m_IgnoreEquip == 0 and heroData.mEquip or {}
    tempData.stLegacy = heroModifyCfg.m_IgnoreLegacy == 0 and heroData.stLegacy or {}
    return tempData
  else
    return heroData
  end
end

function ArenaManager:GetDownloadResourceExtra()
  local vPackage = {}
  if self.m_curArenaEnemyDetail and self.m_curArenaEnemyDetail.mCmdHero then
    for _, stHeroData in pairs(self.m_curArenaEnemyDetail.mCmdHero) do
      local iHeroBaseID = stHeroData.iHeroId
      if iHeroBaseID then
        vPackage[#vPackage + 1] = {
          sName = tostring(iHeroBaseID),
          eType = DownloadManager.ResourcePackageType.Character
        }
        vPackage[#vPackage + 1] = {
          sName = tostring(iHeroBaseID),
          eType = DownloadManager.ResourcePackageType.Level_Character
        }
      end
    end
  end
  return vPackage, nil
end

function ArenaManager:StartEnterBattle(levelType, arenaSubType, enemyIndex)
  if not arenaSubType then
    return
  end
  self.m_curArenaType = levelType
  self.m_curArenaSubType = arenaSubType
  self.m_curEnemyIndex = enemyIndex or 0
  self:BeforeEnterBattle(levelType, arenaSubType, enemyIndex)
  local mapID = self:GetLevelMapID()
  self:EnterPVPBattle(mapID)
end

function ArenaManager:EnterPVPBattle(mapID)
  BattleFlowManager:ChangeBattleStage(BattleFlowManager.BattleStage.InBattle)
  BattleGlobalManager:EnterPVPBattle(mapID)
end

function ArenaManager:BeforeEnterBattle(levelType, levelSubType, enemyIndex)
  ArenaManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = levelSubType or 0,
    levelID = 0,
    heroList = HeroManager:GetHeroServerList(),
    enemyIndex = enemyIndex or 0,
    enemyDetail = self.m_curArenaEnemyDetail,
    seasonId = self.m_curSeasonID
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function ArenaManager:GetLevelMapID()
  local mapID = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewMapid") or 0)
  return mapID
end

function ArenaManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID)
  log.info("ArenaManager OnBattleEnd isSuc: ", tostring(isSuc))
  if finishErrorCode == nil or finishErrorCode == 0 then
    self:ReqOriginalArenaRefreshEnemy(true)
  end
  if finishErrorCode ~= nil and finishErrorCode ~= 0 and finishErrorCode ~= MTTD.Error_OriginalArena_FinishChallenge then
    local msg = {rspcode = finishErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    local result = isSuc
    local levelType = self.m_curArenaType
    local levelSubType = self.m_curArenaSubType
    if result then
      local rewardData
      if stageFinishChallengeSc and stageFinishChallengeSc.stFinishChallengeInfoSC then
        local stFinishChallengeInfoSC = stageFinishChallengeSc.stFinishChallengeInfoSC
        rewardData = stFinishChallengeInfoSC.vReward
      end
      StackFlow:Push(UIDefines.ID_FORM_PVPBATTLEVICTORY, {
        levelType = levelType,
        levelSubType = levelSubType,
        rewardData = rewardData,
        finishErrorCode = finishErrorCode,
        showHeroID = randomShowHeroID
      })
    else
      StackFlow:Push(UIDefines.ID_FORM_PVPBATTLEDEFEAT, {
        levelType = levelType,
        levelSubType = levelSubType,
        finishErrorCode = finishErrorCode
      })
    end
  end
end

function ArenaManager:EnterNextBattle(levelType, ...)
end

function ArenaManager:OnBackLobby(fCB)
  local formStr = "Form_PvpMain"
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      if self.m_curArenaSubType == BattleFlowManager.ArenaSubType.ArenaBattle or self.m_curArenaSubType == BattleFlowManager.ArenaSubType.ArenaDefense then
        if self:IsInSeasonGameTime() == true then
          StackFlow:Push(UIDefines.ID_FORM_PVPMAIN)
          formStr = "Form_PvpMain"
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
  end, true)
end

function ArenaManager:ClearCurBattleInfo()
  self.m_curArenaType = nil
  self.m_curArenaSubType = nil
  self.m_curEnemyIndex = nil
  self.m_curArenaEnemyDetail = nil
  self:ClearOldInfo()
end

function ArenaManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  self:ExitBattle()
end

return ArenaManager
