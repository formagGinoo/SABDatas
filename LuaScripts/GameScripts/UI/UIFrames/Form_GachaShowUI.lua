local Form_GachaShowUI = class("Form_GachaShowUI", require("UI/Common/UIBase"))

function Form_GachaShowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaShowUI:GetID()
  return UIDefines.ID_FORM_GACHASHOW
end

function Form_GachaShowUI:GetFramePrefabName()
  return "Form_GachaShow"
end

return Form_GachaShowUI
