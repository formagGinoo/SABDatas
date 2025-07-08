local RogueItemIcon = class("RogueItemIcon")
local RogueStageItemInfoIns = ConfigManager:GetConfigInsByName("RogueStageItemInfo")

function RogueItemIcon:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  self.m_icon = self.m_goRootTrans:Find("mask_item_icon/c_item_icon").gameObject
  self.m_icon_Image = self.m_goRootTrans:Find("mask_item_icon/c_item_icon"):GetComponent(T_Image)
  local tempGrayImage = self.m_goRootTrans:Find("mask_item_icon/c_item_icon_gray")
  if tempGrayImage then
    self.m_icon_Image_Gray = tempGrayImage:GetComponent(T_Image)
  end
  self.m_square_icon_Image = self.m_goRootTrans:Find("c_img_square"):GetComponent(T_Image)
  self.m_pnl_type = self.m_goRootTrans:Find("c_pnl_type")
  self.m_type_Image = self.m_goRootTrans:Find("c_pnl_type/c_img_type"):GetComponent(T_Image)
  self.m_txt_type_Text = self.m_goRootTrans:Find("c_pnl_type/c_txt_type"):GetComponent(T_TextMeshProUGUI)
  self.m_pnl_lock = self.m_goRootTrans:Find("c_pnl_lock")
  self.m_txt_name_Text = self.m_goRootTrans:Find("img_bg_name/c_txt_name"):GetComponent(T_TextMeshProUGUI)
  self.m_img_framevx = self.m_goRootTrans:Find("c_img_framevx")
  self.m_exclusive = self.m_goRootTrans:Find("c_img_exclusive")
  self.m_frameallowed = self.m_goRootTrans:Find("c_img_frameallowed")
  self.m_frameunallowed = self.m_goRootTrans:Find("c_img_frameunallowed")
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
end

function RogueItemIcon:SetItemInfo(info)
  local itemId = info.itemId
  if not itemId then
    return
  end
  local itemCfg = RogueStageItemInfoIns:GetValue_ByItemID(itemId)
  if not itemCfg or itemCfg:GetError() == true then
    return
  end
  self.m_txt_name_Text.text = itemCfg.m_mItemName
  UILuaHelper.SetAtlasSprite(self.m_icon_Image, itemCfg.m_ItemIcon, function()
    if self and not utils.isNull(self.m_icon_Image) then
      self.m_icon_Image:SetNativeSize()
    end
  end)
  if self.m_icon_Image_Gray then
    UILuaHelper.SetAtlasSprite(self.m_icon_Image_Gray, itemCfg.m_ItemIcon, function()
      if self and not utils.isNull(self.m_icon_Image_Gray) then
        self.m_icon_Image_Gray:SetNativeSize()
      end
    end)
  end
  UILuaHelper.SetAtlasSprite(self.m_square_icon_Image, itemCfg.m_VolumeIcon, function()
    if self and not utils.isNull(self.m_square_icon_Image) then
      self.m_square_icon_Image:SetNativeSize()
    end
  end)
  local cfg = self.m_levelRogueStageHelper:GetRougeItemSubTypeInfoCfgBySubType(itemCfg.m_ItemSubType)
  if cfg then
    UILuaHelper.SetAtlasSprite(self.m_type_Image, cfg.m_TypeIcon)
    local color = utils.changeCSArrayToLuaTable(cfg.m_TypeColor)
    UILuaHelper.SetColor(self.m_square_icon_Image, table.unpack(color))
    self.m_txt_type_Text.text = cfg.m_mTypeName
  end
  if not utils.isNull(self.m_pnl_lock) then
    UILuaHelper.SetActive(self.m_pnl_lock, info.unlock)
  end
  UILuaHelper.SetActive(self.m_pnl_type, not info.hideType)
  if not utils.isNull(self.m_img_framevx) then
    UILuaHelper.SetActive(self.m_img_framevx, info.showAnim and info.synthesisFlag)
  end
  if not utils.isNull(self.m_exclusive) then
    UILuaHelper.SetActive(self.m_exclusive, itemCfg.m_ItemSubType == RogueStageManager.RogueStageItemSubType.CharacterEquip)
  end
  local posCfg = self.m_levelRogueStageHelper:GetRogueItemIconPosById(itemId)
  if info.useTipsPos then
    if posCfg and posCfg.m_TipsPos then
      local posTab = utils.changeCSArrayToLuaTable(posCfg.m_TipsPos)
      if posTab and posTab[1] then
        UILuaHelper.SetLocalPosition(self.m_icon, posTab[1], posTab[2], 0)
      end
      if posTab[3] then
        local scale = posTab[3] * 0.01
        UILuaHelper.SetLocalScale(self.m_icon, scale, scale, 1)
        if self.m_icon_Image_Gray then
          UILuaHelper.SetLocalScale(self.m_icon_Image_Gray, scale, scale, 1)
        end
      end
    end
  elseif posCfg and posCfg.m_CombinationPos then
    local posTab = utils.changeCSArrayToLuaTable(posCfg.m_CombinationPos)
    if posTab and posTab[1] then
      UILuaHelper.SetLocalPosition(self.m_icon, posTab[1], posTab[2], 0)
    end
    if posTab[3] then
      local scale = posTab[3] * 0.01
      UILuaHelper.SetLocalScale(self.m_icon, scale, scale, 1)
      if self.m_icon_Image_Gray then
        UILuaHelper.SetLocalScale(self.m_icon_Image_Gray, scale, scale, 1)
      end
    end
  end
  if not utils.isNull(self.m_frameallowed) then
    UILuaHelper.SetActive(self.m_frameallowed, info.sort == RogueStageManager.RegionTypeSort.Normal)
  end
  if not utils.isNull(self.m_frameunallowed) then
    UILuaHelper.SetActive(self.m_frameunallowed, info.sort == RogueStageManager.RegionTypeSort.Exclusive)
  end
  if info.isHave or not info.checkIsHave then
    if self.m_icon_Image_Gray then
      UILuaHelper.SetActive(self.m_icon_Image_Gray, false)
    end
    UILuaHelper.SetActive(self.m_icon_Image, true)
  else
    if self.m_icon_Image_Gray then
      UILuaHelper.SetActive(self.m_icon_Image_Gray, true)
    end
    UILuaHelper.SetActive(self.m_icon_Image, false)
  end
end

function RogueItemIcon:GetRootTrans()
  return self.m_goRoot.transform
end

function RogueItemIcon:OnDestroy()
end

return RogueItemIcon
