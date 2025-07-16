local Form_AttractLevelUpUI = class("Form_AttractLevelUpUI", require("UI/Common/UIBase"))

function Form_AttractLevelUpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractLevelUpUI:GetID()
  return UIDefines.ID_FORM_ATTRACTLEVELUP
end

function Form_AttractLevelUpUI:GetFramePrefabName()
  return "Form_AttractLevelUp"
end

return Form_AttractLevelUpUI
