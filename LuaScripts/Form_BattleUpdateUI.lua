local Form_BattleUpdateUI = class("Form_BattleUpdateUI", require("UI/Common/UIBase"))

function Form_BattleUpdateUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleUpdateUI:GetID()
  return UIDefines.ID_FORM_BATTLEUPDATE
end

function Form_BattleUpdateUI:GetFramePrefabName()
  return "Form_BattleUpdate"
end

return Form_BattleUpdateUI
