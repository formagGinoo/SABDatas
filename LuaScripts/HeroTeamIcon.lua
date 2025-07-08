local HeroTeamIcon = class("HeroTeamIcon", require("UI/Widgets/HeroIcon"))

function HeroTeamIcon:InitComponents()
  HeroTeamIcon.super.InitComponents(self)
  local c_img_maskObj = self.m_goRootTrans:Find("c_battle_card/c_img_mask")
  if c_img_maskObj then
    self.m_img_maskObj = c_img_maskObj:GetComponent(T_Image)
  end
  local border2Obj = self.m_goRootTrans:Find("c_battle_card/c_img_border2")
  if border2Obj then
    self.m_img_border2 = border2Obj:GetComponent(T_Image)
  end
  local c_img_hero_mask = self.m_goRootTrans:Find("c_img_hero_mask")
  if c_img_hero_mask then
    c_img_hero_mask.gameObject:SetActive(false)
    self.c_img_hero_mask = c_img_hero_mask
  end
end

function HeroTeamIcon:FreshQuality(qualityNum)
  if not qualityNum then
    return
  end
  local pathData = QualityPathCfg[qualityNum]
  if pathData then
    if self.m_img_border then
      UILuaHelper.SetAtlasSprite(self.m_img_border, pathData.borderImgTeamPath)
    end
    if self.m_img_border2 then
      UILuaHelper.SetAtlasSprite(self.m_img_border2, pathData.borderImgTeamPath)
    end
    if self.m_img_maskObj then
      UILuaHelper.SetAtlasSprite(self.m_img_maskObj, pathData.teamImgMask)
    end
  end
end

function HeroTeamIcon:SetTeamSelected(bSelected)
  if self.c_img_hero_mask then
    self.c_img_hero_mask.gameObject:SetActive(bSelected)
  end
end

return HeroTeamIcon
