local Form_GmNewUI = class("Form_GmNewUI", require("UI/Common/UIBase"))

function Form_GmNewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GmNewUI:GetID()
  return UIDefines.ID_FORM_GMNEW
end

function Form_GmNewUI:GetFramePrefabName()
  return "Form_GmNew"
end

return Form_GmNewUI
