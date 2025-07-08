local Form_PlayerCenterPop2UI = class("Form_PlayerCenterPop2UI", require("UI/Common/UIBase"))

function Form_PlayerCenterPop2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PlayerCenterPop2UI:GetID()
  return UIDefines.ID_FORM_PLAYERCENTERPOP2
end

function Form_PlayerCenterPop2UI:GetFramePrefabName()
  return "Form_PlayerCenterPop2"
end

return Form_PlayerCenterPop2UI
