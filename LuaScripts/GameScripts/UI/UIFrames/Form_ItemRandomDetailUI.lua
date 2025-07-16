local Form_ItemRandomDetailUI = class("Form_ItemRandomDetailUI", require("UI/Common/UIBase"))

function Form_ItemRandomDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ItemRandomDetailUI:GetID()
  return UIDefines.ID_FORM_ITEMRANDOMDETAIL
end

function Form_ItemRandomDetailUI:GetFramePrefabName()
  return "Form_ItemRandomDetail"
end

return Form_ItemRandomDetailUI
