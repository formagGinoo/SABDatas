local Form_Activity105Minigame_PuzzleUI = class("Form_Activity105Minigame_PuzzleUI", require("UI/Common/UIBase"))

function Form_Activity105Minigame_PuzzleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105Minigame_PuzzleUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105MINIGAME_PUZZLE
end

function Form_Activity105Minigame_PuzzleUI:GetFramePrefabName()
  return "Form_Activity105Minigame_Puzzle"
end

return Form_Activity105Minigame_PuzzleUI
