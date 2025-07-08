local Form_BattleEndUI = class("Form_BattleEndUI", require("UI/Common/UIBase"))

function Form_BattleEndUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleEndUI:GetID()
  return UIDefines.ID_FORM_BATTLEEND
end

function Form_BattleEndUI:GetFramePrefabName()
  return "Form_BattleEnd"
end

return Form_BattleEndUI
