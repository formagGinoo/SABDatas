local Form_CastleStatueLevelupTipsUI = class("Form_CastleStatueLevelupTipsUI", require("UI/Common/UIBase"))

function Form_CastleStatueLevelupTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStatueLevelupTipsUI:GetID()
  return UIDefines.ID_FORM_CASTLESTATUELEVELUPTIPS
end

function Form_CastleStatueLevelupTipsUI:GetFramePrefabName()
  return "Form_CastleStatueLevelupTips"
end

return Form_CastleStatueLevelupTipsUI
