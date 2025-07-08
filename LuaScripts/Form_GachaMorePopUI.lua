local Form_GachaMorePopUI = class("Form_GachaMorePopUI", require("UI/Common/UIBase"))

function Form_GachaMorePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaMorePopUI:GetID()
  return UIDefines.ID_FORM_GACHAMOREPOP
end

function Form_GachaMorePopUI:GetFramePrefabName()
  return "Form_GachaMorePop"
end

return Form_GachaMorePopUI
