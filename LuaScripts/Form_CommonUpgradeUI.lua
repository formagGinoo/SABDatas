local Form_CommonUpgradeUI = class("Form_CommonUpgradeUI", require("UI/Common/UIBase"))

function Form_CommonUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonUpgradeUI:GetID()
  return UIDefines.ID_FORM_COMMONUPGRADE
end

function Form_CommonUpgradeUI:GetFramePrefabName()
  return "Form_CommonUpgrade"
end

return Form_CommonUpgradeUI
