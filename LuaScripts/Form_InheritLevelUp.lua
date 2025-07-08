local Form_InheritLevelUp = class("Form_InheritLevelUp", require("UI/UIFrames/Form_InheritLevelUpUI"))

function Form_InheritLevelUp:SetInitParam(param)
end

function Form_InheritLevelUp:AfterInit()
  self.super.AfterInit(self)
end

function Form_InheritLevelUp:OnActive()
  self.super.OnActive(self)
end

function Form_InheritLevelUp:OnInactive()
  self.super.OnInactive(self)
end

function Form_InheritLevelUp:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InheritLevelUp:IsOpenGuassianBlur()
  return true
end

function Form_InheritLevelUp:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  self:broadcastEvent("eGameEvent_Inherit_EvolveClose")
end

local fullscreen = true
ActiveLuaUI("Form_InheritLevelUp", Form_InheritLevelUp)
return Form_InheritLevelUp
