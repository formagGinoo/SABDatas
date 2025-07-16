local Form_PvpRecordListUI = class("Form_PvpRecordListUI", require("UI/Common/UIBase"))

function Form_PvpRecordListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpRecordListUI:GetID()
  return UIDefines.ID_FORM_PVPRECORDLIST
end

function Form_PvpRecordListUI:GetFramePrefabName()
  return "Form_PvpRecordList"
end

return Form_PvpRecordListUI
