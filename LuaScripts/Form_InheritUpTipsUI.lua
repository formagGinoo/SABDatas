local Form_InheritUpTipsUI = class("Form_InheritUpTipsUI", require("UI/Common/UIBase"))

function Form_InheritUpTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritUpTipsUI:GetID()
  return UIDefines.ID_FORM_INHERITUPTIPS
end

function Form_InheritUpTipsUI:GetFramePrefabName()
  return "Form_InheritUpTips"
end

return Form_InheritUpTipsUI
