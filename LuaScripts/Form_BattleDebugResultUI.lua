local Form_BattleDebugResultUI = class("Form_BattleDebugResultUI", require("UI/Common/UIBase"))

function Form_BattleDebugResultUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleDebugResultUI:GetID()
  return UIDefines.ID_FORM_BATTLEDEBUGRESULT
end

function Form_BattleDebugResultUI:GetFramePrefabName()
  return "Form_BattleDebugResult"
end

return Form_BattleDebugResultUI
