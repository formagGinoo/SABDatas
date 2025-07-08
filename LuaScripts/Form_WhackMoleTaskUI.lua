local Form_WhackMoleTaskUI = class("Form_WhackMoleTaskUI", require("UI/Common/UIBase"))

function Form_WhackMoleTaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleTaskUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLETASK
end

function Form_WhackMoleTaskUI:GetFramePrefabName()
  return "Form_WhackMoleTask"
end

return Form_WhackMoleTaskUI
