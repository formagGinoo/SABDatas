local Form_HeroEquipReplacePopUI = class("Form_HeroEquipReplacePopUI", require("UI/Common/UIBase"))

function Form_HeroEquipReplacePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroEquipReplacePopUI:GetID()
  return UIDefines.ID_FORM_HEROEQUIPREPLACEPOP
end

function Form_HeroEquipReplacePopUI:GetFramePrefabName()
  return "Form_HeroEquipReplacePop"
end

return Form_HeroEquipReplacePopUI
