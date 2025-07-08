local Form_RankListMainUI = class("Form_RankListMainUI", require("UI/Common/UIBase"))

function Form_RankListMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RankListMainUI:GetID()
  return UIDefines.ID_FORM_RANKLISTMAIN
end

function Form_RankListMainUI:GetFramePrefabName()
  return "Form_RankListMain"
end

return Form_RankListMainUI
