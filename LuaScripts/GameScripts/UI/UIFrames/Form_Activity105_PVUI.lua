local Form_Activity105_PVUI = class("Form_Activity105_PVUI", require("UI/Common/UIBase"))

function Form_Activity105_PVUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105_PVUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105_PV
end

function Form_Activity105_PVUI:GetFramePrefabName()
  return "Form_Activity105_PV"
end

return Form_Activity105_PVUI
