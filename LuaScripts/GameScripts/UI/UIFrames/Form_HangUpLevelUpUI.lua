local Form_HangUpLevelUpUI = class("Form_HangUpLevelUpUI", require("UI/Common/UIBase"))

function Form_HangUpLevelUpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HangUpLevelUpUI:GetID()
  return UIDefines.ID_FORM_HANGUPLEVELUP
end

function Form_HangUpLevelUpUI:GetFramePrefabName()
  return "Form_HangUpLevelUp"
end

return Form_HangUpLevelUpUI
