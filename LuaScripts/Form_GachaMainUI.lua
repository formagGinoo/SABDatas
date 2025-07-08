local Form_GachaMainUI = class("Form_GachaMainUI", require("UI/Common/UIBase"))

function Form_GachaMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaMainUI:GetID()
  return UIDefines.ID_FORM_GACHAMAIN
end

function Form_GachaMainUI:GetFramePrefabName()
  return "Form_GachaMain"
end

return Form_GachaMainUI
