local Form_PopupHero_TipsUI = class("Form_PopupHero_TipsUI", require("UI/Common/UIBase"))

function Form_PopupHero_TipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupHero_TipsUI:GetID()
  return UIDefines.ID_FORM_POPUPHERO_TIPS
end

function Form_PopupHero_TipsUI:GetFramePrefabName()
  return "Form_PopupHero_Tips"
end

return Form_PopupHero_TipsUI
