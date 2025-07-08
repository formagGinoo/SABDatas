local Form_StageSelect_NewUI = class("Form_StageSelect_NewUI", require("UI/Common/UIBase"))

function Form_StageSelect_NewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_StageSelect_NewUI:GetID()
  return UIDefines.ID_FORM_STAGESELECT_NEW
end

function Form_StageSelect_NewUI:GetFramePrefabName()
  return "Form_StageSelect_New"
end

return Form_StageSelect_NewUI
