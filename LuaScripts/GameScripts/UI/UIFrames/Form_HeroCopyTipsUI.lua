local Form_HeroCopyTipsUI = class("Form_HeroCopyTipsUI", require("UI/Common/UIBase"))

function Form_HeroCopyTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroCopyTipsUI:GetID()
  return UIDefines.ID_FORM_HEROCOPYTIPS
end

function Form_HeroCopyTipsUI:GetFramePrefabName()
  return "Form_HeroCopyTips"
end

return Form_HeroCopyTipsUI
