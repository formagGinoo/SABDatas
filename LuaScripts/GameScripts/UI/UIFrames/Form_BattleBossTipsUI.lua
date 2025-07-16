local Form_BattleBossTipsUI = class("Form_BattleBossTipsUI", require("UI/Common/UIBase"))

function Form_BattleBossTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleBossTipsUI:GetID()
  return UIDefines.ID_FORM_BATTLEBOSSTIPS
end

function Form_BattleBossTipsUI:GetFramePrefabName()
  return "Form_BattleBossTips"
end

return Form_BattleBossTipsUI
