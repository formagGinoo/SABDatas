local Form_Activity110MiniGameRewardUI = class("Form_Activity110MiniGameRewardUI", require("UI/Common/UIBase"))

function Form_Activity110MiniGameRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110MiniGameRewardUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110MINIGAMEREWARD
end

function Form_Activity110MiniGameRewardUI:GetFramePrefabName()
  return "Form_Activity110MiniGameReward"
end

return Form_Activity110MiniGameRewardUI
