local Form_PvpReplaceDetailsUI = class("Form_PvpReplaceDetailsUI", require("UI/Common/UIBase"))

function Form_PvpReplaceDetailsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceDetailsUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEDETAILS
end

function Form_PvpReplaceDetailsUI:GetFramePrefabName()
  return "Form_PvpReplaceDetails"
end

return Form_PvpReplaceDetailsUI
