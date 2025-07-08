local Form_RankListGiftUI = class("Form_RankListGiftUI", require("UI/Common/UIBase"))

function Form_RankListGiftUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RankListGiftUI:GetID()
  return UIDefines.ID_FORM_RANKLISTGIFT
end

function Form_RankListGiftUI:GetFramePrefabName()
  return "Form_RankListGift"
end

return Form_RankListGiftUI
