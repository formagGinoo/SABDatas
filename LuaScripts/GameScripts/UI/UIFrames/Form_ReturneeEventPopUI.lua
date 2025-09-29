local Form_ReturneeEventPopUI = class("Form_ReturneeEventPopUI", require("UI/Common/UIBase"))

function Form_ReturneeEventPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ReturneeEventPopUI:GetID()
  return UIDefines.ID_FORM_RETURNEEEVENTPOP
end

function Form_ReturneeEventPopUI:GetFramePrefabName()
  return "Form_ReturneeEventPop"
end

return Form_ReturneeEventPopUI
