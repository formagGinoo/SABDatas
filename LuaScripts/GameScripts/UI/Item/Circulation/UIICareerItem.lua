local UIItemBase = require("UI/Common/UIItemBase")
local UIICareerItem = class("UIICareerItem", UIItemBase)
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")

function UIICareerItem:OnInit()
  self.m_common_item_obj = self.m_itemRootObj.transform:Find("c_common_hero_small").gameObject
  self.m_btn_empty_obj = self.m_itemRootObj.transform:Find("c_btn_empty").gameObject
  self.m_btn_lock_obj = self.m_itemRootObj.transform:Find("c_btn_lock").gameObject
  self.m_icon_lock_obj = self.m_itemRootObj.transform:Find("c_btn_lock/img_lock").gameObject
  self.m_icon_empty_obj = self.m_itemRootObj.transform:Find("c_btn_empty/icon_empty").gameObject
  self.m_redpoint_hero = self.m_itemRootObj.transform:Find("m_redpoint_hero").gameObject
  self.c_icon_camp = self.m_itemRootObj.transform:Find("c_pnl_camp/c_icon_camp").gameObject:GetComponent("Image")
  self.m_iTimeDurationOneSecond = 0
end

function UIICareerItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIICareerItem:SetItemInfo(itemData)
  self.m_common_item_obj:SetActive(not itemData.isLock and itemData.iHeroId ~= 0)
  self.m_btn_lock_obj:SetActive(itemData.isLock)
  self.m_icon_lock_obj:SetActive(itemData.isLock)
  self.m_redpoint_hero:SetActive(false)
  self.m_btn_empty_obj:SetActive(not itemData.isLock and itemData.iHeroId == 0)
  if not itemData.isLock and itemData.iHeroId ~= 0 then
    if self.m_itemIcon == nil then
      self.m_itemIcon = self:createHeroIcon(self.m_common_item_obj)
    end
    local heroData = HeroManager:GetHeroDataByID(itemData.iHeroId)
    self.m_itemIcon:SetHeroData(heroData.serverData)
    self.m_itemIcon:SetInheritColor(255, 255, 255)
    self.m_itemIcon:SetHeroIconClickCB(function()
      self:OnItemClick()
    end)
  else
    local careerCfg = CareerCfgIns:GetValue_ByCareerID(itemData.careerID)
    UILuaHelper.SetAtlasSprite(self.c_icon_camp, careerCfg.m_CirculationCareerIcon, nil, nil, true)
  end
  if not itemData.isLock and itemData.iHeroId == 0 then
    local redNum = HeroManager:IsCareerLocationIDHaveRedDot(itemData.careerID)
    self.m_redpoint_hero:SetActive(0 < redNum)
  end
  self.m_icon_empty_obj:SetActive(not itemData.isLock and itemData.iHeroId == 0 and self.m_iTimeTick == nil)
end

function UIICareerItem:OnItemClick()
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex)
  end
end

return UIICareerItem
