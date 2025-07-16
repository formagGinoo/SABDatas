local Form_HangUpBattleUI = class("Form_HangUpBattleUI", require("UI/Common/UIBase"))

function Form_HangUpBattleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HangUpBattleUI:GetID()
  return UIDefines.ID_FORM_HANGUPBATTLE
end

function Form_HangUpBattleUI:GetFramePrefabName()
  return "Form_HangUpBattle"
end

return Form_HangUpBattleUI
