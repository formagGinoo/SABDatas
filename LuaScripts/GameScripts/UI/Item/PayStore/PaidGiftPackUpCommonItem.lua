local UIItemBase = require("UI/Common/UIItemBase")
local PaidGiftPackUpCommonItem = class("PaidGiftPackUpCommonItem", UIItemBase)

function PaidGiftPackUpCommonItem:OnInit()
end

function PaidGiftPackUpCommonItem:OnUpdate(dt)
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

function PaidGiftPackUpCommonItem:OnFreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local config = self.m_itemData
  self.configType = config.configBg
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
  self:RefreshBg()
  self:RefreshIcon()
  self:RefreshPackName()
  self:RefreshLastBuyTimes()
  self:RefreshPriceAndBuyState()
  self:RefreshMagnification()
  self:RefreshReward()
end

function PaidGiftPackUpCommonItem:RefreshReward()
  local config = self.m_itemData
  if self.m_pnl_itemgift then
    local itemRoot = self.m_pnl_itemgift.transform
    local bHaveExtraReward = config.vRewardExt and #config.vRewardExt > 0
    local exTraRewardIndex = 0
    local pointRewardIndex = 0
    local count = #config.vReward
    if bHaveExtraReward then
      count = count + 1
      exTraRewardIndex = count - 1
    end
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
    if bHaveExtraReward then
      local itemObj = itemRoot:GetChild(exTraRewardIndex).gameObject
      local common_item = self:createCommonItem(itemObj)
      common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = config.vRewardExt[1].iID,
        iNum = config.vRewardExt[1].iNum
      })
      common_item:SetItemInfo(processItemData)
      common_item:SetGiftIcon(true)
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
end

function PaidGiftPackUpCommonItem:RefreshBg()
  self.m_img_buy:SetActive(false)
  UILuaHelper.SetAtlasSprite(self.m_img_buy_Image, self.configType.sGiftPackBasePlate, function()
    if self.m_img_buy then
      self.m_img_buy:SetActive(true)
    end
  end)
end

function PaidGiftPackUpCommonItem:RefreshIcon()
  local config = self.m_itemData
  if config.sGoodsPic ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, config.sGoodsPic)
  end
end

function PaidGiftPackUpCommonItem:RefreshPackName()
  local config = self.m_itemData
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  self.m_txt_titlegift_Text.text = payStoreActivity:getLangText(config.sGoodsName)
  self:SetTextColor(self.m_txt_titlegift_Text, config.configBg.sGiftPackNameTextColor)
end

function PaidGiftPackUpCommonItem:RefreshLastBuyTimes()
  local config = self.m_itemData
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local numText = ""
  local buyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId)
  if config.iLimitNum and config.iLimitNum > 0 then
    local v = config.iLimitNum - buyTimes
    if v < 0 then
      v = 0
    end
    self:RefreshSoldOutMask(v <= 0)
    numText = string.format(ConfigManager:GetCommonTextById(20047), v, config.iLimitNum)
  end
  self.m_txt_giftnum_Text.text = numText
  self:SetTextColor(self.m_txt_giftnum_Text, config.configBg.sStockTextColor)
end

function PaidGiftPackUpCommonItem:RefreshSoldOutMask(isShowSold)
  self.m_img_soldoutmask:SetActive(false)
  if isShowSold then
    self.m_img_soldoutmask:SetActive(true)
    UILuaHelper.SetAtlasSprite(self.m_img_soldout_Image, self.configType.sSoldOutPic, function()
      if self.m_img_soldout then
        self.m_img_soldout:SetActive(true)
      end
    end)
  end
end

function PaidGiftPackUpCommonItem:RefreshPriceAndBuyState()
  local config = self.m_itemData
  local isFree = config.sProductId == ""
  self.m_txt_price:SetActive(not isFree)
  self.m_txt_free:SetActive(isFree)
  if isFree then
    self.m_txt_free_Text.text = ConfigManager:GetCommonTextById(20041)
    self:SetTextColor(self.m_txt_free_Text, config.configBg.sPurchasePriceTextColor)
  else
    self.m_txt_price_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
    self:SetTextColor(self.m_txt_price_Text, config.configBg.sPurchasePriceTextColor)
  end
end

function PaidGiftPackUpCommonItem:SetTextColor(text, color)
  local _, color = CS.UnityEngine.ColorUtility.TryParseHtmlString(color)
  text.color = color
end

function PaidGiftPackUpCommonItem:RefreshMagnification()
  local config = self.m_itemData
  local discount = config.iDiscount
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  if 0 < discount then
    UILuaHelper.SetActive(self.m_bg_magnification, true)
    local showText = tonumber(discount) .. "%"
    self.m_txt_magnification_Text.text = tostring(showText)
    UILuaHelper.SetAtlasSprite(self.m_img_tag_act_Image, config.configBg.sValueForMoneyBaseImage)
    UILuaHelper.SetAtlasSprite(self.m_count_mask_Image, config.configBg.sValueForMoneyBaseImage)
    self:SetTextColor(self.m_txt_magnification_Text, config.configBg.sValueForMoneyTextColor)
    local buyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId)
    self.m_count_mask:SetActive(buyTimes >= config.iLimitNum and 0 < config.iLimitNum)
  else
    UILuaHelper.SetActive(self.m_bg_magnification, false)
    self.m_count_mask:SetActive(false)
  end
end

function PaidGiftPackUpCommonItem:UpdateChildCount(transform, count)
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

function PaidGiftPackUpCommonItem:OnIconboxClicked()
  self:OnBtnbuyClicked()
end

function PaidGiftPackUpCommonItem:OnBtnfreeClicked()
  self:OnBtnbuyClicked()
end

function PaidGiftPackUpCommonItem:OnBtnbuyClicked()
  local config = self.m_itemData
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
  if config.vRewardExt and 0 < #config.vRewardExt then
    table.insert(rewardList, config.vRewardExt[1])
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
    rewardList = rewardList
  }
  IAPManager:BuyProductByStoreType(ProductInfo, nil, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

return PaidGiftPackUpCommonItem
