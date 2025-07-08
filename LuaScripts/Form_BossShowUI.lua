local Form_BossShowUI = class("Form_BossShowUI", require("UI/Common/UIBase"))

function Form_BossShowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BossShowUI:GetID()
  return UIDefines.ID_FORM_BOSSSHOW
end

function Form_BossShowUI:GetFramePrefabName()
  return "Form_BossShow"
end

return Form_BossShowUI
