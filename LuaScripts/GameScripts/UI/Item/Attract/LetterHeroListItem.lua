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
  local m_PerformanceID
  local heroid = heroData.serverData.iHeroId
  local iFasionId = HeroManager:GetCurUseFashionID(heroid) or 0
  local fashionCfg = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroid, iFasionId)
  if not fashionCfg or fashionCfg:GetError() then
    ResourceUtil:CreateHeroIcon(self.m_head_tab_icon_Image, heroData.serverData.iHeroId)
    log.error("BattlePass skinCfgID Cannot Find Check Config: " .. iFasionId)
    return
  end
  local performanceID = fashionCfg.m_PerformanceID[0]
  local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
  local szIcon = presentationData.m_UIkeyword .. "002"
  UILuaHelper.SetAtlasSprite(self.m_head_tab_icon_Image, szIcon, nil, nil, true)
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
