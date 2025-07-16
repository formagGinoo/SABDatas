local Form_TowerUI = class("Form_TowerUI", require("UI/Common/UIBase"))

function Form_TowerUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TowerUI:GetID()
  return UIDefines.ID_FORM_TOWER
end

function Form_TowerUI:GetFramePrefabName()
  return "Form_Tower"
end

return Form_TowerUI
