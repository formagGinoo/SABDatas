local Form_CastleStarExcitingWindowUI = class("Form_CastleStarExcitingWindowUI", require("UI/Common/UIBase"))

function Form_CastleStarExcitingWindowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStarExcitingWindowUI:GetID()
  return UIDefines.ID_FORM_CASTLESTAREXCITINGWINDOW
end

function Form_CastleStarExcitingWindowUI:GetFramePrefabName()
  return "Form_CastleStarExcitingWindow"
end

return Form_CastleStarExcitingWindowUI
