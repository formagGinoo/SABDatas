local Form_PopupReceiveUI = class("Form_PopupReceiveUI", require("UI/Common/UIBase"))

function Form_PopupReceiveUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupReceiveUI:GetID()
  return UIDefines.ID_FORM_POPUPRECEIVE
end

function Form_PopupReceiveUI:GetFramePrefabName()
  return "Form_PopupReceive"
end

return Form_PopupReceiveUI
