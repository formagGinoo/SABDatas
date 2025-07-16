local Form_HuntingNightBattleInfoUI = class("Form_HuntingNightBattleInfoUI", require("UI/Common/UIBase"))

function Form_HuntingNightBattleInfoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightBattleInfoUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHTBATTLEINFO
end

function Form_HuntingNightBattleInfoUI:GetFramePrefabName()
  return "Form_HuntingNightBattleInfo"
end

return Form_HuntingNightBattleInfoUI
