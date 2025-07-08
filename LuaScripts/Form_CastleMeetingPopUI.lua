local Form_CastleMeetingPopUI = class("Form_CastleMeetingPopUI", require("UI/Common/UIBase"))

function Form_CastleMeetingPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleMeetingPopUI:GetID()
  return UIDefines.ID_FORM_CASTLEMEETINGPOP
end

function Form_CastleMeetingPopUI:GetFramePrefabName()
  return "Form_CastleMeetingPop"
end

return Form_CastleMeetingPopUI
