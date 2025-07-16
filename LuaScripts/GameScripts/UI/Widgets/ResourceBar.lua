local ResourceBar = class("ResourceBar")
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local ItemIns = ConfigManager:GetConfigInsByName("Item")
local FreeCurrencyID = MTTDProto.SpecialItem_FreeDiamond
local RechargeCurrencyID = MTTDProto.SpecialItem_Diamond
local VirtualDiamondsID = MTTDProto.SpecialItem_ShowDiamond
local DefaultItemCfg = {
  {
    itemID = MTTDProto.SpecialItem_Coin
  },
  {itemID = VirtualDiamondsID}
}

function ResourceBar:ctor(goRoot, paramShowItemIDs)
  self.m_goRoot = goRoot
  self.m_rootTrans = self.m_goRoot.transform
  UILuaHelper.BindViewObjectsManual(self, self.m_goRoot, "ResourceBar")
  self.m_item_base = self.m_rootTrans:Find("m_item_root/item_base")
  UILuaHelper.SetActive(self.m_item_base, false)
  self:FreshShowItemDataList(paramShowItemIDs)
  self.m_item_list = {
    [1] = self:InitItem(self.m_item_base, 1)
  }
  self:FreshItemList()
  self:AddListener()
  self:SetBGActive()
end

function ResourceBar:OnUpdate(dt)
end

function ResourceBar:AddListener()
  self.m_handleId = EventCenter.AddListener(EventDefine.eGameEvent_Item_SetItem, handler(self, self.OnItemChange))
end

function ResourceBar:RemoveListener()
  if self.m_handleId then
    EventCenter.RemoveListener(EventDefine.eGameEvent_Item_SetItem, self.m_handleId)
    self.m_handleId = nil
  end
end

function ResourceBar:FreshShowItemDataList(paramShowItemIDs)
  local inputParams
  if paramShowItemIDs then
    inputParams = {}
    for _, paramID in ipairs(paramShowItemIDs) do
      inputParams[#inputParams + 1] = {itemID = paramID}
    end
  end
  self.m_showItemDataList = inputParams or DefaultItemCfg
end

function ResourceBar:FreshChangeItems(paramShowItemIDs)
  self:FreshShowItemDataList(paramShowItemIDs)
  self:FreshItemList()
end

function ResourceBar:FreshItemList()
  if not self.m_showItemDataList then
    return
  end
  local itemList = self.m_item_list
  local dataLen = #self.m_showItemDataList
  local parentTrans = self.m_item_root
  local childCount = #itemList
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local item = itemList[i]
      local itemData = self.m_showItemDataList[i]
      self:FreshItemData(item, itemData)
      UILuaHelper.SetActive(item.root, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_item_base, parentTrans.transform).gameObject
      local item = self:InitItem(itemObj, i)
      local itemData = self.m_showItemDataList[i]
      self:FreshItemData(item, itemData)
      itemList[#itemList + 1] = item
      UILuaHelper.SetActive(item.root, true)
    elseif i <= childCount and i > dataLen then
      local item = itemList[i]
      item.itemData = nil
      UILuaHelper.SetActive(item.root, false)
    end
  end
end

function ResourceBar:InitItem(itemObj, index)
  if not itemObj then
    return
  end
  local itemTrans = itemObj.transform
  local txt_num = itemTrans:Find("txt_item_num"):GetComponent(T_TextMeshProUGUI)
  local img_item_icon = itemTrans:Find("icon_item"):GetComponent(T_Image)
  local itemButton = itemTrans:GetComponent(T_Button)
  local bg_Image = itemTrans:Find("m_img_bk")
  local rechargeBtn = itemTrans:Find("m_btn_recharge")
  rechargeBtn = rechargeBtn and rechargeBtn:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, itemButton, function()
    self:OnItemClk(index)
  end)
  if rechargeBtn then
    UILuaHelper.BindButtonClickManual(self, rechargeBtn, function()
      self:OnItemRechargeClk(index)
    end)
  end
  local item = {
    itemData = nil,
    root = itemTrans,
    txt_num = txt_num,
    img_item_icon = img_item_icon,
    itemButton = itemButton,
    bg_Image = bg_Image and bg_Image.gameObject or nil,
    rechargeButton = rechargeBtn
  }
  return item
end

function ResourceBar:FreshItemData(item, itemData)
  if not item then
    return
  end
  if not itemData then
    return
  end
  item.itemData = itemData
  local itemNum = ItemManager:GetItemNum(itemData.itemID)
  if itemData.itemID == MTTDProto.SpecialItem_Welfare then
    item.txt_num.text = tostring(itemNum)
  else
    item.txt_num.text = BigNumFormat(itemNum)
  end
  local itemCfg = ItemIns:GetValue_ByItemID(itemData.itemID)
  if not itemCfg:GetError() then
    UILuaHelper.SetAtlasSprite(item.img_item_icon, "Atlas_Item/" .. itemCfg.m_IconPath)
  end
  local enbaleRechargBtn = false
  if itemData.itemID == RechargeCurrencyID or itemData.itemID == FreeCurrencyID or itemData.itemID == VirtualDiamondsID then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    if payStoreActivity and payStoreActivity:GetRechargeStoreID() ~= 0 then
      enbaleRechargBtn = true
    end
    local isSystemUnlock = UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuideDefeatJump)
    enbaleRechargBtn = enbaleRechargBtn and isSystemUnlock
  end
  if itemData.itemID == MTTDProto.SpecialItem_Welfare then
    local isShowAdd = ActivityManager:OnCheckVoucherControlAndUrl()
    if isShowAdd and item.rechargeButton then
      enbaleRechargBtn = true
    end
  end
  if item.rechargeButton then
    UILuaHelper.SetActive(item.rechargeButton, enbaleRechargBtn)
  end
end

function ResourceBar:GetItemIndex(itemID)
  if not itemID then
    return
  end
  for i, itemData in ipairs(self.m_showItemDataList) do
    if itemID == itemData.itemID then
      return i
    end
  end
end

function ResourceBar:OnItemChange(vItemChange)
  if not vItemChange then
    return
  end
  for _, itemChange in ipairs(vItemChange) do
    local itemIndex = self:GetItemIndex(itemChange.iID)
    if not itemIndex and (itemChange.iID == RechargeCurrencyID or itemChange.iID == FreeCurrencyID) then
      itemIndex = self:GetItemIndex(VirtualDiamondsID)
    end
    if itemIndex and self.m_item_list[itemIndex] then
      self:FreshItemData(self.m_item_list[itemIndex], self.m_showItemDataList[itemIndex])
    end
  end
end

function ResourceBar:OnItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local itemData = self.m_showItemDataList[itemIndex]
  if not itemData then
    return
  end
  local itemNum = ItemManager:GetItemNum(itemData.itemID)
  utils.openItemDetailPop({
    iID = itemData.itemID,
    iNum = itemNum
  })
end

function ResourceBar:OnItemRechargeClk(itemIndex)
  if not itemIndex then
    return
  end
  local itemData = self.m_showItemDataList[itemIndex]
  if not itemData then
    return
  end
  if itemData.itemID == RechargeCurrencyID or itemData.itemID == FreeCurrencyID or itemData.itemID == VirtualDiamondsID then
    QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
    EventCenter.Broadcast(EventDefine.eGameEvent_Item_Jump)
  end
  if itemData.itemID == MTTDProto.SpecialItem_Welfare then
    local isAdd, jumpUrl = ActivityManager:OnCheckVoucherControlAndUrl()
    if isAdd and jumpUrl then
      CS.DeviceUtil.OpenURLNew(jumpUrl)
    end
  end
end

function ResourceBar:SetBGActive(active)
  if self.m_item_list and next(self.m_item_list) then
    for _, itemNode in ipairs(self.m_item_list) do
      if itemNode.bg_Image then
        itemNode.bg_Image:SetActive(active)
      end
    end
  end
end

function ResourceBar:OnDestroy()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_goRoot, "ResourceBar")
  if self.m_item_list and next(self.m_item_list) then
    for _, itemNode in ipairs(self.m_item_list) do
      UILuaHelper.UnbindButtonClickManual(itemNode.itemButton)
      UILuaHelper.UnbindButtonClickManual(itemNode.rechargeButton)
    end
  end
  self:RemoveListener()
end

return ResourceBar
