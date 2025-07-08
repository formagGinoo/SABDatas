local Form_Bag = class("Form_Bag", require("UI/UIFrames/Form_BagUI"))
local EquipmentConfigInstance = ConfigManager:GetConfigInsByName("Equipment")
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
local ITEM_WIDTH = 216

function Form_Bag:SetInitParam(param)
end

function Form_Bag:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_iTagCur = 0
  self.m_panelTag = {}
  self.m_mItemData = {}
  for i = 1, #TagConfig do
    self.m_panelTag[i] = {}
    self.m_panelTag[i].panel = goRoot.transform:Find("content_node/bg_tab/m_tab" .. i)
    UILuaHelper.BindButtonClickManual(self, self.m_panelTag[i].panel:GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:ChangeTag(i)
    end)
    self.m_panelTag[i].textTag = self.m_panelTag[i].panel:Find("PanelTextTab/m_txt_tab"):GetComponent(T_TextMeshProUGUI)
    self.m_panelTag[i].textTag.text = ConfigManager:GetCommonTextById(TagConfig[i].name)
    self.m_panelTag[i].panel:Find("PanelTextTab"):GetComponent("TextContentFitScroll"):Refresh()
    UILuaHelper.SetColor(self.m_panelTag[i].textTag, 165, 165, 165, 1)
    self.m_panelTag[i].imageIcon = self.m_panelTag[i].panel:Find("m_tab_icon")
    self.m_panelTag[i].imageIcon.gameObject:SetActive(true)
    self.m_panelTag[i].imageIconSelected = self.m_panelTag[i].panel:Find("m_tab_icon_selected")
    self.m_panelTag[i].imageIconSelected.gameObject:SetActive(false)
    self.m_panelTag[i].imageIconSelectedLine = self.m_panelTag[i].panel:Find("m_img_tab_line")
    self.m_panelTag[i].imageIconSelectedLine.gameObject:SetActive(false)
    self.m_panelTag[i].imageIconRedPoint = self.m_panelTag[i].panel:Find("ui_common_redpoint")
    self.m_panelTag[i].imageIconRedPoint.gameObject:SetActive(false)
  end
  self.m_vItemIcon = {}
  self.m_updateQueueItemIcon = self:addComponent("UpdateQueue")
  self:InitPanelItemTips()
  local goFilterBtnRoot = goRoot.transform:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.Back))
  self:addComponent("UITouchMask")
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
  }
  self.m_itemListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_scrollView_InfinityGrid, "UICommonItem", initGridData)
  self.m_itemListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnCommonItemClk))
  self.m_itemListInfinityGrid2 = require("UI/Common/UICommonItemInfinityGrid").new(self.m_scrollView2_InfinityGrid, "UICommonItem", initGridData)
  self.m_itemListInfinityGrid2:RegisterButtonCallback("c_btnClick", handler(self, self.OnCommonItemClk))
  for i = 0, 4 do
    local panel = goRoot.transform:Find("content_node/pnl_list/m_bg_tab02/m_pnl_tab02" .. i)
    UILuaHelper.BindButtonClickManual(self, panel:GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:ChangeEquipTag(i)
    end)
  end
  self:OnEquipTabChangeShow(0)
  self:SetCellPerLine()
  self:CheckRegisterRedDot()
end

function Form_Bag:SetCellPerLine()
  local count2 = math.floor(self.m_scrollView2.transform.rect.width / ITEM_WIDTH)
  self.m_itemListInfinityGrid2:SetCellPerLine(count2)
  local count = math.floor(self.m_scrollView.transform.rect.width / ITEM_WIDTH)
  self.m_itemListInfinityGrid:SetCellPerLine(count)
end

function Form_Bag:OnActive()
  self.super.OnActive(self)
  self.m_itemList = {}
  self.m_selItemIndex = 1
  self.m_selItemData = nil
  self.m_iTagCur = 0
  self:ChangeTag(TagType.Consume)
  self:RemoveEventListeners()
  self.m_iHandlerIDItemSet = self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.OnEventItemSet))
  self.m_iHandlerIDItemUse = self:addEventListener("eGameEvent_Item_Use", handler(self, self.OnEventItemUse))
end

function Form_Bag:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_panelTag[1].imageIconRedPoint, RedDotDefine.ModuleType.BagTab1)
end

function Form_Bag:RemoveEventListeners()
  if self.m_iHandlerIDItemSet then
    self:removeEventListener("eGameEvent_Item_SetItem", self.m_iHandlerIDItemSet)
    self.m_iHandlerIDItemSet = nil
  end
  if self.m_iHandlerIDItemUse then
    self:removeEventListener("eGameEvent_Item_Use", self.m_iHandlerIDItemUse)
    self.m_iHandlerIDItemUse = nil
  end
end

function Form_Bag:OnInactive()
  self.super.OnInactive(self)
  self:RemoveEventListeners()
end

function Form_Bag:ChangeTag(iTag)
  if self.m_iTagCur == iTag then
    return
  end
  local panelTagPre = self.m_panelTag[self.m_iTagCur]
  if panelTagPre ~= nil then
    UILuaHelper.SetColor(panelTagPre.textTag, 165, 165, 165, 1)
    panelTagPre.imageIcon.gameObject:SetActive(true)
    panelTagPre.imageIconSelected.gameObject:SetActive(false)
    panelTagPre.imageIconSelectedLine.gameObject:SetActive(false)
  else
    for i, panelTag in ipairs(self.m_panelTag) do
      UILuaHelper.SetColor(panelTag.textTag, 165, 165, 165, 1)
      panelTag.imageIcon.gameObject:SetActive(true)
      panelTag.imageIconSelected.gameObject:SetActive(false)
      panelTag.imageIconSelectedLine.gameObject:SetActive(false)
    end
  end
  self.m_iTagCur = iTag
  self.m_iFilterTabIndex = 1
  self.m_bFilterDown = false
  self.m_widgetBtnFilter:RefreshTabConfig(TagConfig[self.m_iTagCur].vFilterTabConfig, self.m_iFilterTabIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  local panelTagCur = self.m_panelTag[self.m_iTagCur]
  if panelTagCur ~= nil then
    UILuaHelper.SetColor(panelTagCur.textTag, 255, 237, 204, 1)
    panelTagCur.imageIcon.gameObject:SetActive(false)
    panelTagCur.imageIconSelected.gameObject:SetActive(true)
    panelTagCur.imageIconSelectedLine.gameObject:SetActive(true)
  end
  self:RefreshItemList()
  self:ChooseOneItem()
  if self.m_itemList and #self.m_itemList > 0 then
    self:ResetInfinityGridLocate()
  end
end

function Form_Bag:ChangeEquipTag(iTag)
  if self.m_equipTagCur == iTag then
    return
  end
  self.m_equipTagCur = iTag
  self:RefreshItemList()
  self:ResetInfinityGridLocate()
  self:ChooseOneItem()
  self:OnEquipTabChangeShow(iTag)
end

function Form_Bag:OnEquipTabChangeShow(index)
  for i = 0, 4 do
    if index == i then
      self["m_img_tab_sel02" .. i]:SetActive(true)
    else
      self["m_img_tab_sel02" .. i]:SetActive(false)
    end
  end
end

function Form_Bag:OnFilterChanged(iIndex, bDown)
  self.m_iFilterTabIndex = iIndex
  self.m_bFilterDown = bDown
  self:ResetInfinityGridLocate()
  self:RefreshItemList()
  self:ChooseOneItem()
end

function Form_Bag:RefreshShowItemList(itemList)
  local dataList = self:GeneratedListData(itemList)
  if self.m_iTagCur == TagType.Equipment then
    self.m_itemListInfinityGrid:ShowItemList(dataList)
  else
    self.m_itemListInfinityGrid2:ShowItemList(dataList)
  end
end

function Form_Bag:ResetInfinityGridLocate()
  if self.m_iTagCur == TagType.Equipment then
    self.m_itemListInfinityGrid:LocateTo(0)
  else
    self.m_itemListInfinityGrid2:LocateTo(0)
  end
end

function Form_Bag:GeneratedListData(itemList)
  local dataList = {}
  for i, v in ipairs(itemList) do
    local itemData = v
    local customData = v.data
    if customData then
      customData.bBag = true
    else
      customData = {bBag = true}
    end
    itemData.customData = customData
    dataList[#dataList + 1] = itemData
  end
  return dataList
end

function Form_Bag:RefreshItemList()
  self.m_pnl_item_des:SetActive(false)
  if self.m_iTagCur == TagType.Equipment then
    self.m_bg_tab02:SetActive(true)
    self.m_img_rl_bg:SetActive(true)
    self.m_scrollView:SetActive(true)
    self.m_scrollView2:SetActive(false)
    if not self.m_equipTagCur or self.m_equipTagCur == 0 then
      self.m_itemList = EquipManager:GetUnOverLoadEquipDataList()
    else
      self.m_itemList = EquipManager:GetUnOverLoadEquipDataListByPos(self.m_equipTagCur)
    end
    if self.m_iFilterTabIndex == SortType.Quality then
      EquipManager:SortEquipListByQuality(self.m_itemList, self.m_bFilterDown)
    elseif self.m_iFilterTabIndex == SortType.Level then
      EquipManager:SortEquipListByLevel(self.m_itemList, self.m_bFilterDown)
    end
    self.m_img_line:SetActive(true)
    self.m_txt_rl_num_Text.text = #self.m_itemList
  else
    self.m_bg_tab02:SetActive(false)
    self.m_img_rl_bg:SetActive(false)
    self.m_img_line:SetActive(false)
    self.m_scrollView:SetActive(false)
    self.m_scrollView2:SetActive(true)
    self.m_itemList = ItemManager:GetItemListByTag(self.m_iTagCur)
    table.sort(self.m_itemList, handler(self, self.SortItemList))
  end
  self:RefreshShowItemList(self.m_itemList)
end

function Form_Bag:ChooseOneItem(index)
  if self.m_itemList then
    if #self.m_itemList == 0 then
      self.m_bg_empty:SetActive(true)
    else
      index = math.min(#self.m_itemList, index or 1)
      self.m_selItemIndex = index
      local chooseFJItemData = self.m_itemList[index]
      if chooseFJItemData then
        self.m_selItemData = chooseFJItemData
        if ResourceUtil:GetResourceTypeById(chooseFJItemData.iID) == ResourceUtil.RESOURCE_TYPE.EQUIPS then
          self:RefreshEquipPanel()
        else
          self:RefreshPanelItemTips(chooseFJItemData.iID, chooseFJItemData.iNum)
        end
        if self.m_iTagCur == TagType.Equipment then
          self.m_itemListInfinityGrid:OnChooseItem(self.m_selItemIndex, true)
        else
          self.m_itemListInfinityGrid2:OnChooseItem(self.m_selItemIndex, true)
        end
      end
      self.m_bg_empty:SetActive(false)
    end
  end
end

function Form_Bag:SortItemList(a, b)
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

function Form_Bag:OnCommonItemClk(index, widgetItemObj)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if self.m_iTagCur == TagType.Equipment then
    self.m_itemListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
    self.m_itemListInfinityGrid:OnChooseItem(fjItemIndex, true)
  else
    self.m_itemListInfinityGrid2:OnChooseItem(self.m_selItemIndex, false)
    self.m_itemListInfinityGrid2:OnChooseItem(fjItemIndex, true)
  end
  self.m_selItemIndex = fjItemIndex
  local chooseFJItemData = self.m_itemList[fjItemIndex]
  if chooseFJItemData then
    self.m_selItemData = chooseFJItemData
    if ResourceUtil:GetResourceTypeById(chooseFJItemData.iID) == ResourceUtil.RESOURCE_TYPE.EQUIPS then
      self:RefreshEquipPanel()
    else
      self:RefreshPanelItemTips(chooseFJItemData.iID, chooseFJItemData.iNum)
    end
  end
end

function Form_Bag:OnEventItemSet(vItemChange)
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
    self:ChooseOneItem(self.m_selItemIndex)
  else
    for _, stItemChange in pairs(vItemChange) do
      if stItemChange.iID == self.m_iItemTipsID then
        self:RefreshPanelItemTips(stItemChange.iID, stItemChange.iNum)
        break
      end
    end
  end
end

function Form_Bag:Back()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_updateQueueItemIcon:clear()
  for i = 1, #self.m_vItemIcon do
    local stItemInfo = self.m_vItemIcon[i]
    if stItemInfo.go.activeSelf then
      stItemInfo.go:GetComponent("Animation"):Play("list_big_out")
    end
  end
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_BAG)
end

function Form_Bag:InitPanelItemTips()
  self.m_panelItemTipsConfig = {}
  local panelBaseConfig = {}
  local panelBase = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_base").gameObject
  local goItemIconRoot = panelBase.transform:Find("c_common_item_middle").gameObject
  panelBaseConfig.widgetItemIcon = self:createItemIcon(goItemIconRoot)
  panelBaseConfig.textName = panelBase.transform:Find("m_txt_name"):GetComponent(T_TextMeshProUGUI)
  panelBaseConfig.textNum = panelBase.transform:Find("m_z_txt_num/m_txt_num01"):GetComponent(T_TextMeshProUGUI)
  panelBaseConfig.imageMax = panelBase.transform:Find("m_img_max").gameObject
  self.m_panelItemTipsConfig.panelBaseConfig = panelBaseConfig
  local panelDescConfig = {}
  local panelDesc = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_des").gameObject
  panelDescConfig.panel = panelDesc
  local scrollViewDesc = panelDesc.transform:Find("scrollview")
  panelDescConfig.goTextDesc = scrollViewDesc:GetComponent("ScrollRect").content.gameObject
  panelDescConfig.textDesc = panelDescConfig.goTextDesc:GetComponent(T_TextMeshProUGUI)
  self.m_panelItemTipsConfig.panelDescConfig = panelDescConfig
  local panelChestCertainConfig = {}
  local panelChestCertain = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_mustwin").gameObject
  panelChestCertainConfig.panel = panelChestCertain
  local scrollViewChestCertain = panelChestCertain.transform:Find("m_scrollview_mustwin").gameObject
  panelChestCertainConfig.scrollView = scrollViewChestCertain
  panelChestCertainConfig.goChestCertainPanelItemTemplate = scrollViewChestCertain:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  panelChestCertainConfig.goChestCertainPanelItemTemplate:SetActive(false)
  panelChestCertainConfig.vChestCertainPanelItem = {}
  self.m_panelItemTipsConfig.panelChestCertainConfig = panelChestCertainConfig
  local panelChestRandomConfig = {}
  local panelChestRandom = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_random").gameObject
  panelChestRandomConfig.panel = panelChestRandom
  panelChestRandomConfig.goTextRandom = panelChestRandom.transform:Find("txt_des_random").gameObject
  panelChestRandomConfig.goTextCustom = panelChestRandom.transform:Find("txt_des_custom").gameObject
  panelChestRandomConfig.goBtnRandomDetail = panelChestRandom.transform:Find("m_btn_randomdetail").gameObject
  local scrollViewChestRandom = panelChestRandom.transform:Find("m_scrollview_random").gameObject
  panelChestRandomConfig.scrollView = scrollViewChestRandom
  panelChestRandomConfig.goChestRandomPanelItemTemplate = scrollViewChestRandom:GetComponent("ScrollRect").content.transform:Find("c_common_item").gameObject
  panelChestRandomConfig.goChestRandomPanelItemTemplate:SetActive(false)
  panelChestRandomConfig.vChestRandomPanelItem = {}
  self.m_panelItemTipsConfig.panelChestRandomConfig = panelChestRandomConfig
  local panelCoinConfig = {}
  local panelCoin = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_coin").gameObject
  panelCoinConfig.panel = panelCoin
  self.m_panelItemTipsConfig.panelCoinConfig = panelCoinConfig
  local panelJumpConfig = {}
  local panelJump = self.m_pnl_item_des.transform:Find("img_bg/m_pnl_jump").gameObject
  panelJumpConfig.panel = panelJump
  local scrollViewJump = panelJump.transform:Find("m_scrollview_access").gameObject
  panelJumpConfig.scrollView = scrollViewJump
  panelJumpConfig.goJumpPanelItemTemplate = scrollViewJump:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  panelJumpConfig.goJumpPanelItemTemplate:SetActive(false)
  panelJumpConfig.m_vJumpPanelItem = {}
  self.m_panelItemTipsConfig.panelJumpConfig = panelJumpConfig
  local panelUseConfig = {}
  local panelUse = self.m_pnl_item_des.transform:Find("m_pnl_use").gameObject
  panelUseConfig.panel = panelUse
  panelUseConfig.goBtnUseDetail = panelUse.transform:Find("m_btn_usedetail").gameObject
  panelUseConfig.widgetNumStepper = self:createNumStepper(panelUse.transform:Find("ui_common_stepper"))
  self.m_panelItemTipsConfig.panelUseConfig = panelUseConfig
  local panelBtnConfig = {}
  local panelBtn = self.m_pnl_item_des.transform:Find("m_pnl_btn").gameObject
  panelBtnConfig.panel = panelBtn
  panelBtnConfig.btnUse = panelBtn.transform:Find("m_btnUse"):GetComponent("Button")
  self.m_panelItemTipsConfig.panelBtnConfig = panelBtnConfig
end

function Form_Bag:RefreshPanelItemTips(iID, iNum)
  self.m_iItemTipsID = iID
  self.m_iItemTipsNum = iNum
  if iID == nil then
    self.m_pnl_item_des:SetActive(false)
    return
  end
  self.m_pnl_equipment:SetActive(false)
  self.m_pnl_item_des:SetActive(true)
  self.m_equip_node:SetActive(false)
  self.m_panelItemTipsConfig.panelBaseConfig.widgetItemIcon:SetActive(true)
  self.m_stItemTipsData = CS.CData_Item.GetInstance():GetValue_ByItemID(self.m_iItemTipsID)
  self.m_z_txt_num_Text.text = ConfigManager:GetCommonTextById(20007)
  local panelBaseConfig = self.m_panelItemTipsConfig.panelBaseConfig
  local widgetItemIcon = panelBaseConfig.widgetItemIcon
  widgetItemIcon:SetItemInfo(self.m_iItemTipsID)
  if CS.UnityEngine.Application.isEditor then
    self.m_iWidgetItemTipsIconClickLastTime = 0
    widgetItemIcon:SetItemIconClickCB(handler(self, self.OnWidgetItemTipsIconClicked))
  else
    widgetItemIcon:SetItemIconClickCB(nil)
  end
  panelBaseConfig.textName.text = self.m_stItemTipsData.m_mItemName
  panelBaseConfig.textNum.text = tostring(self.m_iItemTipsNum)
  if 0 < self.m_stItemTipsData.m_ItemMaxNum and self.m_iItemTipsNum >= self.m_stItemTipsData.m_ItemMaxNum then
    panelBaseConfig.imageMax:SetActive(true)
  else
    panelBaseConfig.imageMax:SetActive(false)
  end
  self.m_panelItemTipsConfig.panelDescConfig.panel:SetActive(false)
  self.m_panelItemTipsConfig.panelChestCertainConfig.panel:SetActive(false)
  self.m_panelItemTipsConfig.panelChestRandomConfig.panel:SetActive(false)
  self.m_panelItemTipsConfig.panelCoinConfig.panel:SetActive(false)
  self.m_panelItemTipsConfig.panelUseConfig.panel:SetActive(false)
  self.m_panelItemTipsConfig.panelBtnConfig.panel:SetActive(false)
  if self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestCertain or self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.IdleCapsule then
    self:RefreshSubTypeChestCertain()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.EffectiveItem then
    self:RefreshDesc()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestCustom then
    self:RefreshSubTypeChestCustom()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestRandom then
    self:RefreshSubTypeChestRandom()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentCertain then
    self:RefreshSubTypeFragmentCertain()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentRandom then
    self:RefreshSubTypeFragmentRandom()
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentDeduplicatedRandom then
    self:RefreshSubTypeFragmentDeduplicatedRandom()
  else
    self:RefreshDesc()
  end
  self:RefreshJump()
end

function Form_Bag:RefreshEquipPanel()
  self.m_pnl_use:SetActive(false)
  self.m_pnl_btn:SetActive(false)
  self.m_pnl_random:SetActive(false)
  self.m_pnl_mustwin:SetActive(false)
  self.m_pnl_jump:SetActive(false)
  self.m_pnl_coin:SetActive(false)
  self.m_pnl_base:SetActive(true)
  self.m_panelItemTipsConfig.panelBaseConfig.widgetItemIcon:SetActive(false)
  self.m_img_max:SetActive(false)
  self.m_pnl_item_des:SetActive(true)
  self.m_equip_node:SetActive(true)
  self.m_pnl_equipment:SetActive(true)
  self.m_pnl_des:SetActive(false)
  if self.m_selItemData then
    local processData = ResourceUtil:GetProcessRewardData({
      iID = self.m_selItemData.iID,
      iNum = 1
    }, self.m_selItemData.data)
    self.m_txt_name_Text.text = processData.name
    self.m_txt_num01_Text.text = processData.level
    self.m_z_txt_num_Text.text = ConfigManager:GetCommonTextById(20008)
    ResourceUtil:CreateEquipIcon(self.m_equip_icon_Image, self.m_selItemData.iID)
    self.m_txt_imf_Text.text = processData.description
    local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_selItemData.iID, processData.level)
    for i = 1, 2 do
      local attrInfo = attrInfoList[i]
      if attrInfo and attrInfo.cfg then
        ResourceUtil:CreatePropertyImg(self["m_icon_attributes0" .. i .. "_Image"], attrInfo.id)
        local attrCfg = attrInfo.cfg
        self["m_txt_attributes0" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
        self["m_txt_num_before0" .. i .. "_Text"].text = tostring(attrInfo.num)
      end
    end
    local qualityCfg = GlobalConfig.QUALITY_EQUIP_SETTING[processData.quality]
    if qualityCfg then
      self.m_txt_quality_Text.text = ConfigManager:GetCommonTextById(qualityCfg.name)
    end
    ResourceUtil:CreateEquipQualityImg(self.m_img_icon_quality_bg_Image, processData.quality, GlobalConfig.EQUIP_QUALITY_STYLE.Default)
    local equipCfg = EquipmentConfigInstance:GetValue_ByEquipID(self.m_selItemData.iID)
    ResourceUtil:CreateEquipPosImg(self.m_icon_position_Image, equipCfg.m_PosRes)
    self.m_iEquipCareer = processData.career
    if self.m_iEquipCareer and #self.m_iEquipCareer > 0 then
      for i, v in ipairs(self.m_iEquipCareer) do
        if self["m_img_career_bg" .. i] then
          self["m_img_career_bg" .. i]:SetActive(true)
          ResourceUtil:CreateCareerImg(self["m_icon_career" .. i .. "_Image"], v)
        end
      end
    else
      self.m_img_career_bg1:SetActive(false)
      self.m_img_career_bg2:SetActive(false)
    end
    self:RefreshJump(true)
  end
end

function Form_Bag:RefreshDesc()
  local panelDescConfig = self.m_panelItemTipsConfig.panelDescConfig
  panelDescConfig.panel:SetActive(true)
  local v2TextDescOffset = panelDescConfig.goTextDesc:GetComponent("RectTransform").anchoredPosition
  v2TextDescOffset.y = 0
  panelDescConfig.goTextDesc:GetComponent("RectTransform").anchoredPosition = v2TextDescOffset
  panelDescConfig.textDesc.text = self.m_stItemTipsData.m_mItemDesc
end

function Form_Bag:RefreshJump(isEquipment)
  local panelJumpConfig = self.m_panelItemTipsConfig.panelJumpConfig
  local jumpList = {}
  if isEquipment and self.m_selItemData and self.m_selItemData.data then
    local cfg = EquipManager:GetEquipCfgByBaseId(self.m_selItemData.data.iBaseId)
    if cfg then
      jumpList = utils.changeCSArrayToLuaTable(cfg.m_SystemWarp)
    end
  elseif self.m_stItemTipsData then
    jumpList = utils.changeCSArrayToLuaTable(self.m_stItemTipsData.m_SystemWarp)
  end
  if not jumpList or #jumpList == 0 then
    panelJumpConfig.panel:SetActive(false)
    return
  end
  panelJumpConfig.panel:SetActive(true)
  local panelItemList = panelJumpConfig.scrollView:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local vGetItemInfo = jumpList
  for i = 1, #vGetItemInfo do
    local goJumpPanelItem = panelJumpConfig.m_vJumpPanelItem[i]
    if goJumpPanelItem == nil then
      goJumpPanelItem = {}
      goJumpPanelItem.go = CS.UnityEngine.GameObject.Instantiate(panelJumpConfig.goJumpPanelItemTemplate, panelItemList)
      panelJumpConfig.m_vJumpPanelItem[i] = goJumpPanelItem
    end
    goJumpPanelItem.go:SetActive(true)
    local stGetItemData = CS.CData_Jump.GetInstance():GetValue_ByJumpID(vGetItemInfo[i])
    if stGetItemData then
      goJumpPanelItem.go.transform:Find("c_txt_item_name1"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.m_mName
    end
    local m_btn_jump = goJumpPanelItem.go.transform:Find("m_btn_jump"):GetComponent("Button")
    local m_btn_jump_obj = goJumpPanelItem.go.transform:Find("m_btn_jump").gameObject
    local m_btn_lock = goJumpPanelItem.go.transform:Find("m_btn_lock"):GetComponent("Button")
    local m_btn_lock_obj = goJumpPanelItem.go.transform:Find("m_btn_lock").gameObject
    m_btn_jump.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, m_btn_jump, function()
      if vGetItemInfo then
        QuickOpenFuncUtil:OpenFunc(vGetItemInfo[i])
      end
    end)
    local jumpIns = ConfigManager:GetConfigInsByName("Jump")
    local jump_item = jumpIns:GetValue_ByJumpID(vGetItemInfo[i])
    if jump_item then
      local open_condition_id = jump_item.m_SystemID or 0
      local open_flag, tips_id = UnlockSystemUtil:IsSystemOpen(open_condition_id)
      if 0 < open_condition_id and not open_flag then
        m_btn_jump_obj:SetActive(false)
        m_btn_lock_obj:SetActive(true)
        m_btn_lock.onClick:RemoveAllListeners()
        UILuaHelper.BindButtonClickManual(self, m_btn_lock, function()
          if tips_id then
            local paramData = {delayClose = 2, prompts = tips_id}
            utils.createPromptTips(paramData)
          end
        end)
      else
        m_btn_jump_obj:SetActive(true)
        m_btn_lock_obj:SetActive(false)
      end
    end
  end
  for i = #vGetItemInfo + 1, #panelJumpConfig.m_vJumpPanelItem do
    panelJumpConfig.m_vJumpPanelItem[i].go:SetActive(false)
  end
end

function Form_Bag:RefreshSubTypeChestCertain()
  local panelChestCertainConfig = self.m_panelItemTipsConfig.panelChestCertainConfig
  panelChestCertainConfig.panel:SetActive(true)
  local panelItemList = panelChestCertainConfig.scrollView:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local vGetItemInfo = string.split(self.m_stItemTipsData.m_ItemUse, ";")
  for i = 1, #vGetItemInfo do
    local goChestCertainPanelItem = panelChestCertainConfig.vChestCertainPanelItem[i]
    if goChestCertainPanelItem == nil then
      goChestCertainPanelItem = {}
      goChestCertainPanelItem.go = CS.UnityEngine.GameObject.Instantiate(panelChestCertainConfig.goChestCertainPanelItemTemplate, panelItemList)
      goChestCertainPanelItem.widgetItemIcon = self:createCommonItem(goChestCertainPanelItem.go.transform:Find("c_common_item"))
      panelChestCertainConfig.vChestCertainPanelItem[i] = goChestCertainPanelItem
    end
    goChestCertainPanelItem.go:SetActive(true)
    local vItemInfoStr = string.split(vGetItemInfo[i], ",")
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    if self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.IdleCapsule then
      iGetItemNum = HangUpManager:GetItemProductionByIdAndSeconds(iGetItemID, iGetItemNum)
    end
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    goChestCertainPanelItem.widgetItemIcon:SetItemInfo(processData)
    local stGetItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iGetItemID)
    goChestCertainPanelItem.go.transform:Find("c_txt_item_name"):GetComponent(T_TextMeshProUGUI).text = stGetItemData.m_mItemName
    goChestCertainPanelItem.go.transform:Find("c_txt_item_name_1"):GetComponent(T_TextMeshProUGUI).text = "x" .. tostring(iGetItemNum)
  end
  for i = #vGetItemInfo + 1, #panelChestCertainConfig.vChestCertainPanelItem do
    panelChestCertainConfig.vChestCertainPanelItem[i].go:SetActive(false)
  end
  local panelUseConfig = self.m_panelItemTipsConfig.panelUseConfig
  panelUseConfig.panel:SetActive(true)
  panelUseConfig.goBtnUseDetail:SetActive(false)
  panelUseConfig.widgetNumStepper:SetNumShowMax(false)
  panelUseConfig.widgetNumStepper:SetNumMax(self.m_iItemTipsNum)
  panelUseConfig.widgetNumStepper:SetNumMin(1)
  panelUseConfig.widgetNumStepper:SetNumCur(1)
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelBtnConfig.panel:SetActive(true)
  panelBtnConfig.btnUse.interactable = true
end

function Form_Bag:RefreshSubTypeChestCustom()
  self:RefreshDesc()
  local panelChestRandomConfig = self.m_panelItemTipsConfig.panelChestRandomConfig
  panelChestRandomConfig.panel:SetActive(true)
  panelChestRandomConfig.goBtnRandomDetail:SetActive(false)
  panelChestRandomConfig.goTextRandom:SetActive(false)
  panelChestRandomConfig.goTextCustom:SetActive(true)
  local panelItemList = panelChestRandomConfig.scrollView:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.x = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local vGetItemInfo = string.split(self.m_stItemTipsData.m_ItemUse, ";")
  for i = 1, #vGetItemInfo do
    local goChestRandomPanelItem = panelChestRandomConfig.vChestRandomPanelItem[i]
    if goChestRandomPanelItem == nil then
      goChestRandomPanelItem = {}
      goChestRandomPanelItem.go = CS.UnityEngine.GameObject.Instantiate(panelChestRandomConfig.goChestRandomPanelItemTemplate, panelItemList)
      goChestRandomPanelItem.widget = self:createCommonItem(goChestRandomPanelItem.go)
      panelChestRandomConfig.vChestRandomPanelItem[i] = goChestRandomPanelItem
    end
    goChestRandomPanelItem.go:SetActive(true)
    local vItemInfoStr = string.split(vGetItemInfo[i], ",")
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    goChestRandomPanelItem.widget:SetItemInfo(processData)
  end
  for i = #vGetItemInfo + 1, #panelChestRandomConfig.vChestRandomPanelItem do
    panelChestRandomConfig.vChestRandomPanelItem[i].go:SetActive(false)
  end
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelBtnConfig.panel:SetActive(true)
  panelBtnConfig.btnUse.interactable = true
end

function Form_Bag:RefreshSubTypeChestRandom()
  self:RefreshDesc()
  local panelChestRandomConfig = self.m_panelItemTipsConfig.panelChestRandomConfig
  panelChestRandomConfig.panel:SetActive(true)
  panelChestRandomConfig.goBtnRandomDetail:SetActive(true)
  panelChestRandomConfig.goTextRandom:SetActive(true)
  panelChestRandomConfig.goTextCustom:SetActive(false)
  local panelItemList = panelChestRandomConfig.scrollView:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.x = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local iRandomPoolID = tonumber(self.m_stItemTipsData.m_ItemUse)
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    for i = 1, #panelChestRandomConfig.vChestRandomPanelItem do
      panelChestRandomConfig.vChestRandomPanelItem[i].go:SetActive(false)
    end
    return
  end
  local vRandomItemInfo = utils.changeCSArrayToLuaTable(stRandomPoolData.m_RandompoolContent)
  if ActivityManager:IsInCensorOpen() then
    local temp = utils.changeCSArrayToLuaTable(stRandomPoolData.m_CensorRandompoolContent)
    vRandomItemInfo = 0 < #temp and temp or vRandomItemInfo
  end
  for i = 1, #vRandomItemInfo do
    local goChestRandomPanelItem = panelChestRandomConfig.vChestRandomPanelItem[i]
    if goChestRandomPanelItem == nil then
      goChestRandomPanelItem = {}
      goChestRandomPanelItem.go = CS.UnityEngine.GameObject.Instantiate(panelChestRandomConfig.goChestRandomPanelItemTemplate, panelItemList)
      goChestRandomPanelItem.widget = self:createCommonItem(goChestRandomPanelItem.go)
      panelChestRandomConfig.vChestRandomPanelItem[i] = goChestRandomPanelItem
    end
    goChestRandomPanelItem.go:SetActive(true)
    local vItemInfoStr = vRandomItemInfo[i]
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    goChestRandomPanelItem.widget:SetItemInfo(processData)
  end
  for i = #vRandomItemInfo + 1, #panelChestRandomConfig.vChestRandomPanelItem do
    panelChestRandomConfig.vChestRandomPanelItem[i].go:SetActive(false)
  end
  local panelUseConfig = self.m_panelItemTipsConfig.panelUseConfig
  panelUseConfig.panel:SetActive(true)
  panelUseConfig.goBtnUseDetail:SetActive(false)
  panelUseConfig.widgetNumStepper:SetNumShowMax(false)
  panelUseConfig.widgetNumStepper:SetNumMax(self.m_iItemTipsNum)
  panelUseConfig.widgetNumStepper:SetNumMin(1)
  panelUseConfig.widgetNumStepper:SetNumCur(1)
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelBtnConfig.panel:SetActive(true)
  panelBtnConfig.btnUse.interactable = true
end

function Form_Bag:RefreshSubTypeFragmentCertain()
  self:RefreshDesc()
  local panelUseConfig = self.m_panelItemTipsConfig.panelUseConfig
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelUseConfig.panel:SetActive(true)
  panelUseConfig.goBtnUseDetail:SetActive(false)
  local iOneCount = tonumber(string.split(self.m_stItemTipsData.m_ItemUse, ":")[2])
  local iMaxNum = math.floor(self.m_iItemTipsNum / iOneCount)
  panelUseConfig.widgetNumStepper:SetNumShowMax(true)
  if iMaxNum == 0 then
    panelUseConfig.widgetNumStepper:SetNumMax(0)
    panelUseConfig.widgetNumStepper:SetNumMin(0)
    panelUseConfig.widgetNumStepper:SetNumCur(0)
  else
    panelUseConfig.widgetNumStepper:SetNumMax(iMaxNum)
    panelUseConfig.widgetNumStepper:SetNumMin(1)
    panelUseConfig.widgetNumStepper:SetNumCur(1)
    panelBtnConfig.btnUse.interactable = true
  end
  panelBtnConfig.panel:SetActive(true)
end

function Form_Bag:RefreshSubTypeFragmentRandom()
  self:RefreshDesc()
  local panelUseConfig = self.m_panelItemTipsConfig.panelUseConfig
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelUseConfig.panel:SetActive(true)
  panelUseConfig.goBtnUseDetail:SetActive(true)
  local iOneCount = tonumber(string.split(self.m_stItemTipsData.m_ItemUse, ":")[2])
  local iMaxNum = math.floor(self.m_iItemTipsNum / iOneCount)
  panelUseConfig.widgetNumStepper:SetNumShowMax(true)
  if iMaxNum == 0 then
    panelUseConfig.widgetNumStepper:SetNumMax(0)
    panelUseConfig.widgetNumStepper:SetNumMin(1)
    panelUseConfig.widgetNumStepper:SetNumCur(0)
  else
    panelUseConfig.widgetNumStepper:SetNumMax(iMaxNum)
    panelUseConfig.widgetNumStepper:SetNumMin(1)
    panelUseConfig.widgetNumStepper:SetNumCur(1)
    panelBtnConfig.btnUse.interactable = true
  end
  panelBtnConfig.panel:SetActive(true)
end

function Form_Bag:RefreshSubTypeFragmentDeduplicatedRandom()
  self:RefreshDesc()
  local panelUseConfig = self.m_panelItemTipsConfig.panelUseConfig
  local panelBtnConfig = self.m_panelItemTipsConfig.panelBtnConfig
  panelUseConfig.panel:SetActive(false)
  panelUseConfig.goBtnUseDetail:SetActive(false)
  local iOneCount = tonumber(self.m_stItemTipsData.m_ItemUse)
  local iMaxNum = math.floor(self.m_iItemTipsNum / iOneCount)
  panelUseConfig.widgetNumStepper:SetNumShowMax(true)
  if iMaxNum == 0 then
    panelUseConfig.widgetNumStepper:SetNumMax(0)
    panelUseConfig.widgetNumStepper:SetNumMin(0)
    panelUseConfig.widgetNumStepper:SetNumCur(0)
  else
    panelUseConfig.widgetNumStepper:SetNumMax(iMaxNum)
    panelUseConfig.widgetNumStepper:SetNumMin(1)
    panelUseConfig.widgetNumStepper:SetNumCur(1)
    panelBtnConfig.btnUse.interactable = true
  end
  panelBtnConfig.panel:SetActive(true)
end

function Form_Bag:OnBtnrandomdetailClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iRandomPoolID = tonumber(self.m_stItemTipsData.m_ItemUse)
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    return
  end
  if stRandomPoolData.m_RandompoolUIType == 1 then
    StackPopup:Push(UIDefines.ID_FORM_BAGINFO, {iRandomPoolID = iRandomPoolID})
  else
    StackPopup:Push(UIDefines.ID_FORM_ITEMRANDOMDETAIL, {iRandomPoolID = iRandomPoolID})
  end
end

function Form_Bag:OnBtnusedetailClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iRandomPoolID = tonumber(string.split(self.m_stItemTipsData.m_ItemUse, ":")[1])
  local stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(iRandomPoolID)
  if stRandomPoolData == nil then
    return
  end
  if stRandomPoolData.m_RandompoolUIType == 1 then
    StackPopup:Push(UIDefines.ID_FORM_BAGINFO, {iRandomPoolID = iRandomPoolID})
  else
    StackPopup:Push(UIDefines.ID_FORM_ITEMRANDOMDETAIL, {iRandomPoolID = iRandomPoolID})
  end
end

function Form_Bag:OnEventItemUse(stItemUseInfo)
  local iID = stItemUseInfo.iID
  if self.m_iItemTipsIDUse == iID and next(stItemUseInfo.vReward) then
    local vReward = stItemUseInfo.vReward
    utils.popUpRewardUI(vReward)
  end
  self:RefreshItemList()
  self:ChooseOneItem(self.m_selItemIndex)
end

function Form_Bag:OnBtnUseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_iItemTipsIDUse = self.m_iItemTipsID
  if self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestCertain or self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.IdleCapsule then
    ItemManager:RequestItemUse(self.m_iItemTipsID, self.m_panelItemTipsConfig.panelUseConfig.widgetNumStepper:GetNumCur())
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestCustom then
    StackFlow:Push(UIDefines.ID_FORM_OPTIONALGIFT, {
      iID = self.m_iItemTipsID
    })
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.ChestRandom then
    ItemManager:RequestItemUse(self.m_iItemTipsID, self.m_panelItemTipsConfig.panelUseConfig.widgetNumStepper:GetNumCur())
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentCertain then
    local iNum = self.m_panelItemTipsConfig.panelUseConfig.widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(string.split(self.m_stItemTipsData.m_ItemUse, ":")[2])
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iItemTipsID, iNum)
    else
      local paramData = {delayClose = 2, prompts = 30004}
      utils.createPromptTips(paramData)
    end
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentRandom then
    local iNum = self.m_panelItemTipsConfig.panelUseConfig.widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(string.split(self.m_stItemTipsData.m_ItemUse, ":")[2])
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iItemTipsID, iNum)
    else
      local paramData = {delayClose = 2, prompts = 30004}
      utils.createPromptTips(paramData)
    end
  elseif self.m_stItemTipsData.m_ItemSubType == ItemManager.ItemSubType.FragmentDeduplicatedRandom then
    local iNum = self.m_panelItemTipsConfig.panelUseConfig.widgetNumStepper:GetNumCur()
    if 0 < iNum then
      local iOneCount = tonumber(self.m_stItemTipsData.m_ItemUse)
      iNum = iNum * iOneCount
      ItemManager:RequestItemUse(self.m_iItemTipsID, iNum)
    else
      local paramData = {delayClose = 2, prompts = 30004}
      utils.createPromptTips(paramData)
    end
  end
end

function Form_Bag:OnWidgetItemTipsIconClicked()
  local iDiff = CS.Util.GetTime() - self.m_iWidgetItemTipsIconClickLastTime
  if iDiff <= 300 then
    local loginContext = CS.LoginContext.GetContext()
    Util.RequestGM(loginContext.CurZoneInfo.iZoneId, "add_item " .. loginContext.AccountID .. " " .. self.m_iItemTipsID .. " 999")
  end
  self.m_iWidgetItemTipsIconClickLastTime = CS.Util.GetTime()
end

function Form_Bag:OnItemClk()
end

function Form_Bag:IsFullScreen()
  return true
end

function Form_Bag:GuideSetItemTop(itemId)
  if self.m_itemList == nil or #self.m_itemList < 2 then
    return
  end
  for i, v in ipairs(self.m_itemList) do
    if v.iID == itemId then
      self.m_itemList[i] = self.m_itemList[1]
      self.m_itemList[1] = v
      break
    end
  end
  self:RefreshShowItemList(self.m_itemList)
  self:ChooseOneItem()
end

local fullscreen = true
ActiveLuaUI("Form_Bag", Form_Bag)
return Form_Bag
