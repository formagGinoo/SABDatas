local Form_PvpReplaceBattleDefeatUI = class("Form_PvpReplaceBattleDefeatUI", require("UI/Common/UIBase"))

function Form_PvpReplaceBattleDefeatUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceBattleDefeatUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEBATTLEDEFEAT
end

function Form_PvpReplaceBattleDefeatUI:GetFramePrefabName()
  return "Form_PvpReplaceBattleDefeat"
end

return Form_PvpReplaceBattleDefeatUI
