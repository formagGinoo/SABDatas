local Form_Dialogue = class("Form_Dialogue", require("UI/UIFrames/Form_DialogueUI"))

function Form_Dialogue:SetInitParam(param)
end

local DialogueType = {Dialogue = 0, OptionList = 1}

function Form_Dialogue:AfterInit()
  self.speedUp = false
  self.super.AfterInit(self)
  self.m_fTime = 0
  self.m_lockClickTime = 0
  self.m_iStyleMax = 2
  self.m_fDuration = -1
  self.m_iDialogueStyle = 0
  self.endNotClose = false
  self.playingId = -1
  self.mode = -1
  self.hasShowMesssage = false
  self.optionCount = 0
  self.optionCountDown = 0
  self.optionCountDownShow = 0
  self.timelinePause = false
  self.lastArrowObj = nil
  self.timelineDialogueEndHandler = handler(self, self.OnTimelineDialogueEnd)
  self:addEventListener("eGameEvent_TimelineDialogueEnd", self.timelineDialogueEndHandler)
  self.timelineDialoguePauseHandler = handler(self, self.OnTimelineDialoguePause)
  self:addEventListener("eGameEvent_TimelineDialoguePause", self.timelineDialoguePauseHandler)
  self:addEventListener("eGameEvent_DialogueDebug", handler(self, self.LogDebugInfo))
  self.m_review = {}
  self.subPnls = {}
  local pnlTrans = self.m_pnl.transform
  local childCount = pnlTrans.childCount
  for i = 1, childCount do
    local child = pnlTrans:GetChild(i - 1)
    local name = child.name
    if string.startsWith(name, "m_panelStyle") then
      self.subPnls[name] = child.gameObject
    end
  end
  self.expressionAnimation = self.m_imagePortrait:GetComponent(typeof(CS.CinExpressionAnimation))
  self.expressionAnimation.SpriteLoader = CS.RuntimeSpriteLoader.Instance
  self.m_panel_end:SetActive(false)
  self:SwitchMode(0)
  self:RefreshSpeedUp()
  self:SetDisableSpeedUp(true)
end

function Form_Dialogue:IsSpedUp()
  return self.speedUp
end

function Form_Dialogue:GetRootTransformType()
  return UIRootTransformType.Story
end

function Form_Dialogue:OnActive()
  self.super.OnActive(self)
  self.m_pnl_btn:SetActive(true)
  self:RefreshAutoStatus()
  self:RefreshBtn()
end

function Form_Dialogue:SetPause(pause)
  self.m_pasueByPreview = pause
end

function Form_Dialogue:OnInactive()
  self.super.OnInactive(self)
  self:StopSFX()
  self.hasShowMesssage = false
  self.message = nil
  self:RemoveEventListeners()
end

function Form_Dialogue:CloseForm()
  self.super.CloseForm(self)
  self.speedUp = false
  self:RefreshSpeedUp()
  self:SetDisableSpeedUp(true)
  self:SetAutoAndManual(false)
  self.m_btnReview:SetActive(false)
  self.m_btnSkip:SetActive(false)
  self.m_btnCannotSkip:SetActive(false)
  self.m_btnAuto:SetActive(false)
  self.m_btnManual:SetActive(false)
  self.m_pnl_btn:SetActive(true)
  self.expressionAnimation:ReleaseResource()
  self.m_imagePortrait_Image.sprite = nil
  self.m_imageFace_Image.sprite = nil
  self.m_imageMouth_Image.sprite = nil
end

function Form_Dialogue:OnTimelineEnd()
  self.m_review = {}
  self:CloseForm()
end

function Form_Dialogue:OnTimelineDialoguePause()
  self.timelinePause = true
  if self.lastArrowObj then
    self.lastArrowObj:SetActive(true)
  end
end

function Form_Dialogue:OnTimelineDialogueEnd()
  if self.lastArrowObj then
    self.lastArrowObj:SetActive(false)
  end
end

function Form_Dialogue:OnTextTypeWriterFinish()
  if self.lastArrowObj then
    self.lastArrowObj:SetActive(not self.canNotJump)
  end
end

function Form_Dialogue:RefreshBtn()
  self.m_btnReview:SetActive(not self.closeReview and #self.m_review > 0)
  self:RefreshAutoStatus()
end

function Form_Dialogue:SetOptions(message)
  self.optionFromTimeline = true
  self:SwitchMode(2)
  self.dialgueList = nil
  local list = {}
  for _, value in pairs(message) do
    table.insert(list, {
      Key = value.Key,
      Selectable = value.Selectable
    })
  end
  self:FillOption(list, false)
end

function Form_Dialogue:SetData(message)
  self.message = message
  if self.message == nil then
    self:SwitchMode(0)
    return
  end
  if self.m_pasueByPreview then
    StackSpecial:RemoveUIFromStack(UIDefines.ID_FORM_DIALOGUEREVIEW)
    CS.TimelineExtension.TimelineAssembler.SetPause(false)
    self:SetPause(false)
  end
  self.optionFromTimeline = false
  self:SwitchMode(1)
  self.m_textTypeWriter = nil
  self.m_iDialogueStyle = 0
  self.m_bShowContent = false
  self.m_fDuration = -1
  self.m_bAutoPlayForce = false
  self.endNotClose = false
  self.m_lockClickTime = 0
  self.m_fTime = 0
  for i = 1, self.m_iStyleMax do
    self["m_panelStyle" .. i]:SetActive(false)
  end
  self:RemoveEventListeners()
  self.fromTimeLine = false
  self.m_clipDuration = 0
  self.canNotJump = false
  self.timelinePause = false
  if message then
    if message.fromTimeLine then
      self.fromTimeLine = true
    end
    if not self.closeReview then
      self.m_btnReview:SetActive(self.fromTimeLine)
    end
    if message.bHideBtn then
      self.m_pnl_btn:SetActive(false)
    else
      self.m_pnl_btn:SetActive(true)
    end
    self.m_bAutoPlayForce = message.bAutoPlay
    self.m_clipDuration = message.duration or 0
    self.endNotClose = message.endNotClose
    self.canNotJump = message.canNotJump
    self:RefreshAutoStatus()
    self.dialgueList = {}
    local dialogueName
    for _, id in pairs(message.vCineVoiceExpressionID) do
      table.insert(self.dialgueList, {
        Type = DialogueType.Dialogue,
        Value = id
      })
      if dialogueName == nil then
        dialogueName = id
      end
    end
    if dialogueName == nil then
      dialogueName = "none"
    end
    self:ShowDialogue()
  end
end

function Form_Dialogue:SwitchMode(mode)
  if mode == self.mode then
    return
  end
  self.mode = mode
  self.m_panel_end:SetActive(false)
  if mode == 1 then
    self.m_pnl:SetActive(true)
    self.m_pnl_options:SetActive(false)
    self.m_img_option_bk:SetActive(false)
  elseif mode == 2 then
    self.m_pnl:SetActive(self.hasShowMesssage)
    self.m_pnl_options:SetActive(true)
    self.m_img_option_bk:SetActive(true)
  else
    self.m_pnl:SetActive(false)
    self.m_pnl_options:SetActive(false)
    self.m_img_option_bk:SetActive(false)
  end
end

function Form_Dialogue:FillOption(message, showCountDown)
  self.showCountDown = showCountDown
  if self.CountDown == nil then
    self.m_btn_option:SetActive(false)
    local PlotDialogueOptionsCountDown = CS.CData_GlobalSettings.GetInstance():GetValue_ByName("PlotDialogueOptionsCountDown")
    self.CountDown = tonumber(PlotDialogueOptionsCountDown.m_Value)
  end
  if showCountDown then
    self.optionCountDown = self.CountDown
  else
    self.optionCountDown = 0
  end
  local panelTrans = self.m_pnl_options_content.transform
  local childCount = panelTrans.childCount
  local optionCount = #message
  for i = 3, childCount do
    local child = panelTrans:GetChild(i - 1)
    child.gameObject:SetActive(false)
  end
  local needChildCount = optionCount + 2
  while needChildCount > panelTrans.childCount do
    local child = CS.UnityEngine.GameObject.Instantiate(self.m_btn_option, panelTrans)
    local index = panelTrans.childCount - 3
    local btn = child:GetComponent(T_Button)
    CS.UI.UILuaHelper.BindButtonClickManual(self, btn, handler1(self, self.OnClickOption, index))
  end
  local activeIndex = 0
  self.defaultSelectIndex = optionCount - 1
  local reviewData = {
    Type = 1,
    Options = {}
  }
  self:AddReviewData(reviewData)
  for i = 1, optionCount do
    local selectable = message[i].Selectable
    if selectable then
      activeIndex = activeIndex + 1
      if i - 1 < self.defaultSelectIndex then
        self.defaultSelectIndex = i - 1
      end
    end
    local child = panelTrans:GetChild(i + 1)
    child.gameObject:SetActive(selectable)
    local optionTrans = child:Find("m_pnl_option")
    local text = optionTrans:Find("txt_option"):GetComponent(T_TextMeshProUGUI)
    local key = message[i].Key
    table.insert(reviewData.Options, key)
    local v = CS.MultiLanguageManager.Instance:GetPlotText(key)
    if v == nil then
      v = key
    end
    text.text = v
  end
end

function Form_Dialogue:FillDialogueContent(tCineVoiceExpressionInfo, isLast)
  if self.fromTimeLine then
    self:AddReviewData({
      Type = 0,
      Message = tCineVoiceExpressionInfo.m_ID
    })
  end
  self.m_fTime = 0
  self.m_fDuration = tCineVoiceExpressionInfo.m_Duration
  if isLast and self.m_bAutoPlayForce then
    self.m_fDuration = self.m_clipDuration
    self.m_clipDuration = -1
  else
    self.m_clipDuration = self.m_clipDuration - self.m_fDuration
  end
  if isLast and 0 < self.m_clipDuration then
    self.m_fDuration = self.m_fDuration + self.m_clipDuration
    self.m_clipDuration = -1
  end
  local sName = CS.MultiLanguageManager.Instance:GetPlotText(tCineVoiceExpressionInfo.m_RoleName)
  local dialogueContent = CS.MultiLanguageManager.Instance:GetPlotText(tCineVoiceExpressionInfo.m_DialogueContent)
  self.m_iDialogueStyle = tCineVoiceExpressionInfo.m_DialogueStyle
  if self.m_iDialogueStyle == 0 then
    self.m_panel_end:SetActive(true)
    self.m_pnl:SetActive(false)
    self.m_txt_title_Text.text = dialogueContent
    return
  end
  self.m_panel_end:SetActive(false)
  self.m_pnl:SetActive(true)
  local pnlName = "m_panelStyle" .. self.m_iDialogueStyle
  for k, v in pairs(self.subPnls) do
    v:SetActive(k == pnlName)
  end
  local txtObj = self["m_textDialogue" .. tCineVoiceExpressionInfo.m_DialogueStyle]
  self.m_textTypeWriter = nil
  if txtObj then
    self.m_textTypeWriter = txtObj:GetComponent("CommonStoryText")
  end
  if self.m_textTypeWriter then
    self.m_textTypeWriter:ShowText(dialogueContent, self.message.textTimeSpace or 0, handler(self, self.OnTextTypeWriterFinish))
  end
  self.hasShowMesssage = true
  local objArrow = self["m_img_arror" .. tCineVoiceExpressionInfo.m_DialogueStyle]
  if objArrow then
    objArrow.gameObject:SetActive(false)
    self.lastArrowObj = objArrow.gameObject
  end
  if not string.IsNullOrEmpty(tCineVoiceExpressionInfo.m_Voice) then
    self:StopSFX()
    CS.UI.UILuaHelper.StartPlaySFX(tCineVoiceExpressionInfo.m_Voice, nil, handler(self, self.OnPlaySFXStart), handler(self, self.OnPlaySFXFinish))
  end
  self:SetExpression(tCineVoiceExpressionInfo)
  if string.isnullorempty(sName) or ConfigManager:CheckConfigFieldStrIsEmpty(sName) then
    self.m_imgTextNameBg:SetActive(false)
  else
    self.m_imgTextNameBg:SetActive(true)
    self.m_textName_Text.text = sName
  end
end

function Form_Dialogue:SetExpression(tCineVoiceExpressionInfo)
  local expression = tCineVoiceExpressionInfo.m_Expression
  local face = tCineVoiceExpressionInfo.m_Face
  local hasExpression = not string.IsNullOrEmpty(expression)
  local hasFace = not string.IsNullOrEmpty(face)
  if hasFace then
    local animationCfg = CS.CData_CineExpressionAnimation.GetInstance():GetValue_ByID(face)
    if not animationCfg:GetError() then
      local rectTrans = self.m_imageFace.transform
      local pos = rectTrans.anchoredPosition
      pos.x = animationCfg.m_EyeX
      pos.y = -animationCfg.m_EyeY
      rectTrans.anchoredPosition = pos
      rectTrans = self.m_imageMouth.transform
      pos.x = animationCfg.m_MouthX
      pos.y = -animationCfg.m_MouthY
      rectTrans.anchoredPosition = pos
      self.expressionAnimation:SetAnimation(animationCfg.m_Main, animationCfg.m_Atlas, animationCfg.m_HiddenMain == 1, animationCfg.m_EyeSpriteCount, animationCfg.m_EyeSpriteName, animationCfg.m_MouthSpriteCount, animationCfg.m_MouthSpriteName)
      self.m_imagePortrait:SetActive(true)
      return
    end
  end
  if hasExpression then
    local lastIndex, _ = string.rfind(expression, "/")
    local name = string.sub(expression, lastIndex + 1)
    local facePath
    if hasFace then
      facePath = "Atlas_" .. name .. "/" .. name .. "_" .. face
    end
    local roleFaceInfo = CS.CData_CineRoleFace.GetInstance():GetValue_ByID(name)
    if not roleFaceInfo:GetError() then
      if roleFaceInfo.m_Replace == 0 then
        local rectTrans = self.m_imageFace.transform
        local pos = rectTrans.anchoredPosition
        pos.x = roleFaceInfo.m_PosX
        pos.y = -roleFaceInfo.m_PosY
        rectTrans.anchoredPosition = pos
      elseif facePath ~= nil then
        expression = facePath
        facePath = nil
      end
    end
    self.expressionAnimation:SetStatic(expression, facePath)
    self.m_imagePortrait:SetActive(true)
    return
  end
  self.m_imagePortrait:SetActive(false)
end

function Form_Dialogue:SetExpressionSprite(expression, face)
  self.m_imagePortrait:SetActive(false)
  self.m_imageFace:SetActive(false)
  local isExpressionComplete = false
  local isFaceComplete = false
  
  local function onLoadExpression()
    isExpressionComplete = true
    if isExpressionComplete and isFaceComplete then
      self.m_imagePortrait:SetActive(true)
      self.m_imageFace:SetActive(true)
    end
  end
  
  local lastIndex, _ = string.rfind(expression, "/")
  local name = string.sub(expression, lastIndex + 1)
  
  local function onLoadFace()
    isFaceComplete = true
    self.m_imageFace_Image:SetNativeSize()
    local roleFaceInfo = CS.CData_CineRoleFace.GetInstance():GetValue_ByID(name)
    if not roleFaceInfo:GetError() then
      local rectTrans = self.m_imageFace.transform
      local pos = rectTrans.anchoredPosition
      pos.x = roleFaceInfo.m_PosX
      pos.y = -roleFaceInfo.m_PosY
      rectTrans.anchoredPosition = pos
    end
    if isExpressionComplete and isFaceComplete then
      self.m_imagePortrait:SetActive(true)
      self.m_imageFace:SetActive(true)
    end
  end
  
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_imageFace_Image, "Atlas_" .. name .. "/" .. name .. "_" .. face, onLoadFace, nil, true)
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_imagePortrait_Image, expression, onLoadExpression, nil, true)
end

function Form_Dialogue:StopSFX()
  if self.playingId > 0 then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingId)
    self.playingId = -1
  end
end

function Form_Dialogue:ShowDialogueFinish()
  self.message = nil
  if self.fromTimeLine then
    self.m_textTypeWriter = nil
    self.m_iDialogueStyle = 0
    self.m_bShowContent = false
    self.m_fDuration = -1
    self.m_bAutoPlayForce = false
    self.m_lockClickTime = 0
    self.m_fTime = 0
    if not self.endNotClose then
      self:SwitchMode(0)
      if self.lastArrowObj then
        self.lastArrowObj:SetActive(false)
      end
    end
  else
    self:CloseForm()
    self.expressionAnimation:ReleaseResource()
  end
  self:broadcastEvent("eGameEvent_DialogueShowEnd")
end

function Form_Dialogue:ShowDialogue()
  self:StopSFX()
  self.m_fDuration = -1
  if self.dialgueList == nil or #self.dialgueList == 0 then
    self:ShowDialogueFinish()
    return
  end
  self.m_lockClickTime = 0
  local first = self.dialgueList[1]
  if first.Type == DialogueType.Dialogue then
    table.remove(self.dialgueList, 1)
    local tCineVoiceExpressionInfo = CS.CData_CineVoiceExpression.GetInstance():GetValue_ByID(first.Value)
    if tCineVoiceExpressionInfo:GetError() then
      self:ShowDialogueFinish()
      return
    end
    if 0 < tCineVoiceExpressionInfo.m_Options.Length then
      table.insert(self.dialgueList, 1, {
        Type = DialogueType.OptionList,
        Value = tCineVoiceExpressionInfo.m_Options
      })
    end
    self:SwitchMode(1)
    self:FillDialogueContent(tCineVoiceExpressionInfo, #self.dialgueList == 0)
    self:broadcastEvent("eGameEvent_OnRolePlayDialogue", first.Value)
  elseif first.Type == DialogueType.OptionList then
    local list = {}
    local length = first.Value.Length
    for i = 1, length do
      local value = first.Value[i - 1]
      local optionInfo = CS.CData_CineDialogueOption.GetInstance():GetValue_ByID(value)
      table.insert(list, {
        Key = optionInfo.m_OptionContent,
        Selectable = true
      })
    end
    self:SwitchMode(2)
    self:FillOption(list, false)
  end
end

function Form_Dialogue:OnPlaySFXStart(playingId)
  if playingId == 0 then
    playingId = -1
  end
  self.playingId = playingId
end

function Form_Dialogue:OnPlaySFXFinish(playingId)
  if self.playingId == playingId then
    self.playingId = -1
    self.expressionAnimation:SetMouthAnimationDuration(0)
  end
end

function Form_Dialogue:SetSkip(bCanSkip)
  self.m_btnSkip:SetActive(bCanSkip)
  if self.message == nil then
    self.m_btnCannotSkip:SetActive(false)
  else
    self.m_btnCannotSkip:SetActive(not bCanSkip)
  end
end

function Form_Dialogue:SetReview(bCanReview)
  self.closeReview = bCanReview
end

function Form_Dialogue:SetAutoAndManual(bCanAutoAndManual)
  self.closeAutoAndManual = bCanAutoAndManual
  self:RefreshAutoStatus()
end

function Form_Dialogue:SetDisableSpeedUp(disable)
  self.sisableSpeedUp = disable
  if disable then
    self.speedUp = false
    CS.TimelineExtension.TimelineAssembler.SetGlobalSpeed(1)
    self:RefreshSpeedUp()
  end
  self.m_btnSpeed:SetActive(not disable)
end

function Form_Dialogue:PlayAnimation(animation, clipName)
  for _, v in pairs(animation) do
    if string.find(v.name, clipName) then
      animation:Play(v.name)
      if clipName == "in" then
        self.m_lockClickTime = 0.4
      end
      break
    end
  end
end

function Form_Dialogue:OnUpdate(dt)
  if self.m_pasueByPreview then
    return
  end
  if self.mode == 1 then
    if self.speedUp then
      dt = dt * 2
    end
    self:UpdateNormal(dt)
  end
end

function Form_Dialogue:LogDebugInfo()
  local info = string.format("m_fDuration = %s \n", self.m_fDuration)
  info = info .. string.format(" m_fTime = %s \n", self.m_fTime)
  info = info .. "StoryManager:getAutoStatus() = " .. tostring(StoryManager:getAutoStatus()) .. "\n"
  info = info .. string.format(" m_bAutoPlayForce = %s \n", self.m_bAutoPlayForce)
  info = info .. string.format(" playingId = %d \n", self.playingId)
  log.error(info)
end

function Form_Dialogue:UpdateNormal(dt)
  if self.message == nil then
    return
  end
  if self.m_fDuration > 0 then
    self.m_fTime = self.m_fTime + dt
    if self.m_bShowContent and not self.m_textTypeWriter:IsActive() then
      self.m_bShowContent = false
      self:PlayAnimation(self["m_Image_loop" .. self.m_iDialogueStyle]:GetComponent("Animation"), "loop")
    end
    local duration = self.m_fDuration
    if self.m_bAutoPlayForce then
      if duration <= self.m_fTime then
        self:ShowDialogue()
      end
    elseif StoryManager:getAutoStatus() then
      if duration <= self.m_fTime and 0 > self.playingId then
        if self.dialgueList == nil or #self.dialgueList == 0 then
          if self.fromTimeLine and self.timelinePause then
            self:ShowDialogue()
          else
            self:ShowDialogue()
          end
        else
          self:ShowDialogue()
        end
      end
      if duration <= self.m_fTime and 0 < self.playingId and self.m_fTime > 30 then
        self:StopSFX()
      end
    end
  end
end

function Form_Dialogue:RefreshAutoStatus()
  local bAuto = StoryManager:getAutoStatus()
  if not utils.isNull(self.m_btnAuto) then
    self.m_btnAuto:SetActive(bAuto and not self.closeAutoAndManual and self.message ~= nil)
  end
  if not utils.isNull(self.m_btnManual) then
    self.m_btnManual:SetActive(not bAuto and not self.closeAutoAndManual and self.message ~= nil)
  end
end

function Form_Dialogue:OnBtnContinueClicked()
  if self.message == nil or self.mode == 2 then
    return
  end
  if not self.m_pnl.activeInHierarchy then
    self:SwitchMode(0)
    return
  end
  if self.m_fTime < self.m_lockClickTime then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if self.m_textTypeWriter and self.m_textTypeWriter:IsActive() == true then
    self.m_textTypeWriter:FinishShowText()
  else
    self:ShowDialogue()
  end
end

function Form_Dialogue:OnBtnAutoClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StoryManager:setAutoStatus(false)
  self:RefreshAutoStatus()
end

function Form_Dialogue:OnBtnManualClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StoryManager:setAutoStatus(true)
  self:RefreshAutoStatus()
end

function Form_Dialogue:OnBtnSpeedClicked()
  self.speedUp = not self.speedUp
  if self.speedUp then
    CS.TimelineExtension.TimelineAssembler.SetGlobalSpeed(2)
  else
    CS.TimelineExtension.TimelineAssembler.SetGlobalSpeed(1)
  end
  self:RefreshSpeedUp()
end

function Form_Dialogue:RefreshSpeedUp()
  self.m_pnl_speed01:SetActive(not self.speedUp)
  self.m_pnl_speed02:SetActive(self.speedUp)
end

function Form_Dialogue:OnBtnSkipClicked()
  self:StopSFX()
  self:broadcastEvent("eGameEvent_DialogueShowEnd")
  self:broadcastEvent("eGameEvent_DialogueOptionSelect", 0)
  if CS.TimelineExtension.TimelineAssembler.Skip() then
    return
  end
  self:CloseForm()
  self.expressionAnimation:ReleaseResource()
  self:broadcastEvent("eGameEvent_DialogueSkip")
end

function Form_Dialogue:OnBtnCannotSkipClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
end

function Form_Dialogue:OnBtnHideClicked()
  self:SwitchMode(0)
end

function Form_Dialogue:AddReviewData(reviewData)
  table.insert(self.m_review, reviewData)
  if #self.m_review > 0 and not self.closeReview then
    self.m_btnReview:SetActive(true)
  end
end

function Form_Dialogue:OnBtnReviewClicked()
  if #self.m_review == 0 then
    return
  end
  CS.TimelineExtension.TimelineAssembler.SetPause(true)
  self:SetPause(true)
  StackSpecial:Push(UIDefines.ID_FORM_DIALOGUEREVIEW, self.m_review)
end

function Form_Dialogue:RemoveEventListeners()
  self.lastArrowObj = nil
  self:removeEventListener("eGameEvent_TimelineDialogueEnd", self.timelineDialogueEndHandler)
  self:removeEventListener("eGameEvent_TimelineDialoguePause", self.timelineDialoguePauseHandler)
end

function Form_Dialogue:OnClickOption(index)
  local last = self.m_review[#self.m_review]
  last.SelectedIndex = index + 1
  if self.optionFromTimeline then
    self.optionFromTimeline = false
    local panelTrans = self.m_pnl_options_content.transform
    local child = panelTrans:GetChild(index + 2)
    child:Find("m_pnl_option/bg_option_red").gameObject:SetActive(true)
    self:SwitchMode(0)
    self.expressionAnimation:ReleaseResource()
    self:broadcastEvent("eGameEvent_DialogueOptionSelect", index)
  elseif self.dialgueList and 0 < #self.dialgueList then
    local first = self.dialgueList[1]
    if first.Type == DialogueType.OptionList then
      table.remove(self.dialgueList, 1)
      local option = first.Value[index]
      local optionInfo = CS.CData_CineDialogueOption.GetInstance():GetValue_ByID(option)
      if optionInfo:GetError() then
        self:ShowDialogueFinish()
        return
      end
      local insertIndex = 1
      if 0 < optionInfo.m_DialogueList.Length then
        local length = optionInfo.m_DialogueList.Length
        for i = 1, length do
          local value = optionInfo.m_DialogueList[i - 1]
          table.insert(self.dialgueList, insertIndex, {
            Type = DialogueType.Dialogue,
            Value = value
          })
          insertIndex = insertIndex + 1
        end
      end
      if 0 < optionInfo.m_OptionList.Length then
        table.insert(self.dialgueList, insertIndex, {
          Type = DialogueType.OptionList,
          Value = optionInfo.m_OptionList
        })
      end
      self:ShowDialogue()
    end
  else
    self:ShowDialogueFinish()
  end
end

ActiveLuaUI("Form_Dialogue", Form_Dialogue)
return Form_Dialogue
