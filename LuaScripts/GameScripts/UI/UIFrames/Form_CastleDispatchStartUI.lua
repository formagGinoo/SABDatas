local Form_CastleDispatchStartUI = class("Form_CastleDispatchStartUI", require("UI/Common/UIBase"))

function Form_CastleDispatchStartUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchStartUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHSTART
end

function Form_CastleDispatchStartUI:GetFramePrefabName()
  return "Form_CastleDispatchStart"
end

return Form_CastleDispatchStartUI
