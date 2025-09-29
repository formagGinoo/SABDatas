local Form_Activity110_ItemPopUI = class("Form_Activity110_ItemPopUI", require("UI/Common/UIBase"))

function Form_Activity110_ItemPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_ItemPopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_ITEMPOP
end

function Form_Activity110_ItemPopUI:GetFramePrefabName()
  return "Form_Activity110_ItemPop"
end

return Form_Activity110_ItemPopUI
