local Form_BagFilternewUI = class("Form_BagFilternewUI", require("UI/Common/UIBase"))

function Form_BagFilternewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BagFilternewUI:GetID()
  return UIDefines.ID_FORM_BAGFILTERNEW
end

function Form_BagFilternewUI:GetFramePrefabName()
  return "Form_BagFilternew"
end

return Form_BagFilternewUI
