local Form_TeamUI = class("Form_TeamUI", require("UI/Common/UIBase"))

function Form_TeamUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TeamUI:GetID()
  return UIDefines.ID_FORM_TEAM
end

function Form_TeamUI:GetFramePrefabName()
  return "Form_Team"
end

return Form_TeamUI
