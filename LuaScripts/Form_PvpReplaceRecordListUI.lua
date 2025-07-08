local Form_PvpReplaceRecordListUI = class("Form_PvpReplaceRecordListUI", require("UI/Common/UIBase"))

function Form_PvpReplaceRecordListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceRecordListUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACERECORDLIST
end

function Form_PvpReplaceRecordListUI:GetFramePrefabName()
  return "Form_PvpReplaceRecordList"
end

return Form_PvpReplaceRecordListUI
