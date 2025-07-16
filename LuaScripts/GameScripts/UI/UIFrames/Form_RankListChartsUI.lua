local Form_RankListChartsUI = class("Form_RankListChartsUI", require("UI/Common/UIBase"))

function Form_RankListChartsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RankListChartsUI:GetID()
  return UIDefines.ID_FORM_RANKLISTCHARTS
end

function Form_RankListChartsUI:GetFramePrefabName()
  return "Form_RankListCharts"
end

return Form_RankListChartsUI
