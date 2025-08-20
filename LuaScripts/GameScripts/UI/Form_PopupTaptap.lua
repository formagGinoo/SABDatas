local Form_PopupTaptap = class("Form_PopupTaptap", require("UI/UIFrames/Form_PopupTaptapUI"))

function Form_PopupTaptap:SetInitParam(param)
end

function Form_PopupTaptap:AfterInit()
  self.super.AfterInit(self)
end

function Form_PopupTaptap:OnActive()
  self.super.OnActive(self)
end

function Form_PopupTaptap:OnInactive()
  self.super.OnInactive(self)
end

function Form_PopupTaptap:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PopupTaptap:OnBtncancelClicked()
  self:CloseForm()
end

function Form_PopupTaptap:OnBtnyesClicked()
  self:CloseForm()
  QSDKManager:CallTapTap()
end

local fullscreen = true
ActiveLuaUI("Form_PopupTaptap", Form_PopupTaptap)
return Form_PopupTaptap
