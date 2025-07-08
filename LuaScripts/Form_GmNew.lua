local Form_GmNew = class("Form_GmNew", require("UI/UIFrames/Form_GmNewUI"))

function Form_GmNew:SetInitParam(param)
end

function Form_GmNew:AfterInit()
  self.super.AfterInit(self)
end

function Form_GmNew:OnActive()
  self.super.OnActive(self)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_column)
end

function Form_GmNew:OnInactive()
  self.super.OnInactive(self)
end

function Form_GmNew:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GmNew", Form_GmNew)
return Form_GmNew
