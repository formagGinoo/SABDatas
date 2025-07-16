local Form_BattleGuideUI = class("Form_BattleGuideUI", require("UI/Common/UIBase"))

function Form_BattleGuideUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleGuideUI:GetID()
  return UIDefines.ID_FORM_BATTLEGUIDE
end

function Form_BattleGuideUI:GetFramePrefabName()
  return "Form_BattleGuide"
end

return Form_BattleGuideUI
