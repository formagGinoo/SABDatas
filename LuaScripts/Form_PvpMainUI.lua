local Form_PvpMainUI = class("Form_PvpMainUI", require("UI/Common/UIBase"))

function Form_PvpMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpMainUI:GetID()
  return UIDefines.ID_FORM_PVPMAIN
end

function Form_PvpMainUI:GetFramePrefabName()
  return "Form_PvpMain"
end

return Form_PvpMainUI
