local Form_WhackMoleBattleResultUI = class("Form_WhackMoleBattleResultUI", require("UI/Common/UIBase"))

function Form_WhackMoleBattleResultUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleBattleResultUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLEBATTLERESULT
end

function Form_WhackMoleBattleResultUI:GetFramePrefabName()
  return "Form_WhackMoleBattleResult"
end

return Form_WhackMoleBattleResultUI
