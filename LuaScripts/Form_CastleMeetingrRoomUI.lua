local Form_CastleMeetingrRoomUI = class("Form_CastleMeetingrRoomUI", require("UI/Common/UIBase"))

function Form_CastleMeetingrRoomUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleMeetingrRoomUI:GetID()
  return UIDefines.ID_FORM_CASTLEMEETINGRROOM
end

function Form_CastleMeetingrRoomUI:GetFramePrefabName()
  return "Form_CastleMeetingrRoom"
end

return Form_CastleMeetingrRoomUI
