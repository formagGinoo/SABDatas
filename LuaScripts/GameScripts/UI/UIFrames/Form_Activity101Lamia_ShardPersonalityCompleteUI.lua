local Form_Activity101Lamia_ShardPersonalityCompleteUI = class("Form_Activity101Lamia_ShardPersonalityCompleteUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardPersonalityCompleteUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardPersonalityCompleteUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDPERSONALITYCOMPLETE
end

function Form_Activity101Lamia_ShardPersonalityCompleteUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardPersonalityComplete"
end

return Form_Activity101Lamia_ShardPersonalityCompleteUI
