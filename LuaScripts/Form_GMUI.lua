local Form_GMUI = class("Form_GMUI", require("UI/Common/UIBase"))

function Form_GMUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GMUI:GetID()
  return UIDefines.ID_FORM_GM
end

function Form_GMUI:GetFramePrefabName()
  return "Form_GM"
end

return Form_GMUI
