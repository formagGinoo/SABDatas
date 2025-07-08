local Form_GM = class("Form_GM", require("UI/UIFrames/Form_GMUI"))

function Form_GM:SetInitParam(param)
end

function Form_GM:AfterInit()
  self.super.AfterInit(self)
end

local fullscreen = true
ActiveLuaUI("Form_GM", Form_GM)
return Form_GM
