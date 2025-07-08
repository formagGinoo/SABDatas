local Form_RogueHandBookUI = class("Form_RogueHandBookUI", require("UI/Common/UIBase"))

function Form_RogueHandBookUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueHandBookUI:GetID()
  return UIDefines.ID_FORM_ROGUEHANDBOOK
end

function Form_RogueHandBookUI:GetFramePrefabName()
  return "Form_RogueHandBook"
end

return Form_RogueHandBookUI
