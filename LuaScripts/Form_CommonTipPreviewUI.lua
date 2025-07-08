local Form_CommonTipPreviewUI = class("Form_CommonTipPreviewUI", require("UI/Common/UIBase"))

function Form_CommonTipPreviewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonTipPreviewUI:GetID()
  return UIDefines.ID_FORM_COMMONTIPPREVIEW
end

function Form_CommonTipPreviewUI:GetFramePrefabName()
  return "Form_CommonTipPreview"
end

return Form_CommonTipPreviewUI
