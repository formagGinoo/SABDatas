local Form_PersonalRaidNewDifficultUI = class("Form_PersonalRaidNewDifficultUI", require("UI/Common/UIBase"))

function Form_PersonalRaidNewDifficultUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidNewDifficultUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDNEWDIFFICULT
end

function Form_PersonalRaidNewDifficultUI:GetFramePrefabName()
  return "Form_PersonalRaidNewDifficult"
end

return Form_PersonalRaidNewDifficultUI
