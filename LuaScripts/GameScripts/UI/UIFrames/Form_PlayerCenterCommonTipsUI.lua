local Form_PlayerCenterCommonTipsUI = class("Form_PlayerCenterCommonTipsUI", require("UI/Common/UIBase"))

function Form_PlayerCenterCommonTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterCommonTipsUI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERCOMMONTIPS
end

function Form_PlayerCenterCommonTipsUI:GetFramePrefabName()
  return "Form_PlayerCenterCommonTips"
end

return Form_PlayerCenterCommonTipsUI
