local Form_CastleDispatchPopupRuleUI = class("Form_CastleDispatchPopupRuleUI", require("UI/Common/UIBase"))

function Form_CastleDispatchPopupRuleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchPopupRuleUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHPOPUPRULE
end

function Form_CastleDispatchPopupRuleUI:GetFramePrefabName()
  return "Form_CastleDispatchPopupRule"
end

return Form_CastleDispatchPopupRuleUI
