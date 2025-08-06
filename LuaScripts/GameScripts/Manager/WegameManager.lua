local BaseManager = require("Manager/Base/BaseManager")
local WegameManager = class("WegameManager", BaseManager)

function WegameManager:OnCreate()
end

function WegameManager:OnUpdate(dt)
end

function WegameManager:Initialize()
  self.wegameManager = CS.WeGameManager.Instance
  self.wegameManager:Initialize()
end

function WegameManager:Login(callback)
  log.info("WegameManager:Login")
  self.wegameManager:Login(callback)
end

function WegameManager:UpdateToken(callback)
  self.wegameManager.onUpdateToken = callback
  self.wegameManager:UpdateToken()
end

function WegameManager:SetDirtyWordsFilter(text, callback)
  self.wegameManager:SetDirtyWordsFilter(text, callback)
end

function WegameManager:Purchase(productId, productSubId, iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
  self.wegameManager:Purchase(productId, productSubId, iStoreType, storeParam, callback, exParam, isBuyWithWelfare)
end

function WegameManager:AddCallbackGetProfile(callback)
end

function WegameManager:AddCallbackGetChip(callback)
end

function WegameManager:AddCallbackGetPoint(callback)
end

function WegameManager:AddCallbackPayment(callback)
end

function WegameManager:SetAccountInfo(accountInfo)
end

function WegameManager:SetTicket(ticket)
  self.ticket = ticket
end

function WegameManager:GetAccountInfo()
  local accountInfo = {}
  accountInfo.railId = self.wegameManager.playerRailId
  accountInfo.ticket = self.ticket
  return accountInfo
end

function WegameManager:GetRailID()
  return self.wegameManager.playerRailId
end

return WegameManager
