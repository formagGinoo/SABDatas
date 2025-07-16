local Form_GameSceneLoadingUI = class("Form_GameSceneLoadingUI", require("UI/Common/UIBase"))

function Form_GameSceneLoadingUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GameSceneLoadingUI:GetID()
  return UIDefines.ID_FORM_GAMESCENELOADING
end

function Form_GameSceneLoadingUI:GetFramePrefabName()
  return "Form_GameSceneLoading"
end

return Form_GameSceneLoadingUI
