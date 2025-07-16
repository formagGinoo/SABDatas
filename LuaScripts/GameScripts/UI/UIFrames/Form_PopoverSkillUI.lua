local Form_PopoverSkillUI = class("Form_PopoverSkillUI", require("UI/Common/UIBase"))

function Form_PopoverSkillUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopoverSkillUI:GetID()
  return UIDefines.ID_FORM_POPOVERSKILL
end

function Form_PopoverSkillUI:GetFramePrefabName()
  return "Form_PopoverSkill"
end

return Form_PopoverSkillUI
