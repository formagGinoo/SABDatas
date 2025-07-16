local BaseNode = require("Base/BaseNode")
local UIItemBase = class("UIItemBase", BaseNode)

function UIItemBase:ctor(itemTemplateCache, itemRootObj, itemInitData, itemData, itemIndex)
  UIItemBase.super.ctor(self, itemTemplateCache, itemRootObj, itemData)
  self.m_itemTemplateCache = itemTemplateCache
  self.m_itemRootObj = itemRootObj
  self.m_itemInitData = itemInitData
  self.m_itemData = itemData
  self.m_itemIndex = itemIndex
  self.m_redDotItemList = {}
  self:InitItemUI()
  self:FreshData(itemData, itemIndex)
end

function UIItemBase:InitItemUI()
  if not self.m_itemRootObj then
    return
  end
  UILuaHelper.BindViewObjectsManual(self, self.m_itemRootObj, self:getName())
  self:doEvent("OnInit")
end

function UIItemBase:FreshData(itemData, itemIndex)
  if not itemData then
    return
  end
  self.m_itemData = itemData
  self.m_itemIndex = itemIndex
  self:doEvent("OnFreshData")
end

function UIItemBase:dispose()
  UIItemBase.super.dispose(self)
end

function UIItemBase:OnDestroy()
  self:UnRegisterAllRedDotItem()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_itemRootObj, self:getName())
  self.m_itemTemplateCache = nil
  self.m_itemRootObj = nil
  self.m_itemData = nil
  self.m_itemIndex = nil
end

function UIItemBase:GetItemRootObj()
  return self.m_itemRootObj
end

function UIItemBase:SetActive(isActive)
  if self.m_itemRootObj then
    self.m_itemRootObj:SetActive(isActive)
  end
end

function UIItemBase:RegisterOrUpdateRedDotItem(redDotNodeTrans, redDotType, param)
  local tempRedDotItem
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    if redDotItem and redDotItem:GetRedDotTrans() ~= nil and redDotItem:GetRedDotTrans() == redDotNodeTrans then
      tempRedDotItem = redDotItem
    end
  end
  if tempRedDotItem then
    self:FreshRedDotItemData(redDotNodeTrans, redDotType, param)
  else
    self:RegisterRedDotItem(redDotNodeTrans, redDotType, param)
  end
end

function UIItemBase:FreshRedDotItemData(redDotNodeTrans, redDotType, param)
  if not redDotType then
    return
  end
  if not self.m_redDotItemList then
    return
  end
  if not next(self.m_redDotItemList) then
    return
  end
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    if redDotItem:GetRedDotTrans() == redDotNodeTrans then
      redDotItem:FreshData(redDotType, param)
    end
  end
end

function UIItemBase:RegisterRedDotItem(redDotTrans, redDotType, param)
  if not redDotTrans then
    return
  end
  local retDotItem = RedDotManager:RegisterRedDotItem(redDotTrans, redDotType, param)
  if retDotItem then
    self.m_redDotItemList[#self.m_redDotItemList + 1] = retDotItem
  end
  return retDotItem
end

function UIItemBase:UnRegisterAllRedDotItem()
  if not self.m_redDotItemList then
    return
  end
  if not next(self.m_redDotItemList) then
    return
  end
  for _, redDotItem in ipairs(self.m_redDotItemList) do
    RedDotManager:UnRegisterRedDotItem(redDotItem)
  end
  self.m_redDotItemList = {}
end

return UIItemBase
