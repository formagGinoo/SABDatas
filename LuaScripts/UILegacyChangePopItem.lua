local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyChangePopItem = class("UILegacyChangePopItem", UIItemBase)

function UILegacyChangePopItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_hero_middle)
end

function UILegacyChangePopItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_changePopItemData = self.m_itemData
  self.m_HeroIcon:SetHeroData(self.m_changePopItemData.heroData.serverData)
  self.m_txt_power_Text.text = BigNumFormat(self.m_changePopItemData.heroData.serverData.iPower or 0)
  self:FreshLegacyShow()
end

function UILegacyChangePopItem:FreshLegacyShow()
  if not self.m_changePopItemData then
    return
  end
  UILuaHelper.SetActive(self.m_pnl_none_before, self.m_changePopItemData.beforeLegacyData == nil)
  UILuaHelper.SetActive(self.m_pnl_before, self.m_changePopItemData.beforeLegacyData ~= nil)
  if self.m_changePopItemData.beforeLegacyData ~= nil then
    UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_before_Image, self.m_changePopItemData.beforeLegacyData.legacyCfg.m_Icon)
    self.m_txt_lv_num_before_Text.text = self.m_changePopItemData.beforeLegacyData.serverData.iLevel
  end
  UILuaHelper.SetActive(self.m_pnl_none_after, self.m_changePopItemData.afterLegacyData == nil)
  UILuaHelper.SetActive(self.m_pnl_after, self.m_changePopItemData.afterLegacyData ~= nil)
  if self.m_changePopItemData.afterLegacyData ~= nil then
    UILuaHelper.SetAtlasSprite(self.m_img_legacy_icon_after_Image, self.m_changePopItemData.afterLegacyData.legacyCfg.m_Icon)
    self.m_txt_lv_num_after_Text.text = self.m_changePopItemData.afterLegacyData.serverData.iLevel
  end
end

return UILegacyChangePopItem
