local Form_HallActivityPvpUI = class("Form_HallActivityPvpUI", require("UI/Common/UIBase"))

function Form_HallActivityPvpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallActivityPvpUI:GetID()
  return UIDefines.ID_FORM_HALLACTIVITYPVP
end

function Form_HallActivityPvpUI:GetFramePrefabName()
  return "Form_HallActivityPvp"
end

return Form_HallActivityPvpUI
