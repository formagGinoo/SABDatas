local UIItemBase = require("UI/Common/UIItemBase")
local LetterHeroListItem = class("LetterHeroListItem", UIItemBase)

function LetterHeroListItem:OnInit()
  self.c_btnClick = self.m_itemRootObj:GetComponent("ButtonExtensions")
  self.c_btnClick.Clicked = handler(self, self.OnHeroItemClick)
end

function LetterHeroListItem:OnFreshData()
  local heroData = self.m_itemData.heroData
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_btn_head_select:SetActive(self.m_itemData.bIsLetterSelected)
  ResourceUtil:CreateHeroIcon(self.m_head_tab_icon_Image, heroData.serverData.iHeroId)
  self.m_head_redpoint:SetActive(false)
  self.m_itemRootObj.transform.localRotation = Vector3.zero
end

function LetterHeroListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
end

return LetterHeroListItem
