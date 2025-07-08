local Form_Activity101Lamia_ShardItemUI = class("Form_Activity101Lamia_ShardItemUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardItemUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardItemUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITEM
end

function Form_Activity101Lamia_ShardItemUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardItem"
end

return Form_Activity101Lamia_ShardItemUI
