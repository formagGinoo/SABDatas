local Form_Rolling_TipsUI = class("Form_Rolling_TipsUI", require("UI/Common/UIBase"))

function Form_Rolling_TipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Rolling_TipsUI:GetID()
  return UIDefines.ID_FORM_ROLLING_TIPS
end

function Form_Rolling_TipsUI:GetFramePrefabName()
  return "Form_Rolling_Tips"
end

return Form_Rolling_TipsUI
