local Form_PopupLevelUI = class("Form_PopupLevelUI", require("UI/Common/UIBase"))

function Form_PopupLevelUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupLevelUI:GetID()
  return UIDefines.ID_FORM_POPUPLEVEL
end

function Form_PopupLevelUI:GetFramePrefabName()
  return "Form_PopupLevel"
end

return Form_PopupLevelUI
