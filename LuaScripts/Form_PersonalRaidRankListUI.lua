local Form_PersonalRaidRankListUI = class("Form_PersonalRaidRankListUI", require("UI/Common/UIBase"))

function Form_PersonalRaidRankListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidRankListUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDRANKLIST
end

function Form_PersonalRaidRankListUI:GetFramePrefabName()
  return "Form_PersonalRaidRankList"
end

return Form_PersonalRaidRankListUI
