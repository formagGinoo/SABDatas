local Form_CastleEventPopUI = class("Form_CastleEventPopUI", require("UI/Common/UIBase"))

function Form_CastleEventPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleEventPopUI:GetID()
  return UIDefines.ID_FORM_CASTLEEVENTPOP
end

function Form_CastleEventPopUI:GetFramePrefabName()
  return "Form_CastleEventPop"
end

return Form_CastleEventPopUI
