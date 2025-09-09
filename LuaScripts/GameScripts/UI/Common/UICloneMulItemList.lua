local BaseNode = require("Base/BaseNode")
local UICloneMulItemList = class("UICloneMulItemList", BaseNode)

function UICloneMulItemList:ctor(parentNode, baseNode, itemLuaPath, initItemData)
  UICloneMulItemList.super.ctor(self, parentNode, baseNode, itemLuaPath, initItemData)
  if not parentNode then
    return
  end
  if not baseNode then
    return
  end
  if not itemLuaPath then
    return
  end
  self.m_parentTrans = parentNode.transform
  self.m_baseObject = baseNode.gameObject
  UILuaHelper.SetActive(self.m_baseObject, false)
  self.m_itemDataList = nil
  self.m_itemLuaPath = "UI/Item/" .. itemLuaPath
  self.m_itemClass = require(self.m_itemLuaPath)
  self.m_itemList = {}
  self.m_initItemData = initItemData
end

function UICloneMulItemList:OnUpdate(dt)
  if not self.m_itemList then
    return
  end
  if not self.m_itemDataList then
    return
  end
  for i, v in ipairs(self.m_itemDataList) do
    local itemNode = self.m_itemList[i]
    if itemNode then
      itemNode:update(dt)
    end
  end
end

function UICloneMulItemList:dispose()
  self:DisPoseItems()
  UICloneMulItemList.super.dispose(self)
end

function UICloneMulItemList:ShowItemList(itemDataList)
  if not itemDataList then
    return
  end
  self.m_itemDataList = itemDataList
  self:FreshAllItemNodes()
end

function UICloneMulItemList:FreshAllItemNodes()
  if not self.m_itemDataList then
    return
  end
  local itemNodes = self.m_itemList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_parentTrans
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      itemNode:FreshData(self.m_itemDataList[i], i)
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_baseObject, parentTrans).gameObject
      local itemNode = self:InitItemNode(itemObj, self.m_itemDataList[i], i)
      itemNode:SetActive(true)
      itemNodes[#itemNodes + 1] = itemNode
    elseif i <= childCount and i > dataLen and itemNodes[i].SetActive then
      itemNodes[i]:SetActive(false)
    end
  end
end

function UICloneMulItemList:FreshItemByIndex(itemIndex)
  if not itemIndex then
    return
  end
  local itemNode = self.m_itemList[itemIndex]
  if not itemNode then
    return
  end
  local itemData = self.m_itemDataList[itemIndex]
  if not itemData then
    return
  end
  itemNode:FreshData(itemData, itemIndex)
end

function UICloneMulItemList:GetAllShownItemList()
  if not self.m_itemDataList then
    return
  end
  if not self.m_itemList then
    return
  end
  local showItemNodeList = {}
  for i, _ in ipairs(self.m_itemDataList) do
    local itemNode = self.m_itemList[i]
    if itemNode then
      showItemNodeList[#showItemNodeList + 1] = itemNode
    end
  end
  return showItemNodeList
end

function UICloneMulItemList:GetShowItemByIndex(itemIndex)
  if not itemIndex then
    return
  end
  if not self.m_itemDataList then
    return
  end
  if not self.m_itemList then
    return
  end
  local itemData = self.m_itemDataList[itemIndex]
  if not itemData then
    return
  end
  local itemNode = self.m_itemList[itemIndex]
  if not itemNode then
    return
  end
  return itemNode
end

function UICloneMulItemList:GetShowItemByData(data)
  if not data then
    return
  end
  if not self.m_itemDataList then
    return
  end
  if not self.m_itemList then
    return
  end
  for i, itemData in ipairs(self.m_itemDataList) do
    if itemData == data then
      local itemNode = self.m_itemList[i]
      if itemNode then
        return itemNode
      end
    end
  end
end

function UICloneMulItemList:DisPoseItems()
  if not self.m_itemList then
    return
  end
  for _, item in ipairs(self.m_itemList) do
    if item then
      item:dispose()
    end
  end
  self.m_itemList = {}
  self.m_itemDataList = nil
  local childCount = self.m_parentTrans.childCount
  for i = childCount, 1, -1 do
    local child = self.m_parentTrans:GetChild(i - 1)
    if child and not utils.isNull(child) then
      local childObj = child.gameObject
      if childObj and childObj ~= self.m_baseObject then
        UILuaHelper.DestroyReleaseSpriteRefHolder(childObj)
        GameObject.Destroy(childObj)
      end
    end
  end
end

function UICloneMulItemList:UnRegisterAllRedDotItem()
  if not self.m_itemList then
    return
  end
  for _, item in pairs(self.m_itemList) do
    if item then
      item:UnRegisterAllRedDotItem()
    end
  end
end

function UICloneMulItemList:InitItemNode(itemObj, itemData, itemIndex)
  if not itemObj then
    return
  end
  if not self.m_itemClass then
    return
  end
  local itemNode = self.m_itemClass.new(nil, itemObj, self.m_initItemData, itemData, itemIndex)
  return itemNode
end

return UICloneMulItemList
