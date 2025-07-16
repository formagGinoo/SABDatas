local Form_RankListRewardPopUI = class("Form_RankListRewardPopUI", require("UI/Common/UIBase"))

function Form_RankListRewardPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RankListRewardPopUI:GetID()
  return UIDefines.ID_FORM_RANKLISTREWARDPOP
end

function Form_RankListRewardPopUI:GetFramePrefabName()
  return "Form_RankListRewardPop"
end

return Form_RankListRewardPopUI
