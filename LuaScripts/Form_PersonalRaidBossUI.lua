local Form_PersonalRaidBossUI = class("Form_PersonalRaidBossUI", require("UI/Common/UIBase"))

function Form_PersonalRaidBossUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidBossUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDBOSS
end

function Form_PersonalRaidBossUI:GetFramePrefabName()
  return "Form_PersonalRaidBoss"
end

return Form_PersonalRaidBossUI
