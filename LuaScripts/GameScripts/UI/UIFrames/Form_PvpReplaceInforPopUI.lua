local Form_PvpReplaceInforPopUI = class("Form_PvpReplaceInforPopUI", require("UI/Common/UIBase"))

function Form_PvpReplaceInforPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceInforPopUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEINFORPOP
end

function Form_PvpReplaceInforPopUI:GetFramePrefabName()
  return "Form_PvpReplaceInforPop"
end

return Form_PvpReplaceInforPopUI
