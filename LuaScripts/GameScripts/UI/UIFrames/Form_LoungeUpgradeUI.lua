local Form_LoungeUpgradeUI = class("Form_LoungeUpgradeUI", require("UI/Common/UIBase"))

function Form_LoungeUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeUpgradeUI:GetID()
  return UIDefines.ID_FORM_LOUNGEUPGRADE
end

function Form_LoungeUpgradeUI:GetFramePrefabName()
  return "Form_LoungeUpgrade"
end

return Form_LoungeUpgradeUI
