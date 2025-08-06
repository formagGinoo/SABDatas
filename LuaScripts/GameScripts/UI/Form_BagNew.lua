local Form_BagNew = class("Form_BagNew", require("UI/UIFrames/Form_BagNewUI"))
local TagType = {
  Consume = 1,
  Resource = 2,
  Equipment = 3
}
local SortType = {Quality = 1, Level = 2}
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
  local goFilterBtnRoot = goRoot.transform:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.Back))
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
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
end

function Form_BagNew:AddEventListeners()
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnEventItemSet))
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnEventItemUse))
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.RefreshItemList))
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
  self:RefreshItemList()
  if self.m_itemList and #self.m_itemList > 0 then
    self:ResetInfinityGridLocate()
  end
end

function Form_BagNew:RefreshItemList()
  if self.m_iTagCur == TagType.Equipment then
    self.m_bg_tab02:SetActive(true)
    self.m_img_line:SetActive(false)
    self.m_img_rl_bg:SetActive(true)
    if not self.m_equipTagCur or self.m_equipTagCur == 0 then
      self.m_itemList = EquipManager:GetUnOverLoadEquipDataList()
      local list = EquipManager:GetEquipList()
      self.m_txt_rl_num_Text.text = string.format(ConfigManager:GetCommonTextById(20050), table.getn(list), ConfigManager:GetGlobalSettingsByKey("EquipMaxSpace"))
    else
      self.m_itemList = EquipManager:GetUnOverLoadEquipDataListByPos(self.m_equipTagCur)
      local list = EquipManager:GetEquipDataByPos(self.m_equipTagCur)
      self.m_txt_rl_num_Text.text = table.getn(list)
    end
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
    local customData = v.data
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
  local chooseFJItemData = self.m_itemList[fjItemIndex]
  if chooseFJItemData then
    local itemData = chooseFJItemData
    if itemData.data and itemData.data.iEquipUid then
      itemData = itemData.data
    end
    utils.openItemDetailPop(itemData, nil, true)
    if chooseFJItemData then
      local changeFlag = ItemManager:SetImportantItemShowRedPoint(chooseFJItemData.iID, 0, true)
      if changeFlag then
        self.m_itemListInfinityGrid:ReBind(fjItemIndex)
      end
    end
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
  self:RefreshItemList()
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
