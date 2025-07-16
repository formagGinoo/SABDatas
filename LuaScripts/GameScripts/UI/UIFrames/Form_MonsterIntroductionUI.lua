local Form_MonsterIntroductionUI = class("Form_MonsterIntroductionUI", require("UI/Common/UIBase"))

function Form_MonsterIntroductionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MonsterIntroductionUI:GetID()
  return UIDefines.ID_FORM_MONSTERINTRODUCTION
end

function Form_MonsterIntroductionUI:GetFramePrefabName()
  return "Form_MonsterIntroduction"
end

return Form_MonsterIntroductionUI
