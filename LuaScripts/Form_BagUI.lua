local Form_BagUI = class("Form_BagUI", require("UI/Common/UIBase"))

function Form_BagUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BagUI:GetID()
  return UIDefines.ID_FORM_BAG
end

function Form_BagUI:GetFramePrefabName()
  return "Form_Bag"
end

return Form_BagUI
