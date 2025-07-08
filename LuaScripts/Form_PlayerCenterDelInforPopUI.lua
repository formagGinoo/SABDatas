local Form_PlayerCenterDelInforPopUI = class("Form_PlayerCenterDelInforPopUI", require("UI/Common/UIBase"))

function Form_PlayerCenterDelInforPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterDelInforPopUI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERDELINFORPOP
end

function Form_PlayerCenterDelInforPopUI:GetFramePrefabName()
  return "Form_PlayerCenterDelInforPop"
end

return Form_PlayerCenterDelInforPopUI
