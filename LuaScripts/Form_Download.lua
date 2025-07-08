local Form_Download = class("Form_Download", require("UI/UIFrames/Form_DownloadUI"))

function Form_Download:SetInitParam(param)
end

function Form_Download:AfterInit()
  self.super.AfterInit(self)
end

local fullscreen = true
ActiveLuaUI("Form_Download", Form_Download)
return Form_Download
