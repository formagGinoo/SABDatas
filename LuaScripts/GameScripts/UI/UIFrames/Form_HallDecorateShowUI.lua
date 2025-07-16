local Form_HallDecorateShowUI = class("Form_HallDecorateShowUI", require("UI/Common/UIBase"))

function Form_HallDecorateShowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallDecorateShowUI:GetID()
  return UIDefines.ID_FORM_HALLDECORATESHOW
end

function Form_HallDecorateShowUI:GetFramePrefabName()
  return "Form_HallDecorateShow"
end

return Form_HallDecorateShowUI
