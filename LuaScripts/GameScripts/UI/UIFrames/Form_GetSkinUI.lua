local Form_GetSkinUI = class("Form_GetSkinUI", require("UI/Common/UIBase"))

function Form_GetSkinUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GetSkinUI:GetID()
  return UIDefines.ID_FORM_GETSKIN
end

function Form_GetSkinUI:GetFramePrefabName()
  return "Form_GetSkin"
end

return Form_GetSkinUI
