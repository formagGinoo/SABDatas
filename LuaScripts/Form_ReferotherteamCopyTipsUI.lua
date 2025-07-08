local Form_ReferotherteamCopyTipsUI = class("Form_ReferotherteamCopyTipsUI", require("UI/Common/UIBase"))

function Form_ReferotherteamCopyTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ReferotherteamCopyTipsUI:GetID()
  return UIDefines.ID_FORM_REFEROTHERTEAMCOPYTIPS
end

function Form_ReferotherteamCopyTipsUI:GetFramePrefabName()
  return "Form_ReferotherteamCopyTips"
end

return Form_ReferotherteamCopyTipsUI
