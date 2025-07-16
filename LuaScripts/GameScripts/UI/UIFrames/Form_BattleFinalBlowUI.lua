local Form_BattleFinalBlowUI = class("Form_BattleFinalBlowUI", require("UI/Common/UIBase"))

function Form_BattleFinalBlowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleFinalBlowUI:GetID()
  return UIDefines.ID_FORM_BATTLEFINALBLOW
end

function Form_BattleFinalBlowUI:GetFramePrefabName()
  return "Form_BattleFinalBlow"
end

return Form_BattleFinalBlowUI
