local Form_BattleFinalBlow = class("Form_BattleFinalBlow", require("UI/UIFrames/Form_BattleFinalBlowUI"))

function Form_BattleFinalBlow:SetInitParam(param)
end

function Form_BattleFinalBlow:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattleFinalBlow:OnActive()
  self.super.OnActive(self)
end

function Form_BattleFinalBlow:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleFinalBlow:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_BattleFinalBlow", Form_BattleFinalBlow)
return Form_BattleFinalBlow
