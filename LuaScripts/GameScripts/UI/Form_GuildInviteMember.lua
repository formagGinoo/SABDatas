local Form_GuildInviteMember = class("Form_GuildInviteMember", require("UI/UIFrames/Form_GuildInviteMemberUI"))

function Form_GuildInviteMember:SetInitParam(param)
end

function Form_GuildInviteMember:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildInviteMember:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
end

function Form_GuildInviteMember:OnInactive()
  self.super.OnInactive(self)
  self.m_inputfield_TMP_InputField.text = ""
  self:RemoveAllEventListeners()
end

function Form_GuildInviteMember:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Invite", handler(self, self.OnEventAllianceInvite))
end

function Form_GuildInviteMember:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildInviteMember:OnEventAllianceInvite()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10211)
end

function Form_GuildInviteMember:OnCommonbtnlightaClicked()
  local roleId = self.m_inputfield_TMP_InputField.text
  if roleId ~= "" then
    local spacing = string.checkFirstCharIsSpacing(roleId)
    if spacing then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
      return
    end
    GuildManager:ReqSearchRoleCS(roleId)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20022))
  end
end

function Form_GuildInviteMember:OnCommonbtnblackClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildInviteMember:OnBtnemptyClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildInviteMember:OnBtnCloseClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildInviteMember:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDINVITEMEMBER)
end

function Form_GuildInviteMember:IsOpenGuassianBlur()
  return true
end

function Form_GuildInviteMember:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildInviteMember", Form_GuildInviteMember)
return Form_GuildInviteMember
