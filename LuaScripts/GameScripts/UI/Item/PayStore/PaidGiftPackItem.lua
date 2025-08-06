local UIItemBase = require("UI/Common/UIItemBase")
local PaidGiftPackItem = class("PaidGiftPackItem", UIItemBase)

function PaidGiftPackItem:OnInit()
end

function PaidGiftPackItem:OnUpdate(dt)
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

function PaidGiftPackItem:OnFreshData()
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
  if self.m_pnl_free then
    self.m_pnl_free:SetActive(isFree)
    self.m_img_free:SetActive(isFree)
  end
  self.m_btn_buy:SetActive(not isFree)
  self.m_txt_giftnum:SetActive(not isFree)
  self.m_txt_titlegift:SetActive(not isFree)
  local buyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId)
  local numText = ""
  if 0 < config.iLimitNum then
    local v = config.iLimitNum - buyTimes
    if v < 0 then
      v = 0
    end
    numText = string.format(ConfigManager:GetCommonTextById(20047), v, config.iLimitNum)
  end
  if isFree then
    self.m_txt_giftnum_free_Text.text = numText
  else
    self.m_txt_giftnum_Text.text = numText
  end
  if config.sGoodsPic ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, config.sGoodsPic)
  end
  self.m_img_soldoutmask:SetActive(buyTimes >= config.iLimitNum and 0 < config.iLimitNum)
  self.m_count_mask:SetActive(buyTimes >= config.iLimitNum and 0 < config.iLimitNum)
  if isFree then
    self.m_txt_price_free_Text.text = ConfigManager:GetCommonTextById(20041)
    self.m_txt_titlegift_free_Text.text = payStoreActivity:getLangText(config.sGoodsName)
  else
    self.m_txt_price_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
    self.m_txt_titlegift_Text.text = payStoreActivity:getLangText(config.sGoodsName)
  end
  local discount = config.iDiscount
  if 0 < discount then
    UILuaHelper.SetActive(self.m_bg_magnification, true)
    local showText = tonumber(discount) .. "%"
    self.m_txt_magnification_Text.text = tostring(showText)
  else
    UILuaHelper.SetActive(self.m_bg_magnification, false)
    self.m_count_mask:SetActive(false)
  end
  self.m_img_recommend:SetActive(config.iRecommend and config.iRecommend == 1)
  local bHaveExtraReward = config.vRewardExt and 0 < #config.vRewardExt
  if self.m_img_bg_gift then
    self.m_img_bg_gift:SetActive(bHaveExtraReward)
    if bHaveExtraReward then
      self.m_txt_extranum_Text.text = config.vRewardExt[1].iNum
    end
  end
  if self.m_pnl_itemgift then
    local itemRoot = self.m_pnl_itemgift.transform
    local count = #config.vReward
    local exTraRewardIndex = 0
    local pointRewardIndex = 0
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

function PaidGiftPackItem:UpdateChildCount(transform, count)
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

function PaidGiftPackItem:OnIconboxClicked()
  self:OnBtnbuyClicked()
end

function PaidGiftPackItem:OnBtnbuyfreeClicked()
  self:OnBtnbuyClicked()
end

function PaidGiftPackItem:OnBtnbuyClicked()
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
  if config.iStoreType == MTTDProto.CmdActPayStoreType_Permanent then
    local param = {
      Name = payStoreActivity:getLangText(config.sGoodsName),
      Desc = payStoreActivity:getLangText(config.sGoodsDesc),
      Icon = config.sGoodsPic,
      PriceText = IAPManager:GetProductPrice(config.sProductId, true),
      Reward = rewardList,
      ProductInfo = {
        productId = config.sProductId,
        productSubId = config.iProductSubId,
        StoreID = config.iStoreId,
        GoodsID = config.iGoodsId,
        iStoreType = MTTDProto.IAPStoreType_ActPayStore,
        GiftPackType = 1,
        rewardList = rewardList
      }
    }
    if config.sProductId == "" then
      param.PriceText = ConfigManager:GetCommonTextById(20041)
    end
    StackPopup:Push(UIDefines.ID_FORM_FIXEDGIFTWINDOW, param)
    return
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

return PaidGiftPackItem
