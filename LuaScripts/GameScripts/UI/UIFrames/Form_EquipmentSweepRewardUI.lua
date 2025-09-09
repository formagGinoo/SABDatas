local Form_EquipmentSweepRewardUI = class("Form_EquipmentSweepRewardUI", require("UI/Common/UIBase"))

function Form_EquipmentSweepRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentSweepRewardUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTSWEEPREWARD
end

function Form_EquipmentSweepRewardUI:GetFramePrefabName()
  return "Form_EquipmentSweepReward"
end

return Form_EquipmentSweepRewardUI
