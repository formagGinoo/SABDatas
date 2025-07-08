local Form_EndingUI = class("Form_EndingUI", require("UI/Common/UIBase"))

function Form_EndingUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EndingUI:GetID()
  return UIDefines.ID_FORM_ENDING
end

function Form_EndingUI:GetFramePrefabName()
  return "Form_Ending"
end

return Form_EndingUI
