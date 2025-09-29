local BaseManager = require("Manager/Base/BaseManager")
local LoungeManager = class("LoungeManager", BaseManager)
LoungeManager.SpineTouchType = {
  Default = 0,
  Down = 1,
  Up = 2,
  Drag = 3,
  BeginDrag = 4,
  EndDrag = 5,
  LongPress = 6
}
LoungeManager.SpineGestureType = {
  Click = 1,
  Drag = 2,
  DragBackAndForth = 3,
  PropClick = 4,
  LongPressButton = 5,
  GetItemClick = 6
}
LoungeManager.HeroType = {Hero = 1, Special = 2}
LoungeManager.BiteType = {
  Focus = 1,
  Idle = 2,
  Bond = 3
}
LoungeManager.__MiniGameOver = 9999
LoungeManager.sLocalStatus = "LoungeManager_LocalStatus"
LoungeManager.sLocalParts = "LoungeManager_LocalParts"

function LoungeManager:OnCreate()
  self.m_LoungeCharCfg = {}
  self.m_LoungeCharPartsCfg = {}
  self.m_LoungeCharProcessCfg = {}
  self.m_LoungeCharPartsCollisionTab = {}
  self.m_LoungeCharPartsActionTab = {}
  self.m_gestureDragBackAndForthTab = {
    positiveNumber = {},
    negativeNumber = {}
  }
  self.m_loungeLevelUpCfgList = {}
  self.m_loungeCharIdleCfg = {}
  self.m_clientLoungeData = {}
end

function LoungeManager:OnInitNetwork()
end

function LoungeManager:OnComplianceSwitch()
  self:OnAfterInitConfig()
end

function LoungeManager:OnAfterFreshData()
end

function LoungeManager:OnAfterInitConfig()
  local loungeValueLevelIns = ConfigManager:GetConfigInsByName("LoungeValueLevel")
  local loungeValueLevelCfgAll = loungeValueLevelIns:GetAll()
  if loungeValueLevelCfgAll then
    for i, v in pairs(loungeValueLevelCfgAll) do
      self.m_loungeLevelUpCfgList[v.m_Level] = v
    end
  end
  local loungeIns = ConfigManager:GetConfigInsByName("LoungeChar")
  local loungeCfgAll = loungeIns:GetAll()
  if loungeCfgAll then
    for i, v in pairs(loungeCfgAll) do
      self.m_LoungeCharCfg[v.m_ID] = v
    end
  end
  local loungeCharPartIns = ConfigManager:GetConfigInsByName("LoungeCharParts")
  local loungeCharPartsCfgAll = loungeCharPartIns:GetAll()
  if loungeCharPartsCfgAll then
    for i, v in pairs(loungeCharPartsCfgAll) do
      self.m_LoungeCharPartsCfg[v.m_ID] = v
    end
  end
  local loungeCharIdleIns = ConfigManager:GetConfigInsByName("LoungeCharIdle")
  local loungeCharIdleCfgAll = loungeCharIdleIns:GetAll()
  if loungeCharIdleCfgAll then
    for i, v in pairs(loungeCharIdleCfgAll) do
      if not self.m_loungeCharIdleCfg[i] then
        self.m_loungeCharIdleCfg[i] = {}
      end
      for m, n in pairs(v) do
        self.m_loungeCharIdleCfg[i][m] = n
      end
    end
  end
  if self.m_LoungeCharCfg then
    for i, v in pairs(self.m_LoungeCharCfg) do
      if v.m_Collision then
        local collisions = utils.changeCSArrayToLuaTable(v.m_Collision)
        for _, id in pairs(collisions) do
          local cfg = loungeCharPartIns:GetValue_ByID(id)
          if not cfg:GetError() then
            if cfg.m_Collision and cfg.m_Collision ~= "" then
              if not self.m_LoungeCharPartsCollisionTab[v.m_ID] then
                self.m_LoungeCharPartsCollisionTab[v.m_ID] = {}
              end
              if not self.m_LoungeCharPartsCollisionTab[v.m_ID][cfg.m_State] then
                self.m_LoungeCharPartsCollisionTab[v.m_ID][cfg.m_State] = {}
              end
              local gestureParameters = utils.changeCSArrayToLuaTable(cfg.m_GestureParameters)
              self.m_LoungeCharPartsCollisionTab[v.m_ID][cfg.m_State][cfg.m_Collision] = {
                boneName = cfg.m_BoneName,
                action = cfg.m_Action,
                gesture = cfg.m_Gesture,
                gestureParameters = gestureParameters,
                voice = cfg.m_Voice,
                subtitle = cfg.m_Subtitle,
                cfg = cfg,
                heroId = v.m_ID
              }
            end
            if cfg.m_Action and cfg.m_Action ~= "" then
              if not self.m_LoungeCharPartsActionTab[v.m_ID] then
                self.m_LoungeCharPartsActionTab[v.m_ID] = {}
              end
              if not self.m_LoungeCharPartsActionTab[v.m_ID][cfg.m_State] then
                self.m_LoungeCharPartsActionTab[v.m_ID][cfg.m_State] = {}
              end
              self.m_LoungeCharPartsActionTab[v.m_ID][cfg.m_State][cfg.m_Action] = {
                cfg = cfg,
                heroId = v.m_ID
              }
            end
          end
        end
      end
    end
  end
  local loungeCharProcessIns = ConfigManager:GetConfigInsByName("LoungeCharProcess")
  local loungeCharProcessCfgAll = loungeCharProcessIns:GetAll()
  if loungeCharProcessCfgAll then
    for i, v in pairs(loungeCharProcessCfgAll) do
      self.m_LoungeCharProcessCfg[v.m_ID] = v
    end
  end
  LoungeManager.LoungeBondStatus = {
    Init = MTTDProto.LoungeBondStatus_Init,
    Unlock = MTTDProto.LoungeBondStatus_Unlock,
    Bond = MTTDProto.LoungeBondStatus_Bond
  }
  self.m_LoungeValueEmpty = tonumber(ConfigManager:GetGlobalSettingsByKey("LoungeValueEmpty") or 0)
end

function LoungeManager:ReqAttractLoungeBondCS(iHeroId)
  local reqMsg = MTTDProto.Cmd_Attract_LoungeBond_CS()
  reqMsg.iHeroId = iHeroId
  RPCS():Attract_LoungeBond(reqMsg, handler(self, self.OnReqAttractLoungeBondSC))
end

function LoungeManager:OnReqAttractLoungeBondSC(stData, msg)
  AttractManager:SetHeroLoungeDataById(stData.iHeroId, stData)
  self:broadcastEvent("eGameEvent_Lounge_Mark", stData)
end

function LoungeManager:GetLoungeCharCfgById(id)
  return self.m_LoungeCharCfg[id]
end

function LoungeManager:GetLoungeCharIdleCfgById(id, state)
  if not id or not state then
    return
  end
  if not self.m_loungeCharIdleCfg[id] then
    return
  end
  return self.m_loungeCharIdleCfg[id][state]
end

function LoungeManager:GetLoungeCharPartsCfgById(partId)
  return self.m_LoungeCharPartsCfg[partId]
end

function LoungeManager:GetLoungeCharProcessCfgByID(id)
  return self.m_LoungeCharProcessCfg[id]
end

function LoungeManager:GetLoungeComfortLevelCfgByLv(lv)
  local cfgIns = ConfigManager:GetConfigInsByName("LoungeComfortLevel")
  local cfg = cfgIns:GetValue_ByLevel(lv)
  if cfg:GetError() then
    return
  end
  return cfg
end

function LoungeManager:GetLoungeItemCfgById(id)
  local cfgIns = ConfigManager:GetConfigInsByName("LoungeItem")
  local cfg = cfgIns:GetValue_ByID(id)
  if cfg:GetError() then
    return
  end
  return cfg
end

function LoungeManager:InitClientLoungeData(iHeroId, bIsReset)
  self.m_clientLoungeData = {}
  self.m_clientLoungeData.iHeroId = iHeroId
  local iLocalStatus = bIsReset and LoungeManager.LoungeBondStatus.Init or LocalDataManager:GetIntSimple(LoungeManager.sLocalStatus .. iHeroId, LoungeManager.LoungeBondStatus.Init)
  self.m_clientLoungeData.iStatus = iLocalStatus
  self:FormatLocalClientLoungeData(iHeroId, bIsReset)
end

function LoungeManager:FormatLocalClientLoungeData(iHeroId, bIsReset)
  local str = bIsReset and "" or LocalDataManager:GetStringSimple(LoungeManager.sLocalParts .. iHeroId, "")
  local t = {}
  local clientData = string.split(str, ",")
  for _, v in ipairs(clientData) do
    table.insert(t, tonumber(v))
  end
  self.m_clientLoungeData.vParts = t
end

function LoungeManager:SetClientLoungeParts(heroId, iPart)
  if not self.m_clientLoungeData or self.m_clientLoungeData.iHeroId ~= heroId then
    self:InitClientLoungeData(heroId)
  end
  if not self.m_clientLoungeData.vParts then
    self.m_clientLoungeData.vParts = {}
  end
  local index = table.indexof(self.m_clientLoungeData.vParts, iPart)
  if not index then
    table.insert(self.m_clientLoungeData.vParts, iPart)
    LocalDataManager:SetStringSimple(LoungeManager.sLocalParts .. heroId, table.concat(self.m_clientLoungeData.vParts, ","))
  end
end

function LoungeManager:SetClientLoungeState(heroId, iState)
  if not self.m_clientLoungeData or self.m_clientLoungeData.iHeroId ~= heroId then
    self:InitClientLoungeData(heroId)
  end
  self.m_clientLoungeData.iStatus = iState
  LocalDataManager:SetIntSimple(LoungeManager.sLocalStatus .. heroId, iState)
end

function LoungeManager:GetLoungeHeroRealStatus(iHeroId)
  local data = AttractManager:GetHeroLoungeDataById(iHeroId)
  if data then
    return data.iStatus
  end
  return LoungeManager.LoungeBondStatus.Init
end

function LoungeManager:GetLoungeDataByHeroId(iHeroId)
  if not self.m_clientLoungeData or self.m_clientLoungeData.iHeroId ~= iHeroId then
    self:InitClientLoungeData(iHeroId)
  end
  return self.m_clientLoungeData
end

function LoungeManager:CheckPartsIsInteraction(iHeroId, partId)
  local data = self:GetLoungeDataByHeroId(iHeroId)
  if data and data.vParts then
    for _, v in pairs(data.vParts) do
      if v == partId then
        return true
      end
    end
  end
end

function LoungeManager:GetCollisionAction(collisionList)
  local collisionAction = {}
  local boneNameList = {}
  if table.getn(collisionList) > 0 then
    for _, collisionId in ipairs(collisionList) do
      local cfg = self:GetLoungeCharPartsCfgById(collisionId)
      if cfg then
        collisionAction[cfg.m_Collision] = cfg.m_Action
        boneNameList[cfg.m_Collision] = cfg.m_BoneName
      end
    end
  end
  return collisionAction, boneNameList
end

function LoungeManager:GetHeroCurState(heroId)
  local state
  local partId, partCfg = self:GetCurPartByHeroId(heroId)
  if partId and partCfg then
    if partCfg.m_ChangeAction and partCfg.m_ChangeAction ~= "" then
      state = partCfg.m_ChangeAction
    else
      state = partCfg.m_State
    end
  else
    local cfg = self:GetLoungeCharCfgById(heroId)
    if cfg then
      state = cfg.m_DefaultIdle
    end
  end
  return state
end

function LoungeManager:GetSpineStateByIdAndState(heroId, state)
  state = state or self:GetHeroCurState(heroId)
  local cfg = self:GetLoungeCharIdleCfgById(heroId, state)
  if cfg then
    return cfg.m_SpineIdle, cfg.m_SpineIdleSubtitle, cfg.m_SpineIdleVoice
  else
    state = self:GetHeroCurState(heroId)
    cfg = self:GetLoungeCharIdleCfgById(heroId, state)
    if cfg then
      return cfg.m_SpineIdle, cfg.m_SpineIdleSubtitle, cfg.m_SpineIdleVoice
    end
  end
  log.error("GetSpineStateById LoungeCharCfg is null heroId == " .. tostring(heroId))
  return "idle_01"
end

function LoungeManager:GetSpineRandomIdleById(heroId, state)
  local cfg = self:GetLoungeCharIdleCfgById(heroId, state)
  if cfg then
    return cfg.m_SpineIdleShow, cfg.m_SpineIdleShowSubtitle, cfg.m_SpineIdleShowVoice
  end
  log.error("GetSpineRandomIdleById LoungeCharCfg is null heroId == " .. tostring(heroId))
  return "Lounge_Idle_01"
end

function LoungeManager:GetSpineRefuseActionById(heroId, state)
  local cfg = self:GetLoungeCharIdleCfgById(heroId, state)
  if cfg then
    return cfg.m_SpineRefuse, cfg.m_SpineRefuseSubtitle, cfg.m_SpineRefuseVoice
  end
  return "touch_refuse_01"
end

function LoungeManager:GetSpineEngravingActionById(heroId, biteType)
  local cfg = self:GetLoungeCharCfgById(heroId)
  local bitFocus = {}
  if cfg then
    local engraveRefuse = utils.changeCSArrayToLuaTable(cfg.m_EngravingRefuse)
    for i, v in ipairs(engraveRefuse) do
      local partCfg = self:GetLoungeCharPartsCfgById(v)
      if partCfg then
        table.insert(bitFocus, partCfg)
      end
    end
    if bitFocus[biteType] then
      local subTitle = utils.changeCSArrayToLuaTable(bitFocus[biteType].m_Subtitle) or {}
      return bitFocus[biteType].m_Action, subTitle[1], bitFocus[biteType].m_Voice, bitFocus[biteType]
    end
  end
end

function LoungeManager:GetLoungeCharPartsCollisionCfgByHeroId(heroId)
  if self.m_LoungeCharPartsCollisionTab then
    return self.m_LoungeCharPartsCollisionTab[heroId]
  end
end

function LoungeManager:GetLoungeCharPartsActionCfgByHeroId(heroId)
  if self.m_LoungeCharPartsActionTab then
    return self.m_LoungeCharPartsActionTab[heroId]
  end
end

function LoungeManager:GetSpineActionByStateAndAction(heroId, state, action)
  if not state or not action then
    return
  end
  local cfgTab = self:GetLoungeCharPartsActionCfgByHeroId(heroId)
  if cfgTab and cfgTab[state] then
    return cfgTab[state][action]
  end
end

function LoungeManager:GetSpineActionByStateAndCollision(heroId, state, collision)
  if not state or not collision then
    return
  end
  local cfgTab = self:GetLoungeCharPartsCollisionCfgByHeroId(heroId)
  if cfgTab and cfgTab[state] then
    return cfgTab[state][collision]
  end
end

local __LoungeGestureCondition = {}
__LoungeGestureCondition[LoungeManager.SpineGestureType.Click] = function(param, collisionAction)
  return collisionAction
end
__LoungeGestureCondition[LoungeManager.SpineGestureType.Drag] = function(param, collisionAction)
  if param.startPoint and param.point and collisionAction.gestureParameters then
    local list = collisionAction.gestureParameters
    if list and list[1] then
      local signed = math.GetProjOnAngle(param.startPoint, param.point, list[1])
      if list[2] and signed >= list[2] then
        return collisionAction
      end
    end
  end
end
__LoungeGestureCondition[LoungeManager.SpineGestureType.DragBackAndForth] = function(param, collisionAction)
  if collisionAction.gestureParameters then
    local list = collisionAction.gestureParameters
    if list and list[1] and list[2] and param.count and param.count >= list[2] then
      return collisionAction
    end
  end
end
__LoungeGestureCondition[LoungeManager.SpineGestureType.PropClick] = function(param, collisionAction)
  return collisionAction
end
__LoungeGestureCondition[LoungeManager.SpineGestureType.LongPressButton] = function(param, collisionAction)
  if collisionAction.gestureParameters then
    local list = collisionAction.gestureParameters
    if param.pressTime and list[1] then
      local time = math.floor(list[1] / 1000)
      if time <= param.pressTime then
        return collisionAction
      end
    end
  end
end
__LoungeGestureCondition[LoungeManager.SpineGestureType.GetItemClick] = function(param, collisionAction)
  return collisionAction
end

function LoungeManager:CheckGestureActionByParam(heroId, params)
  local state = params.state
  local collision = params.collision
  local collisionAction = self:GetSpineActionByStateAndCollision(heroId, state, collision)
  if not collisionAction or not collisionAction.cfg then
    return
  end
  local refAction, subTitle, voice = self:GetSpineRefuseActionById(heroId)
  local refuseData = {
    refuseAction = refAction,
    subTitle = subTitle,
    voice = voice
  }
  local isOver = self:CheckKeyStepsIsOver(heroId, collisionAction.cfg.m_ID)
  if not isOver then
    return nil, refuseData
  end
  local gesture = collisionAction.gesture
  if not gesture then
    return
  end
  local data, reActionDate
  if __LoungeGestureCondition[gesture] then
    if gesture == LoungeManager.SpineGestureType.DragBackAndForth and params.startPoint and params.point then
      local list = collisionAction.gestureParameters
      local signed = math.GetProjOnAngle(params.startPoint, params.point, list[1])
      local num = self:SetGestureDragBackAndForthValue(signed)
      params.count = num
    end
    data = __LoungeGestureCondition[gesture](params, collisionAction)
    reActionDate = collisionAction
  end
  return data, nil, reActionDate
end

function LoungeManager:CheckKeyStepsIsOver(heroId, partId)
  local data = self:GetLoungeDataByHeroId(heroId)
  local miniGameStep = self:GetLoungeCharPartsCfgById(partId)
  if data and miniGameStep and miniGameStep.m_LoungeMinigame ~= 0 and miniGameStep.m_LoungeMinigame ~= LoungeManager.__MiniGameOver then
    if data.vParts then
      for _, v in pairs(data.vParts) do
        local cfg = self:GetLoungeCharPartsCfgById(v)
        if cfg and cfg.m_LoungeItemID == miniGameStep.m_LoungeMinigame then
          return true
        end
      end
    end
    return false
  end
  return true
end

function LoungeManager:CheckIsCanBindBone(heroId, params)
  self:ResetGestureDragBackAndForthTab()
  local state = params.state
  local collision = params.collision
  local collisionAction = self:GetSpineActionByStateAndCollision(heroId, state, collision)
  if not collisionAction then
    return
  end
  return collisionAction.boneName
end

function LoungeManager:ResetGestureDragBackAndForthTab()
  if not self.m_gestureDragBackAndForthTab then
    self.m_gestureDragBackAndForthTab = {}
    self.m_gestureDragBackAndForthTab.negativeNumber = {}
    self.m_gestureDragBackAndForthTab.positiveNumber = {}
    return
  end
  self.m_gestureDragBackAndForthTab.negativeNumber = {}
  self.m_gestureDragBackAndForthTab.positiveNumber = {}
end

function LoungeManager:SetGestureDragBackAndForthValue(value)
  if not self.m_gestureDragBackAndForthTab then
    self:ResetGestureDragBackAndForthTab()
  end
  if 0 < value then
    table.insert(self.m_gestureDragBackAndForthTab.positiveNumber, value)
  else
    table.insert(self.m_gestureDragBackAndForthTab.negativeNumber, value)
  end
  local realNum = math.min(#self.m_gestureDragBackAndForthTab.positiveNumber, #self.m_gestureDragBackAndForthTab.negativeNumber)
  return realNum
end

function LoungeManager:GetLoungeAttrByPropertyIDs(propertyIDList)
  local attrList = {}
  for i, v in ipairs(propertyIDList) do
    local attrInfoList = AttractManager:GetBaseAttr(v)
    for m, n in ipairs(attrInfoList) do
      local isHave = false
      for p, q in ipairs(attrList) do
        if n.id == q.id then
          attrList[p].num = n.num + q.num
          isHave = true
        end
      end
      if not isHave then
        attrList[#attrList + 1] = {
          cfg = n.cfg,
          num = n.num,
          id = n.id
        }
      end
    end
    table.sort(attrList, function(a, b)
      return a.id < b.id
    end)
  end
  if table.getn(attrList) == 0 then
    attrList = self:GetBaseAttrsInfo()
  end
  return attrList
end

function LoungeManager:GetBaseAttrsInfo()
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local propertyCfg = PropertyIns:GetValue_ByPropertyID(self.m_LoungeValueEmpty)
  local retParamList = {}
  if propertyCfg:GetError() == true then
    return retParamList
  end
  for i = 1, 4 do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
    retParamList[i] = {
      cfg = propertyIndexCfg,
      num = 0,
      id = i
    }
  end
  return retParamList
end

function LoungeManager:GetHeroChangeList()
  local list = {}
  for k, v in pairs(self.m_LoungeCharCfg) do
    if v.m_Type == LoungeManager.HeroType.Hero then
      list[#list + 1] = v
    end
  end
  return list
end

function LoungeManager:CheckHeroLoungeUnlockById(heroId)
  local isUnlock = false
  local isLoungeHero = false
  local cfg = self:GetLoungeCharCfgById(heroId)
  if not cfg then
    return isUnlock, isLoungeHero
  else
    isLoungeHero = true
  end
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Lounge)
  if not openFlag then
    return isUnlock, isLoungeHero, tips_id
  end
  local tipStr = ""
  if cfg.m_Type == LoungeManager.HeroType.Hero then
    local heroData = HeroManager:GetHeroDataByID(heroId)
    if utils.isNull(heroData) then
      isUnlock = false
      isLoungeHero = true
      tipStr = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40056), cfg.m_UnlockLimitBreakLevel)
      return isUnlock, isLoungeHero, tipStr
    end
    if heroData and heroData.serverData and cfg.m_UnlockLimitBreakLevel then
      local heroBreak = heroData.serverData.iBreak
      isUnlock = heroBreak >= cfg.m_UnlockLimitBreakLevel and true or false
      if not isUnlock then
        tipStr = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(cfg.m_UnlockClientMessage), cfg.m_UnlockLimitBreakLevel)
      end
    end
  end
  return isUnlock, isLoungeHero, tipStr
end

function LoungeManager:CheckHeroLoungeHaveRedDot(heroId)
  local redDot = 0
  if heroId then
    local isUnlock = self:CheckHeroLoungeUnlockById(heroId)
    local iStatus = self:GetLoungeHeroRealStatus(heroId)
    if isUnlock and iStatus ~= LoungeManager.LoungeBondStatus.Bond then
      redDot = redDot + 1
    end
  else
    local heroList = self:GetHeroChangeList()
    for k, v in ipairs(heroList) do
      local isUnlock = self:CheckHeroLoungeUnlockById(v.m_ID)
      local iStatus = self:GetLoungeHeroRealStatus(v.m_ID)
      if isUnlock and iStatus ~= LoungeManager.LoungeBondStatus.Bond then
        redDot = redDot + 1
      end
    end
  end
  return redDot
end

function LoungeManager:CheckLoungeUnlock()
  local heroList = self:GetHeroChangeList()
  for k, v in ipairs(heroList) do
    local isUnlock = self:CheckHeroLoungeUnlockById(v.m_ID)
    if isUnlock then
      return true
    end
  end
  return false
end

function LoungeManager:GetOneLoungeHeroCfg()
  local heroList = {}
  for k, v in pairs(self.m_LoungeCharCfg) do
    local isUnlock = self:CheckHeroLoungeUnlockById(v.m_ID)
    if v.m_Type == LoungeManager.HeroType.Hero and isUnlock then
      heroList[#heroList + 1] = v
    end
  end
  if 0 < #heroList then
    table.sort(heroList, function(a, b)
      return a.m_Sort < b.m_Sort
    end)
    return heroList[1]
  end
end

function LoungeManager:GetCurPartByHeroId(iHeroId)
  local data = self:GetLoungeDataByHeroId(iHeroId)
  if data and table.getn(data.vParts) > 0 then
    local vParts = data.vParts
    table.sort(vParts, function(a, b)
      return b < a
    end)
    local cfg
    if vParts[1] then
      cfg = self:GetLoungeCharPartsCfgById(vParts[1])
    end
    return vParts[1], cfg
  end
end

function LoungeManager:GetHeroUnlockPartList(heroId, state)
  local partList = {}
  local partMap = {}
  local data = self:GetLoungeDataByHeroId(heroId)
  if data and state then
    for id, v in pairs(self.m_LoungeCharPartsCollisionTab) do
      if id == heroId then
        for idle, n in pairs(v) do
          if idle == state then
            for p, q in pairs(n) do
              if q.cfg then
                partList[#partList + 1] = q.cfg.m_ID
                partMap[q.cfg.m_ID] = q.cfg.m_ID
              end
            end
          end
        end
      end
    end
  end
  return partList, partMap
end

function LoungeManager:CheckHeroIsBond(heroId)
  if not heroId then
    return
  end
  local iStatus = self:GetLoungeHeroRealStatus(heroId)
  if iStatus == LoungeManager.LoungeBondStatus.Bond then
    return true
  end
end

function LoungeManager:GetLoungeAllAttrsId()
  local attrIdList = {}
  local exp = 0
  local heroList = self:GetHeroChangeList()
  for k, v in ipairs(heroList) do
    local flag = self:CheckHeroIsBond(v.m_ID)
    if flag then
      local cfg = self:GetLoungeCharCfgById(v.m_ID)
      if cfg then
        exp = exp + cfg.m_LevelExp
        attrIdList[#attrIdList + 1] = cfg.m_PropertyID
      end
    end
  end
  local lv = self:GetLoungeAttrLvByExp(exp)
  return attrIdList, lv
end

function LoungeManager:GetBefLvUpAttrsById(heroId)
  local oldAttrIdList = {}
  local exp = 0
  local heroList = self:GetHeroChangeList()
  for k, v in pairs(heroList) do
    if v.m_ID ~= heroId then
      local flag = self:CheckHeroIsBond(v.m_ID)
      if flag then
        local cfg = self:GetLoungeCharCfgById(v.m_ID)
        if cfg then
          exp = exp + cfg.m_LevelExp
          oldAttrIdList[#oldAttrIdList + 1] = cfg.m_PropertyID
        end
      end
    end
  end
  local lv = self:GetLoungeAttrLvByExp(exp)
  return oldAttrIdList, lv
end

function LoungeManager:GetLoungeAttrLvByExp(exp)
  local lv = 0
  if exp == 0 then
    return lv
  end
  local curExp = exp
  for k, v in ipairs(self.m_loungeLevelUpCfgList) do
    curExp = curExp - v.m_LevelExp
    if curExp == 0 then
      return v.m_Level
    elseif curExp < 0 then
      return v.m_Level - 1
    end
  end
  return lv
end

function LoungeManager:GetMiniGameOverAction(heroId)
  local action, changeAction, id
  local cfg = self:GetLoungeCharCfgById(heroId)
  if cfg then
    local partId = cfg.m_MinigameOverIdle
    if partId and partId ~= 0 then
      local pCfg = self:GetLoungeCharPartsCfgById(partId)
      if pCfg then
        action = pCfg.m_Action
        changeAction = pCfg.m_ChangeAction
        id = partId
      end
    end
  end
  return action, changeAction, id
end

function LoungeManager:GetSpineAllIdleById(heroId)
  local idleList = {}
  if self.m_loungeCharIdleCfg[heroId] then
    for i, v in pairs(self.m_loungeCharIdleCfg[heroId]) do
      idleList[#idleList + 1] = i
    end
  end
  return idleList
end

local __AudioMap = {}

function __AudioMap.touch_unlock_02()
  GlobalManagerIns:TriggerWwiseBGMState(405)
end

function __AudioMap.touch_unlock_01()
  GlobalManagerIns:TriggerWwiseBGMState(402)
end

function __AudioMap.key_off()
  GlobalManagerIns:TriggerWwiseBGMState(401)
end

function __AudioMap.key_up()
  GlobalManagerIns:TriggerWwiseBGMState(411)
end

function __AudioMap:key_idle_02()
  GlobalManagerIns:TriggerWwiseBGMState(403)
end

function __AudioMap.key_in()
  GlobalManagerIns:TriggerWwiseBGMState(400)
end

function __AudioMap.touch_hand_03()
  GlobalManagerIns:TriggerWwiseBGMState(412)
end

function __AudioMap.bite_climax()
  GlobalManagerIns:TriggerWwiseBGMState(397)
end

function __AudioMap.touch_breast_03()
  TimeService:SetTimer(0.5, 1, function()
    GlobalManagerIns:TriggerWwiseBGMState(413)
  end)
end

function __AudioMap.touch_breast_04()
  TimeService:SetTimer(0.5, 1, function()
    GlobalManagerIns:TriggerWwiseBGMState(413)
  end)
end

function __AudioMap.touch_leg_03()
  TimeService:SetTimer(0.7, 1, function()
    GlobalManagerIns:TriggerWwiseBGMState(408)
  end)
end

function __AudioMap.touch_leg_04()
  TimeService:SetTimer(0.7, 1, function()
    GlobalManagerIns:TriggerWwiseBGMState(408)
  end)
end

function __AudioMap.touch_head_02()
  GlobalManagerIns:TriggerWwiseBGMState(424)
end

function LoungeManager:CheckPlayAudio(action)
  local func = __AudioMap[action]
  if func then
    func(self)
  end
end

return LoungeManager
