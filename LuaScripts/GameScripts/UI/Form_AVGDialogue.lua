local Form_AVGDialogue = class("Form_AVGDialogue", require("UI/UIFrames/Form_AVGDialogueUI"))

function Form_AVGDialogue:GetRootTransformType()
  return UIRootTransformType.Story
end

function Form_AVGDialogue:SetInitParam(param)
end

function Form_AVGDialogue:IsAuto()
  return self.autoPlay and not self.isPause
end

function Form_AVGDialogue:AfterInit()
  self.super.AfterInit(self)
  self.speedUp = false
  self.autoPlay = false
  self.isPause = false
  self.currentColor = CS.UnityEngine.Color.white
  self.preColor = CS.UnityEngine.Color.white
  local bodyImage = self.m_role.transform:Find("body"):GetComponent(T_Image)
  self.bgMaterial = GameObject.Instantiate(bodyImage.material)
  self.m_bgContent_Image.material = self.bgMaterial
  self.bgAnimation = self.m_bg:GetComponent(T_Animation)
  self.m_role:SetActive(false)
  self.subPnls = {}
  self.bgMinOffset = self.m_bg.transform.offsetMin
  self.bgMaxOffset = self.m_bg.transform.offsetMax
  local pnlTrans = self.m_pnl.transform
  local childCount = pnlTrans.childCount
  for i = 1, childCount do
    local child = pnlTrans:GetChild(i - 1)
    local name = child.name
    if string.startsWith(name, "m_panelStyle") then
      self.subPnls[name] = child.gameObject
      local animation = child:GetComponent(T_Animation)
      if animation then
        animation.playAutomatically = false
      end
    end
  end
  self.rolePos = {}
  local root = self.m_rolePos.transform
  for i = 1, self.m_rolePos.transform.childCount do
    local child = root:GetChild(i - 1)
    local name = child.name
    self.rolePos[name] = child
  end
  self.bgScale = 1
  self.bgOffset = CS.UnityEngine.Vector2.zero
  self.m_btnSpeed:SetActive(true)
  self.m_btnReview:SetActive(true)
  self.m_btnSkip:SetActive(true)
  self.m_btnCannotSkip:SetActive(false)
  self:SwitchDialogueMode(0)
  self:UpdateAutoState()
  self:UpdateSpeedState()
end

function Form_AVGDialogue:OnActive()
  self.super.OnActive(self)
  if not self.playingInfo then
    self:Play(StoryManager:PopAVGInfo())
  end
end

function Form_AVGDialogue:Play(info)
  self.playingInfo = info
  if self.playingInfo ~= nil then
    local class = require("Module/AVG/AVGContext")
    self.m_context = class.new()
    self.m_context:Init(info.Name, self)
    local disableSkip = self.m_context.data.DisableSkip
    local disableSpeedUp = self.m_context.data.DisableSpeedUp
    self.m_btnSpeed:SetActive(not disableSpeedUp)
    self.m_btnSkip:SetActive(not disableSkip)
    self.m_btnCannotSkip:SetActive(disableSkip)
  end
end

function Form_AVGDialogue:OnInactive()
  self.super.OnInactive(self)
end

function Form_AVGDialogue:OnUpdate(dt)
  if self.m_context then
    if self.speedUp then
      dt = dt * 2
    end
    self.m_context:Update(dt)
    if self.m_context.Stage == AVGStageType.Finished then
      self:OnPlayFinished()
    end
  end
end

function Form_AVGDialogue:OnDestroy()
  if self.m_context then
    self.m_context:Destroy()
    self.m_context = nil
  end
  self.super.OnDestroy(self)
end

function Form_AVGDialogue:OnPlayFinished()
  if self.m_context then
    self.m_context:Destroy()
    self.m_context = nil
  end
  self.dialogueStyle = nil
  self.dialogueRoleName = nil
  self.currentColor = CS.UnityEngine.Color.white
  self.preColor = CS.UnityEngine.Color.white
  self.bgMaterial:SetColor("_Color", self.currentColor)
  local info = self.playingInfo
  self.playingInfo = nil
  if info.OnFinished then
    info.OnFinished()
  end
  info = StoryManager:PopAVGInfo()
  if info then
    self:Play(info)
  else
    StackSpecial:DestroyUI(UIDefines.ID_FORM_AVGDIALOGUE)
  end
end

function Form_AVGDialogue:GetRolePos(name)
  local node = self.rolePos[name]
  if node then
    return node.anchoredPosition
  end
  log.error("Form_AVGDialogue 无效的角色位置: " .. name)
  return CS.UnityEngine.Vector2.zero
end

function Form_AVGDialogue:SetBG(sprite)
  self.m_bgContent_Image.preserveAspect = true
  self.m_bgContent_Image.sprite = sprite
  self.m_bgContent_Image.enabled = sprite ~= nil
end

function Form_AVGDialogue:SetBGColor(color)
  self.preColor = self.currentColor
  self.currentColor = color
end

function Form_AVGDialogue:LerpBGColor(p)
  local color = CS.UnityEngine.Color.Lerp(self.preColor, self.currentColor, p)
  self.bgMaterial:SetColor("_Color", color)
end

function Form_AVGDialogue:PlayBGAnimation(name)
  if self.bgAnimation then
    CS.UI.UILuaHelper.PlayAnimationByName(self.bgAnimation, name, 1, 0)
    return CS.UI.UILuaHelper.GetAnimationPlayingTime(self.bgAnimation, name)
  end
  return 0
end

function Form_AVGDialogue:SetBGScale(scale)
  self.bgScale = scale
  self.m_bg.transform.localScale = CS.UnityEngine.Vector3(scale, scale, 1)
end

function Form_AVGDialogue:GetBGScale()
  return self.bgScale
end

function Form_AVGDialogue:SetBGOffset(v)
  self.bgOffset = v
  local rectTrans = self.m_bg.transform
  local min = rectTrans.offsetMin
  min.x = min.x + v.x
  min.y = min.y + v.y
  rectTrans.offsetMin = min
  local max = rectTrans.offsetMax
  max.x = max.x + v.x
  max.y = max.y + v.y
  rectTrans.offsetMax = max
end

function Form_AVGDialogue:GetBGOffset()
  return self.bgOffset
end

function Form_AVGDialogue:SetCurtainLayer(type)
  local back
  self.m_curtain.transform:SetAsLastSibling()
  if type == 0 then
    back = self.m_bg.transform
  elseif type == 1 then
    back = self.m_roles.transform
  elseif type == 2 then
    back = self.m_dialogue.transform
  end
  if back then
    local index = back:GetSiblingIndex()
    self.m_curtain.transform:SetSiblingIndex(index + 1)
  else
    self.m_curtain.transform:SetAsLastSibling()
  end
end

function Form_AVGDialogue:SetCurtainColor(color)
  self.m_curtain_Image.color = color
end

function Form_AVGDialogue:SetDialogueContent(style, roleName)
  self:SwitchDialogueMode(1)
  local pnlName = "m_panelStyle" .. style
  for k, v in pairs(self.subPnls) do
    local active = k == pnlName
    v:SetActive(active)
    if active and (self.dialogueStyle ~= style or self.dialogueRoleName ~= roleName) then
      CS.UI.UILuaHelper.PlayAnimationByName(v, nil, 1, 0)
    end
  end
  self.dialogueStyle = style
  self.dialogueRoleName = roleName
  local textTypeWriter
  local txtObj = self["m_textDialogue" .. style]
  if txtObj then
    textTypeWriter = txtObj:GetComponent("CommonStoryText")
  end
  local objArrow = self["m_img_arror" .. style]
  if objArrow then
    objArrow.gameObject:SetActive(false)
    self.lastArrowObj = objArrow.gameObject
  end
  if string.isnullorempty(roleName) then
    self.m_imgTextNameBg:SetActive(false)
  else
    self.m_imgTextNameBg:SetActive(true)
    self.m_textName_Text.text = roleName
  end
  return textTypeWriter
end

function Form_AVGDialogue:ShowArrow()
  if self.lastArrowObj then
    self.lastArrowObj:SetActive(true)
  end
end

function Form_AVGDialogue:SetOptions(message, showDialogue, obj, onClickOption)
  if showDialogue then
    self:SwitchDialogueMode(3)
  else
    self:SwitchDialogueMode(2)
  end
  local panelTrans = self.m_pnl_options_content.transform
  local childCount = panelTrans.childCount
  local optionCount = #message
  for i = 1, childCount do
    local child = panelTrans:GetChild(i - 1)
    child.gameObject:SetActive(false)
    local btn = child:GetComponent(T_Button)
    btn.onClick:RemoveAllListeners()
  end
  while optionCount > panelTrans.childCount do
    CS.UnityEngine.GameObject.Instantiate(self.m_btn_option, panelTrans)
  end
  self.defaultSelectIndex = 1
  for i = 1, optionCount do
    local child = panelTrans:GetChild(i - 1)
    local optionTrans = child:Find("m_pnl_option")
    local text = optionTrans:Find("txt_option"):GetComponent(T_TextMeshProUGUI)
    text.text = message[i]
    child.gameObject:SetActive(true)
    local index = i
    local btn = child:GetComponent(T_Button)
    CS.UI.UILuaHelper.BindButtonClickManual(self, btn, handler1(obj, onClickOption, index))
  end
end

function Form_AVGDialogue:SwitchDialogueMode(mode)
  if self.mode == mode then
    return
  end
  self.mode = mode
  if mode == 0 then
    self.m_dialogue:SetActive(false)
  elseif mode == 1 then
    self.m_dialogue:SetActive(true)
    self.m_pnl:SetActive(true)
    self.m_options:SetActive(false)
  elseif mode == 2 then
    self.m_dialogue:SetActive(true)
    self.m_pnl:SetActive(false)
    self.m_options:SetActive(true)
  elseif mode == 3 then
    self.m_dialogue:SetActive(true)
    self.m_pnl:SetActive(true)
    self.m_options:SetActive(true)
  end
end

function Form_AVGDialogue:SetPause(pause)
  self.isPause = pause
end

function Form_AVGDialogue:OnBtnContinueClicked()
  if self.m_context then
    self.m_context:OnClickContinue()
  end
end

function Form_AVGDialogue:OnBtnReviewClicked()
  if self.m_context then
    local reviewData = self.m_context:GetReviewList()
    self:SetPause(true)
    StackSpecial:Push(UIDefines.ID_FORM_DIALOGUEREVIEW, {
      data = reviewData,
      onClose = function()
        self:SetPause(false)
      end
    })
  end
end

function Form_AVGDialogue:OnBtnAutoClicked()
  self.autoPlay = false
  self:UpdateAutoState()
end

function Form_AVGDialogue:OnBtnManualClicked()
  self.autoPlay = true
  self:UpdateAutoState()
end

function Form_AVGDialogue:OnBtnSpeedClicked()
  self.speedUp = not self.speedUp
  self:UpdateSpeedState()
end

function Form_AVGDialogue:OnBtnSkipClicked()
  if self.m_context then
    self.m_context:Finish()
  end
end

function Form_AVGDialogue:UpdateAutoState()
  self.m_btnAuto:SetActive(self.autoPlay)
  self.m_btnManual:SetActive(not self.autoPlay)
end

function Form_AVGDialogue:UpdateSpeedState()
  self.m_pnl_speed01:SetActive(not self.speedUp)
  self.m_pnl_speed02:SetActive(self.speedUp)
end

ActiveLuaUI("Form_AVGDialogue", Form_AVGDialogue)
return Form_AVGDialogue
