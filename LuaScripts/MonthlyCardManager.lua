local BaseManager = require("Manager/Base/BaseManager")
local MonthlyCardManager = class("MonthlyCardManager", BaseManager)
local smallCardID = 201001
local bigCardID = 201002

function MonthlyCardManager:OnCreate()
  self.exhibitionRewardInHall = true
  self.cardInfos = {}
  self.rewardCfgs = {}
  self.dailyRewardCfgs = {}
  self.rewardInfos = {}
end

function MonthlyCardManager:OnInitLoginPush()
  if self.rewardHandler == nil then
    self.rewardHandler = RPCS():Listen_Push_BaseStoreMonthlyCardReward(handler(self, self.OnPushBaseStoreMonthlyCardReward), "MonthlyCardManager")
  end
end

function MonthlyCardManager:OnInitNetwork()
  if self.storeHandler == nil then
    self.storeHandler = RPCS():Listen_Push_BaseStoreMonthlyCard(handler(self, self.OnPushBaseStoreMonthlyCard), "MonthlyCardManager")
  end
  self:addEventListener("eGameEvent_IAPDeliveryOnCloseRewardUI", handler(self, self.OnCloseRewardUI))
end

function MonthlyCardManager:GetSmallCardCfg()
  if self.smallCardCfg == nil then
    self.smallCardCfg = CS.CData_StoreBaseGoodsMonthly.GetInstance():GetValue_ByGoodsID(smallCardID)
    self.rewardCfgs[smallCardID] = utils.changeCSArrayToLuaTable(self.smallCardCfg.m_ItemID)[1]
    self.dailyRewardCfgs[smallCardID] = utils.changeCSArrayToLuaTable(self.smallCardCfg.m_DailyReward)[1]
  end
  return self.smallCardCfg
end

function MonthlyCardManager:GetBigCardCfg()
  if self.bigCardCfg == nil then
    self.bigCardCfg = CS.CData_StoreBaseGoodsMonthly.GetInstance():GetValue_ByGoodsID(bigCardID)
    self.rewardCfgs[bigCardID] = utils.changeCSArrayToLuaTable(self.bigCardCfg.m_ItemID)[1]
    self.dailyRewardCfgs[bigCardID] = utils.changeCSArrayToLuaTable(self.bigCardCfg.m_DailyReward)[1]
  end
  return self.bigCardCfg
end

function MonthlyCardManager:GetRewardCfg(isSmallCard, isDailyReward)
  local cardId = isSmallCard and smallCardID or bigCardID
  return isDailyReward and self.dailyRewardCfgs[cardId] or self.rewardCfgs[cardId]
end

function MonthlyCardManager:OnDailyReset()
  self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
end

function MonthlyCardManager:DailyRewardExhibition(isSmallCard)
  if isSmallCard then
    self:GetSmallCardCfg()
  else
    self:GetBigCardCfg()
  end
  local cardId = isSmallCard and smallCardID or bigCardID
  local rewardInfo = self.rewardInfos[cardId]
  if rewardInfo == 1 then
    self.rewardInfos[cardId] = 2
    return true
  end
  return false
end

function MonthlyCardManager:CheckCanBuyCard(isSmallCard)
  local cardId = isSmallCard and smallCardID or bigCardID
  local info = self.cardInfos[cardId]
  if info == nil then
    return true
  end
  local leftTime = info.iExpireTime - TimeUtil:GetServerTimeS()
  if leftTime <= 0 then
    return true
  end
  local cfg = isSmallCard and self:GetSmallCardCfg() or self:GetBigCardCfg()
  return leftTime < cfg.m_MaxDuration
end

function MonthlyCardManager:GetSmallCardRemainingDayText()
  local info = self.cardInfos[smallCardID]
  if info == nil then
    return nil
  end
  if info.iExpireTime <= TimeUtil:GetServerTimeS() then
    return nil
  end
  return self:SecondToDayText(info.iExpireTime)
end

function MonthlyCardManager:GetBigCardRemainingDayText()
  local info = self.cardInfos[bigCardID]
  if info == nil then
    return nil
  end
  if info.iExpireTime <= TimeUtil:GetServerTimeS() then
    return nil
  end
  return self:SecondToDayText(info.iExpireTime)
end

function MonthlyCardManager:IsCanMonthlyCardPushFace()
  local bigInfo = self.cardInfos[bigCardID]
  if bigInfo and bigInfo.iExpireTime > TimeUtil:GetServerTimeS() then
    return "Form_MallMonthCardTips"
  end
  local smallInfo = self.cardInfos[smallCardID]
  if smallInfo and smallInfo.iExpireTime > TimeUtil:GetServerTimeS() then
    return "Form_MallMonthCardTips"
  end
  return false
end

function MonthlyCardManager:SecondToDayText(expireTime)
  local time = expireTime - TimeUtil:GetServerTimeS()
  local day = math.ceil(time / 86400)
  return string.gsubNumberReplace(UnlockSystemUtil:GetLockClientMessage(10303), day)
end

function MonthlyCardManager:EnableExhibitionRewardInHall(enable)
  self.exhibitionRewardInHall = enable
end

function MonthlyCardManager:BuyCard(isSmallCard, iStoreId)
  if not self:CheckCanBuyCard(isSmallCard) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13023)
    return
  end
  local cfg = isSmallCard and self:GetSmallCardCfg() or self:GetBigCardCfg()
  local baseStoreBuyParam = MTTDProto.CmdBaseStoreBuyParam()
  baseStoreBuyParam.iStoreId = iStoreId
  baseStoreBuyParam.iGoodsId = cfg.m_GoodsID
  local storeParam = sdp.pack(baseStoreBuyParam)
  self:EnableExhibitionRewardInHall(false)
  local ProductInfo = {
    StoreID = iStoreId,
    GoodsID = cfg.m_GoodsID,
    productId = cfg.m_ProductID,
    productSubId = cfg.m_ProductSubID,
    iStoreType = MTTDProto.IAPStoreType_BaseStore,
    productName = cfg.m_mItemName or "",
    productDesc = cfg.m_mItemDesc or ""
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, handler(self, self.OnBuyResult))
end

function MonthlyCardManager:OnBuyResult(isSuccess, param1, param2)
  if not isSuccess then
    IAPManager:OnCallbackFail(param1, param2)
    return
  end
end

function MonthlyCardManager:ReqGetMonthlyCard(iStoreId)
  local rqs_msg = MTTDProto.Cmd_BaseStore_GetBaseStoreMonthlyCard_CS()
  rqs_msg.iStoreId = iStoreId
  rqs_msg.iCardId = smallCardID
  RPCS():BaseStore_GetBaseStoreMonthlyCard(rqs_msg, handler(self, self.OnGetBaseStoreMonthlyCardSC))
  local rqs_msg1 = MTTDProto.Cmd_BaseStore_GetBaseStoreMonthlyCard_CS()
  rqs_msg1.iStoreId = iStoreId
  rqs_msg1.iCardId = bigCardID
  RPCS():BaseStore_GetBaseStoreMonthlyCard(rqs_msg1, handler(self, self.OnGetBaseStoreMonthlyCardSC))
end

function MonthlyCardManager:OnGetBaseStoreMonthlyCardSC(data)
  for key, value in pairs(data.stMonthlyCard.mMonthlyCard) do
    self.cardInfos[key] = value
  end
end

function MonthlyCardManager:OnPushBaseStoreMonthlyCard(stStoreMonthlyCard, msg)
  self:OnGetBaseStoreMonthlyCardSC(stStoreMonthlyCard)
  self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
end

function MonthlyCardManager:OnPushBaseStoreMonthlyCardReward(stStoreMonthlyCardRewardList, msg)
  for _, v in ipairs(stStoreMonthlyCardRewardList.vMonthlyCardReward) do
    self.rewardInfos[v.iCardId] = 1
    if self.cardInfos[v.iCardId] == nil then
      self.cardInfos[v.iCardId] = {
        iExpireTime = v.iExpireTime
      }
    end
  end
  if not self.exhibitionRewardInHall then
    return
  end
  self:broadcastEvent("eGameEvent_MonthlyCardDailyReward")
  self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
end

function MonthlyCardManager:OnCloseRewardUI(data)
  if self.smallCardCfg and self.smallCardCfg.m_ProductID == data.sProductId and self.smallCardCfg.m_ProductSubID == data.iSubProductId and self.rewardInfos[smallCardID] == 1 then
    StackPopup:Push(UIDefines.ID_FORM_MALLMONTHCARDTIPS)
    return
  end
  if self.bigCardCfg and self.bigCardCfg.m_ProductID == data.sProductId and self.bigCardCfg.m_ProductSubID == data.iSubProductId and self.rewardInfos[bigCardID] == 1 then
    StackPopup:Push(UIDefines.ID_FORM_MALLMONTHCARDTIPS)
    return
  end
end

function MonthlyCardManager:Debug()
  self.rewardInfos[smallCardID] = 1
  self.rewardInfos[bigCardID] = 1
  self:broadcastEvent("eGameEvent_MonthlyCardDailyReward")
end

return MonthlyCardManager
