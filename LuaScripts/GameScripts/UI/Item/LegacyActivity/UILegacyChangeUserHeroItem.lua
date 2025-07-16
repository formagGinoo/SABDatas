local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyChangeUserHeroItem = class("UILegacyChangeUserHeroItem", UIItemBase)

function UILegacyChangeUserHeroItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemTemplateCache:GameObject("c_common_hero_middle"))
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
  self.m_isSelected = false
end

function UILegacyChangeUserHeroItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_isSelected = self.m_itemData.isChoose
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, self.m_isSelected, nil, true)
  self:FreshChooseStatus()
  self:FreshLegacyShow()
end

function UILegacyChangeUserHeroItem:FreshChooseStatus()
  if not self.m_HeroIcon then
    return
  end
  self.m_HeroIcon:SetSelected(self.m_isSelected)
end

function UILegacyChangeUserHeroItem:FreshLegacyShow()
  if not self.m_itemData then
    return
  end
  local heroServerData = self.m_itemData.serverData
  local legacyTab = heroServerData.stLegacy or {}
  local legacyID = legacyTab.iLegacyId
  local legacyData = LegacyManager:GetLegacyDataByID(legacyID)
  UILuaHelper.SetActive(self.m_pnl_legacy, legacyData ~= nil)
  if legacyData then
    UILuaHelper.SetAtlasSprite(self.m_icon_legacy_Image, legacyData.legacyCfg.m_Icon)
  end
end

function UILegacyChangeUserHeroItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

function UILegacyChangeUserHeroItem:ChangeChooseItem(flag)
  self.m_isSelected = flag
  self.m_itemData.isChoose = flag
  self:FreshChooseStatus()
end

return UILegacyChangeUserHeroItem
