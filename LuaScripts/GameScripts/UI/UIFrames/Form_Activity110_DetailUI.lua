local Form_Activity110_DetailUI = class("Form_Activity110_DetailUI", require("UI/Common/UIBase"))

function Form_Activity110_DetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_DetailUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_DETAIL
end

function Form_Activity110_DetailUI:GetFramePrefabName()
  return "Form_Activity110_Detail"
end

return Form_Activity110_DetailUI
