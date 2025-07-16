local Form_CommonTipCostOneUI = class("Form_CommonTipCostOneUI", require("UI/Common/UIBase"))

function Form_CommonTipCostOneUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonTipCostOneUI:GetID()
  return UIDefines.ID_FORM_COMMONTIPCOSTONE
end

function Form_CommonTipCostOneUI:GetFramePrefabName()
  return "Form_CommonTipCostOne"
end

return Form_CommonTipCostOneUI
