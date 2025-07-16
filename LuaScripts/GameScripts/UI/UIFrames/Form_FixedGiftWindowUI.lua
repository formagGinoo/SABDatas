local Form_FixedGiftWindowUI = class("Form_FixedGiftWindowUI", require("UI/Common/UIBase"))

function Form_FixedGiftWindowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_FixedGiftWindowUI:GetID()
  return UIDefines.ID_FORM_FIXEDGIFTWINDOW
end

function Form_FixedGiftWindowUI:GetFramePrefabName()
  return "Form_FixedGiftWindow"
end

return Form_FixedGiftWindowUI
