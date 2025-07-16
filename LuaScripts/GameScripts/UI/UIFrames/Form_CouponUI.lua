local Form_CouponUI = class("Form_CouponUI", require("UI/Common/UIBase"))

function Form_CouponUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CouponUI:GetID()
  return UIDefines.ID_FORM_COUPON
end

function Form_CouponUI:GetFramePrefabName()
  return "Form_Coupon"
end

return Form_CouponUI
