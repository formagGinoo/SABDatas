local Form_HeroCampDetailUI = class("Form_HeroCampDetailUI", require("UI/Common/UIBase"))

function Form_HeroCampDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroCampDetailUI:GetID()
  return UIDefines.ID_FORM_HEROCAMPDETAIL
end

function Form_HeroCampDetailUI:GetFramePrefabName()
  return "Form_HeroCampDetail"
end

return Form_HeroCampDetailUI
