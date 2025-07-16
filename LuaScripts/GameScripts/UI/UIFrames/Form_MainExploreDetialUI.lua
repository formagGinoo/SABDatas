local Form_MainExploreDetialUI = class("Form_MainExploreDetialUI", require("UI/Common/UIBase"))

function Form_MainExploreDetialUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainExploreDetialUI:GetID()
  return UIDefines.ID_FORM_MAINEXPLOREDETIAL
end

function Form_MainExploreDetialUI:GetFramePrefabName()
  return "Form_MainExploreDetial"
end

return Form_MainExploreDetialUI
