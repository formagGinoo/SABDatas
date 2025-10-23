local Form_Equipsmeltingmaterials = class("Form_Equipsmeltingmaterials", require("UI/UIFrames/Form_EquipsmeltingmaterialsUI"))

function Form_Equipsmeltingmaterials:SetInitParam(param)
end

function Form_Equipsmeltingmaterials:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEquipItemClk),
    itemDelClkBackFun = handler(self, self.OnEquipItemDelClk)
  }
  self.m_itemListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_equip_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_itemListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnEquipItemClk))
end

function Form_Equipsmeltingmaterials:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_selCamp = tParam.iCamp
  self.m_needNum = EquipManager:GetCampEquipMergeCostNum()
  local selEquipIds = tParam.selEquipIds or {}
  self.m_selEquipTab, self.m_stackedList = self:MarkSelectedEquipsByUId(selEquipIds)
  self.m_chooseNumTextRed = ConfigManager:GetClientMessageTextById(58006)
  self.m_chooseNumTextGreen = ConfigManager:GetClientMessageTextById(58007)
  self.m_chooseFilterType = {}
  self.m_equipDataList = {}
  self:RefreshEquipList()
  self:MarkSelectedEquips(self.m_itemList, self.m_stackedList)
  self:RefreshBtnState()
end

function Form_Equipsmeltingmaterials:OnInactive()
  self.super.OnInactive(self)
end

function Form_Equipsmeltingmaterials:GetMaterialEquips(filterEquipList)
  local equipList = {}
  if filterEquipList then
    equipList = filterEquipList
  else
    equipList = EquipManager:GetAllBagEquipDataList()
  end
  local materialEquipList = {}
  local list = {}
  for i, v in ipairs(equipList) do
    if v.data and v.data.iHeroId == 0 then
      local equipCfg = EquipManager:GetEquipCfgByBaseId(v.iID)
      if equipCfg.m_BonusCamp ~= 0 and equipCfg.m_Quality == GlobalConfig.QUALITY_EQUIP_ENUM.T9 then
        local customData = table.deepcopy(v.data)
        if customData then
          customData.optimizing = true
        else
          customData = {optimizing = true}
        end
        materialEquipList[#materialEquipList + 1] = {
          iID = v.iID,
          iNum = 1,
          customData = customData
        }
        list[#list + 1] = {
          iID = v.iID,
          iNum = 1,
          data = v.data
        }
      end
    end
  end
  return materialEquipList, list
end

function Form_Equipsmeltingmaterials:RefreshUI()
  local itemList, unStackedList = self:GetMaterialEquips()
  self.m_equipUnStackedList = unStackedList
  self.m_equipDataList = unStackedList
  self.m_itemList = EquipManager:EquipmentStacked(itemList)
  self.m_itemList = self:SortEquipByLevel(self.m_itemList)
  self.m_itemListInfinityGrid:ShowItemList(self.m_itemList)
  self:MarkSelectedEquips(self.m_itemList, self.m_selEquipTab)
  self:RefreshBtnState()
  if not utils.isNull(self.m_common_empty) then
    UILuaHelper.SetActive(self.m_common_empty, #self.m_itemList == 0)
  end
  if not utils.isNull(self.m_equip_list) then
    UILuaHelper.SetActive(self.m_equip_list, #self.m_itemList ~= 0)
  end
  self.m_filter_select:SetActive(0 < table.getn(self.m_chooseFilterType))
end

function Form_Equipsmeltingmaterials:RefreshEquipList(equipList)
  local itemList, unStackedList = self:GetMaterialEquips(equipList)
  self.m_equipUnStackedList = unStackedList
  if not equipList then
    self.m_equipDataList = unStackedList
  end
  self.m_itemList = EquipManager:EquipmentStacked(itemList)
  self.m_itemList = self:SortEquipByLevel(self.m_itemList)
  self.m_itemListInfinityGrid:ShowItemList(self.m_itemList)
  self.m_itemListInfinityGrid:LocateTo(0)
  if equipList then
    self:MarkSelectedEquips(self.m_itemList, self.m_selEquipTab)
  end
  if not utils.isNull(self.m_common_empty) then
    UILuaHelper.SetActive(self.m_common_empty, #self.m_itemList == 0)
  end
  if not utils.isNull(self.m_equip_list) then
    UILuaHelper.SetActive(self.m_equip_list, #self.m_itemList ~= 0)
  end
  self.m_filter_select:SetActive(0 < table.getn(self.m_chooseFilterType))
end

function Form_Equipsmeltingmaterials:RefreshBtnState()
  local selNum = table.getn(self.m_selEquipTab)
  local tipsStr = self.m_chooseNumTextGreen
  if selNum ~= self.m_needNum then
    tipsStr = self.m_chooseNumTextRed
  end
  self.m_txt_num_Text.text = string.gsubNumberReplace(tipsStr, selNum, self.m_needNum)
  UILuaHelper.SetActive(self.m_common_btn_grey, selNum ~= self.m_needNum)
  UILuaHelper.SetActive(self.m_common_btn_light, selNum == self.m_needNum)
end

function Form_Equipsmeltingmaterials:SortEquipByLevel(equipList)
  local function sortFun(data1, data2)
    if data1.customData and data2.customData then
      if data1.customData.iLevel == data2.customData.iLevel then
        return data1.iID < data2.iID
      else
        return data1.customData.iLevel < data2.customData.iLevel
      end
    else
      return data1.iID < data2.iID
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function Form_Equipsmeltingmaterials:MarkSelectedEquipsByUId(equipList)
  local list = {}
  local equipMap = {}
  for i, uid in ipairs(equipList) do
    local equipData = EquipManager:GetEquipDataByID(uid)
    if equipData then
      local customData = table.deepcopy(equipData)
      list[#list + 1] = {
        iID = equipData.iBaseId,
        iNum = 1,
        customData = customData
      }
      equipMap[equipData.iEquipUid] = {
        iID = equipData.iBaseId,
        iNum = 1,
        customData = customData
      }
    end
  end
  list = EquipManager:EquipmentStacked(list)
  return equipMap, list
end

function Form_Equipsmeltingmaterials:MarkSelectedEquips(equipList, selList)
  if table.getn(equipList) == 0 then
    return
  end
  for m, n in ipairs(equipList) do
    self.m_itemListInfinityGrid:SetUpGradeNum(m, 0)
  end
  if table.getn(selList) > 0 then
    for i, v in pairs(selList) do
      for m, n in ipairs(equipList) do
        local equipData1 = n.data or n.customData
        local equipData2 = v.data or v.customData
        if v.iID == n.iID and equipData1 and equipData2 and equipData1.iLevel == equipData2.iLevel and equipData1.iExp == equipData2.iExp then
          local equipData = self.m_selEquipTab[n.customData.iEquipUid]
          if equipData and equipData.customData then
            self.m_selEquipTab[n.customData.iEquipUid].customData.sel_upgrade_item_num = v.iNum
          end
          self.m_itemListInfinityGrid:SetUpGradeNum(m, v.iNum)
        end
      end
    end
  end
end

function Form_Equipsmeltingmaterials:OnEquipItemDelClk(index, widgetItemObj)
  if not index then
    return
  end
  local fjItemIndex = index + 1
  local itemData = self.m_itemList[fjItemIndex]
  if itemData then
    local equipList = EquipManager:GetSameEquipInListByEquipUid(self.m_equipUnStackedList, itemData.customData.iEquipUid)
    local removeEquipData = self:RemoveOneEquipInMap(equipList, itemData.customData)
    local equipData = self.m_selEquipTab[itemData.customData.iEquipUid]
    if equipData and equipData.customData and removeEquipData then
      if equipData.customData.sel_upgrade_item_num then
        equipData.customData.sel_upgrade_item_num = equipData.customData.sel_upgrade_item_num - 1
      end
      self.m_itemListInfinityGrid:SetUpGradeNum(fjItemIndex, equipData.customData.sel_upgrade_item_num)
      self.m_selEquipTab[removeEquipData.iEquipUid] = nil
    end
  end
  self:RefreshBtnState()
end

function Form_Equipsmeltingmaterials:OnEquipItemClk(index, widgetItemObj)
  if not index then
    return
  end
  if self.m_needNum <= table.getn(self.m_selEquipTab) then
    return
  end
  local fjItemIndex = index + 1
  local itemData = self.m_itemList[fjItemIndex]
  if itemData then
    local equipList = EquipManager:GetSameEquipInListByEquipUid(self.m_equipUnStackedList, itemData.customData.iEquipUid)
    if equipList and itemData.customData and itemData.customData.iEquipUid then
      local addEquipData = itemData
      if self.m_selEquipTab[itemData.customData.iEquipUid] then
        addEquipData = self:GetOneEquipInMap(equipList)
      end
      if addEquipData then
        if itemData.customData.sel_upgrade_item_num then
          itemData.customData.sel_upgrade_item_num = itemData.customData.sel_upgrade_item_num + 1
        else
          itemData.customData.sel_upgrade_item_num = 1
        end
        self.m_itemListInfinityGrid:SetUpGradeNum(fjItemIndex, itemData.customData.sel_upgrade_item_num)
        local iEquipUid = addEquipData.iEquipUid
        local equipData = addEquipData
        if not iEquipUid and addEquipData.customData then
          iEquipUid = addEquipData.customData.iEquipUid
        else
          equipData = {data = addEquipData}
        end
        self.m_selEquipTab[iEquipUid] = equipData
      end
    end
  end
  self:RefreshBtnState()
end

function Form_Equipsmeltingmaterials:RemoveOneEquipInMap(equipList, customData)
  for i, v in pairs(equipList) do
    if self.m_selEquipTab[v.iEquipUid] and v.iEquipUid ~= customData.iEquipUid then
      return v
    end
  end
  return customData
end

function Form_Equipsmeltingmaterials:GetOneEquipInMap(equipList)
  for i, v in pairs(equipList) do
    if not self.m_selEquipTab[v.iEquipUid] then
      return v
    end
  end
end

function Form_Equipsmeltingmaterials:OnBtnemptyClicked()
  self.m_selEquipTab = {}
  self.m_chooseFilterType = {}
  self:RefreshUI()
end

function Form_Equipsmeltingmaterials:CheckSelEquipIsUpgrade()
  local iCamp = self.m_selCamp
  if not iCamp then
    return
  end
  for iEquipUid, equipData in pairs(self.m_selEquipTab) do
    if equipData.customData and equipData.customData.iLevel > 0 then
      return true
    end
  end
  return false
end

function Form_Equipsmeltingmaterials:OnCommonbtnlightClicked()
  if table.getn(self.m_selEquipTab) ~= self.m_needNum then
    return
  end
  local equipUids = {}
  for iEquipUid, equipData in pairs(self.m_selEquipTab) do
    table.insert(equipUids, iEquipUid)
  end
  if self:CheckSelEquipIsUpgrade() then
    utils.popUpDirectionsUI({
      tipsID = 1277,
      func1 = function()
        self:broadcastEvent("eGameEvent_EquipT9Reset_SelEquipMat", equipUids)
        self:OnBtnCloseClicked()
      end
    })
  else
    self:broadcastEvent("eGameEvent_EquipT9Reset_SelEquipMat", equipUids)
    self:OnBtnCloseClicked()
  end
end

function Form_Equipsmeltingmaterials:OnCommonbtngreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 58004)
end

function Form_Equipsmeltingmaterials:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
    self.m_chooseFilterType = filterData
    
    local equips = self.m_equipDataList
    if table.getn(self.m_chooseFilterType) ~= 0 then
      equips = EquipManager:FilterEquipMergeByConditions(self.m_equipDataList, filterData)
    end
    self.m_selEquipTab = {}
    self:RefreshEquipList(equips)
    self:RefreshBtnState()
  end
  
  local params = {
    equipDataList = self.m_itemList,
    click_transform = self.m_btn_Filter.transform,
    content_pivot = {x = 1, y = 1},
    pos_offset = {x = -35, y = 130},
    chooseBackFun = chooseBackFun,
    chooseFilterType = self.m_chooseFilterType,
    enhanceTxt = ConfigManager:GetClientMessageTextById(58009),
    showFilterTypeList = {
      EquipManager.EquipFilterType.Pos,
      EquipManager.EquipFilterType.Camp,
      EquipManager.EquipFilterType.EquipType,
      EquipManager.EquipFilterType.Enhance
    },
    show_empty = false
  }
  utils.openFormBagEquipFilter(params)
end

function Form_Equipsmeltingmaterials:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_Equipsmeltingmaterials:IsOpenGuassianBlur()
  return true
end

function Form_Equipsmeltingmaterials:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Equipsmeltingmaterials", Form_Equipsmeltingmaterials)
return Form_Equipsmeltingmaterials
