local Form_GuildinvitationPopUI = class("Form_GuildinvitationPopUI", require("UI/Common/UIBase"))

function Form_GuildinvitationPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildinvitationPopUI:GetID()
  return UIDefines.ID_FORM_GUILDINVITATIONPOP
end

function Form_GuildinvitationPopUI:GetFramePrefabName()
  return "Form_GuildinvitationPop"
end

return Form_GuildinvitationPopUI
