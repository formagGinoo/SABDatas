local Form_HuntingNightRewardUI = class("Form_HuntingNightRewardUI", require("UI/Common/UIBase"))

function Form_HuntingNightRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightRewardUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHTREWARD
end

function Form_HuntingNightRewardUI:GetFramePrefabName()
  return "Form_HuntingNightReward"
end

return Form_HuntingNightRewardUI
