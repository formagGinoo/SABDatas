local Form_BattleSystemPop1UI = class("Form_BattleSystemPop1UI", require("UI/Common/UIBase"))

function Form_BattleSystemPop1UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleSystemPop1UI:GetID()
  return UIDefines.ID_FORM_BATTLESYSTEMPOP1
end

function Form_BattleSystemPop1UI:GetFramePrefabName()
  return "Form_BattleSystemPop1"
end

return Form_BattleSystemPop1UI
