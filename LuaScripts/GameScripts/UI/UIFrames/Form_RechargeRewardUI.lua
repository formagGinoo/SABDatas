local Form_RechargeRewardUI = class("Form_RechargeRewardUI", require("UI/Common/UIBase"))

function Form_RechargeRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RechargeRewardUI:GetID()
  return UIDefines.ID_FORM_RECHARGEREWARD
end

function Form_RechargeRewardUI:GetFramePrefabName()
  return "Form_RechargeReward"
end

return Form_RechargeRewardUI
