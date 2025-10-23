local Form_GachaExchangePopUI = class("Form_GachaExchangePopUI", require("UI/Common/UIBase"))

function Form_GachaExchangePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaExchangePopUI:GetID()
  return UIDefines.ID_FORM_GACHAEXCHANGEPOP
end

function Form_GachaExchangePopUI:GetFramePrefabName()
  return "Form_GachaExchangePop"
end

return Form_GachaExchangePopUI
