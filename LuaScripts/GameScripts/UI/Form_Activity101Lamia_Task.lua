local Form_Activity101Lamia_Task = class("Form_Activity101Lamia_Task", require("UI/UIFrames/Form_Activity101Lamia_TaskUI"))

function Form_Activity101Lamia_Task:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(103)
end

ActiveLuaUI("Form_Activity101Lamia_Task", Form_Activity101Lamia_Task)
return Form_Activity101Lamia_Task
