local Form_PvpRewardPopUI = class("Form_PvpRewardPopUI", require("UI/Common/UIBase"))

function Form_PvpRewardPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpRewardPopUI:GetID()
  return UIDefines.ID_FORM_PVPREWARDPOP
end

function Form_PvpRewardPopUI:GetFramePrefabName()
  return "Form_PvpRewardPop"
end

return Form_PvpRewardPopUI
