local Form_ActivityMinigame108TaskUI = class("Form_ActivityMinigame108TaskUI", require("UI/Common/UIBase"))

function Form_ActivityMinigame108TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMinigame108TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMINIGAME108TASK
end

function Form_ActivityMinigame108TaskUI:GetFramePrefabName()
  return "Form_ActivityMinigame108Task"
end

return Form_ActivityMinigame108TaskUI
