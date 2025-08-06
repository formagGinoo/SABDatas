local Form_GuildNoticeChange = class("Form_GuildNoticeChange", require("UI/UIFrames/Form_GuildNoticeChangeUI"))

function Form_GuildNoticeChange:SetInitParam(param)
end

function Form_GuildNoticeChange:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_InputField.onEndEdit:AddListener(function()
    self:CheckStrIsCorrect()
  end)
  self.m_inputfield_InputField.onValueChanged:AddListener(function()
    self:OnValueChangedRefresh()
  end)
end

function Form_GuildNoticeChange:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_openType = tParam.openType
  self.m_inputfield_InputField.text = ""
  self:AddEventListeners()
  local text = ConfigManager:GetCommonTextById(20063)
  local tipsText = ConfigManager:GetCommonTextById(20064)
  if self.m_openType == 1 then
    text = ConfigManager:GetCommonTextById(20061)
    tipsText = ConfigManager:GetCommonTextById(20062)
  end
  self.m_txt_guild_title_Text.text = text
  self.m_placeholder_txt_Text.text = tipsText
  local guildData = GuildManager:GetOwnerGuildDetail()
  if guildData then
    if self.m_openType == 1 then
      self.m_inputfield_InputField.text = guildData.sBulletin
    else
      self.m_inputfield_InputField.text = guildData.stBriefData.sRecruit
    end
  end
end

function Form_GuildNoticeChange:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildNoticeChange:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangeBulletin", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_Alliance_ChangeRecruit", handler(self, self.OnBtnCloseClicked))
end

function Form_GuildNoticeChange:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildNoticeChange:OnValueChangedRefresh()
  self:RefreshStrNum()
  self:CheckStrIsCorrect()
end

function Form_GuildNoticeChange:RefreshStrNum()
  local num = string.utf8len_WordCount(self.m_inputfield_InputField.text)
  self.m_txt_notice_max_Text.text = num .. "/50"
  if 50 < num then
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 142, 38, 38, 200)
  else
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 0, 0, 0, 200)
  end
end

function Form_GuildNoticeChange:CheckStrIsCorrect()
  local text = self.m_inputfield_InputField.text
  if text ~= "" then
    local str = string.GetTextualNormsGuildNotice(text)
    self.m_inputfield_InputField.text = str
  end
end

function Form_GuildNoticeChange:OnBtnsaveClicked()
  local text = self.m_inputfield_InputField.text
  local spacing = string.checkFirstCharIsSpacing(text)
  if spacing then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
    return
  end
  if self.m_openType == 1 then
    GuildManager:ReqChangeBulletin(text)
  else
    GuildManager:ReqChangeRecruit(text)
  end
end

function Form_GuildNoticeChange:OnBtnemptyClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildNoticeChange:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildNoticeChange:IsOpenGuassianBlur()
  return true
end

function Form_GuildNoticeChange:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDNOTICECHANGE)
end

function Form_GuildNoticeChange:OnDestroy()
  self.super.OnDestroy(self)
  self:RemoveAllEventListeners()
end

local fullscreen = true
ActiveLuaUI("Form_GuildNoticeChange", Form_GuildNoticeChange)
return Form_GuildNoticeChange
