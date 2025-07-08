local Form_AttractTimelineTransformUI = class("Form_AttractTimelineTransformUI", require("UI/Common/UIBase"))

function Form_AttractTimelineTransformUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractTimelineTransformUI:GetID()
  return UIDefines.ID_FORM_ATTRACTTIMELINETRANSFORM
end

function Form_AttractTimelineTransformUI:GetFramePrefabName()
  return "Form_AttractTimelineTransform"
end

return Form_AttractTimelineTransformUI
