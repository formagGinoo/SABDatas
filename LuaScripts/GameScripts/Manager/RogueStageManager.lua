local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local RogueStageManager = class("RogueStageManager", BaseLevelManager)
RogueStageManager.DragRectType = {
  BgGrid = 1,
  TempPos = 2,
  ItemList = 3,
  Other = 4,
  Delete = 5
}
RogueStageManager.RogueStageItemType = {
  Material = 1,
  Product = 2,
  BgGridExpand = 3
}
RogueStageManager.RogueStageItemSubType = {
  CommonMaterial = 101,
  CommonMap = 102,
  ExclusiveMap = 103,
  CharacterEquip = 201,
  CommonPassive = 202,
  CommonActive = 203,
  ExpandItem = 301
}
RogueStageManager.RegionTypeSort = {Normal = 1, Exclusive = 2}
RogueStageManager.HandBookType = {
  Exclusive = 1,
  Normal = 2,
  Material = 3
}

function RogueStageManager:OnCreate()
end

function RogueStageManager:OnInitNetwork()
  RPCS():Listen_Push_Rogue_FinishChallenge(handler(self, self.OnPushFightData), "RogueStageManager")
end

function RogueStageManager:OnAfterInitConfig()
  self.m_levelRogueStageHelper = require("Manager/ManagerPlus/LevelRogueStageHelper").new()
  self:InitGlobalCfg()
end

function RogueStageManager:OnInitMustRequestInFetchMore()
  self:ReqRogueGetDataCS()
end

function RogueStageManager:InitGlobalCfg()
  RogueStageManager.BattleType = MTTDProto.FightType_Rogue
  RogueStageManager.BattleSubType = MTTDProto.RogueSubFightType_Fight
end

function RogueStageManager:OnDailyReset()
  self:ReqRogueGetDataCS()
end

function RogueStageManager:OnPushFightData(stData, msg)
  self.m_levelRogueStageHelper:UpdateFinishChallengePushData(stData)
  self:broadcastEvent("eGameEvent_RogueHandBookItem_StateChange")
  self:CheckRedDot()
end

function RogueStageManager:ReqRogueGetDataCS()
  local stageGetListCSMsg = MTTDProto.Cmd_Rogue_GetData_CS()
  RPCS():Rogue_GetData(stageGetListCSMsg, handler(self, self.OnRogueGetDataSC))
end

function RogueStageManager:OnRogueGetDataSC(stData, msg)
  self.m_levelRogueStageHelper:UpdateRogueStageData(stData)
  self:CheckRedDot()
end

function RogueStageManager:ReqRogueUnlockTech(techID)
  if not techID then
    return
  end
  local msg = MTTDProto.Cmd_Rogue_UnlockTech_CS()
  msg.iTechId = techID
  RPCS():Rogue_UnlockTech(msg, handler(self, self.OnRogueUnlockTechSC))
end

function RogueStageManager:OnRogueUnlockTechSC(stRogueUnlock, msg)
  if not stRogueUnlock then
    return
  end
  local levelRogueStageHelper = self:GetLevelRogueStageHelper()
  levelRogueStageHelper:FreshTechUnlockTime(stRogueUnlock.iTechId, stRogueUnlock.iUnlockTime)
  self:broadcastEvent("eGameEvent_RogueStage_ActiveTreeNode", {
    techID = stRogueUnlock.iTechId
  })
  self:CheckRedDot()
end

function RogueStageManager:ReqRogueTakeRewardCS()
  local takeRewardCSMsg = MTTDProto.Cmd_Rogue_TakeReward_CS()
  RPCS():Rogue_TakeReward(takeRewardCSMsg, handler(self, self.OnRogueTakeRewardSC))
end

function RogueStageManager:OnRogueTakeRewardSC(stData, msg)
  self.m_levelRogueStageHelper:UpdateTakenReward(stData)
  local vReward = stData.vReward
  if stData.vActivityReward then
    for _, v in ipairs(stData.vActivityReward) do
      table.insert(vReward, v)
    end
  end
  if vReward and next(vReward) then
    utils.popUpRewardUI(vReward)
  end
  self:broadcastEvent("eGameEvent_RogueStage_TakeReward")
  self:CheckRedDot()
end

function RogueStageManager:CheckRedDot()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueHandBookEntry,
    count = self.m_levelRogueStageHelper:CheckRogueHandBookEntryReddot()
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueRewardEntry,
    count = self:IsHaveRogueRewardCanGet()
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueTechEntry,
    count = self.m_levelRogueStageHelper:IsRogueTechCanUnlock()
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueDailyRedDot,
    count = self:CheckDailyRedPoint()
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueNewStage,
    count = self:IsRogueHaveNewStage()
  })
end

function RogueStageManager:GetLevelRogueStageHelper()
  return self.m_levelRogueStageHelper
end

function RogueStageManager:ResetRogueBagData()
  if self.m_levelRogueStageHelper then
    self.m_levelRogueStageHelper:SetRogueBagData()
  end
end

function RogueStageManager:GetFightHeros()
  local heroIdList = {}
  local heros = CS.BattleGlobalManager.Instance:GetFightHeros()
  if not utils.isNull(heros) then
    for i, v in pairs(heros) do
      heroIdList[#heroIdList + 1] = v
    end
  end
  return heroIdList
end

function RogueStageManager:StartEnterBattle(levelType, levelID)
  if not levelType then
    levelType = RogueStageManager.BattleType
    return
  end
  local mapID = self:GetLevelMapID(levelType, levelID)
  if not mapID then
    return
  end
  self:BeforeEnterBattle(levelType, levelID)
  self:EnterPVEBattle(mapID)
end

function RogueStageManager:BeforeEnterBattle(levelType, levelID)
  RogueStageManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType,
    levelSubType = RogueStageManager.BattleSubType,
    levelID = levelID,
    heroList = HeroManager:GetHeroServerList(),
    monsters = self.m_levelRogueStageHelper:GetStageInfoById(levelID).mDailyMonster,
    techNodes = self.m_levelRogueStageHelper:GetAllActiveTechIDList(),
    dailyRewardLevel = self.m_levelRogueStageHelper:GetDailyRewardLevel()
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function RogueStageManager:GetLevelMapID(levelType, levelID)
  return self.m_levelRogueStageHelper:GetStageMapIdById(levelID)
end

function RogueStageManager:IsLevelHavePass(levelType, levelID)
  return self.m_levelRogueStageHelper:IsLevelHavePass(levelID)
end

function RogueStageManager:OnBattleEnd(isSuc, finishChallengeSc, finishErrorCode, randomShowHeroID)
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    local iErrorCode = msg.rspcode
    log.error("Message Error Code: ", iErrorCode)
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    finishChallengeSc = finishChallengeSc or {}
    local param = {
      levelType = finishChallengeSc.iFightType,
      levelID = finishChallengeSc.stFinishChallengeInfoSC.stVerifyInfo.iFightId,
      iScore = finishChallengeSc.iScore,
      showHeroID = randomShowHeroID
    }
    StackFlow:Push(UIDefines.ID_FORM_ROGUEBATTLEVICTORY, param)
  end
end

function RogueStageManager:OnBackLobby(fCB)
  local formStr
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      formStr = "Form_Hall"
      StackFlow:Push(UIDefines.ID_FORM_HALL)
      local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.RogueStage)
      if isOpen then
        formStr = "Form_RogueStageMain"
        StackFlow:Push(UIDefines.ID_FORM_ROGUESTAGEMAIN)
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end, true)
end

function RogueStageManager:EnterNextBattle(levelType, ...)
end

function RogueStageManager:FromBattleToHall()
  self:ExitBattle()
end

function RogueStageManager:GetAssignLevelParams()
  return {
    RogueStageManager.BattleType,
    RogueStageManager.BattleSubType,
    0,
    0
  }
end

function RogueStageManager:GetDownloadResourceExtra(levelType)
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = "Form_RogueChose",
    eType = DownloadManager.ResourcePackageType.UI
  }
  vPackage[#vPackage + 1] = {
    sName = "Form_RogueBattleVictory",
    eType = DownloadManager.ResourcePackageType.UI
  }
  vPackage[#vPackage + 1] = {
    sName = "Form_RogueItemTips",
    eType = DownloadManager.ResourcePackageType.UI
  }
  vPackage[#vPackage + 1] = {
    sName = "Form_RogueLocalBag",
    eType = DownloadManager.ResourcePackageType.UI
  }
  return vPackage, nil
end

function RogueStageManager:IsRogueHandBookItemHaveNew(params)
  return self.m_levelRogueStageHelper:IsRogueHandBookItemHaveNew(params)
end

function RogueStageManager:IsRogueHandBookTabHaveNew(iHandBookType)
  return self.m_levelRogueStageHelper:IsRogueHandBookTabHaveNew(iHandBookType)
end

function RogueStageManager:IsHaveRogueRewardCanGet()
  return self.m_levelRogueStageHelper:IsHaveRewards() == true and 1 or 0
end

function RogueStageManager:IsRogueTechCanUnlock()
  return self.m_levelRogueStageHelper:IsRogueTechCanUnlock()
end

function RogueStageManager:IsRogueHaveNewStage()
  return self.m_levelRogueStageHelper:IsHaveNewStage()
end

function RogueStageManager:CheckRogueEntryHaveRedPoint()
  return self.m_levelRogueStageHelper:CheckRogueEntryHaveRedPoint()
end

function RogueStageManager:SetDailyRedPointFlag()
  local checkFlag = false
  if LocalDataManager:GetIntSimple("Red_Point_RogueStage", 0) ~= TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()) then
    checkFlag = true
  end
  LocalDataManager:SetIntSimple("Red_Point_RogueStage", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
  if checkFlag then
    self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
      redDotKey = RedDotDefine.ModuleType.RogueDailyRedDot,
      count = self:CheckDailyRedPoint()
    })
  end
  self:broadcastEvent("eGameEvent_RogueStage_RefreshDailyDot")
end

function RogueStageManager:CheckDailyRedPoint()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.RogueStage)
  if not openFlag or TimeUtil:GetServerTimeS() < LocalDataManager:GetIntSimple("Red_Point_RogueStage", 0) then
    return 0
  end
  return 1
end

function RogueStageManager:CheckNewStageRedPoint(stageId)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.RogueStage)
  if not openFlag or LocalDataManager:GetIntSimple("Red_Point_RogueStage_" .. stageId, 0) ~= 0 then
    return 0
  end
  return 1
end

function RogueStageManager:SetNewStageRedPointFlag(stageId)
  if not stageId then
    return
  end
  LocalDataManager:SetIntSimple("Red_Point_RogueStage_" .. stageId, stageId)
  self:broadcastEvent("eGameEvent_RogueStage_RefreshDailyDot")
end

return RogueStageManager
