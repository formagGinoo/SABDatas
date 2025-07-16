local Form_GachaShowSSR = class("Form_GachaShowSSR", require("UI/UIFrames/Form_GachaShowSSRUI"))

function Form_GachaShowSSR:SetInitParam(param)
end

function Form_GachaShowSSR:AfterInit()
  self.super.AfterInit(self)
end

function Form_GachaShowSSR:OnActive()
  self.super.OnActive(self)
end

function Form_GachaShowSSR:OnInactive()
  self.super.OnInactive(self)
end

function Form_GachaShowSSR:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GachaShowSSR", Form_GachaShowSSR)
return Form_GachaShowSSR
