local Form_GuideAllSkipPopUI = class("Form_GuideAllSkipPopUI", require("UI/Common/UIBase"))

function Form_GuideAllSkipPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuideAllSkipPopUI:GetID()
  return UIDefines.ID_FORM_GUIDEALLSKIPPOP
end

function Form_GuideAllSkipPopUI:GetFramePrefabName()
  return "Form_GuideAllSkipPop"
end

return Form_GuideAllSkipPopUI
