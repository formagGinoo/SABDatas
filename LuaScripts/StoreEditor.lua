local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreEditor = class("StoreEditor", StoreBase)

function StoreEditor:OnCreate()
  log.info("StoreEditor:OnCreate")
end

function StoreEditor:RealPay(productId, productSubId, exParam, OnSdkCallback)
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
  RPCS():Store_IAP_Deliver_Welfare(msg, OnDeliverWelfareSuccessCB, OnDeliverWelfareFailedCB, OnDeliverWelfareTimeoutCB)
end

function StoreEditor:GetIAPReceiptType()
  return MTTDProto.IAPReceiptType_Welfare
end

function StoreEditor:GetStoreType()
  return StoreType.Editor
end

return StoreEditor
