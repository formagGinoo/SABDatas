local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreQSDK = class("StoreQSDK", StoreBase)

function StoreQSDK:OnCreate()
  log.info("StoreQSDK:OnCreate")
end

function StoreQSDK:RealPay(productId, productSubId, exParam, OnSdkCallback)
  QSDKManager:Pay(productId, productSubId, exParam, self:GetProductPrice(productId, false), function(code, payResult)
    if code == 0 then
      OnSdkCallback(true, payResult)
    elseif code == -1 then
      OnSdkCallback(false, "message", "支付取消")
    else
      OnSdkCallback(false, "message", "支付失败")
    end
  end)
end

function StoreQSDK:GetIAPReceiptType()
  if ChannelManager:IsWindows() or ChannelManager:IsIOS() then
    return MTTDProto.IAPReceiptType_QuickGame
  else
    return MTTDProto.IAPReceiptType_QuickSDK
  end
end

function StoreQSDK:OnCallbackFail()
end

function StoreQSDK:EnableCheckValid()
  if QSDKManager:GetParentChannelType() == "9" then
    return false
  end
  return true
end

function StoreQSDK:GetStoreType()
  return StoreType.QSDK
end

return StoreQSDK
