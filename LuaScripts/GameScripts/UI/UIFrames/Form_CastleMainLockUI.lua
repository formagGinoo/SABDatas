local Form_CastleMainLockUI = class("Form_CastleMainLockUI", require("UI/Common/UIBase"))

function Form_CastleMainLockUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleMainLockUI:GetID()
  return UIDefines.ID_FORM_CASTLEMAINLOCK
end

function Form_CastleMainLockUI:GetFramePrefabName()
  return "Form_CastleMainLock"
end

return Form_CastleMainLockUI
