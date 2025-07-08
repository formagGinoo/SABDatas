local Form_TowerChooseUI = class("Form_TowerChooseUI", require("UI/Common/UIBase"))

function Form_TowerChooseUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TowerChooseUI:GetID()
  return UIDefines.ID_FORM_TOWERCHOOSE
end

function Form_TowerChooseUI:GetFramePrefabName()
  return "Form_TowerChoose"
end

return Form_TowerChooseUI
