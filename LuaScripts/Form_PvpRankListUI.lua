local Form_PvpRankListUI = class("Form_PvpRankListUI", require("UI/Common/UIBase"))

function Form_PvpRankListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpRankListUI:GetID()
  return UIDefines.ID_FORM_PVPRANKLIST
end

function Form_PvpRankListUI:GetFramePrefabName()
  return "Form_PvpRankList"
end

return Form_PvpRankListUI
