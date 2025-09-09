local Form_BagNew = class("Form_BagNew", require("UI/UIFrames/Form_BagNewUI"))
local TagType = {
  Consume = 1,
  Resource = 2,
  Equipment = 3
}
local SortType = {Quality = 1, Level = 2}
local ResolveState = {Default = 1, Resolving = 2}
local TagConfig = {
  [TagType.Consume] = {
    name = 20001,
    vFilterTabConfig = {
      {iIndex = 1, sTitle = 2001}
    }
  },
  [TagType.Resource] = {
    name = 20002,
    vFilterTabConfig = {
      {iIndex = 1, sTitle = 2001}
    }
  },
  [TagType.Equipment] = {
    name = 20003,
    vFilterTabConfig = {
      {iIndex = 1, sTitle = 2001},
      {iIndex = 2, sTitle = 2002}
    }
  }
}
local isFirstEnter = true
local isChangeTab = false
local ITEM_WIDTH = 186

function Form_BagNew:SetInitParam(param)
end

function Form_BagNew:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_iTagCur = 0
  self.m_panelTag = {}
  self.m_mItemData = {}
  for i = 1, #TagConfig do
    self.m_panelTag[i] = {}
    self.m_panelTag[i].panel = self.m_pnl_tab.transform:Find("m_Btn_Toggle" .. i)
    UILuaHelper.BindButtonClickManual(self, self.m_panelTag[i].panel:GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:ChangeTag(i)
    end)
    self.m_panelTag[i].imageIconSelected = self.m_panelTag[i].panel:Find("m_tab_select" .. i)
    self.m_panelTag[i].imageIconSelected.gameObject:SetActive(false)
    self.m_panelTag[i].imageIcon = self.m_panelTag[i].panel:Find("m_tab_unselect" .. i)
    self.m_panelTag[i].imageIcon.gameObject:SetActive(false)
    self.m_panelTag[i].imageIconRedPoint = self.m_panelTag[i].panel:Find("m_img_RedDot_Base" .. i)
    self.m_panelTag[i].imageIconRedPoint.gameObject:SetActive(false)
  end
  self.m_goFilterBtnRoot = goRoot.transform:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(self.m_goFilterBtnRoot)
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.Back), nil, nil, 1253)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk),
    itemDelClkBackFun = handler(self, self.OnEquipItemDelClk),
    itemLongClkBackFun = handler(self, self.OnEquipItemLongClk)
  }
  self.m_itemListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_scrollView_InfinityGrid, "UICommonItem", initGridData)
  self.m_itemListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnCommonItemClk))
  for i = 0, 4 do
    local panel = goRoot.transform:Find("content_node/m_bg_tab02/m_pnl_tab02" .. i)
    UILuaHelper.BindButtonClickManual(self, panel:GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:ChangeEquipTag(i)
    end)
  end
  self:OnEquipTabChangeShow(0)
  self:CheckRegisterRedDot()
  self.m_equipped_toggle_Toggle.onValueChanged:AddListener(function()
    self:OnToggleValueChanged()
  end)
end

function Form_BagNew:OnToggleValueChanged()
  LocalDataManager:SetIntSimple("Bag_Show_ALL_Equip", self.m_equipped_toggle_Toggle.isOn == true and 1 or 0)
  self:RefreshItemList()
end

function Form_BagNew:SetCellPerLine()
  local count = math.floor(self.m_scrollView.transform.rect.width / ITEM_WIDTH)
  self.m_itemListInfinityGrid:SetCellPerLine(count)
end

function Form_BagNew:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  isFirstEnter = false
  isChangeTab = false
  self.m_resolveEquipBtnState = ResolveState.Default
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self.m_equipUnStackedList = {}
end

function Form_BagNew:OnActiveTransitionDone()
  self.m_iTagCur = 0
  self.m_selItemIndex = 1
  self.m_itemList = {}
  self:SetCellPerLine()
  self:ChangeTag(TagType.Consume)
end

function Form_BagNew:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_resolveEquipBtnState = ResolveState.Default
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self.m_equipUnStackedList = {}
end

function Form_BagNew:AddEventListeners()
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnEventItemSet))
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnEventItemUse))
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.RefreshItemList))
  self:addEventListener("eGameEvent_Equip_Overload", handler(self, self.RefreshItemList))
  self:addEventListener("eGameEvent_Equip_Decompose", handler(self, self.OnEventEquipDecompose))
  self:addEventListener("eGameEvent_ItemTips_OpenEquipmentUpgrade", handler(self, self.OnExitResolveEquipState))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnExitResolveEquipState))
  self:addEventListener("eGameEvent_SetEffectLock", handler(self, self.RefreshItemList))
  self:addEventListener("eGameEvent_ReOverload", handler(self, self.RefreshItemList))
  self:addEventListener("eGameEvent_Equip_SetEquip", handler(self, self.RefreshItemList))
  self:addEventListener("eGameEvent_SaveReOverload", handler(self, self.RefreshItemList))
end

function Form_BagNew:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BagNew:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_panelTag[1].imageIconRedPoint, RedDotDefine.ModuleType.BagTab1)
end

function Form_BagNew:ChangeTag(iTag)
  if self.m_iTagCur == iTag then
    return
  end
  isChangeTab = true
  local panelTagPre = self.m_panelTag[self.m_iTagCur]
  if panelTagPre ~= nil then
    panelTagPre.imageIcon.gameObject:SetActive(true)
    panelTagPre.imageIconSelected.gameObject:SetActive(false)
  else
    for i, panelTag in ipairs(self.m_panelTag) do
      panelTag.imageIcon.gameObject:SetActive(true)
      panelTag.imageIconSelected.gameObject:SetActive(false)
    end
  end
  self.m_iTagCur = iTag
  self.m_iFilterTabIndex = 1
  self.m_bFilterDown = false
  self.m_widgetBtnFilter:RefreshTabConfig(TagConfig[self.m_iTagCur].vFilterTabConfig, self.m_iFilterTabIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  local panelTagCur = self.m_panelTag[self.m_iTagCur]
  if panelTagCur ~= nil then
    panelTagCur.imageIcon.gameObject:SetActive(false)
    panelTagCur.imageIconSelected.gameObject:SetActive(true)
  end
  self.m_equipped_toggle_Toggle.isOn = LocalDataManager:GetIntSimple("Bag_Show_ALL_Equip") == 1
  self.m_resolveEquipBtnState = ResolveState.Default
  self:RefreshResolveEquipUI()
  self:RefreshItemList()
  if self.m_itemList and #self.m_itemList > 0 then
    self:ResetInfinityGridLocate()
  end
end

function Form_BagNew:RefreshItemList()
  if self.m_iTagCur == TagType.Equipment then
    self.m_bg_tab02:SetActive(true)
    self.m_img_line:SetActive(false)
    self.m_img_rl_bg:SetActive(self.m_resolveEquipBtnState == ResolveState.Default)
    self.m_pnl_equipped:SetActive(self.m_resolveEquipBtnState == ResolveState.Default)
    self.m_txt_num_Text.text = table.getn(self.m_selResolveEquipTab)
    local isShow = self:CheckIsShowAllEquip()
    if not self.m_equipTagCur or self.m_equipTagCur == 0 then
      local list = EquipManager:GetAllBagEquipDataList()
      if isShow then
        self.m_itemList = list
      else
        self.m_itemList = EquipManager:GetUnOverLoadEquipDataList()
      end
      self.m_txt_rl_num_Text.text = string.format(ConfigManager:GetCommonTextById(20050), table.getn(list), ConfigManager:GetGlobalSettingsByKey("EquipMaxSpace"))
    else
      local list = EquipManager:GetBagEquipDataListByPos(self.m_equipTagCur)
      if isShow then
        self.m_itemList = list
      else
        self.m_itemList = EquipManager:GetUnOverLoadEquipDataListByPos(self.m_equipTagCur)
      end
      self.m_txt_rl_num_Text.text = table.getn(list)
    end
    self.m_equipUnStackedList = self.m_itemList
    self.m_itemList = EquipManager:EquipmentStacked(self.m_itemList)
    if self.m_iFilterTabIndex == SortType.Quality then
      EquipManager:SortEquipListByQuality(self.m_itemList, self.m_bFilterDown)
    elseif self.m_iFilterTabIndex == SortType.Level then
      EquipManager:SortEquipListByLevel(self.m_itemList, self.m_bFilterDown)
    end
    self.m_txt_title_Text.text = ""
  else
    self.m_bg_tab02:SetActive(false)
    self.m_img_line:SetActive(true)
    self.m_img_rl_bg:SetActive(false)
    self.m_pnl_equipped:SetActive(false)
    self.m_btn_resolve:SetActive(false)
    self.m_itemList = ItemManager:GetItemListByTag(self.m_iTagCur)
    table.sort(self.m_itemList, handler(self, self.SortItemList))
    self.m_txt_title_Text.text = ConfigManager:GetCommonTextById(TagConfig[self.m_iTagCur].name)
  end
  self:RefreshShowItemList(self.m_itemList)
  self.m_bg_empty:SetActive(#self.m_itemList == 0)
end

function Form_BagNew:RefreshShowItemList(itemList)
  local dataList = self:GeneratedListData(itemList)
  self.m_itemListInfinityGrid:ShowItemList(dataList)
  if isFirstEnter == false and isChangeTab == true then
    local itemshowList = self.m_itemListInfinityGrid:GetAllShownItemList()
    self.m_itemInitShowNum = #itemshowList
    local itemTable = {}
    self:ResetInfinityGridLocate()
    for i = 1, self.m_itemInitShowNum do
      if not utils.isNull(self.m_itemListInfinityGrid:GetShowItemByIndex(i)) then
        local obj = self.m_itemListInfinityGrid:GetShowItemByIndex(i).m_itemRootObj
        table.insert(itemTable, obj)
        UILuaHelper.SetCanvasGroupAlpha(obj, 0)
        UILuaHelper.StopAnimation(obj)
      end
    end
    self:DisplayDiagonalAnim(itemTable)
  end
end

function Form_BagNew:DisplayDiagonalAnim(objList)
  local itemListCols = math.floor(self.m_scrollView.transform.rect.width / ITEM_WIDTH)
  local itemListRows = math.ceil(#objList / itemListCols)
  local maxIndex = itemListRows + itemListCols - 1
  for i = 1, maxIndex do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.01 * i, 1, function()
      self["ItemInitTimer" .. i] = nil
      for j = 1, i do
        local row = j
        local col = i - j + 1
        if 1 <= col and col <= itemListCols and (row - 1) * itemListCols + col <= #objList then
          local obj = objList[(row - 1) * itemListCols + col]
          UILuaHelper.PlayAnimationByName(obj, "c_common_item_in")
        end
      end
    end)
  end
end

function Form_BagNew:ResetInfinityGridLocate()
  self.m_itemListInfinityGrid:LocateTo(0)
end

function Form_BagNew:GeneratedListData(itemList)
  local dataList = {}
  for i, v in ipairs(itemList) do
    local itemData = v
    local customData = table.deepcopy(v.data)
    if customData then
      customData.bBag = true
      customData.optimizing = true
    else
      customData = {bBag = true, optimizing = true}
    end
    itemData.customData = customData
    dataList[#dataList + 1] = itemData
  end
  return dataList
end

function Form_BagNew:SortItemList(a, b)
  if self.m_mItemData[a.iID] == nil then
    self.m_mItemData[a.iID] = CS.CData_Item.GetInstance():GetValue_ByItemID(a.iID)
  end
  local stItemDataA = self.m_mItemData[a.iID]
  if self.m_mItemData[b.iID] == nil then
    self.m_mItemData[b.iID] = CS.CData_Item.GetInstance():GetValue_ByItemID(b.iID)
  end
  local stItemDataB = self.m_mItemData[b.iID]
  if stItemDataA.m_ItemSubType ~= stItemDataB.m_ItemSubType then
    return stItemDataA.m_ItemSubType < stItemDataB.m_ItemSubType
  else
    if self.m_iFilterTabIndex == SortType.Quality and stItemDataA.m_ItemRarity ~= stItemDataB.m_ItemRarity then
      if self.m_bFilterDown then
        return stItemDataA.m_ItemRarity < stItemDataB.m_ItemRarity
      else
        return stItemDataA.m_ItemRarity > stItemDataB.m_ItemRarity
      end
    end
    return a.iID < b.iID
  end
end

function Form_BagNew:ChangeEquipTag(iTag)
  if self.m_equipTagCur == iTag then
    return
  end
  isChangeTab = true
  self.m_equipTagCur = iTag
  if self.m_resolveEquipBtnState == ResolveState.Resolving then
    self:OnExitResolveEquipRefreshSortBtn()
  end
  self.m_resolveEquipBtnState = ResolveState.Default
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self:RefreshResolveEquipUI()
  self:RefreshItemList()
  self:ResetInfinityGridLocate()
  self:OnEquipTabChangeShow(iTag)
end

function Form_BagNew:OnEquipTabChangeShow(index)
  for i = 0, 4 do
    if index == i then
      self["m_img_tab_sel02" .. i]:SetActive(true)
      self["m_icon_tab02" .. i]:SetActive(false)
    else
      self["m_img_tab_sel02" .. i]:SetActive(false)
      self["m_icon_tab02" .. i]:SetActive(true)
    end
  end
end

function Form_BagNew:OnCommonItemClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  self.m_itemListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  self.m_itemListInfinityGrid:OnChooseItem(fjItemIndex, true)
  self.m_selItemIndex = fjItemIndex
  if self.m_resolveEquipBtnState == ResolveState.Resolving then
    self:OnEquipItemClk(fjItemIndex)
  else
    self:OpenItemTips(fjItemIndex)
  end
end

function Form_BagNew:OnEventItemSet(vItemChange)
  local bRefresh = false
  for _, stItemChange in pairs(vItemChange) do
    if self.m_mItemData[stItemChange.iID] == nil then
      self.m_mItemData[stItemChange.iID] = CS.CData_Item.GetInstance():GetValue_ByItemID(stItemChange.iID)
    end
    local stItemData = self.m_mItemData[stItemChange.iID]
    if stItemData.m_VisibleInvTag == self.m_iTagCur then
      bRefresh = true
      break
    end
  end
  if bRefresh then
    self:RefreshItemList()
  end
end

function Form_BagNew:OnEventItemUse(stItemUseInfo)
  self:RefreshItemList()
end

function Form_BagNew:OnFilterChanged(iIndex, bDown)
  self.m_iFilterTabIndex = iIndex
  self.m_bFilterDown = bDown
  self:ResetInfinityGridLocate()
  if self.m_iTagCur == TagType.Equipment and self.m_resolveEquipBtnState == ResolveState.Resolving then
    self:OnSortFilterEquip()
  else
    self:RefreshItemList()
  end
end

function Form_BagNew:OnExitResolveEquipState()
  self.m_resolveEquipBtnState = ResolveState.Default
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self.m_equipUnStackedList = {}
  self:RefreshResolveEquipUI()
  self:RefreshItemList()
end

function Form_BagNew:OnEventEquipDecompose()
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self.m_equipUnStackedList = {}
  self:RefreshItemList()
end

function Form_BagNew:CheckIsShowAllEquip()
  if self.m_equipped_toggle_Toggle.isOn and self.m_resolveEquipBtnState == ResolveState.Default then
    return true
  end
  return false
end

function Form_BagNew:RefreshResolveEquipUI()
  self.m_btn_resolve:SetActive(self.m_iTagCur == TagType.Equipment and self.m_resolveEquipBtnState == ResolveState.Default)
  self.m_pnl_btn:SetActive(self.m_iTagCur == TagType.Equipment and self.m_resolveEquipBtnState == ResolveState.Resolving)
  self.m_img_bg_quick_light:SetActive(table.getn(self.m_chooseFilterType) > 0)
end

function Form_BagNew:MarkSelectedEquips(equipList, selList)
  if table.getn(equipList) == 0 then
    return
  end
  for m, n in ipairs(equipList) do
    self.m_itemListInfinityGrid:SetUpGradeNum(m, 0)
  end
  if 0 < #selList then
    for i, v in ipairs(selList) do
      for m, n in ipairs(equipList) do
        local equipData1 = n.data
        local equipData2 = v.data
        if v.iID == n.iID and equipData1 and equipData2 and equipData1.iLevel == equipData2.iLevel and equipData1.iExp == equipData2.iExp then
          self.m_itemListInfinityGrid:SetUpGradeNum(m, n.iNum)
        end
      end
    end
  end
end

function Form_BagNew:OnEquipItemDelClk(index, widgetItemObj)
  if not index then
    return
  end
  local fjItemIndex = index + 1
  local itemData = self.m_itemList[fjItemIndex]
  if itemData then
    local equipList = EquipManager:GetSameEquipInListByEquipUid(self.m_equipUnStackedList, itemData.customData.iEquipUid)
    local removeEquipData = self:RemoveOneEquipInMap(equipList, itemData.customData)
    local equipData = self.m_selResolveEquipTab[itemData.customData.iEquipUid]
    if equipData and equipData.customData and removeEquipData then
      if equipData.customData.sel_upgrade_item_num then
        equipData.customData.sel_upgrade_item_num = equipData.customData.sel_upgrade_item_num - 1
      end
      self.m_itemListInfinityGrid:SetUpGradeNum(fjItemIndex, equipData.customData.sel_upgrade_item_num)
      self.m_selResolveEquipTab[removeEquipData.iEquipUid] = nil
      self.m_txt_num_Text.text = table.getn(self.m_selResolveEquipTab)
    end
  end
end

function Form_BagNew:OnEquipItemClk(index, widgetItemObj)
  if not index then
    return
  end
  local fjItemIndex = index
  local itemData = self.m_itemList[fjItemIndex]
  if itemData then
    local equipList = EquipManager:GetSameEquipInListByEquipUid(self.m_equipUnStackedList, itemData.customData.iEquipUid)
    if equipList and itemData.customData and itemData.customData.iEquipUid then
      local addEquipData = itemData
      if self.m_selResolveEquipTab[itemData.customData.iEquipUid] then
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
        if not iEquipUid and addEquipData.data then
          iEquipUid = addEquipData.data.iEquipUid
        else
          equipData = {data = addEquipData}
        end
        self.m_selResolveEquipTab[iEquipUid] = equipData
        self.m_txt_num_Text.text = table.getn(self.m_selResolveEquipTab)
      end
    end
  end
end

function Form_BagNew:RemoveOneEquipInMap(equipList, customData)
  for i, v in pairs(equipList) do
    if self.m_selResolveEquipTab[v.iEquipUid] and v.iEquipUid ~= customData.iEquipUid then
      return v
    end
  end
  return customData
end

function Form_BagNew:GetOneEquipInMap(equipList)
  for i, v in pairs(equipList) do
    if not self.m_selResolveEquipTab[v.iEquipUid] then
      return v
    end
  end
end

function Form_BagNew:OpenItemTips(fjItemIndex)
  if not fjItemIndex then
    return
  end
  if not self.m_itemListInfinityGrid then
    return
  end
  local chooseFJItemData = self.m_itemList[fjItemIndex]
  if chooseFJItemData then
    local itemData = chooseFJItemData
    if itemData.data and itemData.data.iEquipUid then
      itemData = itemData.data
    end
    if itemData and itemData.iEquipUid and itemData.iOverloadHero and itemData.iOverloadHero ~= 0 then
      StackPopup:Push(UIDefines.ID_FORM_ITEMTIPST10, {equipData = itemData})
    else
      utils.openItemDetailPop(itemData, nil, true)
    end
    if chooseFJItemData then
      local changeFlag = ItemManager:SetImportantItemShowRedPoint(chooseFJItemData.iID, 0, true)
      if changeFlag then
        self.m_itemListInfinityGrid:ReBind(fjItemIndex)
      end
    end
  end
end

function Form_BagNew:OnEquipItemLongClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if self.m_resolveEquipBtnState == ResolveState.Default then
    return
  end
  self:OpenItemTips(fjItemIndex)
end

function Form_BagNew:OnBtnresolveClicked()
  if self.m_resolveEquipBtnState == ResolveState.Default then
    self.m_resolveEquipBtnState = ResolveState.Resolving
  else
    self.m_resolveEquipBtnState = ResolveState.Default
  end
  self:OnEnterResolveEquipRefreshSortBtn()
  self:RefreshResolveEquipUI()
  self:RefreshItemList()
end

function Form_BagNew:OnBtnresolve02Clicked()
  if table.getn(self.m_selResolveEquipTab) == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40053)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTRESOLVE, {
    equipTab = self.m_selResolveEquipTab
  })
end

function Form_BagNew:OnBtnquickClicked()
  local function chooseBackFun(filterData)
    self.m_chooseFilterType = filterData
    
    self:OnFilterResolveEquip()
  end
  
  utils.openFormBagEquipFilter(self.m_itemList, self.m_btn_quick.transform, {x = 0, y = 0}, {x = -35, y = 40}, chooseBackFun, self.m_chooseFilterType, self.m_equipTagCur, true)
end

function Form_BagNew:OnBtncancelClicked()
  self.m_resolveEquipBtnState = ResolveState.Default
  self.m_selResolveEquipTab = {}
  self.m_chooseFilterType = {}
  self:OnExitResolveEquipRefreshSortBtn()
  self:RefreshResolveEquipUI()
  self:RefreshItemList()
end

function Form_BagNew:CheckIsClearChooseState()
  if table.getn(self.m_chooseFilterType) == 0 then
    return true
  elseif self.m_equipTagCur and self.m_equipTagCur ~= 0 and table.getn(self.m_chooseFilterType) == 1 and table.getn(self.m_chooseFilterType[EquipManager.EquipFilterType.Pos]) == 1 and self.m_chooseFilterType[EquipManager.EquipFilterType.Pos][self.m_equipTagCur] then
    return true
  end
end

function Form_BagNew:OnFilterResolveEquip()
  local count = table.getn(self.m_selResolveEquipTab)
  local equips, equipIdTab = {}, {}
  if self:CheckIsClearChooseState() then
    self.m_selResolveEquipTab = {}
  else
    equips, equipIdTab = EquipManager:FilterEquipByConditions(self.m_equipUnStackedList, self.m_chooseFilterType)
    self.m_selResolveEquipTab = equipIdTab
  end
  local countNew = table.getn(self.m_selResolveEquipTab)
  if count >= countNew then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40053)
  end
  equips = EquipManager:EquipmentStacked(equips)
  self:MarkSelectedEquips(self.m_itemList, equips)
  self.m_txt_num_Text.text = countNew
  self.m_img_bg_quick_light:SetActive(table.getn(self.m_chooseFilterType) > 0)
end

function Form_BagNew:OnSortFilterEquip()
  if self.m_iFilterTabIndex == SortType.Quality then
    EquipManager:SortEquipListByQuality(self.m_itemList, self.m_bFilterDown)
  elseif self.m_iFilterTabIndex == SortType.Level then
    EquipManager:SortEquipListByLevel(self.m_itemList, self.m_bFilterDown)
  end
  self.m_itemListInfinityGrid:ShowItemList(self.m_itemList)
end

function Form_BagNew:OnExitResolveEquipRefreshSortBtn()
  self.m_iFilterTabIndex = SortType.Quality
  self.m_bFilterDown = false
  self.m_widgetBtnFilter:ForceChangeTabIndex(self.m_iFilterTabIndex)
  self.m_widgetBtnFilter:ForceChangeUpDownBtn(self.m_bFilterDown)
end

function Form_BagNew:OnEnterResolveEquipRefreshSortBtn()
  self.m_iFilterTabIndex = SortType.Quality
  self.m_bFilterDown = true
  self.m_widgetBtnFilter:ForceChangeTabIndex(self.m_iFilterTabIndex)
  self.m_widgetBtnFilter:ForceChangeUpDownBtn(self.m_bFilterDown)
end

function Form_BagNew:IsFullScreen()
  return true
end

function Form_BagNew:Back()
  isFirstEnter = true
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_BAGNEW)
end

function Form_BagNew:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_BagNew", Form_BagNew)
return Form_BagNew
