local Form_Activity105MinigameUI = class("Form_Activity105MinigameUI", require("UI/Common/UIBase"))

function Form_Activity105MinigameUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105MinigameUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105MINIGAME
end

function Form_Activity105MinigameUI:GetFramePrefabName()
  return "Form_Activity105Minigame"
end

return Form_Activity105MinigameUI
