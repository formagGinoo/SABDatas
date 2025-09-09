local EScrollViewActions = {
  INIT_CELL = 1,
  UPDATE_CELL = 2,
  PULL_REFRESH = 3
}
local BaseNode = require("Base/BaseNode")
local UILoopScrollView = class("UILoopScrollView", BaseNode)

function UILoopScrollView:ctor(loopScrollView, itemLuaPath, initItemData)
  UILoopScrollView.super.ctor(self, loopScrollView, itemLuaPath, initItemData)
  if not loopScrollView then
    return
  end
  self.m_loopScrollView = loopScrollView
  self.m_itemDataList = nil
  self.m_itemLuaPath = "UI/Item/" .. itemLuaPath
  self.m_itemClass = require(self.m_itemLuaPath)
  self.m_itemCache = {}
  self.m_initItemData = initItemData
  self.m_paramTab = initItemData.params or {}
  self.m_pullFreshBackFun = nil
end

function UILoopScrollView:InitLoopScrollView()
  if not self.m_itemDataList then
    return
  end
  self.m_loopScrollView.cellsCount = #self.m_itemDataList
  self.m_loopScrollView:Initialize(handler(self, self.OnItemBind))
end

function UILoopScrollView:OnItemBind(loopScrollView, actionType, index, gameObject)
  if not self.m_itemDataList then
    return
  end
  local itemIndex = index + 1
  local itemData = self.m_itemDataList[itemIndex]
  if not itemData then
    return
  end
  if actionType == EScrollViewActions.INIT_CELL or actionType == EScrollViewActions.UPDATE_CELL then
    if gameObject and not utils.isNull(gameObject) then
      local gameObjectHashCode = gameObject:GetHashCode()
      if not self.m_itemCache[gameObjectHashCode] then
        self.m_itemCache[gameObjectHashCode] = self.m_itemClass.new(nil, gameObject, self.m_initItemData, itemData, itemIndex)
      else
        local itemLuaPanel = self.m_itemCache[gameObjectHashCode]
        itemLuaPanel:FreshData(itemData, itemIndex)
      end
    end
  elseif actionType == EScrollViewActions.PULL_REFRESH then
    self:OnPullRefresh()
  end
end

function UILoopScrollView:OnUpdate(dt)
  if self.m_itemCache then
    for i, itemLuaPanel in pairs(self.m_itemCache) do
      itemLuaPanel:update(dt)
    end
  end
end

function UILoopScrollView:dispose()
  self:DisPoseItems()
  UILoopScrollView.super.dispose(self)
end

function UILoopScrollView:ShowItemList(itemDataList, forceRefresh)
  if not itemDataList then
    return
  end
  if not self.m_itemDataList then
    self:DisPoseItems()
    self.m_itemDataList = itemDataList
    self:InitLoopScrollView()
  elseif #self.m_itemDataList ~= #itemDataList or forceRefresh then
    self:DisPoseItems()
    self.m_itemDataList = itemDataList
    self.m_loopScrollView:ReloadData(#self.m_itemDataList, true)
  else
    self.m_itemDataList = itemDataList
    self:ReBindAll()
  end
end

function UILoopScrollView:OnPullRefresh()
  if self.m_pullFreshBackFun then
    self.m_pullFreshBackFun()
  end
end

function UILoopScrollView:SetPullFreshBackFun(fun)
  self.m_pullFreshBackFun = fun
end

function UILoopScrollView:ReBindAll(isResetPos)
  if not self.m_loopScrollView then
    return
  end
  if not self.m_itemDataList then
    return
  end
  if isResetPos == nil then
    isResetPos = false
  end
  self.m_loopScrollView:ReloadData(#self.m_itemDataList, isResetPos)
end

function UILoopScrollView:ReBind(itemIndex)
  if not itemIndex then
    return
  end
  local index = itemIndex - 1
  self.m_loopScrollView:UpdateCellAtIndex(index)
end

function UILoopScrollView:GetAllShownItem()
  return self.m_itemCache
end

function UILoopScrollView:GetAllShownItemList()
  local tempItemList = {}
  for _, item in pairs(self.m_itemCache) do
    tempItemList[#tempItemList + 1] = item
  end
  if next(tempItemList) then
    table.sort(tempItemList, function(a, b)
      return a.m_itemIndex < b.m_itemIndex
    end)
  end
  return tempItemList
end

function UILoopScrollView:GetShowItemByIndex(itemIndex)
  for _, item in pairs(self.m_itemCache) do
    if item.m_itemIndex == itemIndex then
      return item
    end
  end
end

function UILoopScrollView:GetItemByData(data)
  if not data then
    return
  end
  for _, item in pairs(self.m_itemCache) do
    if item.m_itemData == data then
      return item
    end
  end
end

function UILoopScrollView:ScrollTo(itemIndex, offset)
  if not self.m_itemDataList then
    return
  end
  if itemIndex and 0 < itemIndex then
    itemIndex = itemIndex - 1
  else
    itemIndex = 0
  end
  offset = offset or 0
  local num = #self.m_itemDataList
  if 1 < num then
    self.m_loopScrollView:MoveToCellIndex(itemIndex)
  end
end

function UILoopScrollView:DisPoseItems()
  for _, item in pairs(self.m_itemCache) do
    if item then
      item:dispose()
    end
  end
  self.m_itemCache = {}
end

function UILoopScrollView:UnRegisterAllRedDotItem()
  if not self.m_itemCache then
    return
  end
  for _, item in pairs(self.m_itemCache) do
    if item then
      item:UnRegisterAllRedDotItem()
    end
  end
end

return UILoopScrollView
