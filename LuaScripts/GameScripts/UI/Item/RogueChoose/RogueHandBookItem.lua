local UIItemBase = require("UI/Common/UIItemBase")
local RogueHandBookItem = class("RogueHandBookItem", UIItemBase)
local MaxJobCount = 3

function RogueHandBookItem:OnInit()
end

function RogueHandBookItem:dispose()
  self.super.dispose(self)
  self:UnRegisterAllRedDotItem()
end

function RogueHandBookItem:OnFreshData()
  local cfg = self.m_itemData.cfg
  if not cfg then
    return
  end
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  local item_id = cfg.m_ItemID
  self.mPosCfg = self.m_levelRogueStageHelper:GetRogueItemIconPosById(item_id)
  local bIsLock = false
  local stRogue = self.m_levelRogueStageHelper:GetRogueServerData()
  if not stRogue then
    self.bIsLock = true
    self:FreshLockUI()
    return
  end
  local mHandbook = stRogue.mHandbook
  local mTech = stRogue.mTech
  self.m_btnEX = self.m_btn_Tips:GetComponent("ButtonExtensions")
  self.m_btnEX.Clicked = handler(self, self.OnBtnTipsClicked)
  local iLimitTechID = cfg.m_TechID
  if 0 < iLimitTechID and mTech and (mTech[iLimitTechID] == nil or mTech[iLimitTechID] == 0) then
    bIsLock = true
  end
  self.bIsLock = bIsLock
  if mHandbook then
    self.bIsActive = mHandbook[item_id] ~= nil and 0 < mHandbook[item_id]
  end
  if bIsLock or not self.bIsActive then
    self:FreshLockUI()
  else
    self:FreshNormalUI()
  end
end

function RogueHandBookItem:FreshNormalUI()
  local cfg = self.m_itemData.cfg
  local iSubType = cfg.m_ItemSubType
  self.m_pnl_lock:SetActive(false)
  self.m_pnl_normal:SetActive(true)
  self:RegisterOrUpdateRedDotItem(self.m_img_new, RedDotDefine.ModuleType.RogueHandBookItemRedDot, {
    id = cfg.m_ItemID,
    bIsActive = self.bIsActive
  })
  local s_cfg = self.m_levelRogueStageHelper:GetRougeItemSubTypeInfoCfgBySubType(cfg.m_ItemSubType)
  if s_cfg then
    local color = utils.changeCSArrayToLuaTable(s_cfg.m_TypeColor)
    UILuaHelper.SetColor(self.m_img_occupy_Image, table.unpack(color))
  end
  if RogueStageManager.RogueStageItemSubType.ExclusiveMap == iSubType or RogueStageManager.RogueStageItemSubType.CommonMap == iSubType then
    self.m_img_bg_blueprint:SetActive(true)
    self.m_img_bg_green:SetActive(false)
    self.m_img_bg_red:SetActive(false)
    self.m_img_bg_yellow:SetActive(false)
  else
    self.m_img_bg_blueprint:SetActive(false)
    self.m_img_bg_red:SetActive(cfg.m_HandbookType == 1)
    self.m_img_bg_yellow:SetActive(cfg.m_HandbookType == 2)
    self.m_img_bg_green:SetActive(cfg.m_HandbookType == 3)
  end
  UILuaHelper.SetAtlasSprite(self.m_img_occupy_Image, cfg.m_VolumeIcon, function()
    if not utils.isNull(self.m_img_occupy_Image) then
      self.m_img_occupy_Image:SetNativeSize()
    end
  end)
  UILuaHelper.SetAtlasSprite(self.m_img_icon_Image, cfg.m_ItemIcon, function()
    if utils.isNull(self.m_img_icon_Image) then
      return
    end
    self.m_img_icon_Image:SetNativeSize()
    if self.mPosCfg and not utils.isNull(self.m_img_icon) then
      local posTab = utils.changeCSArrayToLuaTable(self.mPosCfg.m_HandBookPos)
      if posTab and posTab[1] then
        UILuaHelper.SetLocalPosition(self.m_img_icon, posTab[1], posTab[2], 0)
      end
      if posTab and posTab[3] then
        UILuaHelper.SetLocalScale(self.m_img_icon, posTab[3] / 100, posTab[3] / 100, 1)
      end
    end
  end)
  if RogueStageManager.RogueStageItemSubType.ExclusiveMap == iSubType or RogueStageManager.RogueStageItemSubType.CharacterEquip == iSubType then
    self.m_pnl_role:SetActive(true)
    self.m_pnl_carrer:SetActive(false)
    local iCharacterID = cfg.m_Character
    ResourceUtil:CreateHeroHeadIcon(self.m_img_icon_carrer_Image, iCharacterID)
  else
    self.m_pnl_role:SetActive(false)
    self.m_pnl_carrer:SetActive(true)
    local vJob = utils.changeCSArrayToLuaTable(cfg.m_Job)
    local vCamp = utils.changeCSArrayToLuaTable(cfg.m_Camp)
    if vJob and 0 < #vJob then
      for i = 1, MaxJobCount do
        local job = vJob[i]
        if job then
          self["m_img_carrer_bg0" .. i]:SetActive(true)
          ResourceUtil:CreateCareerImg(self["m_img_icon_carrer0" .. i .. "_Image"], job)
        else
          self["m_img_carrer_bg0" .. i]:SetActive(false)
        end
      end
    elseif vCamp and 0 < #vCamp then
      for i = 1, MaxJobCount do
        local camp = vCamp[i]
        if camp then
          self["m_img_carrer_bg0" .. i]:SetActive(true)
          ResourceUtil:CreateCampImg(self["m_img_icon_carrer0" .. i .. "_Image"], camp)
        else
          self["m_img_carrer_bg0" .. i]:SetActive(false)
        end
      end
    else
      self.m_pnl_role:SetActive(false)
      self.m_pnl_carrer:SetActive(false)
    end
  end
  self.m_txt_title_Text.text = cfg.m_mItemName
end

function RogueHandBookItem:FreshLockUI()
  local cfg = self.m_itemData.cfg
  self.m_pnl_lock:SetActive(true)
  self.m_pnl_normal:SetActive(false)
  UILuaHelper.SetAtlasSprite(self.m_img_occupy_lock_Image, cfg.m_VolumeIcon, function()
    if not utils.isNull(self.m_img_occupy_lock_Image) then
      self.m_img_occupy_lock_Image:SetNativeSize()
    end
  end)
  UILuaHelper.SetAtlasSprite(self.m_img_icon_lock_Image, cfg.m_ItemIcon, function()
    if utils.isNull(self.m_img_icon_lock_Image) then
      return
    end
    self.m_img_icon_lock_Image:SetNativeSize()
    if self.mPosCfg and not utils.isNull(self.m_img_icon_lock) then
      local posTab = utils.changeCSArrayToLuaTable(self.mPosCfg.m_HandBookPos)
      if posTab and posTab[1] then
        UILuaHelper.SetLocalPosition(self.m_img_icon_lock, posTab[1], posTab[2], 0)
      end
      if posTab and posTab[3] then
        UILuaHelper.SetLocalScale(self.m_img_icon_lock, posTab[3] / 100, posTab[3] / 100, 1)
      end
    end
  end)
  local iSubType = cfg.m_ItemSubType
  self.m_img_bg_title:SetActive(self.bIsLock)
  local s_cfg = self.m_levelRogueStageHelper:GetRougeItemSubTypeInfoCfgBySubType(cfg.m_ItemSubType)
  if s_cfg then
    local color = utils.changeCSArrayToLuaTable(s_cfg.m_TypeColor)
    UILuaHelper.SetColor(self.m_img_occupy_lock_Image, table.unpack(color))
  end
  if RogueStageManager.RogueStageItemSubType.ExclusiveMap == iSubType or RogueStageManager.RogueStageItemSubType.CharacterEquip == iSubType then
    self.m_pnl_role_lock:SetActive(true)
    self.m_pnl_carrer_lock:SetActive(false)
    local iCharacterID = cfg.m_Character
    ResourceUtil:CreateHeroHeadIcon(self.m_img_icon_carrer_lock_Image, iCharacterID)
  else
    self.m_pnl_role_lock:SetActive(false)
    self.m_pnl_carrer_lock:SetActive(true)
    local vJob = utils.changeCSArrayToLuaTable(cfg.m_Job)
    local vCamp = utils.changeCSArrayToLuaTable(cfg.m_Camp)
    if vJob and 0 < #vJob then
      for i = 1, MaxJobCount do
        local job = vJob[i]
        if job then
          self["m_img_carrer_bg0" .. i .. "_lock"]:SetActive(true)
          ResourceUtil:CreateCareerImg(self["m_img_icon_carrer0" .. i .. "_lock_Image"], job)
        else
          self["m_img_carrer_bg0" .. i .. "_lock"]:SetActive(false)
        end
      end
    elseif vCamp and 0 < #vCamp then
      for i = 1, MaxJobCount do
        local camp = vCamp[i]
        if camp then
          self["m_img_carrer_bg0" .. i .. "_lock"]:SetActive(true)
          ResourceUtil:CreateCampImg(self["m_img_icon_carrer0" .. i .. "_lock_Image"], camp)
        else
          self["m_img_carrer_bg0" .. i .. "_lock"]:SetActive(false)
        end
      end
    else
      self.m_pnl_role_lock:SetActive(false)
      self.m_pnl_carrer_lock:SetActive(false)
    end
  end
  self.m_txt_title_lock_Text.text = cfg.m_mItemName
  self.m_txt_title_lock02_Text.text = cfg.m_mUnlockText
end

function RogueHandBookItem:OnBtnTipsClicked()
  local cfg = self.m_itemData.cfg
  if not cfg then
    return
  end
  utils.openRogueItemTips(cfg.m_ItemID)
  if self.bIsLock or not self.bIsActive then
    return
  end
  local localValue = LocalDataManager:GetIntSimple("RogueHandBookItem_ID_" .. cfg.m_ItemID, 0)
  if localValue == 0 then
    LocalDataManager:SetIntSimple("RogueHandBookItem_ID_" .. cfg.m_ItemID, 1, true)
    self.m_img_new:SetActive(false)
    self:broadcastEvent("eGameEvent_RogueHandBookItem_StateChange")
    self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
      redDotKey = RedDotDefine.ModuleType.RogueHandBookEntry,
      count = self.m_levelRogueStageHelper:CheckRogueHandBookEntryReddot()
    })
  end
end

return RogueHandBookItem
