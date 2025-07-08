local Form_RogueItemTipsUI = class("Form_RogueItemTipsUI", require("UI/Common/UIBase"))

function Form_RogueItemTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueItemTipsUI:GetID()
  return UIDefines.ID_FORM_ROGUEITEMTIPS
end

function Form_RogueItemTipsUI:GetFramePrefabName()
  return "Form_RogueItemTips"
end

return Form_RogueItemTipsUI
