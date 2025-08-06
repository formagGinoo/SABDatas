local UIItemBase = require("UI/Common/UIItemBase")
local StepPaidGiftPackItem = class("StepPaidGiftPackItem", UIItemBase)

function StepPaidGiftPackItem:OnInit()
end

function StepPaidGiftPackItem:OnUpdate(dt)
  if self.enableUpdateCheck then
    local delalyActiveTime = self.m_itemData.delalyActiveTime
    if delalyActiveTime and delalyActiveTime <= 0 then
      self:SetActive(true)
      UILuaHelper.PlayAnimationByName(self:GetItemRootObj(), nil)
      self.enableUpdateCheck = false
    else
    end
  end
end

function StepPaidGiftPackItem:OnFreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local config = self.m_itemData
  local delalyActiveTime = config.delalyActiveTime
  if delalyActiveTime and 0 < delalyActiveTime then
    self.enableUpdateCheck = true
    self:SetActive(false)
  else
    self.enableUpdateCheck = false
    self:SetActive(true)
    UILuaHelper.ResetAnimationByName(self:GetItemRootObj(), nil, -1)
    UILuaHelper.PlayAnimationByName(self:GetItemRootObj(), nil)
  end
  local isFree = config.sProductId == ""
  if self.m_itemIndex == 1 then
    self.m_pnl_arror:SetActive(false)
  else
    self.m_pnl_arror:SetActive(true)
  end
  if config.sGoodsPic ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, config.sGoodsPic)
  end
  self.m_txt_giftname_Text.text = payStoreActivity:getLangText(config.sGoodsName)
  UILuaHelper.SetActive(self.m_img_select, false)
  self.m_img_soldoutmask:SetActive(config.m_Sellout)
  self.m_count_mask:SetActive(false)
  if config.m_Sellout then
    self.m_txt_price:SetActive(false)
    if 0 < tonumber(config.iDiscount) then
      self.m_count_mask:SetActive(true)
    end
  else
    self.m_txt_price:SetActive(true)
    if isFree then
      self.m_txt_price_Text.text = ConfigManager:GetCommonTextById(20041)
    else
      self.m_txt_price_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
    end
  end
  if 0 < tonumber(config.iDiscount) then
    UILuaHelper.SetActive(self.m_bg_magnification, true)
    local showText = tonumber(config.iDiscount) .. "%"
    self.m_txt_magnification_Text.text = tostring(showText)
  else
    UILuaHelper.SetActive(self.m_bg_magnification, false)
  end
  self.m_img_block:SetActive(config.isBlockBuy)
  self.m_txt_lock:SetActive(config.isBlockBuy)
  if config.isBlockBuy then
    if isFree then
      self.m_txt_lock_Text.text = ConfigManager:GetCommonTextById(20041)
    else
      self.m_txt_lock_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
    end
  end
  self.m_txt_price:SetActive(not config.isBlockBuy and not config.m_Sellout)
  self.m_pnl_stock:SetActive(not config.m_Sellout)
  self.m_img_arror2:SetActive(config.isBlockBuy or config.m_Sellout)
  self.m_img_normal:SetActive(not config.isBlockBuy)
  self.m_img_arror1:SetActive(not config.isBlockBuy and not config.m_Sellout)
  self.m_img_select:SetActive(not config.isBlockBuy and not config.m_Sellout)
  self.m_uifx_loop:SetActive(not config.isBlockBuy and not config.m_Sellout)
  self.m_uifx_box_loop:SetActive(not config.isBlockBuy and not config.m_Sellout)
  local itemRoot = self.m_pnl_itemgift.transform
  local count = #config.vReward
  local pointRewardIndex = 0
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(config.sProductId)
  if isShowPoint then
    count = count + 1
    pointRewardIndex = count - 1
  end
  self:UpdateChildCount(itemRoot, count)
  for i, v in ipairs(config.vReward) do
    local itemObj = itemRoot:GetChild(i - 1).gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = v.iID,
      iNum = v.iNum
    })
    common_item:SetItemInfo(processItemData)
  end
  if isShowPoint then
    local itemObj = itemRoot:GetChild(pointRewardIndex).gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = pointReward.iID,
      iNum = pointReward.iNum
    })
    common_item:SetItemInfo(processItemData)
  end
end

function StepPaidGiftPackItem:UpdateChildCount(transform, count)
  local childCount = transform.childCount
  if count > childCount then
    local itemInstance = transform:GetChild(0)
    for i = 1, count - childCount do
      GameObject.Instantiate(itemInstance, transform)
    end
    childCount = count
  end
  for i = 1, childCount do
    local child = transform:GetChild(i - 1)
    child.gameObject:SetActive(count >= i)
  end
end

function StepPaidGiftPackItem:OnIconboxClicked()
  self:OnBtnbuyClicked()
end

function StepPaidGiftPackItem:OnBtnbuyClicked()
  local config = self.m_itemData
  if config.isBlockBuy then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 52003)
    return
  end
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local buyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId)
  if buyTimes >= config.iLimitNum and config.iLimitNum > 0 then
    return
  end
  local rewardList = {}
  for i, v in ipairs(config.vReward) do
    table.insert(rewardList, v)
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(config.sProductId)
  if isShowPoint then
    table.insert(rewardList, pointReward)
  end
  local ProductInfo = {
    StoreID = config.iStoreId,
    GoodsID = config.iGoodsId,
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPayStore,
    productName = payStoreActivity:getLangText(config.sGoodsName),
    productDesc = payStoreActivity:getLangText(config.sGoodsDesc),
    iActivityId = payStoreActivity:getID(),
    GiftPackType = 1,
    rewardList = rewardList
  }
  IAPManager:BuyProductByStoreType(ProductInfo, nil, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

return StepPaidGiftPackItem
