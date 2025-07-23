local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreMSDKPc = class("StoreMSDKPc", StoreBase)

function StoreMSDKPc:OnCreate()
  log.info("StoreMSDKPc:OnCreate")
end

function StoreMSDKPc:InitStore(callback)
  CS.UICachedImageLoader.savedBasePath = CS.MUF.Resource.ResourceLocationHelper.Instance.PersistentDataPath
  CS.MSDKPay.Instance:PaymentInit(function(isSuccess)
    if isSuccess then
      CS.MSDKPay.Instance.createRoleCountry = self:GetCreateRoleCountry()
      self.m_needQuery = true
      if self.m_sProductList then
        self:QueryProductsDetail()
      end
      if callback then
        callback(true)
      end
    elseif callback then
      callback(false)
    end
  end)
end

function StoreMSDKPc:OnAfterFreshData()
  self.m_suffix = ""
  local areaId = CS.VersionContext.GetContext().AreaId
  if areaId ~= nil then
    local cfg = ConfigManager:GetConfigInsByName("RegionMapping"):GetValue_ByAreaID(areaId)
    if not cfg:GetError() then
      self.m_suffix = cfg.m_MappingID
    end
  end
end

function StoreMSDKPc:GetCreateRoleCountry()
  return RoleManager:GetLoginRoleCountry()
end

function StoreMSDKPc:GetProductInfo(productId)
  return CS.MSDKPay.Instance:GetProductInfoPc(productId .. self.m_suffix)
end

function StoreMSDKPc:QueryProductsDetail(callback)
  if callback then
    self.m_queryCallback = callback
  end
  if self.m_needQuery then
    local _sProductList
    if self.m_suffix ~= "" then
      local vProductList = string.split(self.m_sProductList, ",")
      local vProductListWithSuffix = {}
      for i = 1, #vProductList do
        vProductListWithSuffix[i] = vProductList[i] .. self.m_suffix
      end
      _sProductList = table.concat(vProductListWithSuffix, ",")
    else
      _sProductList = self.m_sProductList
    end
    CS.MSDKPay.Instance:QueryProductsDetailPc(_sProductList, function(isSuccess, skuInfos, code, message)
      if isSuccess then
        self.m_needQuery = false
      end
      if self.m_queryCallback then
        self.m_queryCallback(isSuccess)
      end
    end)
  end
end

function StoreMSDKPc:GetProductPrice(productId, withCurrency)
  return CS.MSDKPay.Instance:GetProductPricePc(productId .. self.m_suffix, withCurrency, true)
end

function StoreMSDKPc:GetProductDetailInfo(productId, callback)
  CS.MSDKPay.Instance:GetProductInfoDetailPc(productId .. self.m_suffix, callback)
end

function StoreMSDKPc:RealPay(productId, productSubId, exParam, OnSdkCallback)
  local productInfo = self:GetProductInfo(productId)
  if productInfo then
    CS.Form_Waiting.Show(true)
    self:GetProductDetailInfo(productId, function(isGetSuccess, detailInfo)
      CS.Form_Waiting.Hide()
      if isGetSuccess then
        local priceInfo = CS.MSDKPay.Instance:GetPriceInfoPc(productId .. self.m_suffix)
        StackTop:Push(UIDefines.ID_FORM_TRIPARTITEPAYMENT, {
          detailInfo = detailInfo,
          skuInfo = productInfo,
          priceInfo = priceInfo,
          callback = function(isCancel, channelInfo)
            if isCancel then
              OnSdkCallback(false, "message", 56001)
              return
            end
            CS.MSDKPay.Instance:BuyProductPc(productId .. self.m_suffix, tostring(productSubId), channelInfo.price_local_sell, channelInfo.direct_channel, productInfo.currency, channelInfo.price_local_sell_show, function(isSuccess, payId, code, message)
              if isSuccess then
                OnSdkCallback(true, "msdk", {
                  order = payId,
                  code = code,
                  message = message
                })
              else
                OnSdkCallback(false, "msdk", {
                  order = payId,
                  code = code,
                  message = message
                })
              end
            end)
          end
        })
      else
        OnSdkCallback(false, "message", 56002)
      end
    end)
  else
    OnSdkCallback(false, "message", 56003)
  end
end

function StoreMSDKPc:Report()
end

function StoreMSDKPc:OnCallback()
  log.error("StoreMSDKPc:OnCallbackFail")
end

function StoreMSDKPc:GetIAPReceiptType()
  return MTTDProto.IAPReceiptType_MSDK
end

function StoreMSDKPc:GetStoreType()
  return StoreType.MSDKPc
end

return StoreMSDKPc
