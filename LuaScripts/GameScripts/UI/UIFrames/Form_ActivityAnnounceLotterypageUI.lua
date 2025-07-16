local Form_ActivityAnnounceLotterypageUI = class("Form_ActivityAnnounceLotterypageUI", require("UI/Common/UIBase"))

function Form_ActivityAnnounceLotterypageUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityAnnounceLotterypageUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYANNOUNCELOTTERYPAGE
end

function Form_ActivityAnnounceLotterypageUI:GetFramePrefabName()
  return "Form_ActivityAnnounceLotterypage"
end

return Form_ActivityAnnounceLotterypageUI
