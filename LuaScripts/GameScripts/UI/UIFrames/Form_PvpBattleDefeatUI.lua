local Form_PvpBattleDefeatUI = class("Form_PvpBattleDefeatUI", require("UI/Common/UIBase"))

function Form_PvpBattleDefeatUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpBattleDefeatUI:GetID()
  return UIDefines.ID_FORM_PVPBATTLEDEFEAT
end

function Form_PvpBattleDefeatUI:GetFramePrefabName()
  return "Form_PvpBattleDefeat"
end

return Form_PvpBattleDefeatUI
