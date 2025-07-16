local Form_MaterialsPopUI = class("Form_MaterialsPopUI", require("UI/Common/UIBase"))

function Form_MaterialsPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MaterialsPopUI:GetID()
  return UIDefines.ID_FORM_MATERIALSPOP
end

function Form_MaterialsPopUI:GetFramePrefabName()
  return "Form_MaterialsPop"
end

return Form_MaterialsPopUI
