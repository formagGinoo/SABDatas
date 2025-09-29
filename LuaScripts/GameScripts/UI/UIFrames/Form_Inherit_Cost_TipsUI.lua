local Form_Inherit_Cost_TipsUI = class("Form_Inherit_Cost_TipsUI", require("UI/Common/UIBase"))

function Form_Inherit_Cost_TipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Inherit_Cost_TipsUI:GetID()
  return UIDefines.ID_FORM_INHERIT_COST_TIPS
end

function Form_Inherit_Cost_TipsUI:GetFramePrefabName()
  return "Form_Inherit_Cost_Tips"
end

return Form_Inherit_Cost_TipsUI
