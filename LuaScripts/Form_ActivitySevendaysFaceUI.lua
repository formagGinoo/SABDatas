local Form_ActivitySevendaysFaceUI = class("Form_ActivitySevendaysFaceUI", require("UI/Common/UIBase"))

function Form_ActivitySevendaysFaceUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivitySevendaysFaceUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE
end

function Form_ActivitySevendaysFaceUI:GetFramePrefabName()
  return "Form_ActivitySevendaysFace"
end

return Form_ActivitySevendaysFaceUI
