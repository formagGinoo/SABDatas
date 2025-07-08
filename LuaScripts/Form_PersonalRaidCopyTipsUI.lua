local Form_PersonalRaidCopyTipsUI = class("Form_PersonalRaidCopyTipsUI", require("UI/Common/UIBase"))

function Form_PersonalRaidCopyTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidCopyTipsUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDCOPYTIPS
end

function Form_PersonalRaidCopyTipsUI:GetFramePrefabName()
  return "Form_PersonalRaidCopyTips"
end

return Form_PersonalRaidCopyTipsUI
