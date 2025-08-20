local Form_CollectionEmailUI = class("Form_CollectionEmailUI", require("UI/Common/UIBase"))

function Form_CollectionEmailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CollectionEmailUI:GetID()
  return UIDefines.ID_FORM_COLLECTIONEMAIL
end

function Form_CollectionEmailUI:GetFramePrefabName()
  return "Form_CollectionEmail"
end

return Form_CollectionEmailUI
