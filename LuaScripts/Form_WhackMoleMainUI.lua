local Form_WhackMoleMainUI = class("Form_WhackMoleMainUI", require("UI/Common/UIBase"))

function Form_WhackMoleMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleMainUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLEMAIN
end

function Form_WhackMoleMainUI:GetFramePrefabName()
  return "Form_WhackMoleMain"
end

return Form_WhackMoleMainUI
