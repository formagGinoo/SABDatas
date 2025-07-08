local Form_HallDecorateUI = class("Form_HallDecorateUI", require("UI/Common/UIBase"))

function Form_HallDecorateUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallDecorateUI:GetID()
  return UIDefines.ID_FORM_HALLDECORATE
end

function Form_HallDecorateUI:GetFramePrefabName()
  return "Form_HallDecorate"
end

return Form_HallDecorateUI
