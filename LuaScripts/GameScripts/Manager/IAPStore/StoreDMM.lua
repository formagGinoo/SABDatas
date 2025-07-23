local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreDMM = class("StoreDMM", StoreBase)

function StoreDMM:OnCreate()
end

function StoreDMM:InitStore()
  log.info("StoreDMM:InitStore")
  CS.DMMSDKManger.Instance:InitializeStore(function(success, result)
    if success then
      log.info("StoreDMM:InitStore success")
    else
      log.error("StoreDMM:InitStore failed", result)
    end
  end, function(result)
    self:OnDetectUnConfirmedReception(result)
  end)
  self.productCallbacks = {}
end

function StoreDMM:QueryProductsDetail()
  log.info("StoreDMM:InitStore m_sProductList type:", type(self.m_sProductList))
  log.info("StoreDMM:InitStore m_sProductList length:", #self.m_sProductList)
  log.info("StoreDMM:InitStore products:", self.m_sProductList)
end

function StoreDMM:GetProductPrice(productId, withCurrency)
  local product = self.m_mProductList[productId]
  print("productId", productId)
  if product then
    print(productId .. "product.m_DmmPoint", product.m_DmmPoint)
    return product.m_DmmPoint .. "Pt"
  end
end

function StoreDMM:RealPay(productId, productSubId, exParam, OnSdkCallback)
  CS.DMMSDKManger.Instance:Purchase(productId)
  self.productCallbacks[productId] = OnSdkCallback
end

function StoreDMM:OnDetectUnConfirmedReception(result)
  log.info("result type:", type(result))
  local resultTable = json.decode(result)
  for k, v in pairs(resultTable) do
    if type(v) == "table" then
      log.info(string.format("result key: %s, value: [table], type: %s", k, type(v)))
    else
      log.info(string.format("result key: %s, value: %s, type: %s", k, tostring(v), type(v)))
    end
  end
  local success = resultTable.success
  log.info(string.format("OnDetectUnConfirmedReception success: %s, type: %s", tostring(success), type(success)))
  if success then
    if type(resultTable.inAppPurchaseData) == "table" then
      log.info("Purchase data: [table]")
    else
      log.info("Purchase data:", resultTable.inAppPurchaseData)
    end
    self:OnGetReceipt(resultTable, function(isSuccess, param1, param2)
      if isSuccess then
        log.info("iReceiptStatus:" .. tostring(param1.iReceiptStatus))
        if param1.iReceiptStatus == MTTDProto.IAPDmmReceiptStatus_Delivered then
          log.info("DMM渠道，消费商品::" .. tostring(param1.sProductId))
          CS.DMMGameStoreManager.Instance:ConsumeRecept(param1.sProductId)
        end
      else
        IAPManager:OnCallbackFail(param1, param2)
      end
      if self.productCallbacks[resultTable.productId] then
        self.productCallbacks[resultTable.productId](isSuccess, param1, param2)
        self.productCallbacks[resultTable.productId] = nil
      end
    end)
  else
    IAPManager:RemoveProductBuying(resultTable.productId)
    log.error("Purchase failed:", resultTable.failureReason, resultTable.failureMessage)
    if self.productCallbacks[resultTable.productId] then
      self.productCallbacks[resultTable.productId](success, resultTable.failureReason, resultTable.failureMessage)
      self.productCallbacks[resultTable.productId] = nil
    end
  end
end

function StoreDMM:OnGetReceipt(result, onSdkCallback)
  local msg = MTTDProto.Cmd_Store_IAP_Deliver_DMM_CS()
  local jsonData = json.decode(result.inAppPurchaseData)
  msg.sPurchaseToken = jsonData.purchaseToken
  msg.sOrderId = jsonData.orderId
  msg.sProductId = jsonData.productId
  msg.iPrice = jsonData.price
  msg.iPriceAmountMicros = jsonData.priceAmountMicros
  msg.sPriceCurrencyCode = jsonData.priceCurrencyCode
  msg.quantity = jsonData.quantity
  msg.purchaseTime = jsonData.purchaseTime
  msg.purchaseState = jsonData.purchaseState
  msg.developerPayload = jsonData.developerPayload
  msg.sInAppPurchaseData = result.inAppPurchaseData
  msg.sInAppDataSignature = result.inAppDataSignature
  log.info(result.inAppPurchaseData)
  log.info(result.inAppDataSignature)
  local loginContext = CS.LoginContext.GetContext()
  msg.iZoneId = loginContext.CurZoneInfo.iZoneId
  msg.iUid = loginContext.AccountID
  
  local function OnRequestSuccessCB(sc, msg)
    log.info("Cmd_Store_Request_IAPBuy_CS success")
    if onSdkCallback then
      onSdkCallback(true, sc)
    end
  end
  
  local function OnRequestFailedCB(msg)
    log.error("Cmd_Store_Request_IAPBuy_CS failed, rspCode:" .. msg.rspcode)
    if onSdkCallback then
      onSdkCallback(false, "network", msg)
    end
  end
  
  local function OnRequestTimeoutCB()
    log.error("Cmd_Store_Request_IAPBuy_CS timeout")
  end
  
  RPCS():Store_IAP_Deliver_DMM(msg, OnRequestSuccessCB, OnRequestFailedCB, OnRequestTimeoutCB)
end

function StoreDMM:GetIAPReceiptType()
  return MTTDProto.IAPReceiptType_DMM
end

function StoreDMM:OnCallbackFail()
end

function StoreDMM:EnableCheckValid()
  return true
end

function StoreDMM:GetStoreType()
  return StoreType.DMM
end

return StoreDMM
