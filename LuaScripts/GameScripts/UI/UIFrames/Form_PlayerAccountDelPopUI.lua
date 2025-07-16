local Form_PlayerAccountDelPopUI = class("Form_PlayerAccountDelPopUI", require("UI/Common/UIBase"))

function Form_PlayerAccountDelPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerAccountDelPopUI:GetID()
  return UIDefines.ID_FORM_PLAYERACCOUNTDELPOP
end

function Form_PlayerAccountDelPopUI:GetFramePrefabName()
  return "Form_PlayerAccountDelPop"
end

return Form_PlayerAccountDelPopUI
