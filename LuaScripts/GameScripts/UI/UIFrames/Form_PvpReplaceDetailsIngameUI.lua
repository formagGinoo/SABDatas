local Form_PvpReplaceDetailsIngameUI = class("Form_PvpReplaceDetailsIngameUI", require("UI/Common/UIBase"))

function Form_PvpReplaceDetailsIngameUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceDetailsIngameUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEDETAILSINGAME
end

function Form_PvpReplaceDetailsIngameUI:GetFramePrefabName()
  return "Form_PvpReplaceDetailsIngame"
end

return Form_PvpReplaceDetailsIngameUI
