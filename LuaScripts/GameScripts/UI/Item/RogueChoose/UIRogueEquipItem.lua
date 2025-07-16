local UIItemBase = require("UI/Common/UIItemBase")
local UIRogueEquipItem = class("UIRogueEquipItem", UIItemBase)
local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local LimitDragDis = 0.1
local MaxCharacterCareerNum = 3
local __RogueItemPropertyRangeType = {
  all = 0,
  job = 1,
  camp = 2,
  character = 3
}
local __RogueItemPropertyRangeTips = {
  [0] = {id = 0, tips = 100701},
  [1] = {
    id = 1,
    tips = 100702,
    range = "m_Job"
  },
  [2] = {
    id = 2,
    tips = 100703,
    range = "m_Camp"
  },
  [3] = {
    id = 3,
    tips = 100704,
    range = "m_Character"
  }
}
local ATTR_COEFFICIENT = 100.0

function UIRogueEquipItem:OnInit()
  if self.m_itemInitData then
    self.m_itemEnterDragBackFun = self.m_itemInitData.itemEnterDragBackFun
    self.m_itemDragBackFun = self.m_itemInitData.itemDragBackFun
    self.m_itemDragEndBackFun = self.m_itemInitData.itemDragEndBackFun
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_item_icon_drag_Btn_Ex = self.m_item_icon_drag:GetComponent("ButtonExtensions")
  if self.m_item_icon_drag_Btn_Ex then
    self.m_item_icon_drag_Btn_Ex.BeginDrag = handler(self, self.OnItemIconBeginDrag)
    self.m_item_icon_drag_Btn_Ex.Drag = handler(self, self.OnItemIconDrag)
    self.m_item_icon_drag_Btn_Ex.EndDrag = handler(self, self.OnItemIconEndDrag)
    self.m_item_icon_drag_Btn_Ex.Clicked = handler(self, self.OnItemIconClk)
  end
  if not utils.isNull(self.m_btn_rogue_right_item) then
    self.m_btn_rogue_right_item_Btn_Ex = self.m_btn_rogue_right_item:GetComponent("ButtonExtensions")
    if self.m_btn_rogue_right_item_Btn_Ex then
      self.m_btn_rogue_right_item_Btn_Ex.Clicked = handler(self, self.OnItemClk)
    end
  end
  self.m_equipItemData = nil
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
end

function UIRogueEquipItem:OnFreshData()
  self.m_showHeroWearEquipped = false
  self.m_equipItemData = self.m_itemData
  if not self.m_equipItemData then
    return
  end
  self:FreshItemUI()
end

function UIRogueEquipItem:GetAttrInfoList(attrList)
  local attrInfoList = {}
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  for i, attr in ipairs(attrList) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(attr[1])
    local paramNum = math.floor(attr[2]) or 0
    if propertyIndexCfg.m_Type == 2 then
      paramNum = paramNum / ATTR_COEFFICIENT
      paramNum = string.format(ConfigManager:GetCommonTextById(100009), tostring(paramNum))
    end
    local des = ""
    local info = __RogueItemPropertyRangeTips[attr[3]]
    if info then
      des = self:GetRangeInfoStr(info)
    end
    attrInfoList[#attrInfoList + 1] = {
      name = propertyIndexCfg.m_mCNName,
      num = paramNum,
      id = attr[1],
      des = des
    }
  end
  return attrInfoList
end

function UIRogueEquipItem:GetRangeInfoStr(info)
  if not info or not info.range then
    return ConfigManager:GetCommonTextById(info.tips)
  end
  local itemCfg = self.m_equipItemData.rogueStageItemCfg
  local str = ""
  local ranges = {}
  if type(itemCfg[info.range]) == "number" then
    ranges = {
      itemCfg[info.range]
    }
  else
    ranges = utils.changeCSArrayToLuaTable(itemCfg[info.range])
  end
  if table.getn(ranges) > 0 then
    if info.id == __RogueItemPropertyRangeType.job then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetCharacterCareerCfgByCareer(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mCareerName .. "</color>"
        end
      end
    elseif info.id == __RogueItemPropertyRangeType.camp then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetCharacterCampCfgByCamp(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mCampName .. "</color>"
        end
      end
    elseif info.id == __RogueItemPropertyRangeType.character then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetHeroConfigByID(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mName .. "</color>"
        end
      end
    end
  end
  return string.gsubnumberreplace(ConfigManager:GetCommonTextById(info.tips), str)
end

function UIRogueEquipItem:GetPropertySkillDesc()
  if not self.m_equipItemData then
    return
  end
  local showStrTab = {}
  local itemCfg = self.m_equipItemData.rogueStageItemCfg
  if itemCfg.m_mItemDesc2 ~= "" and itemCfg.m_mItemDesc2 ~= " " then
    local skillStr = itemCfg.m_mItemDesc2
    showStrTab[#showStrTab + 1] = skillStr
  end
  local propertyList = utils.changeCSArrayToLuaTable(itemCfg.m_ItemProperty)
  if table.getn(propertyList) > 0 then
    local list = self:GetAttrInfoList(propertyList)
    if list and next(list) then
      for i, info in ipairs(list) do
        local propertyNameStr = info.name .. "+" .. info.num
        showStrTab[#showStrTab + 1] = propertyNameStr
        local desStr = info.des
        showStrTab[#showStrTab + 1] = desStr
      end
    end
  end
  return table.concat(showStrTab, "\n")
end

function UIRogueEquipItem:FreshItemUI()
  if not self.m_equipItemData then
    return
  end
  self.m_txt_property_name_Text.text = self.m_equipItemData.rogueStageItemCfg.m_mItemName
  self.m_txt_property_des_Text.text = self:GetPropertySkillDesc() or ""
  UILuaHelper.SetAtlasSprite(self.m_item_icon_Image, self.m_equipItemData.rogueStageItemCfg.m_ItemIcon, function()
    if self and not utils.isNull(self.m_item_icon_Image) then
      self.m_item_icon_Image:SetNativeSize()
    end
  end)
  local maskIcon = self.m_equipItemData.rogueStageItemCfg.m_MaskIcon
  UILuaHelper.SetActive(self.m_item_icon_dust, maskIcon and maskIcon ~= "")
  if maskIcon and maskIcon ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_item_icon_black_Image, self.m_equipItemData.rogueStageItemCfg.m_ItemIcon, function()
      if self and not utils.isNull(self.m_item_icon_black_Image) then
        self.m_item_icon_black_Image:SetNativeSize()
      end
    end)
  end
  UILuaHelper.SetActive(self.m_item_icon_black, maskIcon and maskIcon ~= "")
  UILuaHelper.SetActive(self.m_bg_item_bg_cover, maskIcon and maskIcon ~= "")
  UILuaHelper.SetAtlasSprite(self.m_item_volume_icon_Image, self.m_equipItemData.rogueStageItemCfg.m_VolumeIcon, function()
    if self and not utils.isNull(self.m_item_volume_icon_Image) then
      self.m_item_volume_icon_Image:SetNativeSize()
    end
  end)
  self:FreshHeroCampShow()
  self:FreshIsHaveChooseStatus()
  local cfg = self.m_levelRogueStageHelper:GetRougeItemSubTypeInfoCfgBySubType(self.m_equipItemData.rogueStageItemCfg.m_ItemSubType)
  if cfg then
    UILuaHelper.SetAtlasSprite(self.m_img_tag_Image, cfg.m_TypeIcon)
    if not utils.isNull(self.m_txt_tag_Text) then
      self.m_txt_tag_Text.text = cfg.m_mTypeName
    end
    local color = utils.changeCSArrayToLuaTable(cfg.m_TypeColor)
    UILuaHelper.SetColor(self.m_item_volume_icon_Image, table.unpack(color))
  end
  local posCfg = self.m_levelRogueStageHelper:GetRogueItemIconPosById(self.m_equipItemData.rogueStageItemCfg.m_ItemID)
  if posCfg and posCfg.m_BagItemPos then
    local posTab = utils.changeCSArrayToLuaTable(posCfg.m_BagItemPos)
    if posTab and posTab[1] then
      UILuaHelper.SetLocalPosition(self.m_item_icon, posTab[1], posTab[2], 0)
      UILuaHelper.SetLocalPosition(self.m_item_icon_black, posTab[1], posTab[2], 0)
    end
    if posTab[3] then
      local scale = posTab[3] * 0.01
      UILuaHelper.SetLocalScale(self.m_item_icon, scale, scale, 1)
      UILuaHelper.SetLocalScale(self.m_item_icon_black, scale, scale, 1)
    end
  end
end

function UIRogueEquipItem:FreshIsHaveChooseStatus()
  UILuaHelper.SetActive(self.m_bg_equiped, self.m_equipItemData.isHaveChoose)
  UILuaHelper.SetActive(self.m_bg_wear_equiped, self.m_equipItemData.isHaveChoose and self.m_showHeroWearEquipped)
end

function UIRogueEquipItem:FreshHeroCampShow()
  local chapterID = self.m_equipItemData.rogueStageItemCfg.m_Character
  local characterCareerArray = self.m_equipItemData.rogueStageItemCfg.m_Job
  self.m_showHeroWearEquipped = false
  if chapterID ~= nil and chapterID ~= 0 then
    local heroConfig = HeroManager:GetHeroConfigByID(chapterID)
    if heroConfig then
      self.m_showHeroWearEquipped = true
      UILuaHelper.SetActive(self.m_bg_hero_wear, true)
      UILuaHelper.SetActive(self.m_pnl_camp, false)
      self:FreshHeadIcon(heroConfig.m_PerformanceID[0])
    else
      UILuaHelper.SetActive(self.m_bg_hero_wear, false)
      UILuaHelper.SetActive(self.m_pnl_camp, false)
    end
  elseif characterCareerArray and 0 < characterCareerArray.Length then
    UILuaHelper.SetActive(self.m_bg_hero_wear, false)
    UILuaHelper.SetActive(self.m_pnl_camp, true)
    local characterArrayLen = characterCareerArray.Length
    for i = 1, MaxCharacterCareerNum do
      UILuaHelper.SetActive(self["m_img_bg_icon" .. i], i <= characterArrayLen)
      if i <= characterArrayLen then
        self:FreshCareerIcon(self["m_icon" .. i .. "_Image"], characterCareerArray[i - 1])
      end
    end
  else
    UILuaHelper.SetActive(self.m_bg_hero_wear, false)
    UILuaHelper.SetActive(self.m_pnl_camp, false)
  end
  UILuaHelper.SetActive(self.m_bg_wear_equiped, false)
end

function UIRogueEquipItem:FreshHeadIcon(performanceIDLv)
  if not performanceIDLv then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceIDLv)
  if not presentationData.m_UIkeyword then
    return
  end
  if self.m_img_hero_Image then
    local szIcon = presentationData.m_UIkeyword .. "003"
    UILuaHelper.SetAtlasSprite(self.m_img_hero_Image, szIcon)
  end
end

function UIRogueEquipItem:FreshCareerIcon(careerIconImg, careerID)
  if not careerIconImg then
    return
  end
  if not careerID then
    return
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(careerID)
  if careerCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(careerIconImg, careerCfg.m_CareerIcon)
end

function UIRogueEquipItem:OnItemIconBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_equipItemData.isHaveChoose == true then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function UIRogueEquipItem:OnItemIconDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_equipItemData.isHaveChoose == true then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  if self.m_isDrag then
    if self.m_itemDragBackFun then
      self.m_itemDragBackFun(endPos)
    end
  else
    local deltaNumX = endPos.x - self.m_startDragPos.x
    local deltaNumY = endPos.y - self.m_startDragPos.y
    local dragDis = deltaNumX * deltaNumX + deltaNumY * deltaNumY
    if dragDis > LimitDragDis then
      if self.m_itemEnterDragBackFun then
        self.m_itemEnterDragBackFun(self.m_itemIndex, endPos)
      end
      self.m_isDrag = true
    end
  end
end

function UIRogueEquipItem:OnItemIconEndDrag(pointerEventData)
  if self.m_equipItemData.isHaveChoose == true then
    return
  end
  if not pointerEventData then
    return
  end
  if self.m_itemDragEndBackFun then
    self.m_itemDragEndBackFun(pointerEventData.position)
  end
  self.m_startDragPos = nil
  self.m_isDrag = nil
end

function UIRogueEquipItem:OnItemIconClk()
  if self.m_equipItemData.isHaveChoose then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex, self.m_itemRootObj.transform)
  end
end

return UIRogueEquipItem
