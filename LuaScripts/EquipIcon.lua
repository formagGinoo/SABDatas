local EquipIcon = class("EquipIcon")

function EquipIcon:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_btnClick = self.m_goRoot.transform:Find("c_btnClick"):GetComponent("ButtonExtensions")
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = false
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = false
  if self.m_btnClick then
    self.m_btnClick.Clicked = handler(self, self.OnItemIconClicked)
  end
  self.m_fItemIconClickCB = nil
  self.m_imageBG = self.m_goRoot.transform:Find("c_bg").gameObject
  local tranSelected = self.m_goRoot.transform:Find("c_bg_selected")
  if tranSelected ~= nil then
    self.m_imageSelected = tranSelected.gameObject
    self.m_imageSelected:SetActive(false)
  else
    self.m_imageSelected = nil
  end
  self.m_imageEquip = self.m_goRoot.transform:Find("c_item"):GetComponent("Image")
  self.m_imageLvBG = self.m_goRoot.transform:Find("c_lv_bg").gameObject
  self.m_textLvNum = self.m_imageLvBG.transform:Find("c_txt_lv_num"):GetComponent(T_TextMeshProUGUI)
  self.m_textLv = self.m_textLvNum.transform:Find("common_item_txt_LV"):GetComponent(T_TextMeshProUGUI)
  self.m_imageNumBG = self.m_goRoot.transform:Find("c_num_bg").gameObject
  self.m_textNum = self.m_imageNumBG.transform:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
  self.m_imageGrade = self.m_goRoot.transform:Find("c_icon_item_grade"):GetComponent("Image")
  self.m_imageGradeFxObj = self.m_goRoot.transform:Find("c_icon_item_grade/icon_item_grade_FXLoop_SSR").gameObject
  self.m_imgHeroBg = self.m_goRoot.transform:Find("c_bg_hero_wear").gameObject
  self.m_iconHero = self.m_imgHeroBg.transform:Find("c_pnl_hero_mask/c_img_hero"):GetComponent("Image")
  self.m_imgHeroBg:SetActive(false)
  self.m_imgCombatBg = self.m_goRoot.transform:Find("c_bg_combatpower").gameObject
  local m_iconArrowTrans = self.m_imgCombatBg.transform:Find("c_icon_arrow")
  if not utils.isNull(m_iconArrowTrans) then
    self.m_iconArrow = m_iconArrowTrans.gameObject
  end
  self.m_textCombat = self.m_imgCombatBg.transform:Find("c_txt_zhanli"):GetComponent(T_TextMeshProUGUI)
  self.m_combatBgImg = self.m_goRoot.transform:Find("c_bg_combatpower"):GetComponent("Image")
  self.m_imgCombatBg:SetActive(false)
  self.m_imgRedpoint = self.m_goRoot.transform:Find("c_img_redpoint").gameObject
  self.m_imgRedpoint:SetActive(false)
  self.m_item_have_get = self.m_goRoot.transform:Find("c_item_have_get")
  local m_pnlEquipUpgradeTrans = self.m_goRoot.transform:Find("c_pnl_equip_upgrade")
  if not utils.isNull(m_pnlEquipUpgradeTrans) then
    self.m_pnlEquipUpgrade = m_pnlEquipUpgradeTrans.gameObject
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
  end
  self.m_equipCampBg = self.m_goRoot.transform:Find("pnl_lefticon/c_bg_equip_camp").gameObject
  self.m_equipCampImg = self.m_equipCampBg.transform:Find("c_img_equip_camp"):GetComponent("Image")
  self.m_equipCampBg:SetActive(false)
  self.m_equipCampFxList = {}
  for i = 1, 5 do
    local campTrans = self.m_equipCampBg.transform:Find("c_img_equip_camp/c_common_item_camp" .. i)
    if campTrans then
      self.m_equipCampFxList[i] = campTrans.gameObject
    end
  end
  self.m_imgEquipTypeBg = self.m_goRoot.transform:Find("pnl_lefticon/c_img_equip_type").gameObject
  self.m_iconEquipType = self.m_imgEquipTypeBg.transform:Find("c_icon_equip_type"):GetComponent("Image")
  self.m_imgEquipTypeBg:SetActive(false)
  self.m_img_gray = self.m_goRoot.transform:Find("c_img_gray").gameObject
  if self.m_img_gray then
    self.m_img_gray_Image = self.m_img_gray:GetComponent("Image")
    self.m_grayImgMaterial = self.m_img_gray_Image.material
  end
end

function EquipIcon:OnUpdate(dt)
end

function EquipIcon:SetEquipInfo(stEquipData)
  self.m_iItemID = stEquipData.iID
  self.m_iItemNum = stEquipData.iNum
  local itemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_iItemID,
    iNum = self.m_iItemNum
  }, stEquipData.customData)
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_imageEquip, itemData.icon_name)
  if itemData.equipType then
    self.m_imgEquipTypeBg:SetActive(true)
    ResourceUtil:CreateEquipTypeImg(self.m_iconEquipType, itemData.equipType)
  else
    self.m_imgEquipTypeBg:SetActive(false)
  end
  if self.m_imageSelected then
    self.m_imageSelected:SetActive(itemData.is_selected)
  end
  if self.m_imgRedpoint then
    self.m_imgRedpoint:SetActive(itemData.showRedPoint)
  end
  ResourceUtil:CreateEquipQualityImg(self.m_imageGrade, itemData.quality)
  local customData = itemData.equipData or {}
  local combat = itemData.combat
  if combat and combat ~= 0 or itemData.combat_difference then
    self.m_imgCombatBg:SetActive(true)
    local combatTxt = itemData.combat_difference ~= nil and itemData.combat_difference or combat
    if 0 <= combatTxt then
      combatTxt = string.format(ConfigManager:GetCommonTextById(100029), combatTxt)
    end
    self.m_textCombat.text = combatTxt
    if not utils.isNull(self.m_iconArrow) then
      self.m_iconArrow:SetActive(false)
    end
    if itemData.combat_difference then
      if 0 <= itemData.combat_difference then
        UILuaHelper.SetColor(self.m_textCombat, 41, 123, 68, 255)
      else
        UILuaHelper.SetColor(self.m_textCombat, 209, 74, 74, 255)
      end
    end
  else
    self.m_imgCombatBg:SetActive(false)
    if not utils.isNull(self.m_iconArrow) then
      self.m_iconArrow:SetActive(false)
    end
  end
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
    self.m_imageLvBG:SetActive(false)
  end
  if self.m_iItemNum > 1 then
    self.m_imageNumBG:SetActive(true)
    self.m_textNum.text = tostring(self.m_iItemNum)
  else
    self.m_imageNumBG:SetActive(false)
  end
  if itemData.config and 0 < itemData.config.m_BonusCamp then
    self.m_equipCampBg:SetActive(true)
    ResourceUtil:CreateEquipCampImg(self.m_equipCampImg, itemData.config.m_BonusCamp)
    if customData.iEquipUid then
      local flag = false
      if customData.equipHeroId then
        flag = EquipManager:CheckIsShowCampAttAddExtByCfgId(customData.iBaseId, customData.equipHeroId)
      else
        flag = EquipManager:CheckIsShowCampAttAddExt(customData.iEquipUid)
      end
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
  if self.m_imageGradeFxObj then
    if itemData.quality == 4 then
      self.m_imageGradeFxObj:SetActive(true)
    else
      self.m_imageGradeFxObj:SetActive(false)
    end
  end
  if not utils.isNull(self.m_pnlEquipUpgrade) then
    if itemData.sel_upgrade_item_num then
      self:SetUpGradeNum(itemData.sel_upgrade_item_num)
    else
      self.m_pnlEquipUpgrade:SetActive(false)
    end
  end
end

function EquipIcon:SetUpGradeNum(iNum)
  if iNum == nil or iNum < 0 then
    return
  end
  self.m_pnlEquipUpgrade:SetActive(true)
  self.m_equipUpgradeNumBg:SetActive(0 < iNum)
  if ResourceUtil:GetResourceTypeById(self.m_iItemID) == ResourceUtil.RESOURCE_TYPE.EQUIPS then
    self.m_btnUpgradeDel:SetActive(false)
    self.m_txtEquipNumText.text = ""
  else
    self.m_btnUpgradeDel:SetActive(0 < iNum)
    self.m_txtEquipNumText.text = iNum
  end
end

function EquipIcon:SetSwallowTouch(bSwallowTouch)
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = bSwallowTouch
end

function EquipIcon:SetSelected(bSelected)
  if self.m_imageSelected then
    self.m_imageSelected:SetActive(bSelected)
  end
end

function EquipIcon:SetActive(isActive)
  if self.m_goRoot then
    self.m_goRoot.gameObject:SetActive(isActive)
  end
end

function EquipIcon:SetParent(parentTrans)
  if not parentTrans then
    return
  end
  if not self.m_goRoot then
    return
  end
  UILuaHelper.SetParent(self.m_goRoot, parentTrans)
end

function EquipIcon:SetItemIconClickCB(fClickCB)
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
  self.m_fItemIconClickCB = fClickCB
end

function EquipIcon:OnItemIconClicked()
  if self.m_fItemIconClickCB then
    self.m_fItemIconClickCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

function EquipIcon:SetItemDelClickCB(fClickCB)
  if not utils.isNull(self.m_btnDeleteClick) then
    self.m_btnDeleteClick:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
    self.m_fItemDelClickCB = fClickCB
  end
end

function EquipIcon:OnItemDelClicked()
  if self.m_fItemDelClickCB then
    self.m_fItemDelClickCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

return EquipIcon
