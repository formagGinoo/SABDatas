local Form_HallActivityUI = class("Form_HallActivityUI", require("UI/Common/UIBase"))

function Form_HallActivityUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallActivityUI:GetID()
  return UIDefines.ID_FORM_HALLACTIVITY
end

function Form_HallActivityUI:GetFramePrefabName()
  return "Form_HallActivity"
end

return Form_HallActivityUI
