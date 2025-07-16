local Form_AttractMailPop1UI = class("Form_AttractMailPop1UI", require("UI/Common/UIBase"))

function Form_AttractMailPop1UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractMailPop1UI:GetID()
  return UIDefines.ID_FORM_ATTRACTMAILPOP1
end

function Form_AttractMailPop1UI:GetFramePrefabName()
  return "Form_AttractMailPop1"
end

return Form_AttractMailPop1UI
