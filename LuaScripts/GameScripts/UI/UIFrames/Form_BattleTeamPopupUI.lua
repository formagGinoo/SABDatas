local Form_BattleTeamPopupUI = class("Form_BattleTeamPopupUI", require("UI/Common/UIBase"))

function Form_BattleTeamPopupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleTeamPopupUI:GetID()
  return UIDefines.ID_FORM_BATTLETEAMPOPUP
end

function Form_BattleTeamPopupUI:GetFramePrefabName()
  return "Form_BattleTeamPopup"
end

return Form_BattleTeamPopupUI
