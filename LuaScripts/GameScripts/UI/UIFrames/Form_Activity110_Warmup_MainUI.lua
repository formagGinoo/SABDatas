local Form_Activity110_Warmup_MainUI = class("Form_Activity110_Warmup_MainUI", require("UI/Common/UIBase"))

function Form_Activity110_Warmup_MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_Warmup_MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_WARMUP_MAIN
end

function Form_Activity110_Warmup_MainUI:GetFramePrefabName()
  return "Form_Activity110_Warmup_Main"
end

return Form_Activity110_Warmup_MainUI
