local Form_GachaTouchNewUI = class("Form_GachaTouchNewUI", require("UI/Common/UIBase"))

function Form_GachaTouchNewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaTouchNewUI:GetID()
  return UIDefines.ID_FORM_GACHATOUCHNEW
end

function Form_GachaTouchNewUI:GetFramePrefabName()
  return "Form_GachaTouchNew"
end

return Form_GachaTouchNewUI
