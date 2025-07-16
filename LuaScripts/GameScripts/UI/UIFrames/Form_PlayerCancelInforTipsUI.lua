local Form_PlayerCancelInforTipsUI = class("Form_PlayerCancelInforTipsUI", require("UI/Common/UIBase"))

function Form_PlayerCancelInforTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCancelInforTipsUI:GetID()
  return UIDefines.ID_FORM_PLAYERCANCELINFORTIPS
end

function Form_PlayerCancelInforTipsUI:GetFramePrefabName()
  return "Form_PlayerCancelInforTips"
end

return Form_PlayerCancelInforTipsUI
