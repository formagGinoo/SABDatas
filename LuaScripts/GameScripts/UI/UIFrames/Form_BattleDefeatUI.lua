local Form_BattleDefeatUI = class("Form_BattleDefeatUI", require("UI/Common/UIBase"))

function Form_BattleDefeatUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleDefeatUI:GetID()
  return UIDefines.ID_FORM_BATTLEDEFEAT
end

function Form_BattleDefeatUI:GetFramePrefabName()
  return "Form_BattleDefeat"
end

return Form_BattleDefeatUI
