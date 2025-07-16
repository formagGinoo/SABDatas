local Form_Item_TipsUI = class("Form_Item_TipsUI", require("UI/Common/UIBase"))

function Form_Item_TipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Item_TipsUI:GetID()
  return UIDefines.ID_FORM_ITEM_TIPS
end

function Form_Item_TipsUI:GetFramePrefabName()
  return "Form_Item_Tips"
end

return Form_Item_TipsUI
