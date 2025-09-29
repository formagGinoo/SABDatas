local Form_LoungeVictoryUI = class("Form_LoungeVictoryUI", require("UI/Common/UIBase"))

function Form_LoungeVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeVictoryUI:GetID()
  return UIDefines.ID_FORM_LOUNGEVICTORY
end

function Form_LoungeVictoryUI:GetFramePrefabName()
  return "Form_LoungeVictory"
end

return Form_LoungeVictoryUI
