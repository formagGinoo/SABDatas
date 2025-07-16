local Form_GachaTouchUI = class("Form_GachaTouchUI", require("UI/Common/UIBase"))

function Form_GachaTouchUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaTouchUI:GetID()
  return UIDefines.ID_FORM_GACHATOUCH
end

function Form_GachaTouchUI:GetFramePrefabName()
  return "Form_GachaTouch"
end

return Form_GachaTouchUI
