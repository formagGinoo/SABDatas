local Form_BattlePassBenefits_Monthly = class("Form_BattlePassBenefits_Monthly", require("UI/UIFrames/Form_BattlePassBenefits_MonthlyUI"))

function Form_BattlePassBenefits_Monthly:SetInitParam(param)
end

function Form_BattlePassBenefits_Monthly:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattlePassBenefits_Monthly:OnActive()
  self.super.OnActive(self)
end

function Form_BattlePassBenefits_Monthly:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattlePassBenefits_Monthly:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_BattlePassBenefits_Monthly", Form_BattlePassBenefits_Monthly)
return Form_BattlePassBenefits_Monthly
