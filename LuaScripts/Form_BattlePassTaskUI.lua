local Form_BattlePassTaskUI = class("Form_BattlePassTaskUI", require("UI/Common/UIBase"))

function Form_BattlePassTaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassTaskUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSTASK
end

function Form_BattlePassTaskUI:GetFramePrefabName()
  return "Form_BattlePassTask"
end

return Form_BattlePassTaskUI
