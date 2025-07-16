local Form_PlayerProtocolPopUI = class("Form_PlayerProtocolPopUI", require("UI/Common/UIBase"))

function Form_PlayerProtocolPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerProtocolPopUI:GetID()
  return UIDefines.ID_FORM_PLAYERPROTOCOLPOP
end

function Form_PlayerProtocolPopUI:GetFramePrefabName()
  return "Form_PlayerProtocolPop"
end

return Form_PlayerProtocolPopUI
