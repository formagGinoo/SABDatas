local Form_GuildCalmDown = class("Form_GuildCalmDown", require("UI/UIFrames/Form_GuildCalmDownUI"))

function Form_GuildCalmDown:SetInitParam(param)
end

function Form_GuildCalmDown:AfterInit()
  self.super.AfterInit(self)
  self.m_guildName = nil
  self.m_transformTargetUid = nil
  self.m_transformTargetZoneId = nil
end

function Form_GuildCalmDown:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_GuildCalmDown:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildCalmDown:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildCalmDown:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_memberInfo = tParam
  local briefData = GuildManager:GetOwnerGuildDetail()
  self.m_guildName = tostring(briefData.stBriefData.sName)
  self.m_transformTargetZoneId = self.m_memberInfo.stRoleId.iZoneId
  self.m_transformTargetUid = self.m_memberInfo.stRoleId.iUid
  self.m_csui.m_param = nil
end

function Form_GuildCalmDown:FreshUI()
  self.m_txt_guildname_Text.text = self.m_guildName
  self.m_txt_clamdown_Text.text = ConfigManager:GetCommonTextById(20211)
end

function Form_GuildCalmDown:OnCommonbtnlightaClicked()
  if self.m_transformTargetUid and self.m_transformTargetZoneId then
    GuildManager:ReqAllianceTransferCS(self.m_transformTargetUid, self.m_transformTargetZoneId)
  else
    log.error("Transform Guild CalmDown uid or zoneId error")
  end
  self:CloseForm()
end

function Form_GuildCalmDown:OnCommonbtnblackClicked()
  self:CloseForm()
end

function Form_GuildCalmDown:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildCalmDown", Form_GuildCalmDown)
return Form_GuildCalmDown
