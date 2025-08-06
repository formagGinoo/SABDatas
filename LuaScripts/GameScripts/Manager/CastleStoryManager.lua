local BaseManager = require("Manager/Base/BaseManager")
local CastleStoryManager = class("CastleStoryManager", BaseManager)
CastleStoryManager.TextTypeEnum = {
  Speak = 1,
  Choose = 2,
  Text = 3
}
CastleStoryManager.ShowStoryType = {Plot = 1, Playback = 2}

function CastleStoryManager:OnCreate()
  self.mWaitStory = {}
  self.iStoryTimes = 0
  self.iCurClkPlace = nil
  self.mAllPlaceCurStory = {}
  self.m_mFinishedStory = {}
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnItemChange))
  self:addEventListener("eGameEvent_Castle_UnlockPlace", handler(self, self.OnUnlockPlace))
end

function CastleStoryManager:OnInitNetwork()
  local msg = MTTDProto.Cmd_Castle_GetPlace_CS()
  RPCS():Castle_GetPlace(msg, handler(self, self.OnCastleGetPlaceSC))
end

function CastleStoryManager:OnDailyReset()
  local msg = MTTDProto.Cmd_Castle_GetPlace_CS()
  RPCS():Castle_GetPlace(msg, handler(self, self.OnCastleGetPlaceSC))
end

function CastleStoryManager:OnDestroy()
end

function CastleStoryManager:OnItemChange()
  self:FreshEventEntryRedDot()
end

function CastleStoryManager:OnUnlockPlace()
  self:FreshEventEntryRedDot()
end

function CastleStoryManager:OnCastleGetPlaceSC(data)
  self.mWaitStory = data.mWaitStory
  self.iStoryTimes = data.iStoryTimes
  self.m_mFinishedStory = data.mFinishedStory
  self:FormatCurStoryList()
  self:FreshEventEntryRedDot()
  self:broadcastEvent("eGameEvent_CastleStoryFresh")
end

function CastleStoryManager:RqsCastleDoPlaceStory(iStoryId, is_skip, callback)
  local msg = MTTDProto.Cmd_Castle_DoPlaceStory_CS()
  msg.iStoryId = iStoryId
  msg.bSkip = is_skip
  RPCS():Castle_DoPlaceStory(msg, function(data)
    self.mWaitStory[data.iStoryId] = nil
    self.iStoryTimes = data.iStoryTimes
    self.m_mFinishedStory[data.iStoryId] = data.iStoryTimes
    local reward_list = data.vReward
    if reward_list and next(reward_list) then
      utils.popUpRewardUI(reward_list, callback)
    elseif callback then
      callback()
    end
    self:FormatCurStoryList()
    self:FreshEventEntryRedDot()
  end)
end

function CastleStoryManager:GetCastleStoryInfoCfgByStoryID(iStoryId)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleStoryInfo")
  local cfg = cfgIns:GetValue_ByStoryID(iStoryId)
  if cfg:GetError() then
    log.error("CastleStoryManager GetCastleStoryInfoCfgByStoryID Error, wrong storyId:  " .. tostring(iStoryId))
    return
  end
  return cfg
end

function CastleStoryManager:GetCastleStoryPerformCfgByStoryID(iStoryId)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleStoryPerform")
  return cfgIns:GetValue_ByStoryID(iStoryId)
end

function CastleStoryManager:GetmWaitStory()
  return self.mWaitStory
end

function CastleStoryManager:GetiStoryTimes()
  return self.iStoryTimes
end

function CastleStoryManager:GetMaxStoryEnergyCount()
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local count = tonumber(GlobalManagerIns:GetValue_ByName("CastleStoryLimitInitial").m_Value) or 2
  return count + (StatueShowroomManager:GetStatueEffectValue("StatueEffect_StaminaMaxCount") or 0)
end

function CastleStoryManager:GetAllPlaceCurStoryList()
  return self.mAllPlaceCurStory
end

function CastleStoryManager:FormatCurStoryList()
  local CastlePlaceIns = ConfigManager:GetConfigInsByName("CastlePlace")
  local allPlaceCfg = CastlePlaceIns:GetAll()
  self.mAllPlaceCurStory = {}
  local t = {}
  for i, tempPlaceCfg in pairs(allPlaceCfg) do
    local storydata = self:GetPlaceCurStory(tempPlaceCfg.m_PlaceID)
    if storydata then
      t[#t + 1] = storydata
    end
  end
  if 0 < #t then
    if #t == 1 then
      self.mAllPlaceCurStory[1] = t[1].cfg
      return
    end
    table.sort(t, function(a, b)
      if a.time ~= b.time then
        return a.time < b.time
      elseif a.iStoryId ~= b.iStoryId then
        return a.iStoryId < b.iStoryId
      end
    end)
    for _, v in ipairs(t) do
      local temp1 = utils.changeCSArrayToLuaTable(v.cfg.m_Character)
      local is_have = false
      for _, vv in ipairs(self.mAllPlaceCurStory) do
        local temp2 = utils.changeCSArrayToLuaTable(vv.m_Character)
        for _, heroID1 in ipairs(temp1) do
          for _, heroID2 in ipairs(temp2) do
            if heroID1 == heroID2 then
              is_have = true
              break
            end
          end
          if is_have then
            break
          end
        end
        if is_have then
          break
        end
      end
      if not is_have then
        self.mAllPlaceCurStory[#self.mAllPlaceCurStory + 1] = v.cfg
      end
    end
  end
end

function CastleStoryManager:GetPlaceCurStory(iPlaceId)
  local list = {}
  for iStoryId, time in pairs(self.mWaitStory) do
    local cfg = self:GetCastleStoryInfoCfgByStoryID(iStoryId)
    if cfg and cfg.m_PlaceID == iPlaceId then
      list[#list + 1] = {
        cfg = cfg,
        iStoryId = iStoryId,
        time = time
      }
    end
  end
  if 0 < #list then
    table.sort(list, function(a, b)
      if a.time ~= b.time then
        return a.time < b.time
      elseif a.iStoryId ~= b.iStoryId then
        return a.iStoryId < b.iStoryId
      end
    end)
  else
    return
  end
  return list[1]
end

function CastleStoryManager:SetCurClkPlace(placeID)
  self.iCurClkPlace = placeID
end

function CastleStoryManager:GetCurClkPlace()
  return self.iCurClkPlace
end

function CastleStoryManager:FreshEventEntryRedDot()
  local redDotNum = self:GetEventEntryRedCount()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.CastleEventEntry,
    count = redDotNum
  })
  local num = 0
  for i, cfg in ipairs(self.mAllPlaceCurStory) do
    if CastleManager:GetCastlePlaceCfgByID(cfg.m_PlaceID).m_Type == 1 then
      num = 1
      break
    end
  end
  local maxTimes = self:GetMaxStoryEnergyCount()
  local leftTimes = maxTimes - self:GetiStoryTimes()
  if leftTimes == 0 then
    num = 0
  end
  local CastlePlaceIns = ConfigManager:GetConfigInsByName("CastlePlace")
  local allPlaceCfg = CastlePlaceIns:GetAll()
  for i, tempPlaceCfg in pairs(allPlaceCfg) do
    if self:IsPlaceCanUnlock({
      placeID = tempPlaceCfg.m_PlaceID
    }) == 1 then
      num = 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.CastleEntry,
    count = num
  })
end

function CastleStoryManager:GetEventEntryRedCount()
  local CastlePlaceIns = ConfigManager:GetConfigInsByName("CastlePlace")
  local allPlaceCfg = CastlePlaceIns:GetAll()
  for i, tempPlaceCfg in pairs(allPlaceCfg) do
    if tempPlaceCfg.m_Type == 2 and self:IsPlaceCanUnlock({
      placeID = tempPlaceCfg.m_PlaceID
    }) == 1 then
      return 1
    end
  end
  if not self.mAllPlaceCurStory or #self.mAllPlaceCurStory == 0 then
    return 0
  end
  local maxTimes = self:GetMaxStoryEnergyCount()
  local leftTimes = maxTimes - self:GetiStoryTimes()
  if leftTimes == 0 then
    return 0
  end
  for i, cfg in ipairs(self.mAllPlaceCurStory) do
    local placeCfg = CastleManager:GetCastlePlaceCfgByID(cfg.m_PlaceID)
    if placeCfg.m_Type == 2 then
      return 1
    end
  end
  return 0
end

function CastleStoryManager:IsPlaceCanUnlock(param)
  local isUnlock, _ = CastleManager:IsCastlePlaceUnlock(param.placeID)
  local unlockItem = CastleManager:GetCastlePlaceCfgByID(param.placeID).m_UnlockData
  local itemNum = ItemManager:GetItemNum(unlockItem)
  local isCanUnlock = false
  if 0 < itemNum then
    isCanUnlock = true
  end
  if not isUnlock and isCanUnlock then
    return 1
  end
  return 0
end

function CastleStoryManager:IsStoryCanShow(storydata)
  for i, cfg in ipairs(self.mAllPlaceCurStory) do
    if cfg.m_PlaceID == storydata.cfg.m_PlaceID then
      return true
    end
  end
end

function CastleStoryManager:GetFinishedStory()
  return self.m_mFinishedStory
end

function CastleStoryManager:GetAllFinishedStoryInfo()
  local list = {}
  local cfgList = {}
  for iStoryId, time in pairs(self.m_mFinishedStory) do
    local cfg = self:GetCastleStoryInfoCfgByStoryID(iStoryId)
    if cfg then
      list[#list + 1] = {
        cfg = cfg,
        iStoryId = iStoryId,
        time = time
      }
    end
  end
  if 0 < #list then
    table.sort(list, function(a, b)
      if a.time ~= b.time then
        return a.time < b.time
      elseif a.iStoryId ~= b.iStoryId then
        return a.iStoryId < b.iStoryId
      end
    end)
    for i, v in ipairs(list) do
      cfgList[#cfgList + 1] = v.cfg
    end
  end
  return cfgList, list
end

return CastleStoryManager
