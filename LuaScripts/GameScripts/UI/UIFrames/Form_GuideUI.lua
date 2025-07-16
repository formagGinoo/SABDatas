local Form_GuideUI = class("Form_GuideUI", require("UI/Common/UIBase"))

function Form_GuideUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuideUI:GetID()
  return UIDefines.ID_FORM_GUIDE
end

function Form_GuideUI:GetFramePrefabName()
  return "Form_Guide"
end

return Form_GuideUI
