local Form_LoungeVictory = class("Form_LoungeVictory", require("UI/UIFrames/Form_LoungeVictoryUI"))
local __KeyIdle = "key_idle_02"
local __DefaultControl = "key_control"

function Form_LoungeVictory:SetInitParam(param)
end

function Form_LoungeVictory:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  UILuaHelper.SetActive(goBackBtnRoot, true)
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1259)
  self.m_curHeroSpineObj = nil
  self.m_spineClick = self.m_root_hero:GetComponent(LoungeSpineClick)
  if self.m_spineClick then
    self.m_spineClick.Touched = handler(self, self.OnSpineClick)
  end
  self.m_spineObjTab = {}
  self.m_curSpineState = __KeyIdle
  self.m_pnl_finish:SetActive(false)
end

function Form_LoungeVictory:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curLoungeHeroId = tParam.heroId
  self.m_charId = tParam.charId
  self.iCurTipsId = nil
  self.m_CollisionAction = {}
  self.m_BoneNameTab = {}
  self.m_GestureParam = self:GenerateGestureParam()
  self.m_pnl_finish:SetActive(false)
  self.m_pnl_key:SetActive(true)
  self:OnSelectedHero()
  LoungeManager:ResetGestureDragBackAndForthTab()
  self.m_csui.m_param = nil
  self:AddEventListeners()
  self:RefreshTips(100125)
  self.m_touchKeyFlag = nil
end

function Form_LoungeVictory:OnInactive()
  self.super.OnInactive(self)
  if self.m_closeTimer then
    TimeService:KillTimer(self.m_closeTimer)
    self.m_closeTimer = nil
  end
  self.m_touchKeyFlag = nil
  self.m_unlockReqFlag = nil
  self:RemoveAllEventListeners()
end

function Form_LoungeVictory:AddEventListeners()
  self:addEventListener("eGameEvent_Lounge_Unlock", handler(self, self.OnUnlockSpGame))
end

function Form_LoungeVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LoungeVictory:OnUnlockSpGame()
  GlobalManagerIns:TriggerWwiseBGMState(414)
  self.m_pnl_finish:SetActive(true)
  self.m_pnl_key:SetActive(false)
  if self.m_closeTimer then
    TimeService:KillTimer(self.m_closeTimer)
    self.m_closeTimer = nil
  end
  self.m_closeTimer = TimeService:SetTimer(1.2, 1, function()
    if self then
      self.m_closeTimer = nil
      self:OnBackClk()
    end
  end)
end

function Form_LoungeVictory:GenerateGestureParam()
  local m_GestureParam = {}
  m_GestureParam.state = self.m_curSpineState
  return m_GestureParam
end

function Form_LoungeVictory:OnSelectedHero()
  local cfg = LoungeManager:GetLoungeCharCfgById(self.m_charId)
  if cfg then
    local spineName = cfg.m_SpineName
    if spineName and spineName ~= "" then
      local collisionList = utils.changeCSArrayToLuaTable(cfg.m_Collision)
      self.m_CollisionAction, self.m_BoneNameTab = LoungeManager:GetCollisionAction(collisionList)
      self:ShowHeroSpine(spineName)
    end
  end
end

function Form_LoungeVictory:ShowHeroSpine(showSpineStr)
  if not utils.isNull(self.m_spineObjTab[showSpineStr]) then
    if self.m_spineClick then
      self.m_spineClick:DestroyFollowerList()
    end
    if not utils.isNull(self.m_curHeroSpineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj, false)
    end
    self.m_curHeroSpineObj = self.m_spineObjTab[showSpineStr]
    UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
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

function Form_LoungeVictory:OnLoadSpineBack(showSpineStr)
  if not self.m_curHeroSpineObj then
    return
  end
  UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
  UILuaHelper.SetSpineTimeScale(self.m_curHeroSpineObj, 1)
  self:SpinePlayAnimByActionName()
  LoungeManager:ResetGestureDragBackAndForthTab()
  if self.m_spineClick and not utils.isNull(self.m_curHeroSpineObj) then
    self.m_spineClick:BindingSpine(__DefaultControl .. "," .. showSpineStr)
  end
end

function Form_LoungeVictory:SpinePlayAnimByActionName(actionName, cfg)
  if utils.isNull(self.m_curHeroSpineObj) then
    return
  end
  local heroSpine = self.m_curHeroSpineObj
  local action = actionName and actionName or __KeyIdle
  if self.m_spineClick and action ~= self.m_curSpineState then
    self.m_spineClick:SetControlBoneMove(false)
  else
    self.m_spineClick:SetControlBoneMove(true)
  end
  self.m_curSpineState = action
  self.m_GestureParam.state = action
  if cfg and cfg.m_Subtitle then
    self:ShowPlotText(cfg)
  end
  if self.sCurAudioAction ~= action then
    LoungeManager:CheckPlayAudio(action)
    self.sCurAudioAction = action
  end
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
    if UILuaHelper.IsNull(heroSpine) then
      return
    end
    self.m_spineClick:SetControlBoneMove(true)
    local newAction = __KeyIdle
    if cfg and cfg.m_ChangeAction and cfg.m_ChangeAction ~= "" then
      newAction = cfg.m_ChangeAction
      self.m_touchKeyFlag = true
    end
    self.m_GestureParam.state = newAction
    self.m_curSpineState = newAction
    if cfg and cfg.m_LoungeMinigame == LoungeManager.__MiniGameOver then
      LoungeManager:SetClientLoungeState(self.m_curLoungeHeroId, LoungeManager.LoungeBondStatus.Unlock)
      self:broadcastEvent("eGameEvent_Lounge_Unlock")
      self.m_unlockReqFlag = true
    end
    local newCfg = cfg
    if cfg and cfg.m_ChangeAction then
      newCfg = {
        m_ChangeAction = cfg.m_ChangeAction,
        m_LoungeMinigame = cfg.m_LoungeMinigame
      }
    end
    self:SpinePlayAnimByActionName(newAction, newCfg)
  end)
end

function Form_LoungeVictory:OnSpineClickInteractionCB(data)
  if data and data.action and data.action ~= "" and data.cfg then
    self:SpinePlayAnimByActionName(data.action, data.cfg)
    if not self.m_touchKeyFlag then
    end
  end
end

function Form_LoungeVictory:OnSpineClick(name, localPos, touchType)
  if self.m_CollisionAction and self.m_CollisionAction[name] and touchType == LoungeManager.SpineTouchType.Up then
    if self.m_GestureParam.collision == "key_range" and self.m_GestureParam.state == "key_idle_02" then
      self.m_GestureParam.collision = "lock_range"
    end
    local data, refuseData = LoungeManager:CheckGestureActionByParam(self.m_charId, self.m_GestureParam)
    if data and data.action and data.action ~= "" and refuseData == nil then
      self:OnSpineClickInteractionCB(data)
    end
    if refuseData and refuseData.refuseAction ~= "" then
      self:SpinePlayAnimByActionName(refuseData.refuseAction)
      self:ShowPlotTextByStr(refuseData.subTitle, refuseData.voice)
    end
    LoungeManager:ResetGestureDragBackAndForthTab()
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.Down then
    self.m_GestureParam = self:GenerateGestureParam()
    self.m_GestureParam.startPoint = localPos
    self.m_GestureParam.collision = name
    LoungeManager:ResetGestureDragBackAndForthTab()
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.EndDrag then
    LoungeManager:ResetGestureDragBackAndForthTab()
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.Drag then
    self.m_GestureParam.point = localPos
    local data, refuseData = LoungeManager:CheckGestureActionByParam(self.m_charId, self.m_GestureParam)
    if data and data.action and data.action ~= "" and refuseData == nil then
      self.m_curSpineState = data.action
      self:OnSpineClickInteractionCB(data)
    end
    if refuseData and refuseData.refuseAction ~= "" then
      self:SpinePlayAnimByActionName(refuseData.refuseAction)
      self:ShowPlotTextByStr(refuseData.subTitle, refuseData.voice)
    end
  elseif self.m_spineClick and touchType == LoungeManager.SpineTouchType.BeginDrag then
    self.m_GestureParam.point = localPos
    local data, refuseData, reActionDate = LoungeManager:CheckGestureActionByParam(self.m_charId, self.m_GestureParam)
    if reActionDate and reActionDate.action and reActionDate.action ~= "" and refuseData == nil and reActionDate.action == "key_up" then
      GlobalManagerIns:TriggerWwiseBGMState(411)
    end
  end
end

function Form_LoungeVictory:RefreshTips(tipsId)
  self.m_txt_title_Text.text = ConfigManager:GetCommonTextById(tipsId or 100125)
  if self.iCurTipsId ~= tipsId then
    GlobalManagerIns:TriggerWwiseBGMState(407)
  end
  self.iCurTipsId = tipsId
end

function Form_LoungeVictory:ShowPlotPanel()
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

function Form_LoungeVictory:ShowPlotText(cfg)
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if cfg and cfg.m_Subtitle and cfg.m_Subtitle.Length > 0 then
    self:ShowPlotPanel()
    math.newrandomseed()
    local randomIndex = math.random(0, cfg.m_Subtitle.Length - 1) or 0
    self.m_txt_dialogue_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(cfg.m_Subtitle[randomIndex] .. "_" .. tostring(self.m_curLoungeHeroId))
  else
    UILuaHelper.SetActive(self.m_pnl_dialogue, false)
  end
  if cfg and cfg.m_Voice and cfg.m_Voice ~= "" then
    self.m_playSFXStr = cfg.m_Voice
    UILuaHelper.StartPlaySFX(cfg.m_Voice, nil, nil, function()
      if self then
        self:ShowPlotText()
      end
    end)
  end
end

function Form_LoungeVictory:ShowPlotTextByStr(str, voice)
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if str then
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

function Form_LoungeVictory:DestroyAndUnloadSpine()
  if self.m_spineObjTab then
    for name, obj in pairs(self.m_spineObjTab) do
      ResourceUtil:DestroyAndUnloadUIPrefab(obj, name)
    end
  end
end

function Form_LoungeVictory:OnBackClk()
  if not self.m_unlockReqFlag then
    self:broadcastEvent("eGameEvent_Lounge_CloseMiniGame")
  end
  self:DestroyForm()
end

function Form_LoungeVictory:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
  self:DestroyForm()
end

function Form_LoungeVictory:IsOpenGuassianBlur()
  return true
end

function Form_LoungeVictory:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
  self.m_unlockReqFlag = nil
  self:DestroyAndUnloadSpine()
  LoungeManager:ResetGestureDragBackAndForthTab()
end

local fullscreen = true
ActiveLuaUI("Form_LoungeVictory", Form_LoungeVictory)
return Form_LoungeVictory
