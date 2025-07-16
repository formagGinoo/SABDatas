local Form_CastleEventMainUI = class("Form_CastleEventMainUI", require("UI/Common/UIBase"))

function Form_CastleEventMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleEventMainUI:GetID()
  return UIDefines.ID_FORM_CASTLEEVENTMAIN
end

function Form_CastleEventMainUI:GetFramePrefabName()
  return "Form_CastleEventMain"
end

return Form_CastleEventMainUI
