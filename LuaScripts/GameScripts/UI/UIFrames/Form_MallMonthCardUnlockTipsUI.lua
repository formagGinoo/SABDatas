local Form_MallMonthCardUnlockTipsUI = class("Form_MallMonthCardUnlockTipsUI", require("UI/Common/UIBase"))

function Form_MallMonthCardUnlockTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MallMonthCardUnlockTipsUI:GetID()
  return UIDefines.ID_FORM_MALLMONTHCARDUNLOCKTIPS
end

function Form_MallMonthCardUnlockTipsUI:GetFramePrefabName()
  return "Form_MallMonthCardUnlockTips"
end

return Form_MallMonthCardUnlockTipsUI
