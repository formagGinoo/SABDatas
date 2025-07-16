local Form_CastleEventStoryUI = class("Form_CastleEventStoryUI", require("UI/Common/UIBase"))

function Form_CastleEventStoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleEventStoryUI:GetID()
  return UIDefines.ID_FORM_CASTLEEVENTSTORY
end

function Form_CastleEventStoryUI:GetFramePrefabName()
  return "Form_CastleEventStory"
end

return Form_CastleEventStoryUI
