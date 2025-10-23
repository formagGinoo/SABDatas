local Form_Push_StageGiftUI = class("Form_Push_StageGiftUI", require("UI/Common/UIBase"))

function Form_Push_StageGiftUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Push_StageGiftUI:GetID()
  return UIDefines.ID_FORM_PUSH_STAGEGIFT
end

function Form_Push_StageGiftUI:GetFramePrefabName()
  return "Form_Push_StageGift"
end

return Form_Push_StageGiftUI
