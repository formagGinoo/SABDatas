local Form_Activity101Lamia_DialogueFastPass = class("Form_Activity101Lamia_DialogueFastPass", require("UI/UIFrames/Form_Activity101Lamia_DialogueFastPassUI"))

function Form_Activity101Lamia_DialogueFastPass:SetInitParam(param)
end

function Form_Activity101Lamia_DialogueFastPass:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_DialogueFastPass:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(15)
end

function Form_Activity101Lamia_DialogueFastPass:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_DialogueFastPass:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_DialogueFastPass:OnBtncheckClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_DialogueFastPass", Form_Activity101Lamia_DialogueFastPass)
return Form_Activity101Lamia_DialogueFastPass
