local Form_BattleFlyText_TMP2 = class("Form_BattleFlyText_TMP2", require("UI/UIFrames/Form_BattleFlyText_TMP2UI"))

function Form_BattleFlyText_TMP2:SetInitParam(param)
end

function Form_BattleFlyText_TMP2:AfterInit()
  self.super.AfterInit(self)
end

local fullscreen = true
ActiveLuaUI("Form_BattleFlyText_TMP2", Form_BattleFlyText_TMP2)
return Form_BattleFlyText_TMP2
