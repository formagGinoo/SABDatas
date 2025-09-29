local UIItemBase = require("UI/Common/UIItemBase")
local UILoungeChangeHeroItem = class("UILoungeChangeHeroItem", UIItemBase)

function UILoungeChangeHeroItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UILoungeChangeHeroItem:OnFreshData()
  self.m_heroData = self.m_itemData
  UILuaHelper.SetActive(self.m_img_bg_select, self.m_heroData.isChoose)
  UILuaHelper.SetActive(self.m_img_blood, true)
  UILuaHelper.SetActive(self.m_txt_role, true)
  UILuaHelper.SetActive(self.m_pnl_unavailable, false)
  UILuaHelper.SetActive(self.m_img_lock, not self.m_heroData.isUnlock)
  ResourceUtil:CreateHeroHeadIcon(self.m_img_hero_Image, self.m_heroData.heroId)
  self.m_txt_role_Text.text = self.m_heroData.name
end

function UILoungeChangeHeroItem:RefreshChooseStatus(isChoose)
  UILuaHelper.SetActive(self.m_img_bg_select, isChoose)
end

function UILoungeChangeHeroItem:ChangeChooseStatus(isChoose)
  self.m_heroData.isChoose = isChoose
  self:RefreshChooseStatus(isChoose)
end

function UILoungeChangeHeroItem:OnBtntabrootClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

function UILoungeChangeHeroItem:dispose()
  UILoungeChangeHeroItem.super.dispose(self)
end

return UILoungeChangeHeroItem
