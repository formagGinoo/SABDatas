local Form_BossEquipmentPartRewardUI = class("Form_BossEquipmentPartRewardUI", require("UI/Common/UIBase"))

function Form_BossEquipmentPartRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BossEquipmentPartRewardUI:GetID()
  return UIDefines.ID_FORM_BOSSEQUIPMENTPARTREWARD
end

function Form_BossEquipmentPartRewardUI:GetFramePrefabName()
  return "Form_BossEquipmentPartReward"
end

return Form_BossEquipmentPartRewardUI
