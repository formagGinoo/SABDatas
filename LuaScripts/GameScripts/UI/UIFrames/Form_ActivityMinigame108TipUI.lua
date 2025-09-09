local Form_ActivityMinigame108TipUI = class("Form_ActivityMinigame108TipUI", require("UI/Common/UIBase"))

function Form_ActivityMinigame108TipUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMinigame108TipUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMINIGAME108TIP
end

function Form_ActivityMinigame108TipUI:GetFramePrefabName()
  return "Form_ActivityMinigame108Tip"
end

return Form_ActivityMinigame108TipUI
