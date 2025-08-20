local Form_Recharge = class("Form_Recharge", require("UI/UIFrames/Form_RechargeUI"))

function Form_Recharge:SetInitParam(param)
end

function Form_Recharge:AfterInit()
  self.super.AfterInit(self)
end

function Form_Recharge:OnActive()
  self.super.OnActive(self)
  self.m_itemData = self.m_csui.m_param
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity == nil then
    return
  end
  self.m_multiColor = self.m_txt_coupon:GetComponent("MultiColorChange")
  local root_trans = self.m_csui.m_uiGameObject.transform
  local resourceBarRoot = root_trans:Find("m_coupon_resource").gameObject
  local config = self.m_itemData
  self.m_btn_recharge:SetActive(false)
  self.m_pnl_coupon:SetActive(false)
  self.m_coupon_resource:SetActive(false)
  local curWelfareNum = ItemManager:GetItemNum(MTTDProto.SpecialItem_Welfare)
  local curProductWelfarePrice = IAPManager:GetProductWelfarePrice(config.sProductId)
  self.m_enough = tonumber(curWelfareNum) >= tonumber(curProductWelfarePrice)
  if self.m_enough or ActivityManager:OnCheckVoucherControlAndUrl() then
    local resourceBarList = {
      MTTDProto.SpecialItem_Welfare
    }
    self.m_btn_coupon:SetActive(self.m_enough)
    if ActivityManager:OnCheckVoucherControlAndUrl() then
      self.m_btn_recharge:SetActive(not self.m_enough)
    end
    self.m_coupon_resource:SetActive(true)
    self.m_pnl_coupon:SetActive(self.m_enough or ActivityManager:OnCheckVoucherControlAndUrl())
    self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot, resourceBarList)
    self.m_txt_coupon_Text.text = tostring(curProductWelfarePrice)
    self.m_multiColor:SetColorByIndex(self.m_enough and 0 or 1)
  end
  self.m_txt_upgrade_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
  self.m_txt_name_Text.text = payStoreActivity:getLangText(config.sGoodsName)
  local defaultCount = 0
  if 0 < #config.vReward then
    defaultCount = config.vReward[1].iNum
  end
  local externCount = defaultCount
  local isFirstBuy = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId) == 0
  if not isFirstBuy then
    externCount = 0
    if 0 < #config.vRewardExt then
      externCount = config.vRewardExt[1].iNum
    end
  end
  local purchaseItemData = ResourceUtil:GetProcessRewardData({
    iID = MTTDProto.SpecialItem_Diamond,
    iNum = defaultCount
  })
  self.m_txt_desc2_Text.text = purchaseItemData.description
  self.goodsDesText = purchaseItemData.description
  local purchaseItem = self.m_item_group.transform:Find("item_purchase")
  if purchaseItem then
    UILuaHelper.BindButtonClickManual(self, self.m_btn_purchaseItem_Button, function()
      utils.openItemDetailPop({
        iID = MTTDProto.SpecialItem_Diamond,
        iNum = defaultCount
      })
    end)
    self.m_txt_title_pur_Text.text = purchaseItemData.name
    self.m_txt_num1_Text.text = tostring(defaultCount)
    UILuaHelper.SetAtlasSprite(self.m_icon_item1_Image, purchaseItemData.icon_name, function()
      self.m_icon_item1.gameObject:SetActive(true)
    end)
  end
  local externItem = self.m_item_group.transform:Find("item_double")
  if externItem then
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = MTTDProto.SpecialItem_FreeDiamond,
      iNum = externCount
    })
    UILuaHelper.BindButtonClickManual(self, self.m_btn_doubleItem_Button, function()
      utils.openItemDetailPop({
        iID = MTTDProto.SpecialItem_FreeDiamond,
        iNum = externCount
      })
    end)
    self.m_txt_title_double_Text.text = processItemData.name
    self.m_txt_num2_Text.text = tostring(externCount)
    UILuaHelper.SetAtlasSprite(self.m_icon_item2_Image, processItemData.icon_name, function()
      self.m_icon_item2.gameObject:SetActive(true)
    end)
    self.m_pnl_firstrecharge:SetActive(isFirstBuy)
    self.m_pnl_otherrecharge:SetActive(not isFirstBuy)
  end
  self:OnRefreshGiftPoint()
end

function Form_Recharge:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Recharge:OnBtnupgradeClicked()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity == nil then
    return
  end
  local config = self.m_itemData
  local baseStoreBuyParam = MTTDProto.CmdActPayStoreBuyParam()
  baseStoreBuyParam.iStoreId = config.iStoreId
  baseStoreBuyParam.iGoodsId = config.iGoodsId
  baseStoreBuyParam.iActivityId = payStoreActivity:getID()
  local storeParam = sdp.pack(baseStoreBuyParam)
  local ProductInfo = {
    StoreID = config.iStoreId,
    GoodsID = config.iGoodsId,
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPayStore,
    productName = payStoreActivity:getLangText(config.sGoodsName),
    productDesc = payStoreActivity:getLangText(config.sGoodsName),
    iActivityId = payStoreActivity:getID()
  }
  IAPManager:BuyProductByStoreTypeRe(ProductInfo, storeParam, handler(self, self.OnBuyResult))
end

function Form_Recharge:OnBuyResult(isSuccess, param1, param2)
  if not isSuccess then
    IAPManager:OnCallbackFail(param1, param2)
    return
  end
  self:CloseForm()
end

function Form_Recharge:OnBtnreturnClicked()
  self:CloseForm()
end

function Form_Recharge:OnImgbgcloseClicked()
  self:CloseForm()
end

function Form_Recharge:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  local productId = self.m_itemData.sProductId
  if not productId then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(self.m_itemData.sProductId)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    self.m_packgift_point:SetActive(true)
    if self.m_paidGiftPoint then
      self.m_paidGiftPoint:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point, pointParams)
    end
  else
    self.m_packgift_point:SetActive(false)
  end
end

function Form_Recharge:OnBtncouponClicked()
  if self.m_enough then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    if payStoreActivity == nil then
      return
    end
    local config = self.m_itemData
    local baseStoreBuyParam = MTTDProto.CmdActPayStoreBuyParam()
    baseStoreBuyParam.iStoreId = config.iStoreId
    baseStoreBuyParam.iGoodsId = config.iGoodsId
    baseStoreBuyParam.iActivityId = payStoreActivity:getID()
    local storeParam = sdp.pack(baseStoreBuyParam)
    local ProductInfo = {
      StoreID = config.iStoreId,
      GoodsID = config.iGoodsId,
      productId = config.sProductId,
      productSubId = config.iProductSubId,
      iStoreType = MTTDProto.IAPStoreType_ActPayStore,
      productName = payStoreActivity:getLangText(config.sGoodsName),
      productDesc = payStoreActivity:getLangText(config.sGoodsName),
      iActivityId = payStoreActivity:getID()
    }
    IAPManager:BuyProductByStoreTypeRe(ProductInfo, storeParam, handler(self, self.OnBuyResult), true)
  end
end

function Form_Recharge:OnBtnrechargeClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1030,
    func1 = function()
      local iShow, url = ActivityManager:OnCheckVoucherControlAndUrl()
      if iShow and url then
        CS.DeviceUtil.OpenURLNew(url)
      end
    end
  })
end

function Form_Recharge:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Recharge", Form_Recharge)
return Form_Recharge
