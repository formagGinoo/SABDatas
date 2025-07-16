local Form_Activity101Lamia_ShardTableUI = class("Form_Activity101Lamia_ShardTableUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardTableUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardTableUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDTABLE
end

function Form_Activity101Lamia_ShardTableUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardTable"
end

return Form_Activity101Lamia_ShardTableUI
