local Form_ActivityMinigame108_PopUI = class("Form_ActivityMinigame108_PopUI", require("UI/Common/UIBase"))

function Form_ActivityMinigame108_PopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMinigame108_PopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMINIGAME108_POP
end

function Form_ActivityMinigame108_PopUI:GetFramePrefabName()
  return "Form_ActivityMinigame108_Pop"
end

return Form_ActivityMinigame108_PopUI
