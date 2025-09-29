local Form_MallMonthCardEndPopUI = class("Form_MallMonthCardEndPopUI", require("UI/Common/UIBase"))

function Form_MallMonthCardEndPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MallMonthCardEndPopUI:GetID()
  return UIDefines.ID_FORM_MALLMONTHCARDENDPOP
end

function Form_MallMonthCardEndPopUI:GetFramePrefabName()
  return "Form_MallMonthCardEndPop"
end

return Form_MallMonthCardEndPopUI
