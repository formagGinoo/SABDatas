local Form_Activity101Lamia_ShardMemoryUI = class("Form_Activity101Lamia_ShardMemoryUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_ShardMemoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShardMemoryUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDMEMORY
end

function Form_Activity101Lamia_ShardMemoryUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ShardMemory"
end

return Form_Activity101Lamia_ShardMemoryUI
