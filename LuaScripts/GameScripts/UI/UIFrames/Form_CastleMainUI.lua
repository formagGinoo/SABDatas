local Form_CastleMainUI = class("Form_CastleMainUI", require("UI/Common/UIBase"))

function Form_CastleMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleMainUI:GetID()
  return UIDefines.ID_FORM_CASTLEMAIN
end

function Form_CastleMainUI:GetFramePrefabName()
  return "Form_CastleMain"
end

return Form_CastleMainUI
