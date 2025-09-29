local Form_LoungeGuidePopUI = class("Form_LoungeGuidePopUI", require("UI/Common/UIBase"))

function Form_LoungeGuidePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeGuidePopUI:GetID()
  return UIDefines.ID_FORM_LOUNGEGUIDEPOP
end

function Form_LoungeGuidePopUI:GetFramePrefabName()
  return "Form_LoungeGuidePop"
end

return Form_LoungeGuidePopUI
