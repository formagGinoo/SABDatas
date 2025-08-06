local Form_Activity105PlotclockUI = class("Form_Activity105PlotclockUI", require("UI/Common/UIBase"))

function Form_Activity105PlotclockUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105PlotclockUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105PLOTCLOCK
end

function Form_Activity105PlotclockUI:GetFramePrefabName()
  return "Form_Activity105Plotclock"
end

return Form_Activity105PlotclockUI
