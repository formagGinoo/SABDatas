local Form_MaterialsMainUI = class("Form_MaterialsMainUI", require("UI/Common/UIBase"))

function Form_MaterialsMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MaterialsMainUI:GetID()
  return UIDefines.ID_FORM_MATERIALSMAIN
end

function Form_MaterialsMainUI:GetFramePrefabName()
  return "Form_MaterialsMain"
end

return Form_MaterialsMainUI
