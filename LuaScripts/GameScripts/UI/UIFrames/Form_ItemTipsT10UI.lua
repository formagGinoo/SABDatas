local Form_ItemTipsT10UI = class("Form_ItemTipsT10UI", require("UI/Common/UIBase"))

function Form_ItemTipsT10UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ItemTipsT10UI:GetID()
  return UIDefines.ID_FORM_ITEMTIPST10
end

function Form_ItemTipsT10UI:GetFramePrefabName()
  return "Form_ItemTipsT10"
end

return Form_ItemTipsT10UI
