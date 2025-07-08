local Form_CastleStatueUnlockTipsUI = class("Form_CastleStatueUnlockTipsUI", require("UI/Common/UIBase"))

function Form_CastleStatueUnlockTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStatueUnlockTipsUI:GetID()
  return UIDefines.ID_FORM_CASTLESTATUEUNLOCKTIPS
end

function Form_CastleStatueUnlockTipsUI:GetFramePrefabName()
  return "Form_CastleStatueUnlockTips"
end

return Form_CastleStatueUnlockTipsUI
