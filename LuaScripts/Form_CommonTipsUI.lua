local Form_CommonTipsUI = class("Form_CommonTipsUI", require("UI/Common/UIBase"))

function Form_CommonTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CommonTipsUI:GetID()
  return UIDefines.ID_FORM_COMMONTIPS
end

function Form_CommonTipsUI:GetFramePrefabName()
  return "Form_CommonTips"
end

return Form_CommonTipsUI
