local Form_HeroheatUI = class("Form_HeroheatUI", require("UI/Common/UIBase"))

function Form_HeroheatUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroheatUI:GetID()
  return UIDefines.ID_FORM_HEROHEAT
end

function Form_HeroheatUI:GetFramePrefabName()
  return "Form_Heroheat"
end

return Form_HeroheatUI
