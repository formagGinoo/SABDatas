local Form_HangUpUI = class("Form_HangUpUI", require("UI/Common/UIBase"))

function Form_HangUpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HangUpUI:GetID()
  return UIDefines.ID_FORM_HANGUP
end

function Form_HangUpUI:GetFramePrefabName()
  return "Form_HangUp"
end

return Form_HangUpUI
