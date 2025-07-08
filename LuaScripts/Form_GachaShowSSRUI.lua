local Form_GachaShowSSRUI = class("Form_GachaShowSSRUI", require("UI/Common/UIBase"))

function Form_GachaShowSSRUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaShowSSRUI:GetID()
  return UIDefines.ID_FORM_GACHASHOWSSR
end

function Form_GachaShowSSRUI:GetFramePrefabName()
  return "Form_GachaShowSSR"
end

return Form_GachaShowSSRUI
