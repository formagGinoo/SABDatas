local Form_LoungeHeroChangeUI = class("Form_LoungeHeroChangeUI", require("UI/Common/UIBase"))

function Form_LoungeHeroChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeHeroChangeUI:GetID()
  return UIDefines.ID_FORM_LOUNGEHEROCHANGE
end

function Form_LoungeHeroChangeUI:GetFramePrefabName()
  return "Form_LoungeHeroChange"
end

return Form_LoungeHeroChangeUI
