local Form_battle_mainUI = class("Form_battle_mainUI", require("UI/Common/UIBase"))

function Form_battle_mainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_battle_mainUI:GetID()
  return UIDefines.ID_FORM_BATTLE_MAIN
end

function Form_battle_mainUI:GetFramePrefabName()
  return "Form_battle_main"
end

return Form_battle_mainUI
