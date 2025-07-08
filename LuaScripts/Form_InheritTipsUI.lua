local Form_InheritTipsUI = class("Form_InheritTipsUI", require("UI/Common/UIBase"))

function Form_InheritTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritTipsUI:GetID()
  return UIDefines.ID_FORM_INHERITTIPS
end

function Form_InheritTipsUI:GetFramePrefabName()
  return "Form_InheritTips"
end

return Form_InheritTipsUI
