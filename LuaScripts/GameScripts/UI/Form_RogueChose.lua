local Form_RogueChose = class("Form_RogueChose", require("UI/UIFrames/Form_RogueChoseUI"))
local RogueDragEquipItem = require("UI/Item/RogueChoose/RogueDragEquipItem")
local __SimRoomBuffListMaxNum = tonumber(ConfigManager:GetGlobalSettingsByKey("RogueStageBagChooseNum"))
local DragRectType = RogueStageManager.DragRectType
local RogueStageItemType = RogueStageManager.RogueStageItemType
local RogueStageItemSubType = RogueStageManager.RogueStageItemSubType
local MaxTempPosNum = 5
local __RogueChose_inone = "RogueChose_inone"
local __RogueChose_in = "RogueChose_in"

function Form_RogueChose:SetInitParam(param)
end

function Form_RogueChose:Init(gameObject, csui)
  self:CheckCreateVariable(csui)
  Form_RogueChose.super.Init(self, gameObject, csui)
end

function Form_RogueChose:AfterInit()
  self.GuideRecordActiveCount = 0
  self.super.AfterInit(self)
  self.m_tips_pos_base_trans = self.m_tips_pos_base.transform
  self.m_equip_item_root_trans = self.m_equip_item_root.transform
  local initGridX = self.m_uiVariables.initGridX
  local initGridY = self.m_uiVariables.initGridY
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  if self.m_levelRogueStageHelper then
    local effect = self.m_levelRogueStageHelper:GetTechEffectByType(MTTDProto.RogueTechEffect_InitGrid)
    if 0 < table.getn(effect) and effect[1] and effect[2] then
      initGridX = effect[1][1]
      initGridY = effect[2][1]
    end
  end
  self.m_RogueGridSubPanel = self:CreateSubPanel("RogueGridSubPanel", self.m_rogue_bg_grid, self, {
    maxGridX = self.m_uiVariables.maxGridX,
    maxGridY = self.m_uiVariables.maxGridY,
    initGridX = initGridX,
    initGridY = initGridY
  }, nil, nil)
  local initGridData = {
    itemEnterDragBackFun = function(itemIndex, dragPos)
      self:OnItemEnterDrag(itemIndex, dragPos)
    end,
    itemDragBackFun = function(dragPos)
      self:OnItemDrag(dragPos)
    end,
    itemDragEndBackFun = function(dragPos)
      self:OnItemEndDrag(dragPos)
    end,
    itemClkBackFun = function(itemIndex, itemTrans)
      self:OnItemClk(itemIndex, itemTrans)
    end
  }
  self.m_luaRogueEquipInfinityGrid = self:CreateInfinityGrid(self.m_scrollview_property_InfinityGrid, "RogueChoose/UIRogueEquipItem", initGridData)
  self.m_showRogueEquipItemDataList = {}
  self.m_isHaveChooseNum = 0
  self.m_MainCamera = GameCameraManager.GetCurMainCamera()
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.DragPosRectTab = {
    [DragRectType.BgGrid] = {
      areaRect = self.m_rogue_bg_grid.transform
    },
    [DragRectType.ItemList] = {
      areaRect = self.m_scrollview_property.transform
    },
    [DragRectType.TempPos] = {
      areaRect = self.m_temp_pos_root.transform
    },
    [DragRectType.Delete] = {
      areaRect = self.m_del_root.transform
    }
  }
  self.m_rogueBagGridItemList = {}
  self.m_tempBagGridItemPosList = {}
  self.m_startDragType = nil
  self.m_endDragType = nil
  self.m_dragEquipItem = nil
  self.m_dragCanUpEquipItemCom = nil
  self.m_startDragScreenPos = nil
  self.m_startDragEquipItemLocalPosX = nil
  self.m_startDragEquipItemLocalPosY = nil
  self.m_equipUID = 0
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_enterRogueStageFlag = true
  self.m_tempRoundCombineItemIDList = {}
  self.m_tempPosDragItemList = {}
  for i = 1, MaxTempPosNum do
    local btnExtension = self["m_temp_pos_btn" .. i]:GetComponent("ButtonExtensions")
    if btnExtension then
      btnExtension.BeginDrag = handler(self, self["OnTempPosBeginDrag" .. i], i)
      btnExtension.Drag = handler(self, self["OnTempPosDrag" .. i], i)
      btnExtension.EndDrag = handler(self, self["OnTempPosEndDrag" .. i], i)
      btnExtension.Clicked = handler(self, self["OnTempPosClk" .. i], i)
    end
  end
end

function Form_RogueChose:OnOpen()
end

function Form_RogueChose:OnActive()
  self.GuideRecordActiveCount = self.GuideRecordActiveCount + 1
  self.super.OnActive(self)
  self:ResetGuideData()
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self:EnterAnim()
end

function Form_RogueChose:EnterAnim()
  if self.m_enterRogueStageFlag then
    self.m_enterRogueStageFlag = false
    CS.GlobalManager.Instance:TriggerWwiseBGMState(263)
    self.m_pnl_box:SetActive(true)
    if not utils.isNull(self.m_csui.m_uiGameObject) then
      UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, __RogueChose_inone)
    end
  else
    self.m_pnl_box:SetActive(false)
    if not utils.isNull(self.m_csui.m_uiGameObject) then
      UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, __RogueChose_in)
    end
  end
end

function Form_RogueChose:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_RogueChose:OnDestroy()
  self.GuideRecordActiveCount = 0
  self.super.OnDestroy(self)
end

function Form_RogueChose:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local itemIDList = tParam.dropItems
    self.m_isHaveChooseNum = 0
    self.m_showRogueEquipItemDataList = {}
    self.m_tempRoundCombineItemIDList = {}
    self:InitCreateEquipItemDataList(itemIDList)
    self.m_csui.m_param = nil
  end
end

function Form_RogueChose:ClearCacheData()
end

function Form_RogueChose:InitCreateEquipItemDataList(rogueItemIDList)
  if not rogueItemIDList then
    return
  end
  local itemNum = rogueItemIDList.Count
  if itemNum <= 0 then
    return
  end
  local recommendList = self:CheckEquipItemIsRecommend(rogueItemIDList)
  for i = 1, itemNum do
    local tempItemID = rogueItemIDList[i - 1]
    local tempRogueStageItemInfoCfg = self.m_levelRogueStageHelper:GetRogueItemCfgByID(tempItemID)
    local isRecommend = false
    if 0 < table.getn(recommendList) then
      isRecommend = table.indexof(recommendList, tempItemID) ~= false and true or false
    end
    if tempRogueStageItemInfoCfg then
      self.m_equipUID = self.m_equipUID + 1
      local showEquipItemData = {
        uid = self.m_equipUID,
        rogueStageItemCfg = tempRogueStageItemInfoCfg,
        isHaveChoose = false,
        isChooseFull = false,
        isRecommend = isRecommend
      }
      self.m_showRogueEquipItemDataList[#self.m_showRogueEquipItemDataList + 1] = showEquipItemData
    end
  end
end

function Form_RogueChose:CheckEquipItemIsRecommend(rogueItemIDList)
  local recommendList = {}
  if table.getn(rogueItemIDList) == 0 then
    return recommendList
  end
  for i, tempItemID in pairs(rogueItemIDList) do
    local recommend = self:CheckEquipItemIsRecommendMat(tempItemID)
    if recommend then
      recommendList[#recommendList + 1] = tempItemID
    end
  end
  if table.getn(recommendList) > 0 then
    return recommendList
  end
  for i, tempItemID in pairs(rogueItemIDList) do
    local recommend = self:CheckEquipItemIsRecommendMap(tempItemID)
    if recommend then
      recommendList[#recommendList + 1] = tempItemID
    end
  end
  return recommendList
end

function Form_RogueChose:CheckEquipItemIsRecommendMat(itemID)
  if not itemID then
    return
  end
  local rogueStageItemCfg = self.m_levelRogueStageHelper:GetRogueItemCfgByID(itemID)
  if rogueStageItemCfg.m_ItemType == RogueStageManager.RogueStageItemType.Material then
    local connectMatIDList = self.m_levelRogueStageHelper:GetRogueCombinationMapIDListByMaterialID(itemID)
    if table.getn(connectMatIDList) > 0 then
      for i, matID in ipairs(connectMatIDList) do
        local tempRogueDragEquipItemCom = self:GetRogueDragEquipItemByID(matID)
        if tempRogueDragEquipItemCom then
          return true
        end
      end
    end
  end
end

function Form_RogueChose:CheckEquipItemIsRecommendMap(itemID)
  if not itemID then
    return
  end
  local rogueStageItemCfg = self.m_levelRogueStageHelper:GetRogueItemCfgByID(itemID)
  if rogueStageItemCfg.m_ItemSubType == RogueStageManager.RogueStageItemSubType.CommonMap or rogueStageItemCfg.m_ItemSubType == RogueStageManager.RogueStageItemSubType.ExclusiveMap then
    return true
  end
end

function Form_RogueChose:GetDragRectTypeByLocalPos(localPosX, localPosY, localPosZ)
  if not self.m_equip_item_root_trans then
    return
  end
  local dragRectType = DragRectType.Other
  for i, v in pairs(self.DragPosRectTab) do
    local tempRect = v.areaRect
    if UILuaHelper.IsLocalPosInRectTransform(self.m_equip_item_root_trans, localPosX, localPosY, localPosZ, tempRect, self.m_MainCamera) then
      dragRectType = i
      return dragRectType
    end
  end
  return dragRectType
end

function Form_RogueChose:GetMapTypeRogueEquipItemList()
  if not self.m_rogueBagGridItemList then
    return
  end
  local allRogueMapEquipItemList = {}
  for _, v in ipairs(self.m_rogueBagGridItemList) do
    if self.m_levelRogueStageHelper:IsRogueMapMaterialByItemCfg(v.m_rogueEquipItemData.rogueStageItemCfg) == true then
      allRogueMapEquipItemList[#allRogueMapEquipItemList + 1] = v
    end
  end
  table.sort(allRogueMapEquipItemList, function(a, b)
    local gridXA = a:GetPutBgGridIndexXY()
    local gridXB = b:GetPutBgGridIndexXY()
    if gridXA ~= gridXB then
      return gridXA < gridXB
    end
    return a.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID < b.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
  end)
  return allRogueMapEquipItemList
end

function Form_RogueChose:IsEquipItemCanCombine(dragEquipItem)
  if not self.m_RogueGridSubPanel then
    return
  end
  if not dragEquipItem then
    return
  end
  if dragEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemType ~= RogueStageItemType.Material then
    return false
  end
  local allRogueMapEquipItemList = self:GetMapTypeRogueEquipItemList() or {}
  if not next(allRogueMapEquipItemList) then
    return false
  end
  for _, v in ipairs(allRogueMapEquipItemList) do
    local isCanComBine, materialItemList = self.m_RogueGridSubPanel:IsMapEquipItemCanCombine(v)
    if isCanComBine == true then
      return true, v, materialItemList
    end
  end
  return false
end

function Form_RogueChose:IsEquipItemCanEquip(dragEquipItem)
  if not dragEquipItem then
    return
  end
  if not self.m_RogueGridSubPanel then
    return
  end
  return self.m_RogueGridSubPanel:IsEquipItemCanEquip(dragEquipItem)
end

function Form_RogueChose:GetEquipItemIDList()
  if not self.m_rogueBagGridItemList then
    return {}
  end
  local itemIDList = {}
  for i, v in ipairs(self.m_rogueBagGridItemList) do
    local tempItemID = v.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
    itemIDList[#itemIDList + 1] = tempItemID
  end
  return itemIDList
end

function Form_RogueChose:GetTempPosItemIDList()
  if not self.m_rogueBagGridItemList then
    return {}
  end
  local itemIDList = {}
  for i = 1, MaxTempPosNum do
    local tempPosData = self.m_tempBagGridItemPosList[i]
    if tempPosData ~= nil then
      local itemID = tempPosData.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
      itemIDList[#itemIDList + 1] = itemID
    end
  end
  return itemIDList
end

function Form_RogueChose:GetCurTempEmptyIndex()
  if not self.m_tempBagGridItemPosList then
    return
  end
  for i = 1, MaxTempPosNum do
    local tempPosData = self.m_tempBagGridItemPosList[i]
    if tempPosData == nil then
      return i
    end
  end
  return nil
end

function Form_RogueChose:AddEquipDragItem(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  if not self.m_rogueBagGridItemList then
    return
  end
  self.m_rogueBagGridItemList[#self.m_rogueBagGridItemList + 1] = rogueDragEquipItemCom
end

function Form_RogueChose:RemoveEquipItem(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  if not self.m_rogueBagGridItemList then
    return
  end
  for i, v in ipairs(self.m_rogueBagGridItemList) do
    if v == rogueDragEquipItemCom then
      table.remove(self.m_rogueBagGridItemList, i)
    end
  end
end

function Form_RogueChose:AddEquipItemInTemPos(rogueDragEquipItem, tempPosIndex)
  if not rogueDragEquipItem then
    return
  end
  if not tempPosIndex then
    return
  end
  self.m_tempBagGridItemPosList[tempPosIndex] = rogueDragEquipItem
end

function Form_RogueChose:RemoveEquipItemFromTempPos(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  if not self.m_tempBagGridItemPosList then
    return
  end
  for i = 1, MaxTempPosNum do
    local tempRogueDragEquipItemCom = self.m_tempBagGridItemPosList[i]
    if tempRogueDragEquipItemCom and tempRogueDragEquipItemCom == rogueDragEquipItemCom then
      self.m_tempBagGridItemPosList[i] = nil
    end
  end
end

function Form_RogueChose:GetEquipItemFromTempPosIndex(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  if not self.m_tempBagGridItemPosList then
    return
  end
  for i = 1, MaxTempPosNum do
    local tempRogueDragEquipItemCom = self.m_tempBagGridItemPosList[i]
    if tempRogueDragEquipItemCom and tempRogueDragEquipItemCom == rogueDragEquipItemCom then
      return i
    end
  end
end

function Form_RogueChose:GetCurEquipItemLvByItemGroupID(groupID)
  if not groupID then
    return
  end
  if not self.m_rogueBagGridItemList then
    return
  end
  for i, v in ipairs(self.m_rogueBagGridItemList) do
    local tempRogueEquipItemData = v.m_rogueEquipItemData
    if tempRogueEquipItemData then
      local tempRogueStageItemCfg = tempRogueEquipItemData.rogueStageItemCfg
      if tempRogueStageItemCfg and tempRogueStageItemCfg.m_ItemGroupID == groupID then
        return tempRogueStageItemCfg.m_ItemLevel or 0
      end
    end
  end
  return 0
end

function Form_RogueChose:GetRogueDragEquipItemByID(rogueItemID)
  if not rogueItemID then
    return
  end
  if not self.m_rogueBagGridItemList then
    return
  end
  if not next(self.m_rogueBagGridItemList) then
    return
  end
  for i, v in ipairs(self.m_rogueBagGridItemList) do
    if v.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID == rogueItemID then
      return v
    end
  end
end

function Form_RogueChose:GetLockGridNum()
  if not self.m_RogueGridSubPanel then
    return
  end
  return self.m_RogueGridSubPanel:GetLockGridNum()
end

function Form_RogueChose:IsInRogueShowItemList(rogueEquipItemData)
  if not rogueEquipItemData then
    return
  end
  if not self.m_showRogueEquipItemDataList then
    return
  end
  for i, v in ipairs(self.m_showRogueEquipItemDataList) do
    if v.uid == rogueEquipItemData.uid then
      return true
    end
  end
end

function Form_RogueChose:AddEventListeners()
end

function Form_RogueChose:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RogueChose:FreshUI()
  self:FreshShowEquipItemList(true)
end

function Form_RogueChose:FreshShowEquipItemList(isResetPos)
  self.m_luaRogueEquipInfinityGrid:ShowItemList(self.m_showRogueEquipItemDataList)
  if isResetPos then
    self.m_luaRogueEquipInfinityGrid:LocateTo()
  end
  self.m_txt_choosetip_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100716), self.m_isHaveChooseNum, __SimRoomBuffListMaxNum)
end

function Form_RogueChose:CheckChangeAllEquipItemListUseStatus()
  if self.m_isHaveChooseNum >= __SimRoomBuffListMaxNum then
    return
  end
  if not self.m_showRogueEquipItemDataList then
    return
  end
  if not self.m_dragEquipItem then
    return
  end
  if not self.m_startDragType then
    return
  end
  if self.m_startDragType ~= DragRectType.ItemList then
    return
  end
  self.m_dragEquipItem.m_rogueEquipItemData.isHaveChoose = true
  if self.m_isHaveChooseNum + 1 >= __SimRoomBuffListMaxNum then
    for i, v in ipairs(self.m_showRogueEquipItemDataList) do
      if v and v.isHaveChoose ~= true then
        v.isChooseFull = true
      end
    end
  end
  self.m_luaRogueEquipInfinityGrid:ReBindAll()
  self.m_isHaveChooseNum = self.m_isHaveChooseNum + 1
  self.m_txt_choosetip_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100716), self.m_isHaveChooseNum, __SimRoomBuffListMaxNum)
end

function Form_RogueChose:CreateDragEquipItem(screenPosX, screenPosY, rogueEquipItemData)
  if not rogueEquipItemData then
    return
  end
  local localPosX, localPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_equip_item_root_trans, screenPosX, screenPosY, self.m_groupCam)
  local gameObject = GameObject.Instantiate(self.m_drag_base_item, self.m_equip_item_root_trans).gameObject
  UILuaHelper.SetActive(gameObject, true)
  UILuaHelper.SetLocalScale(gameObject, 1, 1, 1)
  UILuaHelper.SetLocalPosition(gameObject, localPosX, localPosY, 0)
  local itemIndex = #self.m_showRogueEquipItemDataList + 1
  local initItemData = {
    equipItemRootTran = self.m_equip_item_root_trans,
    itemEnterDragBackFun = function(equipDragItemCom, dragPos)
      self:OnDragEquipItemEnterDrag(equipDragItemCom, dragPos)
    end,
    itemDragBackFun = function(dragPos)
      self:OnItemDrag(dragPos)
    end,
    itemDragEndBackFun = function(dragPos)
      self:OnItemEndDrag(dragPos)
    end,
    itemClkBackFun = function(equipItemData, itemTrans)
      self:OnDragEquipItemClk(equipItemData, itemTrans)
    end
  }
  local RogueDragEquipItemCom = RogueDragEquipItem.new(nil, gameObject, initItemData, rogueEquipItemData, itemIndex)
  return RogueDragEquipItemCom
end

function Form_RogueChose:EquipDragItemInGridFresh(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  self:AddEquipDragItem(rogueDragEquipItemCom)
end

function Form_RogueChose:EquipDragItemInTempPosFresh(rogueDragEquipItemCom, tempPosIndex)
  if not rogueDragEquipItemCom then
    return
  end
  if not tempPosIndex then
    return
  end
  if tempPosIndex < 0 and tempPosIndex > MaxTempPosNum then
    return
  end
  self:AddEquipItemInTemPos(rogueDragEquipItemCom, tempPosIndex)
  local posRoot = self["m_temp_pos" .. tempPosIndex]
  if posRoot then
    UILuaHelper.SetParent(rogueDragEquipItemCom.m_itemRootObj, posRoot)
    UILuaHelper.SetLocalPosition(rogueDragEquipItemCom.m_itemRootObj, 0, 0, 0)
    UILuaHelper.SetLocalScale(rogueDragEquipItemCom.m_itemRootObj, 1, 1, 1)
    self.m_tempPosDragItemList[tempPosIndex] = rogueDragEquipItemCom
  end
  rogueDragEquipItemCom:OnPutInTempPos(tempPosIndex)
  if self.m_startDragType == DragRectType.BgGrid then
    self:CheckRemoveConnectLine(rogueDragEquipItemCom)
    self:CheckFreshCombineLineInEquipGrid(rogueDragEquipItemCom)
  else
    self:CheckRemoveConnectLine(rogueDragEquipItemCom)
  end
end

function Form_RogueChose:SetPutTempPosScale(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  local rogueStageItemCfg = rogueDragEquipItemCom.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local posCfg = self.m_levelRogueStageHelper:GetRogueItemIconPosById(rogueStageItemCfg.m_ItemID)
  if posCfg then
    local posTab = utils.changeCSArrayToLuaTable(posCfg.m_SmallBagItemPos)
    if posTab and posTab[1] then
      UILuaHelper.SetLocalPosition(rogueDragEquipItemCom.m_itemRootObj, posTab[1], posTab[2], 0)
    end
    if posTab and posTab[3] then
      local scale = posTab[3] * 0.01
      UILuaHelper.SetLocalScale(rogueDragEquipItemCom.m_itemRootObj, scale, scale, 1)
    end
  end
end

function Form_RogueChose:ResetRogueDragEquipItemScaleAndPos(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  UILuaHelper.SetLocalScale(rogueDragEquipItemCom.m_itemRootObj, 1, 1, 1)
  UILuaHelper.SetLocalPosition(rogueDragEquipItemCom.m_itemRootObj, 0, 0, 0)
end

function Form_RogueChose:CombineItem(mapRogueDragEquipItem, materialRogueDragItemList)
  if not mapRogueDragEquipItem then
    return
  end
  if not self.m_RogueGridSubPanel then
    return
  end
  if not materialRogueDragItemList then
    return
  end
  self:CheckRemoveConnectLine(mapRogueDragEquipItem)
  mapRogueDragEquipItem:CombineRogueItem()
  if self:IsInRogueShowItemList(mapRogueDragEquipItem.m_rogueEquipItemData) == true then
    self.m_tempRoundCombineItemIDList[#self.m_tempRoundCombineItemIDList + 1] = mapRogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(267)
  for _, v in ipairs(materialRogueDragItemList) do
    self.m_RogueGridSubPanel:ClearBgGridEquipStatus(v)
    self:CheckRemoveConnectLine(v)
    self:PlayCombineAnim(v)
    if self:IsInRogueShowItemList(v.m_rogueEquipItemData) == true then
      self.m_tempRoundCombineItemIDList[#self.m_tempRoundCombineItemIDList + 1] = v.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
    end
  end
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(0.5)
  sequence:OnComplete(function()
    if self and self.DestroyEquipItem then
      self:DestroyEquipItem(materialRogueDragItemList)
    end
    if not utils.isNull(mapRogueDragEquipItem) then
      mapRogueDragEquipItem:PlayCombineOverAnim()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(269)
    end
    if self and self.FreshAllMapCombineLineInEquipGrid then
      self:FreshAllMapCombineLineInEquipGrid()
    end
  end)
  sequence:SetAutoKill(true)
end

function Form_RogueChose:DestroyEquipItem(materialRogueDragItemList)
  if not self.m_RogueGridSubPanel then
    return
  end
  if not materialRogueDragItemList then
    return
  end
  for _, v in ipairs(materialRogueDragItemList) do
    self:RemoveEquipItem(v)
    if v.m_itemRootObj then
      GameObject.Destroy(v.m_itemRootObj)
      v:dispose()
    end
  end
end

function Form_RogueChose:PlayCombineAnim(rogueDragEquipItemCom)
  if not rogueDragEquipItemCom then
    return
  end
  if not self.m_rogueBagGridItemList then
    return
  end
  for i, v in ipairs(self.m_rogueBagGridItemList) do
    if v == rogueDragEquipItemCom then
      rogueDragEquipItemCom:PlayCombineAnim()
    end
  end
end

function Form_RogueChose:CheckPutBack()
  if not self.m_startDragType then
    return
  end
  if self.m_startDragType == DragRectType.BgGrid then
    local bgGridIndexX, bgGridIndexY = self.m_dragEquipItem:GetPutBgGridIndexXY()
    self.m_RogueGridSubPanel:EquipDragItemInGridByIndex(self.m_dragEquipItem, bgGridIndexX, bgGridIndexY)
    self:EquipDragItemInGridFresh(self.m_dragEquipItem)
    self:CheckFreshCombineLineInEquipGrid(self.m_dragEquipItem)
    self:ClearDragData()
  elseif self.m_startDragType == DragRectType.TempPos then
    local posIndex = self.m_dragEquipItem:GetPutTempPosIndex()
    self:EquipDragItemInTempPosFresh(self.m_dragEquipItem, posIndex)
    if self:GetEquipItemFromTempPosIndex(self.m_dragEquipItem) then
      self:SetPutTempPosScale(self.m_dragEquipItem)
    end
    self:ClearDragData()
  else
    self:ClearDragData(true)
  end
end

function Form_RogueChose:CheckCreateCombineLine(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local rogueStageItemCfg = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local itemType = rogueStageItemCfg.m_ItemType
  if itemType ~= RogueStageItemType.Material then
    return
  end
  local itemSubType = rogueStageItemCfg.m_ItemSubType
  local materialItemID = rogueStageItemCfg.m_ItemID
  local connectMatIDList
  if itemSubType == RogueStageItemSubType.CommonMap or itemSubType == RogueStageItemSubType.ExclusiveMap then
    connectMatIDList = self.m_levelRogueStageHelper:GetRogueCombinationMaterialIDListByMapID(materialItemID)
  else
    connectMatIDList = self.m_levelRogueStageHelper:GetRogueCombinationMapIDListByMaterialID(materialItemID)
  end
  if not connectMatIDList then
    return
  end
  if not next(connectMatIDList) then
    return
  end
  for i, itemID in ipairs(connectMatIDList) do
    local tempRogueDragEquipItemCom = self:GetRogueDragEquipItemByID(itemID)
    if tempRogueDragEquipItemCom then
      tempRogueDragEquipItemCom:CreateLineNode(rogueDragEquipItem)
      rogueDragEquipItem:CreateLineNode(tempRogueDragEquipItemCom)
    end
  end
end

function Form_RogueChose:CheckFreshCombineLine(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local rogueStageItemCfg = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local itemType = rogueStageItemCfg.m_ItemType
  if itemType ~= RogueStageItemType.Material then
    return
  end
  local connectItemList = rogueDragEquipItem:GetAllLineRogueDragItemList()
  if connectItemList and next(connectItemList) ~= nil then
    rogueDragEquipItem:FreshAllLineShow()
    for i, v in ipairs(connectItemList) do
      v:FreshLineShowByItem(rogueDragEquipItem)
    end
  end
end

function Form_RogueChose:RemoveAllLineNodeByRogueItem(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local connectItemList = rogueDragEquipItem:GetAllLineRogueDragItemList()
  if connectItemList and next(connectItemList) ~= nil then
    for i, v in ipairs(connectItemList) do
      v:RemoveLineNodeByItem(rogueDragEquipItem)
    end
    rogueDragEquipItem:RemoveAllLineNode()
  end
end

function Form_RogueChose:CheckFreshCombineLineInEquipGrid(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local rogueStageItemCfg = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local itemType = rogueStageItemCfg.m_ItemType
  if itemType ~= RogueStageItemType.Material then
    return
  end
  self:FreshAllMapCombineLineInEquipGrid()
end

function Form_RogueChose:FreshAllMapCombineLineInEquipGrid()
  if not self.m_RogueGridSubPanel then
    return
  end
  local allRogueMapEquipItemList = self:GetMapTypeRogueEquipItemList()
  if not allRogueMapEquipItemList or not next(allRogueMapEquipItemList) then
    return
  end
  for i, tempMapRogueCom in ipairs(allRogueMapEquipItemList) do
    if tempMapRogueCom then
      self:RemoveAllLineNodeByRogueItem(tempMapRogueCom)
    end
  end
  for i, tempMapRogueCom in ipairs(allRogueMapEquipItemList) do
    if tempMapRogueCom then
      local roundMaterialItemList = self.m_RogueGridSubPanel:GetMapRoundAllCombineMaterialItemList(tempMapRogueCom)
      if roundMaterialItemList and next(roundMaterialItemList) then
        for _, roundMatItem in ipairs(roundMaterialItemList) do
          if roundMatItem then
            roundMatItem:CreateLineNode(tempMapRogueCom, true)
            tempMapRogueCom:CreateLineNode(roundMatItem, true)
          end
        end
      end
    end
  end
end

function Form_RogueChose:CheckRemoveConnectLine(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local rogueStageItemCfg = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local itemType = rogueStageItemCfg.m_ItemType
  if itemType ~= RogueStageItemType.Material then
    return
  end
  self:RemoveAllLineNodeByRogueItem(rogueDragEquipItem)
end

function Form_RogueChose:CheckFreshShowPosAndDelShow(isEnterDrag)
  UILuaHelper.SetActive(self.m_del_root, isEnterDrag)
  local isShowLock = false
  if isEnterDrag then
    local curEmptyIndex = self:GetCurTempEmptyIndex()
    if curEmptyIndex == nil then
      isShowLock = true
    end
  end
  for i = 1, MaxTempPosNum do
    if self["m_img_lock_" .. i] then
      UILuaHelper.SetActive(self["m_img_lock_" .. i], isShowLock)
    end
  end
end

function Form_RogueChose:OnItemEnterDrag(itemIndex, dragPos)
  if not itemIndex then
    return
  end
  if not dragPos then
    return
  end
  if self.m_guideFormIndex and self.m_guideFormIndex ~= itemIndex then
    return
  end
  local curEquipItemData = self.m_showRogueEquipItemDataList[itemIndex]
  if not curEquipItemData then
    return
  end
  local dragEquipItemCom = self:CreateDragEquipItem(dragPos.x, dragPos.y, curEquipItemData)
  if not dragEquipItemCom then
    return
  end
  self.m_dragEquipItem = dragEquipItemCom
  self.m_startDragScreenPos = dragPos
  self.m_startDragUIPosX, self.m_startDragUIPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_equip_item_root_trans, dragPos.x, dragPos.y, self.m_groupCam)
  self.m_startDragEquipItemLocalPosX, self.m_startDragEquipItemLocalPosY, _ = self.m_dragEquipItem:GetLocalPos()
  self.m_startDragType = DragRectType.ItemList
  dragEquipItemCom:OnEquipDrag()
  self.m_RogueGridSubPanel:FreshGridStatusByPos(dragEquipItemCom)
  self:CheckCreateCombineLine(self.m_dragEquipItem)
  self:CheckFreshShowPosAndDelShow(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(265)
end

function Form_RogueChose:OnDragEquipItemEnterDrag(equipDragItemCom, dragPos)
  if not equipDragItemCom then
    return
  end
  if not dragPos then
    return
  end
  if self.m_guideCallback then
    return
  end
  self.m_dragEquipItem = equipDragItemCom
  UILuaHelper.SetParent(self.m_dragEquipItem.m_itemRootObj, self.m_equip_item_root_trans, false, false, true)
  self:ResetRogueDragEquipItemScaleAndPos(self.m_dragEquipItem)
  UILuaHelper.SetChildIndex(self.m_dragEquipItem.m_itemRootObj, -1)
  self.m_startDragScreenPos = dragPos
  self.m_startDragUIPosX, self.m_startDragUIPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_equip_item_root_trans, dragPos.x, dragPos.y, self.m_groupCam)
  self.m_startDragEquipItemLocalPosX, self.m_startDragEquipItemLocalPosY, _ = self.m_dragEquipItem:GetLocalPos()
  self.m_dragEquipItem:SetLocalPos(self.m_startDragUIPosX, self.m_startDragUIPosY, 0)
  local isEquip = self.m_dragEquipItem:IsEquip()
  if isEquip then
    self.m_startDragType = DragRectType.BgGrid
    self.m_RogueGridSubPanel:ClearBgGridEquipStatus(equipDragItemCom)
    self:RemoveEquipItem(equipDragItemCom)
    self:CheckCreateCombineLine(equipDragItemCom)
  else
    self.m_startDragType = DragRectType.TempPos
    self:RemoveEquipItemFromTempPos(equipDragItemCom)
    self:CheckCreateCombineLine(equipDragItemCom)
  end
  equipDragItemCom:OnEquipDrag()
  self.m_RogueGridSubPanel:FreshGridStatusByPos(equipDragItemCom)
  self:CheckFreshShowPosAndDelShow(true)
end

function Form_RogueChose:OnItemDrag(dragPos)
  if not self.m_startDragType then
    return
  end
  local localUIPosX, localUIPoxY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_equip_item_root_trans, dragPos.x, dragPos.y, self.m_groupCam)
  self.m_dragEquipItem:SetLocalPos(localUIPosX, localUIPoxY, 0)
  self.m_RogueGridSubPanel:FreshGridStatusByPos(self.m_dragEquipItem)
  self:CheckFreshCombineLine(self.m_dragEquipItem)
end

function Form_RogueChose:OnItemEndDrag(dragPos)
  if not self.m_startDragType then
    return
  end
  if not self.m_RogueGridSubPanel then
    return
  end
  if not self.m_dragEquipItem then
    return
  end
  self:CheckFreshShowPosAndDelShow(false)
  local gridXNum, gridYNum = self.m_RogueGridSubPanel:GetItemPosInGrid(self.m_dragEquipItem)
  if self.m_guideGridX and self.m_guideGridY then
    local deltaNumX = math.abs(gridXNum - self.m_guideGridX)
    local deltaNumY = math.abs(gridYNum - self.m_guideGridY)
    if math.sqrt(deltaNumX * deltaNumX + deltaNumY * deltaNumY) > self.m_guide_deltaNum then
      self:CheckPutBack()
      return
    end
  end
  if self.m_guideCallback then
    if not utils.isNull(self.m_dragEquipItem) then
      self.m_dragEquipItem:PlayEquippedAnim()
    end
    local isExGridItem = self.m_dragEquipItem:IsGridExItem()
    if isExGridItem then
      self.m_RogueGridSubPanel:ExpandBgGridByIndex(self.m_dragEquipItem, self.m_guideGridX, self.m_guideGridY)
      self:CheckChangeAllEquipItemListUseStatus()
      self:ClearDragData(true)
    else
      self.m_RogueGridSubPanel:EquipDragItemInGridByIndex(self.m_dragEquipItem, self.m_guideGridX, self.m_guideGridY)
      self:EquipDragItemInGridFresh(self.m_dragEquipItem)
      self:CheckChangeAllEquipItemListUseStatus()
      local isCanCombine, mapRogueDragEquipItem, materialItemList = self:IsEquipItemCanCombine(self.m_dragEquipItem)
      if isCanCombine then
        self:ClearDragData()
        self:CombineItem(mapRogueDragEquipItem, materialItemList)
      else
        self:CheckFreshCombineLineInEquipGrid(self.m_dragEquipItem)
        self:ClearDragData()
      end
    end
    CS.GlobalManager.Instance:TriggerWwiseBGMState(266)
    self.m_guideCallback()
    self:ResetGuideData()
    return
  end
  local localUIPosX, localUIPoxY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_equip_item_root_trans, dragPos.x, dragPos.y, self.m_groupCam)
  local dragRectType = self:GetDragRectTypeByLocalPos(localUIPosX, localUIPoxY, 0)
  self.m_dragEquipItem:SetLocalPos(localUIPosX, localUIPoxY, 0)
  self.m_RogueGridSubPanel:FreshGridStatusByPos(self.m_dragEquipItem)
  if dragRectType == DragRectType.BgGrid then
    local isCanEquip = self:IsEquipItemCanEquip(self.m_dragEquipItem)
    if isCanEquip then
      local isExGridItem = self.m_dragEquipItem:IsGridExItem()
      if isExGridItem then
        self.m_RogueGridSubPanel:ExpandBgGrid(self.m_dragEquipItem)
        self:CheckChangeAllEquipItemListUseStatus()
        self:ClearDragData(true)
      else
        self:DelTempPosDragItemList()
        if not utils.isNull(self.m_dragEquipItem) then
          self.m_dragEquipItem:PlayEquippedAnim()
        end
        self.m_RogueGridSubPanel:EquipDragItemInGrid(self.m_dragEquipItem)
        self:EquipDragItemInGridFresh(self.m_dragEquipItem)
        self:CheckChangeAllEquipItemListUseStatus()
        local isCanCombine, mapRogueDragEquipItem, materialItemList = self:IsEquipItemCanCombine(self.m_dragEquipItem)
        if isCanCombine then
          self:ClearDragData()
          self:CombineItem(mapRogueDragEquipItem, materialItemList)
        else
          self:CheckFreshCombineLineInEquipGrid(self.m_dragEquipItem)
          self:ClearDragData()
        end
      end
      CS.GlobalManager.Instance:TriggerWwiseBGMState(266)
    else
      self:CheckPutBack()
    end
  elseif dragRectType == DragRectType.TempPos then
    local curEmptyIndex = self:GetCurTempEmptyIndex()
    if curEmptyIndex ~= nil then
      self:EquipDragItemInTempPosFresh(self.m_dragEquipItem, curEmptyIndex)
      self:CheckChangeAllEquipItemListUseStatus()
      self:SetPutTempPosScale(self.m_dragEquipItem)
      self:ClearDragData()
    else
      self:CheckPutBack()
    end
    CS.GlobalManager.Instance:TriggerWwiseBGMState(266)
  elseif dragRectType == DragRectType.Delete then
    utils.popUpDirectionsUI({
      tipsID = 1205,
      func1 = function()
        self:CheckChangeAllEquipItemListUseStatus()
        self:ClearDragData(true)
        self:DelTempPosDragItemList()
      end,
      func2 = function()
        self:CheckPutBack()
      end
    })
    CS.GlobalManager.Instance:TriggerWwiseBGMState(270)
  else
    self:CheckPutBack()
  end
end

function Form_RogueChose:ClearDragData(isNeedDestroy)
  if not self.m_dragEquipItem then
    return
  end
  if self.m_dragCanUpEquipItemCom then
    self.m_dragCanUpEquipItemCom:ChangeUpgradeShowStatus(false)
    self.m_dragEquipItem:ChangeUpgradeShowStatus(false)
  end
  if isNeedDestroy then
    self:CheckRemoveConnectLine(self.m_dragEquipItem)
    GameObject.Destroy(self.m_dragEquipItem.m_itemRootObj)
    self.m_dragEquipItem:dispose()
  end
  self:FreshShowEquipItemList()
  self.m_dragEquipItem = nil
  self.m_startDragType = nil
  self.m_startDragEquipItemLocalPosX = nil
  self.m_startDragEquipItemLocalPosY = nil
  self.m_startDragScreenPos = nil
end

function Form_RogueChose:OnItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local dragEquipItemData = self.m_showRogueEquipItemDataList[itemIndex]
  if not dragEquipItemData then
    return
  end
  local heroIdList = RogueStageManager:GetFightHeros()
  local itemIds = self:GetRogueEquipItemIds()
  utils.openRogueItemTips(dragEquipItemData.rogueStageItemCfg.m_ItemID, heroIdList, itemIds)
end

function Form_RogueChose:OnDragEquipItemClk(equipItemData, itemTrans)
  if not equipItemData then
    return
  end
  local heroIdList = RogueStageManager:GetFightHeros()
  local itemIds = self:GetRogueEquipItemIds()
  utils.openRogueItemTips(equipItemData.rogueStageItemCfg.m_ItemID, heroIdList, itemIds)
end

function Form_RogueChose:GetRogueEquipItemIds()
  local list = {}
  if table.getn(self.m_rogueBagGridItemList) > 0 or 0 < table.getn(self.m_tempBagGridItemPosList) then
    if self.m_rogueBagGridItemList then
      for i, v in pairs(self.m_rogueBagGridItemList) do
        if v.m_rogueEquipItemData and v.m_rogueEquipItemData.rogueStageItemCfg then
          list[#list + 1] = v.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
        end
      end
    end
    if self.m_tempBagGridItemPosList then
      for i, v in pairs(self.m_tempBagGridItemPosList) do
        if v.m_rogueEquipItemData and v.m_rogueEquipItemData.rogueStageItemCfg then
          list[#list + 1] = v.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
        end
      end
    end
  end
  return list
end

function Form_RogueChose:OnBtncontinueClicked()
  if self.m_guideCallback then
    return
  end
  local itemIDList = self:GetEquipItemIDList()
  local tempPosItemIDList = self:GetTempPosItemIDList()
  local lockGridNum = self:GetLockGridNum() or 0
  self:CloseForm()
  if BattleGlobalManager then
    BattleGlobalManager:SetRoguePropIdListData(itemIDList, tempPosItemIDList, self.m_tempRoundCombineItemIDList, lockGridNum)
  end
  if self.m_levelRogueStageHelper and self.m_rogueBagGridItemList then
    local bagData = {}
    for i, v in ipairs(self.m_rogueBagGridItemList) do
      bagData[#bagData + 1] = {
        rogueStageItemCfg = v.m_rogueEquipItemData.rogueStageItemCfg
      }
    end
    self.m_levelRogueStageHelper:SetRogueBagData(bagData)
  end
  self:ResetGuideData()
end

function Form_RogueChose:DelTempPosDragItemList()
  if table.getn(self.m_tempPosDragItemList) > 0 then
    local index = table.keyof(self.m_tempPosDragItemList, self.m_dragEquipItem)
    if index then
      self.m_tempPosDragItemList[index] = nil
    end
  end
end

function Form_RogueChose:OnTempPosBeginDrag(index, pointerEventData)
  if not pointerEventData or not index then
    return
  end
  if utils.isNull(self.m_tempPosDragItemList[index]) or utils.isNull(self.m_tempPosDragItemList[index].m_itemRootObj) then
    self.m_tempPosDragItemList[index] = nil
    return
  end
  self:OnDragEquipItemEnterDrag(self.m_tempPosDragItemList[index], pointerEventData.position)
end

function Form_RogueChose:OnTempPosDrag(index, pointerEventData)
  if not pointerEventData or not index then
    return
  end
  if utils.isNull(self.m_tempPosDragItemList[index]) or utils.isNull(self.m_tempPosDragItemList[index].m_itemRootObj) then
    self.m_tempPosDragItemList[index] = nil
    return
  end
  self:OnItemDrag(pointerEventData.position)
end

function Form_RogueChose:OnTempPosEndDrag(index, pointerEventData)
  if not pointerEventData or not index then
    return
  end
  if utils.isNull(self.m_tempPosDragItemList[index]) or utils.isNull(self.m_tempPosDragItemList[index].m_itemRootObj) then
    self.m_tempPosDragItemList[index] = nil
    return
  end
  self:OnItemEndDrag(pointerEventData.position)
end

function Form_RogueChose:OnTempPosClk(index)
  if utils.isNull(self.m_tempPosDragItemList[index]) or utils.isNull(self.m_tempPosDragItemList[index].m_itemRootObj) then
    self.m_tempPosDragItemList[index] = nil
    return
  end
  if self.m_tempPosDragItemList[index].m_rogueEquipItemData and self.m_tempPosDragItemList[index].m_itemRootObj then
    self:OnDragEquipItemClk(self.m_tempPosDragItemList[index].m_rogueEquipItemData, self.m_tempPosDragItemList[index].m_itemRootObj.transform)
  end
end

function Form_RogueChose:OnTempPosBeginDrag1(pointerEventData)
  self:OnTempPosBeginDrag(1, pointerEventData)
end

function Form_RogueChose:OnTempPosDrag1(pointerEventData)
  self:OnTempPosDrag(1, pointerEventData)
end

function Form_RogueChose:OnTempPosEndDrag1(pointerEventData)
  self:OnTempPosEndDrag(1, pointerEventData)
end

function Form_RogueChose:OnTempPosClk1()
  self:OnTempPosClk(1)
end

function Form_RogueChose:OnTempPosBeginDrag2(pointerEventData)
  self:OnTempPosBeginDrag(2, pointerEventData)
end

function Form_RogueChose:OnTempPosDrag2(pointerEventData)
  self:OnTempPosDrag(2, pointerEventData)
end

function Form_RogueChose:OnTempPosEndDrag2(pointerEventData)
  self:OnTempPosEndDrag(2, pointerEventData)
end

function Form_RogueChose:OnTempPosClk2()
  self:OnTempPosClk(2)
end

function Form_RogueChose:OnTempPosBeginDrag3(pointerEventData)
  self:OnTempPosBeginDrag(3, pointerEventData)
end

function Form_RogueChose:OnTempPosDrag3(pointerEventData)
  self:OnTempPosDrag(3, pointerEventData)
end

function Form_RogueChose:OnTempPosEndDrag3(pointerEventData)
  self:OnTempPosEndDrag(3, pointerEventData)
end

function Form_RogueChose:OnTempPosClk3()
  self:OnTempPosClk(3)
end

function Form_RogueChose:OnTempPosBeginDrag4(pointerEventData)
  self:OnTempPosBeginDrag(4, pointerEventData)
end

function Form_RogueChose:OnTempPosDrag4(pointerEventData)
  self:OnTempPosDrag(4, pointerEventData)
end

function Form_RogueChose:OnTempPosEndDrag4(pointerEventData)
  self:OnTempPosEndDrag(4, pointerEventData)
end

function Form_RogueChose:OnTempPosClk4()
  self:OnTempPosClk(4)
end

function Form_RogueChose:OnTempPosBeginDrag5(pointerEventData)
  self:OnTempPosBeginDrag(5, pointerEventData)
end

function Form_RogueChose:OnTempPosDrag5(pointerEventData)
  self:OnTempPosDrag(5, pointerEventData)
end

function Form_RogueChose:OnTempPosEndDrag5(pointerEventData)
  self:OnTempPosEndDrag(5, pointerEventData)
end

function Form_RogueChose:OnTempPosClk5()
  self:OnTempPosClk(5)
end

function Form_RogueChose:GuideTimetowerchoose(fromIdx, toGridX, toGridY, callback, deltaNum)
  if callback then
    self.m_guideFormIndex = fromIdx
    self.m_guideGridX = toGridX
    self.m_guideGridY = toGridY
    self.m_guide_deltaNum = deltaNum or 1
    self.m_guideCallback = callback
  end
end

function Form_RogueChose:GetGuideConditionIsOpen(conditionType, conditionParam)
  local ret = false
  if self.GuideRecordActiveCount == tonumber(conditionParam) then
    ret = true
  end
  return ret
end

function Form_RogueChose:ResetGuideData()
  self.m_guideFormIndex = nil
  self.m_guideGridX = nil
  self.m_guideGridY = nil
  self.m_guideCallback = nil
end

ActiveLuaUI("Form_RogueChose", Form_RogueChose)
return Form_RogueChose
