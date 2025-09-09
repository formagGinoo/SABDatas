local Form_GuildConfirmationlist = class("Form_GuildConfirmationlist", require("UI/UIFrames/Form_GuildConfirmationlistUI"))

function Form_GuildConfirmationlist:SetInitParam(param)
end

function Form_GuildConfirmationlist:AfterInit()
  self.super.AfterInit(self)
  self.m_mulItemSureList = self:CreateCloneMulItemList(self.m_grid_namesure, self.m_item_namecopy, "Guild/UIGuildConfirmationItem")
  self.m_mulItemNotSureList = self:CreateCloneMulItemList(self.m_grid_namenotsure, self.m_item_namecopy, "Guild/UIGuildConfirmationItem")
end

function Form_GuildConfirmationlist:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_confirmList, self.unconfirmedList = GuildManager:GetMessageConfirmPlayer(tParam)
  self:RefreshUI()
end

function Form_GuildConfirmationlist:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildConfirmationlist:RefreshUI()
  self.m_txt_playersure_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100108), #self.m_confirmList)
  self.m_txt_playernotsure_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100109), #self.unconfirmedList)
  self.m_mulItemSureList:ShowItemList(self.m_confirmList)
  self.m_mulItemNotSureList:ShowItemList(self.unconfirmedList)
end

function Form_GuildConfirmationlist:IsOpenGuassianBlur()
  return true
end

function Form_GuildConfirmationlist:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildConfirmationlist", Form_GuildConfirmationlist)
return Form_GuildConfirmationlist
