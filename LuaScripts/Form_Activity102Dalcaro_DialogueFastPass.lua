local Form_Activity102Dalcaro_DialogueFastPass = class("Form_Activity102Dalcaro_DialogueFastPass", require("UI/UIFrames/Form_Activity102Dalcaro_DialogueFastPassUI"))

function Form_Activity102Dalcaro_DialogueFastPass:SetInitParam(param)
end

function Form_Activity102Dalcaro_DialogueFastPass:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102Dalcaro_DialogueFastPass:OnActive()
  self.super.OnActive(self)
end

function Form_Activity102Dalcaro_DialogueFastPass:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_DialogueFastPass:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_DialogueFastPass:OnBtncheckClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_DialogueFastPass", Form_Activity102Dalcaro_DialogueFastPass)
return Form_Activity102Dalcaro_DialogueFastPass
