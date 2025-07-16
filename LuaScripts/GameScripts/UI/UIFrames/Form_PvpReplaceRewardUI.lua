local Form_PvpReplaceRewardUI = class("Form_PvpReplaceRewardUI", require("UI/Common/UIBase"))

function Form_PvpReplaceRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceRewardUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEREWARD
end

function Form_PvpReplaceRewardUI:GetFramePrefabName()
  return "Form_PvpReplaceReward"
end

return Form_PvpReplaceRewardUI
