local Form_Push_GiftUI = class("Form_Push_GiftUI", require("UI/Common/UIBase"))

function Form_Push_GiftUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Push_GiftUI:GetID()
  return UIDefines.ID_FORM_PUSH_GIFT
end

function Form_Push_GiftUI:GetFramePrefabName()
  return "Form_Push_Gift"
end

return Form_Push_GiftUI
