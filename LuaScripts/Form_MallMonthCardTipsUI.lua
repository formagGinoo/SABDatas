local Form_MallMonthCardTipsUI = class("Form_MallMonthCardTipsUI", require("UI/Common/UIBase"))

function Form_MallMonthCardTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MallMonthCardTipsUI:GetID()
  return UIDefines.ID_FORM_MALLMONTHCARDTIPS
end

function Form_MallMonthCardTipsUI:GetFramePrefabName()
  return "Form_MallMonthCardTips"
end

return Form_MallMonthCardTipsUI
