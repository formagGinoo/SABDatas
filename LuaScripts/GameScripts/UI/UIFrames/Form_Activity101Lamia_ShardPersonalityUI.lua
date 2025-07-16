local Form_Activity101Lamia_ShardPersonalityUI = class("Form_Activity101Lamia_ShardPersonalityUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardPersonalityUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardPersonalityUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDPERSONALITY
end

function Form_Activity101Lamia_ShardPersonalityUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardPersonality"
end

return Form_Activity101Lamia_ShardPersonalityUI
