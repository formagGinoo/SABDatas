local BaseNode = require("Base/BaseNode")
local UIInfinityGrid = class("UIInfinityGrid", BaseNode)

function UIInfinityGrid:ctor(infinityGrid, itemLuaName, initItemData, disableAutoActive)
  UIInfinityGrid.super.ctor(self, infinityGrid, itemLuaName, initItemData)
  if not infinityGrid then
    return
  end
  self.m_infinityGrid = infinityGrid
  self.m_itemDataList = nil
  self.m_itemLuaPath = "UI/Item/" .. itemLuaName
  self.m_itemClass = require(self.m_itemLuaPath)
  self.m_itemCache = {}
  self.m_initItemData = initItemData
  self.m_infinityGrid:RegisterBindCallback(handler(self, self.OnItemBind))
  self.m_infinityGrid.AutoActive = not disableAutoActive
end

function UIInfinityGrid:ShowItemList(itemDataList, forceRefresh)
  if not itemDataList then
    return
  end
  if not self.m_itemDataList then
    self:DisPoseItems()
    self.m_infinityGrid:Clear()
    self.m_itemDataList = itemDataList
    self.m_infinityGrid.TotalItemCount = #self.m_itemDataList
  elseif #self.m_itemDataList ~= #itemDataList or forceRefresh then
    self:DisPoseItems()
    self.m_infinityGrid:Clear()
    self.m_itemDataList = itemDataList
    self.m_infinityGrid.TotalItemCount = #self.m_itemDataList
  else
    self.m_itemDataList = itemDataList
    self:ReBindAll()
  end
end

function UIInfinityGrid:OnItemBind(templateCache, gameObject, index)
  local itemIndex = index + 1
  local itemData = self.m_itemDataList[itemIndex]
  if not itemData then
    return
  end
  local gameObjectHashCode = gameObject:GetHashCode()
  if not self.m_itemCache[gameObjectHashCode] then
    self.m_itemCache[gameObjectHashCode] = self.m_itemClass.new(templateCache, gameObject, self.m_initItemData, itemData, itemIndex)
  else
    local itemLuaPanel = self.m_itemCache[gameObjectHashCode]
    itemLuaPanel:FreshData(itemData, itemIndex)
  end
end

function UIInfinityGrid:OnUpdate(dt)
  if self.m_itemCache then
    for i, itemLuaPanel in pairs(self.m_itemCache) do
      itemLuaPanel:update(dt)
    end
  end
end

function UIInfinityGrid:RegisterButtonCallback(btnNameStr, callBack)
  if not btnNameStr then
    return
  end
  if not self.m_infinityGrid then
    return
  end
  self.m_infinityGrid:RegisterButtonCallback(btnNameStr, callBack)
end

function UIInfinityGrid:ReBindAll()
  if not self.m_infinityGrid then
    return
  end
  self.m_infinityGrid:ReBindAll()
end

function UIInfinityGrid:ReBind(itemIndex)
  if not itemIndex then
    return
  end
  local index = itemIndex - 1
  self.m_infinityGrid:ReBind(index)
end

function UIInfinityGrid:GetAllShownItem()
  return self.m_itemCache
end

function UIInfinityGrid:GetAllShownItemList()
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

function UIInfinityGrid:GetShowItemByIndex(itemIndex)
  for _, item in pairs(self.m_itemCache) do
    if item.m_itemIndex == itemIndex then
      return item
    end
  end
end

function UIInfinityGrid:GetItemByData(data)
  if not data then
    return
  end
  for _, item in pairs(self.m_itemCache) do
    if item.m_itemData == data then
      return item
    end
  end
end

function UIInfinityGrid:LocateTo(itemIndex)
  itemIndex = itemIndex or 0
  local num = table.getn(self.m_itemDataList)
  if 1 < num then
    self.m_infinityGrid:LocateTo(itemIndex)
  end
end

function UIInfinityGrid:SetCellPerLine(count)
  count = count or 1
  self.m_infinityGrid:SetCellPerLine(count)
end

function UIInfinityGrid:GetLineSize()
  if self.m_infinityGrid.LimitSlideWhenContentInMask then
    return self.m_infinityGrid.LineSize
  end
  return nil
end

function UIInfinityGrid:DisPoseItems()
  for _, item in pairs(self.m_itemCache) do
    if item then
      item:dispose()
    end
  end
  self.m_itemCache = {}
end

function UIInfinityGrid:UnRegisterAllRedDotItem()
  if not self.m_itemCache then
    return
  end
  for _, item in pairs(self.m_itemCache) do
    if item then
      item:UnRegisterAllRedDotItem()
    end
  end
end

function UIInfinityGrid:dispose()
  self:DisPoseItems()
  UIInfinityGrid.super.dispose(self)
end

return UIInfinityGrid
