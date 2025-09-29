local Form_MallMonthCardUnlockTips = class("Form_MallMonthCardUnlockTips", require("UI/UIFrames/Form_MallMonthCardUnlockTipsUI"))

function Form_MallMonthCardUnlockTips:SetInitParam(param)
end

function Form_MallMonthCardUnlockTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_MallMonthCardUnlockTips:OnActive()
  self.super.OnActive(self)
end

function Form_MallMonthCardUnlockTips:OnInactive()
  self.super.OnInactive(self)
  self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
  MonthlyCardManager:GetAddCardId()
end

function Form_MallMonthCardUnlockTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MallMonthCardUnlockTips:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_MallMonthCardUnlockTips", Form_MallMonthCardUnlockTips)
return Form_MallMonthCardUnlockTips
