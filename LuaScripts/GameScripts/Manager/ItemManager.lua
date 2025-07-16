local BaseManager = require("Manager/Base/BaseManager")
local ItemManager = class("ItemManager", BaseManager)
local CData_ItemInstance = CS.CData_Item.GetInstance()
ItemManager.ItemType = {
  Item = 10,
  Character = 20,
  Chest = 30,
  IdleCapsule = 40,
  Fragment = 50,
  Equipment = 60,
  AttractGift = 80,
  Null = 90,
  PaidItemActivation = 110
}
ItemManager.ItemSubType = {
  Item = 10,
  EffectiveItem = 11,
  Character = 20,
  ChestCertain = 30,
  ChestCustom = 31,
  ChestRandom = 32,
  IdleCapsule = 40,
  FragmentCertain = 50,
  FragmentRandom = 51,
  FragmentDeduplicatedRandom = 52,
  Equipment = 60,
  Null = 90
}
ItemManager.ItemQuickUseType = {
  HeroLevelUp = 1,
  SkillLevelUp = 2,
  LevelUp = 3
}

function ItemManager:OnCreate()
  self.m_vItemList = {}
  self.m_mItemList = {}
  self.m_iBagLimit = 0
  self.m_mSpecialItem = {}
  self.m_mUniqueItem = {}
  self.m_quickBagItem = {}
end

function ItemManager:OnInitNetwork()
  RPCS():Listen_Push_SetItem(handler(self, self.OnPushSetItem), "ItemManager")
  RPCS():Listen_Push_SetSpecialItem(handler(self, self.OnPushSetSpecialItem), "ItemManager")
  RPCS():Listen_Push_SetUniqueItem(handler(self, self.OnPushSetUniqueItem), "ItemManager")
end

function ItemManager:OnAfterInitConfig()
  self:InitQuickBagItemCfgId()
end

function ItemManager:InitQuickBagItemCfgId()
  local itemAllCfg = CS.CData_Item.GetInstance():GetAll()
  for _, tempCfg in pairs(itemAllCfg) do
    if tempCfg.m_FastBagSign and tempCfg.m_FastBagSign ~= 0 then
      if not self.m_quickBagItem[tempCfg.m_FastBagSign] then
        self.m_quickBagItem[tempCfg.m_FastBagSign] = {}
      end
      table.insert(self.m_quickBagItem[tempCfg.m_FastBagSign], tempCfg.m_ItemID)
    end
  end
end

function ItemManager:GetQuickBagItem()
  return self.m_quickBagItem
end

function ItemManager:SetSpecialItem(mSpecialItem)
  self.m_mSpecialItem = mSpecialItem
  if self.m_mSpecialItem[MTTDProto.SpecialItem_Diamond] == nil then
    self.m_mSpecialItem[MTTDProto.SpecialItem_Diamond] = 0
  end
end

function ItemManager:OnUpdate(dt)
end

function ItemManager:OnItemGetListSC(stItemGetListSC, msg)
  self.m_vItemList = stItemGetListSC.vItemList
  self.m_iBagLimit = stItemGetListSC.iBagLimit
  self.m_mUniqueItem = stItemGetListSC.mUniqueItem
  self.m_mItemList = {}
  for _, stItemInfo in pairs(self.m_vItemList) do
    self.m_mItemList[stItemInfo.iItemUid] = stItemInfo.iNum
  end
  self:broadcastEvent("eGameEvent_Item_Init")
  self:CheckFragmentCertainRedPoint()
end

function ItemManager:OnPushSetItem(stPushSetItem, msg)
  local vItemChange = {}
  for _, stItemInfoNew in pairs(stPushSetItem.vItem) do
    local stItemChange = {
      iID = stItemInfoNew.iBaseId,
      iNum = stItemInfoNew.iNum,
      iNumOld = 0,
      expireTime = nil
    }
    if self.m_mItemList[stItemInfoNew.iItemUid] == nil then
      self.m_mItemList[stItemInfoNew.iItemUid] = stItemInfoNew.iNum
      self.m_vItemList[#self.m_vItemList + 1] = stItemInfoNew
      stItemChange.iNumOld = 0
      self:SetImportantItemShowRedPoint(stItemInfoNew.iBaseId, 1)
    else
      if stItemInfoNew.iNum == 0 then
        self.m_mItemList[stItemInfoNew.iItemUid] = nil
        self:SetImportantItemShowRedPoint(stItemInfoNew.iBaseId, 0)
      else
        local flag = self.m_mItemList[stItemInfoNew.iItemUid] > stItemInfoNew.iNum and 0 or 1
        self:SetImportantItemShowRedPoint(stItemInfoNew.iBaseId, flag)
        self.m_mItemList[stItemInfoNew.iItemUid] = stItemInfoNew.iNum
      end
      for key, stItemInfoOld in pairs(self.m_vItemList) do
        if stItemInfoOld.iItemUid == stItemInfoNew.iItemUid then
          stItemChange.iNumOld = stItemInfoOld.iNum
          if stItemInfoNew.iNum == 0 then
            self.m_vItemList[key] = nil
            break
          end
          stItemInfoOld.iNum = stItemInfoNew.iNum
          break
        end
      end
    end
    vItemChange[#vItemChange + 1] = stItemChange
    GuideManager:OnAddItem(stItemInfoNew.iBaseId)
  end
  self:broadcastEvent("eGameEvent_Item_SetItem", vItemChange)
  self:CheckFragmentCertainRedPoint()
end

function ItemManager:OnPushSetSpecialItem(stPushSetSpecialItem, msg)
  local stItemChange
  if stPushSetSpecialItem.iID == MTTDProto.SpecialItem_NegDiamond then
    local oldNum = self:GetItemNum(MTTDProto.SpecialItem_FreeDiamond)
    local iNum = (self.m_mSpecialItem[MTTDProto.SpecialItem_FreeDiamond] or 0) - (stPushSetSpecialItem.iNum or 0)
    stItemChange = {
      iID = MTTDProto.SpecialItem_FreeDiamond,
      iNum = iNum,
      iNumOld = oldNum
    }
  elseif stPushSetSpecialItem.iID == MTTDProto.SpecialItem_FreeDiamond then
    local oldNum = self:GetItemNum(MTTDProto.SpecialItem_FreeDiamond)
    local iNum = (stPushSetSpecialItem.iNum or 0) - (self.m_mSpecialItem[MTTDProto.SpecialItem_NegDiamond] or 0)
    stItemChange = {
      iID = MTTDProto.SpecialItem_FreeDiamond,
      iNum = iNum,
      iNumOld = oldNum
    }
  else
    stItemChange = {
      iID = stPushSetSpecialItem.iID,
      iNum = stPushSetSpecialItem.iNum,
      iNumOld = self.m_mSpecialItem[stPushSetSpecialItem.iID] or 0
    }
  end
  if stPushSetSpecialItem.iNum == 0 and stPushSetSpecialItem.iID ~= MTTDProto.SpecialItem_FreeDiamond and stPushSetSpecialItem.iID ~= MTTDProto.SpecialItem_Diamond then
    self.m_mSpecialItem[stPushSetSpecialItem.iID] = nil
  else
    self.m_mSpecialItem[stPushSetSpecialItem.iID] = stPushSetSpecialItem.iNum
  end
  local flag = stItemChange.iNumOld > stItemChange.iNum and 0 or 1
  self:SetImportantItemShowRedPoint(stPushSetSpecialItem.iID, flag)
  self:broadcastEvent("eGameEvent_Item_SetItem", {stItemChange})
  GuideManager:OnAddItem(stPushSetSpecialItem.iID)
  self:CheckFragmentCertainRedPoint()
end

function ItemManager:OnPushSetUniqueItem(stPushSetUniqueItem, msg)
  local stItemChange = {
    iID = stPushSetUniqueItem.iItemId,
    iNum = 0,
    iNumOld = 0,
    expireTime = nil
  }
  local expireTime = self.m_mUniqueItem[stPushSetUniqueItem.iItemId]
  if expireTime then
    stItemChange.iNumOld = 1
  else
    stItemChange.iNumOld = 0
  end
  if stPushSetUniqueItem.bDelete then
    stItemChange.iNum = 0
    self.m_mUniqueItem[stPushSetUniqueItem.iItemId] = nil
  else
    stItemChange.iNum = 1
    self.m_mUniqueItem[stPushSetUniqueItem.iItemId] = stPushSetUniqueItem.iExpireTime
  end
  stItemChange.expireTime = stPushSetUniqueItem.iExpireTime
  self:broadcastEvent("eGameEvent_Item_SetItem", {stItemChange})
end

function ItemManager:GetItemListByTag(iTag)
  local vItemList = {}
  local num = self.m_mSpecialItem[MTTDProto.SpecialItem_Diamond] or 0
  for iID, iNum in pairs(self.m_mSpecialItem) do
    if (iTag == nil or iTag == 0) and iNum ~= 0 then
      vItemList[#vItemList + 1] = {iID = iID, iNum = iNum}
    else
      local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iID)
      if stItemData and stItemData.m_VisibleInvTag == iTag and (iNum ~= 0 or iID == MTTDProto.SpecialItem_FreeDiamond and num ~= 0) then
        vItemList[#vItemList + 1] = {iID = iID, iNum = iNum}
      end
    end
  end
  for _, stItemInfo in pairs(self.m_vItemList) do
    if (iTag == nil or iTag == 0) and stItemInfo.iNum ~= 0 then
      vItemList[#vItemList + 1] = {
        iID = stItemInfo.iBaseId,
        iNum = stItemInfo.iNum
      }
    else
      local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(stItemInfo.iBaseId)
      if stItemData and stItemData.m_VisibleInvTag == iTag and stItemInfo.iNum ~= 0 then
        vItemList[#vItemList + 1] = {
          iID = stItemInfo.iBaseId,
          iNum = stItemInfo.iNum
        }
      end
    end
  end
  return vItemList
end

function ItemManager:GetAllItemList()
  local vItemList = {}
  for iID, iNum in pairs(self.m_mSpecialItem) do
    vItemList[#vItemList + 1] = {iID = iID, iNum = iNum}
  end
  for _, stItemInfo in pairs(self.m_vItemList) do
    vItemList[#vItemList + 1] = {
      iID = stItemInfo.iBaseId,
      iNum = stItemInfo.iNum
    }
  end
  return vItemList
end

function ItemManager:GetItemListByType(itemType)
  local vItemList = {}
  for iID, iNum in pairs(self.m_mSpecialItem) do
    local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iID)
    if stItemData and stItemData.m_ItemType == itemType and iNum ~= 0 then
      vItemList[#vItemList + 1] = {iID = iID, iNum = iNum}
    end
  end
  for _, stItemInfo in pairs(self.m_vItemList) do
    local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(stItemInfo.iBaseId)
    if stItemData and stItemData.m_ItemType == itemType and stItemInfo.iNum ~= 0 then
      vItemList[#vItemList + 1] = {
        iID = stItemInfo.iBaseId,
        iNum = stItemInfo.iNum
      }
    end
  end
  return vItemList
end

function ItemManager:GetItemListBySubType(subType)
  local vItemList = {}
  for iID, iNum in pairs(self.m_mSpecialItem) do
    local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iID)
    if stItemData and stItemData.m_ItemSubType == subType and iNum ~= 0 then
      vItemList[#vItemList + 1] = {iID = iID, iNum = iNum}
    end
  end
  for _, stItemInfo in pairs(self.m_vItemList) do
    local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(stItemInfo.iBaseId)
    if stItemData and stItemData.m_ItemSubType == subType and stItemInfo.iNum ~= 0 then
      vItemList[#vItemList + 1] = {
        iID = stItemInfo.iBaseId,
        iNum = stItemInfo.iNum
      }
    end
  end
  return vItemList
end

function ItemManager:GetDiamondTotalNum()
  local totalNum = self:GetItemNum(MTTDProto.SpecialItem_Diamond) + self:GetItemNum(MTTDProto.SpecialItem_FreeDiamond)
  local freeNum = self:GetItemNum(MTTDProto.SpecialItem_FreeDiamond)
  return totalNum, freeNum
end

function ItemManager:GetItemNum(iItemID, bIsPurchasing)
  if iItemID == MTTDProto.SpecialItem_ShowDiamond or iItemID == MTTDProto.SpecialItem_FreeDiamond and bIsPurchasing then
    return self:GetDiamondTotalNum()
  end
  if iItemID == MTTDProto.SpecialItem_FreeDiamond then
    local freeDiamondNum = self.m_mSpecialItem[iItemID] or 0
    local negDiamondNum = self.m_mSpecialItem[MTTDProto.SpecialItem_NegDiamond] or 0
    return freeDiamondNum - negDiamondNum
  end
  if self.m_mSpecialItem[iItemID] ~= nil then
    return self.m_mSpecialItem[iItemID]
  end
  if self.m_mUniqueItem[iItemID] ~= nil then
    local expireTime = self.m_mUniqueItem[iItemID]
    if expireTime == nil or expireTime < 0 then
      return 0
    end
    if expireTime == 0 then
      return 1
    end
    local serverTime = TimeUtil:GetServerTimeS()
    if expireTime < serverTime then
      return 0
    end
    return 1
  end
  local num = 0
  for i, stItemInfo in pairs(self.m_vItemList) do
    if stItemInfo.iBaseId == iItemID then
      num = num + stItemInfo.iNum
    end
  end
  return num
end

function ItemManager:GetItemExpireTime(itemID)
  if not itemID then
    return
  end
  if self.m_mUniqueItem[itemID] ~= nil then
    return self.m_mUniqueItem[itemID]
  end
end

function ItemManager:RequestItemUse(iID, iNum, stItemUseData)
  local function OnItemUseSC(stItemUseSC, msg)
    self:broadcastEvent("eGameEvent_Item_Use", {
      iID = iID,
      
      iNum = iNum,
      ItemUseSC = stItemUseSC
    })
    self:CheckFragmentCertainRedPoint()
  end
  
  local stItemUseCS = MTTDProto.Cmd_Item_Use_CS()
  stItemUseCS.iItemBaseId = iID
  stItemUseCS.iNum = iNum
  if stItemUseData then
    stItemUseCS.stItemUseData = stItemUseData
  end
  RPCS():Item_Use(stItemUseCS, OnItemUseSC)
end

function ItemManager:IsItemAddNumOverMaxNum(itemID, itemAddNum)
  if not itemID then
    return
  end
  itemAddNum = itemAddNum or 0
  local curNum = self:GetItemNum(itemID)
  local afterAddNum = curNum + itemAddNum
  local itemCfg = CData_ItemInstance:GetValue_ByItemID(itemID)
  if itemCfg then
    local maxItemNum = itemCfg.m_ItemMaxNum
    return 0 < maxItemNum and afterAddNum > maxItemNum or false
  end
end

function ItemManager:GetItemConfigById(itemID)
  local itemCfg = CData_ItemInstance:GetValue_ByItemID(itemID)
  if itemCfg:GetError() then
    log.error("ItemManager GetItemConfigById itemID  " .. tostring(itemID))
    return
  end
  return itemCfg
end

local itemIconPrePath = "Atlas_Item/"

function ItemManager:GetItemIconPathByID(itemID)
  if not itemID then
    return
  end
  local itemCfg = self:GetItemConfigById(itemID)
  if not itemCfg then
    return
  end
  return itemIconPrePath .. itemCfg.m_IconPath
end

function ItemManager:GetItemName(itemID)
  if not itemID then
    return
  end
  local itemCfg = self:GetItemConfigById(itemID)
  if not itemCfg then
    return
  end
  return itemCfg.m_mItemName
end

function ItemManager:CheckFragmentCertainRedPoint()
  local itemList = self:GetItemListBySubType(ItemManager.ItemSubType.FragmentCertain)
  local canSynthesisIdList = {}
  for i, v in ipairs(itemList) do
    local itemCfg = self:GetItemConfigById(v.iID)
    local itemUseInfo = string.split(itemCfg.m_ItemUse, ":")
    local iOneCount = tonumber(itemUseInfo[2])
    local iMaxNum = math.floor(v.iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      canSynthesisIdList[#canSynthesisIdList + 1] = v.iID
    end
  end
  local itemList1 = self:GetItemListBySubType(ItemManager.ItemSubType.FragmentRandom)
  for i, v in ipairs(itemList1) do
    local itemCfg = self:GetItemConfigById(v.iID)
    local itemUseInfo = string.split(itemCfg.m_ItemUse, ":")
    local iOneCount = tonumber(itemUseInfo[2])
    local iMaxNum = math.floor(v.iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      canSynthesisIdList[#canSynthesisIdList + 1] = v.iID
    end
  end
  local itemList2 = self:GetItemListBySubType(ItemManager.ItemSubType.FragmentDeduplicatedRandom)
  for i, v in ipairs(itemList2) do
    local itemCfg = self:GetItemConfigById(v.iID)
    local iOneCount = tonumber(itemCfg.m_ItemUse)
    local iMaxNum = math.floor(v.iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      canSynthesisIdList[#canSynthesisIdList + 1] = v.iID
    end
  end
  local allItemList = self:GetAllItemList()
  for i, v in ipairs(allItemList) do
    local redFlag = self:CheckImportantItemShowRedPoint(v.iID)
    if 0 < redFlag then
      canSynthesisIdList[#canSynthesisIdList + 1] = v.iID
    end
  end
  if canSynthesisIdList then
    self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
      redDotKey = RedDotDefine.ModuleType.BagTab1,
      count = #canSynthesisIdList
    })
  end
  return 0 < #canSynthesisIdList, canSynthesisIdList
end

function ItemManager:SetImportantItemShowRedPoint(itemId, flag, in_bag)
  local changeFlag = false
  if itemId and ResourceUtil:GetResourceTypeById(itemId) ~= ResourceUtil.RESOURCE_TYPE.EQUIPS then
    local m_RedDotwhileGain = self:CheckImportantItemRedDotWhileGain(itemId)
    if m_RedDotwhileGain == 1 or flag == 0 then
      if in_bag then
        local itemRed = LocalDataManager:GetIntSimple("Item_Red_ID_" .. itemId, 0)
        LocalDataManager:SetIntSimple("Item_Red_ID_" .. itemId, flag)
        if itemRed ~= flag then
          self:CheckFragmentCertainRedPoint()
          changeFlag = true
        end
      else
        LocalDataManager:SetIntSimple("Item_Red_ID_" .. itemId, flag)
      end
    end
  end
  return changeFlag
end

function ItemManager:CheckImportantItemShowRedPoint(itemId)
  if itemId then
    local num = self:GetItemNum(itemId)
    if num == 0 then
      return 0
    end
    local itemRed = LocalDataManager:GetIntSimple("Item_Red_ID_" .. itemId, 0)
    return itemRed
  end
  return 0
end

function ItemManager:CheckImportantItemRedDotWhileGain(itemId)
  if itemId then
    local itemCfg = self:GetItemConfigById(itemId)
    if itemCfg then
      return itemCfg.m_RedDotwhileGain
    end
  end
  return 0
end

function ItemManager:CheckFragmentCertainRedPointById(itemId, iNum)
  local flag = 0
  local itemCfg = self:GetItemConfigById(itemId)
  if itemCfg.m_ItemSubType == ItemManager.ItemSubType.FragmentCertain and 0 < iNum then
    local itemUseInfo = string.split(itemCfg.m_ItemUse, ":")
    local iOneCount = tonumber(itemUseInfo[2])
    local iMaxNum = math.floor(iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      flag = iMaxNum
    end
  elseif itemCfg.m_ItemSubType == ItemManager.ItemSubType.FragmentRandom and 0 < iNum then
    local itemUseInfo = string.split(itemCfg.m_ItemUse, ":")
    local iOneCount = tonumber(itemUseInfo[2])
    local iMaxNum = math.floor(iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      flag = iMaxNum
    end
  elseif itemCfg.m_ItemSubType == ItemManager.ItemSubType.FragmentDeduplicatedRandom then
    local iOneCount = tonumber(itemCfg.m_ItemUse)
    local iMaxNum = math.floor(iNum / iOneCount)
    if iMaxNum and 0 < iMaxNum then
      flag = iMaxNum
    end
  end
  return flag
end

return ItemManager
