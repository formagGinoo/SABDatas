local Form_BattleRecordUI = class("Form_BattleRecordUI", require("UI/Common/UIBase"))

function Form_BattleRecordUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleRecordUI:GetID()
  return UIDefines.ID_FORM_BATTLERECORD
end

function Form_BattleRecordUI:GetFramePrefabName()
  return "Form_BattleRecord"
end

return Form_BattleRecordUI
