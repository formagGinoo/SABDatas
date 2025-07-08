local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local CastleManager = class("CastleManager", BaseLevelManager)
CastleManager.UnlockType = {
  DefaultUnlock = 1,
  KeyUnlock = 2,
  SystemUnlock = 3
}

function CastleManager:OnCreate()
  self.m_castlePlaceCfgCache = {}
  self.m_castleKeyPlaceUnlockList = nil
end

function CastleManager:OnInitNetwork()
end

function CastleManager:OnAfterFreshData()
  self:InitGlobalCfg()
  self:ReqGetCastlePlace()
end

function CastleManager:OnUpdate(dt)
end

function CastleManager:ReqGetCastlePlace()
  local msg = MTTDProto.Cmd_Castle_GetPlace_CS()
  RPCS():Castle_GetPlace(msg, handler(self, self.OnGetCastlePlaceSC))
end

function CastleManager:OnGetCastlePlaceSC(stGetPlaceSC, msg)
  if not stGetPlaceSC then
    return
  end
  local unlockPlaceList = stGetPlaceSC.vUnlockPlace
  if not unlockPlaceList then
    return
  end
  self.m_castleKeyPlaceUnlockList = unlockPlaceList
end

function CastleManager:ReqCastleUnlockKeyPlace(placeID)
  if not placeID then
    return
  end
  local msg = MTTDProto.Cmd_Castle_UnlockKeyPlace_CS()
  msg.iPlaceId = placeID
  RPCS():Castle_UnlockKeyPlace(msg, handler(self, self.OnCastleUnlockKeyPlaceSC))
end

function CastleManager:OnCastleUnlockKeyPlaceSC(stUnlockPlaceSC, msg)
  if not stUnlockPlaceSC then
    return
  end
  local unlockPlaceID = stUnlockPlaceSC.iPlaceId
  self:InsertUnlockPlaceID(unlockPlaceID)
  self:broadcastEvent("eGameEvent_Castle_UnlockPlace", {placeID = unlockPlaceID})
end

function CastleManager:InitGlobalCfg()
  self.m_CastlePlaceCfg = ConfigManager:GetConfigInsByName("CastlePlace")
end

function CastleManager:InsertUnlockPlaceID(placeID)
  if not self.m_castleKeyPlaceUnlockList then
    self.m_castleKeyPlaceUnlockList = {}
  end
  self.m_castleKeyPlaceUnlockList[#self.m_castleKeyPlaceUnlockList + 1] = placeID
end

function CastleManager:IsKeyPlaceUnlock(placeID)
  if not placeID then
    return
  end
  local tempCastlePlaceCfg = self:GetCastlePlaceCfgByID(placeID)
  if not tempCastlePlaceCfg then
    return
  end
  local unlockType = tempCastlePlaceCfg.m_UnlockType
  if unlockType ~= CastleManager.UnlockType.KeyUnlock then
    return
  end
  if not self.m_castleKeyPlaceUnlockList then
    return
  end
  for _, tempPlaceID in ipairs(self.m_castleKeyPlaceUnlockList) do
    if tempPlaceID == placeID then
      return true
    end
  end
  return false
end

function CastleManager:IsCastlePlaceUnlock(placeID)
  if not placeID then
    return
  end
  local placeCfg = self:GetCastlePlaceCfgByID(placeID)
  if not placeCfg then
    return
  end
  local unlockType = placeCfg.m_UnlockType
  if unlockType == CastleManager.UnlockType.DefaultUnlock then
    return true
  end
  local isUnlock, unlockTips
  if unlockType == CastleManager.UnlockType.KeyUnlock then
    isUnlock = self:IsKeyPlaceUnlock(placeCfg.m_PlaceID)
    if isUnlock ~= true then
      unlockTips = placeCfg.m_mUnlockText
    end
  elseif unlockType == CastleManager.UnlockType.SystemUnlock then
    local systemID = placeCfg.m_UnlockData
    isUnlock, unlockTips = UnlockSystemUtil:IsSystemOpen(systemID)
  end
  return isUnlock, unlockTips
end

function CastleManager:GetCastlePlaceCfgByID(placeID)
  if not placeID then
    return
  end
  local tempCastlePlaceCfg = self.m_castlePlaceCfgCache[placeID]
  if not tempCastlePlaceCfg then
    tempCastlePlaceCfg = self.m_CastlePlaceCfg:GetValue_ByPlaceID(placeID)
    if tempCastlePlaceCfg:GetError() == true then
      tempCastlePlaceCfg = nil
    end
    self.m_castlePlaceCfgCache[placeID] = tempCastlePlaceCfg
  end
  return tempCastlePlaceCfg
end

return CastleManager
