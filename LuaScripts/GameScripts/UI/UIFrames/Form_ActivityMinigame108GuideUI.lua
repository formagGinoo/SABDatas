local Form_ActivityMinigame108GuideUI = class("Form_ActivityMinigame108GuideUI", require("UI/Common/UIBase"))

function Form_ActivityMinigame108GuideUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMinigame108GuideUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMINIGAME108GUIDE
end

function Form_ActivityMinigame108GuideUI:GetFramePrefabName()
  return "Form_ActivityMinigame108Guide"
end

return Form_ActivityMinigame108GuideUI
