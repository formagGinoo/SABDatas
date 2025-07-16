local UIItemBase = require("UI/Common/UIItemBase")
local UIInheritItem = class("UIInheritItem", UIItemBase)
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local INHERIT_SYNC_CD = GlobalManagerIns:GetValue_ByName("InheritCD").m_Value or ""

function UIInheritItem:OnInit()
  self.m_common_item_obj = self.m_itemRootObj.transform:Find("c_common_hero_small").gameObject
  self.m_btn_empty_obj = self.m_itemRootObj.transform:Find("c_btn_empty").gameObject
  self.m_btn_lock_obj = self.m_itemRootObj.transform:Find("c_btn_lock").gameObject
  self.m_icon_lock_obj = self.m_itemRootObj.transform:Find("c_img_lock").gameObject
  self.m_icon_empty_obj = self.m_itemRootObj.transform:Find("c_icon_empty").gameObject
  self.m_txt_cd_obj = self.m_itemRootObj.transform:Find("c_txt_cd").gameObject
  self.m_txt_cd_Text = self.m_itemRootObj.transform:Find("c_txt_cd"):GetComponent(T_TextMeshProUGUI)
  self.m_tag_next_obj = self.m_itemRootObj.transform:Find("c_tag_next").gameObject
  self.m_iTimeDurationOneSecond = 0
end

function UIInheritItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIInheritItem:SetItemInfo(itemData)
  self.m_common_item_obj:SetActive(not itemData.isLock and itemData.iHeroId ~= 0)
  self.m_btn_lock_obj:SetActive(itemData.isLock)
  self.m_icon_lock_obj:SetActive(itemData.isLock)
  self.m_btn_empty_obj:SetActive(not itemData.isLock and itemData.iHeroId == 0)
  self.m_tag_next_obj:SetActive(itemData.showNext)
  if not itemData.isLock and itemData.iHeroId ~= 0 then
    if self.m_itemIcon == nil then
      self.m_itemIcon = self:createHeroIcon(self.m_common_item_obj)
    end
    local heroData = HeroManager:GetHeroDataByID(itemData.iHeroId)
    self.m_itemIcon:SetHeroData(heroData.serverData)
    self.m_itemIcon:SetInheritColor(255, 255, 255)
    self.m_itemIcon:SetHeroIconClickCB(function(heroId)
      self:OnItemClick(heroId)
    end)
  end
  self.m_txt_cd_Text.text = itemData.iCdTime
  if itemData.iCdTime and 0 < itemData.iCdTime then
    local cd = tonumber(INHERIT_SYNC_CD) - (TimeUtil:GetServerTimeS() - itemData.iCdTime)
    if 0 < cd then
      self.m_iTimeTick = cd
      self.m_txt_cd_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(cd))
    else
      self.m_txt_cd_Text.text = ""
    end
  else
    self.m_iTimeTick = nil
  end
  self.m_txt_cd_obj:SetActive(self.m_iTimeTick and 0 < self.m_iTimeTick)
  self.m_icon_empty_obj:SetActive(not itemData.isLock and itemData.iHeroId == 0 and self.m_iTimeTick == nil)
end

function UIInheritItem:OnUpdate(dt)
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    self.m_txt_cd_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
  end
  if self.m_iTimeTick <= 0 then
    self.m_iTimeTick = nil
    self.m_txt_cd_Text.text = ""
    self:RefreshClearCDState()
  end
end

function UIInheritItem:RefreshClearCDState()
  self.m_icon_empty_obj:SetActive(not self.m_itemData.isLock and self.m_itemData.iHeroId == 0 and self.m_iTimeTick == nil)
  self.m_txt_cd_obj:SetActive(self.m_iTimeTick and 0 < self.m_iTimeTick)
end

function UIInheritItem:OnItemClick(itemId, itemNum)
  local heroData = HeroManager:GetHeroDataByID(itemId)
  local cdStr = TimeUtil:SecondsToFormatStrDHOrHMS(tonumber(INHERIT_SYNC_CD))
  StackTop:Push(UIDefines.ID_FORM_INHERITTIPS, {
    tipsID = 1216,
    heroId = itemId,
    cd = cdStr,
    levelInfo = {
      oldLv = InheritManager:GetInheritLevel(),
      newLv = heroData.serverData.iOriLevel or 0
    },
    func1 = function()
      InheritManager:ReqInheritDelHero(InheritManager:GetInheritPosById(itemId))
    end
  })
end

return UIInheritItem
