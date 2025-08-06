local Form_Activity105Minigame_MainUI = class("Form_Activity105Minigame_MainUI", require("UI/Common/UIBase"))

function Form_Activity105Minigame_MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105Minigame_MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105MINIGAME_MAIN
end

function Form_Activity105Minigame_MainUI:GetFramePrefabName()
  return "Form_Activity105Minigame_Main"
end

return Form_Activity105Minigame_MainUI
