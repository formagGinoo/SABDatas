local Form_LoungeUI = class("Form_LoungeUI", require("UI/Common/UIBase"))

function Form_LoungeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeUI:GetID()
  return UIDefines.ID_FORM_LOUNGE
end

function Form_LoungeUI:GetFramePrefabName()
  return "Form_Lounge"
end

return Form_LoungeUI
