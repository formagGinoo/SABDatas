local Form_HeroEquipTypeDetailUI = class("Form_HeroEquipTypeDetailUI", require("UI/Common/UIBase"))

function Form_HeroEquipTypeDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroEquipTypeDetailUI:GetID()
  return UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL
end

function Form_HeroEquipTypeDetailUI:GetFramePrefabName()
  return "Form_HeroEquipTypeDetail"
end

return Form_HeroEquipTypeDetailUI
