local Form_FriendMainUI = class("Form_FriendMainUI", require("UI/Common/UIBase"))

function Form_FriendMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_FriendMainUI:GetID()
  return UIDefines.ID_FORM_FRIENDMAIN
end

function Form_FriendMainUI:GetFramePrefabName()
  return "Form_FriendMain"
end

return Form_FriendMainUI
