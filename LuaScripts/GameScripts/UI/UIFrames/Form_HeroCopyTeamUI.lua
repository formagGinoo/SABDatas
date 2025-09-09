local Form_HeroCopyTeamUI = class("Form_HeroCopyTeamUI", require("UI/Common/UIBase"))

function Form_HeroCopyTeamUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroCopyTeamUI:GetID()
  return UIDefines.ID_FORM_HEROCOPYTEAM
end

function Form_HeroCopyTeamUI:GetFramePrefabName()
  return "Form_HeroCopyTeam"
end

return Form_HeroCopyTeamUI
