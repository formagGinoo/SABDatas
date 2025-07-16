local Form_CastleStarUnlockUI = class("Form_CastleStarUnlockUI", require("UI/Common/UIBase"))

function Form_CastleStarUnlockUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStarUnlockUI:GetID()
  return UIDefines.ID_FORM_CASTLESTARUNLOCK
end

function Form_CastleStarUnlockUI:GetFramePrefabName()
  return "Form_CastleStarUnlock"
end

return Form_CastleStarUnlockUI
