local Form_Activity102Dalcaro_DialogueFastPassUI = class("Form_Activity102Dalcaro_DialogueFastPassUI", require("UI/Common/HeroActBase/UIHeroActDialogueFastPassBase"))

function Form_Activity102Dalcaro_DialogueFastPassUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_DialogueFastPassUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUEFASTPASS
end

function Form_Activity102Dalcaro_DialogueFastPassUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_DialogueFastPass"
end

return Form_Activity102Dalcaro_DialogueFastPassUI
