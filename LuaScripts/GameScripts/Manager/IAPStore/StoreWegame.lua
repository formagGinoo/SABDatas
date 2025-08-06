local StoreBase = require("Manager/IAPStore/StoreBase")
local StoreWegame = class("StoreWegame", StoreBase)

function StoreWegame:OnCreate()
end

function StoreWegame:InitStore()
  self.productCallbacks = {}
end

function StoreWegame:RealPay(orderId, productSubId, exParam, OnSdkCallback)
  CS.Form_Waiting.Show(true)
  CS.WeGameManager.Instance:Purchase(orderId, "purchase", function(success, result)
    CS.Form_Waiting.Hide()
    print("wegame purchase success", success, result)
    if success then
      OnSdkCallback(true, "wegame", {
        order = orderId,
        code = 0,
        message = "success"
      })
    else
      OnSdkCallback(false, "wegame", {
        order = orderId,
        code = 0,
        message = "fail"
      })
    end
  end)
end

function StoreWegame:OnCallbackFail()
end

function StoreWegame:EnableCheckValid()
  return true
end

function StoreWegame:GetStoreType()
  return StoreType.Wegame
end

return StoreWegame
