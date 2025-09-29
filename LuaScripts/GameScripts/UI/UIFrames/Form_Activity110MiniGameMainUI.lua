local Form_Activity110MiniGameMainUI = class("Form_Activity110MiniGameMainUI", require("UI/Common/UIBase"))

function Form_Activity110MiniGameMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110MiniGameMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110MINIGAMEMAIN
end

function Form_Activity110MiniGameMainUI:GetFramePrefabName()
  return "Form_Activity110MiniGameMain"
end

return Form_Activity110MiniGameMainUI
