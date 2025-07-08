local Form_WhackMoleLevelSelectUI = class("Form_WhackMoleLevelSelectUI", require("UI/Common/UIBase"))

function Form_WhackMoleLevelSelectUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_WhackMoleLevelSelectUI:GetID()
  return UIDefines.ID_FORM_WHACKMOLELEVELSELECT
end

function Form_WhackMoleLevelSelectUI:GetFramePrefabName()
  return "Form_WhackMoleLevelSelect"
end

return Form_WhackMoleLevelSelectUI
