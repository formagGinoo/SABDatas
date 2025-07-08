local BaseManager = require("Manager/Base/BaseManager")
local BattleFlowManager = class("BattleFlowManager", BaseManager)
BattleFlowManager.BattleStage = {
  Before = 1,
  InBattle = 2,
  Finish = 3
}
BattleFlowManager.PlotActionType = {
  Video = 1,
  TimeLine = 2,
  Dialog = 3,
  Black = 4,
  Wait = 5,
  AllPlayerCtrl = 6
}

function BattleFlowManager:OnCreate()
  self.m_BattleType = nil
  self.m_curBattleStage = nil
  self.m_baseRandomLoadInfo = nil
  self.m_assignRandomLoadInfo = nil
end

function BattleFlowManager:OnInitNetwork()
  self:InitGlobalCfg()
end

function BattleFlowManager:OnUpdate(dt)
end

function BattleFlowManager:InitGlobalCfg()
  BattleFlowManager.ArenaType = {
    Arena = MTTDProto.FightType_Arena
  }
  BattleFlowManager.ArenaSubType = {
    ArenaBattle = MTTDProto.FightMainSubType_OriginalPvp,
    ArenaDefense = MTTDProto.FightMainSubType_OriginalPvpDef
  }
end

function BattleFlowManager:InitRandomLoadInfo()
  local CineInLoadingIns = ConfigManager:GetConfigInsByName("CineInLoading")
  if not CineInLoadingIns then
    return
  end
  self.m_baseRandomLoadInfo = {}
  self.m_assignRandomLoadInfo = {}
  local allCineInLoadings = CineInLoadingIns:GetAll()
  for _, v in pairs(allCineInLoadings) do
    if v.m_Type == 1 then
      local tempCfg = {config = v, params = nil}
      self.m_baseRandomLoadInfo[#self.m_baseRandomLoadInfo + 1] = tempCfg
    elseif v.m_Type == 2 then
      local tempCfg = {
        config = v,
        params = utils.changeCSArrayToLuaTable(v.m_Data)
      }
      self.m_assignRandomLoadInfo[#self.m_assignRandomLoadInfo + 1] = tempCfg
    end
  end
end

function BattleFlowManager:GetAssignLevelParams(levelType, ...)
  local manager = self:GetManagerByBattleType(levelType or self.m_BattleType)
  if manager and manager.GetAssignLevelParams then
    return manager:GetAssignLevelParams(levelType, ...)
  end
end

function BattleFlowManager:GetManagerByBattleType(battleType)
  if battleType == BattleFlowManager.ArenaType.Arena then
    return ArenaManager
  elseif battleType == LevelHeroLamiaActivityManager.LevelType.Lamia then
    return LevelHeroLamiaActivityManager
  elseif battleType == PvpReplaceManager.LevelType.ReplacePVP then
    return PvpReplaceManager
  elseif battleType == PersonalRaidManager.FightType_SoloRaid then
    return PersonalRaidManager
  elseif battleType == GuildManager.FightType_AllianceBattle then
    return GuildManager
  elseif battleType == LegacyLevelManager.LevelType.LegacyLevel then
    return LegacyLevelManager
  elseif battleType == RogueStageManager.BattleType then
    return RogueStageManager
  elseif battleType == HuntingRaidManager.FightType_Hunting then
    return HuntingRaidManager
  else
    return LevelManager
  end
end

function BattleFlowManager:ClearCacheInfo()
  self.m_curBattleStage = nil
  self.m_backLobbyBackFun = nil
end

function BattleFlowManager:ChangeBattleStage(stage)
  if not stage then
    return
  end
  self.m_curBattleStage = stage
end

function BattleFlowManager:StartEnterBattle(levelType, ...)
  local vExtraParam = {
    ...
  }
  local cLevelManager = self:GetManagerByBattleType(levelType)
  local vPackage = {}
  local vResource = {}
  vPackage[1] = {
    sName = "Common",
    eType = DownloadManager.ResourcePackageType.Level
  }
  local iBattleWorldID = self:GetLevelMapID(levelType, table.unpack(vExtraParam))
  if iBattleWorldID then
    vPackage[#vPackage + 1] = {
      sName = tostring(iBattleWorldID),
      eType = DownloadManager.ResourcePackageType.Level
    }
  end
  local vHeroServerList = HeroManager:GetHeroServerList()
  for i = 1, #vHeroServerList do
    local iHeroBaseID = vHeroServerList[i].iHeroId
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
  local sBattleLoadingUIName = cLevelManager:GetBattleLoadingUI(levelType, table.unpack(vExtraParam))
  if sBattleLoadingUIName then
    vPackage[#vPackage + 1] = {
      sName = sBattleLoadingUIName,
      eType = DownloadManager.ResourcePackageType.UI
    }
  end
  local vBaseAllLoadingInfo = self:GetBaseAllLoadingInfo()
  for i = 1, #vBaseAllLoadingInfo do
    local sUITextureName = vBaseAllLoadingInfo[i].config.m_Picture
    vResource[#vResource + 1] = {
      sName = sUITextureName,
      eType = DownloadManager.ResourceType.UITexture
    }
  end
  local vAssignAllLoadingInfo = self:GetAssignAllLoadingInfo(levelType, table.unpack(vExtraParam))
  for i = 1, #vAssignAllLoadingInfo do
    local sUITextureName = vAssignAllLoadingInfo[i].config.m_Picture
    vResource[#vResource + 1] = {
      sName = sUITextureName,
      eType = DownloadManager.ResourceType.UITexture
    }
  end
  local vPackageExtra, vResourceExtra = cLevelManager:GetDownloadResourceExtra()
  if vPackageExtra ~= nil then
    for _, v in ipairs(vPackageExtra) do
      table.insert(vPackage, v)
    end
  end
  if vResourceExtra ~= nil then
    for _, v in ipairs(vResourceExtra) do
      table.insert(vResource, v)
    end
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download Level %s Complete: %s", tostring(levelType), tostring(ret)))
    self:ChangeBattleStage(BattleFlowManager.BattleStage.Before)
    self.m_BattleType = levelType
    cLevelManager:StartEnterBattle(levelType, table.unpack(vExtraParam))
  end
  
  local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewbieResourceCheckLevelID").m_Value)
  if LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iNewbieMainLevelID) then
    DownloadManager:DownloadResourceWithUI(vPackage, vResource, "Battle_" .. tostring(levelType) .. "_" .. tostring(iBattleWorldID), nil, nil, OnDownloadComplete)
  else
    OnDownloadComplete()
  end
end

function BattleFlowManager:OnBattleEnd(...)
  self:ChangeBattleStage(BattleFlowManager.BattleStage.Finish)
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.OnBattleEnd then
    manager:OnBattleEnd(...)
  end
end

function BattleFlowManager:OnBackLobby(fcB)
  if self.m_backLobbyBackFun then
    self.m_backLobbyBackFun(fcB)
    self:ClearCacheInfo()
    return
  end
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.OnBackLobby then
    manager:OnBackLobby(fcB)
  end
  self:ClearCacheInfo()
end

function BattleFlowManager:ReStartBattle(reStartArea)
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.ReStartBattle then
    manager:ReStartBattle(reStartArea)
  end
end

function BattleFlowManager:EnterNextBattle(levelType, ...)
  self:ChangeBattleStage(BattleFlowManager.BattleStage.Before)
  self.m_BattleType = levelType
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.EnterNextBattle then
    manager:EnterNextBattle(levelType, ...)
  end
end

function BattleFlowManager:OnBattleWaveEnd(...)
end

function BattleFlowManager:CheckEnterFirstStoryLevel()
  local isEnterFirst = LevelManager:CheckEnterFirstStoryLevel()
  if isEnterFirst then
    self.m_BattleType = LevelManager.LevelType.MainLevel
    self:ChangeBattleStage(BattleFlowManager.BattleStage.Before)
  end
  return isEnterFirst
end

function BattleFlowManager:EnterFirstStoryLevel(levelID)
  local isLevelPass = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, levelID)
  if isLevelPass then
    return false
  end
  LevelManager:ReqStageEnterChallenge(LevelManager.LevelType.MainLevel, levelID)
  self.m_BattleType = LevelManager.LevelType.MainLevel
  self:ChangeBattleStage(BattleFlowManager.BattleStage.Before)
  return true
end

function BattleFlowManager:IsLevelHavePass(levelID)
  local isLevelPass = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, levelID)
  return isLevelPass
end

function BattleFlowManager:FromBattleToHall()
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.FromBattleToHall then
    manager:FromBattleToHall()
  end
end

function BattleFlowManager:ExitBattle()
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.ExitBattle then
    manager:ExitBattle()
  end
end

function BattleFlowManager:GetLevelMapID(levelType, ...)
  local manager = self:GetManagerByBattleType(levelType)
  if manager and manager.GetLevelMapID then
    return manager:GetLevelMapID(levelType, ...)
  end
end

function BattleFlowManager:GetLevelName(levelType, ...)
  local levelName
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.GetLevelName then
    levelName = manager:GetLevelName(levelType, ...)
  end
  if levelName then
    return levelName
  end
  return ""
end

function BattleFlowManager:IsInBattle()
  local manager = self:GetManagerByBattleType(self.m_BattleType)
  if manager and manager.IsInBattle then
    return manager:IsInBattle()
  end
end

function BattleFlowManager:IsLevelEntryHaveRedDot(levelTypeTab)
  local redPoint = 0
  if type(levelTypeTab) == "table" then
    for i, v in pairs(levelTypeTab) do
      if v == BattleFlowManager.ArenaType.Arena then
        redPoint = redPoint + (ArenaManager:IsLevelEntryHaveRedDot(v) or 0)
      elseif v == LegacyLevelManager.LevelType.LegacyLevel then
        redPoint = redPoint + (LegacyLevelManager:IsLevelEntryHaveRedDot(v) or 0)
      else
        redPoint = redPoint + (LevelManager:IsLevelEntryHaveRedDot(v) or 0)
      end
    end
  elseif type(levelTypeTab) == "number" then
    if levelTypeTab == BattleFlowManager.ArenaType.Arena then
      redPoint = redPoint + (ArenaManager:IsLevelEntryHaveRedDot(levelTypeTab) or 0)
    elseif levelTypeTab == LegacyLevelManager.LevelType.LegacyLevel then
      redPoint = redPoint + (LegacyLevelManager:IsLevelEntryHaveRedDot(levelTypeTab) or 0)
    else
      redPoint = redPoint + (LevelManager:IsLevelEntryHaveRedDot(levelTypeTab) or 0)
    end
  end
  return redPoint
end

function BattleFlowManager:CheckSetEnterTimer(levelType)
  if levelType == BattleFlowManager.ArenaType.Arena then
    ArenaManager:CheckSetEnterTimer(levelType)
  else
    LevelManager:CheckSetEnterTimer(levelType)
  end
  self:broadcastEvent("eGameEvent_Level_SetEnterTime", levelType)
end

function BattleFlowManager:GetHeroAttrByParam(param)
  local heroID = param.iTemplateId
  local heroAttrTab = HeroManager:GetHeroAttr():GetHeroAttrByParam(heroID, ConvertLuaParam(param))
  local ret = {}
  ret.mHeroAttr = heroAttrTab
  return ret
end

function BattleFlowManager:GetHeroPowerByParam(param)
  local heroID = param.iTemplateId
  local power = HeroManager:GetHeroAttr():GetHeroPowerByParam(heroID, ConvertLuaParam(param))
  return power
end

function ConvertLuaParam(param)
  local luaParam = {}
  luaParam.iTemplateId = param.iTemplateId
  luaParam.iLevel = param.iLevel
  if param.iBreak and param.iBreak > 0 then
    luaParam.iBreak = param.iBreak
  end
  luaParam.ignoreBreak = param.ignoreBreak
  if param.iAttractRank and 0 < param.iAttractRank then
    luaParam.iAttractRank = param.iAttractRank
  end
  luaParam.ignoreAttractRank = param.ignoreAttractRank
  local equipParam
  if param.equipParam then
    for k, equipData in pairs(param.equipParam) do
      local tmp = {
        equipBaseId = equipData.iBaseId,
        level = equipData.iLevel,
        iOverloadHero = equipData.iOverloadHero
      }
      if equipParam == nil then
        equipParam = {}
      end
      equipParam[#equipParam + 1] = tmp
    end
  end
  luaParam.equipParam = equipParam
  luaParam.ignoreEquip = param.ignoreEquip
  luaParam.ignoreLegacy = param.ignoreLegacy
  local circulationTab
  if param.circulation then
    for k, v in pairs(param.circulation) do
      if circulationTab == nil then
        circulationTab = {}
      end
      circulationTab[#circulationTab + 1] = {ID = k, lv = v}
    end
  end
  luaParam.circulationParam = circulationTab
  luaParam.ignoreXunHuanShi = param.ignoreXunHuanShi
  return luaParam
end

function BattleFlowManager:GetBaseRandomLoadingInfo()
  local vBaseAllLoadingInfo = self:GetBaseAllLoadingInfo()
  if #vBaseAllLoadingInfo <= 0 then
    return
  end
  math.newrandomseed()
  local randomIndex = math.random(1, #vBaseAllLoadingInfo)
  return vBaseAllLoadingInfo[randomIndex].config
end

function BattleFlowManager:GetBaseAllLoadingInfo()
  if self.m_baseRandomLoadInfo == nil then
    self:InitRandomLoadInfo()
  end
  return self.m_baseRandomLoadInfo or {}
end

function BattleFlowManager:GetAssignRandomLoadingInfo()
  if not self.m_BattleType then
    return self:GetBaseRandomLoadingInfo()
  end
  local vAssignAllLoadingInfo = self:GetAssignAllLoadingInfo()
  if #vAssignAllLoadingInfo <= 0 then
    return self:GetBaseRandomLoadingInfo()
  end
  math.newrandomseed()
  local randomIndex = math.random(1, #vAssignAllLoadingInfo)
  return vAssignAllLoadingInfo[randomIndex].config
end

function BattleFlowManager:GetAssignAllLoadingInfo(levelType, ...)
  if self.m_assignRandomLoadInfo == nil then
    self:InitRandomLoadInfo()
  end
  local vAssignAllLoadingInfo = {}
  if #self.m_assignRandomLoadInfo <= 0 then
    return vAssignAllLoadingInfo
  end
  local curAssignParam = self:GetAssignLevelParams(levelType, ...)
  if not curAssignParam then
    return vAssignAllLoadingInfo
  end
  for _, v in ipairs(self.m_assignRandomLoadInfo) do
    local params = v.params
    local isMatch = true
    for i, paramNum in ipairs(params) do
      local curParamNum = curAssignParam[i]
      if paramNum ~= 0 and paramNum ~= curParamNum then
        isMatch = false
        break
      end
    end
    if isMatch then
      vAssignAllLoadingInfo[#vAssignAllLoadingInfo + 1] = v
    end
  end
  return vAssignAllLoadingInfo
end

function BattleFlowManager:EnterShowPlot(levelID, mapID, backLobbyBackFun)
  BattleGlobalManager:EnterPlotReplay(levelID, mapID)
  self.m_backLobbyBackFun = backLobbyBackFun
end

function BattleFlowManager:SavePvpReplaceDetailData(reqEnemyIndex, param)
  self.pvpReplaceDetailReqEnemyIndex = reqEnemyIndex
  self.pvpReplaceDetailParam = param
end

function BattleFlowManager:OpenPvpReplaceDetailWnd(completeBattleResult)
  StackPopup:Push(UIDefines.ID_FORM_PVPREPLACEDETAILSINGAME, {
    enemyIndex = self.pvpReplaceDetailReqEnemyIndex,
    param = self.pvpReplaceDetailParam,
    completeBattleResult = completeBattleResult
  })
end

function BattleFlowManager:HandleBattleJump2System(formUIID, param)
  function self.m_backLobbyBackFun(backFun)
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
      if isSuc then
        StackFlow:Push(UIDefines.ID_FORM_HALL)
        
        if formUIID == UIDefines.ID_FORM_GACHAMAIN then
          GachaManager:GetGachaData(param)
        elseif param then
          StackFlow:Push(formUIID, param)
        else
          StackFlow:Push(formUIID)
        end
        if backFun then
          local formName = CS.UIDefinesForLua.Get(formUIID)
          backFun(formName)
        end
      end
    end, true)
  end
  
  CS.BattleGameManager.Instance:ExitBattle()
end

function BattleFlowManager:PopUpDirectionsUI(tipsID)
  utils.popUpDirectionsUI({
    tipsID = tipsID,
    func1 = function()
    end
  })
end

function BattleFlowManager:SetCommonText(textComp, textId, formatParam)
  textComp.text = string.format(ConfigManager:GetCommonTextById(textId), formatParam)
end

function BattleFlowManager:SetLevelData(fightType, fightSubType, fightId)
  local inputLevelData = {
    levelType = fightType,
    levelSubType = fightSubType,
    levelID = fightId,
    heroList = HeroManager:GetHeroServerList(),
    isSim = false
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

return BattleFlowManager
