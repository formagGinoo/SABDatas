local UISubPanelBase = require("UI/Common/UISubPanelBase")
local RogueGridSubPanel = class("RogueGridSubPanel", UISubPanelBase)
local RogueBgGridItem = require("UI/Item/RogueChoose/RogueBgGridItem")
local GridSizeX = 106
local HalfGridSizeX = math.floor(GridSizeX / 2)
local GridSizeY = 106
local HalfGridSizeY = math.floor(GridSizeY / 2)

function RogueGridSubPanel:OnInit()
  self:AddEventListeners()
  self.m_rootTran = self.m_rootObj.transform
  self.MaxGridX = self.m_initData.maxGridX
  self.MaxGridY = self.m_initData.maxGridY
  self.m_leftMinPosX = nil
  self.m_leftMinPosY = nil
  self.m_allGridList = {}
  self:InitCreateGridList(self.m_initData.initGridX, self.m_initData.initGridY)
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_curDragItemGridIndex = {0, 0}
end

function RogueGridSubPanel:AddEventListeners()
end

function RogueGridSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function RogueGridSubPanel:OnFreshData()
end

function RogueGridSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  RogueGridSubPanel.super.OnDestroy(self)
end

function RogueGridSubPanel:GetLeftMinPos()
  if not self.MaxGridX then
    return
  end
  if not self.MaxGridY then
    return
  end
  local leftMinPosX = self.m_leftMinPosX
  if leftMinPosX == nil then
    local halfGridXNum = math.floor(self.MaxGridX / 2)
    local halfGridLeftXNum = self.MaxGridX % 2
    leftMinPosX = -(halfGridXNum * GridSizeX)
    if 0 < halfGridLeftXNum then
      leftMinPosX = leftMinPosX - HalfGridSizeX
    end
    self.m_leftMinPosX = leftMinPosX
  end
  local leftMinPosY = self.m_leftMinPosY
  if leftMinPosY == nil then
    local halfGridYNum = math.floor(self.MaxGridY / 2)
    local halfGridLeftYNum = self.MaxGridY % 2
    leftMinPosY = -(halfGridYNum * GridSizeY)
    if 0 < halfGridLeftYNum then
      leftMinPosY = leftMinPosY - HalfGridSizeY
    end
    self.m_leftMinPosY = leftMinPosY
  end
  return self.m_leftMinPosX, self.m_leftMinPosY
end

function RogueGridSubPanel:GetGirdPosByGridIndex(gridIndexX, gridIndexY)
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

function RogueGridSubPanel:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridSizeX, gridSizeY)
  localPosX = math.floor(localPosX)
  localPosY = math.floor(localPosY)
  local gridSizeXLen = gridSizeX * GridSizeX
  local halfGridSizeXLen = math.floor(gridSizeXLen / 2)
  local gridSizeYLen = gridSizeY * GridSizeY
  local halfGridSizeYLen = math.floor(gridSizeYLen / 2)
  local maxGridXLen = self.MaxGridX * GridSizeX
  local halfMaxGridXLen = math.floor(maxGridXLen / 2)
  local maxGridYLen = self.MaxGridY * GridSizeY
  local halfMaxGridYLen = math.floor(maxGridYLen / 2)
  local leftZeroPosX = localPosX - halfGridSizeXLen + halfMaxGridXLen
  local isMinusX = leftZeroPosX < 0
  local absPosX = math.abs(leftZeroPosX)
  local leftInGridIndexX = math.floor(absPosX / GridSizeX) + 1
  local leftInGridResX = absPosX % GridSizeX
  if leftInGridResX > HalfGridSizeX then
    leftInGridIndexX = leftInGridIndexX + 1
  end
  if isMinusX then
    leftInGridIndexX = -leftInGridIndexX + 1
  end
  if leftInGridIndexX == 0 then
    leftInGridIndexX = leftInGridIndexX + 1
  end
  local leftZeroPosY = localPosY - halfGridSizeYLen + halfMaxGridYLen
  local isMinusY = leftZeroPosY < 0
  local absPosY = math.abs(leftZeroPosY)
  local leftInGridIndexY = math.floor(absPosY / GridSizeY) + 1
  local leftInGridResY = absPosY % GridSizeY
  if leftInGridResY > HalfGridSizeY then
    leftInGridIndexY = leftInGridIndexY + 1
  end
  if isMinusY then
    leftInGridIndexY = -leftInGridIndexY + 1
  end
  if leftInGridIndexY == 0 then
    leftInGridIndexY = leftInGridIndexY + 1
  end
  return leftInGridIndexX, leftInGridIndexY
end

function RogueGridSubPanel:GetGridCanPutStatusList(gridIndexX, gridIndexY, gridXNum, gridYNum, isGridExEquip)
  if not gridIndexX then
    return
  end
  if not gridIndexY then
    return
  end
  if not gridXNum then
    return
  end
  if not gridYNum then
    return
  end
  local gridStatus = {}
  for i = 1, gridXNum do
    if gridStatus[i] == nil then
      gridStatus[i] = {}
    end
    for j = 1, gridYNum do
      local tempGridIndexX = gridIndexX + i - 1
      local tempGridIndexY = gridIndexY + j - 1
      local status = 0
      if tempGridIndexX <= 0 or tempGridIndexX > self.MaxGridX or tempGridIndexY <= 0 or tempGridIndexY > self.MaxGridY then
        status = 0
      else
        local xGridList = self.m_allGridList[tempGridIndexX]
        local rogueBgGridItemCom = xGridList[tempGridIndexY]
        if rogueBgGridItemCom then
          local isBgGridIsUnlock = rogueBgGridItemCom:IsUnLock()
          if isGridExEquip then
            if isBgGridIsUnlock ~= true then
              status = 1
            else
              status = 0
            end
          else
            local isEquip = rogueBgGridItemCom:IsEquip()
            if isBgGridIsUnlock == true and isEquip ~= true then
              status = 1
            else
              status = 0
            end
          end
        else
          status = 0
        end
      end
      gridStatus[i][j] = status
    end
  end
  return gridStatus
end

function RogueGridSubPanel:GetDragGridCenterLocalGridPos(leftGridIndexX, leftGridIndexY, gridXNum, gridYNum)
  if leftGridIndexX == 0 then
    log.info("GetDragGridCenterLocalGridPos leftGridIndexX=====0")
    return
  end
  if leftGridIndexY == 0 then
    log.info("GetDragGridCenterLocalGridPos leftGridIndexY======0")
    return
  end
  local maxGridXLen = self.MaxGridX * GridSizeX
  local halfMaxGridXLen = math.floor(maxGridXLen / 2)
  local maxGridYLen = self.MaxGridY * GridSizeY
  local halfMaxGridYLen = math.floor(maxGridYLen / 2)
  local gridSizeXLen = gridXNum * GridSizeX
  local halfGridSizeXLen = math.floor(gridSizeXLen / 2)
  local gridSizeYLen = gridYNum * GridSizeY
  local halfGridSizeYLen = math.floor(gridSizeYLen / 2)
  local leftLocalPosX = 0
  if 0 < leftGridIndexX then
    leftLocalPosX = (leftGridIndexX - 1) * GridSizeX - halfMaxGridXLen
  else
    leftLocalPosX = leftGridIndexX * GridSizeX - halfMaxGridXLen
  end
  local leftLocalPosY = 0
  if 0 < leftGridIndexY then
    leftLocalPosY = (leftGridIndexY - 1) * GridSizeY - halfMaxGridYLen
  else
    leftLocalPosY = leftGridIndexY * GridSizeY - halfMaxGridYLen
  end
  local centerLocalPosX = leftLocalPosX + halfGridSizeXLen
  local centerLocalPosY = leftLocalPosY + halfGridSizeYLen
  return centerLocalPosX, centerLocalPosY
end

function RogueGridSubPanel:GetRogueEquipItemRoundMaterialIDDic(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local equipGridItemList = rogueDragEquipItem:GetBgGridItemList()
  local leftInGridIndexX, leftInGridIndexY = rogueDragEquipItem:GetPutBgGridIndexXY()
  local roundMaterialItemIDDic = {}
  local roundMaterialItemDic = {}
  for i = 1, gridXNum do
    local tempBgGridIndexX = leftInGridIndexX + i - 1
    for j = 1, gridYNum do
      if equipGridItemList[i] ~= nil and equipGridItemList[i][j] ~= nil then
        local tempBgGridIndexY = leftInGridIndexY + j - 1
        local tempLeftX = tempBgGridIndexX - 1
        local tempLeftY = tempBgGridIndexY
        if self.m_allGridList[tempLeftX] and self.m_allGridList[tempLeftX][tempLeftY] then
          local leftBgGridItemCom = self.m_allGridList[tempLeftX][tempLeftY]
          if leftBgGridItemCom and leftBgGridItemCom:IsUnLock() then
            local leftBgGridEquipItem = leftBgGridItemCom:GetRogueEquipItem()
            if leftBgGridEquipItem and leftBgGridEquipItem ~= rogueDragEquipItem and self.m_levelRogueStageHelper:IsRogueMaterialByItemCfg(leftBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg) == true then
              local tempItemID = leftBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
              if roundMaterialItemIDDic[tempItemID] == nil then
                roundMaterialItemIDDic[tempItemID] = leftBgGridEquipItem
              end
              roundMaterialItemDic[leftBgGridEquipItem] = tempItemID
            end
          end
        end
        local tempDownX = tempBgGridIndexX
        local tempDownY = tempBgGridIndexY - 1
        if self.m_allGridList[tempDownX] and self.m_allGridList[tempDownX][tempDownY] then
          local downBgGridItemCom = self.m_allGridList[tempDownX][tempDownY]
          if downBgGridItemCom and downBgGridItemCom:IsUnLock() then
            local downBgGridEquipItem = downBgGridItemCom:GetRogueEquipItem()
            if downBgGridEquipItem and downBgGridEquipItem ~= rogueDragEquipItem and self.m_levelRogueStageHelper:IsRogueMaterialByItemCfg(downBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg) == true then
              local tempItemID = downBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
              if roundMaterialItemIDDic[tempItemID] == nil then
                roundMaterialItemIDDic[tempItemID] = downBgGridEquipItem
              end
              roundMaterialItemDic[downBgGridEquipItem] = tempItemID
            end
          end
        end
        local tempUpX = tempBgGridIndexX
        local tempUpY = tempBgGridIndexY + 1
        if self.m_allGridList[tempUpX] and self.m_allGridList[tempUpX][tempUpY] then
          local upBgGridItemCom = self.m_allGridList[tempUpX][tempUpY]
          if upBgGridItemCom and upBgGridItemCom:IsUnLock() then
            local upBgGridEquipItem = upBgGridItemCom:GetRogueEquipItem()
            if upBgGridEquipItem and upBgGridEquipItem ~= rogueDragEquipItem and self.m_levelRogueStageHelper:IsRogueMaterialByItemCfg(upBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg) == true then
              local tempItemID = upBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
              if roundMaterialItemIDDic[tempItemID] == nil then
                roundMaterialItemIDDic[tempItemID] = upBgGridEquipItem
              end
              roundMaterialItemDic[upBgGridEquipItem] = tempItemID
            end
          end
        end
        local tempRightX = tempBgGridIndexX + 1
        local tempRightY = tempBgGridIndexY
        if self.m_allGridList[tempRightX] and self.m_allGridList[tempRightX][tempRightY] then
          local rightBgGridItemCom = self.m_allGridList[tempRightX][tempRightY]
          if rightBgGridItemCom and rightBgGridItemCom:IsUnLock() then
            local rightBgGridEquipItem = rightBgGridItemCom:GetRogueEquipItem()
            if rightBgGridEquipItem and rightBgGridEquipItem ~= rogueDragEquipItem and self.m_levelRogueStageHelper:IsRogueMaterialByItemCfg(rightBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg) == true then
              local tempItemID = rightBgGridEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
              if roundMaterialItemIDDic[tempItemID] == nil then
                roundMaterialItemIDDic[tempItemID] = rightBgGridEquipItem
              end
              roundMaterialItemDic[rightBgGridEquipItem] = tempItemID
            end
          end
        end
      end
    end
  end
  return roundMaterialItemIDDic, roundMaterialItemDic
end

function RogueGridSubPanel:CreateGridItem(itemIndex, itemData, localPosX, localPosY)
  local gameObject = GameObject.Instantiate(self.m_rogue_grid_bg_item, self.m_rootTran).gameObject
  gameObject.name = tostring(itemData.gridX) .. "_" .. tostring(itemData.gridY)
  UILuaHelper.SetActive(gameObject, true)
  UILuaHelper.SetLocalPosition(gameObject, localPosX, localPosY, 0)
  local RogueBgGridItemCom = RogueBgGridItem.new(nil, gameObject, nil, itemData, itemIndex)
  return RogueBgGridItemCom
end

function RogueGridSubPanel:InitCreateGridList(initGridX, initGridY)
  if initGridX > self.MaxGridX or initGridY > self.MaxGridY then
    return
  end
  local halfGridXNum = math.floor(self.MaxGridX / 2)
  local halfGridLeftXNum = self.MaxGridX % 2
  local midGridXIndex = halfGridXNum + halfGridLeftXNum
  local halfInitGridXNum = math.floor(initGridX / 2)
  local halfInitGridLeftXNum = initGridX % 2
  local minInitGridXIndex = midGridXIndex - halfInitGridXNum - halfInitGridLeftXNum + 1
  local maxInitGridXIndex = midGridXIndex + halfInitGridXNum
  local halfGridYNum = math.floor(self.MaxGridY / 2)
  local halfGridLeftYNum = self.MaxGridY % 2
  local midGridYIndex = halfGridYNum + halfGridLeftYNum
  local halfInitGridYNum = math.floor(initGridY / 2)
  local halfInitGridLeftYNum = initGridY % 2
  local minInitGridYIndex = midGridYIndex - halfInitGridYNum - halfInitGridLeftYNum + 1
  local maxInitGridYIndex = midGridYIndex + halfInitGridYNum
  local curItemIndex = 0
  for i = 1, self.MaxGridX do
    local gridXTab = self.m_allGridList[i]
    if gridXTab == nil then
      gridXTab = {}
      self.m_allGridList[i] = gridXTab
    end
    for j = 1, self.MaxGridY do
      curItemIndex = curItemIndex + 1
      local isUnlock = i >= minInitGridXIndex and i <= maxInitGridXIndex and j >= minInitGridYIndex and j <= maxInitGridYIndex
      local itemData = {
        gridX = i,
        gridY = j,
        isUnlock = isUnlock
      }
      local posX, posY = self:GetGirdPosByGridIndex(i, j)
      local gridItemCom = self:CreateGridItem(curItemIndex, itemData, posX, posY)
      gridXTab[j] = gridItemCom
    end
  end
end

function RogueGridSubPanel:FreshGridStatusByPos(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local localPosX, localPosY = rogueDragEquipItem:GetLocalPos()
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridIndexX, gridIndexY = self:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridXNum, gridYNum)
  local isGridExItem = rogueDragEquipItem:IsGridExItem()
  local putStatusList = self:GetGridCanPutStatusList(gridIndexX, gridIndexY, gridXNum, gridYNum, isGridExItem)
  rogueDragEquipItem:FreshBagGridStatusByStatusArray(putStatusList)
  local gridLocalPosX, gridLocalPosY = self:GetDragGridCenterLocalGridPos(gridIndexX, gridIndexY, gridXNum, gridYNum)
  rogueDragEquipItem:FreshBagGridCenterLocalPos(gridLocalPosX, gridLocalPosY)
  if self:CheckAndUpdateGridIndex(gridIndexX, gridIndexY) then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(268)
  end
end

function RogueGridSubPanel:ClearBgGridEquipStatus(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  if not self.m_allGridList then
    return
  end
  for i = 1, self.MaxGridX do
    for j = 1, self.MaxGridY do
      local rogueBgGridItemCom = self.m_allGridList[i][j]
      if rogueBgGridItemCom and rogueBgGridItemCom:GetRogueEquipItem() == rogueDragEquipItem then
        rogueBgGridItemCom:SetRogueEquipItem(nil)
      end
    end
  end
end

function RogueGridSubPanel:CheckAndUpdateGridIndex(gridIndexX, gridIndexY)
  if gridIndexX ~= self.m_curDragItemGridIndex[1] or gridIndexY ~= self.m_curDragItemGridIndex[2] then
    self.m_curDragItemGridIndex[1] = gridIndexX
    self.m_curDragItemGridIndex[2] = gridIndexY
    return true
  end
  return false
end

function RogueGridSubPanel:ChangeBgGridEquipStatusToEquip(rogueDragEquipItem, gridIndexX, gridIndexY)
  if not rogueDragEquipItem then
    return
  end
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local equipGridItemList = rogueDragEquipItem:GetBgGridItemList()
  for i = 1, gridXNum do
    local tempBgGridIndexX = gridIndexX + i - 1
    for j = 1, gridYNum do
      local tempBgGridIndexY = gridIndexY + j - 1
      local rogueBgGridItemCom = self.m_allGridList[tempBgGridIndexX][tempBgGridIndexY]
      if rogueBgGridItemCom and rogueBgGridItemCom:GetRogueEquipItem() == nil and equipGridItemList[i] ~= nil and equipGridItemList[i][j] ~= nil then
        rogueBgGridItemCom:SetRogueEquipItem(rogueDragEquipItem)
      end
    end
  end
end

function RogueGridSubPanel:IsEquipItemCanEquip(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local localPosX, localPosY = rogueDragEquipItem:GetLocalPos()
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridIndexX, gridIndexY = self:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridXNum, gridYNum)
  local isGridExItem = rogueDragEquipItem:IsGridExItem()
  local putStatusList = self:GetGridCanPutStatusList(gridIndexX, gridIndexY, gridXNum, gridYNum, isGridExItem)
  return rogueDragEquipItem:IsEquipItemCanEquip(putStatusList)
end

function RogueGridSubPanel:EquipDragItemInGrid(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local localPosX, localPosY = rogueDragEquipItem:GetLocalPos()
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridIndexX, gridIndexY = self:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridXNum, gridYNum)
  local gridLocalPosX, gridLocalPosY = self:GetDragGridCenterLocalGridPos(gridIndexX, gridIndexY, gridXNum, gridYNum)
  rogueDragEquipItem:SetLocalPos(gridLocalPosX, gridLocalPosY)
  rogueDragEquipItem:FreshBagGridCenterLocalPos(gridLocalPosX, gridLocalPosY)
  self:ChangeBgGridEquipStatusToEquip(rogueDragEquipItem, gridIndexX, gridIndexY)
  rogueDragEquipItem:OnEquipInGrid(gridIndexX, gridIndexY)
end

function RogueGridSubPanel:ExpandBgGrid(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local localPosX, localPosY = rogueDragEquipItem:GetLocalPos()
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridIndexX, gridIndexY = self:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridXNum, gridYNum)
  local equipBgGridItemList = rogueDragEquipItem:GetBgGridItemList()
  for i = 1, gridXNum do
    local tempGridIndexX = gridIndexX + i - 1
    for j = 1, gridYNum do
      local tempGridIndexY = gridIndexY + j - 1
      local tempBgItemCom = self.m_allGridList[tempGridIndexX][tempGridIndexY]
      if tempBgItemCom ~= nil and equipBgGridItemList[i][j] ~= nil then
        tempBgItemCom:ChangeUnlockStatus(true)
      end
    end
  end
  rogueDragEquipItem:OnEquipInGrid(gridIndexX, gridIndexY)
end

function RogueGridSubPanel:ExpandBgGridByIndex(rogueDragEquipItem, bgGridIndexX, bgGridIndexY)
  if not rogueDragEquipItem then
    return
  end
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridLocalPosX, gridLocalPosY = self:GetDragGridCenterLocalGridPos(bgGridIndexX, bgGridIndexY, gridXNum, gridYNum)
  rogueDragEquipItem:SetLocalPos(gridLocalPosX, gridLocalPosY)
  rogueDragEquipItem:FreshBagGridCenterLocalPos(gridLocalPosX, gridLocalPosY)
  local equipBgGridItemList = rogueDragEquipItem:GetBgGridItemList()
  for i = 1, gridXNum do
    local tempGridIndexX = bgGridIndexX + i - 1
    for j = 1, gridYNum do
      local tempGridIndexY = bgGridIndexY + j - 1
      local tempBgItemCom = self.m_allGridList[tempGridIndexX][tempGridIndexY]
      if tempBgItemCom ~= nil and equipBgGridItemList[i][j] ~= nil then
        tempBgItemCom:ChangeUnlockStatus(true)
      end
    end
  end
  rogueDragEquipItem:OnEquipInGrid(bgGridIndexX, bgGridIndexY)
end

function RogueGridSubPanel:EquipDragItemInGridByIndex(rogueDragEquipItem, bgGridIndexX, bgGridIndexY)
  if not rogueDragEquipItem then
    return
  end
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridLocalPosX, gridLocalPosY = self:GetDragGridCenterLocalGridPos(bgGridIndexX, bgGridIndexY, gridXNum, gridYNum)
  rogueDragEquipItem:SetLocalPos(gridLocalPosX, gridLocalPosY)
  rogueDragEquipItem:FreshBagGridCenterLocalPos(gridLocalPosX, gridLocalPosY)
  self:ChangeBgGridEquipStatusToEquip(rogueDragEquipItem, bgGridIndexX, bgGridIndexY)
  rogueDragEquipItem:OnEquipInGrid(bgGridIndexX, bgGridIndexY)
end

function RogueGridSubPanel:IsMapEquipItemCanCombine(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  if self.m_levelRogueStageHelper:IsRogueMapMaterialByItemCfg(rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg) ~= true then
    return false
  end
  local rogueMapID = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
  local combineNeedMaterialIDList = self.m_levelRogueStageHelper:GetRogueCombinationMaterialIDListByMapID(rogueMapID)
  if not combineNeedMaterialIDList or not next(combineNeedMaterialIDList) then
    return false
  end
  local _, roundMaterialItemObjDic = self:GetRogueEquipItemRoundMaterialIDDic(rogueDragEquipItem)
  local isCanCombine = true
  local combineMaterialItemList = {}
  local tempRoundMaterialItemObjDic = {}
  for i, v in pairs(roundMaterialItemObjDic) do
    tempRoundMaterialItemObjDic[i] = v
  end
  for _, itemId in ipairs(combineNeedMaterialIDList) do
    local obj = table.keyof(tempRoundMaterialItemObjDic, itemId)
    if obj then
      combineMaterialItemList[#combineMaterialItemList + 1] = obj
      tempRoundMaterialItemObjDic[obj] = nil
    else
      isCanCombine = false
      break
    end
  end
  return isCanCombine, combineMaterialItemList
end

function RogueGridSubPanel:GetLockGridNum()
  if not self.m_allGridList then
    return
  end
  local lockGridNum = 0
  for i = 1, self.MaxGridX do
    local gridXTab = self.m_allGridList[i]
    if gridXTab then
      for j = 1, self.MaxGridY do
        local gridItemCom = gridXTab[j]
        if gridItemCom:IsUnLock() ~= true then
          lockGridNum = lockGridNum + 1
        end
      end
    end
  end
  return lockGridNum
end

function RogueGridSubPanel:GetMapRoundAllCombineMaterialItemList(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  if self.m_levelRogueStageHelper:IsRogueMapMaterialByItemCfg(rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg) ~= true then
    return
  end
  local rogueMapID = rogueDragEquipItem.m_rogueEquipItemData.rogueStageItemCfg.m_ItemID
  local combineNeedMaterialIDList = self.m_levelRogueStageHelper:GetRogueCombinationMaterialIDListByMapID(rogueMapID)
  if not combineNeedMaterialIDList or not next(combineNeedMaterialIDList) then
    return
  end
  local roundMaterialItemDic = self:GetRogueEquipItemRoundMaterialIDDic(rogueDragEquipItem) or {}
  local combineMaterialItemList = {}
  for _, tempNeedItemID in ipairs(combineNeedMaterialIDList) do
    if roundMaterialItemDic[tempNeedItemID] ~= nil then
      combineMaterialItemList[#combineMaterialItemList + 1] = roundMaterialItemDic[tempNeedItemID]
    end
  end
  return combineMaterialItemList
end

function RogueGridSubPanel:GetGridObjByXY(x, y)
  if not self.m_allGridList then
    return
  end
  local gridXTab = self.m_allGridList[x]
  if gridXTab and gridXTab[y] then
    return gridXTab[y]:GetItemRootObj()
  end
end

function RogueGridSubPanel:GetItemPosInGrid(rogueDragEquipItem)
  if not rogueDragEquipItem then
    return
  end
  local localPosX, localPosY = rogueDragEquipItem:GetLocalPos()
  local gridXNum, gridYNum = rogueDragEquipItem:GetGridNumXY()
  local gridIndexX, gridIndexY = self:GetLeftGridXYByLocalPosAndGridSize(localPosX, localPosY, gridXNum, gridYNum)
  return gridIndexX, gridIndexY
end

return RogueGridSubPanel
