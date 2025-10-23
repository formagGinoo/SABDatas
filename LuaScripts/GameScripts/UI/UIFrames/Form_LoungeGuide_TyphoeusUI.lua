local Form_LoungeGuide_TyphoeusUI = class("Form_LoungeGuide_TyphoeusUI", require("UI/Common/UIBase"))

function Form_LoungeGuide_TyphoeusUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeGuide_TyphoeusUI:GetID()
  return UIDefines.ID_FORM_LOUNGEGUIDE_TYPHOEUS
end

function Form_LoungeGuide_TyphoeusUI:GetFramePrefabName()
  return "Form_LoungeGuide_Typhoeus"
end

return Form_LoungeGuide_TyphoeusUI
