local Form_CastleStatueGeneralViewUI = class("Form_CastleStatueGeneralViewUI", require("UI/Common/UIBase"))

function Form_CastleStatueGeneralViewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStatueGeneralViewUI:GetID()
  return UIDefines.ID_FORM_CASTLESTATUEGENERALVIEW
end

function Form_CastleStatueGeneralViewUI:GetFramePrefabName()
  return "Form_CastleStatueGeneralView"
end

return Form_CastleStatueGeneralViewUI
