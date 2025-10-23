local Form_Activity112Tast14UI = class("Form_Activity112Tast14UI", require("UI/Common/UIActivityTask14Base"))

function Form_Activity112Tast14UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112Tast14UI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112TAST14
end

function Form_Activity112Tast14UI:GetFramePrefabName()
  return "Form_Activity112Tast14"
end

return Form_Activity112Tast14UI
