local Form_BossRewardUI = class("Form_BossRewardUI", require("UI/Common/UIBase"))

function Form_BossRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BossRewardUI:GetID()
  return UIDefines.ID_FORM_BOSSREWARD
end

function Form_BossRewardUI:GetFramePrefabName()
  return "Form_BossReward"
end

return Form_BossRewardUI
