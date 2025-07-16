local Form_Activity102Dalcaro_CommonTipsUI = class("Form_Activity102Dalcaro_CommonTipsUI", require("UI/Common/UIBase"))

function Form_Activity102Dalcaro_CommonTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_CommonTipsUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_COMMONTIPS
end

function Form_Activity102Dalcaro_CommonTipsUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_CommonTips"
end

return Form_Activity102Dalcaro_CommonTipsUI
