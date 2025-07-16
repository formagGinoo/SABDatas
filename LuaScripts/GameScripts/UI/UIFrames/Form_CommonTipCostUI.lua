local Form_CommonTipCostUI = class("Form_CommonTipCostUI", require("UI/Common/UIBase"))

function Form_CommonTipCostUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonTipCostUI:GetID()
  return UIDefines.ID_FORM_COMMONTIPCOST
end

function Form_CommonTipCostUI:GetFramePrefabName()
  return "Form_CommonTipCost"
end

return Form_CommonTipCostUI
