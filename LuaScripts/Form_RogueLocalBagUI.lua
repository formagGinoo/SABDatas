local Form_RogueLocalBagUI = class("Form_RogueLocalBagUI", require("UI/Common/UIBase"))

function Form_RogueLocalBagUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueLocalBagUI:GetID()
  return UIDefines.ID_FORM_ROGUELOCALBAG
end

function Form_RogueLocalBagUI:GetFramePrefabName()
  return "Form_RogueLocalBag"
end

return Form_RogueLocalBagUI
