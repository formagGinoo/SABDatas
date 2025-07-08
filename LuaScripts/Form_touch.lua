local Form_touch = class("Form_touch", require("UI/UIFrames/Form_touchUI"))

function Form_touch:SetInitParam(param)
end

function Form_touch:AfterInit()
  self.super.AfterInit(self)
end

function Form_touch:OnActive()
  self.super.OnActive(self)
end

function Form_touch:OnInactive()
  self.super.OnInactive(self)
end

function Form_touch:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_touch", Form_touch)
return Form_touch
