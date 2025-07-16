local Form_CastleDispatchSelectUI = class("Form_CastleDispatchSelectUI", require("UI/Common/UIBase"))

function Form_CastleDispatchSelectUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchSelectUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHSELECT
end

function Form_CastleDispatchSelectUI:GetFramePrefabName()
  return "Form_CastleDispatchSelect"
end

return Form_CastleDispatchSelectUI
