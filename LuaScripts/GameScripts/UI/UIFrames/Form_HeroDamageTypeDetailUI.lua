local Form_HeroDamageTypeDetailUI = class("Form_HeroDamageTypeDetailUI", require("UI/Common/UIBase"))

function Form_HeroDamageTypeDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroDamageTypeDetailUI:GetID()
  return UIDefines.ID_FORM_HERODAMAGETYPEDETAIL
end

function Form_HeroDamageTypeDetailUI:GetFramePrefabName()
  return "Form_HeroDamageTypeDetail"
end

return Form_HeroDamageTypeDetailUI
