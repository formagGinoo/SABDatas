local UIItemBase = require("UI/Common/UIItemBase")
local UIAttractAbilityItem = class("UIAttractAbilityItem", UIItemBase)

function UIAttractAbilityItem:OnInit()
end

function UIAttractAbilityItem:OnFreshData()
  local attrInfo = self.m_itemData
  ResourceUtil:CreatePropertyImg(self.m_ability1_Image, attrInfo.id)
  self.m_txt_ability_name_Text.text = tostring(attrInfo.cfg.m_mCNName)
  self.m_txt_ability_Text.text = tostring(attrInfo.num)
end

function UIAttractAbilityItem:dispose()
  UIAttractAbilityItem.super.dispose(self)
end

return UIAttractAbilityItem
