local UIItemBase = require("UI/Common/UIItemBase")
local UIPopUpBondHeroItem = class("UIPopUpBondHeroItem", UIItemBase)
local InGamePresentationIns = ConfigManager:GetConfigInsByName("Presentation")

function UIPopUpBondHeroItem:OnInit()
  self.m_btnEx = self.m_btn_Hero_Item:GetComponent("ButtonExtensions")
  if self.m_btnEx then
    self.m_btnEx.Clicked = handler(self, self.OnBtnHeroItemClicked)
  end
end

function UIPopUpBondHeroItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self:FreshHero(self.m_itemData.heroCfg)
  local imgBgSelected = self.m_itemTemplateCache:Image("c_img_bg_selected")
  local isShowAllBond = self.m_itemData.isShowAllBond
  if isShowAllBond then
    UILuaHelper.SetActive(imgBgSelected, false)
    UILuaHelper.SetActive(self.m_z_txt_have, false)
  else
    local isActive = self.m_itemData.isActive
    UILuaHelper.SetActive(imgBgSelected, isActive)
    UILuaHelper.SetActive(self.m_z_txt_have, isActive)
  end
  local isHave = self.m_itemData.isHave
  local alpha = isHave and 1 or 0.6
  UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, alpha)
  UILuaHelper.SetActive(self.m_z_txt_notobtained, not isHave)
end

function UIPopUpBondHeroItem:FreshHero(heroCfg)
  if not heroCfg then
    return
  end
  self:FreshHeadIcon(heroCfg.m_PerformanceID[0])
  self:FreshQuality(heroCfg.m_Quality)
end

function UIPopUpBondHeroItem:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = InGamePresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if not presentationData.m_UIkeyword then
    return
  end
  local imgHead = self.m_itemTemplateCache:Image("c_img_head")
  if imgHead then
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(imgHead, szIcon)
  end
end

function UIPopUpBondHeroItem:FreshQuality(qualityNum)
  if not qualityNum then
    return
  end
  local pathData = QualityPathCfg[qualityNum]
  local imgHeroBorder = self.m_itemTemplateCache:Image("c_img_border")
  if imgHeroBorder then
    UILuaHelper.SetAtlasSprite(imgHeroBorder, pathData.borderImgPath)
  end
end

function UIPopUpBondHeroItem:OnBtnHeroItemClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex)
  end
end

return UIPopUpBondHeroItem
