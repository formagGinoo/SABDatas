local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyLevelGuideItem = class("UILegacyLevelGuideItem", UIItemBase)
local LegacyInAnimStr = "Activity_Guide_legacy_in"
local LegacyInGreyAnimStr = "Activity_Guide_legacygrey_in"

function UILegacyLevelGuideItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_buttonLegacyEx = self.m_btn_Legacy:GetComponent("ButtonExtensions")
  if self.m_buttonLegacyEx then
    self.m_buttonLegacyEx.Clicked = handler(self, self.OnBtnLegacyClicked)
  end
  self.m_buttonLegacyGreyEx = self.m_btn_Legacy_Grey:GetComponent("ButtonExtensions")
  if self.m_buttonLegacyGreyEx then
    self.m_buttonLegacyGreyEx.Clicked = handler(self, self.OnBtnLegacyGreyClicked)
  end
end

function UILegacyLevelGuideItem:OnFreshData()
  self.m_legacyGuideData = self.m_itemData
  self:FreshItemUI()
  self:RegisterOrUpdateRedDotItem(self.m_legacy_red_dot, RedDotDefine.ModuleType.LegacyGuideNode, self.m_legacyGuideData.legacyGuideData.legacyCfg.m_ID)
end

function UILegacyLevelGuideItem:FreshItemUI()
  if not self.m_legacyGuideData then
    return
  end
  UILuaHelper.SetActive(self.m_pnl_legacy, self.m_legacyGuideData.isHave)
  UILuaHelper.SetActive(self.m_pnl_legacygrey, not self.m_legacyGuideData.isHave)
  if self.m_legacyGuideData.isHave then
    self:FreshLegacyNormal()
  else
    self:FreshLegacyGrey()
  end
end

function UILegacyLevelGuideItem:FreshLegacyNormal()
  if not self.m_legacyGuideData then
    return
  end
  local legacyCfg = self.m_legacyGuideData.legacyGuideData.legacyCfg
  UILuaHelper.SetAtlasSprite(self.m_icon_legacy_Image, legacyCfg.m_Icon)
  local legacyData = LegacyManager:GetLegacyDataByID(legacyCfg.m_ID) or {}
  local legacyServerData = legacyData.serverData or {}
  local legacyLv = legacyServerData.iLevel or 0
  self.m_txt_levelnum_Text.text = string.format(ConfigManager:GetCommonTextById(20033), legacyLv)
  self.m_txt_numlegacy_Text.text = self.m_legacyGuideData.legacyGuideData.legacyChapterCfg.m_mChapterName
  self.m_txt_legacyname_Text.text = legacyCfg.m_mName
end

function UILegacyLevelGuideItem:FreshLegacyGrey()
  if not self.m_legacyGuideData then
    return
  end
  local legacyCfg = self.m_legacyGuideData.legacyGuideData.legacyCfg
  UILuaHelper.SetAtlasSprite(self.m_icon_legacygrey_Image, legacyCfg.m_UnlockIcon)
  self.m_txt_numlegacygrey_Text.text = self.m_legacyGuideData.legacyGuideData.legacyChapterCfg.m_mChapterName
  self.m_txt_legacynone_Text.text = legacyCfg.m_mName
end

function UILegacyLevelGuideItem:PlayAnim()
  if not self.m_legacyGuideData then
    return
  end
  if self.m_legacyGuideData.isHave then
    UILuaHelper.PlayAnimationByName(self.m_pnl_legacy, LegacyInAnimStr)
  else
    UILuaHelper.PlayAnimationByName(self.m_pnl_legacygrey, LegacyInGreyAnimStr)
  end
end

function UILegacyLevelGuideItem:OnBtnLegacyClicked()
  if not self.m_legacyGuideData then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

function UILegacyLevelGuideItem:OnBtnLegacyGreyClicked()
  if not self.m_legacyGuideData then
    return
  end
  local legacyCfg = self.m_legacyGuideData.legacyGuideData.legacyCfg
  utils.openItemDetailPop({
    iID = legacyCfg.m_ID,
    iNum = 1
  })
end

return UILegacyLevelGuideItem
