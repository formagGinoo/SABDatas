local Form_CirculationCareerHeroListUI = class("Form_CirculationCareerHeroListUI", require("UI/Common/UIBase"))

function Form_CirculationCareerHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationCareerHeroListUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST
end

function Form_CirculationCareerHeroListUI:GetFramePrefabName()
  return "Form_CirculationCareerHeroList"
end

return Form_CirculationCareerHeroListUI
