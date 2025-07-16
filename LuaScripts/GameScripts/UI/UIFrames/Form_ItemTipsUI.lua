local Form_ItemTipsUI = class("Form_ItemTipsUI", require("UI/Common/UIBase"))

function Form_ItemTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ItemTipsUI:GetID()
  return UIDefines.ID_FORM_ITEMTIPS
end

function Form_ItemTipsUI:GetFramePrefabName()
  return "Form_ItemTips"
end

return Form_ItemTipsUI
