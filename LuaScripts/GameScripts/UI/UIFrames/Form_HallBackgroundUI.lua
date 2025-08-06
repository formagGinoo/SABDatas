local Form_HallBackgroundUI = class("Form_HallBackgroundUI", require("UI/Common/UIBase"))

function Form_HallBackgroundUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallBackgroundUI:GetID()
  return UIDefines.ID_FORM_HALLBACKGROUND
end

function Form_HallBackgroundUI:GetFramePrefabName()
  return "Form_HallBackground"
end

return Form_HallBackgroundUI
