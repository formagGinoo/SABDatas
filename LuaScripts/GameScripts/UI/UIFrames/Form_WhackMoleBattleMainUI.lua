local Form_WhackMoleBattleMainUI = class("Form_WhackMoleBattleMainUI", require("UI/Common/UIBase"))

function Form_WhackMoleBattleMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleBattleMainUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLEBATTLEMAIN
end

function Form_WhackMoleBattleMainUI:GetFramePrefabName()
  return "Form_WhackMoleBattleMain"
end

return Form_WhackMoleBattleMainUI
