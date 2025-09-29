local Form_Activity110_Warmup_VictoryUI = class("Form_Activity110_Warmup_VictoryUI", require("UI/Common/UIBase"))

function Form_Activity110_Warmup_VictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_Warmup_VictoryUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_WARMUP_VICTORY
end

function Form_Activity110_Warmup_VictoryUI:GetFramePrefabName()
  return "Form_Activity110_Warmup_Victory"
end

return Form_Activity110_Warmup_VictoryUI
