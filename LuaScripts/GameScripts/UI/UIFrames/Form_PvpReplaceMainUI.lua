local Form_PvpReplaceMainUI = class("Form_PvpReplaceMainUI", require("UI/Common/UIBase"))

function Form_PvpReplaceMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceMainUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEMAIN
end

function Form_PvpReplaceMainUI:GetFramePrefabName()
  return "Form_PvpReplaceMain"
end

return Form_PvpReplaceMainUI
