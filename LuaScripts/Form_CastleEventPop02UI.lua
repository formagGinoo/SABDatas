local Form_CastleEventPop02UI = class("Form_CastleEventPop02UI", require("UI/Common/UIBase"))

function Form_CastleEventPop02UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleEventPop02UI:GetID()
  return UIDefines.ID_FORM_CASTLEEVENTPOP02
end

function Form_CastleEventPop02UI:GetFramePrefabName()
  return "Form_CastleEventPop02"
end

return Form_CastleEventPop02UI
