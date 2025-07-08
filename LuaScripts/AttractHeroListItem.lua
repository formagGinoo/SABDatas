local UIItemBase = require("UI/Common/UIItemBase")
local AttractHeroListItem = class("AttractHeroListItem", UIItemBase)

function AttractHeroListItem:OnInit()
  self.c_img_bg_selected = self.m_itemTemplateCache:GameObject("c_img_bg_selected")
  self.c_img_head_Image = self.m_itemTemplateCache:Image("c_img_head")
  self.c_txt_attract_lv_num_Text = self.m_itemTemplateCache:TMPPro("c_txt_attract_lv_num")
  self.c_btnClick = self.m_itemTemplateCache:GameObject("c_btnClick"):GetComponent("ButtonExtensions")
  self.c_btnClick.Clicked = handler(self, self.OnHeroItemClick)
  self.c_red = self.m_itemTemplateCache:GameObject("c_reddot")
end

function AttractHeroListItem:OnFreshData()
  local heroData = self.m_itemData
  self.m_itemRootObj.name = self.m_itemIndex
  self.c_img_bg_selected:SetActive(heroData.bIsAttractSelected)
  ResourceUtil:CreateHeroIcon(self.c_img_head_Image, heroData.serverData.iHeroId)
  self.c_txt_attract_lv_num_Text.text = heroData.serverData.iAttractRank
  self:RegisterOrUpdateRedDotItem(self.c_red, RedDotDefine.ModuleType.AttractBiographyEntry, heroData.serverData.iHeroId)
end

function AttractHeroListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
end

return AttractHeroListItem
