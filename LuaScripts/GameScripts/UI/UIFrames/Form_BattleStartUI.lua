local Form_BattleStartUI = class("Form_BattleStartUI", require("UI/Common/UIBase"))

function Form_BattleStartUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleStartUI:GetID()
  return UIDefines.ID_FORM_BATTLESTART
end

function Form_BattleStartUI:GetFramePrefabName()
  return "Form_BattleStart"
end

return Form_BattleStartUI
