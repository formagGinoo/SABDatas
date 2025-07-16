local Form_PlayerCenterPopUI = class("Form_PlayerCenterPopUI", require("UI/Common/UIBase"))

function Form_PlayerCenterPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterPopUI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERPOP
end

function Form_PlayerCenterPopUI:GetFramePrefabName()
  return "Form_PlayerCenterPop"
end

return Form_PlayerCenterPopUI
