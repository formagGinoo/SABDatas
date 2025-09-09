local Form_BagFilterUI = class("Form_BagFilterUI", require("UI/Common/UIBase"))

function Form_BagFilterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BagFilterUI:GetID()
  return UIDefines.ID_FORM_BAGFILTER
end

function Form_BagFilterUI:GetFramePrefabName()
  return "Form_BagFilter"
end

return Form_BagFilterUI
