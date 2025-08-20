local Form_Guide = class("Form_Guide", require("UI/UIFrames/Form_GuideUI"))
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Form_Guide:SetInitParam(param)
end

function Form_Guide:AfterInit()
  self.rootAnimator = self.m_csui.m_uiGameObject.transform:GetComponent("Animator")
  self.lockerId = 0
  self.waitbattletime = 0
end

function Form_Guide:OnActive()
  self:SetConsistentActive(true)
end

function Form_Guide:OnInactive()
end

function Form_Guide:OnUpdate(dt)
  if self.weakclick and self.subStepData and (self.subStepData.Type == "weakclick" or self.subStepData.Type == "weakwait" or self.subStepData.Type == "weakwaitframe") and CS.UnityEngine.Input:GetMouseButtonUp(0) then
    self:FinishSubStepGuide()
  end
  if CS.UnityEngine.Input:GetMouseButtonUp(0) and not self.clickmaskFlag and self.subStepData and (self.subStepData.Type == "click" or self.subStepData.Type == "battleclick") then
    self.clickmaskFlag = true
    self.rootAnimator:Play("VX_Guide_Loop_Animation")
    if 0 < self.subStepData.TypeParam.Length and self.subStepData.TypeParam[0] == "clickmask" then
      self:InitTipsView()
    end
  end
end

function Form_Guide:OnDestroy()
  self:RemoveScheduler()
  self:ResetRegisterClick()
end

function Form_Guide:EndGuide()
  self:ResetView()
  self:RemoveScheduler()
  self:ResetRegisterClick()
  if self.subStepData and self.subStepData.Type == "playdialogue" then
    CS.UI.UILuaHelper.ShowBattleUI()
  end
  if self.subStepData and self.subStepData.Type == "battlepre" then
    CS.UI.UILuaHelper.ClearGuidePointEffect()
  end
  self.guideSubStep = 1
  self.guideData = nil
  self.subStepData = nil
  self.mainTarget = nil
  CS.UI.UILuaHelper.GuideGlobalLockCastSkill = false
  CS.UI.UILuaHelper.SetPauseExcept(false)
end

function Form_Guide:RemoveScheduler()
  GuideManager:RemoveFrameByKey("MaskFollowTarget")
  GuideManager:RemoveFrameByKey("ShowGuide")
  GuideManager:RemoveTimerByKey("ShowClickGuide")
  GuideManager:RemoveFrameByKey("InitTipsView")
  GuideManager:RemoveTimerByKey("waitshowclickguide")
  GuideManager:RemoveTimerByKey("WaitRootUIOpen")
  GuideManager:RemoveFrameByKey("FollowWnd")
  GuideManager:RemoveFrameByKey("FollowTarget")
  GuideManager:RemoveTimerByKey("waitevent")
  GuideManager:RemoveFrameByKey("waitframeevent")
  GuideManager:RemoveFrameByKey("DelayShowStepGuide")
  GuideManager:RemoveTimerByKey("BattlePreMove")
  GuideManager:RemoveTimerByKey("BattleDragMove")
  if self.waitCastSkillEventHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_GuideWaitCastSkillEvent, self.waitCastSkillEventHandler)
    self.waitCastSkillEventHandler = nil
  end
  if self.guideEventHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_GuideEvent, self.guideEventHandler)
    self.guideEventHandler = nil
  end
  if self.dialogueEndHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
    self.dialogueEndHandler = nil
  end
  if self.battleEnergyEvenHandler then
    EventCenter.RemoveListener(EventDefine.eGameBattle_EnergyChange, self.battleEnergyEvenHandler)
    self.battleEnergyEvenHandler = nil
  end
  CS.UI.UILuaHelper.GuideGlobalLockCastSkill = false
  if self.lockerId > 0 then
    CS.UI.UILuaHelper.UnlockInput(self.lockerId)
    self.lockerId = 0
  end
  CS.UI.UILuaHelper.SetLockCastSkill(false)
end

function Form_Guide:ResetView()
  self.m_guide_starup:SetActive(false)
  self.m_guide_herotalk:SetActive(false)
  self.m_guide_mask:SetActive(false)
  self.m_ClickContainer:SetActive(false)
  self.m_Mask_Btn:SetActive(false)
  self.m_FilterTipsContainer:SetActive(false)
  self.m_BattlePreContainer:SetActive(false)
  self.m_BattleDragSkillContainer:SetActive(false)
  self.m_BattleDragSkillTargetContainer:SetActive(false)
  self.m_guide_starup:SetActive(false)
  self.m_Mask:SetActive(false)
  self.mainTarget = nil
  self.rootUI = nil
  self.weakclick = false
  self.waitbattletime = 0
  self.clickmaskFlag = true
  self.isTemplateId = false
  self.guideDisableScrollRect = false
  self.guideStartTime = CS.UnityEngine.Time.realtimeSinceStartup
end

function Form_Guide:ResetRegisterClick()
  CS.UI.UILuaHelper.RegisterLegacyGuideCallback(nil)
  CS.UI.UILuaHelper.RegisterGuideCallback(nil)
  CS.UI.UILuaHelper.RegisterGuideBattlePreCallback(nil)
  CS.UI.UILuaHelper.LockCastSkillCharId = 0
end

function Form_Guide:SetData(_data)
  if self.guideData then
    if self.guideData == _data then
      GuideManager:GuideDebug("guide_该引导正在进行中::::::id:" .. _data.ID)
      return
    elseif _data.Priority > 0 and _data.Priority <= self.guideData.Priority then
      GuideManager:GuideDebug("guide_新激活引导优先级低::::::newid:" .. _data.ID .. ":Priority:" .. _data.Priority .. "::curId::" .. self.guideData.ID .. ":Priority:" .. self.guideData.Priority)
      return
    end
  end
  self.guideSubStep = 1
  self.guideData = _data
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = tostring(_data.ID),
    eType = DownloadManager.ResourcePackageType.Guide
  }
  
  local function OnDownloadComplete(ret)
    self:ShowSubStepGuide()
  end
  
  DownloadManager:DownloadResourceWithUI(vPackage, nil, "Guide_" .. _data.ID, nil, nil, OnDownloadComplete)
end

function Form_Guide:ShowSubStepGuide()
  self:RemoveScheduler()
  self:ResetRegisterClick()
  self:ResetView()
  if self.guideSubStep > self.guideData.SubStepIds.Length then
    GuideManager:GuideDebug("guide_所有步骤执行完，引导结束::::::id:" .. self.guideData.ID)
    local guideId = self.guideData.ID
    GuideManager:FinishSubStepGuide(guideId, true)
    self:EndGuide()
    GuideManager:OnGuideFinish(guideId)
  else
    local subStepId = self.guideData.SubStepIds[self.guideSubStep - 1]
    self.subStepData = GuideManager:GetSubStepConfData(subStepId)
    if self.subStepData == nil then
      GuideManager:GuideDebug("guide_error,subStepId not find,ID:" .. self.guideData.ID .. ":::step_id:" .. subStepId)
      return
    end
    GuideManager:GuideDebug("guide_ShowStepGuide:ID:" .. self.guideData.ID .. ":::step_id:" .. self.subStepData.ID .. "::type:" .. self.subStepData.Type .. "::wndname::" .. self.subStepData.WndName)
    local lockTime = 0.5
    if (self.subStepData.Type == "wait" or self.subStepData.Type == "tips") and self.subStepData.TypeParam.Length > 0 and 0 < tonumber(self.subStepData.TypeParam[0]) and lockTime < tonumber(self.subStepData.TypeParam[0]) then
      lockTime = tonumber(self.subStepData.TypeParam[0])
    end
    self:LockInput(lockTime)
    self:FinishStepGuides(self.subStepData.StartFinishGuide)
    for m = 0, self.guideData.EventType.Length - 1 do
      if self.guideData.EventType[m] == 2 then
        CS.UI.UILuaHelper.RegisterGuideBattlePreCallback(handler(self, self.GuideBattlePreCallback))
        break
      end
    end
    if self.subStepData.IsRepeat == 0 and GuideManager:CheckSubStepGuideCmp(self.subStepData.ID) then
      self.guideSubStep = self.guideSubStep + 1
      self:ShowSubStepGuide()
      return
    end
    if not string.IsNullOrEmpty(self.subStepData.WndName) then
      self:LockInput(1.5)
      self:WaitRootUIOpen()
    else
      self:StartSubStepGuide()
    end
  end
end

function Form_Guide:WaitRootUIOpen()
  self.rootUI = CS.UI.UILuaHelper.GetRootUI(self.subStepData.WndName)
  if self.rootUI ~= nil then
    GuideManager:GuideDebug("guide_start FollowWnd::" .. self.subStepData.WndName)
    GuideManager:AddLoopFrame(1, handler(self, self.FollowWnd), nil, "FollowWnd")
    if self.lockerId > 0 then
      CS.UI.UILuaHelper.UnlockInput(self.lockerId)
      self.lockerId = 0
    end
    self:StartSubStepGuide()
  else
    GuideManager:GuideDebug("guide_start wait wnd open::" .. self.subStepData.WndName)
    GuideManager:AddTimer(1, handler(self, self.WaitRootUIOpen), nil, "WaitRootUIOpen")
  end
end

function Form_Guide:StartSubStepGuide()
  local type = self.subStepData.Type
  if type == "click" then
    self.clickmaskFlag = false
    self:ShowClickGuide()
  elseif type == "mapclick" then
    self:ShowClickGuide()
  elseif type == "legacygridclick" then
    self:ShowLegacyClickGuide()
  elseif type == "battleclick" then
    self.clickmaskFlag = false
    self:ShowClickGuide()
  elseif type == "weakclick" then
    self.weakclick = true
    if self.subStepData.TypeParam.Length > 0 then
      local waitNum = tonumber(self.subStepData.TypeParam[0])
      if 0 < waitNum then
        GuideManager:AddTimer(waitNum, handler(self, self.ShowClickGuide), nil, "waitshowclickguide")
      else
        self:ShowClickGuide()
      end
    else
      self:ShowClickGuide()
    end
  elseif type == "weakwait" or type == "weakwaitframe" then
    self.weakclick = true
    local waitNum = tonumber(self.subStepData.TypeParam[0])
    if 0 < waitNum then
      if type == "weakwait" then
        GuideManager:AddTimer(waitNum, handler(self, self.OnWaitEvent), nil, "waitevent")
      else
        GuideManager:AddFrame(waitNum, handler(self, self.OnWaitEvent), nil, "waitframeevent")
      end
    else
      self:OnWaitEvent()
    end
  elseif type == "tips" then
    CS.UI.UILuaHelper.SetLockCastSkill(true)
    self:ShowTipsGuide()
  elseif type == "disablescroll" then
    self:DisableScrollRect()
  elseif type == "resumescroll" then
    self:ResumeScrollRect()
  elseif type == "scrollto" then
    self:ScrollTo()
  elseif type == "battlepre" then
    CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
    self:BattlePre()
  elseif type == "timetowerchoose" then
    self:Timetowerchoose()
  elseif type == "activesubprefab" then
    local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
    if tf ~= nil then
      if tf.gameObject.activeSelf then
        tf.gameObject:SetActive(false)
      else
        tf.gameObject:SetActive(true)
      end
    end
    self:FinishSubStepGuide()
  elseif type == "wait" or type == "waitframe" then
    if 0 < self.subStepData.TypeExeraParam.Length then
      CS.UI.UILuaHelper.SetLockCastSkill(true)
      CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
    end
    local waitNum = tonumber(self.subStepData.TypeParam[0])
    if 0 < waitNum then
      if type == "wait" then
        self:LockInput(waitNum + 1)
        GuideManager:AddTimer(waitNum, handler(self, self.OnWaitEvent), nil, "waitevent")
      else
        self:LockInput(waitNum)
        GuideManager:AddFrame(waitNum, handler(self, self.OnWaitEvent), nil, "waitframeevent")
      end
    else
      self:OnWaitEvent()
    end
  elseif type == "waitingbattletime" then
    if 0 < self.subStepData.TypeExeraParam.Length then
      CS.UI.UILuaHelper.SetLockCastSkill(true)
      CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
    end
    self.waitbattletime = CS.UI.UILuaHelper.GetCurrentBattleTime() + tonumber(self.subStepData.TypeParam[0])
    CS.UI.UILuaHelper.RegisterWaitBattleTimeCallback(handler(self, self.OnWaitBattleTime))
  elseif type == "guideevent" then
    if 0 < self.subStepData.TypeExeraParam.Length then
      CS.UI.UILuaHelper.SetLockCastSkill(true)
      CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
    end
    self:AddGuideEvent()
  elseif type == "playdialogue" then
    self.message = {}
    self.message.vCineVoiceExpressionID = {}
    for i = 1, self.subStepData.TypeParam.Length do
      table.insert(self.message.vCineVoiceExpressionID, self.subStepData.TypeParam[i - 1])
    end
    self.message.iIndex = 0
    self.message.bAutoPlay = false
    self.message.bHideBtn = false
    if 0 < self.subStepData.TypeExeraParam.Length and self.subStepData.TypeExeraParam[0] == 1 then
      self.message.bHideBtn = true
    end
    self.dialogueEndHandler = EventCenter.AddListener(EventDefine.eGameEvent_DialogueShowEnd, handler(self, self.OnDialogueEndEvent))
    EventCenter.Broadcast(EventDefine.eGameEvent_DialogueShow, self.message)
    EventCenter.Broadcast(EventDefine.eGameEvent_DialogueChangeSkip, true)
  elseif type == "hidebattleui" then
    local hideAll = true
    if self.subStepData.TypeParam.Length > 0 and tonumber(self.subStepData.TypeParam[0]) == 1 then
      hideAll = false
    end
    CS.UI.UILuaHelper.HideBattleUI(hideAll)
    self:FinishSubStepGuide()
  elseif type == "showbattleui" then
    CS.UI.UILuaHelper.ShowBattleUI()
    self:FinishSubStepGuide()
  elseif type == "hidemainui" then
    CS.UI.UILuaHelper.HideMainUI()
    self:FinishSubStepGuide()
  elseif type == "showmainui" then
    CS.UI.UILuaHelper.ShowMainUI()
    self:FinishSubStepGuide()
  elseif type == "waitcastskill" then
    self:AddWaitCastSkillEvent()
  elseif type == "pausebattle" then
    CS.UI.UILuaHelper.SetPauseExcept(true)
    self:FinishSubStepGuide()
  elseif type == "resumbattle" then
    CS.UI.UILuaHelper.SetPauseExcept(false)
    self:FinishSubStepGuide()
  elseif type == "blackin" then
    local lifeTime = tonumber(self.subStepData.TypeParam[0])
    CS.UI.UILuaHelper.BlackTopIn(lifeTime)
    self:FinishSubStepGuide()
  elseif type == "blackout" then
    CS.UI.UILuaHelper.BlackTopOut()
    self:FinishSubStepGuide()
  elseif type == "opentutorialtips" then
    StackFlow:Push(UIDefines.ID_FORM_GUIDEPICTURRE, tonumber(self.subStepData.TypeParam[0]))
    self:FinishSubStepGuide()
  elseif type == "openwnd" then
    local params = self.subStepData.TypeParam
    local wndName = params[0]
    local param
    if params.Length == 2 then
      param = params[1]
    end
    CS.UI.UILuaHelper.OpenWnd(wndName, param)
    self:FinishSubStepGuide()
  elseif type == "closewnd" then
    local params = self.subStepData.TypeParam
    local wndName = params[0]
    CS.UI.UILuaHelper.CloseWnd(wndName)
    self:FinishSubStepGuide()
  elseif type == "playvideo" then
    local params = self.subStepData.TypeParam
    local videoName = params[0]
    local isSkipable = params[1] == "1"
    local subtitleName
    if params.Length == 3 then
      subtitleName = params[2]
    end
    CS.UI.UILuaHelper.PlayFromAddRes(videoName, subtitleName, isSkipable, handler(self, self.OnVideoPlayFinish))
  elseif type == "playtimeline" then
    local params = self.subStepData.TypeParam
    local timelineName = params[0]
    local isSkipable = params[1] == "1"
    local preloadTimelineName = ""
    if params.Length == 3 then
      preloadTimelineName = params[2]
    end
    CS.UI.UILuaHelper.PlayTimeline(timelineName, isSkipable, preloadTimelineName, handler(self, self.OnTimelinePlayFinish))
  elseif type == "setherotop" then
    local heroId = tonumber(self.subStepData.TypeParam[0])
    local wndForm = self:GetOpenUIInstanceLua(self.subStepData.WndName)
    if wndForm ~= nil then
      wndForm:GuideSortHero(heroId)
    end
    self:FinishSubStepGuide()
  elseif type == "setitemtop" then
    local itemId = tonumber(self.subStepData.TypeParam[0])
    local form = StackFlow:GetUIInstanceLua(UIDefines.ID_FORM_BAG)
    if form ~= nil then
      form:GuideSetItemTop(itemId)
    end
    self:FinishSubStepGuide()
  elseif type == "waitclosewnd" then
  elseif type == "mutebgm" then
    local mute = false
    if self.subStepData.TypeParam.Length > 0 and tonumber(self.subStepData.TypeParam[0]) == 1 then
      mute = true
    end
    CS.UI.UILuaHelper.MutePlayBGM(mute)
    self:FinishSubStepGuide()
  elseif type == "setbattlespeed" then
    CS.UI.UILuaHelper.GuideSetBattleSpeed(tonumber(self.subStepData.TypeParam[0]))
    self:FinishSubStepGuide()
  elseif type == "battlecardtop" then
    CS.UI.UILuaHelper.GuideBattleCardTop(tonumber(self.subStepData.TypeParam[0]))
    self:FinishSubStepGuide()
  elseif type == "battlewaitenergy" then
    local globalEnergy = CS.UI.UILuaHelper.GetBattleGlobalEnergy()
    if globalEnergy >= tonumber(self.subStepData.TypeParam[0]) then
      self:FinishSubStepGuide()
    else
      CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
      CS.UI.UILuaHelper.GuideGlobalLockCastSkill = true
      CS.UI.UILuaHelper.SetLockCastSkill(true)
      if self.battleEnergyEvenHandler then
        EventCenter.RemoveListener(EventDefine.eGameBattle_EnergyChange, self.battleEnergyEvenHandler)
        self.battleEnergyEvenHandler = nil
      end
      self.battleEnergyEvenHandler = EventCenter.AddListener(EventDefine.eGameBattle_EnergyChange, handler(self, self.OnBattleEnergyEvent))
    end
  elseif type == "battleskill" then
    CS.UI.UILuaHelper.GuideGlobalLockCastSkill = false
    CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
    self:GuideBattleSkill()
  elseif type == "legacygforcusgrid" then
    CS.VisualExploreManager.ForcusGrid(self.subStepData.TypeExeraParam[0], self.subStepData.TypeExeraParam[1])
    self:FinishSubStepGuide()
  end
end

function Form_Guide:GuideBattleSkill()
  local params = self.subStepData.TypeParam
  local cardIdx = tonumber(params[0])
  self.targetUnitId = tonumber(params[1])
  self.offsetx = tonumber(params[2])
  self.offsetz = tonumber(params[3])
  local checkVale = tonumber(params[4])
  self.duration = 1.5
  local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
  self.fromPos = tf.position
  self.isTemplateId = false
  if params.Length > 5 and tonumber(params[5]) == 1 then
    self.isTemplateId = true
  end
  self.toPos = CS.UI.UILuaHelper.GetBattleCharacterScreenPosition(self.targetUnitId, self.offsetx, self.offsetz, self.isTemplateId)
  self.localFromPos = Vector3.New(0, 0, 0)
  self.localToPos = Vector3.New(0, 0, 0)
  if 0 < self.subStepData.TargetOffset.Length then
    self.localFromPos = Vector3.New(self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
    SetLocalPositionXYZ(self.m_BattleDragSkillOffSetContainer.transform, self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
  else
    SetLocalPositionXYZ(self.m_BattleDragSkillOffSetContainer.transform, 0, 0, 0)
  end
  if 0 < self.subStepData.TypeExeraParam.Length then
    self.m_BattleDragSkillTargetContainer:SetActive(true)
    self.m_BattleDragSkillTargetContainer.transform.position = self.toPos
  end
  if not string.IsNullOrEmpty(self.subStepData.Tips) then
    self:InitTipsView()
  end
  self:StartBattleDragMove()
  CS.UI.UILuaHelper.GuideBattleSkill(cardIdx, self.targetUnitId, self.offsetx, self.offsetz, checkVale, handler(self, self.GuideBattleSkillCallback), self.isTemplateId)
end

function Form_Guide:StartBattleDragMove()
  self.m_BattleDragSkillContainer.transform.position = self.fromPos
  self.m_BattleDragSkillOffSetContainer.transform.localPosition = self.localFromPos
  self.m_BattleDragSkillContainer:SetActive(false)
  self.m_BattleDragSkillContainer:SetActive(true)
  self.m_ui_common_drag:SetActive(true)
  GuideManager:RemoveTimerByKey("BattleDragMove")
  GuideManager:AddTimer(0.5, handler(self, self.DoBattleDragMoveTween), nil, "BattleDragMove")
end

function Form_Guide:DoBattleDragMoveTween()
  local timeScale = CS.BattleGameManager.Instance:GetBattleSpeed()
  if timeScale < 1 then
    timeScale = 1
  end
  local movedDuration = self.duration / timeScale
  if movedDuration < 1 then
    movedDuration = 1
  end
  self.toPos = CS.UI.UILuaHelper.GetBattleCharacterScreenPosition(self.targetUnitId, self.offsetx, self.offsetz, self.isTemplateId)
  if self.subStepData.TypeExeraParam.Length > 0 then
    self.m_BattleDragSkillTargetContainer.transform.position = self.toPos
  end
  CS.UI.UILuaHelper.DoMoveTween(self.m_BattleDragSkillContainer.transform, self.fromPos, self.toPos, movedDuration, nil, "DoMoveTween", false, false, 16)
  if 0 < self.subStepData.TargetOffset.Length then
    CS.UI.UILuaHelper.DoMoveTween(self.m_BattleDragSkillOffSetContainer.transform, self.localFromPos, self.localToPos, movedDuration, nil, "DoLocalMoveTween", true, false, 16)
  end
  GuideManager:RemoveTimerByKey("BattleDragMove")
  GuideManager:AddTimer(movedDuration, handler(self, self.DoBattleDragMoveCmp), nil, "BattleDragMove")
end

function Form_Guide:DoBattleDragMoveCmp()
  GuideManager:RemoveTimerByKey("BattleDragMove")
  self.m_ui_common_drag:SetActive(false)
  GuideManager:AddTimer(1, handler(self, self.StartBattleDragMove), nil, "BattleDragMove")
end

function Form_Guide:GuideBattleSkillCallback(ret)
  if ret and self.subStepData and self.subStepData.Type == "battleskill" then
    CS.UI.UILuaHelper.RegisterGuideCallback(nil)
    CS.UI.UILuaHelper.KillTween("DoMoveTween")
    CS.UI.UILuaHelper.KillTween("DoLocalMoveTween")
    self:FinishSubStepGuide()
  end
end

function Form_Guide:LockInput(time)
  if self.lockerId > 0 then
    CS.UI.UILuaHelper.UnlockInput(self.lockerId)
  end
  self.lockerId = CS.UI.UILuaHelper.LockInput(time)
end

function Form_Guide:OnBattleEnergyEvent(globalEnergy)
  if self.subStepData and self.subStepData.Type == "battlewaitenergy" and globalEnergy >= tonumber(self.subStepData.TypeParam[0]) then
    if self.battleEnergyEvenHandler then
      EventCenter.RemoveListener(EventDefine.eGameBattle_EnergyChange, self.battleEnergyEvenHandler)
      self.battleEnergyEvenHandler = nil
    end
    self:FinishSubStepGuide()
  end
end

function Form_Guide:OnEventWndInactive(wndName)
  if self.subStepData and self.subStepData.Type == "waitclosewnd" and self.subStepData.TypeParam[0] == wndName then
    self:FinishSubStepGuide()
  end
end

function Form_Guide:AddWaitCastSkillEvent()
  if self.waitCastSkillEventHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_GuideWaitCastSkillEvent, self.waitCastSkillEventHandler)
    self.waitCastSkillEventHandler = nil
  end
  self.waitCastSkillEventHandler = EventCenter.AddListener(EventDefine.eGameEvent_GuideWaitCastSkillEvent, handler(self, self.OnWaitCastSkillEvent))
  CS.UI.UILuaHelper.LockCastSkillCharId = tonumber(self.subStepData.TypeParam[0])
end

function Form_Guide:AddGuideEvent()
  if self.guideEventHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_GuideEvent, self.guideEventHandler)
    self.guideEventHandler = nil
  end
  self.guideEventHandler = EventCenter.AddListener(EventDefine.eGameEvent_GuideEvent, handler(self, self.OnGuideEvent))
end

function Form_Guide:OnVideoPlayFinish()
  self:FinishSubStepGuide()
end

function Form_Guide:OnTimelinePlayFinish()
  self:FinishSubStepGuide()
end

function Form_Guide:OnDialogueEndEvent()
  if self.subStepData and self.subStepData.Type == "playdialogue" and self.message then
    if self.dialogueEndHandler then
      EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
      self.dialogueEndHandler = nil
    end
    self:FinishSubStepGuide()
  end
end

function Form_Guide:OnWaitCastSkillEvent(charId)
  if self.subStepData and self.subStepData.Type == "waitcastskill" and (self.subStepData.TypeParam.Length == 0 or tonumber(self.subStepData.TypeParam[0]) == charId) then
    if self.waitCastSkillEventHandler then
      EventCenter.RemoveListener(EventDefine.eGameEvent_GuideWaitCastSkillEvent, self.waitCastSkillEventHandler)
      self.waitCastSkillEventHandler = nil
    end
    self:FinishSubStepGuide()
  end
end

function Form_Guide:OnGuideEvent()
  if self.guideEventHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_GuideEvent, self.guideEventHandler)
    self.guideEventHandler = nil
  end
  self:FinishSubStepGuide()
end

function Form_Guide:OnWaitEvent()
  self:FinishSubStepGuide()
end

function Form_Guide:GuideBattlePreCallback(_inBattleType, _dragType, _fromIdx, _toIdx)
  if self.subStepData and (self.subStepData.Type == "guideevent" or self.subStepData.Type == "battlewaitenergy" or self.subStepData.Type == "weakclick") then
    return false
  end
  if self.subStepData and self.subStepData.Type == "battlepre" then
    local params = self.subStepData.TypeParam
    local inBattleType = tonumber(params[0])
    local fromIdx = tonumber(params[1])
    local toIdx = tonumber(params[2])
    if _inBattleType ~= inBattleType then
      return true
    end
    if _inBattleType == 0 then
      if _dragType == 1 then
        if 0 < self.subStepData.TypeExeraParam.Length then
          self.m_guide_starup:SetActive(false)
        end
        if _toIdx == toIdx or _toIdx == -1 then
          CS.UI.UILuaHelper.ClearGuidePointEffect()
          CS.UI.UILuaHelper.KillTween("DoMoveTween")
          self:FinishSubStepGuide()
          return false
        end
      elseif _dragType == 0 and _fromIdx == fromIdx then
        if 0 < self.subStepData.TypeExeraParam.Length then
          self.m_guide_starup:SetActive(true)
        end
        return false
      end
    elseif _inBattleType == 1 then
      if _dragType == 1 then
        if _toIdx == toIdx then
          CS.UI.UILuaHelper.ClearGuidePointEffect()
          CS.UI.UILuaHelper.KillTween("DoMoveTween")
          self:FinishSubStepGuide()
          return false
        end
      elseif _dragType == 0 and _fromIdx == fromIdx then
        return false
      end
    end
  end
  return true
end

function Form_Guide:Timetowerchoose()
  local params = self.subStepData.TypeParam
  local fromIdx = tonumber(params[0])
  local toGridX = tonumber(params[1])
  local toGridY = tonumber(params[2])
  local toGridPath = params[3]
  self.duration = 1.5
  local wndForm = self:GetOpenUIInstanceLua(self.subStepData.WndName)
  if wndForm == nil then
    GuideManager:AddFrame(1, handler(self, self.Timetowerchoose), nil, "ShowGuide")
    return
  end
  self.toPosIdx = nil
  self.toPos = self.rootUI.transform:Find(toGridPath).position
  self.fromPos = self.rootUI.transform:Find(self.subStepData.TargetPath).position
  self.localFromPos = Vector3.New(0, 0, 0)
  local toGridLocalX = 0
  local toGridLocalY = 0
  if params.Length > 5 then
    toGridLocalX = tonumber(params[4])
    toGridLocalY = tonumber(params[5])
  end
  self.localToPos = Vector3.New(toGridLocalX, toGridLocalY, 0)
  if 0 < self.subStepData.TargetOffset.Length then
    self.localFromPos = Vector3.New(self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
    SetLocalPositionXYZ(self.m_BattleDragSkillOffSetContainer.transform, self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
  else
    SetLocalPositionXYZ(self.m_BattleDragSkillOffSetContainer.transform, 0, 0, 0)
  end
  if not string.IsNullOrEmpty(self.subStepData.Tips) then
    self:InitTipsView()
  end
  self:StartTimetowerchooseMove()
  wndForm:GuideTimetowerchoose(fromIdx, toGridX, toGridY, handler(self, self.GuideTimetowerchooseCallback))
end

function Form_Guide:StartTimetowerchooseMove()
  self.m_BattleDragSkillContainer.transform.position = self.fromPos
  self.m_BattleDragSkillOffSetContainer.transform.localPosition = self.localFromPos
  self.m_BattleDragSkillContainer:SetActive(false)
  self.m_BattleDragSkillContainer:SetActive(true)
  self.m_ui_common_drag:SetActive(true)
  GuideManager:RemoveTimerByKey("BattleDragMove")
  GuideManager:AddTimer(0.5, handler(self, self.DoTimetowerchooseTween), nil, "BattleDragMove")
end

function Form_Guide:DoTimetowerchooseTween()
  local movedDuration = self.duration
  CS.UI.UILuaHelper.DoMoveTween(self.m_BattleDragSkillContainer.transform, self.fromPos, self.toPos, movedDuration, nil, "DoMoveTween", false, false, 16)
  if self.subStepData.TargetOffset.Length > 0 then
    CS.UI.UILuaHelper.DoMoveTween(self.m_BattleDragSkillOffSetContainer.transform, self.localFromPos, self.localToPos, movedDuration, nil, "DoLocalMoveTween", true, false, 16)
  end
  GuideManager:RemoveTimerByKey("BattleDragMove")
  GuideManager:AddTimer(movedDuration, handler(self, self.DoTimetowerchooseMoveCmp), nil, "BattleDragMove")
end

function Form_Guide:DoTimetowerchooseMoveCmp()
  GuideManager:RemoveTimerByKey("BattleDragMove")
  self.m_ui_common_drag:SetActive(false)
  GuideManager:AddTimer(1, handler(self, self.StartTimetowerchooseMove), nil, "BattleDragMove")
end

function Form_Guide:GuideTimetowerchooseCallback()
  if self.subStepData and self.subStepData.Type == "timetowerchoose" then
    CS.UI.UILuaHelper.KillTween("DoMoveTween")
    self:FinishSubStepGuide()
  end
end

function Form_Guide:BattlePre()
  local params = self.subStepData.TypeParam
  local inBattleType = tonumber(params[0])
  local fromIdx = tonumber(params[1])
  local toIdx = tonumber(params[2])
  self.duration = tonumber(params[3])
  local toPos
  if 0 < toIdx then
    toPos = CS.UI.UILuaHelper.GetBattleGridEffectPos(toIdx)
    if toPos.x == 0 and toPos.y == 0 and toPos.z == 0 then
      GuideManager:AddFrame(1, handler(self, self.BattlePre), nil, "ShowGuide")
      return
    end
  end
  self.fromPos = Vector3.New(0, 0, 0)
  if inBattleType == 0 then
    local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
    if tf ~= nil then
      self.fromPos = tf.position
      if 0 < toIdx then
        local isInFormation = CS.UI.UILuaHelper.CardInFormation(fromIdx)
        if isInFormation then
          self:FinishSubStepGuide()
          return
        end
      end
    else
      GuideManager:AddFrame(1, handler(self, self.BattlePre), nil, "ShowGuide")
      return
    end
  else
    self.fromPos = CS.UI.UILuaHelper.GetBattleGridEffectPos(fromIdx)
    local isInFormation = CS.UI.UILuaHelper.CharacterInFormation(fromIdx)
    if not isInFormation then
      self:FinishSubStepGuide()
      return
    end
  end
  self.toPosIdx = toIdx
  self.toPos = toPos
  if 0 < toIdx then
    self.m_BattlePreContainer:SetActive(true)
    self.rootAnimator:Play("VX_Guide_Loop_BattlepreAnimation")
    CS.UI.UILuaHelper.ShowGuidePointEffect(toIdx)
    self:StartBattlePreMove()
  else
    self.m_guide_starup:SetActive(true)
    self.m_guide_starup.transform.position = self.fromPos
  end
end

function Form_Guide:DoMoveTweenCmp()
  self.rootAnimator:Play("VX_Guide_Exit_BattlepreAnimation")
  GuideManager:RemoveTimerByKey("BattlePreMove")
  GuideManager:AddTimer(1, handler(self, self.StartBattlePreMove), nil, "BattlePreMove")
end

function Form_Guide:StartBattlePreMove()
  self.rootAnimator:Play("VX_Guide_Enter_BattlepreAnimation")
  self.m_BattlePreContainer.transform.position = self.fromPos
  GuideManager:RemoveTimerByKey("BattlePreMove")
  GuideManager:AddTimer(0.5, handler(self, self.DoMoveTween), nil, "BattlePreMove")
end

function Form_Guide:DoMoveTween()
  local timeScale = CS.BattleGameManager.Instance:GetBattleSpeed()
  if timeScale < 1 then
    timeScale = 1
  end
  local movedDuration = self.duration / timeScale
  if movedDuration < 1 then
    movedDuration = 1
  end
  if self.toPosIdx then
    local toPos = CS.UI.UILuaHelper.GetBattleGridEffectPos(self.toPosIdx)
    self.toPos = toPos
  end
  CS.UI.UILuaHelper.DoMoveTween(self.m_BattlePreContainer.transform, self.fromPos, self.toPos, movedDuration, nil, "DoMoveTween", false, false, 16)
  GuideManager:RemoveTimerByKey("BattlePreMove")
  GuideManager:AddTimer(movedDuration, handler(self, self.DoMoveTweenCmp), nil, "BattlePreMove")
end

function Form_Guide:DisableScrollRect()
  local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
  if tf ~= nil then
    local infinityGrid = tf:GetComponent("InfinityGrid")
    if infinityGrid then
      infinityGrid:DisableScrollRect()
    end
  end
  self:FinishSubStepGuide()
end

function Form_Guide:ResumeScrollRect()
  local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
  if tf ~= nil then
    local infinityGrid = tf:GetComponent("InfinityGrid")
    if infinityGrid then
      infinityGrid:ResumeScrollRect()
    end
  end
  self:FinishSubStepGuide()
end

function Form_Guide:ScrollTo()
  local tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
  if tf ~= nil then
    local infinityGrid = tf:GetComponent("InfinityGrid")
    if infinityGrid then
      infinityGrid:ScrollTo(tonumber(self.subStepData.TypeParam[0]), 0)
    end
  end
  self:FinishSubStepGuide()
end

function Form_Guide:OnWaitBattleTime(battleTime)
  if self.waitbattletime > 0 and self.subStepData and self.subStepData.Type == "waitingbattletime" and battleTime >= self.waitbattletime then
    self.waitbattletime = 0
    self:FinishSubStepGuide()
  end
end

function Form_Guide:OnGuideLegacyClick(gridx, gridz)
  if self.subStepData and self.subStepData.Type == "legacygridclick" and self.subStepData.TypeExeraParam[0] == gridx and self.subStepData.TypeExeraParam[1] == gridz then
    CS.VisualExploreManager.ClearGuideLimit()
    self:FinishSubStepGuide()
    return false
  end
  return true
end

function Form_Guide:OnGuideClick(go, mapclick, manualFinish)
  if go and type(go) == "userdata" and go == self.m_SkipGuide_Btn then
    return false
  end
  if self.subStepData and self.subStepData.Type == "legacygridclick" then
    return true
  end
  if self.subStepData and (self.subStepData.Type == "wait" or self.subStepData.Type == "waitframe") then
    return true
  end
  if not self.subStepData or self.subStepData.Type ~= "mapclick" or mapclick then
  else
    return true
  end
  if mapclick then
    if self.subStepData and self.subStepData.Type == "mapclick" and go and type(go) == "userdata" and self.mainTarget and go == self.mainTarget then
      self.clickmaskFlag = true
      if self.subStepData.AutoFinishSubStep or manualFinish then
        CS.UI.UILuaHelper.RegisterGuideCallback(nil)
        self:FinishSubStepGuide()
      end
      return false
    end
    return true
  end
  if self.subStepData and not string.IsNullOrEmpty(self.subStepData.WndName) and go and type(go) == "userdata" and go.transform and not CS.UI.UILuaHelper.CheckGuideClickInView(go.transform, self.subStepData.WndName) then
    return false
  end
  if self.subStepData and self.subStepData.Type == "battleskill" then
    return true
  end
  if self.subStepData and (self.subStepData.Type == "battlewaitenergy" or self.subStepData.Type == "waitingbattletime") then
    return true
  end
  if self.subStepData and self.subStepData.Type == "battlepre" then
    return true
  end
  if self.subStepData and (self.subStepData.Type == "click" or self.subStepData.Type == "battleclick") and self.mainTarget then
    if go == self.m_FilterMask_Btn or go == self.m_Mask_Btn or go == self.m_SkipGuide_Btn then
      return false
    end
    if go == self.mainTarget then
      if self.guideDisableScrollRect then
        CS.UI.UILuaHelper.GuideEnabledScrollRect(self.rootUI, self.mainTarget)
        self.guideDisableScrollRect = false
      end
      self.clickmaskFlag = true
      if self.subStepData.AutoFinishSubStep or manualFinish then
        self:FinishSubStepGuide()
      end
      return false
    else
      if not string.IsNullOrEmpty(self.subStepData.FilterTips) then
        self.m_FilterTipsContainer:SetActive(true)
        self.m_FilterText_Text.text = self.subStepData.FilterTips
      end
      return true
    end
  else
    return false
  end
end

function Form_Guide:FollowTarget()
  if self.subStepData.Type == "legacygridclick" or not IsNil(self.mainTarget) then
    local mainTargetPosition
    if self.subStepData.Type == "mapclick" then
      mainTargetPosition = Vector3.New(0, 0, 0)
      local wndForm = self:GetOpenUIInstanceLua(self.subStepData.WndName)
      if wndForm ~= nil and wndForm:IsEnterAnimEnd() then
        mainTargetPosition = CS.UI.UILuaHelper.GetLevelMapScreenPosition(self.mainTarget.transform)
      end
    elseif self.subStepData.Type == "legacygridclick" then
      mainTargetPosition = CS.UI.UILuaHelper.GetLegacyGridScreenPosition(self.subStepData.TypeExeraParam[0], self.subStepData.TypeExeraParam[1])
    else
      mainTargetPosition = self.mainTarget.transform.position
    end
    local clickPosition = self.m_ClickContainer.transform.position
    if self.subStepData.Type == "legacygridclick" then
      if not self.m_ClickContainer.activeInHierarchy then
        self.m_ClickContainer:SetActive(true)
      end
    elseif self.m_ClickContainer.activeInHierarchy ~= self.mainTarget.activeInHierarchy then
      self.m_ClickContainer:SetActive(self.mainTarget.activeInHierarchy)
    end
    if mainTargetPosition.x == clickPosition.x and mainTargetPosition.y == clickPosition.y then
      return
    end
    self.m_ClickContainer.transform.position = mainTargetPosition
  else
    self.m_ClickContainer:SetActive(false)
  end
end

function Form_Guide:MaskFollowTarget(target)
  if not IsNil(target) then
    local mainTargetPosition
    if self.subStepData.Type == "mapclick" then
      mainTargetPosition = Vector3.New(0, 0, 0)
      local wndForm = self:GetOpenUIInstanceLua(self.subStepData.WndName)
      if wndForm ~= nil and wndForm:IsEnterAnimEnd() then
        mainTargetPosition = CS.UI.UILuaHelper.GetLevelMapScreenPosition(self.mainTarget.transform)
      end
    else
      mainTargetPosition = target.transform.position
    end
    if self.m_guide_mask.activeInHierarchy then
      self.m_guide_mask.transform.position = mainTargetPosition
    end
    if self.m_guide_herotalk.activeInHierarchy then
      self.m_guide_herotalk.transform.position = mainTargetPosition
    end
  end
end

function Form_Guide:ShowLegacyClickGuide()
  if self.subStepData == nil then
    return
  end
  if not string.IsNullOrEmpty(self.subStepData.Tips) or self.subStepData.TypeParam.Length > 0 and self.subStepData.TypeParam[0] == "showmask" then
    self:InitTipsView()
  end
  self:FollowTarget()
  GuideManager:RemoveFrameByKey("FollowTarget")
  GuideManager:AddLoopFrame(1, handler(self, self.FollowTarget), self.mainTarget, "FollowTarget")
  self.m_ClickContainer:SetActive(true)
  self.rootAnimator:Play("VX_Guide_Enter_Animation")
  if 0 < self.subStepData.TargetRotationZ then
    CS.UI.UILuaHelper.SetLocalRotationParam(self.m_OffSetContainer, 0, 0, self.subStepData.TargetRotationZ)
  else
    CS.UI.UILuaHelper.SetLocalRotationParam(self.m_OffSetContainer, 0, 0, 0)
  end
  if 0 < self.subStepData.TargetOffset.Length then
    SetLocalPositionXYZ(self.m_OffSetContainer.transform, self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
  else
    SetLocalPositionXYZ(self.m_OffSetContainer.transform, 0, 0, 0)
  end
  local x = self.subStepData.TypeExeraParam[0]
  local y = self.subStepData.TypeExeraParam[1]
  CS.VisualExploreManager.SetGuideLimit(x, y)
  CS.UI.UILuaHelper.RegisterLegacyGuideCallback(handler(self, self.OnGuideLegacyClick))
end

function Form_Guide:ShowClickGuide()
  if self.subStepData == nil then
    return
  end
  if string.IsNullOrEmpty(self.subStepData.TargetPath) then
    GuideManager:GuideDebug("guide_点击引导配置异常，引导id:" .. self.subStepData.ID)
    return
  end
  local tf
  if self.subStepData.Type == "mapclick" then
    tf = CS.UI.UILuaHelper.GetLevelMapSceneObj(self.subStepData.TargetPath)
  else
    tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
  end
  if tf == nil then
    GuideManager:GuideDebug("guide_点击引导path路径异常，引导id:" .. self.subStepData.ID .. ":path:" .. self.subStepData.TargetPath)
    self:LockInput(1.5)
    GuideManager:AddTimer(1, handler(self, self.ShowClickGuide), nil, "ShowClickGuide")
    return
  else
    self.mainTarget = tf.gameObject
    if not string.IsNullOrEmpty(self.subStepData.Tips) or self.subStepData.TypeParam.Length > 0 and self.subStepData.TypeParam[0] == "showmask" then
      self:InitTipsView()
    end
    if self.subStepData.Type == "click" then
      self.guideDisableScrollRect = CS.UI.UILuaHelper.GuideDisableScrollRect(self.rootUI, self.mainTarget)
    end
    self:FollowTarget()
    GuideManager:RemoveFrameByKey("FollowTarget")
    GuideManager:AddLoopFrame(1, handler(self, self.FollowTarget), self.mainTarget, "FollowTarget")
  end
  self.m_ClickContainer:SetActive(true)
  self.rootAnimator:Play("VX_Guide_Enter_Animation")
  if 0 < self.subStepData.TargetRotationZ then
    CS.UI.UILuaHelper.SetLocalRotationParam(self.m_OffSetContainer, 0, 0, self.subStepData.TargetRotationZ)
  else
    CS.UI.UILuaHelper.SetLocalRotationParam(self.m_OffSetContainer, 0, 0, 0)
  end
  if 0 < self.subStepData.TargetOffset.Length then
    SetLocalPositionXYZ(self.m_OffSetContainer.transform, self.subStepData.TargetOffset[0], self.subStepData.TargetOffset[1], 0)
  else
    SetLocalPositionXYZ(self.m_OffSetContainer.transform, 0, 0, 0)
  end
  if not self.weakclick then
    CS.UI.UILuaHelper.RegisterGuideCallback(handler(self, self.OnGuideClick))
  end
end

function Form_Guide:InitTipsView()
  local tf
  if not string.IsNullOrEmpty(self.subStepData.TargetPath) then
    if self.subStepData.Type == "mapclick" then
      tf = self.mainTarget.transform
    else
      tf = self.rootUI.transform:Find(self.subStepData.TargetPath)
    end
    if tf == nil then
      GuideManager:AddFrame(1, handler(self, self.InitTipsView), nil, "InitTipsView")
      return
    end
  end
  if not string.IsNullOrEmpty(self.subStepData.Tips) then
    self.m_guide_herotalk:SetActive(true)
    self.m_txt_herotalk_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(self.subStepData.Tips)
    local headIcon = "Atlas_Role/Nevernight_Final001"
    if not string.IsNullOrEmpty(self.subStepData.TipsPortrait) then
      headIcon = self.subStepData.TipsPortrait
    end
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_hero_head_Image, headIcon)
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_guide_herotalk)
    if self.subStepData.Type == "tips" then
      self.rootAnimator:Play("VX_Guide_Enter_HeroTalk")
    end
  else
    self.m_guide_herotalk:SetActive(false)
  end
  self.m_guide_mask:SetActive(true)
  if tf ~= nil then
    GuideManager:RemoveFrameByKey("MaskFollowTarget")
    self:MaskFollowTarget(tf)
    GuideManager:AddLoopFrame(1, handler(self, self.MaskFollowTarget), tf, "MaskFollowTarget")
  elseif self.subStepData.TypeExeraParam.Length > 0 then
    if self.subStepData.TypeExeraParam.Length == 1 or self.subStepData.TypeExeraParam.Length == 3 then
      local mainTargetPosition = CS.UI.UILuaHelper.GetBattleCharacterScreenPosition(self.subStepData.TypeExeraParam[0], 0, 0, self.subStepData.TypeExeraParam.Length == 3)
      self.m_guide_mask.transform.position = mainTargetPosition
      self.m_guide_herotalk.transform.position = mainTargetPosition
    else
      local mainTargetPosition = CS.UI.UILuaHelper.GetLegacyGridScreenPosition(self.subStepData.TypeExeraParam[0], self.subStepData.TypeExeraParam[1])
      self.m_guide_mask.transform.position = mainTargetPosition
      self.m_guide_herotalk.transform.position = mainTargetPosition
    end
  else
    self.m_guide_mask.transform.localPosition = Vector3.New(0, 0, 0)
    self.m_guide_herotalk.transform.localPosition = Vector3.New(0, 0, 0)
  end
  if self.subStepData.TipsOffset.Length == 0 then
    self.subStepData.TipsOffset = string.split("520;520;" .. self.subStepData.TargetOffset[0] .. ";" .. self.subStepData.TargetOffset[1] .. ";0;0;150;150;0;0", ";")
  end
  CS.UI.UILuaHelper.InitGuideTipsView(self.m_mask_center, self.m_talk_OffSetContainer, self.subStepData.TipsOffset)
  self.m_SkipGuide_Btn:SetActive(0 < self.subStepData.CanSkip.Length)
end

function Form_Guide:ShowTipsGuide()
  self.m_Mask_Btn:SetActive(true)
  self:InitTipsView()
end

function Form_Guide:OnMaskBtnClicked()
  self:FinishSubStepGuide()
end

function Form_Guide:OnFilterMaskBtnClicked()
  self.m_FilterTipsContainer:SetActive(false)
end

function Form_Guide:OnSkipGuideBtnClicked()
  if CS.UI.UILuaHelper.GetDayCount("GuideSkip") > 0 then
    GuideManager:SkipCurrentGuide()
  else
    StackPopup:Push(UIDefines.ID_FORM_GUIDESKIPPOP)
  end
end

function Form_Guide:SkipCurrentGuide()
  if self.guideData and self.subStepData and self.subStepData.CanSkip.Length > 0 then
    local guides = {}
    for i = 0, self.subStepData.CanSkip.Length - 1 do
      table.insert(guides, self.subStepData.CanSkip[i])
    end
    GuideManager:FinishStepGuides(guides)
  end
  self:EndGuide()
  self:CloseForm()
end

function Form_Guide:FinishSubStepGuide()
  self:RemoveScheduler()
  self:ResetRegisterClick()
  self:ResetView()
  GuideManager:GuideDebug("guide_FinishSubStepGuide:::::step_id:" .. self.subStepData.ID .. "::type:" .. self.subStepData.Type)
  GuideManager:FinishSubStepGuide(self.subStepData.ID, self.subStepData.IsRepeat == 0)
  self:FinishStepGuides(self.subStepData.EndFinishGuide)
  if self.subStepData.DelayShowNextStep and self.guideSubStep < self.guideData.SubStepIds.Length then
    self:LockInput(0.5)
    GuideManager:RemoveFrameByKey("DelayShowStepGuide")
    GuideManager:AddFrame(1, handler(self, self.DelayShowStepGuide), nil, "DelayShowStepGuide")
  else
    self.guideSubStep = self.guideSubStep + 1
    self:ShowSubStepGuide()
  end
end

function Form_Guide:DelayShowStepGuide()
  self.guideSubStep = self.guideSubStep + 1
  self:ShowSubStepGuide()
end

function Form_Guide:FinishStepGuides(finishGuides)
  if finishGuides and 0 < #finishGuides then
    local completeGuides = {}
    for i = 1, #finishGuides do
      local guideId = tonumber(finishGuides[i])
      if 0 < guideId then
        table.insert(completeGuides, guideId)
      end
    end
    if 0 < #completeGuides then
      GuideManager:FinishStepGuides(completeGuides)
    end
  end
end

function Form_Guide:FollowWnd()
  if IsNil(self.rootUI) then
    if self.guideData then
      GuideManager:GuideDebug("guide_异常退出结束引导::::::id:" .. self.guideData.ID)
    end
    self:EndGuide()
  else
    StackSpecial:SetGuideUISortingOrder(self.rootUI)
  end
end

function Form_Guide:GuideIsActive()
  if self.guideData and self.subStepData then
    return true
  end
  return false
end

function Form_Guide:CheckGuideIsActive(guideId)
  if self.guideData and self.subStepData and self.guideData.ID == guideId then
    return true
  end
  return false
end

function Form_Guide:GetOpenUIInstanceLua(wndName)
  local uiid = CS.UIDefinesForLua.Get(wndName)
  local wndForm = StackFlow:GetOpenUIInstanceLua(uiid)
  if wndForm ~= nil then
    return wndForm
  end
  wndForm = StackPopup:GetOpenUIInstanceLua(uiid)
  if wndForm ~= nil then
    return wndForm
  end
  wndForm = StackTop:GetOpenUIInstanceLua(uiid)
  if wndForm ~= nil then
    return wndForm
  end
  wndForm = StackSpecial:GetOpenUIInstanceLua(uiid)
  if wndForm ~= nil then
    return wndForm
  end
  return nil
end

local fullscreen = true
ActiveLuaUI("Form_Guide", Form_Guide)
return Form_Guide
