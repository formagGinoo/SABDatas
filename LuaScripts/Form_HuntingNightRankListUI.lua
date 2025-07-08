local Form_HuntingNightRankListUI = class("Form_HuntingNightRankListUI", require("UI/Common/UIBase"))

function Form_HuntingNightRankListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightRankListUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHTRANKLIST
end

function Form_HuntingNightRankListUI:GetFramePrefabName()
  return "Form_HuntingNightRankList"
end

return Form_HuntingNightRankListUI
