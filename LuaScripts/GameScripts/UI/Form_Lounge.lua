local Form_Lounge = class("Form_Lounge", require("UI/UIFrames/Form_LoungeUI"))
local __DefaultControl = "eye_control"
local __ShowBondBtn = 1

function Form_Lounge:SetInitParam(param)
end

function Form_Lounge:AfterInit()
  self.super.AfterInit(self)
  UILuaHelper.SetActive(self.m_common_top_back, true)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1259)
  self.m_loungeChangeInfinityGrid = self:CreateInfinityGrid(self.m_item_list_InfinityGrid, "Lounge/UILoungeChangeHeroItem")
  self.m_curHeroSpineObj = nil
  self.m_spineClick = self.m_root_hero:GetComponent(LoungeSpineClick)
  if self.m_spineClick then
    self.m_spineClick.Touched = handler(self, self.OnSpineClick)
  end
  self.m_buttonEx = self.m_btn_contract:GetComponent("ButtonExtensions")
  if self.m_buttonEx then
    self.m_buttonEx.Down = handler(self, self.OnLongPressDown)
    self.m_buttonEx.Up = handler(self, self.OnLongPressUp)
  end
  self.m_spineObjTab = {}
  self.m_curSpineState = ""
  self.m_iTimeDurationOneSecond = 0
  self.m_playSFXStr = ""
  self.m_stopSpineIdle = false
  self.m_stopRandomIdle = false
  self.fLongPressTime = 0
  self.fTipTimer = 0
  self.bIsCheckTips = true
end

function Form_Lounge:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  local iHeroId
  if not tParam or not tParam.heroId then
    local cfg = LoungeManager:GetOneLoungeHeroCfg()
    if not cfg then
      return
    end
    iHeroId = cfg.m_ID
  else
    iHeroId = tParam.heroId
  end
  if not iHeroId then
    return
  end
  if self.m_spineClick == nil then
    self.m_spineClick = self.m_root_hero:GetComponent(LoungeSpineClick)
  end
  self.m_longPressState = nil
  self.m_curLoungeHeroId = iHeroId
  self:RefreshHeroLoungeData()
  LoungeManager:ResetGestureDragBackAndForthTab()
  self.m_csui.m_param = nil
  self:AddEventListeners()
  self.m_changeIdleTime = 0
  self:GetChangeIdleTime()
  self.bIsFinishMark = LocalDataManager:GetIntSimple("eGameEvent_Lounge_Mark" .. self.m_curLoungeHeroId, 0) == 1
  GlobalManagerIns:TriggerWwiseBGMState(386)
end

function Form_Lounge:OnOpen()
  Form_Lounge.super.OnOpen(self)
  self.m_CollisionAction = {}
  self.m_BoneNameTab = {}
  local isOpen = LoungeManager:CheckLoungeUnlock()
  if not isOpen then
    self:RefreshUnlockUI()
    return
  end
  local open = LocalDataManager:GetIntSimple("Lounge_FirstOpen", 0)
  if open == 0 then
    LocalDataManager:SetIntSimple("Lounge_FirstOpen", 1)
    self:OnBtnguideClicked()
  else
    self:CheckReqAttractLoungeBond()
  end
  self.m_GestureParam = self:GenerateGestureParam()
  self:RefreshUI()
  self:OnSelectedHero()
end

function Form_Lounge:OnInactive()
  self.super.OnInactive(self)
  self:KillTimer()
  if self.m_spineClick then
    self.m_spineClick:DestroyFollowerList()
    self.m_spineClick = nil
  end
  self.m_iTimeDurationOneSecond = 0
  self.fLongPressTime = 0
  LoungeManager:ResetGestureDragBackAndForthTab()
  self:RemoveAllEventListeners()
  self:ReportClientMessage()
  self:DestroyForm()
  self.fTipTimer = 0
  self.bIsCheckTips = true
end

function Form_Lounge:ReportClientMessage()
  local _, lv = LoungeManager:GetLoungeAllAttrsId()
  local data = LoungeManager:GetLoungeDataByHeroId(self.m_curLoungeHeroId)
  local parts = ""
  if data and data.vParts then
    for _, v in pairs(data.vParts) do
      parts = parts .. v .. ","
    end
  end
  local params = {
    Hero_id = self.m_curLoungeHeroId,
    Level = lv,
    Parts = parts,
    IsFinish = data.iStatus
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.Client_lounge, params)
end

function Form_Lounge:OnUpdate(dt)
  self:OnLongPress(dt)
  self:CheckTips(dt)
  if self.m_stopSpineIdle or self.m_stopRandomIdle then
    return
  end
  if not self.m_changeIdleTime or self.m_changeIdleTime == 0 or not self.m_iTimeDurationOneSecond then
    return
  end
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= self.m_changeIdleTime then
    self.m_iTimeDurationOneSecond = 0
    self:GetChangeIdleTime()
    local action, subtitle, voice = LoungeManager:GetSpineRandomIdleById(self.m_curLoungeHeroId, self.m_curSpineState)
    if action and action ~= "" then
      self:SpinePlayAnimByActionName(action)
    end
    if subtitle and subtitle ~= "" then
      self:ShowPlotTextByStr(subtitle, voice)
    end
  end
end

function Form_Lounge:AddEventListeners()
  self:addEventListener("eGameEvent_Lounge_Interaction", handler(self, self.OnInteractionRefreshUI))
  self:addEventListener("eGameEvent_Lounge_Unlock", handler(self, self.OnCompleteMiniGame))
  self:addEventListener("eGameEvent_Lounge_Mark", handler(self, self.OnCompleteStampMark))
  self:addEventListener("eGameEvent_Lounge_CloseMiniGame", handler(self, self.OnCloseMiniGame))
  self:addEventListener("eGameEvent_Lounge_GuidePop_Inactive", handler(self, self.CheckReqAttractLoungeBond))
  self:addEventListener("eGameEvent_Lounge_GuidePop_Inactive2", handler(self, self.FreshTimerTip))
end

function Form_Lounge:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Lounge:GetChangeIdleTime()
  if self.m_uiVariables.RandomIdleMinTime and self.m_uiVariables.RandomIdleMaxTime then
    math.newrandomseed()
    self.m_changeIdleTime = math.random(self.m_uiVariables.RandomIdleMinTime, self.m_uiVariables.RandomIdleMaxTime) or 999
  end
end

function Form_Lounge:RefreshHeroLoungeData()
  self.m_heroLoungeData = LoungeManager:GetLoungeDataByHeroId(self.m_curLoungeHeroId) or {}
  self.m_iStatus = self.m_heroLoungeData.iStatus or 0
  self.m_vParts = self.m_heroLoungeData.vParts or {}
end

function Form_Lounge:OnInteractionRefreshUI(stData)
  self:RefreshHeroLoungeData()
end

function Form_Lounge:RefreshUnlockUI()
  UILuaHelper.SetActive(self.m_root_hero, false)
  UILuaHelper.SetActive(self.m_pnl_btn, false)
  UILuaHelper.SetActive(self.m_pnl_right, false)
  UILuaHelper.SetActive(self.m_pnl_choose, true)
  UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  UILuaHelper.SetActive(self.m_img_bg1, false)
  UILuaHelper.SetActive(self.m_img_bg2, true)
  UILuaHelper.SetActive(self.m_btnShowUI, false)
  UILuaHelper.SetActive(self.m_menupop, false)
  UILuaHelper.SetActive(self.m_ui_panel, true)
  local list = {}
  local heroList = LoungeManager:GetHeroChangeList()
  for i, v in ipairs(heroList) do
    local tab = {
      heroId = v.m_ID,
      unlockLimitBreakLevel = v.m_UnlockLimitBreakLevel,
      name = v.m_mCharName,
      isUnlock = false,
      sortId = v.m_Sort
    }
    list[#list + 1] = tab
  end
  table.sort(list, function(a, b)
    return a.sortId < b.sortId
  end)
  self.m_loungeChangeInfinityGrid:ShowItemList(list)
end

function Form_Lounge:RefreshUI()
  UILuaHelper.SetActive(self.m_root_hero, true)
  UILuaHelper.SetActive(self.m_pnl_right, true)
  UILuaHelper.SetActive(self.m_pnl_choose, false)
  UILuaHelper.SetActive(self.m_pnl_contract, false)
  UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  UILuaHelper.SetActive(self.m_pnl_btn, true)
  UILuaHelper.SetLocalScale(self.m_root_hero, 1, 1, 1)
  UILuaHelper.SetActive(self.m_img_bg1, true)
  UILuaHelper.SetActive(self.m_img_bg2, false)
  UILuaHelper.SetActive(self.m_btnShowUI, false)
  self:ShowALlUI(true)
  self:ShowMenuPop(false)
end

function Form_Lounge:ShowALlUI(flag)
  UILuaHelper.SetActive(self.m_ui_panel, flag)
  UILuaHelper.SetActive(self.m_btnCannothide, not flag)
  UILuaHelper.SetActive(self.m_btnShowUI, not flag)
  UILuaHelper.SetActive(self.m_btnhide, flag)
  UILuaHelper.SetActive(self.m_btnhelp, flag)
  UILuaHelper.SetActive(self.m_btnhelp, flag)
  self:ShowMenuPop(false)
  UILuaHelper.SetActive(self.m_menu, flag)
end

function Form_Lounge:ShowMenuPop(flag)
  UILuaHelper.SetActive(self.m_menupop, flag)
  UILuaHelper.SetActive(self.m_menu_light, flag)
  UILuaHelper.SetActive(self.m_menu, not flag)
end

function Form_Lounge:OnBtnclosemenuClicked()
  self:ShowMenuPop(false)
end

function Form_Lounge:GenerateGestureParam()
  local m_GestureParam = {}
  m_GestureParam.state = self.m_curSpineState
  m_GestureParam.pressTime = 0
  return m_GestureParam
end

function Form_Lounge:OnSelectedHero()
  local cfg = LoungeManager:GetLoungeCharCfgById(self.m_curLoungeHeroId)
  if cfg then
    local spineName = cfg.m_SpineName
    if spineName and spineName ~= "" then
      local collisionList = utils.changeCSArrayToLuaTable(cfg.m_Collision)
      self.m_CollisionAction, self.m_BoneNameTab = LoungeManager:GetCollisionAction(collisionList)
      self:ShowHeroSpine(spineName)
    end
  end
end

function Form_Lounge:ShowHeroSpine(showSpineStr)
  if not utils.isNull(self.m_spineObjTab[showSpineStr]) then
    local reBind = false
    if self.m_spineObjTab[showSpineStr] == self.m_curHeroSpineObj then
      reBind = true
    end
    if self.m_spineClick and not reBind then
      self.m_spineClick:DestroyFollowerList()
    end
    if not utils.isNull(self.m_curHeroSpineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj, false)
    end
    self.m_curHeroSpineObj = self.m_spineObjTab[showSpineStr]
    UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
    self:OnLoadSpineBack(showSpineStr, reBind)
    return
  end
  
  local function callBack(spineLoadObj)
    if not utils.isNull(self.m_curHeroSpineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj, false)
    end
    self.m_spineObjTab[showSpineStr] = spineLoadObj
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack(showSpineStr)
  end
  
  ResourceUtil:CreateUIPrefab(showSpineStr, self.m_root_hero, callBack)
end

function Form_Lounge:OnLoadSpineBack(showSpineStr, reBind)
  if not self.m_curHeroSpineObj then
    return
  end
  UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
  UILuaHelper.SetSpineTimeScale(self.m_curHeroSpineObj, 1)
  local defaultAction, subtitle, voice = LoungeManager:GetSpineStateByIdAndState(self.m_curLoungeHeroId)
  self:SpinePlayAnimByActionName(defaultAction)
  self:ShowPlotTextByStr(subtitle, voice)
  LoungeManager:ResetGestureDragBackAndForthTab()
  if not reBind and self.m_spineClick and not utils.isNull(self.m_curHeroSpineObj) then
    self.m_spineClick:BindingSpine(__DefaultControl .. "," .. showSpineStr)
  end
  local _, partCfg = LoungeManager:GetCurPartByHeroId(self.m_curLoungeHeroId)
  if partCfg and partCfg.m_Engraving == __ShowBondBtn then
    self:ShowBondBtn(true)
  end
end

function Form_Lounge:SpinePlayAnimByActionName(actionName, cfg, callBack, changeAction, reverse, cycleChangeAction, preCallback)
  if self.m_stopSpineIdle then
    return
  end
  if utils.isNull(self.m_curHeroSpineObj) then
    return
  end
  local heroSpine = self.m_curHeroSpineObj
  local cycleState = cycleChangeAction and changeAction or nil
  local defaultAction = changeAction and changeAction ~= "" and changeAction or LoungeManager:GetSpineStateByIdAndState(self.m_curLoungeHeroId, cycleState)
  local action = actionName and actionName or defaultAction
  if self.m_spineClick and action ~= defaultAction then
    self.m_spineClick:SetControlBoneMove(false)
  elseif self.m_spineClick then
    self.m_spineClick:SetControlBoneMove(true)
  end
  self.m_curSpineState = action
  self.m_GestureParam.state = action
  LoungeManager:CheckPlayAudio(action)
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
    if UILuaHelper.IsNull(heroSpine) then
      return
    end
    if self.m_spineClick then
      self.m_spineClick:SetControlBoneMove(true)
    end
    if preCallback then
      preCallback()
    end
    local changeAct = cycleChangeAction and defaultAction or nil
    self:SpinePlayAnimByActionName(defaultAction, nil, nil, changeAct, nil, cycleChangeAction)
    if callBack then
      callBack()
    end
  end)
end

function Form_Lounge:ShowBondBtn(show)
  UILuaHelper.SetActive(self.m_pnl_right, show)
  UILuaHelper.SetActive(self.m_pnl_contract, show)
  self.bIsShowBondBtn = show
end

function Form_Lounge:OnSpineClickInteractionCB(data)
  if data and data.action and data.action ~= "" and data.cfg then
    local playBack, preCallback
    if data.cfg.m_LoungeMinigame ~= 0 and data.cfg.m_LoungeMinigame ~= LoungeManager.__MiniGameOver then
      function preCallback()
        if self and self.OnCompleteSpecialPart then
          self:OnCompleteSpecialPart(data.cfg.m_ID)
        end
      end
    end
    if data.cfg.m_Engraving == __ShowBondBtn then
      function playBack()
        if self and self.ShowBondBtn then
          self:ShowBondBtn(true)
        end
      end
    end
    self:SpinePlayAnimByActionName(data.action, data.cfg, playBack, data.cfg.m_ChangeAction, nil, nil, preCallback)
    if data.cfg.m_ChangeAction and data.cfg.m_ChangeAction ~= "" or data.cfg.m_Engraving == __ShowBondBtn then
      self.fTipTimer = 0
      self.bIsCheckTips = true
    end
    self:ShowPlotText(data.cfg)
    local isInteraction = LoungeManager:CheckPartsIsInteraction(self.m_curLoungeHeroId, data.cfg.m_ID)
    if not isInteraction then
      LoungeManager:SetClientLoungeParts(self.m_curLoungeHeroId, data.cfg.m_ID)
    end
  end
end

function Form_Lounge:FreshTimerTip()
  self.fTipTimer = 0
  self.bIsCheckTips = true
end

function Form_Lounge:OnSpineClick(name, localPos, touchType)
  self.m_iTimeDurationOneSecond = 0
  if self.m_CollisionAction[name] and touchType == LoungeManager.SpineTouchType.Up then
    self.m_GestureParam.pressTime = 0
    local data, refuseData = LoungeManager:CheckGestureActionByParam(self.m_curLoungeHeroId, self.m_GestureParam)
    if data and data.action and data.action ~= "" and refuseData == nil then
      self:OnSpineClickInteractionCB(data)
    end
    if refuseData and refuseData.refuseAction ~= "" then
      self:SpinePlayAnimByActionName(refuseData.refuseAction)
      self:ShowPlotTextByStr(refuseData.subTitle, refuseData.voice)
    end
    self:ResetControlBone()
    LoungeManager:ResetGestureDragBackAndForthTab()
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.Down then
    self.m_GestureParam = self:GenerateGestureParam()
    self.m_GestureParam.startPoint = localPos
    self.m_GestureParam.collision = name
    self.m_GestureParam.pressTime = 0
    self.m_reActionCfg = nil
    local boneName = LoungeManager:CheckIsCanBindBone(self.m_curLoungeHeroId, self.m_GestureParam)
    if boneName then
      self.m_spineClick:ChangeControlBone(boneName)
    end
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.EndDrag then
    self:ResetControlBone()
    LoungeManager:ResetGestureDragBackAndForthTab()
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.Drag then
    self.m_GestureParam.point = localPos
    local data, refuseData, reActionDate = LoungeManager:CheckGestureActionByParam(self.m_curLoungeHeroId, self.m_GestureParam)
    if data and data.action and data.action ~= "" and refuseData == nil then
      self.m_reActionCfg = nil
      self:OnSpineClickInteractionCB(data)
    end
    if refuseData and refuseData.refuseAction ~= "" then
      self:SpinePlayAnimByActionName(refuseData.refuseAction)
      self:ShowPlotTextByStr(refuseData.subTitle, refuseData.voice)
    end
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.BeginDrag then
    self.m_GestureParam.point = localPos
    local data, refuseData, reActionDate = LoungeManager:CheckGestureActionByParam(self.m_curLoungeHeroId, self.m_GestureParam)
    if reActionDate and reActionDate.action and reActionDate.action ~= "" and refuseData == nil and reActionDate.action == "touch_hand_03" then
      GlobalManagerIns:TriggerWwiseBGMState(404)
    end
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.LongPress then
    self.m_GestureParam.pressTime = self.m_GestureParam.pressTime + 1
    self.m_reActionCfg = nil
    local data, refuseData = LoungeManager:CheckGestureActionByParam(self.m_curLoungeHeroId, self.m_GestureParam)
    if data and data.action and data.action ~= "" and refuseData == nil then
      self:OnSpineClickInteractionCB(data)
    end
  end
end

function Form_Lounge:ResetControlBone()
  if self.m_spineClick then
    self.m_spineClick:ChangeControlBone(__DefaultControl)
  end
end

function Form_Lounge:ShowPlotPanel()
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
  self.m_showPlotTimer = TimeService:SetTimer(0.1, 1, function()
    self.m_showPlotTimer = nil
    if not utils.isNull(self.m_pnl_dialogue) then
      UILuaHelper.SetActive(self.m_pnl_dialogue, true)
    end
  end)
end

function Form_Lounge:ShowPlotText(cfg)
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if cfg and cfg.m_Subtitle and cfg.m_Subtitle.Length > 0 then
    math.newrandomseed()
    local randomIndex = math.random(0, cfg.m_Subtitle.Length - 1) or 0
    self.m_txt_dialogue_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(cfg.m_Subtitle[randomIndex] .. "_" .. tostring(self.m_curLoungeHeroId))
    if cfg.m_Voice and cfg.m_Voice ~= "" then
      self.m_playSFXStr = cfg.m_Voice
      UILuaHelper.StartPlaySFX(cfg.m_Voice, nil, nil, function()
        if self then
          self:ShowPlotText()
        end
      end)
    end
    self:ShowPlotPanel()
  else
    UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  end
end

function Form_Lounge:ShowPlotTextByStr(str, voice)
  if str and str ~= "" then
    self:ShowPlotPanel()
    self.m_txt_dialogue_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(str .. "_" .. tostring(self.m_curLoungeHeroId))
  else
    UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  end
  if voice and voice ~= "" then
    self.m_playSFXStr = voice
    UILuaHelper.StartPlaySFX(voice, nil, nil, function()
      if self then
        self:ShowPlotText()
      end
    end)
  end
end

function Form_Lounge:OnCloseMiniGame()
  self.m_stopSpineIdle = false
  self:SpinePlayAnimByActionName()
end

function Form_Lounge:OnCompleteMiniGame()
  self:RefreshHeroLoungeData()
  self.m_longPressState = nil
  self:CompleteMiniGameAction(1)
end

function Form_Lounge:CompleteMiniGameAction(delayTime)
  if self.m_completeMiniGameTimer then
    TimeService:KillTimer(self.m_completeMiniGameTimer)
    self.m_completeMiniGameTimer = nil
  end
  local action, changeAction, partId = LoungeManager:GetMiniGameOverAction(self.m_curLoungeHeroId)
  if action and changeAction and partId then
    LoungeManager:SetClientLoungeParts(self.m_curLoungeHeroId, partId)
    self.m_completeMiniGameTimer = TimeService:SetTimer(delayTime, 1, function()
      self.m_completeMiniGameTimer = nil
      if self and not utils.isNull(self.m_curHeroSpineObj) then
        self.m_stopSpineIdle = false
        local _, subtitle, voice = LoungeManager:GetSpineStateByIdAndState(self.m_curLoungeHeroId)
        self:SpinePlayAnimByActionName(action, nil, function()
          self:JumpToIdle03()
        end, changeAction)
        self:ShowPlotTextByStr(subtitle, voice)
      end
    end)
  else
  end
end

function Form_Lounge:JumpToIdle03()
  local action, changeAction, id
  local pCfg = LoungeManager:GetLoungeCharPartsCfgById(26)
  if pCfg then
    action = pCfg.m_Action
    changeAction = pCfg.m_ChangeAction
    id = 26
  end
  if action and changeAction and id then
    LoungeManager:SetClientLoungeParts(self.m_curLoungeHeroId, id)
    if not utils.isNull(self.m_curHeroSpineObj) then
      self.m_stopSpineIdle = false
      local subtitle, voice = pCfg.m_Subtitle[0], pCfg.m_Voice
      self:SpinePlayAnimByActionName(action, nil, nil, changeAction)
      self:ShowPlotTextByStr(subtitle, voice)
    end
  end
end

function Form_Lounge:OnCompleteStampMark(realMark)
  if utils.isNull(self.m_common_top_back) then
    return
  end
  LoungeManager:SetClientLoungeState(self.m_curLoungeHeroId, LoungeManager.LoungeBondStatus.Bond)
  self.m_longPressState = nil
  self:RefreshHeroLoungeData()
  UILuaHelper.SetActive(self.m_common_top_back, true)
  UILuaHelper.SetActive(self.m_pnl_btn, true)
  self:ShowBondBtn(false)
  if realMark then
    local oldAttrIdList = LoungeManager:GetBefLvUpAttrsById(self.m_curLoungeHeroId)
    local newAttrIdList, newLv = LoungeManager:GetLoungeAllAttrsId()
    StackPopup:Push(UIDefines.ID_FORM_LOUNGEUPGRADE, {
      level = newLv,
      newPropertyIDList = newAttrIdList,
      propertyIDList = oldAttrIdList
    })
  else
    local refAction, subTitle, voice, partCfg = LoungeManager:GetSpineEngravingActionById(self.m_curLoungeHeroId, LoungeManager.BiteType.Bond)
    if partCfg then
      self:SpinePlayAnimByActionName(refAction, nil, nil, partCfg.m_ChangeAction, nil, true)
    end
    self:ShowPlotTextByStr(subTitle, voice)
  end
end

function Form_Lounge:OnCompleteSpecialPart(iPart)
  if not iPart then
    return
  end
  local cfg = LoungeManager:GetLoungeCharPartsCfgById(iPart)
  if not cfg then
    return
  end
  if cfg.m_LoungeMinigame ~= 0 and cfg.m_LoungeMinigame ~= LoungeManager.__MiniGameOver then
    self:OpenMiniGame(cfg)
  end
end

function Form_Lounge:OpenMiniGame(cfg)
  local itemCfg = LoungeManager:GetLoungeItemCfgById(cfg.m_LoungeMinigame)
  if itemCfg then
    self.m_stopSpineIdle = true
    self.fTipTimer = 0
    StackPopup:Push(UIDefines.ID_FORM_LOUNGEVICTORY, {
      heroId = self.m_curLoungeHeroId,
      charId = itemCfg.m_CharID
    })
  end
end

function Form_Lounge:ResetGame()
  LoungeManager:InitClientLoungeData(self.m_curLoungeHeroId, true)
  self:RefreshHeroLoungeData()
  self.m_GestureParam = self:GenerateGestureParam()
  self:RefreshUI()
  self:OnSelectedHero()
  self:ShowBondBtn(false)
end

function Form_Lounge:DestroyAndUnloadSpine()
  if self.m_spineObjTab then
    for name, obj in pairs(self.m_spineObjTab) do
      ResourceUtil:DestroyAndUnloadUIPrefab(obj, name)
    end
  end
end

function Form_Lounge:OnLongPressUp()
  if utils.isNull(self.m_root_hero) then
    return
  end
  self.m_stopRandomIdle = false
  self.fLongPressTime = 0
  UILuaHelper.SetActive(self.m_pnl_contract, true)
  UILuaHelper.SetActive(self.m_pnl_normal, true)
  UILuaHelper.SetActive(self.m_pnl_start, false)
  UILuaHelper.SetActive(self.m_common_top_back, true)
  if not self.m_longPressState then
    self:SpinePlayAnimByActionName()
    GlobalManagerIns:TriggerWwiseBGMState(398)
  else
    self:broadcastEvent("eGameEvent_Lounge_Mark")
    LocalDataManager:SetIntSimple("eGameEvent_Lounge_Mark" .. self.m_curLoungeHeroId, 1)
    self.bIsFinishMark = true
  end
  UILuaHelper.StopAnimation(self.m_csui.m_uiGameObject, "Lounge_ScreenShakes")
  UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "Lounge_ScreenShakes")
end

function Form_Lounge:CheckReqAttractLoungeBond()
  if LoungeManager:GetLoungeHeroRealStatus(self.m_curLoungeHeroId) ~= LoungeManager.LoungeBondStatus.Bond then
    LoungeManager:ReqAttractLoungeBondCS(self.m_curLoungeHeroId)
  end
end

function Form_Lounge:OnLongPressDown()
  if utils.isNull(self.m_common_top_back) then
    return
  end
  self.m_stopRandomIdle = true
  UILuaHelper.SetActive(self.m_pnl_contract, true)
  UILuaHelper.SetActive(self.m_common_top_back, false)
  UILuaHelper.SetActive(self.m_pnl_normal, false)
  UILuaHelper.SetActive(self.m_pnl_start, true)
  local refAction, subTitle, voice = LoungeManager:GetSpineEngravingActionById(self.m_curLoungeHeroId, LoungeManager.BiteType.Focus)
  local idleAction = LoungeManager:GetSpineEngravingActionById(self.m_curLoungeHeroId, LoungeManager.BiteType.Idle)
  self:SpinePlayAnimByActionName(refAction, nil, nil, idleAction, nil, true)
  self:ShowPlotTextByStr(subTitle, voice)
  GlobalManagerIns:TriggerWwiseBGMState(396)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Lounge_ScreenShakes")
end

function Form_Lounge:OnLongPress(dt)
  if self.m_longPressState then
    return
  end
  if not self.m_stopRandomIdle then
    return
  end
  self.fLongPressTime = self.fLongPressTime + dt
  if self.fLongPressTime >= 2 then
    self.m_longPressState = true
  end
end

function Form_Lounge:KillTimer()
  if self.m_completeMiniGameTimer then
    TimeService:KillTimer(self.m_completeMiniGameTimer)
    self.m_completeMiniGameTimer = nil
  end
  if self.m_delayTimer then
    TimeService:KillTimer(self.m_delayTimer)
    self.m_delayTimer = nil
  end
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
end

function Form_Lounge:StopVoice()
  if self.m_playSFXStr and self.m_playSFXStr ~= "" then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playSFXStr)
  end
end

function Form_Lounge:OnBtnhideClicked()
  self:ShowALlUI(false)
end

function Form_Lounge:OnBtnShowUIClicked()
  self:ShowALlUI(true)
end

function Form_Lounge:OnBtnCannothideClicked()
  self:ShowALlUI(true)
end

function Form_Lounge:OnBtnadditionClicked()
  local propertyIDList, lv = LoungeManager:GetLoungeAllAttrsId()
  local params = {level = lv, propertyIDList = propertyIDList}
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEUPGRADEPOP, params)
end

function Form_Lounge:OnBtnswitchClicked()
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEHEROCHANGE, {
    heroId = self.m_curLoungeHeroId
  })
end

function Form_Lounge:OnBtnhelpClicked()
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDEPOP2, {
    heroId = self.m_curLoungeHeroId
  })
end

function Form_Lounge:OnBtnguideClicked()
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDEPOP)
end

function Form_Lounge:OnMenulightClicked()
  self:ShowMenuPop(false)
end

function Form_Lounge:OnMenuClicked()
  self:ShowMenuPop(true)
end

function Form_Lounge:OnBtnresetClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1265,
    func1 = function()
      self:ResetGame()
    end
  })
end

function Form_Lounge:OnBackClk()
  self.m_longPressState = nil
  self:CloseForm()
end

function Form_Lounge:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_Lounge:CheckTips(dt)
  if not self.bIsCheckTips then
    return
  end
  if self.m_stopSpineIdle then
    return
  end
  if self.bIsShowBondBtn then
    return
  end
  if self.bIsFinishMark then
    return
  end
  self.fTipTimer = self.fTipTimer + dt
  if self.fTipTimer >= 20 then
    self.fTipTimer = 0
    self.bIsCheckTips = false
    self:OnBtnhelpClicked()
  end
end

function Form_Lounge:IsFullScreen()
  return true
end

function Form_Lounge:OnDestroy()
  self.super.OnDestroy(self)
  self:KillTimer()
  self:StopVoice()
  self:DestroyAndUnloadSpine()
  LoungeManager:ResetGestureDragBackAndForthTab()
end

local fullscreen = true
ActiveLuaUI("Form_Lounge", Form_Lounge)
return Form_Lounge
