local Form_MaterialsRewardPopUI = class("Form_MaterialsRewardPopUI", require("UI/Common/UIBase"))

function Form_MaterialsRewardPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MaterialsRewardPopUI:GetID()
  return UIDefines.ID_FORM_MATERIALSREWARDPOP
end

function Form_MaterialsRewardPopUI:GetFramePrefabName()
  return "Form_MaterialsRewardPop"
end

return Form_MaterialsRewardPopUI
