local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local CastleDispatchManager = class("CastleDispatchManager", BaseLevelManager)

function CastleDispatchManager:OnCreate()
  self.m_DispatchList = {}
  self.m_DispatchInitLevel = 1
end

function CastleDispatchManager:OnInitNetwork()
  RPCS():Listen_Push_Castle_AddDispatch(handler(self, self.OnPushCastleAddDispatch), "CastleDispatchManager")
end

function CastleDispatchManager:OnInitMustRequestInFetchMore()
  self:ReqGetDispatch()
end

function CastleDispatchManager:OnAfterInitConfig()
  self.m_DispatchInitLevel = tonumber(ConfigManager:GetGlobalSettingsByKey("DispatchInitLevel"))
end

function CastleDispatchManager:OnDailyReset()
  self:ReqGetDispatch()
end

function CastleDispatchManager:OnUpdate(dt)
end

function CastleDispatchManager:OnPushCastleAddDispatch(data, msg)
  local mEvent = data.mEvent or {}
  for i, v in pairs(mEvent) do
    self.m_DispatchList[i] = v
  end
end

function CastleDispatchManager:ReqGetDispatch()
  local msg = MTTDProto.Cmd_Castle_GetDispatch_CS()
  RPCS():Castle_GetDispatch(msg, handler(self, self.OnGetGetDispatchSC))
end

function CastleDispatchManager:OnGetGetDispatchSC(stData, msg)
  self.m_DispatchList = stData.mEvent
  self:broadcastEvent("eGameEvent_CastleDispatchRefresh")
end

function CastleDispatchManager:ReqCastleDoDispatch(mLocationHero)
  local msg = MTTDProto.Cmd_Castle_DoDispatch_CS()
  msg.mLocationHero = mLocationHero
  RPCS():Castle_DoDispatch(msg, handler(self, self.OnCastleDoDispatchSC))
end

function CastleDispatchManager:OnCastleDoDispatchSC(stData, msg)
  for i, v in pairs(stData.mEvent) do
    self.m_DispatchList[i] = v
  end
  self:broadcastEvent("eGameEvent_CastleDoDispatch")
end

function CastleDispatchManager:ReqCastleDoQuickDispatch(mLocationHero)
  local msg = MTTDProto.Cmd_Castle_DoDispatch_CS()
  msg.mLocationHero = mLocationHero
  RPCS():Castle_DoDispatch(msg, handler(self, self.OnCastleDoQuickDispatchSC))
end

function CastleDispatchManager:OnCastleDoQuickDispatchSC(stData, msg)
  for i, v in pairs(stData.mEvent) do
    self.m_DispatchList[i] = v
  end
  self:broadcastEvent("eGameEvent_CastleDoQuickDispatch")
end

function CastleDispatchManager:ReqRefreshDispatch()
  local msg = MTTDProto.Cmd_Castle_RefreshDispatch_CS()
  RPCS():Castle_RefreshDispatch(msg, handler(self, self.OnRefreshDispatchSC))
end

function CastleDispatchManager:OnRefreshDispatchSC(stData, msg)
  for i, v in pairs(stData.mEvent) do
    self.m_DispatchList[i] = v
  end
  self:broadcastEvent("eGameEvent_RefreshDispatch")
end

function CastleDispatchManager:ReqCancelDispatch(iLocation)
  local msg = MTTDProto.Cmd_Castle_CancelDispatch_CS()
  msg.iLocation = iLocation
  RPCS():Castle_CancelDispatch(msg, handler(self, self.OnCancelDispatchSC))
end

function CastleDispatchManager:OnCancelDispatchSC(stData, msg)
  self.m_DispatchList[stData.iLocation] = stData.stEvent
  self:broadcastEvent("eGameEvent_CancelDispatch")
end

function CastleDispatchManager:ReqTakeDispatchReward(vLocation)
  local msg = MTTDProto.Cmd_Castle_TakeDispatchReward_CS()
  msg.vLocation = vLocation
  RPCS():Castle_TakeDispatchReward(msg, handler(self, self.OnTakeDispatchRewardSC))
end

function CastleDispatchManager:OnTakeDispatchRewardSC(stData, msg)
  for i, v in pairs(stData.mEvent) do
    self.m_DispatchList[i] = v
  end
  local rewardList = stData.vReward
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList)
  end
  self:broadcastEvent("eGameEvent_TakeDispatchReward")
end

function CastleDispatchManager:GetDispatchData()
  return self.m_DispatchList
end

function CastleDispatchManager:GetCastleDispatchEventCfg(groupID, eventID)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleDispatchEvent")
  local cfg = cfgIns:GetValue_ByGroupIDAndEventID(groupID, eventID)
  if cfg:GetError() then
    log.error("GetCastleDispatchEventCfg can not find groupID = " .. tostring(groupID) .. " eventID = " .. eventID)
    return
  end
  return cfg
end

function CastleDispatchManager:GetCastleDispatchLevelCfg(dispatchLevel)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleDispatchLevel")
  local cfg = cfgIns:GetValue_ByDispatchLevel(dispatchLevel)
  if cfg:GetError() then
    log.error("GetCastleDispatchLevelCfg can not find dispatchLevel = " .. tostring(dispatchLevel))
    return
  end
  return cfg
end

function CastleDispatchManager:GetCastleDispatchLocationCfg(id)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleDispatchLocation")
  local cfg = cfgIns:GetValue_ByUID(id)
  if cfg:GetError() then
    log.error("GetCastleDispatchLocationCfg can not find id = " .. tostring(id))
    return
  end
  return cfg
end

function CastleDispatchManager:GetDispatchDurationTimeByData(data)
  if not data then
    return 0
  end
  local time = 0
  local eventCfg = self:GetCastleDispatchEventCfg(data.iGroupId, data.iEventId)
  if eventCfg then
    local durationTime = eventCfg.m_TimeMin * 60
    local times = 0
    if data.iStartTime ~= 0 and data.iRewardTime == 0 then
      times = TimeUtil:GetServerTimeS() - data.iStartTime
      time = durationTime - times
    end
  end
  return time
end

function CastleDispatchManager:GetCanGetRewardDispatchList()
  local getList = {}
  if self.m_DispatchList then
    for i, v in pairs(self.m_DispatchList) do
      local time = self:GetDispatchDurationTimeByData(v)
      if time < 0 then
        getList[#getList + 1] = i
      end
    end
  end
  return getList
end

function CastleDispatchManager:FilterHeroByCondition(condition, excludeTab)
  if not condition or not condition.camp then
    return {}
  end
  local heroTab = {}
  local heroList = HeroManager:GetHeroList()
  for i, v in pairs(heroList) do
    local isDispatch = self:CheckDispatchedHero(v.characterCfg.m_HeroID)
    if not isDispatch and not table.keyof(excludeTab, v.characterCfg.m_HeroID) and (v.characterCfg.m_Camp == condition.camp or condition.camp == 0) and v.characterCfg.m_Quality >= condition.quality then
      heroTab[#heroTab + 1] = table.deepcopy(v)
    end
  end
  
  local function sortFun(data1, data2)
    return data1.characterCfg.m_Quality < data2.characterCfg.m_Quality
  end
  
  table.sort(heroTab, sortFun)
  return heroTab
end

function CastleDispatchManager:CheckDispatchedHero(heroId)
  if self.m_DispatchList then
    for i, v in pairs(self.m_DispatchList) do
      if v.vHero then
        for m, n in pairs(v.vHero) do
          if n == heroId then
            return true
          end
        end
      end
    end
  end
  return false
end

function CastleDispatchManager:GetDispatchLevel()
  local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.Dispatch)
  local lv = starEffectMap[StargazingManager.CastleStarEffectType.Dispatch] + self.m_DispatchInitLevel
  return lv
end

function CastleDispatchManager:GetDispatchEventByLevel()
  local dispatchEventList = {}
  local dispatchTab = {}
  local dispatchLevel = self:GetDispatchLevel()
  local lvCfg = self:GetCastleDispatchLevelCfg(dispatchLevel)
  if lvCfg then
    local dispatchList = utils.changeCSArrayToLuaTable(lvCfg.m_DispatchList)
    local cfgIns = ConfigManager:GetConfigInsByName("CastleDispatchEvent")
    for i, v in ipairs(dispatchList) do
      local groupID = v[1]
      local cfgList = cfgIns:GetValue_ByGroupID(groupID)
      local count = cfgList.Count
      local eventSortTab = {}
      for m, n in pairs(cfgList) do
        if not dispatchTab[groupID] then
          dispatchTab[groupID] = {}
        end
        if not dispatchTab[groupID][n.m_Sort] then
          dispatchTab[groupID][n.m_Sort] = {}
        end
        dispatchTab[groupID][n.m_Sort] = {cfg = n}
        eventSortTab[n.m_Sort] = (eventSortTab[n.m_Sort] or 0) + 1
      end
      for p, q in pairs(dispatchTab[groupID]) do
        if eventSortTab[q.cfg.m_Sort] then
          q.rate = v[2] / count * eventSortTab[q.cfg.m_Sort]
        end
      end
    end
  end
  for i, v in pairs(dispatchTab) do
    for m, n in pairs(v) do
      dispatchEventList[#dispatchEventList + 1] = n
    end
  end
  
  local function sortFun(data1, data2)
    local cfg1 = data1.cfg
    local cfg2 = data2.cfg
    return cfg1.m_Grade > cfg2.m_Grade
  end
  
  table.sort(dispatchEventList, sortFun)
  return dispatchEventList
end

function CastleDispatchManager:GetNotDispatchEvent()
  local dispatchList = {}
  if self.m_DispatchList then
    for i, v in pairs(self.m_DispatchList) do
      if v.vHero and table.getn(v.vHero) == 0 and v.iRewardTime == 0 then
        dispatchList[i] = v
      end
    end
  end
  return dispatchList
end

function CastleDispatchManager:GetDispatchSlot(iGroupId, iEventId)
  local conditionTab = {}
  local grade = 0
  local cfg = self:GetCastleDispatchEventCfg(iGroupId, iEventId)
  local campNum = 0
  local qualitySum = 0
  if cfg then
    local slot = utils.changeCSArrayToLuaTable(cfg.m_Slot)
    for i, v in ipairs(slot) do
      conditionTab[i] = {
        camp = v[1],
        quality = v[2]
      }
      if v[1] ~= 0 then
        campNum = campNum + 1
      end
      qualitySum = qualitySum + v[2]
    end
    grade = cfg.m_Grade
  end
  return conditionTab, grade, campNum, qualitySum
end

function CastleDispatchManager:GetNotDispatchedHero(excludeTab)
  local heroes = {}
  local heroList = HeroManager:GetHeroList()
  for m, n in pairs(heroList) do
    local isDispatch = self:CheckDispatchedHero(n.characterCfg.m_HeroID)
    if not isDispatch and not table.Valueof(excludeTab, n.characterCfg.m_HeroID) then
      heroes[#heroes + 1] = n
    end
  end
  return heroes
end

function CastleDispatchManager:GetNotDispatchConditionList(sortDown)
  local dispatchConditionList = {}
  local notDispatchList = self:GetNotDispatchEvent()
  for i, v in pairs(notDispatchList) do
    local conditionTab, grade, campNum, qualitySum = self:GetDispatchSlot(v.iGroupId, v.iEventId)
    dispatchConditionList[#dispatchConditionList + 1] = {
      index = i,
      conditionTab = conditionTab,
      grade = grade,
      event = v,
      campNum = campNum,
      qualitySum = qualitySum
    }
  end
  
  local function sortFunUp(data1, data2)
    if data1.grade == data2.grade then
      if data1.campNum == data2.campNum then
        return data1.qualitySum > data2.qualitySum
      else
        return data1.campNum > data2.campNum
      end
    else
      return data1.grade > data2.grade
    end
  end
  
  local function sortFunDown(data1, data2)
    if data1.campNum == data2.campNum then
      if data1.qualitySum == data2.qualitySum then
        return data1.grade > data2.grade
      else
        return data1.qualitySum > data2.qualitySum
      end
    else
      return data1.campNum > data2.campNum
    end
  end
  
  if sortDown then
    table.sort(dispatchConditionList, sortFunDown)
  else
    table.sort(dispatchConditionList, sortFunUp)
  end
  return dispatchConditionList
end

function CastleDispatchManager:QuicklyOneTaskConditionDispatch(dispatchCondition, heroList)
  local heroTab = {}
  local excludeTab = {}
  local conditionTab = dispatchCondition.conditionTab
  for p, condition in ipairs(conditionTab) do
    local quality = 99
    for m, n in pairs(heroList) do
      local campFlag = n.characterCfg.m_Camp == condition.camp or condition.camp == 0
      local isExclude = table.Valueof(excludeTab, n.characterCfg.m_HeroID)
      if campFlag and not isExclude and n.characterCfg.m_Quality >= condition.quality and quality > n.characterCfg.m_Quality then
        if heroTab[p] then
          excludeTab[heroTab[p]] = nil
        end
        heroTab[p] = n.characterCfg.m_HeroID
        excludeTab[n.characterCfg.m_HeroID] = 1
        quality = n.characterCfg.m_Quality
      end
    end
  end
  if table.getn(conditionTab) == table.getn(heroTab) then
    return {
      index = dispatchCondition.index,
      event = dispatchCondition.event,
      heroTab = heroTab,
      isSelected = true,
      grade = dispatchCondition.grade
    }, excludeTab
  end
end

function CastleDispatchManager:QuicklyDispatch()
  local dispatchConditionList = self:GetNotDispatchConditionList()
  local dispatchList = {}
  local excludeTabs = {}
  local gradeSum = 0
  for i, v in ipairs(dispatchConditionList) do
    local heroList = self:GetNotDispatchedHero(excludeTabs)
    local dispatch, excludeTab = self:QuicklyOneTaskConditionDispatch(v, heroList)
    if dispatch then
      for heroID, n in pairs(excludeTab) do
        excludeTabs[heroID] = 1
      end
      dispatchList[#dispatchList + 1] = dispatch
      gradeSum = gradeSum + dispatch.grade
    end
  end
  local dispatchListDown, gradeSumDown = self:QuicklyDispatchSortDown()
  if gradeSum >= gradeSumDown then
    return dispatchList
  end
  return dispatchListDown
end

function CastleDispatchManager:QuicklyDispatchSortDown()
  local dispatchConditionList = self:GetNotDispatchConditionList(true)
  local dispatchList = {}
  local excludeTabs = {}
  local gradeSum = 0
  for i, v in ipairs(dispatchConditionList) do
    local heroList = self:GetNotDispatchedHero(excludeTabs)
    local dispatch, excludeTab = self:QuicklyOneTaskConditionDispatch(v, heroList)
    if dispatch then
      for heroID, n in pairs(excludeTab) do
        excludeTabs[heroID] = 1
      end
      dispatchList[#dispatchList + 1] = dispatch
      gradeSum = gradeSum + dispatch.grade
    end
  end
  return dispatchList, gradeSum
end

function CastleDispatchManager:GetDispatchMaxMinStar()
  local minGrade = 99
  local maxGrade = 0
  local lvCfg = self:GetCastleDispatchLevelCfg(self:GetDispatchLevel())
  local dispatchList = utils.changeCSArrayToLuaTable(lvCfg.m_DispatchList)
  local cfgIns = ConfigManager:GetConfigInsByName("CastleDispatchEvent")
  for i, v in ipairs(dispatchList) do
    local groupID = v[1]
    local cfgList = cfgIns:GetValue_ByGroupID(groupID)
    for m, n in pairs(cfgList) do
      if minGrade > n.m_Grade then
        minGrade = n.m_Grade
      end
      if maxGrade < n.m_Grade then
        maxGrade = n.m_Grade
      end
    end
  end
  return maxGrade, minGrade
end

function CastleDispatchManager:CheckAutoDispatchIsUnlock()
  return StatueShowroomManager:GetStatueEffectValue("StatueEffect_UnlockAutoDispatch") == 1
end

function CastleDispatchManager:CheckQuickReceiveDispatchIsUnlock()
  return StatueShowroomManager:GetStatueEffectValue("StatueEffect_UnlockAllReceive") == 1
end

function CastleDispatchManager:CheckFastDispatchIsUnlock()
  return StatueShowroomManager:GetStatueEffectValue("StatueEffect_UnlockFastDispatch") == 1
end

function CastleDispatchManager:CheckReceiveRedPoint()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CastleDispatch)
  if not openFlag then
    return 0
  end
  local flag = TimeUtil:GetServerTimeS() > LocalDataManager:GetIntSimple("Red_Point_CastleDispatch", 0)
  if flag then
    return 1
  end
  local redPoint = table.getn(self:GetCanGetRewardDispatchList())
  return redPoint
end

function CastleDispatchManager:CheckDispatchRedPoint()
  local isReceiveRed = self:CheckReceiveRedPoint()
  if isReceiveRed and isReceiveRed ~= 0 then
    return isReceiveRed
  end
  local isUnLockFast = self:CheckFastDispatchIsUnlock()
  local redPoint = 0
  if isUnLockFast then
    redPoint = table.getn(self:QuicklyDispatch()) or 0
    if 0 < redPoint then
      return redPoint
    end
  end
  if self.m_DispatchList then
    local lastCount = LocalDataManager:GetIntSimple("CastleDispatchCount", 0)
    local length = table.getn(self.m_DispatchList)
    if lastCount < length then
      return length - lastCount
    end
  end
  return redPoint
end

function CastleDispatchManager:SetRedPointFlag()
  LocalDataManager:SetIntSimple("Red_Point_CastleDispatch", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
end

return CastleDispatchManager
