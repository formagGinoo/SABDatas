local Form_PopupLevelResetUI = class("Form_PopupLevelResetUI", require("UI/Common/UIBase"))

function Form_PopupLevelResetUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupLevelResetUI:GetID()
  return UIDefines.ID_FORM_POPUPLEVELRESET
end

function Form_PopupLevelResetUI:GetFramePrefabName()
  return "Form_PopupLevelReset"
end

return Form_PopupLevelResetUI
