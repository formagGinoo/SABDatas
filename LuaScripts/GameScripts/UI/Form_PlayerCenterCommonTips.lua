local Form_PlayerCenterCommonTips = class("Form_PlayerCenterCommonTips", require("UI/UIFrames/Form_PlayerCenterCommonTipsUI"))

function Form_PlayerCenterCommonTips:SetInitParam(param)
end

function Form_PlayerCenterCommonTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerCenterCommonTips:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_PlayerCenterCommonTips:RefreshUI()
  self.m_txt_word_Text.text = UILuaHelper.GetCommonText(100102)
end

function Form_PlayerCenterCommonTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_PlayerCenterCommonTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerCenterCommonTips:OnBtnyesClicked()
  self:CloseForm()
  CS.ApplicationManager.Instance:RestartGame()
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCenterCommonTips", Form_PlayerCenterCommonTips)
return Form_PlayerCenterCommonTips
