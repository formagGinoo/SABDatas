local Form_IosUnzip = class("Form_IosUnzip", require("UI/UIFrames/Form_IosUnzipUI"))

function Form_IosUnzip:SetInitParam(param)
end

function Form_IosUnzip:AfterInit()
  self.super.AfterInit(self)
end

local fullscreen = true
ActiveLuaUI("Form_IosUnzip", Form_IosUnzip)
return Form_IosUnzip
