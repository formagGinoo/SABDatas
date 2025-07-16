local Form_BattleBossWarningUI = class("Form_BattleBossWarningUI", require("UI/Common/UIBase"))

function Form_BattleBossWarningUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleBossWarningUI:GetID()
  return UIDefines.ID_FORM_BATTLEBOSSWARNING
end

function Form_BattleBossWarningUI:GetFramePrefabName()
  return "Form_BattleBossWarning"
end

return Form_BattleBossWarningUI
