local Form_WhackMoleTipsUI = class("Form_WhackMoleTipsUI", require("UI/Common/UIBase"))

function Form_WhackMoleTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleTipsUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLETIPS
end

function Form_WhackMoleTipsUI:GetFramePrefabName()
  return "Form_WhackMoleTips"
end

return Form_WhackMoleTipsUI
