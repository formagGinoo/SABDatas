local Form_PlayerAccountDelPop = class("Form_PlayerAccountDelPop", require("UI/UIFrames/Form_PlayerAccountDelPopUI"))

function Form_PlayerAccountDelPop:SetInitParam(param)
end

function Form_PlayerAccountDelPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerAccountDelPop:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_PlayerAccountDelPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PlayerAccountDelPop:RefreshUI()
  self.m_textContent_Text.text = UILuaHelper.GetCommonText(100100)
end

function Form_PlayerAccountDelPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PlayerAccountDelPop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PlayerAccountDelPop:OnBtnnoClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERPOP)
end

function Form_PlayerAccountDelPop:OnBtnyesClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERDELINFORPOP)
end

function Form_PlayerAccountDelPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PlayerAccountDelPop", Form_PlayerAccountDelPop)
return Form_PlayerAccountDelPop
