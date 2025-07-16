local Form_RechargeUI = class("Form_RechargeUI", require("UI/Common/UIBase"))

function Form_RechargeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RechargeUI:GetID()
  return UIDefines.ID_FORM_RECHARGE
end

function Form_RechargeUI:GetFramePrefabName()
  return "Form_Recharge"
end

return Form_RechargeUI
