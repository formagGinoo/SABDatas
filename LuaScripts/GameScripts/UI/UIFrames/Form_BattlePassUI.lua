local Form_BattlePassUI = class("Form_BattlePassUI", require("UI/Common/BattlePassBase/UIBattlePassMain"))

function Form_BattlePassUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASS
end

function Form_BattlePassUI:GetFramePrefabName()
  return "Form_BattlePass"
end

return Form_BattlePassUI
