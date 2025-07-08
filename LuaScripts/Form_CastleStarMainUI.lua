local Form_CastleStarMainUI = class("Form_CastleStarMainUI", require("UI/Common/UIBase"))

function Form_CastleStarMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStarMainUI:GetID()
  return UIDefines.ID_FORM_CASTLESTARMAIN
end

function Form_CastleStarMainUI:GetFramePrefabName()
  return "Form_CastleStarMain"
end

return Form_CastleStarMainUI
