local Form_RogueRewardUI = class("Form_RogueRewardUI", require("UI/Common/UIBase"))

function Form_RogueRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueRewardUI:GetID()
  return UIDefines.ID_FORM_ROGUEREWARD
end

function Form_RogueRewardUI:GetFramePrefabName()
  return "Form_RogueReward"
end

return Form_RogueRewardUI
