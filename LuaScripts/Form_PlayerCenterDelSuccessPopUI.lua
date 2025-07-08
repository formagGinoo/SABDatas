local Form_PlayerCenterDelSuccessPopUI = class("Form_PlayerCenterDelSuccessPopUI", require("UI/Common/UIBase"))

function Form_PlayerCenterDelSuccessPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterDelSuccessPopUI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERDELSUCCESSPOP
end

function Form_PlayerCenterDelSuccessPopUI:GetFramePrefabName()
  return "Form_PlayerCenterDelSuccessPop"
end

return Form_PlayerCenterDelSuccessPopUI
