local Form_BattleFlyText_TMP2UI = class("Form_BattleFlyText_TMP2UI", require("UI/Common/UIBase"))

function Form_BattleFlyText_TMP2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleFlyText_TMP2UI:GetID()
  return UIDefines.ID_FORM_BATTLEFLYTEXT_TMP2
end

function Form_BattleFlyText_TMP2UI:GetFramePrefabName()
  return "Form_BattleFlyText_TMP2"
end

return Form_BattleFlyText_TMP2UI
