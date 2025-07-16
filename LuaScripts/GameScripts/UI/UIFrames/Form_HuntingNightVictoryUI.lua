local Form_HuntingNightVictoryUI = class("Form_HuntingNightVictoryUI", require("UI/Common/UIBase"))

function Form_HuntingNightVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightVictoryUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHTVICTORY
end

function Form_HuntingNightVictoryUI:GetFramePrefabName()
  return "Form_HuntingNightVictory"
end

return Form_HuntingNightVictoryUI
