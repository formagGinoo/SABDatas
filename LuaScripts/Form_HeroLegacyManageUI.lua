local Form_HeroLegacyManageUI = class("Form_HeroLegacyManageUI", require("UI/Common/UIBase"))

function Form_HeroLegacyManageUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyManageUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYMANAGE
end

function Form_HeroLegacyManageUI:GetFramePrefabName()
  return "Form_HeroLegacyManage"
end

return Form_HeroLegacyManageUI
