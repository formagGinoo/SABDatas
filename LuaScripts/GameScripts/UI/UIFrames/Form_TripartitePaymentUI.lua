local Form_TripartitePaymentUI = class("Form_TripartitePaymentUI", require("UI/Common/UIBase"))

function Form_TripartitePaymentUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TripartitePaymentUI:GetID()
  return UIDefines.ID_FORM_TRIPARTITEPAYMENT
end

function Form_TripartitePaymentUI:GetFramePrefabName()
  return "Form_TripartitePayment"
end

return Form_TripartitePaymentUI
