local Form_GuideSkipPop = class("Form_GuideSkipPop", require("UI/UIFrames/Form_GuideSkipPopUI"))

function Form_GuideSkipPop:SetInitParam(param)
end

function Form_GuideSkipPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuideSkipPop:OnActive()
  self.super.OnActive(self)
end

function Form_GuideSkipPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuideSkipPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuideSkipPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_GuideSkipPop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_GuideSkipPop:OnBtnsureClicked()
  GuideManager:SkipCurrentGuide()
  CS.UI.UILuaHelper.SetDayCount("GuideSkip", 1)
  self:CloseForm()
end

function Form_GuideSkipPop:OnBtncancelClicked()
  self:CloseForm()
end

function Form_GuideSkipPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuideSkipPop", Form_GuideSkipPop)
return Form_GuideSkipPop
