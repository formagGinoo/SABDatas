local Form_Activity112_Dialogueclue = class("Form_Activity112_Dialogueclue", require("UI/UIFrames/Form_Activity112_DialogueclueUI"))

function Form_Activity112_Dialogueclue:SetInitParam(param)
end

function Form_Activity112_Dialogueclue:AfterInit()
  Form_Activity112_Dialogueclue.super.AfterInit(self)
  self.sAniName1 = "Activity106_Dialogueclue_cutover_l"
  self.sAniName2 = "Activity106_Dialogueclue_cutover_r"
end

function Form_Activity112_Dialogueclue:OnActive()
  Form_Activity112_Dialogueclue.super.OnActive(self)
end

function Form_Activity112_Dialogueclue:OnInactive()
  Form_Activity112_Dialogueclue.super.OnInactive(self)
  self:broadcastEvent("eGameEvent_HeroAct_ClueClosed")
end

function Form_Activity112_Dialogueclue:OnDestroy()
  Form_Activity112_Dialogueclue.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity112_Dialogueclue", Form_Activity112_Dialogueclue)
return Form_Activity112_Dialogueclue
