local Form_PvpReplaceRankListUI = class("Form_PvpReplaceRankListUI", require("UI/Common/UIBase"))

function Form_PvpReplaceRankListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceRankListUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACERANKLIST
end

function Form_PvpReplaceRankListUI:GetFramePrefabName()
  return "Form_PvpReplaceRankList"
end

return Form_PvpReplaceRankListUI
