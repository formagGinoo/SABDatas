local Form_MainExploreTipsUI = class("Form_MainExploreTipsUI", require("UI/Common/UIBase"))

function Form_MainExploreTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainExploreTipsUI:GetID()
  return UIDefines.ID_FORM_MAINEXPLORETIPS
end

function Form_MainExploreTipsUI:GetFramePrefabName()
  return "Form_MainExploreTips"
end

return Form_MainExploreTipsUI
