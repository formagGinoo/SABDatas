local Form_BattleBossWarning = class("Form_BattleBossWarning", require("UI/UIFrames/Form_BattleBossWarningUI"))

function Form_BattleBossWarning:SetInitParam(param)
end

function Form_BattleBossWarning:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattleBossWarning:OnActive()
  GlobalManagerIns:TriggerWwiseBGMState(105)
end

local fullscreen = true
ActiveLuaUI("Form_BattleBossWarning", Form_BattleBossWarning)
return Form_BattleBossWarning
