local Form_RogueChoseUI = class("Form_RogueChoseUI", require("UI/Common/UIBase"))

function Form_RogueChoseUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueChoseUI:GetID()
  return UIDefines.ID_FORM_ROGUECHOSE
end

function Form_RogueChoseUI:GetFramePrefabName()
  return "Form_RogueChose"
end

return Form_RogueChoseUI
