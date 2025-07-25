local BaseActivity = require("Base/BaseActivity")
local PayStoreActivity = class("PayStoreActivity", BaseActivity)

function PayStoreActivity.getActivityType(_)
  return MTTD.ActivityType_PayStore
end

function PayStoreActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgPayStore
end

function PayStoreActivity.getStatusProto(_)
  return MTTDProto.CmdActPayStore_Status
end

function PayStoreActivity:RequestGetReward(iId)
end

function PayStoreActivity:OnRequestGetRewardSC(sc, msg)
  local vReward = sc.vReward
  utils.popUpRewardUI(vReward)
end

function PayStoreActivity:InitData(m_stSdpConfig)
  self.m_NewSortConfig = {}
  if not m_stSdpConfig then
    return
  end
  local mStore = m_stSdpConfig.stCommonCfg.mStore
  local sort_config = {}
  for _, v in pairs(mStore or {}) do
    if v.iStoreStatus == 1 then
      sort_config[v.iWindowID] = sort_config[v.iWindowID] or {}
      sort_config[v.iWindowID][#sort_config[v.iWindowID] + 1] = v
      if self:CheckStoreIsOpen(v) then
        if v.iStoreType == MTTDProto.CmdActPayStoreType_MainStage then
          MallGoodsChapterManager:RqsGetBaseStoreChapter(v.iStoreId)
        elseif v.iStoreType == MTTDProto.CmdActPayStoreType_MonthlyCard then
          MonthlyCardManager:ReqGetMonthlyCard(v.iStoreId)
        end
      end
    end
  end
  for iWindowID, v in pairs(sort_config) do
    if 1 < #v then
      table.sort(v, function(a, b)
        return a.iShowOrder < b.iShowOrder
      end)
    end
    v.iShowOrder = v[1].iShowOrder
  end
  local t = {}
  for k, v in pairs(sort_config) do
    t[#t + 1] = v
  end
  table.sort(t, function(a, b)
    return a.iShowOrder < b.iShowOrder
  end)
  self.m_NewSortConfig = t
end

function PayStoreActivity:CheckStoreIsOpen(store)
  if store.iStoreStatus == 0 then
    return false
  end
  if not self:CheckActivityIsOpen() then
    return false
  end
  local time = TimeUtil:GetServerTimeS()
  if 0 < store.iStoreEndTime and time > store.iStoreEndTime or 0 < store.iStoreBeginTime and time < store.iStoreBeginTime then
    return false
  end
  local flag = false
  flag = self:isInLevel(store.iMinLevel, store.iMaxLevel)
  local minMainLevelID = store.iMinMainStage or 0
  local maxMainLevelID = store.iMaxMainStage or 0
  if minMainLevelID ~= 0 and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, minMainLevelID) ~= true then
    flag = false
  end
  if maxMainLevelID ~= 0 and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, maxMainLevelID) == true then
    flag = false
  end
  return flag
end

function PayStoreActivity:GetNewStoreList()
  return self.m_NewSortConfig or {}
end

function PayStoreActivity:GetRechargeStoreID()
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_DaimondBuy then
        if not self:CheckStoreIsOpen(store) then
          return false
        end
        return store.iStoreId
      end
    end
  end
  return 0
end

function PayStoreActivity:GetFixedGiftStoreID()
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_Permanent then
        return store.iStoreId
      end
    end
  end
  return 0
end

function PayStoreActivity:GetChainPackState()
  local chainPack
  local isCanShow = false
  local subStoreId, storeId
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_OpenCard then
        storeId = store.iStoreId
        chainPack = store
        break
      end
    end
  end
  if chainPack then
    local m_allGoodList = chainPack.stGoodsConfig
    table.sort(m_allGoodList, function(a, b)
      return a.SortOrder < b.SortOrder
    end)
    for k, v in pairs(m_allGoodList.mGoods) do
      local buyTimes = self:GetBuyCount(chainPack.iStoreId, v.iGoodsId)
      local limitBuyTimes = v.iLimitNum
      if buyTimes < limitBuyTimes then
        isCanShow = true
        subStoreId = chainPack.iStoreId
        break
      end
    end
  end
  return isCanShow, storeId, subStoreId
end

function PayStoreActivity:GetStoreSoldoutState(iStoreType)
  local isCanShow = false
  for _, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == iStoreType then
        local goodsData = store.stGoodsConfig.mGoods
        for k, data in pairs(goodsData) do
          local buyTimes = self:GetBuyCount(store.iStoreId, data.iGoodsId)
          local bIsSoldOut = buyTimes >= data.iLimitNum and data.iLimitNum > 0
          if not bIsSoldOut then
            isCanShow = true
            break
          end
        end
        break
      end
    end
  end
  return isCanShow
end

function PayStoreActivity:GetSignGiftState()
  local signGiftAct = ActivityManager:GetActivityByType(MTTD.ActivityType_SignGift)
  if not signGiftAct then
    return false
  end
  local isShow = signGiftAct:checkCondition()
  return isShow
end

function PayStoreActivity:GetActivityGiftStoreID()
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_Up then
        return store.iStoreId
      end
    end
  end
  return 0
end

function PayStoreActivity:GetMonthlyCardStoreID()
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_MonthlyCard then
        return store.iStoreId
      end
    end
  end
  return 0
end

function PayStoreActivity:GetPushStoreConfigByType(storeType)
  local configList = self.m_NewSortConfig
  for i, v in ipairs(configList) do
    for index, store in ipairs(v) do
      if store.iStoreType == storeType then
        return store
      end
    end
  end
end

function PayStoreActivity:GetActivityFashionStoreID()
  for i, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
        return store.iStoreId
      end
    end
  end
  return 0
end

function PayStoreActivity:CheckIsShowFashionStore()
  local isCanShow = false
  for _, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
        local goodsData = store.stGoodsConfig.mGoods
        for m, goodsInfo in pairs(goodsData) do
          local inTime = true
          if goodsInfo.iLaunchTime and goodsInfo.iRemovalTime and goodsInfo.iLaunchTime ~= 0 then
            inTime = TimeUtil:IsInTime(goodsInfo.iLaunchTime, goodsInfo.iRemovalTime)
          end
          if inTime then
            isCanShow = true
            break
          end
        end
        break
      end
    end
  end
  return isCanShow
end

function PayStoreActivity:CheckFashionStoreRedPoint()
  local redPoint = false
  for _, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
        local goodsData = store.stGoodsConfig.mGoods
        for m, goodsInfo in pairs(goodsData) do
          local buyTimes = self:GetBuyCount(store.iStoreId, goodsInfo.iGoodsId)
          local bIsSoldOut = buyTimes >= goodsInfo.iLimitNum and goodsInfo.iLimitNum > 0
          local inTime = true
          if goodsInfo.iLaunchTime and goodsInfo.iRemovalTime and goodsInfo.iLaunchTime ~= 0 then
            inTime = TimeUtil:IsInTime(goodsInfo.iLaunchTime, goodsInfo.iRemovalTime)
          end
          if not bIsSoldOut and inTime then
            local vReward = goodsInfo.vReward
            if vReward and vReward[1] then
              local iID = vReward[1].iID
              local heroFashion = HeroManager:GetHeroFashion()
              if heroFashion then
                local isHaveFashion = heroFashion:IsFashionHave(iID)
                if isHaveFashion then
                  goto lbl_92
                end
              end
              local red = LocalDataManager:GetIntSimple("Red_Point_FashionStore_" .. tostring(iID) .. tostring(m), 0)
              if red == 0 then
                return true
              end
            end
          end
        end
        break
      end
    end
    ::lbl_92::
  end
  return redPoint
end

function PayStoreActivity:GetFashionStoreCommodity()
  local goods = {}
  for _, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
        local goodsData = store.stGoodsConfig.mGoods
        for m, goodsInfo in pairs(goodsData) do
          local inTime = true
          if goodsInfo.iLaunchTime and goodsInfo.iRemovalTime and goodsInfo.iLaunchTime ~= 0 then
            inTime = TimeUtil:IsInTime(goodsInfo.iLaunchTime, goodsInfo.iRemovalTime)
          end
          if inTime then
            if not goodsInfo.goods_index then
              goodsInfo.goods_index = m
            end
            goods[#goods + 1] = goodsInfo
          end
        end
        return goods
      end
    end
  end
  return goods
end

function PayStoreActivity:GetFashionStoreCommoditySpine()
  local skinIdList = {}
  local goods = self:GetFashionStoreCommodity()
  if table.getn(goods) > 0 then
    for i, goodsData in ipairs(goods) do
      local vReward = goodsData.vReward
      if vReward and vReward[1] then
        skinIdList[#skinIdList + 1] = vReward[1].iID
      end
    end
  end
  return skinIdList
end

function PayStoreActivity:GetFashionStoreCommodityInfoById(id)
  local goods = self:GetFashionStoreCommodity()
  if table.getn(goods) > 0 then
    for i, goodsData in ipairs(goods) do
      local vReward = goodsData.vReward
      if vReward and vReward[1] and vReward[1].iID == id then
        return goodsData
      end
    end
  end
end

function PayStoreActivity:GetFashionStoreToBeReleasedCommodity()
  local goods = {}
  for _, v in ipairs(self.m_NewSortConfig) do
    for index, store in ipairs(v) do
      if store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
        local goodsData = store.stGoodsConfig.mGoods
        for m, goodsInfo in pairs(goodsData) do
          local inTime = true
          if goodsInfo.iLaunchTime and goodsInfo.iLaunchTime ~= 0 then
            inTime = TimeUtil:IsInTime(goodsInfo.iLaunchTime, goodsInfo.iRemovalTime)
          end
          if not inTime then
            goods[#goods + 1] = goodsInfo
          end
        end
        return goods
      end
    end
  end
  return goods
end

function PayStoreActivity:OnResetSdpConfig(m_stSdpConfig)
  self:InitData(m_stSdpConfig)
  self:broadcastEvent("eGameEvent_Activity_RefreshPayStore")
end

local WindowRedEnum = {
  [1] = RedDotDefine.ModuleType.MallNewbieGiftPackTabl,
  [2] = RedDotDefine.ModuleType.ActivityGiftPackTabl,
  [3] = RedDotDefine.ModuleType.MallDailyPackTabl,
  [8] = RedDotDefine.ModuleType.MallFashionTab
}

function PayStoreActivity:OnResetStatusData()
  self:broadcastEvent("eGameEvent_Activity_ResetStatus")
  for i, v in ipairs(self.m_NewSortConfig) do
    local redDotEnum
    if v[1] then
      redDotEnum = WindowRedEnum[v[1].iWindowID]
    end
    if redDotEnum then
      self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
        redDotKey = redDotEnum,
        count = self:GetRedDotCount(v)
      })
    end
  end
end

function PayStoreActivity:OnGetMallStoreOtherActRed()
  for i, v in ipairs(self.m_NewSortConfig) do
    local redDotEnum
    if v[1] then
      redDotEnum = WindowRedEnum[v[1].iWindowID]
    end
    if redDotEnum then
      self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
        redDotKey = redDotEnum,
        count = self:GetRedDotCount(v)
      })
    end
  end
end

function PayStoreActivity:GetRedDotCount(stores)
  for _, store in ipairs(stores) do
    if self:HasStoreRedDot(store) then
      return 1
    end
  end
  return 0
end

function PayStoreActivity:HasStoreRedDot(store)
  if not self:CheckStoreIsOpen(store) then
    return false
  end
  if store.iStoreType == MTTDProto.CmdActPayStoreType_SignGift then
    local signGiftAct = ActivityManager:GetActivityByType(MTTD.ActivityType_SignGift)
    if signGiftAct then
      self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
        redDotKey = RedDotDefine.ModuleType.MallNewStudentsSupplyPackTab,
        count = signGiftAct:checkShowRed() and 1 or 0
      })
      return signGiftAct:checkShowRed()
    end
    return false
  elseif store.iStoreType == MTTDProto.CmdActPayStoreType_FashionStore then
    return self:CheckFashionStoreRedPoint()
  end
  for _, good in pairs(store.stGoodsConfig.mGoods) do
    if good.sProductId == "" then
      local count = self:GetBuyCount(store.iStoreId, good.iGoodsId)
      if count < good.iLimitNum then
        return true
      end
    end
  end
  return false
end

function PayStoreActivity:GetBuyCount(iStoreId, iGoodId)
  local store = self.m_stStatusData.mStore[iStoreId]
  if store then
    local good = store.mGoods[iGoodId]
    if good then
      return good.iBuyTimes
    end
  end
  return 0
end

function PayStoreActivity:checkCondition()
  if not PayStoreActivity.super.checkCondition(self) then
    return false
  end
  return true
end

function PayStoreActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() then
    openFlag = true
  end
  return openFlag
end

function PayStoreActivity:GetCfgByStoreId(storeId)
  local configList = self.m_NewSortConfig
  for i, v in ipairs(configList) do
    for index, store in ipairs(v) do
      if store.iStoreId == storeId then
        return store
      end
    end
  end
end

function PayStoreActivity:GetIsAnyStoreISOpen()
  local configList = self.m_NewSortConfig
  for _, v in ipairs(configList) do
    for _, store in ipairs(v) do
      if self:CheckStoreIsOpen(store) then
        return true
      end
    end
  end
end

function PayStoreActivity:checkShowRed()
end

return PayStoreActivity
