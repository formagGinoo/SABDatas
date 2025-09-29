local BaseManager = require("Manager/Base/BaseManager")
local MonthlyCardManager = class("MonthlyCardManager", BaseManager)
local smallCardID = 201001
local bigCardID = 201002
local middleCardID = 201003
MonthlyCardManager.PrivilegeEffectType = {
  HangUpFreeTimes = 1,
  ShopFreeFreshTimes = 2,
  CouncilHallFreeTimes = 3,
  DispatchExPos = 4,
  EquipLevelExReward = 5,
  RogueExReward = 6
}

function MonthlyCardManager:OnCreate()
  self.exhibitionRewardInHall = true
  self.m_allMonthlyCfg = {}
  self.cardInfos = {}
  self.rewardCfgs = {}
  self.dailyRewardCfgs = {}
  self.m_curBuyCardType = nil
  self.rewardInfos = {}
  self.m_lastCardLength = 0
  self.m_addCardId = nil
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

function MonthlyCardManager:SetAllMonthlyCfg()
  local MonthlyCardIns = ConfigManager:GetConfigInsByName("StoreBaseGoodsMonthly")
  if self.m_allMonthlyCfg then
    local monthlyInfoAll = MonthlyCardIns:GetAll()
    for i, v in pairs(monthlyInfoAll) do
      self.m_allMonthlyCfg[v.m_type] = v
      self.rewardCfgs[v.m_type] = utils.changeCSArrayToLuaTable(v.m_ItemID)[1]
      self.dailyRewardCfgs[v.m_type] = utils.changeCSArrayToLuaTable(v.m_DailyReward)[1]
    end
  end
end

function MonthlyCardManager:GetMonthlyCardByType(type)
  if table.getn(self.m_allMonthlyCfg) <= 0 then
    self:SetAllMonthlyCfg()
  end
  return self.m_allMonthlyCfg[type]
end

function MonthlyCardManager:GetRewardCfg(cardType, isDailyReward)
  return isDailyReward and self.dailyRewardCfgs[cardType] or self.rewardCfgs[cardType]
end

function MonthlyCardManager:OnDailyReset()
  self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
  MonthlyCardManager:GetAddCardId()
end

function MonthlyCardManager:DailyRewardExhibition(cardType)
  local cardId = self.m_allMonthlyCfg[cardType].m_GoodsID
  local rewardInfo = self.rewardInfos[cardId]
  if rewardInfo == 1 then
    self.rewardInfos[cardId] = 2
    return true
  end
  return false
end

function MonthlyCardManager:CheckCanBuyCard(cardType)
  local cardId = self.m_allMonthlyCfg[cardType].m_GoodsID
  local info = self.cardInfos[cardId]
  if info == nil then
    return true
  end
  local leftTime = info.iExpireTime - TimeUtil:GetServerTimeS()
  if leftTime <= 0 then
    return true
  end
  local cfg = self.m_allMonthlyCfg[cardType]
  return leftTime < cfg.m_MaxDuration
end

function MonthlyCardManager:GetCardRemainingDayTextByType(type)
  local cardId = self.m_allMonthlyCfg[type].m_GoodsID
  local info = self.cardInfos[cardId]
  if info == nil then
    return nil
  end
  if info.iExpireTime <= TimeUtil:GetServerTimeS() then
    return nil
  end
  return self:SecondToDayText(info.iExpireTime)
end

function MonthlyCardManager:GetCardEndTime(type)
  if self.m_allMonthlyCfg[type] and self.m_allMonthlyCfg[type].m_GoodsID then
    local cardId = self.m_allMonthlyCfg[type].m_GoodsID
    local info = self.cardInfos[cardId]
    if info then
      return info.iExpireTime or 0
    end
  end
  return 0
end

function MonthlyCardManager:IsCanMonthlyCardPushFace()
  for cardId, v in pairs(self.cardInfos) do
    if v.iExpireTime and v.iExpireTime > TimeUtil:GetServerTimeS() then
      return "Form_MallMonthCardTips"
    end
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

function MonthlyCardManager:BuyCard(cardType, iStoreId)
  if not self:CheckCanBuyCard(cardType) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13023)
    return
  end
  self.m_curBuyCardType = cardType
  local cfg = self.m_allMonthlyCfg[cardType]
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
  if self.m_curBuyCardType then
    LocalDataManager:SetIntSimple("MonthlyCardTips" .. self.m_curBuyCardType, 0)
  end
end

function MonthlyCardManager:ReqGetMonthlyCard(iStoreId)
  self:SetAllMonthlyCfg()
  for key, value in pairs(self.m_allMonthlyCfg) do
    local rqs_msg1 = MTTDProto.Cmd_BaseStore_GetBaseStoreMonthlyCard_CS()
    rqs_msg1.iStoreId = iStoreId
    rqs_msg1.iCardId = value.m_GoodsID
    RPCS():BaseStore_GetBaseStoreMonthlyCard(rqs_msg1, handler(self, self.OnGetBaseStoreMonthlyCardSC))
  end
end

function MonthlyCardManager:OnGetBaseStoreMonthlyCardSC(data)
  for key, value in pairs(data.stMonthlyCard.mMonthlyCard) do
    self.cardInfos[key] = value
  end
  HangUpManager:CheckHangUpHaveFreeGetNum()
end

function MonthlyCardManager:OnPushBaseStoreMonthlyCard(stStoreMonthlyCard, msg)
  self.m_addCardId = stStoreMonthlyCard.iCardID
  self:OnGetBaseStoreMonthlyCardSC(stStoreMonthlyCard)
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
  local params = {
    isPrivilege = self:CheckShowPrivilegeIsUnlockTips()
  }
  self:broadcastEvent("eGameEvent_MonthlyCardDailyReward", params)
end

function MonthlyCardManager:SetAddCardId(addCardId)
  self.m_addCardId = addCardId
end

function MonthlyCardManager:GetAddCardId()
  return self.m_addCardId or -1
end

function MonthlyCardManager:CheckShowPrivilegeIsUnlockTips()
  local isShowTips = false
  if self.m_lastCardLength == GlobalConfig.MonthlyCardPrivilege - 1 and table.getn(self:GetHaveMonthlyCardInfo()) == GlobalConfig.MonthlyCardPrivilege then
    self.m_lastCardLength = GlobalConfig.MonthlyCardPrivilege
    isShowTips = true
  end
  self.m_lastCardLength = table.getn(self:GetHaveMonthlyCardInfo())
  return isShowTips
end

function MonthlyCardManager:OnCloseRewardUI(data)
  local isCanPush = false
  for _, v in ipairs(self.m_allMonthlyCfg) do
    if v and v.m_ProductID == data.sProductId and v.m_ProductSubID == data.iSubProductId and self.rewardInfos[v.m_GoodsID] == 1 then
      isCanPush = true
    end
  end
  if isCanPush then
    local params = {
      isPrivilege = self:CheckShowPrivilegeIsUnlockTips()
    }
    StackPopup:Push(UIDefines.ID_FORM_MALLMONTHCARDTIPS, params)
  else
    self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
    MonthlyCardManager:GetAddCardId()
  end
end

function MonthlyCardManager:GetHaveMonthlyCardInfo()
  self.m_curCardEffectInfo = {}
  for key, value in pairs(self.cardInfos) do
    if value.iExpireTime > TimeUtil:GetServerTimeS() then
      table.insert(self.m_curCardEffectInfo, value)
    end
  end
  return self.m_curCardEffectInfo
end

function MonthlyCardManager:IsPrivilegeEffect()
  local cardNum = 0
  for key, value in pairs(self.cardInfos) do
    if value.iExpireTime > TimeUtil:GetServerTimeS() then
      cardNum = cardNum + 1
    end
  end
  return cardNum >= GlobalConfig.MonthlyCardPrivilege, cardNum
end

function MonthlyCardManager:GetPrivilegeEffectByType(iPrivilegeType)
  local StoreMonthlyPrivilegesIns = ConfigManager:GetConfigInsByName("StoreMonthlyPrivileges")
  local allPrivilegeCfg = StoreMonthlyPrivilegesIns:GetAll()
  for _, v in pairs(allPrivilegeCfg) do
    if v.m_EffectType == iPrivilegeType then
      local effectData = utils.changeCSArrayToLuaTable(v.m_EffectData)
      return self:IsPrivilegeEffect(), effectData
    end
  end
  return false, nil
end

function MonthlyCardManager:Debug()
  self.rewardInfos[smallCardID] = 1
  self.rewardInfos[middleCardID] = 1
  self:broadcastEvent("eGameEvent_MonthlyCardDailyReward")
end

return MonthlyCardManager
