local Form_RogueTalentTreeUI = class("Form_RogueTalentTreeUI", require("UI/Common/UIBase"))

function Form_RogueTalentTreeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueTalentTreeUI:GetID()
  return UIDefines.ID_FORM_ROGUETALENTTREE
end

function Form_RogueTalentTreeUI:GetFramePrefabName()
  return "Form_RogueTalentTree"
end

return Form_RogueTalentTreeUI
