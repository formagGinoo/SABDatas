local Form_Activity106Tast14UI = class("Form_Activity106Tast14UI", require("UI/Common/UIBase"))

function Form_Activity106Tast14UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity106Tast14UI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106TAST14
end

function Form_Activity106Tast14UI:GetFramePrefabName()
  return "Form_Activity106Tast14"
end

return Form_Activity106Tast14UI
