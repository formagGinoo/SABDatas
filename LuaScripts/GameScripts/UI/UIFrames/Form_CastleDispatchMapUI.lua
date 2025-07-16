local Form_CastleDispatchMapUI = class("Form_CastleDispatchMapUI", require("UI/Common/UIBase"))

function Form_CastleDispatchMapUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchMapUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHMAP
end

function Form_CastleDispatchMapUI:GetFramePrefabName()
  return "Form_CastleDispatchMap"
end

return Form_CastleDispatchMapUI
