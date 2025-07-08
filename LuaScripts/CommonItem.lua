local CommonItem = class("CommonItem")

function CommonItem:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_btnClick = self.m_goRoot.transform:Find("c_btnClick"):GetComponent("ButtonExtensions")
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = false
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = false
  if self.m_btnClick then
    self.m_btnClick.Clicked = handler(self, self.OnItemIconClicked)
  end
  self.m_fItemIconClickCB = nil
  self.m_imageBG = self.m_goRoot.transform:Find("c_bg"):GetComponent("Image")
  if self.m_goRoot.transform:Find("c_bg/c_level8_bg") then
    self.m_imageLevel8Bg = self.m_goRoot.transform:Find("c_bg/c_level8_bg").gameObject
  end
  if self.m_goRoot.transform:Find("c_bg/c_level9_bg") then
    self.m_imageLevel9Bg = self.m_goRoot.transform:Find("c_bg/c_level9_bg").gameObject
  end
  if self.m_goRoot.transform:Find("c_bg/c_level10_bg") then
    self.m_imageLevel10Bg = self.m_goRoot.transform:Find("c_bg/c_level10_bg").gameObject
  end
  if self.m_goRoot.transform:Find("vx_item_grade/c_level8") then
    self.m_imageLevel8 = self.m_goRoot.transform:Find("vx_item_grade/c_level8").gameObject
  end
  if self.m_goRoot.transform:Find("vx_item_grade/c_level9") then
    self.m_imageLevel9 = self.m_goRoot.transform:Find("vx_item_grade/c_level9").gameObject
  end
  if self.m_goRoot.transform:Find("vx_item_grade/c_level10") then
    self.m_imageLevel10 = self.m_goRoot.transform:Find("vx_item_grade/c_level10").gameObject
  end
  local tranSelected = self.m_goRoot.transform:Find("c_bg_selected")
  if tranSelected ~= nil then
    self.m_imageSelected = tranSelected.gameObject
  else
    self.m_imageSelected = nil
  end
  self.headFrame = self.m_goRoot.transform:Find("c_icon_headframe").gameObject
  self.m_imageItem = self.m_goRoot.transform:Find("c_item"):GetComponent("Image")
  self.m_imageNumBG = self.m_goRoot.transform:Find("c_num_bg").gameObject
  self.m_textNum = self.m_imageNumBG.transform:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
  self.m_imageLvBG = self.m_goRoot.transform:Find("c_lv_bg").gameObject
  self.m_textLvNum = self.m_imageLvBG.transform:Find("c_txt_lv_num"):GetComponent(T_TextMeshProUGUI)
  self.m_imageTimeBG = self.m_goRoot.transform:Find("c_time_bg").gameObject
  self.m_textTime = self.m_imageTimeBG.transform:Find("c_txt_time"):GetComponent(T_TextMeshProUGUI)
  local tranBarBG = self.m_goRoot.transform:Find("c_bar_bg")
  if tranBarBG ~= nil then
    self.m_imageBarBG = tranBarBG.gameObject
    self.m_imageBar = self.m_imageBarBG.transform:Find("c_bar"):GetComponent("Image")
    self.m_textBar = self.m_imageBarBG.transform:Find("c_bar_txt"):GetComponent(T_TextMeshProUGUI)
    self.m_imageBarDone = self.m_imageBarBG.transform:Find("c_bar_done").gameObject
  else
    self.m_imageBarBG = nil
    self.m_imageBar = nil
    self.m_textBar = nil
    self.m_imageBarDone = nil
  end
  self.m_imageGrade = self.m_goRoot.transform:Find("c_icon_item_grade"):GetComponent("Image")
  self.m_obj_need_rootTrans = self.m_goRoot.transform:Find("c_num_need")
  if self.m_obj_need_rootTrans then
    self.m_obj_need_root = self.m_obj_need_rootTrans.gameObject
    self.m_txt_num_have = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_num_have"):GetComponent(T_TextMeshProUGUI)
    self.m_txt_num_need = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_num_need"):GetComponent(T_TextMeshProUGUI)
    self.m_txt_need_split = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_split"):GetComponent(T_TextMeshProUGUI)
    self.m_obj_need_root:SetActive(false)
  end
  self.m_imgEquipTypeBg = self.m_goRoot.transform:Find("pnl_lefticon/c_img_equip_type").gameObject
  self.m_iconEquipType = self.m_imgEquipTypeBg.transform:Find("c_icon_equip_type"):GetComponent("Image")
  if self.m_imgEquipTypeBg.transform:Find("c_equip_type_effect") then
    self.m_equip_type_effect = self.m_imgEquipTypeBg.transform:Find("c_equip_type_effect").gameObject
  end
  self.m_imgEquipTypeBg:SetActive(false)
  self.m_imgHeroBg = self.m_goRoot.transform:Find("c_bg_hero_wear").gameObject
  self.m_iconHero = self.m_imgHeroBg.transform:Find("c_pnl_hero_mask/c_img_hero"):GetComponent("Image")
  self.m_imgHeroBg:SetActive(false)
  self.m_imgRedpoint = self.m_goRoot.transform:Find("c_img_redpoint").gameObject
  self.m_imgRedpoint:SetActive(false)
  self.m_percentageBg = self.m_goRoot.transform:Find("c_num_percentage_bg").gameObject
  self.m_textPercentage = self.m_percentageBg.transform:Find("c_num_percentage"):GetComponent(T_TextMeshProUGUI)
  self.m_percentageBg:SetActive(false)
  self.m_item_have_get = self.m_goRoot.transform:Find("c_item_have_get")
  self.m_pnlEquipUpgrade = self.m_goRoot.transform:Find("c_pnl_equip_upgrade").gameObject
  self.m_pnlEquipUpgrade:SetActive(false)
  self.m_equipUpgradeNumBg = self.m_pnlEquipUpgrade.transform:Find("c_bg_upgrade_num").gameObject
  self.m_txtEquipNumText = self.m_equipUpgradeNumBg.transform:Find("c_txt_equip_num"):GetComponent(T_TextMeshProUGUI)
  self.m_btnUpgradeDel = self.m_pnlEquipUpgrade.transform:Find("c_btn_upgrade_delete").gameObject
  self.m_btnDeleteClick = self.m_btnUpgradeDel.transform:GetComponent("ButtonExtensions")
  self.m_btnUpgradeDel.transform:GetComponent("Empty4Raycast").raycastTarget = false
  self.m_btnUpgradeDel.transform:GetComponent("Empty4Raycast").SwallowTouch = false
  self.m_fItemDelClickCB = nil
  if self.m_btnDeleteClick then
    self.m_btnDeleteClick.Clicked = handler(self, self.OnItemDelClicked)
  end
  self.m_equipCampNode = self.m_goRoot.transform:Find("pnl_lefticon").gameObject
  self.m_equipCampBg = self.m_goRoot.transform:Find("pnl_lefticon/c_bg_equip_camp").gameObject
  self.m_equipCampImg = self.m_equipCampBg.transform:Find("c_img_equip_camp"):GetComponent("Image")
  self.m_equipCampBg:SetActive(false)
  self.m_equipCampNode:SetActive(true)
  self.m_equipCampFxList = {}
  for i = 1, 5 do
    local campTrans = self.m_equipCampBg.transform:Find("c_img_equip_camp/c_common_item_camp" .. i)
    if campTrans then
      self.m_equipCampFxList[i] = campTrans.gameObject
    end
  end
  self.m_btnGift = self.m_goRoot.transform:Find("c_btn_gift").gameObject
  self.m_btnLikeGift = self.m_goRoot.transform:Find("c_btn_like_gift").gameObject
  self.m_img_gray = self.m_goRoot.transform:Find("c_img_gray").gameObject
  if self.m_img_gray then
    self.m_img_gray_Image = self.m_img_gray:GetComponent("Image")
    self.m_grayImgMaterial = self.m_img_gray_Image.material
  end
  self.m_clickShadow = self.m_goRoot.transform:Find("ClickShadow")
  if not utils.isNull(self.m_clickShadow) then
    self.m_clickShadowImg = self.m_clickShadow:GetComponent("Image")
  end
  local c_img_doublereward = self.m_goRoot.transform:Find("c_img_doublereward")
  if not utils.isNull(c_img_doublereward) then
    self.m_doublereward = c_img_doublereward.gameObject
    self.m_doublereward:SetActive(false)
  end
  self.m_itemCanGet = self.m_goRoot.transform:Find("c_item_get")
  if not utils.isNull(self.m_itemCanGet) then
    UILuaHelper.SetActive(self.m_itemCanGet, false)
  end
  local c_img_gift = self.m_goRoot.transform:Find("c_img_gift")
  if not utils.isNull(c_img_gift) then
    self.m_c_img_gift = c_img_gift.gameObject
    self.m_c_img_gift:SetActive(false)
  end
end

function CommonItem:RefreshNum(iNum)
  if iNum == nil or iNum <= 0 then
    return
  end
  self.m_imageNumBG:SetActive(true)
  self.m_textNum.text = BigNumFormat(iNum)
end

function CommonItem:SetNumActive(active)
  self.m_imageNumBG:SetActive(active)
end

function CommonItem:SetItemInfo(itemData)
  if itemData == nil then
    return
  end
  if itemData.customData and itemData.customData.optimizing then
    itemData = ResourceUtil:GetProcessRewardData({
      iID = itemData.iID,
      iNum = itemData.iNum
    }, itemData.customData)
  end
  self.m_iItemID = itemData.data_id
  self.m_iItemNum = itemData.data_num
  self.m_imageItem.gameObject:SetActive(false)
  UILuaHelper.SetAtlasSprite(self.m_imageItem, itemData.icon_name, function()
    self.m_imageItem.gameObject:SetActive(true)
  end)
  if itemData.equipType then
    self.m_imgEquipTypeBg:SetActive(true)
    ResourceUtil:CreateEquipTypeImg(self.m_iconEquipType, itemData.equipType)
  else
    self.m_imgEquipTypeBg:SetActive(false)
  end
  if self.m_imageSelected then
    self.m_imageSelected:SetActive(itemData.is_selected)
  end
  if self.m_item_have_get then
    UILuaHelper.SetActive(self.m_item_have_get, itemData.is_have_get)
  end
  if itemData.percentage and itemData.percentage ~= 0 then
    self.m_percentageBg:SetActive(true)
    self.m_textPercentage.text = itemData.percentage
  else
    self.m_percentageBg:SetActive(false)
  end
  if self.m_imgRedpoint then
    self.m_imgRedpoint:SetActive(itemData.showRedPoint and 0 < itemData.showRedPoint)
  end
  if self.headFrame then
    UILuaHelper.SetActive(self.headFrame, false)
  end
  self:SetEquipBgLevel(0)
  if itemData.data_type == ResourceUtil.RESOURCE_TYPE.EQUIPS then
    ResourceUtil:CreateEquipQualityImg(self.m_imageGrade, itemData.quality)
    local customData = itemData.equipData or {}
    if customData.iHeroId and customData.iHeroId ~= 0 then
      self.m_imgHeroBg:SetActive(true)
      local cfg = HeroManager:GetHeroConfigByID(customData.iHeroId)
      ResourceUtil:CreateHeroHeadIcon(self.m_iconHero, cfg.m_HeroID, customData.iBreak)
    else
      self.m_imgHeroBg:SetActive(false)
    end
    if customData.iLevel then
      self.m_imageLvBG:SetActive(true)
      self.m_textLvNum.text = tostring(customData.iLevel)
    else
      self.m_imageLvBG:SetActive(true)
      self.m_textLvNum.text = "0"
    end
    if itemData.config and 0 < itemData.config.m_BonusCamp then
      self.m_equipCampBg:SetActive(true)
      ResourceUtil:CreateEquipCampImg(self.m_equipCampImg, itemData.config.m_BonusCamp)
      if customData.iEquipUid then
        local flag = EquipManager:CheckIsShowCampAttAddExt(customData.iEquipUid)
        if flag then
          self.m_equipCampImg.material = nil
        else
          self.m_equipCampImg.material = self.m_grayImgMaterial
        end
        for i = 1, 5 do
          if self.m_equipCampFxList[i] then
            self.m_equipCampFxList[i]:SetActive(i == itemData.config.m_BonusCamp and flag)
          end
        end
      end
    else
      self.m_equipCampBg:SetActive(false)
    end
    self.m_customData = itemData.customData
    self:SetEquipBgLevel(itemData.quality, customData)
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.LEGACY then
    ResourceUtil:CreateQualityImg(self.m_imageGrade, itemData.quality)
    if itemData.level and itemData.level ~= 0 then
      self.m_imageLvBG:SetActive(true)
      self.m_textLvNum.text = tostring(itemData.level)
    else
      self.m_imageLvBG:SetActive(false)
    end
    self.m_imgHeroBg:SetActive(false)
    self.m_equipCampBg:SetActive(false)
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.HEAD_ICONS or itemData.data_type == ResourceUtil.RESOURCE_TYPE.HEAD_FRAME_ICONS then
    ResourceUtil:CreateQualityImg(self.m_imageGrade, itemData.quality)
    if self.headFrame then
      UILuaHelper.SetActive(self.headFrame, true)
    end
    self.m_imgHeroBg:SetActive(false)
    self.m_imageLvBG:SetActive(false)
    self.m_equipCampBg:SetActive(false)
  else
    ResourceUtil:CreateQualityImg(self.m_imageGrade, itemData.quality)
    self.m_imgHeroBg:SetActive(false)
    self.m_imageLvBG:SetActive(false)
    self.m_equipCampBg:SetActive(false)
  end
  if itemData.data_type ~= ResourceUtil.RESOURCE_TYPE.EQUIPS and itemData.quality == 4 then
    if self.m_imageLevel9 then
      UILuaHelper.SetActive(self.m_imageLevel9, true)
    end
    if self.m_imageLevel9Bg then
      UILuaHelper.SetActive(self.m_imageLevel9Bg, true)
    end
    if self.m_imageBG then
      local iconName = "Atlas_Equipment/Quality_8b"
      CS.UI.UILuaHelper.SetAtlasSprite(self.m_imageBG, iconName, nil, nil, true)
    end
  end
  self.m_imageTimeBG:SetActive(false)
  self.m_imageNumBG:SetActive(false)
  self.m_imageBarBG:SetActive(false)
  self.m_btnGift:SetActive(false)
  self.m_btnLikeGift:SetActive(false)
  if itemData.data_type == ResourceUtil.RESOURCE_TYPE.ITEMS or itemData.data_type == ResourceUtil.RESOURCE_TYPE.TREASURE then
    self:RefreshNum(itemData.data_num)
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.EQUIPS then
    if itemData.data_num > 1 then
      self:RefreshNum(itemData.data_num)
    end
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.AFK then
    self:RefreshNum(itemData.data_num)
    self.m_imageTimeBG:SetActive(true)
    local iTime = tonumber(string.split(itemData.item_use, ",")[2])
    self.m_textTime.text = math.floor(iTime / 3600) .. ConfigManager:GetCommonTextById(20012)
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.FRAGMENT then
    if itemData.in_bag then
      if self.m_imageBarBG then
        self.m_imageBarBG:SetActive(true)
        local iOneCount = tonumber(string.split(itemData.item_use, ":")[2])
        iOneCount = iOneCount or tonumber(itemData.item_use)
        local fPercent = math.min(self.m_iItemNum / iOneCount, 1)
        self.m_imageBar.fillAmount = fPercent
        self.m_textBar.text = self.m_iItemNum .. "/" .. iOneCount
        self.m_imageBarDone:SetActive(iOneCount <= self.m_iItemNum)
        UILuaHelper.SetColor(self.m_textBar, 0, 0, 0, 1)
      end
    else
      self:RefreshNum(itemData.data_num)
    end
  elseif itemData.data_type == ResourceUtil.RESOURCE_TYPE.ATTRACT_GIFT then
    self:RefreshNum(itemData.data_num)
    if itemData.in_bag then
      self.m_btnGift:SetActive(true)
    else
      if itemData.bFavourite and not itemData.in_bag then
        self.m_btnLikeGift:SetActive(true)
      end
      if itemData.iCamp then
        self.m_imgEquipTypeBg:SetActive(true)
        ResourceUtil:CreateEquipCampImg(self.m_iconEquipType, itemData.iCamp)
      end
    end
  end
  if itemData.sel_upgrade_item_num then
    self:SetUpGradeNum(itemData.sel_upgrade_item_num)
  else
    self.m_pnlEquipUpgrade:SetActive(false)
  end
  ResourceUtil:CreateCommonItemBg(self.m_imageBG, itemData.data_id, itemData.equipData, itemData)
  if not utils.isNull(self.m_clickShadowImg) then
    UILuaHelper.SetImageAlpha(self.m_clickShadowImg, 0)
  end
  if self.m_doublereward then
    self.m_doublereward:SetActive(itemData.is_extra)
  end
  if not utils.isNull(self.m_itemCanGet) then
    UILuaHelper.SetActive(self.m_itemCanGet, itemData.is_can_get)
  end
  if not utils.isNull(self.m_c_img_gift) then
    self.m_c_img_gift:SetActive(false)
  end
end

function CommonItem:SetUpGradeNum(iNum)
  if iNum == nil or iNum < 0 then
    return
  end
  self.m_pnlEquipUpgrade:SetActive(0 < iNum)
  self.m_equipUpgradeNumBg:SetActive(0 < iNum)
  self.m_btnUpgradeDel:SetActive(0 < iNum)
  self.m_txtEquipNumText.text = iNum
end

function CommonItem:SetNeedNum(needNum, haveNum)
  if not self.m_iItemID then
    return
  end
  self.m_imageNumBG:SetActive(false)
  if self.m_obj_need_root then
    self.m_obj_need_root:SetActive(true)
    haveNum = haveNum or ItemManager:GetItemNum(self.m_iItemID)
    self.m_txt_num_have.text = BigNumFormat(haveNum)
    self.m_txt_num_need.text = BigNumFormat(needNum)
    if needNum <= haveNum then
      UILuaHelper.SetColor(self.m_txt_num_have, table.unpack(GlobalConfig.COMMON_COLOR.Green))
      UILuaHelper.SetColor(self.m_txt_need_split, table.unpack(GlobalConfig.COMMON_COLOR.Green))
    else
      UILuaHelper.SetColor(self.m_txt_num_have, table.unpack(GlobalConfig.COMMON_COLOR.Red))
      UILuaHelper.SetColor(self.m_txt_need_split, table.unpack(GlobalConfig.COMMON_COLOR.Red))
    end
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_goRoot)
  end
end

function CommonItem:SetSwallowTouch(bSwallowTouch)
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = bSwallowTouch
end

function CommonItem:SetSelected(bSelected)
  if self.m_imageSelected then
    self.m_imageSelected:SetActive(bSelected)
  end
end

function CommonItem:ShowHeroIcon(flag)
  if self.m_imgHeroBg then
    self.m_imgHeroBg:SetActive(flag)
  end
end

function CommonItem:SetActive(isActive)
  if self.m_goRoot then
    self.m_goRoot.gameObject:SetActive(isActive)
  end
end

function CommonItem:SetItemHaveGetActive(isActive)
  if self.m_item_have_get then
    UILuaHelper.SetActive(self.m_item_have_get, isActive)
  end
end

function CommonItem:SetParent(parentTrans)
  if not parentTrans then
    return
  end
  if not self.m_goRoot then
    return
  end
  UILuaHelper.SetParent(self.m_goRoot, parentTrans)
end

function CommonItem:GetItemRoot()
  return self.m_goRoot
end

function CommonItem:SetItemIconClickCB(fClickCB)
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
  self.m_fItemIconClickCB = fClickCB
end

function CommonItem:OnItemIconClicked()
  if self.m_fItemIconClickCB then
    self.m_fItemIconClickCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

function CommonItem:SetItemDelClickCB(fClickCB)
  self.m_btnDeleteClick:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
  self.m_fItemDelClickCB = fClickCB
end

function CommonItem:OnItemDelClicked()
  if self.m_fItemDelClickCB then
    self.m_fItemDelClickCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

function CommonItem:SetItemIconLongPress(fLongPressCB)
  if self.m_btnClick then
    self.m_btnClick.LongPress = handler(self, self.OnItemIconLongPress)
    self.m_fItemIconLongPressCB = fLongPressCB
  end
end

function CommonItem:OnItemIconLongPress()
  if self.m_fItemIconLongPressCB then
    self.m_fItemIconLongPressCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

function CommonItem:SetEquipTypeEffect(bShow)
  if self.m_equip_type_effect then
    self.m_equip_type_effect:SetActive(bShow)
  end
end

function CommonItem:SetBGGlow(bShow)
  if self.m_imageLevel8 then
    UILuaHelper.SetActive(self.m_imageLevel8, bShow)
  end
  if self.m_imageLevel8Bg then
    UILuaHelper.SetActive(self.m_imageLevel8Bg, bShow)
  end
end

function CommonItem:SetEquipBgLevel(equipLevel, customData)
  if customData and customData.iOverloadHero and customData.iOverloadHero ~= 0 then
    equipLevel = 10
  end
  if self.m_imageLevel8 then
    UILuaHelper.SetActive(self.m_imageLevel8, equipLevel == 8)
  end
  if self.m_imageLevel8Bg then
    UILuaHelper.SetActive(self.m_imageLevel8Bg, equipLevel == 8)
  end
  if self.m_imageLevel9 then
    UILuaHelper.SetActive(self.m_imageLevel9, equipLevel == 9)
  end
  if self.m_imageLevel9Bg then
    UILuaHelper.SetActive(self.m_imageLevel9Bg, equipLevel == 9)
  end
  if self.m_imageLevel10 then
    UILuaHelper.SetActive(self.m_imageLevel10, equipLevel == 10)
  end
  if self.m_imageLevel10Bg then
    UILuaHelper.SetActive(self.m_imageLevel10Bg, equipLevel == 10)
  end
end

function CommonItem:SetGiftIcon(bShow)
  if not utils.isNull(self.m_c_img_gift) then
    self.m_c_img_gift:SetActive(bShow)
  end
end

return CommonItem
