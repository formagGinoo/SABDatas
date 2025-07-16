local Form_Activity101Lamia_ShardITipsUI = class("Form_Activity101Lamia_ShardITipsUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardITipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardITipsUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITIPS
end

function Form_Activity101Lamia_ShardITipsUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardITips"
end

return Form_Activity101Lamia_ShardITipsUI
