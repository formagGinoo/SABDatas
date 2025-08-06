local BaseManager = require("Manager/Base/BaseManager")
local GuideManager = class("GuideManager", BaseManager)
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local ReportFinishForceGuideID = 81

function GuideManager:OnCreate()
  self.guideStepConfData = nil
  self.guideSubStepConfDic = nil
  self.guideWnds = {}
  self.guideLevelIds = {}
  self.guideItemIds = {}
  self.completeGuideDic = {}
  self.activeGuides = {}
  self:addEventListener("eGameEvent_WndActive", handler(self, self.OnEventWndActive))
  self:addEventListener("eGameEvent_WndInactive", handler(self, self.OnEventWndInactive))
  self:addEventListener("eGameEvent_EnterLevel", handler(self, self.OnEnterLevel))
  self:addEventListener("eGameEvent_ExitLevel", handler(self, self.OnExitLevel))
  self:addEventListener("eGameEvent_MainTask_Jump_Guide", handler(self, self.OnTaskJump))
  self:addEventListener("eGameEvent_ExplorePlayerMove", handler(self, self.OnlegacygPlayerMove))
  self.timeSchedulers = {}
  self.timeCallbacks = {}
  self.mCurrentFrame = 0
  self.frameSchedulers = {}
  self.frameCallbacks = {}
  self.ShowGuide = true
  self.InitNetwork = false
  self.SkipGuideId = 999999
end

function GuideManager:OnInitNetwork()
  self.InitNetwork = true
end

function GuideManager:OnInitEventListener()
  self.InitEventListener = true
end

function GuideManager:OnGuideGetListSC(retData, msg)
  local mGuideData = retData.mGuideData
  for k, v in pairs(mGuideData) do
    if 0 < v then
      self.completeGuideDic[k] = k
      GuideManager:GuideDebug("guide_服务器同步已完成引导:" .. k)
    end
  end
end

function GuideManager:ReqFinishGuide(guideId)
  if not self.InitNetwork then
    return
  end
  GuideManager:GuideDebug("guide_上报服务器完成引导:" .. guideId)
  local reqMsg = MTTDProto.Cmd_Guide_SetGuide_CS()
  reqMsg.iGuideId = guideId
  reqMsg.iGuideStep = guideId
  RPCS():Guide_SetGuide(reqMsg, handler(self, self.OnFinishGuideSC))
end

function GuideManager:OnFinishGuideSC(retData, msg)
  if retData and retData.iGuideId == ReportFinishForceGuideID then
    ReportManager:ReportTrackAttributionEvent("complete_trial", {})
  end
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_WelfareShow)
  if stActivity then
    stActivity:SetPushFaceGuideStep(retData.iGuideId)
  end
end

function GuideManager:AddFrame(frame, func, parms, key)
  local fscheduler = {}
  fscheduler.Frame = frame
  fscheduler.RealFrame = frame + self.mCurrentFrame
  fscheduler.IsLoop = false
  fscheduler.Callback = func
  fscheduler.Parms = parms
  fscheduler.Key = tostring(key)
  table.insert(self.frameSchedulers, fscheduler)
end

function GuideManager:AddLoopFrame(frame, func, parms, key)
  local fscheduler = {}
  fscheduler.Frame = frame
  fscheduler.RealFrame = frame + self.mCurrentFrame
  fscheduler.IsLoop = true
  fscheduler.Callback = func
  fscheduler.Parms = parms
  fscheduler.Key = tostring(key)
  table.insert(self.frameSchedulers, fscheduler)
end

function GuideManager:AddTimer(time, func, parms, key)
  local tscheduler = {}
  tscheduler.Time = time
  tscheduler.RealTime = time + CS.UnityEngine.Time.realtimeSinceStartup
  tscheduler.IsLoop = false
  tscheduler.Callback = func
  tscheduler.Parms = parms
  tscheduler.Key = tostring(key)
  table.insert(self.timeSchedulers, tscheduler)
end

function GuideManager:AddLoopTimer(time, func, parms, key)
  local tscheduler = {}
  tscheduler.Time = time
  tscheduler.RealTime = time + CS.UnityEngine.Time.realtimeSinceStartup
  tscheduler.IsLoop = true
  tscheduler.Callback = func
  tscheduler.Parms = parms
  tscheduler.Key = tostring(key)
  table.insert(self.timeSchedulers, tscheduler)
end

function GuideManager:RemoveFrameByKey(key)
  if key == nil then
    return
  end
  for i = #self.frameSchedulers, 1, -1 do
    local sch = self.frameSchedulers[i]
    if sch.Key == tostring(key) then
      sch.isDirty = true
      table.remove(self.frameSchedulers, i)
    end
  end
end

function GuideManager:RemoveTimerByKey(key)
  if key == nil then
    return
  end
  for i = #self.timeSchedulers, 1, -1 do
    local sch = self.timeSchedulers[i]
    if sch.Key == tostring(key) then
      sch.isDirty = true
      table.remove(self.timeSchedulers, i)
    end
  end
end

function GuideManager:UpdateTimeScheduler()
  for i = #self.timeSchedulers, 1, -1 do
    local sch = self.timeSchedulers[i]
    if sch then
      if sch.RealTime < CS.UnityEngine.Time.realtimeSinceStartup then
        if sch.isDirty then
          table.remove(self.timeSchedulers, i)
        else
          if sch.Callback ~= nil then
            table.insert(self.timeCallbacks, sch)
          end
          if sch.IsLoop then
            sch.RealTime = CS.UnityEngine.Time.realtimeSinceStartup + sch.Time
          else
            table.remove(self.timeSchedulers, i)
          end
        end
      end
    else
      table.remove(self.timeSchedulers, i)
    end
  end
  for i = #self.timeCallbacks, 1, -1 do
    local sch = self.timeCallbacks[i]
    if not sch.isDirty then
      local ret = xpcall(sch.Callback, ErrorHandler, sch.Parms)
      if not ret then
        sch.isDirty = true
      end
    end
    table.remove(self.timeCallbacks, i)
  end
end

function GuideManager:UpdateFrameScheduler()
  self.mCurrentFrame = self.mCurrentFrame + 1
  for i = #self.frameSchedulers, 1, -1 do
    local sch = self.frameSchedulers[i]
    if sch then
      if sch.RealFrame < self.mCurrentFrame then
        if sch.isDirty then
          table.remove(self.frameSchedulers, i)
        else
          if sch.Callback ~= nil then
            table.insert(self.frameCallbacks, sch)
          end
          if sch.IsLoop then
            sch.RealFrame = sch.RealFrame + sch.Frame
          else
            table.remove(self.frameSchedulers, i)
          end
        end
      end
    else
      table.remove(self.frameSchedulers, i)
    end
  end
  for i = #self.frameCallbacks, 1, -1 do
    local sch = self.frameCallbacks[i]
    if not sch.isDirty then
      local ret = xpcall(sch.Callback, ErrorHandler, sch.Parms)
      if not ret then
        sch.isDirty = true
      end
    end
    table.remove(self.frameCallbacks, i)
  end
end

function GuideManager:OnUpdate(dt)
  self:UpdateTimeScheduler()
  self:UpdateFrameScheduler()
end

function GuideManager:InitGuideConfData()
  if not ConfigManager.InitConfigFinish then
    return
  end
  if self.guideStepConfData == nil then
    local guideStepDatas = CS.CData_GuideStep.GetInstance():GetAll()
    if guideStepDatas == nil or guideStepDatas.Count == 0 then
      return
    end
    self.guideStepConfData = {}
    for k, v in pairs(guideStepDatas) do
      local itemData = {}
      itemData.ID = k
      itemData.EventType = v.m_EventType
      itemData.EventParam = v.m_EventParam
      itemData.SubStepIds = v.m_SubStepIds
      itemData.Priority = v.m_Priority
      itemData.IsRepeat = v.m_IsRepeat
      itemData.IsOn = v.m_IsOn
      itemData.ConditionType = v.m_ConditionType
      itemData.ConditionParam = v.m_ConditionParam
      itemData.CheckOut = v.m_CheckOut
      table.insert(self.guideStepConfData, itemData)
      for i = 0, itemData.EventType.Length - 1 do
        local eventType = itemData.EventType[i]
        local eventParam = itemData.EventParam[i]
        if eventType == 1 or eventType == 6 then
          self.guideWnds[eventParam] = eventParam
        elseif eventType == 2 then
          self.guideLevelIds[tonumber(eventParam)] = tonumber(eventParam)
        elseif eventType == 7 then
          self.guideLevelIds[tonumber(eventParam)] = tonumber(eventParam)
        elseif eventType == 5 then
          self.guideItemIds[tonumber(eventParam)] = tonumber(eventParam)
        end
      end
      itemData.FinishConditionType = v.m_FinishConditionType
      itemData.FinishConditionParam = v.m_FinishConditionParam
      self:CheckFinishCondition(itemData)
    end
  end
  if self.guideSubStepConfDic == nil then
    self.guideSubStepConfDic = {}
    local guideSubStepDatas = CS.CData_GuideSubStep.GetInstance():GetAll()
    for k, v in pairs(guideSubStepDatas) do
      local itemData = {}
      itemData.ID = k
      itemData.Type = v.m_Type
      itemData.CanSkip = v.m_CanSkip
      itemData.TypeParam = v.m_TypeParam
      itemData.TypeExeraParam = v.m_TypeExeraParam
      itemData.WndName = v.m_WndName
      itemData.TargetPath = v.m_TargetPath
      itemData.TargetOffset = v.m_TargetOffset
      itemData.TargetRotationZ = v.m_TargetRotationZ
      if not string.IsNullOrEmpty(v.m_StartFinishGuide) then
        itemData.StartFinishGuide = string.split(v.m_StartFinishGuide, ";")
      end
      itemData.TipsPortrait = v.m_TipsPortrait
      itemData.Tips = v.m_Tips
      itemData.TipsOffset = v.m_TipsOffset
      itemData.FilterTips = v.m_FilterTips
      itemData.IsRepeat = v.m_IsRepeat
      itemData.DelayShowNextStep = v.m_IsNextStep == 0
      itemData.AutoFinishSubStep = v.m_IsManual == 0
      if not string.IsNullOrEmpty(v.m_EndFinishGuide) then
        itemData.EndFinishGuide = string.split(v.m_EndFinishGuide, ";")
      end
      self.guideSubStepConfDic[itemData.ID] = itemData
    end
  end
end

function GuideManager:CheckFinishCondition(guideConf)
  if self.completeGuideDic[guideConf.ID] then
    return
  end
  if guideConf.FinishConditionType.Length > 0 and guideConf.FinishConditionType.Length == guideConf.FinishConditionParam.Length then
    local finishGuide = true
    for i = 0, guideConf.FinishConditionType.Length - 1 do
      local conditionType = guideConf.FinishConditionType[i]
      local conditionParam = guideConf.FinishConditionParam[i]
      local ret = false
      if conditionType == 1 then
        ret = self.completeGuideDic[tonumber(conditionParam)] ~= nil
      elseif conditionType == 2 then
        ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(conditionParam))
      elseif conditionType == 3 then
        ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.Tower, tonumber(conditionParam))
      elseif conditionType == 4 then
        ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.Dungeon, tonumber(conditionParam))
      elseif conditionType == 16 then
        ret = RogueStageManager:GetLevelRogueStageHelper():IsLevelHavePass(tonumber(conditionParam))
      elseif conditionType == 18 then
        ret = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(tonumber(conditionParam))
      elseif conditionType == 6 then
        ret = HeroManager:CheckHadLevelHero(tonumber(conditionParam))
      elseif conditionType == 7 then
        local heroData = HeroManager:GetHeroDataByID(tonumber(conditionParam))
        if heroData then
          ret = true
        else
          ret = false
        end
      elseif conditionType == 19 then
        local strs = string.split(conditionParam, "/")
        local circulationLevel = HeroManager:GetCirculationLvByID(tonumber(strs[1]))
        if circulationLevel <= tonumber(strs[2]) then
          ret = true
        else
          ret = false
        end
      elseif conditionType == 8 then
        ret = HeroManager:CheckHeroInPreset(tonumber(conditionParam))
      end
      if not ret then
        finishGuide = false
        break
      end
    end
    if finishGuide then
      self:FinishSubStepGuide(guideConf.ID, true)
    end
  end
end

function GuideManager:InitActiveGuides(activeType, param, param2, param3)
  if self.completeGuideDic[self.SkipGuideId] then
    return
  end
  self.activeGuides = {}
  for i = 1, #self.guideStepConfData do
    local guideConf = self.guideStepConfData[i]
    local accept = true
    if guideConf.IsOn == 0 then
      accept = false
    end
    if accept and self.completeGuideDic[guideConf.ID] and guideConf.IsRepeat == 0 then
      accept = false
    end
    if accept then
      local acceptFlag = false
      for m = 0, guideConf.EventType.Length - 1 do
        local eventType = guideConf.EventType[m]
        local eventParam = guideConf.EventParam[m]
        if eventType == activeType then
          if activeType == 1 then
            if eventParam == param then
              local WndName = eventParam
              if not string.IsNullOrEmpty(WndName) then
                local rootUI = CS.UI.UILuaHelper.GetRootUI(WndName)
                if rootUI ~= nil then
                  acceptFlag = true
                  break
                end
              end
            end
          elseif activeType == 2 or activeType == 3 or activeType == 4 or activeType == 5 then
            if tonumber(eventParam) == param then
              acceptFlag = true
              break
            end
          elseif activeType == 7 then
            if tonumber(guideConf.EventParam[0]) == param and tonumber(guideConf.EventParam[1]) == param2 and tonumber(guideConf.EventParam[2]) == param3 then
              if guideConf.EventParam.Length == 4 then
                local hasKey = 0 < CS.VisualExploreManager.Instance.Logic.KeyCount
                if hasKey and tonumber(guideConf.EventParam[3]) == 1 or not hasKey and tonumber(guideConf.EventParam[3]) == 0 then
                  acceptFlag = true
                  break
                end
              else
                acceptFlag = true
                break
              end
            end
          elseif eventParam == param then
            acceptFlag = true
            break
          end
        end
      end
      if not acceptFlag then
        accept = false
      end
    end
    if accept and 0 < guideConf.ConditionType.Length then
      if guideConf.ConditionType.Length == guideConf.ConditionParam.Length then
        for i = 0, guideConf.ConditionType.Length - 1 do
          local conditionType = guideConf.ConditionType[i]
          local conditionParam = guideConf.ConditionParam[i]
          local checkRet = guideConf.CheckOut[i] == 1
          local ret
          if conditionType == 1 then
            ret = self.completeGuideDic[tonumber(conditionParam)] ~= nil
          elseif conditionType == 2 then
            ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(conditionParam))
          elseif conditionType == 3 then
            ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.Tower, tonumber(conditionParam))
          elseif conditionType == 4 then
            ret = LevelManager:IsLevelHavePass(LevelManager.LevelType.Dungeon, tonumber(conditionParam))
          elseif conditionType == 16 then
            ret = RogueStageManager:GetLevelRogueStageHelper():IsLevelHavePass(tonumber(conditionParam))
          elseif conditionType == 18 then
            ret = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(tonumber(conditionParam))
          elseif conditionType == 5 then
            local items = string.split(conditionParam, "/")
            local itemNum = ItemManager:GetItemNum(tonumber(items[1]), true)
            if itemNum >= tonumber(items[2]) then
              ret = true
            else
              ret = false
            end
          elseif conditionType == 6 then
            ret = HeroManager:CheckHadLevelHero(tonumber(conditionParam))
          elseif conditionType == 7 then
            local heroData = HeroManager:GetHeroDataByID(tonumber(conditionParam))
            if heroData then
              ret = true
            else
              ret = false
            end
          elseif conditionType == 8 then
            ret = HeroManager:CheckHeroInPreset(tonumber(conditionParam))
          elseif conditionType == 9 then
            ret = tonumber(conditionParam) == param2
          elseif conditionType == 10 then
            local curHeroLevel = 0
            ret = false
            local heroForm = StackFlow:GetOpenUIInstanceLua(UIDefines.ID_FORM_HERODETAIL)
            if heroForm ~= nil then
              curHeroLevel = heroForm:GetCurrentHeroLevel()
            end
            if curHeroLevel > tonumber(conditionParam) then
              ret = true
            end
          elseif conditionType == 11 then
            ret = CS.UI.UILuaHelper.GetGuideConditionIsOpen(conditionType)
          elseif conditionType == 12 then
            ret = CS.UI.UILuaHelper.GetGuideConditionIsOpen(conditionType)
          elseif conditionType == 13 then
            ret = CS.UI.UILuaHelper.GetGuideConditionIsOpen(conditionType)
          elseif conditionType == 14 then
            ret = CS.UI.UILuaHelper.GetGuideConditionIsOpen(conditionType)
          elseif conditionType == 15 or conditionType == 17 then
            ret = false
            local uiid = CS.UIDefinesForLua.Get(guideConf.EventParam[0])
            local wndForm = StackFlow:GetOpenUIInstanceLua(uiid)
            if wndForm ~= nil then
              ret = wndForm:GetGuideConditionIsOpen(conditionType, conditionParam)
            end
          elseif conditionType == 19 then
            local strs = string.split(conditionParam, "/")
            local circulationLevel = HeroManager:GetCirculationLvByID(tonumber(strs[1]))
            if circulationLevel <= tonumber(strs[2]) then
              ret = true
            else
              ret = false
            end
          end
          if ret ~= checkRet then
            accept = false
            break
          end
        end
      else
        GuideManager:GuideDebug("guide_error:::::ConditionType ConditionParam长度不一致")
      end
    end
    if accept then
      table.insert(self.activeGuides, guideConf)
    end
  end
  local showGuide
  for i = 1, #self.activeGuides do
    if showGuide == nil then
      showGuide = self.activeGuides[i]
    elseif self.activeGuides[i].Priority > showGuide.Priority then
      showGuide = self.activeGuides[i]
    end
  end
  if showGuide and self.ShowGuide then
    StackSpecial:Push(UIDefines.ID_FORM_GUIDE)
    local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
    if form ~= nil then
      form:SetData(showGuide)
    end
  end
end

function GuideManager:OnGuideFinish(guideId)
  self:InitGuideConfData()
  self:InitActiveGuides(4, guideId)
end

function GuideManager:OnTaskJump(task)
  if not self.InitEventListener then
    return
  end
  self:InitGuideConfData()
  self:InitActiveGuides(3, task.taskId)
end

function GuideManager:OnEnterLevel(levelId, areaId)
  if not self.InitEventListener then
    return
  end
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if form ~= nil and form.guideData ~= nil then
    form:EndGuide()
  end
  self:InitGuideConfData()
  if self.guideLevelIds[levelId] then
    self:InitActiveGuides(2, levelId, areaId)
  end
end

function GuideManager:OnExitLevel(levelId)
  if not self.InitEventListener then
    return
  end
  self:InitGuideConfData()
  if self.guideLevelIds[levelId] then
    local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
    if form ~= nil and form.guideData ~= nil then
      for m = 0, form.guideData.EventType.Length - 1 do
        local eventType = form.guideData.EventType[m]
        local eventParam = form.guideData.EventParam[m]
        if eventType == 2 and tonumber(eventParam) == levelId then
          form:EndGuide()
          break
        end
      end
    end
  end
end

function GuideManager:OnlegacygPlayerMove(levelId, gridx, gridz)
  if not self.InitEventListener then
    return
  end
  self:InitGuideConfData()
  if self.guideLevelIds[levelId] then
    self:InitActiveGuides(7, levelId, gridx, gridz)
  end
end

function GuideManager:OnAddItem(itemId)
  self:InitGuideConfData()
  if self.guideItemIds[itemId] then
    GuideManager:GuideDebug("guide_GuideManager:OnAddItem:" .. itemId)
    self:InitActiveGuides(5, itemId)
  end
end

function GuideManager:OnEventWndActive(wndName)
  if not self.InitEventListener then
    return
  end
  self:InitGuideConfData()
  if self.guideWnds[wndName] then
    GuideManager:GuideDebug("guide_GuideManager:OnEventWndActive:" .. wndName)
    self:InitActiveGuides(1, wndName)
  end
end

function GuideManager:OnEventWndInactive(wndName)
  if not self.InitEventListener then
    return
  end
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if form ~= nil then
    form:OnEventWndInactive(wndName)
  end
  self:InitGuideConfData()
  if self.guideWnds[wndName] then
    GuideManager:GuideDebug("guide_GuideManager:OnEventWndInactive:" .. wndName)
    self:InitActiveGuides(6, wndName)
  end
end

function GuideManager:GuideIsActive()
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if form ~= nil then
    return form:GuideIsActive()
  end
  return false
end

function GuideManager:CheckGuideIsActive(guideId)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if form ~= nil then
    return form:CheckGuideIsActive(guideId)
  end
  return false
end

function GuideManager:FinishStepGuides(guides)
  for i = 1, #guides do
    CS.UI.UILuaHelper.SendReport(CS.LogicDefine.LogicReportType.eGuideFinish, guides[i])
    if self.completeGuideDic[guides[i]] == nil then
      self.completeGuideDic[guides[i]] = guides[i]
      self:ReqFinishGuide(guides[i])
    end
  end
end

function GuideManager:FinishSubStepGuide(subStepGuideId, reqFinish)
  CS.UI.UILuaHelper.SendReport(CS.LogicDefine.LogicReportType.eGuideFinish, subStepGuideId)
  if self.completeGuideDic[subStepGuideId] == nil then
    self.completeGuideDic[subStepGuideId] = subStepGuideId
    if reqFinish then
      self:ReqFinishGuide(subStepGuideId)
    end
  end
  if reqFinish then
    EventCenter.Broadcast(EventDefine.eGameEvent_GuideFinish, subStepGuideId)
  end
end

function GuideManager:CheckSubStepGuideCmp(subStepGuideId)
  return self.completeGuideDic[subStepGuideId] ~= nil
end

function GuideManager:GetSubStepConfData(subStepId)
  if self.guideSubStepConfDic[subStepId] then
    return self.guideSubStepConfDic[subStepId]
  end
  return nil
end

function GuideManager:ToggleGuide()
  self.ShowGuide = not self.ShowGuide
  if self.ShowGuide == false then
    local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
    if form ~= nil then
      form:EndGuide()
      form:CloseForm()
    end
  end
end

function GuideManager:SkipGuide()
  local guides = {}
  table.insert(guides, self.SkipGuideId)
  local guideStepDatas = CS.CData_GuideStep.GetInstance():GetAll()
  for k, v in pairs(guideStepDatas) do
    table.insert(guides, k)
  end
  self:FinishStepGuides(guides)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if form ~= nil then
    form:EndGuide()
    form:CloseForm()
  end
end

function GuideManager:GuideDebug(info)
  log.debug(info)
end

function GuideManager:IsHaveGuideInCurLevel(level)
  if self.guideLevelIds and self.guideLevelIds[level] ~= nil then
    return true
  end
  return false
end

function GuideManager:ManualGuideClick(go, manualFinish)
  local guideBlocked = false
  local guideForm = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if guideForm ~= nil then
    guideBlocked = guideForm:OnGuideClick(go, false, manualFinish)
  end
  return guideBlocked
end

function GuideManager:SkipCurrentGuide()
  local guideForm = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUIDE)
  if guideForm ~= nil then
    guideForm:SkipCurrentGuide()
  end
end

return GuideManager
