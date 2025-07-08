local Form_HuntingNightBuffChooseUI = class("Form_HuntingNightBuffChooseUI", require("UI/Common/UIBase"))

function Form_HuntingNightBuffChooseUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightBuffChooseUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHTBUFFCHOOSE
end

function Form_HuntingNightBuffChooseUI:GetFramePrefabName()
  return "Form_HuntingNightBuffChoose"
end

return Form_HuntingNightBuffChooseUI
