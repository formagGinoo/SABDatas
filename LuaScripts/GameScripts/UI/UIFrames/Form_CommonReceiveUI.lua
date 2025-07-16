local Form_CommonReceiveUI = class("Form_CommonReceiveUI", require("UI/Common/UIBase"))

function Form_CommonReceiveUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonReceiveUI:GetID()
  return UIDefines.ID_FORM_COMMONRECEIVE
end

function Form_CommonReceiveUI:GetFramePrefabName()
  return "Form_CommonReceive"
end

return Form_CommonReceiveUI
