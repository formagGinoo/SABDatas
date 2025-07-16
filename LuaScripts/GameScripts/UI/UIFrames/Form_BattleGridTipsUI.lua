local Form_BattleGridTipsUI = class("Form_BattleGridTipsUI", require("UI/Common/UIBase"))

function Form_BattleGridTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleGridTipsUI:GetID()
  return UIDefines.ID_FORM_BATTLEGRIDTIPS
end

function Form_BattleGridTipsUI:GetFramePrefabName()
  return "Form_BattleGridTips"
end

return Form_BattleGridTipsUI
