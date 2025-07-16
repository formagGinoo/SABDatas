local Form_BattlePass_UpUI = class("Form_BattlePass_UpUI", require("UI/Common/BattlePassBase/UIBattlePassMain"))

function Form_BattlePass_UpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePass_UpUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASS_UP
end

function Form_BattlePass_UpUI:GetFramePrefabName()
  return "Form_BattlePass_Up"
end

return Form_BattlePass_UpUI
