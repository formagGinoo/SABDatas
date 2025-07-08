local Form_PersonalCdkPopUI = class("Form_PersonalCdkPopUI", require("UI/Common/UIBase"))

function Form_PersonalCdkPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalCdkPopUI:GetID()
  return UIDefines.ID_FORM_PERSONALCDKPOP
end

function Form_PersonalCdkPopUI:GetFramePrefabName()
  return "Form_PersonalCdkPop"
end

return Form_PersonalCdkPopUI
