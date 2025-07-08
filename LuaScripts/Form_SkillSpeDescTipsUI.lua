local Form_SkillSpeDescTipsUI = class("Form_SkillSpeDescTipsUI", require("UI/Common/UIBase"))

function Form_SkillSpeDescTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_SkillSpeDescTipsUI:GetID()
  return UIDefines.ID_FORM_SKILLSPEDESCTIPS
end

function Form_SkillSpeDescTipsUI:GetFramePrefabName()
  return "Form_SkillSpeDescTips"
end

return Form_SkillSpeDescTipsUI
