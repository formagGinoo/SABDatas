local Form_BattleBossUI = class("Form_BattleBossUI", require("UI/Common/UIBase"))

function Form_BattleBossUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleBossUI:GetID()
  return UIDefines.ID_FORM_BATTLEBOSS
end

function Form_BattleBossUI:GetFramePrefabName()
  return "Form_BattleBoss"
end

return Form_BattleBossUI
