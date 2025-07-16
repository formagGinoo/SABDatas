local Form_Gacha10UI = class("Form_Gacha10UI", require("UI/Common/UIBase"))

function Form_Gacha10UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Gacha10UI:GetID()
  return UIDefines.ID_FORM_GACHA10
end

function Form_Gacha10UI:GetFramePrefabName()
  return "Form_Gacha10"
end

return Form_Gacha10UI
