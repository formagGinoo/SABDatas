local Form_Activity101Lamia_ShardSelectUI = class("Form_Activity101Lamia_ShardSelectUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardSelectUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardSelectUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDSELECT
end

function Form_Activity101Lamia_ShardSelectUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardSelect"
end

return Form_Activity101Lamia_ShardSelectUI
