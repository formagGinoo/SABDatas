local Form_EquipmentUpgrade = class("Form_EquipmentUpgrade", require("UI/UIFrames/Form_EquipmentUpgradeUI"))
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local INHERIT_SYNC_UNLOCK_COST = GlobalManagerIns:GetValue_ByName("EquipUpgradeItem").m_Value or ""
local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
local EQUIP_EXP_RATIO = GlobalManagerIns:GetValue_ByName("EquipEXPRatio").m_Value or ""
local EQUIP_PROTECT_QUALITY = tonumber(GlobalManagerIns:GetValue_ByName("EquipProtectQuality").m_Value) or 0
local EQUIP_CONFIRM_QUALITY = tonumber(GlobalManagerIns:GetValue_ByName("EquipConfirmQuality").m_Value) or 0
local vFilterTabConfig = {
  {iIndex = 1, sTitle = 2001}
}
local UPGRADE_COST_ITEM_ID = 999
local EquipmentUpgradeTips = "EquipmentUpgradeTips"

function Form_EquipmentUpgrade:SetInitParam(param)
end

function Form_EquipmentUpgrade:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEquipItemClk),
    itemDelClkBackFun = handler(self, self.OnEquipItemDelClk)
  }
  self.m_EquipListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_equip_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_EquipListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnEquipItemClk))
  local goFilterBtnRoot = goRoot.transform:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_commonEquipExpIds = string.split(INHERIT_SYNC_UNLOCK_COST, ",")
  ResourceUtil:CreateItemIcon(self.m_icon_resource_Image, UPGRADE_COST_ITEM_ID)
  EquipmentUpgradeTips = EquipmentUpgradeTips .. RoleManager:GetUID()
  self:createResourceBar(self.m_top_resource)
end

function Form_EquipmentUpgrade:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_equipDataList = {}
  self.m_allSortedItemDataList = {}
  self.m_isMaxLv = false
  self.m_selItemList = {}
  self.m_iFilterTabIndex = 1
  self.m_bFilterDown = false
  self.autoSelNum = nil
  self.m_upgradeEquipData = self.m_csui.m_param.equipData
  self.m_equipLv = self.m_upgradeEquipData.iLevel
  self.m_pos = self.m_csui.m_param.pos
  self.m_widgetBtnFilter:RefreshTabConfig(vFilterTabConfig, self.m_iFilterTabIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  self.m_equipCfg = EquipManager:GetEquipCfgByBaseId(self.m_upgradeEquipData.iBaseId)
  self:RefreshEquipList()
  self:RefreshUpgradeEquipment()
end

function Form_EquipmentUpgrade:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if not utils.isNull(self.m_sequence) then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
  self.autoSelNum = nil
end

function Form_EquipmentUpgrade:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_EquipmentUpgrade:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentUpgrade:RefreshUI(param)
  local iLevel = param.iLevel
  local truthLv = self.m_equipLv or 0
  if truthLv ~= iLevel then
    self.m_equipLv = iLevel
    self.m_upgradeEquipData.iExp = param.iExp
    StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTUPGRADETIPS, {
      equip_id = self.m_upgradeEquipData.iEquipUid,
      before_lv = truthLv,
      after_lv = iLevel,
      vReturnItem = param.vReturnItem
    })
    if self.m_isMaxLv == true then
      self:OnBtnCloseClicked()
    end
  end
  self.m_selItemList = {}
  self.m_FX_img_bar_over:SetActive(false)
  self.m_FX_img_bar_over:SetActive(true)
  self.m_sequence = Tweening.DOTween.Sequence()
  self.m_sequence:AppendInterval(1.5)
  self.m_sequence:OnComplete(function()
    if not utils.isNull(self.m_FX_img_bar_over) then
      self.m_FX_img_bar_over:SetActive(false)
    end
  end)
  self.m_sequence:SetAutoKill(true)
  self:RefreshEquipList()
  self:RefreshUpgradeEquipment()
end

function Form_EquipmentUpgrade:RefreshUpgradeEquipment(addExp)
  local equipData = EquipManager:GetEquipDataByID(self.m_upgradeEquipData.iEquipUid)
  local equipCfg = self.m_equipCfg
  if not equipData then
    log.error("RefreshUpgradeEquipment GetEquipDataByID is error")
    return
  end
  if equipCfg:GetError() then
    log.error("RefreshUpgradeEquipment GetEquipCfgByBaseId is error")
    return
  end
  if self.m_itemIcon == nil then
    self.m_itemIcon = self:createEquipIcon(self.m_item_equip)
  end
  self.m_itemIcon:SetEquipInfo({
    iID = equipData.iBaseId,
    iNum = 1
  })
  self.m_txt_reource_num_Text.text = math.ceil((addExp or 0) * tonumber(EQUIP_EXP_RATIO) / 10000)
  local curExp, lvUp = EquipManager:GetExpsCanUpgradeLvAndRemainingExp(equipData.iEquipUid, addExp)
  local levelTemplateID = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel + lvUp)
  if not lvCfg:GetError() and 0 < lvCfg.m_EXPConsume then
    local eXPConsume = lvCfg.m_EXPConsume
    self.m_img_bar_Image.fillAmount = curExp / tonumber(eXPConsume)
    self.m_txt_bar_num_Text.text = string.format(ConfigManager:GetCommonTextById(20048), curExp, eXPConsume)
    self.m_img_popo:SetActive(false)
    self.m_img_bar_over:SetActive(false)
    self.m_isMaxLv = false
  else
    local lvCfg2 = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel + lvUp - 1)
    if not lvCfg2:GetError() then
      self.m_img_bar_Image.fillAmount = 1
      self.m_txt_bar_num_Text.text = string.format(ConfigManager:GetCommonTextById(20048), curExp + lvCfg2.m_EXPConsume, lvCfg2.m_EXPConsume)
    end
    self.m_img_bar_over_Image.fillAmount = curExp / lvCfg2.m_EXPConsume
    self.m_img_bar_over:SetActive(0 < curExp)
    self.m_img_popo:SetActive(0 < curExp)
    self.m_isMaxLv = true
    self.m_txt_reource_num_Text.text = math.ceil(((addExp or 0) - curExp) * tonumber(EQUIP_EXP_RATIO) / 10000)
  end
  self.m_txt_lv_before_Text.text = equipData.iLevel
  self.m_txt_lv_after_Text.text = equipData.iLevel + lvUp
  self:RefreshAttrs(equipData.iBaseId, equipData.iLevel, lvUp)
  local userNum = ItemManager:GetItemNum(UPGRADE_COST_ITEM_ID)
  local needNum = tonumber(self.m_txt_reource_num_Text.text)
  if userNum > needNum then
    UILuaHelper.SetColor(self.m_txt_reource_num_Text, 0, 0, 0, 1)
  else
    UILuaHelper.SetColor(self.m_txt_reource_num_Text, 178, 69, 43, 1)
  end
end

function Form_EquipmentUpgrade:RefreshAttrs(iBaseId, lv, addLv)
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.m_upgradeEquipData.iEquipUid)
  local attrInfoList = {}
  if self.m_upgradeEquipData.iOverloadHero ~= 0 then
    attrInfoList = EquipManager:GetEquipOverLoadBaseAttr(iBaseId, lv)
  else
    attrInfoList = EquipManager:GetEquipBaseAttr(iBaseId, lv, flag)
  end
  local is_level_up = addLv and 0 < addLv
  local afterAttrInfoList
  if is_level_up then
    if self.m_upgradeEquipData.iOverloadHero ~= 0 then
      afterAttrInfoList = EquipManager:GetEquipOverLoadBaseAttr(iBaseId, lv + (addLv or 0))
    else
      afterAttrInfoList = EquipManager:GetEquipBaseAttr(iBaseId, lv + (addLv or 0), flag)
    end
    is_level_up = afterAttrInfoList and true or false
  end
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    if attrInfo and attrInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_icon_sx" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_sx_name" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_before_sx_num" .. i .. "_Text"].text = tostring(attrInfo.num)
      self["m_before_num" .. i .. "_Text"].text = tostring(attrInfo.num)
    end
    if afterAttrInfoList then
      local afterAttrInfo = afterAttrInfoList[i]
      if afterAttrInfo then
        self["m_after_sx_num" .. i .. "_Text"].text = tostring(afterAttrInfo.num)
      end
    else
      self["m_after_sx_num" .. i .. "_Text"].text = ""
    end
    self["m_pnl_change" .. i]:SetActive(is_level_up)
    self["m_before_sx_num" .. i]:SetActive(not is_level_up)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self["m_pnl_change" .. i]:GetComponent("RectTransform"))
  end
end

function Form_EquipmentUpgrade:OnFilterChanged(iIndex, bDown)
  self.m_iFilterTabIndex = iIndex
  self.m_bFilterDown = bDown
  self:RefreshEquipList()
end

function Form_EquipmentUpgrade:RefreshEquipList()
  self.m_equipDataList = EquipManager:GetUnEquippedEquipsById(self.m_upgradeEquipData.iEquipUid)
  self.m_allSortedItemDataList = self:GeneratedListData(self.m_equipDataList)
  if #self.m_allSortedItemDataList > 0 then
    self.m_equip_list:SetActive(true)
    self.m_EquipListInfinityGrid:ShowItemList(self.m_allSortedItemDataList)
    self.m_EquipListInfinityGrid:LocateTo(0)
  else
    self.m_equip_list:SetActive(false)
  end
end

function Form_EquipmentUpgrade:GeneratedListData(equipList)
  local dataList = {}
  for i, v in ipairs(equipList) do
    local data = {
      iID = v.iBaseId,
      iNum = 1,
      customData = {
        iEquipUid = v.iEquipUid,
        iLevel = v.iLevel,
        iExp = v.iExp,
        iHeroId = v.iHeroId,
        optimizing = true
      }
    }
    if self.m_selItemList[v.iEquipUid] then
      data.customData.sel_upgrade_item_num = self.m_selItemList[v.iEquipUid].sel_upgrade_item_num
    end
    dataList[#dataList + 1] = data
  end
  dataList = EquipManager:EquipmentStacked(dataList)
  dataList = self:SortEquipByLvUpDown2(dataList, self.m_bFilterDown)
  for i = #self.m_commonEquipExpIds, 1, -1 do
    local itemId = tonumber(self.m_commonEquipExpIds[i])
    local userItemNum = ItemManager:GetItemNum(itemId, true)
    if 0 < userItemNum then
      local data = {
        iID = itemId,
        iNum = userItemNum,
        customData = {optimizing = true}
      }
      if self.m_selItemList[itemId] then
        data.customData.sel_upgrade_item_num = self.m_selItemList[itemId].sel_upgrade_item_num
      end
      table.insert(dataList, 1, data)
    end
  end
  return dataList
end

function Form_EquipmentUpgrade:SortEquipByLvUpDown(equipList, filterDown)
  if #equipList <= 1 then
    return equipList
  end
  
  local function sortFun(data1, data2)
    local equipCfg1 = EquipManager:GetEquipCfgByBaseId(data1.iBaseId)
    local equipCfg2 = EquipManager:GetEquipCfgByBaseId(data2.iBaseId)
    local quality1 = equipCfg1.m_Quality
    local quality2 = equipCfg2.m_Quality
    if self.m_iFilterTabIndex == 2 then
      if quality1 == quality2 then
        if data1.iLevel == data2.iLevel then
          return data1.iBaseId < data2.iBaseId
        elseif filterDown then
          return data1.iLevel > data2.iLevel
        else
          return data1.iLevel < data2.iLevel
        end
      else
        return quality1 < quality2
      end
    elseif data1.iLevel == data2.iLevel then
      if quality1 == quality2 then
        return data1.iBaseId < data2.iBaseId
      elseif filterDown then
        return quality1 > quality2
      else
        return quality1 < quality2
      end
    else
      return data1.iLevel < data2.iLevel
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function Form_EquipmentUpgrade:SortEquipByLvUpDown2(equipList, filterDown)
  if #equipList <= 1 then
    return equipList
  end
  
  local function sortFun(data1, data2)
    local equipCfg1 = EquipManager:GetEquipCfgByBaseId(data1.iID)
    local equipCfg2 = EquipManager:GetEquipCfgByBaseId(data2.iID)
    local quality1 = equipCfg1.m_Quality
    local quality2 = equipCfg2.m_Quality
    local equipData1 = data1.customData
    local equipData2 = data2.customData
    if self.m_iFilterTabIndex == 2 then
      if quality1 == quality2 then
        if equipData1.iLevel == equipData2.iLevel then
          return data1.iID < data2.iID
        elseif filterDown then
          return equipData1.iLevel > equipData2.iLevel
        else
          return equipData1.iLevel < equipData2.iLevel
        end
      else
        return quality1 < quality2
      end
    elseif equipData1.iLevel == equipData2.iLevel then
      if quality1 == quality2 then
        if filterDown then
          return data1.iID > data2.iID
        else
          return data1.iID < data2.iID
        end
      elseif filterDown then
        return quality1 > quality2
      else
        return quality1 < quality2
      end
    else
      return equipData1.iLevel < equipData2.iLevel
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function Form_EquipmentUpgrade:GetSelectedItemsEXPs()
  local exp = 0
  for uid, itemInfo in pairs(self.m_selItemList) do
    if itemInfo.data_type == ResourceUtil.RESOURCE_TYPE.ITEMS then
      local itemCfg = ItemManager:GetItemConfigById(itemInfo.data_id)
      exp = exp + tonumber(itemCfg.m_ItemUse or 0) * itemInfo.sel_upgrade_item_num
    else
      exp = exp + EquipManager:GetEquipEXPValueById(uid)
    end
  end
  return exp
end

function Form_EquipmentUpgrade:SelectCanUpgradeNeedMaterialsByUid(equipUid)
  local equipData = EquipManager:GetEquipDataByID(equipUid)
  local equipCfg = EquipManager:GetEquipCfgByBaseId(equipData.iBaseId)
  local curExp = equipData.iExp or 0
  local needExp = 0
  local selectedExp = self:GetSelectedItemsEXPs()
  local _, lvUp = EquipManager:GetExpsCanUpgradeLvAndRemainingExp(equipData.iEquipUid, selectedExp)
  local levelTemplateID = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  local upLv = 0
  for i = equipData.iLevel, equipData.iLevel + lvUp do
    local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel + upLv)
    if not lvCfg:GetError() and 0 < lvCfg.m_EXPConsume then
      local EXPConsume = lvCfg.m_EXPConsume
      needExp = EXPConsume + needExp
      self.m_isMaxLv = false
    else
      local lvCfg2 = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel + upLv - 1)
      if not lvCfg2:GetError() then
        local EXPConsume = lvCfg.m_EXPConsume
        needExp = EXPConsume + needExp
        self.m_isMaxLv = true
      end
    end
    upLv = upLv + 1
  end
  needExp = needExp - curExp
  needExp = needExp - selectedExp
  if needExp <= 0 then
    return
  end
  for i, itemId in ipairs(self.m_commonEquipExpIds) do
    local item_id = tonumber(itemId)
    local userItemNum = self:GetResidueMaterialsCountByItemId(item_id)
    if 0 < userItemNum then
      local itemCfg = ItemManager:GetItemConfigById(itemId)
      for m = 1, userItemNum do
        needExp = needExp - tonumber(itemCfg.m_ItemUse or 0)
        if 0 < needExp and not self.m_selItemList[item_id] then
          local processData = ResourceUtil:GetProcessRewardData({iID = item_id, iNum = userItemNum})
          processData.sel_upgrade_item_num = 1
          self.m_selItemList[item_id] = processData
        elseif 0 < needExp then
          self.m_selItemList[item_id].sel_upgrade_item_num = self.m_selItemList[item_id].sel_upgrade_item_num + 1
        elseif needExp <= 0 then
          local processData = ResourceUtil:GetProcessRewardData({iID = item_id, iNum = userItemNum})
          if not self.m_selItemList[item_id] then
            processData.sel_upgrade_item_num = 1
          else
            processData.sel_upgrade_item_num = 1 + (self.m_selItemList[item_id].sel_upgrade_item_num or 0)
          end
          self.m_selItemList[item_id] = processData
          return
        end
      end
    end
  end
  if needExp <= 0 then
    return
  end
  local equipList, overConditionTips = self:GetUnSelectedEquips()
  local dataList = self:SortEquipByLvUpDown(equipList, false)
  for i, v in ipairs(dataList) do
    local eXPValue = EquipManager:GetEquipEXPValueById(v.iEquipUid)
    if 0 < needExp then
      local processData = ResourceUtil:GetProcessRewardData({
        iID = v.iBaseId,
        iNum = 1
      }, v)
      processData.is_selected = true
      self.m_selItemList[v.iEquipUid] = processData
      if not self.m_selItemList[v.iEquipUid].sel_upgrade_item_num then
        self.m_selItemList[v.iEquipUid].sel_upgrade_item_num = 1
      end
    else
      break
    end
    needExp = needExp - eXPValue
  end
  local _, stackTab = EquipManager:EquipmentStacked(self.m_selItemList)
  for i, v in pairs(self.m_selItemList) do
    if ResourceUtil:GetResourceTypeById(tonumber(v.data_id)) == ResourceUtil.RESOURCE_TYPE.EQUIPS and v.equipData.iExp == 0 and v.equipData.iLevel == 0 and stackTab[v.data_id] then
      v.sel_upgrade_item_num = #stackTab[v.data_id]
    end
  end
  return overConditionTips
end

function Form_EquipmentUpgrade:GetUnSelectedEquips()
  local list = {}
  local overConditionTips
  local equipList = EquipManager:GetUnEquippedEquipsById(self.m_upgradeEquipData.iEquipUid)
  local equipCfg = self.m_equipCfg
  local selQuality = equipCfg.m_Quality < EQUIP_PROTECT_QUALITY and equipCfg.m_Quality or equipCfg.m_Quality - 1
  for i, v in ipairs(equipList) do
    local selectFlag = false
    for m, n in pairs(self.m_selItemList) do
      if m == v.iEquipUid then
        selectFlag = true
        break
      end
    end
    local equipCfg2 = EquipManager:GetEquipCfgByBaseId(v.iBaseId)
    if not selectFlag and selQuality >= equipCfg2.m_Quality then
      list[#list + 1] = v
    elseif not selectFlag then
      overConditionTips = string.gsubnumberreplace(ConfigManager:GetClientMessageTextById(20043), selQuality)
    end
  end
  return list, overConditionTips
end

function Form_EquipmentUpgrade:GetResidueMaterialsCountByItemId(itemId)
  local userItemNum = ItemManager:GetItemNum(tonumber(itemId))
  local count = userItemNum
  for i, v in pairs(self.m_selItemList) do
    if itemId == v.data_id then
      count = userItemNum - v.sel_upgrade_item_num
    end
  end
  return count
end

function Form_EquipmentUpgrade:MarkSelectedMaterials()
  for i, v in pairs(self.m_selItemList) do
    for m, n in ipairs(self.m_allSortedItemDataList) do
      if i == n.iID then
        self.m_EquipListInfinityGrid:SetUpGradeNum(m, v.sel_upgrade_item_num)
      elseif n.customData and i == n.customData.iEquipUid then
        self.m_EquipListInfinityGrid:SetUpGradeNum(m, v.sel_upgrade_item_num)
      end
    end
  end
end

function Form_EquipmentUpgrade:OnEquipItemClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local itemData = self.m_allSortedItemDataList[fjItemIndex]
  if self.m_isMaxLv and (not itemData.customData or itemData.customData and not self.m_selItemList[itemData.customData.iEquipUid]) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30022)
    return
  end
  local equipList = EquipManager:GetSameEquipByEquipUid(itemData.customData.iEquipUid)
  if itemData.customData and itemData.customData.iEquipUid then
    local addEquipData = itemData
    if self.m_selItemList[itemData.customData.iEquipUid] then
      addEquipData = self:GetOneEquipInMap(equipList)
    end
    if addEquipData then
      local id = addEquipData.iBaseId and addEquipData.iBaseId or itemData.iID
      local iEquipUid = addEquipData.iEquipUid and addEquipData.iEquipUid or itemData.customData.iEquipUid
      self.m_selItemList[iEquipUid] = ResourceUtil:GetProcessRewardData({
        iID = id,
        iNum = itemData.iNum
      }, itemData.customData)
      if not self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num then
        self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num = 1
      else
        self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num = self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num + 1
      end
      self.m_EquipListInfinityGrid:SetUpGradeNum(fjItemIndex, self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num)
    end
  else
    local userItemNum = ItemManager:GetItemNum(tonumber(itemData.iID))
    if self.m_selItemList[itemData.iID] then
      if userItemNum <= self.m_selItemList[itemData.iID].sel_upgrade_item_num then
        return
      end
      self.m_selItemList[itemData.iID].sel_upgrade_item_num = self.m_selItemList[itemData.iID].sel_upgrade_item_num + 1
    else
      self.m_selItemList[itemData.iID] = ResourceUtil:GetProcessRewardData({
        iID = itemData.iID,
        iNum = itemData.iNum
      }, itemData.customData)
      self.m_selItemList[itemData.iID].sel_upgrade_item_num = 1
    end
    self.m_EquipListInfinityGrid:SetUpGradeNum(fjItemIndex, self.m_selItemList[itemData.iID].sel_upgrade_item_num)
  end
  local addExp = self:GetSelectedItemsEXPs()
  self:RefreshUpgradeEquipment(addExp)
end

function Form_EquipmentUpgrade:GetOneEquipInMap(equipList)
  for i, v in pairs(equipList) do
    if not self.m_selItemList[v.iEquipUid] then
      return v
    end
  end
end

function Form_EquipmentUpgrade:RemoveOneEquipInMap(equipList, customData)
  for i, v in pairs(equipList) do
    if self.m_selItemList[v.iEquipUid] and v.iEquipUid ~= customData.iEquipUid then
      return v
    end
  end
  return customData
end

function Form_EquipmentUpgrade:OnEquipItemDelClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local itemData = self.m_allSortedItemDataList[fjItemIndex]
  if itemData then
    if ResourceUtil:GetResourceTypeById(itemData.iID) == ResourceUtil.RESOURCE_TYPE.EQUIPS then
      local equipList = EquipManager:GetSameEquipByEquipUid(itemData.customData.iEquipUid)
      local removeEquipData = self:RemoveOneEquipInMap(equipList, itemData.customData)
      if self.m_selItemList[itemData.customData.iEquipUid] and removeEquipData then
        self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num = self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num - 1
        self.m_EquipListInfinityGrid:SetUpGradeNum(fjItemIndex, self.m_selItemList[itemData.customData.iEquipUid].sel_upgrade_item_num)
        self.m_selItemList[removeEquipData.iEquipUid] = nil
        self.autoSelNum = nil
      end
    elseif self.m_selItemList[itemData.iID] then
      self.m_selItemList[itemData.iID].sel_upgrade_item_num = self.m_selItemList[itemData.iID].sel_upgrade_item_num - 1
      self.m_EquipListInfinityGrid:SetUpGradeNum(fjItemIndex, self.m_selItemList[itemData.iID].sel_upgrade_item_num)
      if self.m_selItemList[itemData.iID].sel_upgrade_item_num == 0 then
        self.m_selItemList[itemData.iID] = nil
        self.autoSelNum = nil
      end
    else
      log.error("OnEquipItemDelClk is error")
    end
  else
    log.error("OnEquipItemDelClk  SortedItemDataList is error")
  end
  local addExp = self:GetSelectedItemsEXPs()
  self:RefreshUpgradeEquipment(addExp)
end

function Form_EquipmentUpgrade:OnBtnemptyClicked()
  self.m_selItemList = {}
  self:RefreshEquipList()
  self:RefreshUpgradeEquipment()
end

function Form_EquipmentUpgrade:OnBtnautoblackClicked()
  if self.m_isMaxLv then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30022)
    return
  end
  local overConditionTips = self:SelectCanUpgradeNeedMaterialsByUid(self.m_upgradeEquipData.iEquipUid)
  if self.autoSelNum and self.autoSelNum == table.getn(self.m_selItemList) and overConditionTips then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, overConditionTips)
    self.autoSelNum = nil
  elseif table.getn(self.m_selItemList) == 0 and not overConditionTips then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20042)
  end
  self.autoSelNum = table.getn(self.m_selItemList)
  local addExp = self:GetSelectedItemsEXPs()
  self:RefreshUpgradeEquipment(addExp)
  self:MarkSelectedMaterials()
end

function Form_EquipmentUpgrade:OnBtnupgraderedClicked()
  if self.m_selItemList and table.getn(self.m_selItemList) > 0 then
    local itemList = {}
    local equipList = {}
    local showTips = false
    local isShowToggle = CS.UnityEngine.PlayerPrefs.GetInt(EquipmentUpgradeTips)
    for equipUid, v in pairs(self.m_selItemList) do
      if not v.equipData then
        itemList[#itemList + 1] = {
          iID = v.data_id,
          iNum = v.sel_upgrade_item_num
        }
      else
        if showTips == false and isShowToggle ~= 1 then
          local equipCfg = EquipManager:GetEquipCfgByBaseId(v.data_id)
          if equipCfg.m_Quality >= EQUIP_CONFIRM_QUALITY then
            showTips = true
          end
        end
        equipList[#equipList + 1] = equipUid
      end
    end
    if showTips and isShowToggle ~= 1 then
      utils.popUpDirectionsUI({
        tipsID = 1221,
        showToggle = true,
        toggleText = ConfigManager:GetCommonTextById(20096),
        toggleCallBack = function(isOn)
          if isOn then
            CS.UnityEngine.PlayerPrefs.SetInt(EquipmentUpgradeTips, 1)
          end
        end,
        func1 = function()
          EquipManager:ReqEquipAddExp(self.m_upgradeEquipData.iEquipUid, itemList, equipList)
        end
      })
    else
      EquipManager:ReqEquipAddExp(self.m_upgradeEquipData.iEquipUid, itemList, equipList)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30023)
  end
end

function Form_EquipmentUpgrade:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_EquipmentUpgrade:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_EquipmentUpgrade:IsOpenGuassianBlur()
  return true
end

function Form_EquipmentUpgrade:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentUpgrade", Form_EquipmentUpgrade)
return Form_EquipmentUpgrade
