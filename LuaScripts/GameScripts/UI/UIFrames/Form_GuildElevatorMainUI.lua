local Form_GuildElevatorMainUI = class("Form_GuildElevatorMainUI", require("UI/Common/UIBase"))

function Form_GuildElevatorMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildElevatorMainUI:GetID()
  return UIDefines.ID_FORM_GUILDELEVATORMAIN
end

function Form_GuildElevatorMainUI:GetFramePrefabName()
  return "Form_GuildElevatorMain"
end

return Form_GuildElevatorMainUI
