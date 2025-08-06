local Form_GuideSkipPopUI = class("Form_GuideSkipPopUI", require("UI/Common/UIBase"))

function Form_GuideSkipPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuideSkipPopUI:GetID()
  return UIDefines.ID_FORM_GUIDESKIPPOP
end

function Form_GuideSkipPopUI:GetFramePrefabName()
  return "Form_GuideSkipPop"
end

return Form_GuideSkipPopUI
