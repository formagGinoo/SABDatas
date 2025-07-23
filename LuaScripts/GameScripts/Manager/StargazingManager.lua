local BaseManager = require("Manager/Base/BaseManager")
local StargazingManager = class("StargazingManager", BaseManager)
StargazingManager.CastleStarEffectType = {
  HangUp = 1,
  Dispatch = 2,
  Boss = 3,
  Inherit = 4
}

function StargazingManager:OnCreate()
  self.m_mConstellaAvailableInfo = {}
  self.m_vAvailableStarList = {}
  self.m_dispatchHero = {}
  self.m_monitorItems = {}
  self:AddEventListener()
end

function StargazingManager:AddEventListener()
  self:addEventListener("eGameEvent_Item_Init", handler(self, self.OnItemInit))
  self:addEventListener("eGameEvent_PopupUnlockSystem", handler(self, self.OnUnlockSystem))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnItemChange))
  self:addEventListener("eGameEvent_Level_PushPassStage", handler(self, self.OnLevelPassStage))
end

function StargazingManager:OnLevelPassStage(stPushPassStage)
  local levelType = stPushPassStage.iStageType
  if levelType == LevelManager.LevelType.MainLevel then
    self:FreshStargazingRedDot()
  end
end

function StargazingManager:OnUnlockSystem(param)
  if not param then
    return
  end
  if param.systemID == GlobalConfig.SYSTEM_ID.CastleStar then
    self:FreshStargazingRedDot()
  end
end

function StargazingManager:OnItemChange(vItemChange)
  local bNeedFresh = false
  for _, stItemChange in pairs(vItemChange) do
    if self.m_monitorItems[stItemChange.iID] then
      bNeedFresh = true
      break
    end
  end
  if bNeedFresh then
    self:FreshStargazingRedDot()
  end
end

function StargazingManager:OnInitNetwork()
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  SROptionsModify.AddSROptionMethod("跳转观星台", function()
    StackFlow:Push(UIDefines.ID_FORM_CASTLESTARUNLOCK, {})
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("跳转观星台2", function()
    StackFlow:Push(UIDefines.ID_FORM_CASTLESTARMAIN, {})
  end, "Debug", 0)
end

function StargazingManager:OnAfterFreshData()
  local castleStarInfoCfg = ConfigManager:GetConfigInsByName("CastleStarInfo")
  local vStarInfo = castleStarInfoCfg:GetAll()
  self.m_vConstellationList = {}
  for k, v in pairs(vStarInfo) do
    self.m_vConstellationList[#self.m_vConstellationList + 1] = v
    local conditionTypeArray = utils.changeCSArrayToLuaTable(v.m_UnlockConditionType)
    local conditionDataArray = utils.changeCSArrayToLuaTable(v.m_UnlockConditionData)
    for k2, v2 in ipairs(conditionTypeArray) do
      if v2 == 21 then
        local itemId = conditionDataArray[k2][1]
        self.m_monitorItems[itemId] = true
      end
    end
    if v.m_ItemConsume.Length > 0 then
      local itemConsume = v.m_ItemConsume[0]
      self.m_monitorItems[itemConsume[0]] = true
    end
  end
  table.sort(self.m_vConstellationList, function(a, b)
    return a.m_ConstellationID < b.m_ConstellationID
  end)
  local castleStarTechCfg = ConfigManager:GetConfigInsByName("CastleStarTech")
  local vList = castleStarTechCfg:GetAll()
  local iConstellationID = 0
  local iStarID = 0
  self.m_vAvailableStarList = {}
  for k, v in pairs(vList) do
    local list2 = v
    for k2, v2 in pairs(list2) do
      iStarID = v2.m_StarID
      iConstellationID = v2.m_ConstellationID
      if self.m_mConstellaAvailableInfo[iConstellationID] == nil then
        self.m_mConstellaAvailableInfo[iConstellationID] = {}
      end
      self.m_mConstellaAvailableInfo[iConstellationID][#self.m_mConstellaAvailableInfo[iConstellationID] + 1] = iStarID
      self.m_vAvailableStarList[#self.m_vAvailableStarList + 1] = v2
      if v2.m_ItemConsume.Length > 0 then
        local itemConsume = v2.m_ItemConsume[0]
        self.m_monitorItems[itemConsume[0]] = true
      end
    end
  end
  
  local function sortByStarID(a, b)
    return a < b
  end
  
  table.sort(self.m_vAvailableStarList, function(a, b)
    return a.m_StarID < b.m_StarID
  end)
  for k, v in pairs(self.m_mConstellaAvailableInfo) do
    if 1 < #v then
      table.sort(v, sortByStarID)
    end
  end
  self:FreshStargazingRedDot()
end

function StargazingManager:GetConstellationList()
  return self.m_vConstellationList
end

function StargazingManager:GetConstellationInfo(iConstellationID)
  local castleStarInfoCfg = ConfigManager:GetConfigInsByName("CastleStarInfo")
  return castleStarInfoCfg:GetValue_ByConstellationID(iConstellationID)
end

function StargazingManager:GetCastleStarTechInfo(iConstellationID)
  local castleStarInfoCfg = ConfigManager:GetConfigInsByName("CastleStarTech")
  local list = castleStarInfoCfg:GetValue_ByConstellationID(iConstellationID)
  local cfgs = {}
  for key, v in pairs(list) do
    if v.m_StarID and v.m_StarID > 0 then
      cfgs[#cfgs + 1] = v
    end
  end
  table.sort(cfgs, function(a, b)
    return a.m_StarID < b.m_StarID
  end)
  return cfgs
end

function StargazingManager:GetStarInfo(iConstellationID, iStarID)
  if iConstellationID == nil then
    for k, v in ipairs(self.m_vAvailableStarList) do
      if v.m_StarID == iStarID then
        return v
      end
    end
  else
    local castleStarTechCfg = ConfigManager:GetConfigInsByName("CastleStarTech")
    return castleStarTechCfg:GetValue_ByConstellationIDAndStarID(iConstellationID, iStarID)
  end
end

function StargazingManager:GetAvailableStarList(iConstellationID)
  return self.m_mConstellaAvailableInfo[iConstellationID]
end

function StargazingManager:IsStarUnAvailable(iConstellationID, iStarID)
  local starInfo = self:GetStarInfo(iConstellationID, iStarID)
  return starInfo.m_EffectType == 5
end

function StargazingManager:IsStarUnlock(iConstellationID, iStarID)
  local constellationInfo = self.m_mConstella[iConstellationID]
  if constellationInfo == nil or constellationInfo.mUnlockStar == nil then
    return false
  end
  if iStarID == 0 then
    return true
  end
  local mUnlockStar = constellationInfo.mUnlockStar
  for k, v in pairs(mUnlockStar) do
    if k == iStarID then
      return true
    end
  end
  return false
end

function StargazingManager:GetDispatchHeroes(iConstellationID, iStarID)
  local constellationInfo = self.m_mConstella[iConstellationID]
  if constellationInfo == nil or constellationInfo.mUnlockStar == nil then
    return nil
  end
  local mUnlockStar = constellationInfo.mUnlockStar
  for k, v in pairs(mUnlockStar) do
    if k == iStarID then
      return v
    end
  end
  return nil
end

function StargazingManager:IsConstellationUnlock(iConstellationID)
  return self.m_mConstella[iConstellationID] ~= nil
end

function StargazingManager:IsConstellationAllStarActivate(iConstellationID)
  local constellaInfo = self.m_mConstella[iConstellationID]
  if constellaInfo == nil or constellaInfo.mUnlockStar == nil then
    return false
  end
  local vStarList = self.m_mConstellaAvailableInfo[iConstellationID]
  for k, v in pairs(vStarList) do
    if constellaInfo.mUnlockStar[v] == nil then
      return false
    end
  end
  return true
end

function StargazingManager:GetFirstUnlockStarInfo()
  for k, v in ipairs(self.m_vAvailableStarList) do
    if self:IsConstellationUnlock(v.m_ConstellationID) then
      if not self:IsStarUnlock(v.m_ConstellationID, v.m_StarID) then
        return v
      end
    else
      return v
    end
  end
  return self.m_vAvailableStarList[#self.m_vAvailableStarList]
end

function StargazingManager:IsAllStarUnlock()
  for k, v in ipairs(self.m_vAvailableStarList) do
    if self:IsConstellationUnlock(v.m_ConstellationID) then
      if not self:IsStarUnlock(v.m_ConstellationID, v.m_StarID) then
        return false
      end
    else
      return false
    end
  end
  return true
end

function StargazingManager:GetFirstUnlockStarInfoByConstellation(iConstellationID)
  local vStarList = self.m_mConstellaAvailableInfo[iConstellationID]
  local constellaInfo = self.m_mConstella[iConstellationID]
  if constellaInfo == nil or constellaInfo.mUnlockStar == nil then
    return vStarList[1]
  end
  local mUnlockStar = constellaInfo.mUnlockStar
  for k, v in ipairs(vStarList) do
    if mUnlockStar[v] == nil then
      return v
    end
  end
  return vStarList[#vStarList]
end

function StargazingManager:FreshStargazingRedDot()
  local redDotNum = self:CheckRedDot()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.StarPlatform,
    count = redDotNum
  })
end

function StargazingManager:CheckRedDot()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.CastleStar) then
    return 0
  end
  local starInfo = self:GetFirstUnlockStarInfo()
  local constellationInfo = self:GetConstellationInfo(starInfo.m_ConstellationID)
  if not self:IsConstellationUnlock(constellationInfo.m_ConstellationID) then
    local conditionTypeArray = utils.changeCSArrayToLuaTable(constellationInfo.m_UnlockConditionType)
    local conditionDataArray = utils.changeCSArrayToLuaTable(constellationInfo.m_UnlockConditionData)
    for k, v in ipairs(conditionTypeArray) do
      if v == 3 then
        local stageId = conditionDataArray[k][1]
        local cfg = LevelManager:GetMainLevelCfgById(stageId)
        if LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stageId) == false then
          return 0
        end
      elseif v == 21 then
        local itemId = conditionDataArray[k][1]
        local cfg = ItemManager:GetItemConfigById(itemId)
        if 0 >= ItemManager:GetItemNum(itemId, true) then
          return 0
        end
      end
    end
    local itemConsume = constellationInfo.m_ItemConsume[0]
    if itemConsume[1] <= ItemManager:GetItemNum(itemConsume[0], true) then
      return 1
    end
  else
    if self:IsStarUnlock(constellationInfo.m_ConstellationID, starInfo.m_StarID) then
      return 0
    end
    local itemConsume = starInfo.m_ItemConsume[0]
    if itemConsume[1] <= ItemManager:GetItemNum(itemConsume[0], true) then
      local characterList = utils.changeCSArrayToLuaTable(starInfo.m_CharacterList)
      local is_have = true
      for _, heroID in pairs(characterList) do
        if not HeroManager:GetHeroDataByID(heroID) then
          is_have = false
          break
        end
      end
      return is_have and 1 or 0
    end
  end
  return 0
end

function StargazingManager:SetDispatchHero(heroId, isDispatch)
  self.m_dispatchHero[heroId] = isDispatch
end

function StargazingManager:GetDispatchHero(heroId)
  return self.m_dispatchHero[heroId]
end

function StargazingManager:ClearDispatchHero()
  self.m_dispatchHero = {}
end

function StargazingManager:ReqGetStarRoom()
  local msg = MTTDProto.Cmd_Castle_GetStarRoom_CS()
  RPCS():Castle_GetStarRoom(msg, handler(self, self.OnGetStarRoomSC))
end

function StargazingManager:OnGetStarRoomSC(sc)
  self.m_mConstella = sc.mConstella
end

function StargazingManager:ReqUnlockConstella(iConstellationID, callback)
  local msg = MTTDProto.Cmd_Castle_UnlockConstella_CS()
  msg.iConstellaId = iConstellationID
  
  local function OnUnlockConstellaSC(sc, msg)
    self.m_mConstella[sc.iConstellaId] = {}
    self.m_mConstella[sc.iConstellaId].mUnlockStar = {}
    self:FreshStargazingRedDot()
    if callback then
      callback()
    end
  end
  
  RPCS():Castle_UnlockConstella(msg, OnUnlockConstellaSC)
end

function StargazingManager:ReqSeeStar(iConstellationID, iStarID, vHero, callback)
  local msg = MTTDProto.Cmd_Castle_SeeStar_CS()
  msg.iConstellaId = iConstellationID
  msg.iStarId = iStarID
  msg.vHero = vHero
  
  local function OnSeeStarSC(sc, msg)
    if self.m_mConstella[sc.iConstellaId].mUnlockStar == nil then
      self.m_mConstella[sc.iConstellaId].mUnlockStar = {}
    end
    self.m_mConstella[sc.iConstellaId].mUnlockStar[sc.iStarId] = sc.vHero
    self:FreshStargazingRedDot()
    if callback then
      callback(sc.iStarId)
    end
  end
  
  RPCS():Castle_SeeStar(msg, OnSeeStarSC)
end

function StargazingManager:GetCastleStarTechEffectByType(effectType)
  local effectList = {}
  local effectMap = {}
  if self.m_vAvailableStarList then
    for k, v in ipairs(self.m_vAvailableStarList) do
      if self:IsConstellationUnlock(v.m_ConstellationID) and self:IsStarUnlock(v.m_ConstellationID, v.m_StarID) and v.m_EffectType == effectType then
        effectList[#effectList + 1] = utils.changeCSArrayToLuaTable(v.m_EffectData)
      end
    end
    if effectType == StargazingManager.CastleStarEffectType.Inherit or effectType == StargazingManager.CastleStarEffectType.Dispatch then
      local count = 0
      for i, v in ipairs(effectList) do
        for m, n in ipairs(v) do
          count = count + n[1]
        end
      end
      effectMap[effectType] = count
    else
      for i, v in ipairs(effectList) do
        for m, n in ipairs(v) do
          if not effectMap[n[1]] then
            effectMap[n[1]] = n[2]
          else
            effectMap[n[1]] = effectMap[n[1]] + n[2]
          end
        end
      end
    end
  end
  return effectMap
end

return StargazingManager
