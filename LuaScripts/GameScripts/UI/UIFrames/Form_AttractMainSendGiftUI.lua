local Form_AttractMainSendGiftUI = class("Form_AttractMainSendGiftUI", require("UI/Common/UIBase"))

function Form_AttractMainSendGiftUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractMainSendGiftUI:GetID()
  return UIDefines.ID_FORM_ATTRACTMAINSENDGIFT
end

function Form_AttractMainSendGiftUI:GetFramePrefabName()
  return "Form_AttractMainSendGift"
end

return Form_AttractMainSendGiftUI
