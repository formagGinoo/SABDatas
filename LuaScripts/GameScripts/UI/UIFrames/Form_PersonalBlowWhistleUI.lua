local Form_PersonalBlowWhistleUI = class("Form_PersonalBlowWhistleUI", require("UI/Common/UIBase"))

function Form_PersonalBlowWhistleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalBlowWhistleUI:GetID()
  return UIDefines.ID_FORM_PERSONALBLOWWHISTLE
end

function Form_PersonalBlowWhistleUI:GetFramePrefabName()
  return "Form_PersonalBlowWhistle"
end

return Form_PersonalBlowWhistleUI
