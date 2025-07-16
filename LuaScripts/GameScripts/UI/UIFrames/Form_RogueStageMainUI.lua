local Form_RogueStageMainUI = class("Form_RogueStageMainUI", require("UI/Common/UIBase"))

function Form_RogueStageMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueStageMainUI:GetID()
  return UIDefines.ID_FORM_ROGUESTAGEMAIN
end

function Form_RogueStageMainUI:GetFramePrefabName()
  return "Form_RogueStageMain"
end

return Form_RogueStageMainUI
