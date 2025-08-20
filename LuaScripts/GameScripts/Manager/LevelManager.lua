local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local LevelManager = class("LevelManager", BaseLevelManager)

function LevelManager:OnCreate()
  self.m_curBattleLevelType = nil
  self.m_curBattleLevelSubType = nil
  self.m_curBattleLevelID = nil
  self.m_reqEnterBattleTimer = nil
  self.m_cacheLevelCfgTab = {}
  self.m_isSim = nil
  self.m_towerAutoBattleEffective = false
end

function LevelManager:OnInitNetwork()
  RPCS():Listen_Push_PassStage(handler(self, self.OnPushPassStage), "LevelManager")
  RPCS():Listen_Push_StageTimes(handler(self, self.OnPushStageTimes), "LevelManager")
  RPCS():Listen_Push_DungeonChapterMop(handler(self, self.OnPushDungeonChapterData), "LevelManager")
end

function LevelManager:OnAfterFreshData()
  self:ReqAllLevelTypeDailyTimes()
  self:ReqAllLevelTypeDetails()
end

function LevelManager:OnDailyReset()
  self:broadcastEvent("eGameEvent_Level_DailyReset")
  if self.m_levelMainHelper then
    self:ReqAllLevelTypeDailyTimes()
    self:ReqAllLevelTypeDetails()
  end
  if self.m_levelEquipmentHelper then
    self.m_levelEquipmentHelper:ReqStageGetDungeonChapterMopCS()
  end
end

function LevelManager:OnUpdate(dt)
end

function LevelManager:InitGlobalCfg()
  LevelManager.ChapterType = {Normal = 1, Hard = 2}
  LevelManager.LevelType = {
    MainLevel = MTTDProto.FightType_Main,
    Dungeon = MTTDProto.FightType_Dungeon,
    Tower = MTTDProto.FightType_Tower,
    Goblin = MTTDProto.FightType_Goblin
  }
  LevelManager.MainLevelSubType = {
    MainStory = MTTDProto.FightMainSubType_Main,
    ExLevel = MTTDProto.FightMainSubType_Ex,
    HardLevel = MTTDProto.FightMainSubType_Hard
  }
  LevelManager.TowerLevelSubType = {
    Main = MTTDProto.FightTowerSubType_Main,
    Tribe1 = MTTDProto.FightTowerSubType_Tribe1,
    Tribe2 = MTTDProto.FightTowerSubType_Tribe2,
    Tribe3 = MTTDProto.FightTowerSubType_Tribe3,
    Tribe4 = MTTDProto.FightTowerSubType_Tribe4
  }
  LevelManager.TowerTribeMaxNum = 4
  LevelManager.TowerEnumMaxNum = 5
  LevelManager.GoblinMaxProgressNum = 6
  LevelManager.DungeonSubType = {
    Main = MTTDProto.FightDungeonSubType_Equip
  }
  LevelManager.GoblinSubType = {
    Skill = MTTDProto.FightGoblinSubType_Skill
  }
end

function LevelManager:OnStageGetListSCMerge(mStageListData)
  self:InitGlobalCfg()
  self.m_levelMainHelper = require("Manager/ManagerPlus/LevelMainHelper").new()
  self.m_levelTowerHelper = require("Manager/ManagerPlus/LevelTowerHelper").new()
  self.m_levelGoblinHelper = require("Manager/ManagerPlus/LevelGoblinHelper").new()
  self.m_levelEquipmentHelper = require("Manager/ManagerPlus/LevelEquipmentHelper").new()
  for _, v in pairs(LevelManager.LevelType) do
    local stStageListData = mStageListData[v]
    if stStageListData ~= nil then
      log.info("LevelManager OnStageGetListSC stStageListData: ", tostring(stStageListData))
      local levelType = stStageListData.iStageType
      local mSubStage = stStageListData.mSubStage
      local tempLevelHelper = self:GetLevelHelperByType(levelType)
      if tempLevelHelper and tempLevelHelper.SetStageData then
        tempLevelHelper:SetStageData(mSubStage)
      end
    end
  end
end

function LevelManager:ReqAllLevelTypeDailyTimes()
  local subTowerTypeList = {}
  for _, levelSubType in pairs(LevelManager.TowerLevelSubType) do
    subTowerTypeList[#subTowerTypeList + 1] = levelSubType
  end
  self:ReqGetStageTimes(LevelManager.LevelType.Tower, subTowerTypeList)
  local subGoblinTypeList = {}
  for _, levelSubType in pairs(LevelManager.GoblinSubType) do
    subGoblinTypeList[#subGoblinTypeList + 1] = levelSubType
  end
  self:ReqGetStageTimes(LevelManager.LevelType.Goblin, subGoblinTypeList)
end

function LevelManager:ReqAllLevelTypeDetails()
  self:ReqGetStageDetail(LevelManager.LevelType.Goblin)
  self:ReqGetStageDetail(LevelManager.LevelType.Dungeon)
end

function LevelManager:ReqGetStageTimes(levelType, levelSubTypeList)
  if not levelType then
    return
  end
  if not levelSubTypeList then
    return
  end
  local msg = MTTDProto.Cmd_Stage_GetStageTimes_CS()
  msg.iType = levelType
  msg.vSubType = levelSubTypeList
  RPCS():Stage_GetStageTimes(msg, handler(self, self.OnGetStageTimesSC))
end

function LevelManager:OnGetStageTimesSC(stStageTimesData, msg)
  if not stStageTimesData then
    return
  end
  local levelType = stStageTimesData.iType
  if not levelType then
    return
  end
  local levelHelper = self:GetLevelHelperByType(levelType)
  if levelHelper and levelHelper.SetLevelDailyTimes then
    local dailyTimes = stStageTimesData.mTimes
    levelHelper:SetLevelDailyTimes(dailyTimes)
  end
  self:broadcastEvent("eGameEvent_Level_StageTimesFresh")
end

function LevelManager:ReqGetStageDetail(levelType, levelIDList)
  if not levelType then
    return
  end
  levelIDList = levelIDList or {}
  local msg = MTTDProto.Cmd_Stage_GetStageDetail_CS()
  msg.iType = levelType
  msg.vStageId = levelIDList
  RPCS():Stage_GetStageDetail(msg, handler(self, self.OnGetStageDetailSC))
end

function LevelManager:OnGetStageDetailSC(stStageDetailData, msg)
  if not stStageDetailData then
    return
  end
  local levelType = stStageDetailData.iType
  if not levelType then
    return
  end
  local levelHelper = self:GetLevelHelperByType(levelType)
  if levelHelper and levelHelper.FreshLevelDetail then
    local stageDetail = stStageDetailData.mStageDetail
    levelHelper:FreshLevelDetail(stageDetail)
  end
  self:broadcastEvent("eGameEvent_Level_StageDetailFresh")
end

function LevelManager:StartEnterBattle(levelType, levelID, isSim)
  if isSim == true then
    self:EnterBattle(levelType, levelID, isSim)
  else
    self:ReqStageEnterChallenge(levelType, levelID)
  end
end

function LevelManager:ReStartBattle(isRestartArea)
  if not self.m_curBattleLevelType then
    log.error("测试关卡不支持再战功能")
    return
  end
  if isRestartArea then
    CS.BattleGameManager.Instance:ReStartBattle(isRestartArea)
  else
    CS.BattleGameManager.Instance:ReStartBattle(isRestartArea)
  end
end

function LevelManager:ReqStageEnterChallenge(levelType, levelID)
  if not levelType or not levelID then
    return
  end
  if self.m_reqEnterBattleTimer then
    return
  end
  self.m_reqEnterBattleTimer = TimeService:SetTimer(6, 1, function()
    self.m_reqEnterBattleTimer = nil
  end)
  local msg = MTTDProto.Cmd_Stage_EnterChallenge_CS()
  msg.iStageType = levelType
  msg.iStageId = levelID
  RPCS():Stage_EnterChallenge(msg, handler(self, self.OnStageEnterChallengeSC), handler(self, self.OnStageEnterChallengeFail))
end

function LevelManager:OnStageEnterChallengeSC(stStageEnterData, msg)
  log.info("LevelManager OnStageEnterChallengeSC stStageEnterData: ", tostring(stStageEnterData))
  if self.m_reqEnterBattleTimer then
    TimeService:KillTimer(self.m_reqEnterBattleTimer)
    self.m_reqEnterBattleTimer = nil
  end
  local levelType = stStageEnterData.iStageType
  local levelID = stStageEnterData.iStageId
  self:EnterBattle(levelType, levelID, false)
end

function LevelManager:OnStageEnterChallengeFail(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  if self.m_reqEnterBattleTimer then
    TimeService:KillTimer(self.m_reqEnterBattleTimer)
    self.m_reqEnterBattleTimer = nil
  end
  local iErrorCode = msg.rspcode
  if iErrorCode == 1172 then
    local commonTextStr = ConfigManager:GetCommonTextById(20023)
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, commonTextStr)
  else
    NetworkManager:OnRpcCallbackFail(msg)
  end
end

function LevelManager:OnPushPassStage(stPushPassStage, msg)
  if not stPushPassStage then
    return
  end
  local levelType = stPushPassStage.iStageType
  local levelHelper = self:GetLevelHelperByType(levelType)
  if levelHelper and levelHelper.FreshPassStageInfo then
    levelHelper:FreshPassStageInfo(stPushPassStage)
  end
  if ChannelManager:IsUsingQSDK() then
    local strStageId = tostring(stPushPassStage.iStageId)
    local eventName
    if strStageId == "1102030" then
      eventName = "event_6"
    elseif strStageId == "1102060" then
      eventName = "event_8"
    end
    if eventName then
      QSDKManager:ReportReYunEvent(eventName)
    end
  end
  self:broadcastEvent("eGameEvent_Level_PushPassStage", stPushPassStage)
end

function LevelManager:OnPushStageTimes(stPushStageTimes, msg)
  if not stPushStageTimes then
    return
  end
  local levelType = stPushStageTimes.iType
  local levelHelper = self:GetLevelHelperByType(levelType)
  if levelHelper and levelHelper.FreshLevelDailyTimes then
    local subType = stPushStageTimes.iSubType
    local times = stPushStageTimes.iTimes
    levelHelper:FreshLevelDailyTimes(subType, times)
    self:broadcastEvent("eGameEvent_Level_PushStageTimes", {levelType = levelType, subType = subType})
  end
end

function LevelManager:OnPushDungeonChapterData(stPushStageTimes, msg)
  self.m_levelEquipmentHelper:SetLevelDailyData(stPushStageTimes.iTimes, stPushStageTimes.mRotationLevelSubType)
end

function LevelManager:ReqStageMopUp(levelType, levelID, times)
  if not levelType then
    return
  end
  if not levelID then
    return
  end
  if not times then
    return
  end
  self:InitRestartBattle()
  local msg = MTTDProto.Cmd_Stage_MopUp_CS()
  msg.iStageType = levelType
  msg.iStageId = levelID
  msg.iMopTimes = times
  RPCS():Stage_MopUp(msg, handler(self, self.OnStageMopUpSC))
end

function LevelManager:OnStageMopUpSC(stStageMopUpData, msg)
  log.info("LevelManager OnStageMopUpSC stStageMopUpData: ", tostring(stStageMopUpData))
  local levelType = stStageMopUpData.iStageType
  local levelID = stStageMopUpData.iStageId
  local times = stStageMopUpData.iMopTimes
  local rewards = stStageMopUpData.vReward
  local exRewards = stStageMopUpData.vExtraReward
  self:broadcastEvent("eGameEvent_Level_MopUp", {
    levelType = levelType,
    levelID = levelID,
    times = times,
    rewards = rewards,
    extraReward = exRewards
  })
end

function LevelManager:InitRestartBattle()
  RoleManager:ClearOldLevel()
  RoleManager:ClearOldRoleExp()
  HangUpManager:ClearOldAFKLevel()
  HangUpManager:ClearOldAFKExp()
  RoleManager:CacheCurLevelAndExpAsOld()
  HangUpManager:CacheAFKLevelAndExpAsOld()
end

function LevelManager:CacheCurBattleInfo(levelType, levelID, isSim)
  if not levelType then
    return
  end
  if not levelID then
    return
  end
  self.m_curBattleLevelType = levelType
  self.m_curBattleLevelSubType = self:GetLevelSunType(levelType, levelID)
  self.m_curBattleLevelID = levelID
  self.m_isSim = isSim
end

function LevelManager:ClearCurBattleInfo()
  self.m_curBattleLevelType = nil
  self.m_curBattleLevelSubType = nil
  self.m_curBattleLevelID = nil
  self.m_isSim = nil
end

function LevelManager:GetEnterClientDataKeyByLevelType(levelType)
  if levelType == LevelManager.LevelType.MainLevel then
    return ClientDataManager.ClientKeyType.Level_MainEnter
  elseif levelType == LevelManager.LevelType.Tower then
    return ClientDataManager.ClientKeyType.Level_TowerEnter
  end
end

function LevelManager:GetUnlockSystemTypeByLevelType(levelType)
  if levelType == LevelManager.LevelType.MainLevel then
    return GlobalConfig.SYSTEM_ID.MainLevel
  elseif levelType == LevelManager.LevelType.Tower then
    return GlobalConfig.SYSTEM_ID.Tower
  elseif levelType == LevelManager.LevelType.Goblin then
    return GlobalConfig.SYSTEM_ID.Goblin
  elseif levelType == LevelManager.LevelType.Dungeon then
    return GlobalConfig.SYSTEM_ID.Dungeon
  end
end

function LevelManager:GetLevelCfgTableByType(levelType)
  local levelCfgTable = self.m_cacheLevelCfgTab[levelType]
  if not levelCfgTable then
    if levelType == LevelManager.LevelType.MainLevel then
      levelCfgTable = ConfigManager:GetConfigInsByName("MainLevel")
    elseif levelType == LevelManager.LevelType.Tower then
      levelCfgTable = ConfigManager:GetConfigInsByName("TribeTowerLevel")
    elseif levelType == LevelManager.LevelType.Dungeon then
      levelCfgTable = ConfigManager:GetConfigInsByName("DunLevel")
    else
      if levelType == LevelManager.LevelType.Goblin then
        levelCfgTable = ConfigManager:GetConfigInsByName("GoblinLevel")
      else
      end
    end
    self.m_cacheLevelCfgTab[levelType] = levelCfgTable
  end
  return levelCfgTable
end

function LevelManager:GetBackLobbyMainLevelParam()
  local levelType = self.m_curBattleLevelType
  if not levelType then
    return
  end
  if levelType ~= LevelManager.LevelType.MainLevel then
    return
  end
  if not self.m_curBattleLevelID then
    return
  end
  local chapterData = self.m_levelMainHelper:GetChapterDataByLevelID(self.m_curBattleLevelID)
  if not chapterData then
    return
  end
  local paramLevelSubType
  local chapterType = chapterData.chapterCfg.m_ChapterType
  if chapterType == LevelManager.ChapterType.Normal then
    paramLevelSubType = LevelManager.MainLevelSubType.MainStory
  elseif chapterType == LevelManager.ChapterType.Hard then
    paramLevelSubType = LevelManager.MainLevelSubType.HardLevel
  end
  local chapterIndex
  if self.m_curBattleLevelSubType == LevelManager.MainLevelSubType.ExLevel then
    chapterIndex = self.m_levelMainHelper:GetChapterIndexBySubType(paramLevelSubType, chapterData.chapterCfg.m_ChapterID)
  end
  return {
    levelSubType = paramLevelSubType,
    chapterIndex = chapterIndex,
    isCheckShowNewAnim = true
  }
end

function LevelManager:GetLevelHelperByType(levelType)
  if not levelType then
    return
  end
  if levelType == LevelManager.LevelType.MainLevel then
    return self.m_levelMainHelper
  elseif levelType == LevelManager.LevelType.Tower then
    return self.m_levelTowerHelper
  elseif levelType == LevelManager.LevelType.Goblin then
    return self.m_levelGoblinHelper
  else
    if levelType == LevelManager.LevelType.Dungeon then
      return self.m_levelEquipmentHelper
    else
    end
  end
end

function LevelManager:GetLevelMapID(levelType, levelID)
  local mapID
  local levelCfg = self:GetLevelCfgByTypeAndLevelID(levelType, levelID)
  if levelCfg and not levelCfg:GetError() then
    mapID = levelCfg.m_MapID
  end
  return mapID
end

function LevelManager:GetLevelName(levelType, levelID)
  local levelName
  if levelType == LevelManager.LevelType.MainLevel then
    local MainLevelIns = ConfigManager:GetConfigInsByName("MainLevel")
    local levelCfg = MainLevelIns:GetValue_ByLevelID(levelID)
    levelName = levelCfg.m_LevelName
  elseif levelType == LevelManager.LevelType.Tower then
    local TribeTowerLevelIns = ConfigManager:GetConfigInsByName("TribeTowerLevel")
    local levelCfg = TribeTowerLevelIns:GetValue_ByLevelID(levelID)
    levelName = levelCfg.m_LevelName
  elseif levelType == LevelManager.LevelType.Dungeon then
    local DunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")
    local levelCfg = DunLevelIns:GetValue_ByLevelID(levelID)
    levelName = levelCfg.m_mName
  else
    if levelType == LevelManager.LevelType.Goblin then
      local GoblinLevelIns = ConfigManager:GetConfigInsByName("GoblinLevel")
      local levelCfg = GoblinLevelIns:GetValue_ByLevelID(levelID)
      levelName = levelCfg.m_mName
    else
    end
  end
  return levelName
end

function LevelManager:GetAssignLevelParams(levelType, levelID)
  if levelType == nil then
    levelType = self.m_curBattleLevelType
  end
  if levelID == nil then
    levelID = self.m_curBattleLevelID
  end
  if not levelType or not levelID then
    return
  end
  local levelSubType = self:GetLevelSunType(levelType, levelID)
  if levelType == LevelManager.LevelType.Dungeon then
    return {
      levelType,
      levelSubType,
      0,
      levelID
    }
  end
  local tempLevelHelper = self:GetLevelHelperByType(levelType)
  if not tempLevelHelper then
    return
  end
  if not tempLevelHelper.GetAssignLevelParams then
    return
  end
  return tempLevelHelper:GetAssignLevelParams(levelSubType, levelID)
end

function LevelManager:GetLevelMainHelper()
  return self.m_levelMainHelper
end

function LevelManager:GetLevelTowerHelper()
  return self.m_levelTowerHelper
end

function LevelManager:GetLevelGoblinHelper()
  return self.m_levelGoblinHelper
end

function LevelManager:GetLevelEquipmentHelper()
  return self.m_levelEquipmentHelper
end

function LevelManager:IsLevelHavePass(levelType, levelID)
  if levelType == LevelManager.LevelType.MainLevel then
    return self.m_levelMainHelper:IsLevelHavePass(levelID)
  elseif levelType == LevelManager.LevelType.Tower then
    return self.m_levelTowerHelper:IsLevelHavePass(levelID)
  elseif levelType == LevelManager.LevelType.Dungeon then
    return self.m_levelEquipmentHelper:IsLevelHavePass(levelID)
  elseif levelType == LevelManager.LevelType.Goblin then
    return self.m_levelGoblinHelper:IsLevelHavePass(levelID)
  end
end

function LevelManager:PushInnerGameData(levelType, levelID, isSim)
  local subType = self:GetLevelSunType(levelType, levelID)
  local towerAutoBattle = false
  if levelType == LevelManager.LevelType.Tower and self.m_towerAutoBattleEffective then
    towerAutoBattle = LocalDataManager:GetIntSimple("Tower_Auto_Battle", 0) == 1
    self.m_towerAutoBattleEffective = false
  end
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = subType or 0,
    levelID = levelID or 0,
    isSim = isSim or false,
    heroList = HeroManager:GetHeroServerList(),
    towerAutoBattle = towerAutoBattle
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
  RoleManager:ClearOldLevel()
  RoleManager:ClearOldRoleExp()
  HangUpManager:ClearOldAFKLevel()
  HangUpManager:ClearOldAFKExp()
  RoleManager:CacheCurLevelAndExpAsOld()
  HangUpManager:CacheAFKLevelAndExpAsOld()
end

function LevelManager:BeforeEnterBattle(levelType, levelID, isSim)
  LevelManager.super.BeforeEnterBattle(self)
  if not levelType or not levelID then
    return
  end
  self:PushInnerGameData(levelType, levelID, isSim)
  self:CacheCurBattleInfo(levelType, levelID, isSim)
end

function LevelManager:EnterBattle(levelType, levelID, isSim)
  if not levelType or not levelID then
    return
  end
  local mapID = self:GetLevelMapID(levelType, levelID)
  if not mapID then
    return
  end
  self:BeforeEnterBattle(levelType, levelID, isSim)
  self:EnterPVEBattle(mapID)
end

function LevelManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID, damage)
  log.info("LevelManager OnBattleEnd isSuc: ", tostring(isSuc))
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    local result = isSuc
    stageFinishChallengeSc = stageFinishChallengeSc or {}
    local levelType = self.m_isSim and self.m_curBattleLevelType or stageFinishChallengeSc.iFightType
    local levelID = self.m_isSim and self.m_curBattleLevelID or stageFinishChallengeSc.iStageId
    local areaId = CS.BattleGlobalManager.Instance:GetSaveInt(CS.LogicDefine.IntVariableType.BattleAreaID)
    local mapID = CS.BattleGlobalManager.Instance:GetSaveInt(CS.LogicDefine.IntVariableType.BattleWorldID)
    if result then
      local stFinishChallengeInfoSC = stageFinishChallengeSc.stFinishChallengeInfoSC or {}
      local rewardData = stFinishChallengeInfoSC.vReward
      local extraRewardData = stFinishChallengeInfoSC.vExtraReward
      if levelType == LevelManager.LevelType.Dungeon then
        local damageNum = self.m_isSim and damage or self.m_levelEquipmentHelper:GetLevelDamageByLevelID(levelID)
        StackFlow:Push(UIDefines.ID_FORM_BOSSBATTLEVICTORY, {
          levelType = levelType,
          levelID = levelID,
          rewardData = rewardData,
          extraReward = extraRewardData,
          isSim = self.m_isSim,
          damageNum = damageNum,
          showHeroID = randomShowHeroID
        })
      else
        StackFlow:Push(UIDefines.ID_FORM_BATTLEVICTORY, {
          levelType = levelType,
          levelID = levelID,
          rewardData = rewardData,
          extraReward = extraRewardData,
          showHeroID = randomShowHeroID
        })
      end
    else
      StackFlow:Push(UIDefines.ID_FORM_BATTLEDEFEAT, {
        levelType = levelType,
        levelID = levelID,
        areaId = areaId,
        mapID = mapID
      })
    end
  end
end

function LevelManager:OnBackLobby(fCB)
  local formStr = "Form_Hall"
  if self.m_curBattleLevelType == LevelManager.LevelType.MainLevel then
    self:LoadLevelMapScene(function()
      log.info("OnBackLobby LevelMap LoadBack")
      StackFlow:Push(UIDefines.ID_FORM_LEVELMAIN, self:GetBackLobbyMainLevelParam())
      formStr = "Form_LevelMain"
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end, true)
  else
    self:BackMainCityScene(function()
      log.info("OnBackLobby MainCity LoadBack")
      if self.m_curBattleLevelType == LevelManager.LevelType.Tower then
        local isInOpen = self.m_levelTowerHelper:IsLevelSubTypeInOpen(self.m_curBattleLevelSubType)
        if isInOpen == true then
          StackFlow:Push(UIDefines.ID_FORM_TOWER, {
            subType = self.m_curBattleLevelSubType or LevelManager.TowerLevelSubType.Main
          })
          formStr = "Form_Tower"
        else
          StackFlow:Push(UIDefines.ID_FORM_TOWERCHOOSE)
          formStr = "Form_TowerChoose"
        end
      elseif self.m_curBattleLevelType == LevelManager.LevelType.Dungeon then
        local isToday, tempChapterIndex = self.m_levelEquipmentHelper:CheckIsTodayBossByLevelID(self.m_curBattleLevelID)
        if not isToday or not tempChapterIndex then
          StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE)
          formStr = "Form_EquipmentCopyMainChoose"
        else
          StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAIN, {
            chapterIndex = tempChapterIndex,
            createBoss = CS.GameQualityManager.DestroyBossChapterInBattle
          })
          formStr = "Form_EquipmentCopyMain"
        end
      elseif self.m_curBattleLevelType == LevelManager.LevelType.Goblin then
        StackFlow:Push(UIDefines.ID_FORM_MATERIALSMAIN, {
          levelID = self.m_curBattleLevelID
        })
        formStr = "Form_MaterialsMain"
      else
        StackFlow:Push(UIDefines.ID_FORM_HALL)
        formStr = "Form_Hall"
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end, true)
  end
end

function LevelManager:BackMainCityScene(backFun, bHideLoading)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc and backFun then
      backFun()
    end
  end, bHideLoading)
end

function LevelManager:GetLevelSunType(levelType, levelID)
  local level_subtype = 0
  local levelCfg = self:GetLevelCfgByTypeAndLevelID(levelType, levelID)
  if levelCfg and not levelCfg:GetError() then
    level_subtype = levelCfg.m_LevelSubType
  end
  return level_subtype
end

function LevelManager:GetLevelCfgByTypeAndLevelID(levelType, levelID)
  if not levelType then
    return
  end
  if not levelID then
    return
  end
  local levelCfgTab = self:GetLevelCfgTableByType(levelType)
  if not levelCfgTab then
    return
  end
  return levelCfgTab:GetValue_ByLevelID(levelID)
end

function LevelManager:CheckEnterFirstStoryLevel()
  if not self.m_levelMainHelper then
    return false
  end
  local isFirstPass, firstLevelID = self.m_levelMainHelper:IsFirstLevelHavePass()
  if isFirstPass == false then
    self:ReqStageEnterChallenge(LevelManager.LevelType.MainLevel, firstLevelID)
    return true
  end
  return false
end

function LevelManager:IsLevelEntryHaveRedDot(levelType)
  local unlockSystemType = self:GetUnlockSystemTypeByLevelType(levelType)
  if not unlockSystemType then
    return
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(unlockSystemType)
  if isOpen ~= true then
    return
  end
  local levelHelper = self:GetLevelHelperByType(levelType)
  if not levelHelper then
    return
  end
  if levelHelper.IsAllLevelPass and levelHelper:IsAllLevelPass() == true then
    return 0
  end
  if levelType == LevelManager.LevelType.Goblin then
    return self.m_levelGoblinHelper:IsHaveRedDot(LevelManager.GoblinSubType.Skill)
  elseif levelType == LevelManager.LevelType.Tower then
    return self.m_levelTowerHelper:IsHaveRedDot()
  elseif levelType == LevelManager.LevelType.Dungeon then
    return self.m_levelEquipmentHelper:IsHaveRedDot()
  else
    local clientDataKey = self:GetEnterClientDataKeyByLevelType(levelType)
    if not clientDataKey then
      return
    end
    local enterTimerStr = ClientDataManager:GetClientValueStringByKey(clientDataKey)
    local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
    if TimeUtil:IsCurDayTime(enterTimer) == true then
      return 0
    else
      return 1
    end
  end
end

function LevelManager:CheckSetEnterTimer(levelType)
  local clientDataKey = self:GetEnterClientDataKeyByLevelType(levelType)
  if not clientDataKey then
    return
  end
  local levelHelper = self:GetLevelHelperByType(levelType)
  if not levelHelper then
    return
  end
  if levelHelper:IsAllLevelPass() == true then
    return
  end
  local enterTimerStr = ClientDataManager:GetClientValueStringByKey(clientDataKey)
  local enterTimer = TimeUtil:ServerTimeStrToServerTimeSec(enterTimerStr) or 0
  if TimeUtil:IsCurDayTime(enterTimer) == true then
    return
  end
  local curServerTime = TimeUtil:GetServerTimeS()
  local curServerTimeStr = TimeUtil:ServerTimerToServerString(curServerTime)
  ClientDataManager:SetClientValue(clientDataKey, curServerTimeStr)
end

function LevelManager:GetMainLevelCfgById(levelId)
  local MainLevelIns = ConfigManager:GetConfigInsByName("MainLevel")
  local levelCfg = MainLevelIns:GetValue_ByLevelID(levelId)
  if levelCfg:GetError() then
    log.error("LevelManager GetMainLevelCfgById  id  " .. tostring(levelId))
    return
  end
  return levelCfg
end

function LevelManager:IsLevelChapterTaskHaveRedDot(chapterID)
  if not chapterID then
    return
  end
  local isHaveCanReceive = self.m_levelMainHelper:IsChapterProgressTaskCanReceive(chapterID)
  if isHaveCanReceive == true then
    return 1
  else
    return 0
  end
end

function LevelManager:CheckSetSubTowerDailyEnterTime(subLevelType)
  if not subLevelType then
    return
  end
  self.m_levelTowerHelper:CheckSetSubTowerDailyEnterTime(subLevelType)
  self:broadcastEvent("eGameEvent_Level_SetEnterTime")
end

function LevelManager:IsLevelSubTowerHaveRedDot(subTowerType)
  if not subTowerType then
    return 0
  end
  return self.m_levelTowerHelper:IsSubTowerHaveRedDot(subTowerType) or 0
end

function LevelManager:SetDebugLevelData()
  local inputLevelData = {
    levelType = 0,
    levelSubType = 0,
    levelID = 0,
    heroList = HeroManager:GetHeroServerList()
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function LevelManager:GetHeroModifyCfg(heroModify)
  local HeroModifyIns = ConfigManager:GetConfigInsByName("HeroModify")
  local heroModifyCfg = HeroModifyIns:GetValue_ByID(heroModify)
  if heroModifyCfg:GetError() then
    log.error("LevelManager GetHeroModifyCfg  id  " .. tostring(heroModify))
    return
  end
  return heroModifyCfg
end

function LevelManager:GetMainlevelNextId()
  if self.m_levelMainHelper then
    return self.m_levelMainHelper:GetLastPassLevelIDBySubType(LevelManager.MainLevelSubType.MainStory)
  end
  return 0
end

function LevelManager:GetBattleGlobalEffectCfgById(id)
  local BattleGlobalEffectIns = ConfigManager:GetConfigInsByName("BattleGlobalEffect")
  local cfg = BattleGlobalEffectIns:GetValue_ByID(id)
  if cfg:GetError() then
    log.error("LevelManager GetBattleGlobalEffectCfgById  id  " .. tostring(id))
    return
  end
  return cfg
end

function LevelManager:SetTowerAutoBattleEffective(effective)
  self.m_towerAutoBattleEffective = effective
end

return LevelManager
