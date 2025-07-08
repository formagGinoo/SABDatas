local Form_PlayerCenterAccountBindUI = class("Form_PlayerCenterAccountBindUI", require("UI/Common/UIBase"))

function Form_PlayerCenterAccountBindUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterAccountBindUI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERACCOUNTBIND
end

function Form_PlayerCenterAccountBindUI:GetFramePrefabName()
  return "Form_PlayerCenterAccountBind"
end

return Form_PlayerCenterAccountBindUI
