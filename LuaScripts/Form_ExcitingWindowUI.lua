local Form_ExcitingWindowUI = class("Form_ExcitingWindowUI", require("UI/Common/UIBase"))

function Form_ExcitingWindowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ExcitingWindowUI:GetID()
  return UIDefines.ID_FORM_EXCITINGWINDOW
end

function Form_ExcitingWindowUI:GetFramePrefabName()
  return "Form_ExcitingWindow"
end

return Form_ExcitingWindowUI
