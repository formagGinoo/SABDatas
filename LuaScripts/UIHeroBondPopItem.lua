local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroBondPopItem = class("UIHeroBondPopItem", UIItemBase)

function UIHeroBondPopItem:OnInit()
end

function UIHeroBondPopItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self:FreshHeroBond(self.m_itemData)
  self:FreshChooseUI(self.m_itemData.isChoose)
end

function UIHeroBondPopItem:FreshHeroBond(bondData)
  if not bondData then
    return
  end
  local bondCfg = bondData.bondCfg
  local bondIconStr = bondCfg.m_Icon
  local bondStage = bondData.bondActiveStage
  local isShowAllBond = bondData.isShowAllBond
  if isShowAllBond then
    UILuaHelper.SetAtlasSprite(self.m_img_icon_side_Image, HeroManager.BondStageBgPath.Normal.bgPath)
    UILuaHelper.SetActive(self.m_img_icon_side, true)
    UILuaHelper.SetActive(self.m_img_icon_num_bg, false)
    UILuaHelper.SetActive(self.m_img_icon_side_b, false)
  else
    UILuaHelper.SetAtlasSprite(self.m_img_icon_side_Image, HeroManager.BondStageBgPath[bondStage].bgPath)
    UILuaHelper.SetAtlasSprite(self.m_icon_bond_b_Image, bondIconStr .. "_1")
    local isBondActive = 0 < bondStage
    UILuaHelper.SetActive(self.m_img_icon_side, isBondActive)
    UILuaHelper.SetActive(self.m_img_icon_num_bg, isBondActive)
    UILuaHelper.SetActive(self.m_img_icon_side_b, not isBondActive)
    self.m_num_quantity_Text.text = self:GetBondHeroNum(bondData) or ""
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_bond_Image, bondIconStr .. "_1")
end

function UIHeroBondPopItem:GetBondHeroNum(bondData)
  if not bondData then
    return
  end
  local heroList = bondData.bondHeroList
  if not heroList then
    return
  end
  return #heroList
end

function UIHeroBondPopItem:FreshChoose(isChoose)
  self.m_itemData.isChoose = isChoose
  self:FreshChooseUI(self.m_itemData.isChoose)
end

function UIHeroBondPopItem:FreshChooseUI(isChoose)
  if isChoose == nil then
    isChoose = false
  end
  UILuaHelper.SetActive(self.m_icon_selected, isChoose)
end

function UIHeroBondPopItem:OnBtnbondClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex)
  end
end

return UIHeroBondPopItem
