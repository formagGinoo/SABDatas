local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroBondItem = class("UIHeroBondItem", UIItemBase)
local GlobalSettingIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local string_format = string.format
local MaxStageNum = 3

function UIHeroBondItem:OnInit()
  if self.m_FX_sg_opne then
    UILuaHelper.SetActive(self.m_FX_sg_opne, false)
  end
  if self.m_FX_electricity then
    UILuaHelper.SetActive(self.m_FX_electricity, false)
  end
end

function UIHeroBondItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self:FreshHeroBond(self.m_itemData)
  self:FreshBondActive(false)
end

function UIHeroBondItem:FreshHeroBond(bondData)
  if not bondData then
    return
  end
  local bondCfg = bondData.bondCfg
  local bondIconStr = bondCfg.m_Icon
  local bondStage = bondData.bondActiveStage
  UILuaHelper.SetAtlasSprite(self.m_img_icon_side_Image, HeroManager.BondStageBgPath[bondStage].bgPath)
  UILuaHelper.SetAtlasSprite(self.m_icon_bond_Image, bondIconStr .. "_1")
  UILuaHelper.SetAtlasSprite(self.m_icon_bond_b_Image, bondIconStr .. "_1")
  self.m_num_quantity_Text.text = self:GetBondHeroNum(bondData) or ""
  self:FreshHeroActiveStage(bondData)
  local isBondActive = 0 < bondStage
  UILuaHelper.SetActive(self.m_img_icon_side, isBondActive)
  UILuaHelper.SetActive(self.m_img_icon_num_bg, isBondActive)
  UILuaHelper.SetActive(self.m_img_icon_side_b, not isBondActive)
end

function UIHeroBondItem:GetBondHeroNum(bondData)
  if not bondData then
    return
  end
  local heroList = bondData.bondHeroList
  if not heroList then
    return
  end
  return #heroList
end

function UIHeroBondItem:FreshHeroActiveStage(bondData)
  if not bondData then
    return
  end
  local bondStage = bondData.bondActiveStage
  local bondEffectList = bondData.bondEffectCfgList or {}
  for i = 1, MaxStageNum do
    local bondEffectCfg = bondEffectList[i]
    if bondEffectCfg then
      UILuaHelper.SetActive(self["m_stage" .. i], true)
      local requirePeopleNum = bondEffectCfg.m_RequiredCount
      local isBondActive = bondStage == i
      UILuaHelper.SetActive(self["m_num" .. i], isBondActive)
      UILuaHelper.SetActive(self["m_num_a" .. i], not isBondActive)
      self[string_format("m_num%d_Text", i)].text = requirePeopleNum
      self[string_format("m_num_a%d_Text", i)].text = requirePeopleNum
    else
      UILuaHelper.SetActive(self["m_stage" .. i], false)
    end
  end
end

function UIHeroBondItem:FreshBondActive(isActive)
  UILuaHelper.SetActive(self.m_FX_sg_opne, isActive)
  UILuaHelper.SetActive(self.m_FX_electricity, isActive)
end

function UIHeroBondItem:OnBtnbondClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex)
  end
end

return UIHeroBondItem
