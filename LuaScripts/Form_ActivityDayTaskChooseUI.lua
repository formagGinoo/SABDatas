local Form_ActivityDayTaskChooseUI = class("Form_ActivityDayTaskChooseUI", require("UI/Common/UIBase"))

function Form_ActivityDayTaskChooseUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityDayTaskChooseUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYDAYTASKCHOOSE
end

function Form_ActivityDayTaskChooseUI:GetFramePrefabName()
  return "Form_ActivityDayTaskChoose"
end

return Form_ActivityDayTaskChooseUI
