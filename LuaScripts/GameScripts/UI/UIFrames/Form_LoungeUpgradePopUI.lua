local Form_LoungeUpgradePopUI = class("Form_LoungeUpgradePopUI", require("UI/Common/UIBase"))

function Form_LoungeUpgradePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeUpgradePopUI:GetID()
  return UIDefines.ID_FORM_LOUNGEUPGRADEPOP
end

function Form_LoungeUpgradePopUI:GetFramePrefabName()
  return "Form_LoungeUpgradePop"
end

return Form_LoungeUpgradePopUI
