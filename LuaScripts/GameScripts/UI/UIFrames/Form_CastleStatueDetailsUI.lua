local Form_CastleStatueDetailsUI = class("Form_CastleStatueDetailsUI", require("UI/Common/UIBase"))

function Form_CastleStatueDetailsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStatueDetailsUI:GetID()
  return UIDefines.ID_FORM_CASTLESTATUEDETAILS
end

function Form_CastleStatueDetailsUI:GetFramePrefabName()
  return "Form_CastleStatueDetails"
end

return Form_CastleStatueDetailsUI
