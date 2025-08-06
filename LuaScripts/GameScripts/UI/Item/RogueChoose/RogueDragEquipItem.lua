local UIItemBase = require("UI/Common/UIItemBase")
local RogueDragEquipItem = class("RogueDragEquipItem", UIItemBase)
local RogueBagGridItem = require("UI/Item/RogueChoose/RogueBagGridItem")
local DragRectType = RogueStageManager.DragRectType
local LimitDragDis = 0.1
local GridSizeX = 108
local HalfGridSizeX = GridSizeX / 2
local GridSizeY = 98
local HalfGridSizeY = GridSizeY / 2
local BorderWidth = 3
local BorderHeight = 4
local __RogueChose_iconloop = "RogueChose_iconloop"

function RogueDragEquipItem:OnInit()
  self.m_putDragRectType = DragRectType.Other
  self.m_isInDrag = false
  self.m_putBgGridX = nil
  self.m_putBgGridY = nil
  self.m_putTempPosIndex = nil
  self.m_pnl_grid_trans = self.m_pnl_grid.transform
  if self.m_itemInitData then
    self.m_equipItemRootTran = self.m_itemInitData.equipItemRootTran
    self.m_itemEnterDragBackFun = self.m_itemInitData.itemEnterDragBackFun
    self.m_itemDragBackFun = self.m_itemInitData.itemDragBackFun
    self.m_itemDragEndBackFun = self.m_itemInitData.itemDragEndBackFun
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_equip_drag_node_Btn_Ex = self.m_equip_drag_node:GetComponent("ButtonExtensions")
  if self.m_equip_drag_node_Btn_Ex then
    self.m_equip_drag_node_Btn_Ex.BeginDrag = handler(self, self.OnDragNodeStartDrag)
    self.m_equip_drag_node_Btn_Ex.Drag = handler(self, self.OnDragNodeDrag)
    self.m_equip_drag_node_Btn_Ex.EndDrag = handler(self, self.OnDragNodeEndDrag)
    self.m_equip_drag_node_Btn_Ex.Clicked = handler(self, self.OnItemClk)
  end
  self.m_rogueEquipItemData = nil
  self.m_GridList = {}
  self.m_GridXNum = nil
  self.m_GridYNum = nil
  self.m_bagGridItemList = {}
  self.m_leftMinPosX = nil
  self.m_leftMinPosY = nil
  self.m_curEquipLevel = nil
  self.m_equipMaxLevel = nil
  self.m_groupEquipCfgList = nil
  self.m_lineRootTrans = self.m_line_root.transform
  self.m_lineRogueDragItemList = {}
  self.m_lineNodeList = {}
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
end

function RogueDragEquipItem:OnFreshData()
  self.m_rogueEquipItemData = self.m_itemData
  self:InitEquipBaseInfo()
  self:InitFreshGridList()
  self:FreshIconShow()
end

function RogueDragEquipItem:OnDestroy()
  RogueDragEquipItem.super.OnDestroy(self)
  for _, tempList in pairs(self.m_bagGridItemList) do
    if tempList then
      for _, tempItem in pairs(tempList) do
        tempItem:dispose()
      end
    end
  end
end

function RogueDragEquipItem:InitEquipBaseInfo()
  if not self.m_rogueEquipItemData then
    return
  end
  self.m_curEquipLevel = self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemLevel
  local equipGroupList = self.m_levelRogueStageHelper:GetRogueItemGroupListByGroupID(self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemGroupID)
  if not equipGroupList then
    return
  end
  self.m_groupEquipCfgList = equipGroupList
  self.m_equipMaxLevel = #equipGroupList
end

function RogueDragEquipItem:GetLeftMinPos()
  if not self.m_GridXNum then
    return
  end
  if not self.m_GridYNum then
    return
  end
  local leftMinPosX = self.m_leftMinPosX
  if leftMinPosX == nil then
    local halfGridXNum = math.floor(self.m_GridXNum / 2)
    local halfGridLeftXNum = self.m_GridXNum % 2
    leftMinPosX = -(halfGridXNum * GridSizeX)
    if 0 < halfGridLeftXNum then
      leftMinPosX = leftMinPosX - HalfGridSizeX
    end
    self.m_leftMinPosX = leftMinPosX
  end
  local leftMinPosY = self.m_leftMinPosY
  if leftMinPosY == nil then
    local halfGridYNum = math.floor(self.m_GridYNum / 2)
    local halfGridLeftYNum = self.m_GridYNum % 2
    leftMinPosY = -(halfGridYNum * GridSizeY)
    if 0 < halfGridLeftYNum then
      leftMinPosY = leftMinPosY - HalfGridSizeY
    end
    self.m_leftMinPosY = leftMinPosY
  end
  return self.m_leftMinPosX, self.m_leftMinPosY
end

function RogueDragEquipItem:GetGirdPosByGridIndex(gridIndexX, gridIndexY)
  if not gridIndexX then
    return
  end
  if not gridIndexY then
    return
  end
  local minLeftPosX, minLeftPosY = self:GetLeftMinPos()
  local gridCenterPosX = gridIndexX * GridSizeX - HalfGridSizeX + minLeftPosX
  local gridCenterPosY = gridIndexY * GridSizeY - HalfGridSizeY + minLeftPosY
  return gridCenterPosX, gridCenterPosY
end

function RogueDragEquipItem:InitFreshGridList()
  if not self.m_rogueEquipItemData then
    return
  end
  local rogueStageItemCfg = self.m_rogueEquipItemData.rogueStageItemCfg
  if not rogueStageItemCfg then
    return
  end
  local gridArray = rogueStageItemCfg.m_ItemVolume
  if gridArray.Length <= 0 then
    return
  end
  local gridArrayTab = utils.changeCSArrayToLuaTable(gridArray)
  local gridY = #gridArrayTab
  local gridX = #gridArrayTab[1]
  self.m_GridXNum = gridX
  self.m_GridYNum = gridY
  local curItemIndex = 0
  for i = 1, gridX do
    if self.m_GridList[i] == nil then
      self.m_GridList[i] = {}
    end
    if self.m_bagGridItemList[i] == nil then
      self.m_bagGridItemList[i] = {}
    end
    for j = 1, gridY do
      local statusNum = gridArrayTab[j][i]
      self.m_GridList[i][j] = statusNum
      if statusNum == 1 then
        curItemIndex = curItemIndex + 1
        local posX, posY = self:GetGirdPosByGridIndex(i, j)
        local itemData = {
          rogueDragEquipItemCom = self,
          gridX = i,
          gridY = j
        }
        local gridItemCom = self:CreateGridItem(curItemIndex, itemData, posX, posY)
        self.m_bagGridItemList[i][j] = gridItemCom
      end
    end
  end
end

function RogueDragEquipItem:CreateGridItem(itemIndex, itemData, localPosX, localPosY)
  local gameObject = GameObject.Instantiate(self.m_rogue_bag_base_item, self.m_pnl_grid_trans).gameObject
  UILuaHelper.SetActive(gameObject, true)
  UILuaHelper.SetLocalPosition(gameObject, localPosX, localPosY, 0)
  local initItemData = {
    itemEnterDragBackFun = function(equipDragItemCom, dragPos)
      if self.m_itemEnterDragBackFun then
        self.m_itemEnterDragBackFun(equipDragItemCom, dragPos)
      end
    end,
    itemDragBackFun = function(dragPos)
      if self.m_itemDragBackFun then
        self.m_itemDragBackFun(dragPos)
      end
    end,
    itemDragEndBackFun = function(dragPos)
      if self.m_itemDragEndBackFun then
        self.m_itemDragEndBackFun(dragPos)
      end
    end,
    itemClkBackFun = function()
      self:OnItemClk()
    end
  }
  local rogueBagGridItemCom = RogueBagGridItem.new(nil, gameObject, initItemData, itemData, itemIndex)
  return rogueBagGridItemCom
end

function RogueDragEquipItem:FreshIconShow()
  if not self.m_rogueEquipItemData then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_Image, self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemIcon)
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_icon_Image, self.m_GridXNum * GridSizeX + BorderWidth, self.m_GridYNum * GridSizeY + BorderHeight)
  UILuaHelper.SetLocalPosition(self.m_icon, 0, 0, 0)
  local maskIcon = self.m_rogueEquipItemData.rogueStageItemCfg.m_MaskIcon
  if maskIcon and maskIcon ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_dust_Image, maskIcon)
    UILuaHelper.SetSizeWithCurrentAnchors(self.m_icon_dust_Image, self.m_GridXNum * GridSizeX + BorderWidth, self.m_GridYNum * GridSizeY + BorderHeight)
    UILuaHelper.SetLocalPosition(self.m_icon_dust_Image, 0, 0, 0)
    UILuaHelper.SetAtlasSprite(self.m_icon_black_Image, self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemIcon)
    UILuaHelper.SetSizeWithCurrentAnchors(self.m_icon_black_Image, self.m_GridXNum * GridSizeX + BorderWidth, self.m_GridYNum * GridSizeY + BorderHeight)
    UILuaHelper.SetLocalPosition(self.m_icon_black_Image, 0, 0, 0)
  end
  UILuaHelper.SetActive(self.m_icon_dust, maskIcon and maskIcon ~= "")
  UILuaHelper.SetActive(self.m_icon_black, maskIcon and maskIcon ~= "")
end

function RogueDragEquipItem:FreshGridLocalPos(deltaPosX, deltaPosY)
  if not self.m_rogueEquipItemData then
    return
  end
  UILuaHelper.SetLocalPosition(self.m_pnl_grid, deltaPosX, deltaPosY, 0)
end

function RogueDragEquipItem:ChangeDragNodeShow(isShow)
  UILuaHelper.SetActive(self.m_equip_drag_node, isShow)
end

function RogueDragEquipItem:FreshAllGridQuality()
  if not self.m_rogueEquipItemData then
    return
  end
  if not self.m_bagGridItemList then
    return
  end
  for i = 1, self.m_GridXNum do
    for j = 1, self.m_GridYNum do
      local tempBagGridItemCom = self.m_bagGridItemList[i][j]
      if tempBagGridItemCom then
        tempBagGridItemCom:FreshGridQuality()
      end
    end
  end
end

function RogueDragEquipItem:CheckGetLineNode(rogueDragEquipItem)
  local currentFollowNum = #self.m_lineRogueDragItemList
  local curLineNodeNum = #self.m_lineNodeList
  local lineNode
  if currentFollowNum < curLineNodeNum then
    lineNode = self.m_lineNodeList[currentFollowNum + 1]
    lineNode.followRogueItem = rogueDragEquipItem
    self.m_lineRogueDragItemList[#self.m_lineRogueDragItemList + 1] = rogueDragEquipItem
  else
    local lineNodeObj = GameObject.Instantiate(self.m_line_base, self.m_lineRootTrans)
    local lineNodeTab = {
      lineTrans = lineNodeObj.transform,
      followRogueItem = rogueDragEquipItem
    }
    self.m_lineNodeList[#self.m_lineNodeList + 1] = lineNodeTab
    self.m_lineRogueDragItemList[#self.m_lineRogueDragItemList + 1] = rogueDragEquipItem
    lineNode = lineNodeTab
  end
  local colorChange = lineNode.lineTrans:GetComponent("MultiColorChange")
  if colorChange then
    colorChange:SetColorByIndex(0)
  end
  return lineNode
end

function RogueDragEquipItem:FreshLineShow(lineNode, showSpecialLine)
  if not lineNode then
    return
  end
  if not lineNode.lineTrans then
    return
  end
  if utils.isNull(lineNode.lineTrans) then
    return
  end
  local followRogueItem = lineNode.followRogueItem
  if not followRogueItem then
    return
  end
  local startPosX, startPosY, startPosZ = UILuaHelper.GetPosition(self.m_lineRootTrans)
  local localStartX, localStartY, _ = UILuaHelper.WorldPosToTransformLocalPos(self.m_equipItemRootTran, startPosX, startPosY, startPosZ)
  local endPosX, endPosY, endPosZ = UILuaHelper.GetPosition(followRogueItem.m_itemRootObj)
  local localEndX, localEndY, _ = UILuaHelper.WorldPosToTransformLocalPos(self.m_equipItemRootTran, endPosX, endPosY, endPosZ)
  local directionX = localEndX - localStartX
  local directionY = localEndY - localStartY
  local directionZ = 0
  UILuaHelper.SetRotationByDirection(lineNode.lineTrans, directionX, directionY, directionZ)
  local lineLen = math.sqrt(directionX * directionX + directionY * directionY) / 2
  UILuaHelper.SetSizeWithCurrentAnchors(lineNode.lineTrans, lineLen, -1)
  UILuaHelper.SetActive(lineNode.lineTrans, true)
  local colorChange = lineNode.lineTrans:GetComponent("MultiColorChange")
  if colorChange then
    colorChange:SetColorByIndex(showSpecialLine and 1 or 0)
  end
end

function RogueDragEquipItem:GetItemIndexByRogueItem(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  if not next(self.m_lineRogueDragItemList) then
    return
  end
  local itemIndex
  for i, v in ipairs(self.m_lineRogueDragItemList) do
    if v == rogueDragEquipItem then
      itemIndex = i
      return itemIndex
    end
  end
  return itemIndex
end

function RogueDragEquipItem:GetItemIndexOfLineNodeList(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  if not next(self.m_lineNodeList) then
    return
  end
  local itemIndex
  for i, v in ipairs(self.m_lineNodeList) do
    if v.followRogueItem == rogueDragEquipItem then
      itemIndex = i
      return itemIndex
    end
  end
  return itemIndex
end

function RogueDragEquipItem:OnEquipDrag()
  self.m_putDragRectType = DragRectType.Other
  self:SetIsInDrag(true)
  self:ChangeAllGridIsPutStatus(false)
end

function RogueDragEquipItem:SetIsInDrag(isInDrag)
  self.m_isInDrag = isInDrag
end

function RogueDragEquipItem:GetBgGridItemList()
  return self.m_bagGridItemList
end

function RogueDragEquipItem:ChangeAllGridIsPutStatus(isPut)
  if not self.m_bagGridItemList then
  end
  for i = 1, self.m_GridXNum do
    for j = 1, self.m_GridYNum do
      local tempBagGridItemCom = self.m_bagGridItemList[i][j]
      if tempBagGridItemCom then
        tempBagGridItemCom:ChangePutDownStatus(isPut)
      end
    end
  end
end

function RogueDragEquipItem:ChangeGridStatus(isUnlock)
  self.m_isUnlock = isUnlock
  self:FreshGridStatus()
end

function RogueDragEquipItem:IsEquip()
  return self.m_putDragRectType == DragRectType.BgGrid
end

function RogueDragEquipItem:GetLocalPos()
  if not self.m_itemRootObj then
    return
  end
  return UILuaHelper.GetLocalPosition(self.m_itemRootObj)
end

function RogueDragEquipItem:GetGridNumXY()
  return self.m_GridXNum, self.m_GridYNum
end

function RogueDragEquipItem:SetLocalPos(x, y, z)
  if not self.m_itemRootObj then
    return
  end
  UILuaHelper.SetLocalPosition(self.m_itemRootObj, x, y, z)
end

function RogueDragEquipItem:CombineRogueItem()
  if not self.m_rogueEquipItemData then
    return
  end
  if self.m_levelRogueStageHelper:IsRogueMapMaterialByItemCfg(self.m_rogueEquipItemData.rogueStageItemCfg) ~= true then
    return
  end
  local rogueCombineCfg = self.m_levelRogueStageHelper:GetRogueCombinationCfgByMapID(self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID)
  if not rogueCombineCfg then
    return
  end
  local productID = rogueCombineCfg.m_RougeItemID
  local productRogueItemCfg = self.m_levelRogueStageHelper:GetRogueItemCfgByID(productID)
  if not productRogueItemCfg then
    return
  end
  self.m_rogueEquipItemData.rogueStageItemCfg = productRogueItemCfg
  self:InitEquipBaseInfo()
  self:FreshIconShow()
  self:FreshAllGridQuality()
end

function RogueDragEquipItem:GetRogueEquipLevel()
  if not self.m_rogueEquipItemData then
    return
  end
  return self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemLevel
end

function RogueDragEquipItem:FreshBagGridStatusByStatusArray(statusArray)
  if not statusArray then
    return
  end
  if not self.m_bagGridItemList then
  end
  for i = 1, self.m_GridXNum do
    for j = 1, self.m_GridYNum do
      if statusArray[i] ~= nil and statusArray[i][j] ~= nil then
        local isCanPut = statusArray[i][j] == 1
        local tempBagGridItemCom = self.m_bagGridItemList[i][j]
        if tempBagGridItemCom then
          tempBagGridItemCom:ChangeCanPutStatus(isCanPut)
        end
      end
    end
  end
end

function RogueDragEquipItem:FreshBagGridCenterLocalPos(localGridCenterPosX, localGridCenterPosY)
  local curPosX, curPosY = self:GetLocalPos()
  local deltaPosX = localGridCenterPosX - curPosX
  local deltaPosY = localGridCenterPosY - curPosY
  self:FreshGridLocalPos(deltaPosX, deltaPosY)
end

function RogueDragEquipItem:IsEquipItemCanEquip(statusArray)
  if not statusArray then
    return
  end
  if not self.m_bagGridItemList then
  end
  local isCanPut = true
  for i = 1, self.m_GridXNum do
    for j = 1, self.m_GridYNum do
      if statusArray[i] ~= nil and statusArray[i][j] ~= nil then
        local isGridCanPut = statusArray[i][j] == 1
        local tempBagGridItemCom = self.m_bagGridItemList[i][j]
        if tempBagGridItemCom and isGridCanPut ~= true then
          isCanPut = false
          return isCanPut
        end
      end
    end
  end
  return isCanPut
end

function RogueDragEquipItem:OnEquipInGrid(bgGridIndexX, bgGridIndexY)
  self:SetIsInDrag(false)
  self.m_putDragRectType = DragRectType.BgGrid
  self.m_putBgGridX = bgGridIndexX
  self.m_putBgGridY = bgGridIndexY
  self.m_putTempPosIndex = nil
  self:ChangeAllGridIsPutStatus(true)
  self:ChangeDragNodeShow(false)
end

function RogueDragEquipItem:OnPutInTempPos(tempPosIndex)
  self.m_putDragRectType = DragRectType.TempPos
  self.m_isInDrag = false
  self.m_putTempPosIndex = tempPosIndex
  self.m_putBgGridX = nil
  self.m_putBgGridY = nil
  self:ChangeAllGridIsPutStatus(true)
  self:ChangeDragNodeShow(true)
  self:FreshGridLocalPos(0, 0)
end

function RogueDragEquipItem:GetPutBgGridIndexXY()
  return self.m_putBgGridX, self.m_putBgGridY
end

function RogueDragEquipItem:GetPutTempPosIndex()
  return self.m_putTempPosIndex
end

function RogueDragEquipItem:IsGridExItem()
  if not self.m_rogueEquipItemData then
    return
  end
  return self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemType == RogueStageManager.RogueStageItemType.BgGridExpand
end

function RogueDragEquipItem:ChangeUpgradeShowStatus(isShow)
  if not self.m_rogueEquipItemData then
    return
  end
  if not self.m_bagGridItemList then
    return
  end
  for i = 1, self.m_GridXNum do
    for j = 1, self.m_GridYNum do
      local tempBagGridItemCom = self.m_bagGridItemList[i][j]
      if tempBagGridItemCom then
        tempBagGridItemCom:ChangeShowUpStatus(isShow)
      end
    end
  end
end

function RogueDragEquipItem:CreateLineNode(rogueDragEquipItem, showSpecialLine)
  if not rogueDragEquipItem then
    return
  end
  local itemIndex = self:GetItemIndexByRogueItem(rogueDragEquipItem)
  if itemIndex == nil or itemIndex == 0 then
    local lineNode = self:CheckGetLineNode(rogueDragEquipItem)
    self:FreshLineShow(lineNode, showSpecialLine)
  end
end

function RogueDragEquipItem:RemoveLineNodeByItem(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local itemIndex = self:GetItemIndexByRogueItem(rogueDragEquipItem)
  local nodeIndex = self:GetItemIndexOfLineNodeList(rogueDragEquipItem)
  if not itemIndex or not nodeIndex then
    return
  end
  local lineNode = self.m_lineNodeList[nodeIndex]
  if not lineNode then
    return
  end
  if lineNode then
    lineNode.followRogueItem = nil
  end
  table.remove(self.m_lineRogueDragItemList, itemIndex)
  UILuaHelper.SetActive(lineNode.lineTrans, false)
end

function RogueDragEquipItem:FreshLineShowByItem(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local itemIndex = self:GetItemIndexByRogueItem(rogueDragEquipItem)
  if not itemIndex then
    return
  end
  local lineNode = self.m_lineNodeList[itemIndex]
  if lineNode and lineNode.followRogueItem then
    self:FreshLineShow(lineNode)
  end
end

function RogueDragEquipItem:RemoveAllLineNode()
  if not self.m_lineRogueDragItemList then
    return
  end
  for i, v in ipairs(self.m_lineRogueDragItemList) do
    local tempLineNode = self.m_lineNodeList[i]
    if tempLineNode and tempLineNode.followRogueItem then
      tempLineNode.followRogueItem = nil
    end
  end
  UILuaHelper.SetActiveChildren(self.m_lineRootTrans, false)
  self.m_lineRogueDragItemList = {}
end

function RogueDragEquipItem:GetAllLineRogueDragItemList()
  if not self.m_lineRogueDragItemList then
    return
  end
  return self.m_lineRogueDragItemList
end

function RogueDragEquipItem:FreshAllLineShow()
  if not self.m_lineNodeList then
    return
  end
  if not next(self.m_lineNodeList) then
    return
  end
  for i, v in ipairs(self.m_lineNodeList) do
    if v then
      self:FreshLineShow(v)
    end
  end
end

function RogueDragEquipItem:PlayCombineAnim()
  UILuaHelper.PlayAnimationByName(self.m_icon, __RogueChose_iconloop)
end

function RogueDragEquipItem:PlayCombineOverAnim()
  UILuaHelper.SetActive(self.m_vx_get, false)
  UILuaHelper.SetActive(self.m_vx_get, true)
  UILuaHelper.SetAtlasSprite(self.m_icon2_Image, self.m_rogueEquipItemData.rogueStageItemCfg.m_ItemIcon)
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_icon2_Image, self.m_GridXNum * GridSizeX + BorderWidth, self.m_GridYNum * GridSizeY + BorderHeight)
  UILuaHelper.SetLocalPosition(self.m_icon2, 0, 0, 0)
end

function RogueDragEquipItem:PlayEquippedAnim()
  UILuaHelper.SetActive(self.m_vx_in, false)
  UILuaHelper.SetActive(self.m_vx_in, true)
end

function RogueDragEquipItem:OnDragNodeStartDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function RogueDragEquipItem:OnDragNodeDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local dragPos = pointerEventData.position
  if self.m_isDrag then
    if self.m_itemDragBackFun then
      self.m_itemDragBackFun(dragPos)
    end
  else
    local deltaNumX = dragPos.x - self.m_startDragPos.x
    local deltaNumY = dragPos.y - self.m_startDragPos.y
    local dragDis = deltaNumX * deltaNumX + deltaNumY * deltaNumY
    if dragDis > LimitDragDis then
      if self.m_itemEnterDragBackFun then
        self.m_itemEnterDragBackFun(self, dragPos)
      end
      self.m_isDrag = true
    end
  end
end

function RogueDragEquipItem:OnDragNodeEndDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_itemDragEndBackFun then
    self.m_itemDragEndBackFun(pointerEventData.position)
  end
  self.m_startDragPos = nil
  self.m_isDrag = nil
end

function RogueDragEquipItem:OnItemClk()
  if not self.m_rogueEquipItemData then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_rogueEquipItemData, self.m_itemRootObj.transform)
  end
end

return RogueDragEquipItem
