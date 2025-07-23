local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local LevelHeroLamiaActivityManager = class("LevelHeroLamiaActivityManager", BaseLevelManager)
LevelHeroLamiaActivityManager.LevelDegree = {Normal = 1, Hard = 2}
LevelHeroLamiaActivityManager.EnterLevelType = {Story = 1, Normal = 2}

function LevelHeroLamiaActivityManager:OnCreate()
  self.m_curBattleType = nil
  self.m_curActivityID = nil
  self.m_curBattleLevelID = nil
  self.m_curLevelHelper = nil
  self.m_ActivitySubInfoIns = nil
  self.m_ActivityMainInfoIns = nil
  self.m_cacheEnterNormalSubIDList = nil
end

function LevelHeroLamiaActivityManager:OnInitNetwork()
  RPCS():Listen_Push_Lamia_Stage(handler(self, self.OnPushLamiaStage), "LevelHeroLamiaActivityManager")
end

function LevelHeroLamiaActivityManager:OnAfterFreshData()
  self:InitGlobalCfg()
end

function LevelHeroLamiaActivityManager:OnUpdate(dt)
end

function LevelHeroLamiaActivityManager:OnDailyReset()
  self:broadcastEvent("eGameEvent_Level_Lamia_DailyReset")
end

function LevelHeroLamiaActivityManager:InitLevelData(stActDataList)
  if not stActDataList then
    return
  end
  local levelHelper = self:GetLevelHelper()
  if not levelHelper then
    return
  end
  for _, tempLamiaData in ipairs(stActDataList) do
    local actID = tempLamiaData.iActId
    local lamiaStageTab = tempLamiaData.mStageStat
    for subActivityID, lamiaStageInfo in pairs(lamiaStageTab) do
      levelHelper:FreshStageInfo(actID, subActivityID, lamiaStageInfo)
    end
  end
end

function LevelHeroLamiaActivityManager:OnPushLamiaStage(stPushStage, msg)
  if not stPushStage then
    return
  end
  local levelHelper = self:GetLevelHelper()
  if not levelHelper then
    return
  end
  local actID = stPushStage.iActId
  local subActivityID = stPushStage.iSubActId
  local stageInfo = stPushStage.stStage
  levelHelper:FreshStageInfo(actID, subActivityID, stageInfo)
  self:broadcastEvent("eGameEvent_Level_Lamia_StageFresh")
end

function LevelHeroLamiaActivityManager:ReqLamiaStageSweep(activityID, levelID, times)
  if not activityID then
    return
  end
  if not levelID then
    return
  end
  times = times or 1
  local msg = MTTDProto.Cmd_Lamia_Stage_Sweep_CS()
  msg.iActId = activityID
  msg.iStageId = levelID
  msg.iTimes = times
  RPCS():Lamia_Stage_Sweep(msg, handler(self, self.OnLamiaStageSweepSC))
end

function LevelHeroLamiaActivityManager:OnLamiaStageSweepSC(stLamiaStageSweepData, msg)
  if not stLamiaStageSweepData then
    return
  end
  local activityID = stLamiaStageSweepData.iActId
  local levelType = HeroActivityManager:GetLevelTypeByActivityID(activityID)
  if levelType ~= LevelHeroLamiaActivityManager.LevelType.Lamia then
    return
  end
  local levelHelper = self:GetLevelHelper()
  if not levelHelper then
    return
  end
  local levelID = stLamiaStageSweepData.iStageId
  local times = stLamiaStageSweepData.iPassedTimesDaily
  local levelCfg = levelHelper:GetLevelCfgByID(levelID)
  local subActivityID = levelCfg.m_ActivitySubID
  levelHelper:FreshStageTimes(activityID, subActivityID, times)
  self:broadcastEvent("eGameEvent_Level_Lamia_Sweep", {
    activityID = activityID,
    subActivityID = subActivityID,
    levelID = levelID,
    reward = stLamiaStageSweepData.vAward,
    extraReward = stLamiaStageSweepData.vExtraAward
  })
end

function LevelHeroLamiaActivityManager:InitGlobalCfg()
  LevelHeroLamiaActivityManager.LevelType = {
    Lamia = MTTDProto.FightType_Lamia
  }
  self.m_ActivitySubInfoIns = ConfigManager:GetConfigInsByName("ActivitySubInfo")
  self.m_ActivityMainInfoIns = ConfigManager:GetConfigInsByName("ActivityMainInfo")
end

function LevelHeroLamiaActivityManager:GetPrefabParamByStr(params)
  if not params then
    return
  end
  local paramTab = {}
  local paramLen = params.Length
  if paramLen <= 0 then
    return paramTab
  end
  for i = 0, paramLen - 1 do
    local tempParam = params[i]
    local keyStr = tempParam[0]
    local paramStr = tempParam[1]
    paramTab[keyStr] = paramStr
  end
  return paramTab
end

function LevelHeroLamiaActivityManager:GetBackLobbyFormAndParam()
  local formPanelStr, formUIDefineID, paramTab = "Form_Hall", UIDefines.ID_FORM_HALL
  if not self.m_curBattleType then
    return formPanelStr, formUIDefineID, paramTab
  end
  local levelCfg = self:GetLevelCfgByID(self.m_curBattleLevelID)
  if not levelCfg then
    return formPanelStr, formUIDefineID, paramTab
  end
  local subActivityID = levelCfg.m_ActivitySubID
  local activitySubInfoCfg = self.m_ActivitySubInfoIns:GetValue_ByActivitySubID(subActivityID)
  if activitySubInfoCfg:GetError() == true then
    return formPanelStr, formUIDefineID, paramTab
  end
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(self.m_curActivityID, subActivityID)
  if isOpen ~= true then
    return formPanelStr, formUIDefineID, paramTab
  end
  formPanelStr = activitySubInfoCfg.m_Prefab
  formUIDefineID = UIDefines["ID_" .. string.upper(formPanelStr)]
  paramTab = self:GetPrefabParamByStr(activitySubInfoCfg.m_PrefabParam)
  return formPanelStr, formUIDefineID, paramTab
end

function LevelHeroLamiaActivityManager:GetActivitySubTypeByID(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  local subActivityID = levelCfg.m_ActivitySubID
  local activitySubInfoCfg = self.m_ActivitySubInfoIns:GetValue_ByActivitySubID(subActivityID)
  if activitySubInfoCfg:GetError() == true then
    return
  end
  return activitySubInfoCfg.m_ActivitySubType
end

function LevelHeroLamiaActivityManager:GetEnterSubActivityList()
  if not self.m_cacheEnterNormalSubIDList then
    local subActivityIDList
    local clientDataStr = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Level_Lamia_Enter)
    if clientDataStr == nil or clientDataStr == "" then
      subActivityIDList = {}
    else
      subActivityIDList = string.split(clientDataStr, "|")
    end
    self.m_cacheEnterNormalSubIDList = subActivityIDList
  end
  return self.m_cacheEnterNormalSubIDList
end

function LevelHeroLamiaActivityManager:IsSubActHaveEnter(subActivityID)
  if not subActivityID then
    return
  end
  local subActivityIDList = self:GetEnterSubActivityList()
  for _, tempIDStr in ipairs(subActivityIDList) do
    local tempID = tonumber(tempIDStr)
    if tempID == subActivityID then
      return true
    end
  end
  return false
end

function LevelHeroLamiaActivityManager:InsertEnterSubActID(subActivityID)
  if not subActivityID then
    return
  end
  local subActivityIDList = self:GetEnterSubActivityList()
  subActivityIDList[#subActivityIDList + 1] = subActivityID
  self.m_cacheEnterNormalSubIDList = subActivityIDList
end

function LevelHeroLamiaActivityManager:GetEnterSubActivityFormatStr()
  local subActivityIDList = self:GetEnterSubActivityList()
  local enterSubActivityTab = {}
  for i, v in ipairs(subActivityIDList) do
    if i == 1 then
      enterSubActivityTab[#enterSubActivityTab + 1] = tostring(v)
    else
      enterSubActivityTab[#enterSubActivityTab + 1] = "|"
      enterSubActivityTab[#enterSubActivityTab + 1] = tostring(v)
    end
  end
  if #enterSubActivityTab == 0 then
    return ""
  else
    return table.concat(enterSubActivityTab)
  end
end

function LevelHeroLamiaActivityManager:GetLevelHelper()
  local levelHelper = self.m_curLevelHelper
  if levelHelper == nil then
    levelHelper = require("Manager/ManagerPlus/HeroActivityHelper/LevelHeroActivityLamiaHelper").new()
    self.m_curLevelHelper = levelHelper
  end
  return levelHelper
end

function LevelHeroLamiaActivityManager:GetLevelCfgByID(levelID)
  local levelHelper = self:GetLevelHelper()
  if not levelHelper then
    return
  end
  if not levelHelper.GetLevelCfgByID then
    return
  end
  return levelHelper:GetLevelCfgByID(levelID)
end

function LevelHeroLamiaActivityManager:GetBattleLoadingUI(levelType, activityID, levelID)
  local uiName = self.super.GetBattleLoadingUI(levelType, activityID, levelID)
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return uiName
  end
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(levelCfg.m_ActivityID)
  if mainActInfoCfg and mainActInfoCfg.m_BattleLoadingPrefab ~= "" then
    uiName = mainActInfoCfg.m_BattleLoadingPrefab
  end
  return uiName
end

function LevelHeroLamiaActivityManager:GetAssignLevelParams(levelType, activityID, levelID)
  if levelType == nil then
    levelType = self.m_curBattleType
  end
  if levelID == nil then
    levelID = self.m_curBattleLevelID
  end
  local curActivitySubType = self:GetActivitySubTypeByID(levelID)
  return {
    levelType,
    curActivitySubType,
    0,
    levelID
  }
end

function LevelHeroLamiaActivityManager:GetLevelName(levelType, levelID)
  if levelType ~= LevelHeroLamiaActivityManager.LevelType.Lamia then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  return levelCfg.m_mLevelName
end

function LevelHeroLamiaActivityManager:IsSubActLeftTimesEntryHaveRedDot(subActivityID)
  if not subActivityID then
    return 0
  end
  local subInfoCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
  if not subInfoCfg then
    return 0
  end
  local activityID = subInfoCfg.m_ActivityID
  if not activityID then
    return 0
  end
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(activityID, subActivityID)
  if isOpen ~= true then
    return 0
  end
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("SubActLeftTimesEntry_Red_Point" .. activityID, 0)
  if bIsNewDay then
    return 1
  end
  return 0
end

function LevelHeroLamiaActivityManager:SetActivitySubEnter(subActivityID)
  if not subActivityID then
    return
  end
  local isHaveCacheEnter = self:IsSubActHaveEnter(subActivityID)
  if isHaveCacheEnter == true then
    return
  end
  self:InsertEnterSubActID(subActivityID)
  local formatStr = self:GetEnterSubActivityFormatStr()
  ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.Level_Lamia_Enter, formatStr)
  self:broadcastEvent("eGameEvent_Level_Lamia_SetSubActEnter")
end

function LevelHeroLamiaActivityManager:IsSubActEnterHaveRedDot(subActivityID)
  if not subActivityID then
    return 0
  end
  local subInfoCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
  if not subInfoCfg then
    return 0
  end
  local activityID = subInfoCfg.m_ActivityID
  if not activityID then
    return 0
  end
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(activityID, subActivityID)
  if isOpen ~= true then
    return 0
  end
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("SubActEnter_Red_Point" .. activityID, 0)
  if bIsNewDay then
    return 1
  end
  return 0
end

function LevelHeroLamiaActivityManager:StartEnterBattle(levelType, activityID, levelID)
  if not levelType then
    return
  end
  self.m_curBattleType = levelType
  self.m_curActivityID = activityID
  self.m_curBattleLevelID = levelID
  self:BeforeEnterBattle(levelType, activityID, levelID)
  local mapID = self:GetLevelMapID(levelType, activityID, levelID)
  self:EnterPVEBattle(mapID)
end

function LevelHeroLamiaActivityManager:BeforeEnterBattle(levelType, activityID, levelID)
  LevelHeroLamiaActivityManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType or 0,
    activityID = activityID or 0,
    levelID = levelID or 0,
    heroList = HeroManager:GetHeroServerList()
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function LevelHeroLamiaActivityManager:GetLevelMapID(levelType, activityID, levelID)
  if levelType ~= LevelHeroLamiaActivityManager.LevelType.Lamia then
    return
  end
  local levelCfg = self:GetLevelCfgByID(levelID)
  if not levelCfg then
    return
  end
  return levelCfg.m_MapID
end

function LevelHeroLamiaActivityManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID)
  log.info("LevelHeroLamiaActivityManager OnBattleEnd isSuc: ", tostring(isSuc))
  if finishErrorCode ~= nil and finishErrorCode ~= 0 and finishErrorCode ~= MTTD.Error_Lamia_StageTimeInvalid then
    local msg = {rspcode = finishErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    local result = isSuc
    local levelType = self.m_curBattleType
    local activityID = self.m_curActivityID
    if result then
      local firstReward, rewardData, extraReward
      if stageFinishChallengeSc and stageFinishChallengeSc.stFinishChallengeInfoSC then
        local stFinishChallengeInfoSC = stageFinishChallengeSc.stFinishChallengeInfoSC
        rewardData = stFinishChallengeInfoSC.vReward
        extraReward = stFinishChallengeInfoSC.vExtraReward
        firstReward = stFinishChallengeInfoSC.vFirstPassReward
      end
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_VICTORY, {
        levelType = levelType,
        activityID = activityID,
        levelID = self.m_curBattleLevelID,
        firstReward = firstReward,
        rewardData = rewardData,
        extraReward = extraReward,
        finishErrorCode = finishErrorCode,
        showHeroID = randomShowHeroID
      })
    else
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_DEFEAT, {
        levelType = levelType,
        activityID = activityID,
        levelID = self.m_curBattleLevelID,
        finishErrorCode = finishErrorCode
      })
    end
  end
end

function LevelHeroLamiaActivityManager:EnterNextBattle(levelType, ...)
end

function LevelHeroLamiaActivityManager:OnBackLobby(fCB)
  local formStr
  local formPanelStr, formUIDefineID, paramTab = self:GetBackLobbyFormAndParam()
  
  local function OnLoadFinish(isSuc)
    log.info("OnBackLobby MainCity LoadBack")
    formStr = formPanelStr
    StackFlow:Push(formUIDefineID, paramTab)
    if "Form_Activity102Dalcaro_DialogueMain" == formPanelStr then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(115)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(116)
    elseif "Form_Activity101Lamia_DialogueMain" == formPanelStr then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(58)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(93)
    end
    if fCB then
      fCB(formStr)
    end
    self:broadcastEvent("eGameEvent_ActExploreUIReady")
    self:ClearCurBattleInfo()
  end
  
  local levelCfg = self:GetLevelCfgByID(self.m_curBattleLevelID)
  if levelCfg then
    local iActID = levelCfg.m_ActivityID
    local cfg = HeroActivityManager:GetMainInfoByActID(iActID)
    if cfg and cfg.m_ActivityType == 2 and cfg.m_ExploreScene ~= "" then
      local scene = GameSceneManager:GetGameScene(GameSceneManager.SceneID.ActExplore)
      scene:OpenScene(cfg.m_ExploreScene, iActID, function()
        OnLoadFinish()
      end, true)
      return
    end
  end
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, OnLoadFinish, true)
end

function LevelHeroLamiaActivityManager:ClearCurBattleInfo()
  self.m_curBattleType = nil
  self.m_curActivityID = nil
  self.m_curBattleLevelID = nil
end

function LevelHeroLamiaActivityManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  self:ExitBattle()
end

return LevelHeroLamiaActivityManager
