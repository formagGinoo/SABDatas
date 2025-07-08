local Form_CastleStatueEnterUI = class("Form_CastleStatueEnterUI", require("UI/Common/UIBase"))

function Form_CastleStatueEnterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStatueEnterUI:GetID()
  return UIDefines.ID_FORM_CASTLESTATUEENTER
end

function Form_CastleStatueEnterUI:GetFramePrefabName()
  return "Form_CastleStatueEnter"
end

return Form_CastleStatueEnterUI
