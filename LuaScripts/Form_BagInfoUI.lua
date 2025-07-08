local Form_BagInfoUI = class("Form_BagInfoUI", require("UI/Common/UIBase"))

function Form_BagInfoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BagInfoUI:GetID()
  return UIDefines.ID_FORM_BAGINFO
end

function Form_BagInfoUI:GetFramePrefabName()
  return "Form_BagInfo"
end

return Form_BagInfoUI
