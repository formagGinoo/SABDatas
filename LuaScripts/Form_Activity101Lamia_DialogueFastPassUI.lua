local Form_Activity101Lamia_DialogueFastPassUI = class("Form_Activity101Lamia_DialogueFastPassUI", require("UI/Common/HeroActBase/UIHeroActDialogueFastPassBase"))

function Form_Activity101Lamia_DialogueFastPassUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_DialogueFastPassUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUEFASTPASS
end

function Form_Activity101Lamia_DialogueFastPassUI:GetFramePrefabName()
  return "Form_Activity101Lamia_DialogueFastPass"
end

return Form_Activity101Lamia_DialogueFastPassUI
