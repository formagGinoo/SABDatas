local Form_PersonalRenameUI = class("Form_PersonalRenameUI", require("UI/Common/UIBase"))

function Form_PersonalRenameUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRenameUI:GetID()
  return UIDefines.ID_FORM_PERSONALRENAME
end

function Form_PersonalRenameUI:GetFramePrefabName()
  return "Form_PersonalRename"
end

return Form_PersonalRenameUI
