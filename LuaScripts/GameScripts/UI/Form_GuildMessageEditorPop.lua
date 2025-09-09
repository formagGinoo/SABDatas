local Form_GuildMessageEditorPop = class("Form_GuildMessageEditorPop", require("UI/UIFrames/Form_GuildMessageEditorPopUI"))
local __GuildMessageCount = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildMessageCount") or 0)

function Form_GuildMessageEditorPop:SetInitParam(param)
end

function Form_GuildMessageEditorPop:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_InputField.onValueChanged:AddListener(function()
    self:OnValueChangedRefresh()
  end)
  self.m_inputfield_InputField.characterLimit = __GuildMessageCount
  self.m_characterLimit = __GuildMessageCount
end

function Form_GuildMessageEditorPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_message = GuildManager:GetAllianceMessageById(tParam)
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildMessageEditorPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildMessageEditorPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildMessageEditorPop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_MessageNoticeChange", handler(self, self.OnBtnCloseClicked))
end

function Form_GuildMessageEditorPop:RefreshUI()
  if self.m_message then
    self.m_inputfield_InputField.text = self.m_message.sContent
  else
    self.m_inputfield_InputField.text = ""
  end
end

function Form_GuildMessageEditorPop:OnValueChangedRefresh()
  self:RefreshStrNum()
  self:CheckStrIsCorrect()
end

function Form_GuildMessageEditorPop:CheckStrIsCorrect()
  local text = self.m_inputfield_InputField.text
  if text ~= "" then
    local str = string.GetTextualNormsGuildNotice(text)
    self.m_inputfield_InputField.text = str
  end
end

function Form_GuildMessageEditorPop:RefreshStrNum()
  local num = string.utf8len_WordCount(self.m_inputfield_InputField.text)
  self.m_txt_notice_max_Text.text = num .. "/" .. self.m_characterLimit
  if num > self.m_characterLimit then
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 142, 38, 38, 200)
  else
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 0, 0, 0, 200)
  end
end

function Form_GuildMessageEditorPop:OnBtnsaveClicked()
  local text = self.m_inputfield_InputField.text
  if text == "" then
    return
  end
  local flag = GuildManager:CheckOwnHaveMessagePermission()
  if not flag then
    return
  end
  local iAllianceId = RoleManager:GetRoleAllianceInfo()
  if not iAllianceId or iAllianceId == "0" then
    return
  end
  if not self.m_message or not self.m_message.iNoticeID then
    return
  end
  GuildManager:ReqAllianceMessageNoticeEditCS(iAllianceId, text, self.m_message.iNoticeID)
end

function Form_GuildMessageEditorPop:OnBtnquitClicked()
  self:CloseForm()
end

function Form_GuildMessageEditorPop:IsOpenGuassianBlur()
  return true
end

function Form_GuildMessageEditorPop:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_GuildMessageEditorPop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildMessageEditorPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildMessageEditorPop", Form_GuildMessageEditorPop)
return Form_GuildMessageEditorPop
