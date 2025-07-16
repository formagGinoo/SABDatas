local Form_CastleStrongHoldMapUI = class("Form_CastleStrongHoldMapUI", require("UI/Common/UIBase"))

function Form_CastleStrongHoldMapUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleStrongHoldMapUI:GetID()
  return UIDefines.ID_FORM_CASTLESTRONGHOLDMAP
end

function Form_CastleStrongHoldMapUI:GetFramePrefabName()
  return "Form_CastleStrongHoldMap"
end

return Form_CastleStrongHoldMapUI
