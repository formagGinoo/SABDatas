local Form_OptionalGiftUI = class("Form_OptionalGiftUI", require("UI/Common/UIBase"))

function Form_OptionalGiftUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_OptionalGiftUI:GetID()
  return UIDefines.ID_FORM_OPTIONALGIFT
end

function Form_OptionalGiftUI:GetFramePrefabName()
  return "Form_OptionalGift"
end

return Form_OptionalGiftUI
