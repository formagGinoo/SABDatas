local Form_BattlePass_Monthly = class("Form_BattlePass_Monthly", require("UI/UIFrames/Form_BattlePass_MonthlyUI"))

function Form_BattlePass_Monthly:SetInitParam(param)
end

function Form_BattlePass_Monthly:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattlePass_Monthly:OnActive()
  self.super.OnActive(self)
end

function Form_BattlePass_Monthly:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattlePass_Monthly:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_BattlePass_Monthly", Form_BattlePass_Monthly)
return Form_BattlePass_Monthly
