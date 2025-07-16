local BaseManager = require("Manager/Base/BaseManager")
local DmmManager = class("DmmManager", BaseManager)

function DmmManager:OnCreate()
end

function DmmManager:OnUpdate(dt)
end

function DmmManager:Initialize()
  self.dmmManager = CS.DMMSDKManger.Instance
end

function DmmManager:Login(callback)
  self.dmmManager:CheckLogin(callback)
end

function DmmManager:UpdateToken(callback)
  self.dmmManager.onUpdateToken = callback
  self.dmmManager:UpdateToken()
end

function DmmManager:AddCallbackGetProfile(callback)
  self.dmmManager.onGetProfile = callback
end

function DmmManager:AddCallbackGetChip(callback)
  self.dmmManager.onGetChip = callback
end

function DmmManager:AddCallbackGetPoint(callback)
  self.dmmManager.onGetPoint = callback
end

function DmmManager:AddCallbackPayment(callback)
  self.dmmManager.onPayment = callback
end

function DmmManager:SetAccountInfo(accountInfo)
  self.accountInfo = accountInfo
end

function DmmManager:GetAccountInfo()
  return self.accountInfo
end

return DmmManager
