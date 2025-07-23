local BaseManager = require("Manager/Base/BaseManager")
local IAPManager = class("IAPManager", BaseManager)
local json = require("common/json")

function IAPManager:OnCreate()
  self.m_productBuying = {}
  self.m_storeImpl = nil
end

function IAPManager:OnInitNetwork()
  if self.m_initNetwork == true then
    return
  end
  self.m_initNetwork = true
  RPCS():Listen_Push_IAPDelivery(handler(self, self.OnPushIAPDelivery), "IAPManager")
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  SROptionsModify.AddSROptionMethod("测试购买", function()
    local product = self.m_mProductList["com.moonton.diamond_test"]
    local data = {
      revenue = product.m_Price / 100,
      currency = "USD"
    }
    jsonData = json.encode(data)
    log.error("上报数据：" .. jsonData)
  end, "Debug", 0)
end

function IAPManager:OnAfterFreshData()
  self.m_storeImpl:OnAfterFreshData()
  self.m_storeImpl:ParseTable()
  self.m_storeImpl:QueryProductsDetail(function(isSuccess)
    if not isSuccess then
      self:RetryQueryProductsDetail()
    end
  end)
end

function IAPManager:RetryQueryProductsDetail()
  self.m_retryCount = (self.m_retryCount or 0) + 1
  if self.m_retryCount > 5 then
    log.error("IAPManager:RetryQueryProductsDetail failed after 5 attempts")
    return
  end
  local delayTime = 5 * self.m_retryCount
  TimeService:SetTimer(delayTime, 1, function()
    self.m_storeImpl:QueryProductsDetail(function(isSuccess)
      if not isSuccess then
        self:RetryQueryProductsDetail()
      end
    end)
  end)
end

function IAPManager:Initialize(callback)
  if ChannelManager:IsUsingQSDK() then
    self.m_storeImpl = require("Manager/IAPStore/StoreQSDK")
  elseif ChannelManager:IsDMMChannel() then
    self.m_storeImpl = require("Manager/IAPStore/StoreDMM")
  elseif ChannelManager:IsWindows() then
    self.m_storeImpl = require("Manager/IAPStore/StoreMSDKPc")
  elseif CS.UnityEngine.Application.isEditor then
    self.m_storeImpl = require("Manager/IAPStore/StoreEditor")
  else
    self.m_storeImpl = require("Manager/IAPStore/StoreMSDK")
  end
  self.m_storeImpl:InitStore(callback)
end

function IAPManager:GetProductPrice(productId, withCurrency)
  return self.m_storeImpl:GetProductPrice(productId, withCurrency)
end

function IAPManager:GetProductWelfarePrice(productId)
  return self.m_storeImpl:GetProductWelfarePrice(productId)
end

function IAPManager:BuyProduct(productId, productSubId, iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
  if self.m_purchaseDelay and self.m_purchaseDelay > 0 then
    log.error("购买延迟中，无法进行购买")
    return
  end
  self:RealBuyProduct(productId, productSubId, iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
end

function IAPManager:RemoveProductBuying(productId)
  self.m_productBuying[productId] = nil
end

function IAPManager:RealBuyProduct(productId, productSubId, iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
  if self.m_productBuying[productId] and self.m_storeImpl:EnableCheckValid() then
    log.error(tostring(productId) .. "商品正在购买中")
    if ChannelManager:IsIOS() and ChannelManager:IsUsingQSDK() then
      if self.m_autoReleaseDict == nil then
        self.m_autoReleaseDict = {}
      end
      if self.m_autoReleaseDict[productId] == nil then
        self.m_autoReleaseDict[productId] = 60
      end
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, "当前存在未完成订单，请1分钟后再次尝试")
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52006))
    end
    return
  end
  if self:GetStoreType() ~= StoreType.MSDKPc then
    self.m_productBuying[productId] = true
  end
  local msg = MTTDProto.Cmd_Store_Request_IAPBuy_CS()
  msg.sProductId = productId
  msg.iProductSubId = productSubId
  if isBuyWithWelfare then
    msg.iReceiptType = MTTDProto.IAPReceiptType_Welfare
  else
    msg.iReceiptType = self.m_storeImpl:GetIAPReceiptType()
  end
  msg.iStoreType = iStoreType
  msg.sStoreParam = storeParam
  if exParam and exParam.panelName then
    msg.sExtraData = exParam.panelName
  else
    msg.sExtraData = "Form_MallMainNew"
  end
  
  local function OnSdkCallback(isSuccess, param1, param2)
    if isSuccess then
      if ChannelManager:IsIOS() and self:GetStoreType() == StoreType.QSDK then
        self.m_purchaseDelay = 0.5
      end
      if not CS.UnityEngine.Application.isEditor then
        self.m_storeImpl:Report(productId)
      end
    else
      self.m_productBuying[productId] = nil
    end
    if callback then
      callback(isSuccess, param1, param2)
    end
  end
  
  local function OnRequestSuccessCB(sc, msg)
    exParam.cpOrderID = sc.sTraceFlowId
    if isBuyWithWelfare then
      self:OnBuyWithWelfare(productId, productSubId, exParam, iStoreType, storeParam, OnSdkCallback)
    else
      self.m_storeImpl:RealPay(productId, productSubId, exParam, OnSdkCallback)
    end
  end
  
  local function OnRequestFailedCB(msg)
    self.m_productBuying[productId] = nil
    log.error("Cmd_Store_Request_IAPBuy_CS failed, rspCode:" .. msg.rspcode)
    if callback then
      callback(false, "network", msg)
    end
  end
  
  local function OnRequestTimeoutCB()
    self.m_productBuying[productId] = nil
    log.error("Cmd_Store_Request_IAPBuy_CS timeout")
  end
  
  RPCS():Store_Request_IAPBuy(msg, OnRequestSuccessCB, OnRequestFailedCB, OnRequestTimeoutCB)
end

function IAPManager:OnBuyWithWelfare(productId, productSubId, exParam, iStoreType, storeParam, OnSdkCallback)
  local function OnDeliverWelfareSuccessCB(sc, msg)
    if OnSdkCallback then
      OnSdkCallback(true)
    end
  end
  
  local function OnDeliverWelfareFailedCB(msg)
    log.error("Cmd_Store_IAP_Deliver_Welfare_CS failed rspCode:" .. msg.rspcode)
    if OnSdkCallback then
      OnSdkCallback(false, "network", msg)
    end
  end
  
  local function OnDeliverWelfareTimeoutCB()
    log.error("Cmd_Store_IAP_Deliver_Welfare_CS timeout")
    if OnSdkCallback then
      OnSdkCallback(false, "message", "timeout")
    end
  end
  
  local msg = MTTDProto.Cmd_Store_IAP_Deliver_Welfare_CS()
  msg.sProductId = productId
  msg.iProductSubId = productSubId
  msg.iStoreType = iStoreType
  msg.sStoreParam = storeParam
  RPCS():Store_IAP_Deliver_Welfare(msg, OnDeliverWelfareSuccessCB, OnDeliverWelfareFailedCB, OnDeliverWelfareTimeoutCB)
end

function IAPManager:OnCallbackFail(param1, param2)
  if param1 == "network" then
    NetworkManager:OnRpcCallbackFail({
      rspcode = param2.rspcode
    })
    return
  elseif param1 == "message" then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, param2)
    return
  elseif param1 == "msdk" then
    local ok, _ = pcall(function()
      json.decode(param2.message)
    end)
    if ok then
      log.error(param2.message)
      local errorMap = json.decode(param2.message)
      local errorMessage = ConfigManager:GetClientMessageTextById(errorMap.Code or errorMap.err_code)
      if errorMessage == "???" then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, "ErrorCode:" .. tostring(errorMap.Code))
      else
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, errorMessage)
      end
    elseif ChannelManager:IsIOS() then
      local code
      if ChannelManager:IsExeVerBig("1.1.370") >= 0 then
        code = param2.status
      else
        code = string.match(param2.message, "%-(%d+)")
      end
      local errorMessage = ConfigManager:GetClientMessageTextById(code)
      if errorMessage == "???" then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, "ErrorCode:" .. tostring(code))
      else
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, errorMessage)
      end
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, param2.message)
    end
    return
  elseif param1 == "qsdk" then
    return
  end
end

function IAPManager:OnUpdate(dt)
  self.m_dt = (self.m_dt or 0) + dt
  if self.m_dt >= 1.0 then
    self.m_dt = 0
    if self.m_autoReleaseDict then
      for productId, timeLeft in pairs(self.m_autoReleaseDict) do
        if 0 < timeLeft then
          self.m_autoReleaseDict[productId] = timeLeft - 1
        else
          self.m_productBuying[productId] = nil
          self.m_autoReleaseDict[productId] = nil
          log.error("商品限购时间到，自动释放购买限制：" .. tostring(productId))
        end
      end
    end
  end
  if self.m_purchaseDelay then
    self.m_purchaseDelay = self.m_purchaseDelay - dt
    if 0 >= self.m_purchaseDelay then
      self.m_purchaseDelay = nil
    end
  end
end

function IAPManager:OnPushIAPDelivery(data, msg)
  log.error(tostring(data.sProductId) .. "商品购买完成")
  if data.iReceiptType and data.iReceiptType == MTTDProto.IAPReceiptType_Welfare then
  else
    if self.m_lastProductId == data.sProductId and self.m_lastRspseq == msg.rspseq then
      log.error("商品重复推送")
      return
    end
    self.m_lastProductId = data.sProductId
    self.m_lastRspseq = msg.rspseq
  end
  if ChannelManager:IsDMMChannel() then
    log.info("DMM渠道，消费商品:" .. tostring(data.sProductId))
    CS.DMMGameStoreManager.Instance:ConsumeRecept(data.sProductId)
  end
  self.m_productBuying[data.sProductId] = nil
  if data.vItem and table.getn(data.vItem) > 0 then
    utils.popUpRewardUI(data.vItem, function()
      self:broadcastEvent("eGameEvent_IAPDeliveryOnCloseRewardUI", data)
    end)
  end
  self:broadcastEvent("eGameEvent_IAPDelivery_Push", data)
end

function IAPManager:GetStoreType()
  return self.m_storeImpl:GetStoreType()
end

function IAPManager:GetStore()
  return self.m_storeImpl
end

function IAPManager:BuyProductByStoreType(ProductInfo, storeParam, callback)
  local welfarePrice = self:GetProductWelfarePrice(ProductInfo.productId)
  local curWelfareNum = ItemManager:GetItemNum(MTTDProto.SpecialItem_Welfare)
  if ProductInfo.productId ~= "" and (tonumber(welfarePrice) <= tonumber(curWelfareNum) or ActivityManager:OnCheckVoucherControlAndUrl()) then
    local function OnNormalBuy(msg)
      self:BuyProductByStoreTypeRe(ProductInfo, storeParam, callback)
    end
    
    local function OnWelfareBug(msg)
      self:BuyProductByStoreTypeRe(ProductInfo, storeParam, callback, true)
    end
    
    StackPopup:Push(UIDefines.ID_FORM_COUPON, {
      ProductInfo = ProductInfo,
      storeParam = storeParam,
      normalBuy = OnNormalBuy,
      welfareBuy = OnWelfareBug
    })
  else
    self:BuyProductByStoreTypeRe(ProductInfo, storeParam, callback)
  end
end

function IAPManager:BuyProductByStoreTypeRe(ProductInfo, storeParam, callback, isBuyWithWelfare)
  if not ProductInfo then
    return
  end
  if not self.payStoreActivity then
    self.payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  end
  local des = ""
  if self.payStoreActivity then
    local storeCfg = self.payStoreActivity:GetCfgByStoreId(ProductInfo.StoreID)
    if storeCfg then
      des = storeCfg.sStoreDesc or ""
    end
  end
  local reportData = {
    activityId = ProductInfo.iActivityId,
    storeId = ProductInfo.StoreID,
    goodsId = ProductInfo.GoodsID,
    giftPackType = ProductInfo.GiftPackType,
    groudId = ProductInfo.GroupId or 0,
    storeDes = des
  }
  ReportManager:ReportProductBuyBtn(reportData)
  if ProductInfo.productId == "" then
    local function onBuyFreeGoodsSuccess(msg)
      local reward_list = msg.vReward
      
      if reward_list and next(reward_list) then
        utils.popUpRewardUI(reward_list)
      end
    end
    
    local msg = MTTDProto.Cmd_Act_PayStore_FreeReward_CS()
    msg.iStoreId = ProductInfo.StoreID
    msg.iGoodsId = ProductInfo.GoodsID
    msg.iActivityId = ProductInfo.iActivityId
    RPCS():Act_PayStore_FreeReward(msg, onBuyFreeGoodsSuccess)
    return
  end
  if not storeParam then
    local baseStoreBuyParam = MTTDProto.CmdActPayStoreBuyParam()
    baseStoreBuyParam.iStoreId = ProductInfo.StoreID
    baseStoreBuyParam.iGoodsId = ProductInfo.GoodsID
    baseStoreBuyParam.iActivityId = ProductInfo.iActivityId
    storeParam = sdp.pack(baseStoreBuyParam)
  end
  local exParam = {
    productName = ProductInfo.productName or "",
    productDesc = ProductInfo.productDesc or ""
  }
  self:BuyProduct(ProductInfo.productId, ProductInfo.productSubId, ProductInfo.iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
end

return IAPManager
