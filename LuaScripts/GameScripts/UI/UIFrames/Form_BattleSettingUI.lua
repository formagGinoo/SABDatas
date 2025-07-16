local Form_BattleSettingUI = class("Form_BattleSettingUI", require("UI/Common/UIBase"))

function Form_BattleSettingUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleSettingUI:GetID()
  return UIDefines.ID_FORM_BATTLESETTING
end

function Form_BattleSettingUI:GetFramePrefabName()
  return "Form_BattleSetting"
end

return Form_BattleSettingUI
