local ResourceUtil = {}
ResourceUtil.RESOURCE_TYPE = {
  ITEMS = 1001,
  HEROES = 20001,
  TREASURE = 30001,
  AFK = 40001,
  FRAGMENT = 50001,
  LEGACY = 90001,
  EQUIPS = 600001,
  ATTRACT_GIFT = 800001,
  HEAD_ICONS = 1300001,
  HEAD_FRAME_ICONS = 1400001,
  BackGround = 1600001,
  Fashion = 6000001
}

function ResourceUtil:GetProcessRewardData(data, customData)
  local data_id, data_num = data.iID or -1, data.iNum or 0
  if data_id == -1 then
    data_id = data[1] or -1
    data_num = data[2] or 0
  end
  if data_id == -1 then
    log.error("ResourceUtil:GetProcessRewardData  data type error")
    return
  end
  local data_type = ResourceUtil:GetResourceTypeById(data_id)
  local item_data = {
    name = "???",
    icon_name = "item_icon_wenhao",
    quality = 0,
    user_num = 0,
    data_type = data_type,
    data_id = data_id,
    data_num = data_num,
    atlas_name = "Atlas_Item/",
    description = "???",
    equipData = nil,
    heroData = nil,
    level = nil,
    equipType = nil,
    canUse = false,
    useLimit = 0,
    camp = nil,
    item_use = nil,
    in_bag = nil,
    is_selected = false,
    is_have_get = false,
    percentage = nil,
    combat = nil,
    combat_difference = nil,
    sub_type = nil,
    config = nil,
    showRedPoint = nil,
    sel_upgrade_item_num = nil,
    equip_bg = nil,
    is_extra = false,
    is_can_get = false
  }
  item_data.is_extra = customData and customData.is_extra
  item_data.is_can_get = customData and customData.is_can_get
  if data_type == ResourceUtil.RESOURCE_TYPE.EQUIPS then
    local cfg = EquipManager:GetEquipCfgByBaseId(data_id)
    item_data.name = cfg.m_mEquipName
    item_data.quality = cfg.m_Quality
    item_data.equipType = cfg.m_EquiptypeRes
    item_data.icon_name = cfg.m_IconPath
    item_data.description = cfg.m_mEquipDesc
    item_data.config = cfg
    item_data.sub_type = ItemManager.ItemSubType.Equipment
    if customData then
      item_data.equipData = customData
      item_data.level = customData.iLevel
      item_data.percentage = customData.percentage
      item_data.combat = customData.combat
      item_data.equip_bg = customData.equip_bg
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
      item_data.sel_upgrade_item_num = customData.sel_upgrade_item_num
      if customData.iLevel and customData.combat_other then
        local flag = EquipManager:CheckIsShowCampAttAddExtByCfgId(data_id, customData.equipHeroId)
        local combat = CombatUtil:CalculateEquipCombatsByLv(data_id, customData.iLevel, flag)
        if 0 < combat then
          item_data.combat_difference = combat - customData.combat_other
        end
      end
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.LEGACY then
    local cfg = LegacyManager:GetLegacyCfgByID(data_id)
    item_data.quality = cfg.m_Quality
    item_data.icon_name = cfg.m_Icon
    if customData then
      item_data.level = customData.iLevel or 1
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.Fashion then
    local cfg = HeroManager:GetHeroFashion():GetFashionInfoByID(data_id)
    item_data.name = cfg.m_mFashionName
    item_data.quality = cfg.m_Quality
    item_data.icon_name = cfg.m_FashionItemPic
    if customData then
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.HEROES then
    local characterIns = ConfigManager:GetConfigInsByName("CharacterInfo")
    local cfg = characterIns:GetValue_ByHeroID(data_id)
    if cfg:GetError() then
      log.error("can not find hero id in CharacterInfo config  id==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mName
    item_data.quality = cfg.m_Quality
    item_data.icon_name = self:GetHeroIconPath(data_id) or cfg.m_ItemIcon
    item_data.description = cfg.m_mTipDescript
    item_data.camp = cfg.m_Camp
    item_data.career = cfg.m_Career
    item_data.config = cfg
    if customData then
      item_data.heroData = customData
      item_data.level = customData.iLevel
      item_data.combat = customData.combat
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.FRAGMENT then
    local cfg = CS.CData_Item.GetInstance():GetValue_ByItemID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData GetValue_ByItemID is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mItemName
    item_data.quality = cfg.m_ItemRarity
    item_data.icon_name = item_data.atlas_name .. cfg.m_IconPath
    item_data.description = cfg.m_mItemDesc
    item_data.canUse = cfg.m_CanUse
    item_data.useLimit = cfg.m_Uselimit
    item_data.item_use = cfg.m_ItemUse
    item_data.config = cfg
    item_data.user_num = ItemManager:GetItemNum(data_id)
    item_data.sub_type = cfg.m_ItemSubType
    item_data.showRedPoint = false
    if customData then
      item_data.in_bag = customData.bBag
      item_data.percentage = customData.percentage
      if customData.bBag then
        item_data.showRedPoint = customData.showRedPoint ~= nil and customData.showRedPoint or ItemManager:CheckFragmentCertainRedPointById(data_id, item_data.user_num)
      end
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.ATTRACT_GIFT then
    local cfg = CS.CData_Item.GetInstance():GetValue_ByItemID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData GetValue_ByItemID is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mItemName
    item_data.quality = cfg.m_ItemRarity
    item_data.icon_name = item_data.atlas_name .. cfg.m_IconPath
    item_data.description = cfg.m_mItemDesc
    item_data.canUse = cfg.m_CanUse
    item_data.item_use = cfg.m_ItemUse
    item_data.useLimit = cfg.m_Uselimit
    item_data.sub_type = cfg.m_ItemSubType
    item_data.config = cfg
    item_data.user_num = ItemManager:GetItemNum(data_id)
    if customData then
      item_data.in_bag = customData.bBag
      item_data.percentage = customData.percentage
      item_data.sel_upgrade_item_num = customData.sel_upgrade_item_num
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.HEAD_ICONS then
    local cfg = CS.CData_PlayerHead.GetInstance():GetValue_ByHeadID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData PlayerHead_Element is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.mItemName
    item_data.icon_name = cfg.m_ItemIcon
    item_data.description = cfg.m_mHeadDesc
    item_data.quality = cfg.m_ItemRarity
    item_data.config = cfg
    if customData then
      item_data.in_bag = customData.bBag
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.HEAD_FRAME_ICONS then
    local cfg = CS.CData_PlayerHeadFrame.GetInstance():GetValue_ByHeadFrameID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData GetValue_ByHeadFrameID is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mItemName
    item_data.quality = cfg.m_ItemRarity
    item_data.icon_name = cfg.m_ItemIcon
    item_data.description = cfg.m_mHeadFrameDesc
    item_data.config = cfg
    if customData then
      item_data.in_bag = customData.bBag
      item_data.percentage = customData.percentage
    end
  elseif data_type == ResourceUtil.RESOURCE_TYPE.BackGround then
    local cfg = CS.CData_MainBackground.GetInstance():GetValue_ByBDID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData GetValue_ByBDID is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mItemName
    item_data.icon_name = cfg.m_ItemIcon
    item_data.description = cfg.m_mItemDec
    item_data.config = cfg
    if customData then
      item_data.in_bag = customData.bBag
      item_data.percentage = customData.percentage
    end
  else
    local cfg = CS.CData_Item.GetInstance():GetValue_ByItemID(data_id)
    if cfg:GetError() then
      log.error("ResourceUtil GetProcessRewardData GetValue_ByItemID is error id ==" .. tostring(data_id))
      return
    end
    item_data.name = cfg.m_mItemName
    item_data.quality = cfg.m_ItemRarity
    item_data.icon_name = item_data.atlas_name .. cfg.m_IconPath
    item_data.description = cfg.m_mItemDesc
    item_data.canUse = cfg.m_CanUse
    item_data.item_use = cfg.m_ItemUse
    item_data.useLimit = cfg.m_Uselimit
    item_data.sub_type = cfg.m_ItemSubType
    item_data.config = cfg
    item_data.user_num = ItemManager:GetItemNum(data_id)
    item_data.showRedPoint = false
    if customData then
      item_data.percentage = customData.percentage
      item_data.sel_upgrade_item_num = customData.sel_upgrade_item_num
      item_data.is_selected = customData.is_selected
      item_data.is_have_get = customData.is_have_get
      item_data.in_bag = customData.bBag
      if customData.bBag then
        item_data.showRedPoint = ItemManager:CheckImportantItemShowRedPoint(data_id)
      end
    end
  end
  return item_data
end

function ResourceUtil:GetResourceTypeById(id)
  local resourceType = ResourceUtil.RESOURCE_TYPE.ITEMS
  if id >= MTTDProto.ItemIdSeg_Resource_Min and id <= MTTDProto.ItemIdSeg_Resource_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.ITEMS
  elseif id >= MTTDProto.ItemIdSeg_HeroCard_Min and id <= MTTDProto.ItemIdSeg_HeroCard_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.HEROES
  elseif id >= MTTDProto.ItemIdSeg_Treasure_Min and id <= MTTDProto.ItemIdSeg_Treasure_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.TREASURE
  elseif id >= MTTDProto.ItemIdSeg_Afk_Min and id <= MTTDProto.ItemIdSeg_Afk_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.AFK
  elseif id >= MTTDProto.ItemIdSeg_Fragment_Min and id <= MTTDProto.ItemIdSeg_Fragment_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.FRAGMENT
  elseif id >= MTTDProto.ItemIdSeg_Legacy_Min and id <= MTTDProto.ItemIdSeg_Legacy_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.LEGACY
  elseif id >= MTTDProto.ItemIdSeg_Equip_Min and id <= MTTDProto.ItemIdSeg_Equip_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.EQUIPS
  elseif id >= MTTDProto.ItemIdSeg_Attract_Min and id <= MTTDProto.ItemIdSeg_Attract_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.ATTRACT_GIFT
  elseif id >= MTTDProto.ItemIdSeg_Head_Min and id <= MTTDProto.ItemIdSeg_Head_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.HEAD_ICONS
  elseif id >= MTTDProto.ItemIdSeg_HeadFrame_Min and id <= MTTDProto.ItemIdSeg_HeadFrame_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.HEAD_FRAME_ICONS
  elseif id >= MTTDProto.ItemIdSeg_MainBackground_Min and id <= MTTDProto.ItemIdSeg_MainBackground_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.BackGround
  elseif id >= MTTDProto.ItemIdSeg_Fashion_Min and id <= MTTDProto.ItemIdSeg_Fashion_Max then
    resourceType = ResourceUtil.RESOURCE_TYPE.Fashion
  end
  return resourceType
end

function ResourceUtil:CreatIconById(imageItem, id)
  if not imageItem or not id then
    log.error("ResourceUtil CreatIconById  imageItem or id is nil ")
    return
  end
  id = tonumber(id)
  if id >= MTTDProto.ItemIdSeg_Resource_Min and id <= MTTDProto.ItemIdSeg_Resource_Max then
    self:CreateItemIcon(imageItem, id)
  elseif id >= MTTDProto.ItemIdSeg_Equip_Min and id <= MTTDProto.ItemIdSeg_Equip_Max then
    self:CreateEquipIcon(imageItem, id)
  elseif id >= MTTDProto.ItemIdSeg_Head_Min and id <= MTTDProto.ItemIdSeg_Head_Max then
    self:CreateHeroHeadIcon(imageItem, id)
  elseif id >= MTTDProto.ItemIdSeg_Legacy_Min and id <= MTTDProto.ItemIdSeg_Legacy_Max then
    self:CreateLegacyIcon(imageItem, id)
  elseif id >= MTTDProto.ItemIdSeg_HeadFrame_Min and id <= MTTDProto.ItemIdSeg_HeadFrame_Max then
    self:CreateHeadFrameIcon(imageItem, id)
  elseif id >= MTTDProto.ItemIdSeg_Fashion_Min and id <= MTTDProto.ItemIdSeg_Fashion_Max then
    self:CreateFashionIcon(imageItem, id)
  else
    self:CreateItemIcon(imageItem, id)
  end
end

function ResourceUtil:CreateIconByPath(imageItem, imgPath)
  if not imageItem or not imgPath then
    log.error("ResourceUtil:CreateIconByPath imageItem or imgPath == nil")
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, imgPath)
end

function ResourceUtil:CreateItemIcon(imageItem, itemID)
  local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(itemID)
  if stItemData:GetError() then
    log.error("ResourceUtil createItemIcon item id  " .. tostring(itemID))
    return
  end
  if not stItemData.m_IconPath then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, "Atlas_Item/" .. stItemData.m_IconPath, nil, nil, true)
end

function ResourceUtil:CreateEquipIcon(imageItem, equipID)
  local stItemData = EquipManager:GetEquipCfgByBaseId(equipID)
  if not stItemData then
    log.error("ResourceUtil createEquipIcon equipID id  " .. tostring(equipID))
    return
  end
  if not stItemData.m_IconPath then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.m_IconPath, nil, nil, true)
end

function ResourceUtil:CreateEquipQualityImg(imageItem, equipQuality, styleId)
  local stItemData = GlobalConfig.QUALITY_EQUIP_SETTING[equipQuality]
  if not stItemData then
    log.error("ResourceUtil createEquipQualityImg equipQuality  " .. tostring(equipQuality))
    return
  end
  local icon = stItemData.icon
  if styleId and styleId ~= 1 then
    icon = stItemData["icon" .. styleId]
  end
  if not icon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, icon, nil, nil, true)
end

function ResourceUtil:CreateQualityImg(imageItem, quality)
  local stItemData = GlobalConfig.QUALITY_COMMON_SETTING[quality]
  if not stItemData then
    log.error("ResourceUtil CreateQualityImg quality  " .. tostring(quality))
    return
  end
  if not stItemData.icon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.icon, nil, nil, true)
end

function ResourceUtil:CreateQualityTipsBgImg(imageItem, quality)
  local stItemData = GlobalConfig.QUALITY_COMMON_SETTING[quality]
  if not stItemData then
    log.error("ResourceUtil CreateQualityImg quality  " .. tostring(quality))
    return
  end
  if not stItemData.tips_bg then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.tips_bg, nil, nil, true)
end

function ResourceUtil:CreateCareerImg(imageItem, career)
  local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
  local stItemData = CareerCfgIns:GetValue_ByCareerID(career)
  if stItemData:GetError() then
    log.error("ResourceUtil createCareerImg equipCareer  " .. tostring(career))
    return
  end
  if not stItemData.m_CareerIcon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.m_CareerIcon, nil, nil, true)
end

function ResourceUtil:CreateEquipTypeImg(imageItem, equipType)
  if not imageItem then
    return
  end
  local EquipTypeCfgIns = ConfigManager:GetConfigInsByName("EquipType")
  local stItemData = EquipTypeCfgIns:GetValue_ByEquiptypeID(equipType)
  if stItemData:GetError() then
    log.error("ResourceUtil CreateEquipTypeImg equipType  " .. tostring(equipType))
    return
  end
  if not stItemData.m_EquiptypeIcon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.m_EquiptypeIcon, nil, nil, true)
end

function ResourceUtil:CreateCampImg(imageItem, camp, field)
  local icon
  if camp == 0 then
    icon = "Atlas_CharacterCamp/Camp_icon_all"
    CS.UI.UILuaHelper.SetAtlasSprite(imageItem, icon, nil, nil, true)
    return
  end
  local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
  local stItemData = CampCfgIns:GetValue_ByCampID(camp)
  if stItemData:GetError() then
    return
  end
  if not stItemData.m_CampIcon then
    return
  end
  if field then
    icon = stItemData["m_" .. field]
  else
    icon = stItemData.m_CampIcon
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, icon, nil, nil, true)
end

function ResourceUtil:CreateEquipCampImg(imageItem, camp)
  local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
  local stItemData = CampCfgIns:GetValue_ByCampID(camp)
  if stItemData:GetError() then
    log.error("ResourceUtil createCampImg camp  " .. tostring(camp))
    return
  end
  if not stItemData.m_CampIcon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.m_CampIcon, nil, nil, true)
end

function ResourceUtil:CreateEquipCommonQualityImg(imageItem, quality)
  local stItemData = GlobalConfig.QUALITY_EQUIP_SETTING[quality]
  if not stItemData then
    log.error("ResourceUtil CreateEquipCommonQualityImg quality  " .. tostring(quality))
    return
  end
  if not stItemData.BgImage then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.BgImage, nil, nil, true)
end

function ResourceUtil:CreateEquipCommonIconImg(imageItem, quality)
  local stItemData = GlobalConfig.QUALITY_EQUIP_SETTING[quality]
  if not stItemData then
    log.error("ResourceUtil CreateEquipCommonQualityImg quality  " .. tostring(quality))
    return
  end
  if not stItemData.itemIcon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.itemIcon, nil, nil, true)
end

function ResourceUtil:CreateHeroHeadIcon(imageItem, heroId, star)
  if not heroId then
    return
  end
  star = star or 1
  local characterIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  local InGameCharacterIns = characterIns:GetValue_ByHeroID(heroId)
  if InGameCharacterIns:GetError() or not InGameCharacterIns.m_ItemIcon then
    return
  end
  local szIcon = InGameCharacterIns.m_ItemIcon
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, szIcon, nil, nil, true)
end

function ResourceUtil:CreateHeroIcon(imageItem, heroId)
  if not heroId then
    return
  end
  local szIcon = self:GetHeroIconPath(heroId)
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, szIcon, nil, nil, true)
end

function ResourceUtil:CreateLegacyIcon(imageItem, legacyId)
  if not legacyId then
    return
  end
  local config = LegacyManager:GetLegacyCfgByID(legacyId)
  if not config then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, config.m_Icon, nil, nil, true)
end

function ResourceUtil:CreateHeadFrameIcon(imageItem, headFrameID)
  if not headFrameID then
    return
  end
  local config = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not config then
    return
  end
  UILuaHelper.SetAtlasSprite(imageItem, config.m_ItemIcon, nil, nil, true)
end

function ResourceUtil:CreateFashionIcon(imageItem, fashionID)
  if not fashionID then
    return
  end
  local config = HeroManager:GetHeroFashion():GetFashionInfoByID(fashionID)
  if not config then
    return
  end
  UILuaHelper.SetAtlasSprite(imageItem, config.m_FashionItemPic, nil, nil, true)
end

function ResourceUtil:CreateFashionBust(imageItem, fashionID)
  if not fashionID then
    return
  end
  local config = HeroManager:GetHeroFashion():GetFashionInfoByID(fashionID)
  if not config then
    return
  end
  local m_PerformanceID = config.m_PerformanceID[0]
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(imageItem, szIcon, nil, nil, true)
end

function ResourceUtil:CreatHeroBust(imageItem, heroId, iFasionId)
  local m_PerformanceID
  iFasionId = iFasionId or 0
  local fashionCfg = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroId, iFasionId)
  if not fashionCfg then
    return
  end
  m_PerformanceID = fashionCfg.m_PerformanceID[0]
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(imageItem, szIcon, nil, nil, true)
end

function ResourceUtil:GetHeroIconPath(heroId, heroCfg)
  local m_PerformanceID
  if not heroCfg then
    local characterIns = ConfigManager:GetConfigInsByName("CharacterInfo")
    local InGameCharacterIns = characterIns:GetValue_ByHeroID(heroId)
    if InGameCharacterIns:GetError() or not InGameCharacterIns.m_PerformanceID then
      return
    end
    m_PerformanceID = InGameCharacterIns.m_PerformanceID[0]
  elseif heroCfg.m_PerformanceID then
    m_PerformanceID = heroCfg.m_PerformanceID[0]
  end
  if not m_PerformanceID then
    return
  end
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  return presentationData.m_UIkeyword .. "002"
end

function ResourceUtil:GetHeroSkinIconPath(skinId, skinCfg)
  local m_PerformanceID
  if not skinCfg then
    local fashionInfoIns = ConfigManager:GetConfigInsByName("FashionInfo")
    local InGameCharacterSkinIns = fashionInfoIns:GetValue_ByFashionID(skinId)
    if InGameCharacterSkinIns:GetError() or not InGameCharacterSkinIns.m_PerformanceID then
      return
    end
    m_PerformanceID = InGameCharacterSkinIns.m_PerformanceID[0]
  elseif skinCfg.m_PerformanceID then
    m_PerformanceID = skinCfg.m_PerformanceID[0]
  end
  if not m_PerformanceID then
    return
  end
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  return presentationData.m_UIkeyword .. "003"
end

function ResourceUtil:CreateHeroSSRQualityImg(imageItem, quality)
  local stItemData = GlobalConfig.QUALITY_COMMON_SETTING[quality]
  if not stItemData then
    log.error("ResourceUtil CreateQualityImg quality  " .. tostring(quality))
    return
  end
  if not stItemData.character_icon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.character_icon, nil, nil, true)
end

function ResourceUtil:CreateEquipPosImg(imageItem, pos)
  local stItemData = CS.CData_EquipPos.GetInstance():GetValue_ByPosRes(pos)
  if stItemData:GetError() then
    log.error("ResourceUtil createEquipPosImg pos  " .. tostring(pos))
    return
  end
  if not stItemData.m_posicon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, stItemData.m_posicon, nil, nil, true)
end

function ResourceUtil:CreateCommonItemBg(imageItem, itemId, customData, itemData)
  local iconName = "Atlas_CharacterQuality/common_icon_item_bg"
  if self:GetResourceTypeById(itemId) == ResourceUtil.RESOURCE_TYPE.EQUIPS and itemData and itemData.quality then
    local equipQuality = itemData.quality
    local stItemData = GlobalConfig.QUALITY_EQUIP_SETTING[equipQuality]
    if not stItemData then
      log.error("ResourceUtil createEquipQualityImg equipQuality  " .. tostring(equipQuality))
      return
    end
    if customData and customData.iOverloadHero and customData.iOverloadHero ~= 0 then
      stItemData = GlobalConfig.QUALITY_EQUIP_SETTING[10]
    end
    if stItemData.BgImage then
      iconName = stItemData.BgImage
    end
  end
  if self:GetResourceTypeById(itemId) ~= ResourceUtil.RESOURCE_TYPE.EQUIPS and itemData.quality == 4 then
    iconName = GlobalConfig.QUALITY_EQUIP_SETTING[9].BgImage
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, iconName, nil, nil, true)
end

function ResourceUtil:CreatePropertyImg(imageItem, propertyId, propertyType)
  local exName = "_01"
  if propertyType == 2 then
    exName = "_02"
  end
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(propertyId)
  if propertyIndexCfg:GetError() then
    log.error("ResourceUtil createEquipPosImg pos  " .. tostring(propertyId))
    return
  end
  if not propertyIndexCfg.m_PropertyIcon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, propertyIndexCfg.m_PropertyIcon .. exName, nil, nil, true)
end

function ResourceUtil:CreateBuffIcon(imageItem, buffID)
  local stItemData = CS.CData_SkillBuff.GetInstance():GetValue_ByBuffID(buffID)
  if stItemData:GetError() then
    log.error("ResourceUtil CreateBuffIcon buffID id  " .. tostring(buffID))
    return
  end
  if not stItemData.m_Icon then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, "Atlas_Buff/" .. stItemData.m_Icon, nil, nil, true)
end

function ResourceUtil:CreateCommonItemNode(parent, itemBase, processItemData, clickFun)
  if not (parent and itemBase) or not processItemData then
    return
  end
  local itemObj = GameObject.Instantiate(itemBase, parent.transform).gameObject
  local itemWidget = require("UI/Widgets/CommonItem").new(itemObj)
  itemWidget:SetItemInfo(processItemData)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    if clickFun then
      clickFun(itemID, itemNum, itemCom)
    end
  end)
  itemWidget:SetActive(true)
end

function ResourceUtil:CreateCommonItemGroup(parent, itemBase, itemData, clickFun, customDataTab)
  customDataTab = customDataTab or {}
  if not (parent and itemBase) or not itemData then
    return
  end
  for i, v in ipairs(itemData) do
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(v[1]),
      iNum = tonumber(v[2])
    }, customDataTab[i])
    self:CreateCommonItemNode(parent, itemBase, processItemData, clickFun)
  end
  itemBase:SetActive(false)
end

function ResourceUtil:CreateGuildIconById(imageItem, iconId)
  if utils.isNull(imageItem) or not iconId then
    return
  end
  local GuildBadgeIns = ConfigManager:GetConfigInsByName("GuildBadge")
  local cfg = GuildBadgeIns:GetValue_ByBadgeID(iconId)
  if cfg:GetError() then
    log.error("ResourceUtil CreateGuildIconById iconId  " .. tostring(iconId))
    return
  end
  if not cfg.m_IconPath then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, cfg.m_IconPath, nil, nil, true)
end

function ResourceUtil:CreateGuildPostIconByPost(imageItem, iPost)
  if not (not utils.isNull(imageItem) and iPost) or not GuildManager.AlliancePostInfo[iPost] then
    return
  end
  local iconName = GuildManager.AlliancePostInfo[iPost].icon
  if iconName == "" or not iconName then
    imageItem.gameObject:SetActive(false)
  else
    imageItem.gameObject:SetActive(true)
    CS.UI.UILuaHelper.SetAtlasSprite(imageItem, iconName, nil, nil, true)
  end
end

function ResourceUtil:CreateGuildGradeIconById(imageItem, gradeId)
  if utils.isNull(imageItem) or not gradeId then
    return
  end
  local GuildGradeIns = ConfigManager:GetConfigInsByName("GuildBattleGrade")
  local cfg = GuildGradeIns:GetValue_ByGradeID(gradeId)
  if cfg:GetError() then
    log.error("ResourceUtil CreateGuildGradeIconById gradeId  " .. tostring(gradeId))
    return
  end
  if not cfg.m_IconPath then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, cfg.m_IconPath, nil, nil, true)
end

function ResourceUtil:CreateGuildBossIconByName(imageItem, iconName)
  if utils.isNull(imageItem) or not iconName then
    return
  end
  CS.UI.UILuaHelper.SetAtlasSprite(imageItem, "Atlas_Guild/" .. iconName, nil, nil, true)
end

function ResourceUtil:CreateUIPrefab(prefab_name, subBack, failBack)
  local function successCB(uiName, uiObject)
    if subBack then
      subBack(uiObject)
    end
  end
  
  local function failedCB(errorStr)
    log.info("ModuleManger LoadSubUIPrefab Load Fail errorStr: ", errorStr)
    if failBack then
      failBack(errorStr)
    end
  end
  
  UIManager:LoadUIPrefab(prefab_name, successCB, failedCB)
end

function ResourceUtil:UnloadUIPrefab(prefab_name)
  CS.MUF.Resource.ResourceManager.UnloadAsset(prefab_name, CS.MUF.Resource.ResourceType.UI)
end

function ResourceUtil:CreatePrefab(prefab_name, parent)
  local prefab = CS.ResourceManager.LoadAsset(prefab_name, CS.MUF.Resource.ResourceType.Prefab)
  if prefab ~= nil then
    if parent then
      prefab.transform:SetParent(parent, false)
    end
  else
    Logger.logWarning(" 要创建的预制体 " .. prefab_name .. " 没有找到 ")
  end
  return prefab
end

function ResourceUtil:LoadPrefabAsync(prefab_name, callFun)
  CS.MUF.Resource.ResourceManager.LoadAssetAsync(prefab_name, CS.MUF.Resource.ResourceType.Prefab, function(result)
    if result.Status == CS.MUF.Resource.ELoadingStatus.Successed and callFun then
      callFun(result.Result)
    end
  end)
end

function ResourceUtil:UnLoadPrefabAsync(role_name)
  CS.MUF.Resource.ResourceManager.UnloadAsset(role_name, CS.MUF.Resource.ResourceType.Prefab)
end

function ResourceUtil:LoadRoleAsync(role_name, callback)
  CS.MUF.Resource.ResourceManager.LoadAssetAsync(role_name, CS.MUF.Resource.ResourceType.Role, function(result)
    if result.Status == CS.MUF.Resource.ELoadingStatus.Successed and callback then
      callback(result.Result)
    end
  end)
end

function ResourceUtil:UnloadRoleAsync(role_name)
  CS.MUF.Resource.ResourceManager.UnloadAsset(role_name, CS.MUF.Resource.ResourceType.Role)
end

function ResourceUtil:LoadUIPrefab(prefabStr, subBack, failBack)
  if not prefabStr then
    return
  end
  UIManager:LoadUIPrefab(prefabStr, function(uiName, uiObject)
    if subBack then
      subBack(uiObject)
    end
  end, function(errorStr)
    log.info("ResourceUtil LoadUIPrefab Load Fail errorStr: ", errorStr)
    if failBack then
      failBack(errorStr)
    end
  end)
end

function ResourceUtil:LoadPrefabAndBindLua(prefabPath, luaPath, parentObj, paramData, loadBack)
  if not prefabPath then
    return
  end
  if not luaPath then
    return
  end
  self:LoadUIPrefab(prefabPath, function(uiObject)
    local bindLua = require(luaPath).new(parentObj, uiObject, paramData)
    if parentObj then
      UILuaHelper.SetParent(uiObject, parentObj, true)
    end
    if loadBack then
      loadBack(bindLua)
    end
  end)
end

function ResourceUtil:CreateItem(item_base_obj, parentTransform)
  local cloneObj = GameObject.Instantiate(item_base_obj, parentTransform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  return cloneObj
end

return ResourceUtil
