local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyLevelDetailHeroItem = class("UILegacyLevelDetailHeroItem", UIItemBase)
local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local AnimStr = "LegacyActivity_item_in"

function UILegacyLevelDetailHeroItem:OnInit()
  self.m_isUnlock = nil
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UILegacyLevelDetailHeroItem:OnFreshData()
  self.m_legacyStageCharacterCfg = self.m_itemData
  self:FreshItemUI()
end

function UILegacyLevelDetailHeroItem:FreshItemUI()
  if not self.m_legacyStageCharacterCfg then
    return
  end
  self:FreshQualityBorder(self.m_legacyStageCharacterCfg.m_Quality)
  self:FreshHeadIcon(self.m_legacyStageCharacterCfg.m_Presentation)
  self:FreshHeroName(self.m_legacyStageCharacterCfg.m_mName)
end

function UILegacyLevelDetailHeroItem:FreshQualityBorder(quality)
  if not quality then
    return
  end
  local pathData = QualityPathCfg[quality]
  if pathData then
    if self.m_img_border_Image then
      UILuaHelper.SetAtlasSprite(self.m_img_border_Image, pathData.borderImgPath)
    end
    if self.m_img_border2_Image then
      UILuaHelper.SetAtlasSprite(self.m_img_border2_Image, pathData.borderImgPath)
    end
  end
end

function UILegacyLevelDetailHeroItem:FreshHeadIcon(performanceID)
  if not performanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  if self.m_img_head_Image then
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(self.m_img_head_Image, szIcon)
  end
end

function UILegacyLevelDetailHeroItem:FreshHeroName(nameStr)
  if not nameStr then
    return
  end
  self.m_txt_hero_name_Text.text = nameStr
end

function UILegacyLevelDetailHeroItem:PlayAnim()
  UILuaHelper.PlayAnimationByName(self.m_common_hero_middle, AnimStr)
end

function UILegacyLevelDetailHeroItem:OnBtnIconClicked()
  if not self.m_legacyStageCharacterCfg then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UILegacyLevelDetailHeroItem
