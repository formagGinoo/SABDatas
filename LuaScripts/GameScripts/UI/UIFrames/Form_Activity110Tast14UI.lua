local Form_Activity110Tast14UI = class("Form_Activity110Tast14UI", require("UI/Common/UIActivityTask14Base"))

function Form_Activity110Tast14UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110Tast14UI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110TAST14
end

function Form_Activity110Tast14UI:GetFramePrefabName()
  return "Form_Activity110Tast14"
end

return Form_Activity110Tast14UI
