local Form_Screen_ClickUI = class("Form_Screen_ClickUI", require("UI/Common/UIBase"))

function Form_Screen_ClickUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Screen_ClickUI:GetID()
  return UIDefines.ID_FORM_SCREEN_CLICK
end

function Form_Screen_ClickUI:GetFramePrefabName()
  return "Form_Screen_Click"
end

return Form_Screen_ClickUI
