local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreMSDK = class("StoreMSDK", StoreBase)

function StoreMSDK:OnCreate()
  log.info("StoreMSDK:OnCreate")
end

function StoreMSDK:InitStore(callback)
  CS.MSDKPay.Instance:PaymentInit(function(isSuccess)
    if isSuccess then
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

function StoreMSDK:OnAfterFreshData()
  self.m_suffix = ""
  local areaId = CS.VersionContext.GetContext().AreaId
  if areaId ~= nil then
    local cfg = ConfigManager:GetConfigInsByName("RegionMapping"):GetValue_ByAreaID(areaId)
    if not cfg:GetError() then
      self.m_suffix = cfg.m_MappingID
    end
  end
end

function StoreMSDK:GetProductInfo(productId)
  return CS.MSDKPay.Instance:GetProductInfo(productId .. self.m_suffix)
end

function StoreMSDK:QueryProductsDetail(callback)
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
    CS.MSDKPay.Instance:QueryProductsDetail(_sProductList, function(isSuccess)
      if isSuccess then
        self.m_needQuery = false
      end
      if self.m_queryCallback then
        self.m_queryCallback(isSuccess)
      end
    end)
  end
end

function StoreMSDK:GetProductPrice(productId, withCurrency)
  local productInfo = self:GetProductInfo(productId)
  if productInfo then
    if withCurrency then
      return productInfo.formatPrice
    else
      return productInfo.productPrice
    end
  end
end

function StoreMSDK:RealPay(productId, productSubId, exParam, OnSdkCallback)
  CS.MSDKPay.Instance:BuyProduct(productId .. self.m_suffix, tostring(productSubId), function(isSuccess, order, message)
    if isSuccess then
      OnSdkCallback(true, "msdk", {order = order, message = message})
    else
      OnSdkCallback(false, "msdk", {order = order, message = message})
    end
  end)
end

function StoreMSDK:OnCallback()
  log.error("StoreMSDK:OnCallbackFail")
end

function StoreMSDK:GetIAPReceiptType()
  return MTTDProto.IAPReceiptType_MSDK
end

function StoreMSDK:GetStoreType()
  return StoreType.MSDK
end

return StoreMSDK
