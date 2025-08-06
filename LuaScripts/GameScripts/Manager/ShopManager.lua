local BaseManager = require("Manager/Base/BaseManager")
local ShopManager = class("ShopManager", BaseManager)
ShopManager.REFRESH_TYPE = {
  NoRefresh = 0,
  DailyRefresh = 1,
  AppointedTime = 2,
  WeeklyRefresh = 3,
  MonthlyRefresh = 4
}
ShopManager.ShopGoodsConditionType = {
  ShopGoodsConditionType_RoleLevel = 1,
  ShopGoodsConditionType_StageMain = 2,
  ShopGoodsConditionType_Time = 3,
  ShopGoodsConditionType_PreTime = 4
}
ShopManager.ShopType = {ShopType_Normal = 1, ShopType_Activity = 2}

function ShopManager:OnCreate()
  self.m_allShopServerDataList = {}
  self.m_iTimerHandlerTab = {}
end

function ShopManager:OnInitNetwork()
end

function ShopManager:OnInitMustRequestInFetchMore()
  self:GetAllOpenShopData()
  self:RefreshAppointedTimeShop()
end

function ShopManager:OnDailyReset()
  local iTime = TimeUtil:GetServerTimeS()
  local date = os.date("*t", iTime)
  if date.day == 1 then
    self:RefreshShopDataByType(ShopManager.REFRESH_TYPE.MonthlyRefresh)
  end
  local swday = TimeUtil:GetServerTimeWeekDay() - 1
  if swday == 1 then
    self:RefreshShopDataByType(ShopManager.REFRESH_TYPE.WeeklyRefresh)
  end
  self:RefreshShopDataByType(ShopManager.REFRESH_TYPE.DailyRefresh)
end

function ShopManager:GetAllOpenShopData()
  local shopList = self:GetShopConfigList()
  local vShopId = {}
  if shopList then
    for i, shopCfg in ipairs(shopList) do
      vShopId[#vShopId + 1] = shopCfg.m_ShopID
    end
  end
  local msg = MTTDProto.Cmd_Shop_GetShopList_CS()
  msg.vShopId = vShopId
  RPCS():Shop_GetShopList(msg, handler(self, self.OnReqGetAllShopDataSC))
end

function ShopManager:OnReqGetAllShopDataSC(stData, msg)
  local vShopList = stData.vShopList
  for _, stShop in ipairs(vShopList) do
    self.m_allShopServerDataList[stShop.iShopId] = stShop
    self:broadcastEvent("eGameEvent_RefreshShopData", stShop.iShopId)
  end
end

function ShopManager:ReqGetShopData(shopId)
  local shopCfg = ShopManager:GetShopConfig(shopId)
  if shopCfg and shopCfg.m_Type == ShopManager.ShopType.ShopType_Activity then
    local startTime = TimeUtil:TimeStringToTimeSec2(shopCfg.m_StartTime) or 0
    local endTime = TimeUtil:TimeStringToTimeSec2(shopCfg.m_EndTime) or 0
    local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
      id = shopCfg.m_ActId,
      shop_id = shopCfg.m_ShopID
    })
    if is_corved then
      startTime = t1
      endTime = t2
    end
    if not TimeUtil:IsInTime(startTime, endTime) or not HeroActivityManager:IsMainActIsOpenByID(shopCfg.m_ActId) then
      return
    end
  end
  local reqMsg = MTTDProto.Cmd_Shop_GetShop_CS()
  reqMsg.iShopId = shopId
  RPCS():Shop_GetShop(reqMsg, handler(self, self.OnReqGetShopDataSC))
end

function ShopManager:OnReqGetShopDataSC(stData, msg)
  local stShop = stData.stShop
  self.m_allShopServerDataList[stShop.iShopId] = stShop
  self:broadcastEvent("eGameEvent_RefreshShopData", stShop.iShopId)
end

function ShopManager:ReqShopBuy(shopId, iGroupId, iGoodsId, iNum, bSkipVoice)
  self.bSkipVoice = bSkipVoice
  local reqMsg = MTTDProto.Cmd_Shop_Buy_CS()
  reqMsg.iShopId = shopId
  reqMsg.iGroupId = iGroupId
  reqMsg.iGoodsId = iGoodsId
  reqMsg.iNum = iNum
  RPCS():Shop_Buy(reqMsg, handler(self, self.OnReqShopBuySC))
end

function ShopManager:OnReqShopBuySC(stData, msg)
  local vReward = stData.vReward
  self:SetShopBuyChangeData(stData.iShopId, stData.iGroupId, stData.iGoodsId, stData.iStockBought, stData.iLimitBought)
  if vReward and next(vReward) then
    utils.popUpRewardUI(vReward, function()
      local goodCfg = ShopManager:GetShopGoodsConfig(stData.iGroupId, stData.iGoodsId)
      if stData.iStockBought >= goodCfg.m_ItemQuantity then
        self:broadcastEvent("eGameEvent_ShopSoldOut")
      else
        self:broadcastEvent("eGameEvent_ShopBuy")
      end
    end, stData.mChangeReward)
  else
    self:broadcastEvent("eGameEvent_ShopBuy")
  end
end

function ShopManager:ReqShopRefresh(shopId)
  local reqMsg = MTTDProto.Cmd_Shop_Refresh_CS()
  reqMsg.iShopId = shopId
  RPCS():Shop_Refresh(reqMsg, handler(self, self.OnReqShopRefreshSC))
end

function ShopManager:OnReqShopRefreshSC(stData, msg)
  local stShop = stData.stShop
  self.m_allShopServerDataList[stShop.iShopId] = stShop
  self:broadcastEvent("eGameEvent_RefreshShopItem", stShop.iShopId)
end

function ShopManager:GetShopDataByShopId(shopId)
  return self.m_allShopServerDataList[shopId] or {}
end

function ShopManager:GetShopRefreshTimesByShopId(shopId)
  local shopData = self.m_allShopServerDataList[shopId] or {}
  return shopData.iRefreshTimes or 0
end

function ShopManager:GetShopCurFreeRefreshTimesByShopId(shopId)
  local shopData = self.m_allShopServerDataList[shopId] or {}
  return shopData.iFreeRefreshTimes or 0
end

function ShopManager:GetShopCanRefreshMaxTimesByShopId(shopId)
  local shopList = self:GetShopConfigList()
  local maxRefreshTimes = 0
  local freeRefreshTimes = 0
  if shopList then
    for i, shopCfg in ipairs(shopList) do
      if shopCfg.m_ShopID == shopId then
        maxRefreshTimes = shopCfg.m_RefreshNum
      end
    end
  end
  if shopId == 101 then
    freeRefreshTimes = StatueShowroomManager:GetStatueEffectValue("StatueEffect_ShopNormalFreeResetMaxCount") or 0
  end
  maxRefreshTimes = maxRefreshTimes + freeRefreshTimes
  return maxRefreshTimes, freeRefreshTimes
end

function ShopManager:GetShopGoodsByShopId(shopId)
  local goods = {}
  local shopData = self.m_allShopServerDataList[shopId] or {}
  local vGoods = shopData.vGoods or {}
  for i, v in ipairs(vGoods) do
    local goodCfg = self:GetShopGoodsConfig(v.iGroupId, v.iGoodsId)
    if goodCfg and not goodCfg:GetError() then
      if goodCfg.m_ConditionType == ShopManager.ShopGoodsConditionType.ShopGoodsConditionType_PreTime then
        local goodInfo = table.deepcopy(v)
        goodInfo.iShopId = shopId
        local confitionTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_ConditionTime) or 0
        local shopCfg = ShopManager:GetShopConfig(shopId)
        local is_corved, corveCfg = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shopGoods, {
          id = shopCfg.m_ActId,
          iGroupID = goodCfg.m_GoodsGroupID,
          iGoodsId = goodCfg.m_GoodsID
        })
        local endTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_EndTime) or 0
        if is_corved then
          confitionTime = corveCfg.iConditionTime
          endTime = corveCfg.iEndTime
        end
        if TimeUtil:IsInTime(confitionTime, endTime) then
          goods[#goods + 1] = goodInfo
        end
      else
        local showTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_ShowTime) or 0
        local endTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_EndTime) or 0
        if TimeUtil:IsInTime(showTime, endTime) then
          local goodInfo = table.deepcopy(v)
          goodInfo.iShopId = shopId
          goods[#goods + 1] = goodInfo
        end
      end
    end
  end
  return goods
end

function ShopManager:GetShopConfig(id)
  if not id then
    log.error("ShopManager GetShopConfig id = nil")
    return
  end
  local configInstance = ConfigManager:GetConfigInsByName("Shop")
  return configInstance:GetValue_ByShopID(id)
end

function ShopManager:GetShopGoodsConfig(goodsGroupId, goodsId)
  if not goodsGroupId or not goodsId then
    log.error("ShopManager GetShopGoodsConfig goodsGroupId = nil")
    return
  end
  local configInstance = ConfigManager:GetConfigInsByName("ShopGoods")
  return configInstance:GetValue_ByGoodsGroupIDAndGoodsID(goodsGroupId, goodsId)
end

function ShopManager:GetShopGoodsBought(shopId, goodsGroupId, goodsId)
  local shopData = self:GetShopDataByShopId(shopId)
  local mGoodsBought = shopData.mGoodsBought
  local resTimes = 0
  for shopGroupId, v in pairs(mGoodsBought) do
    if shopGroupId == goodsGroupId then
      for itemId, count in pairs(v) do
        if itemId == goodsId then
          resTimes = count
          return resTimes
        end
      end
    end
  end
  return resTimes
end

function ShopManager:GetShopGoodsStockBought(shopId, goodsGroupId, goodsId)
  local shopData = self:GetShopDataByShopId(shopId)
  local count = 0
  if shopData then
    local vGoods = shopData.vGoods
    for i, v in pairs(vGoods) do
      if v.iGroupId == goodsGroupId and v.iGoodsId == goodsId then
        count = v.iBought
        return count
      end
    end
  end
  return count
end

function ShopManager:GetCurInStockNum(shopID, goodsGroupID, goodsID)
  if not shopID then
    return
  end
  if not goodsGroupID then
    return
  end
  if not goodsID then
    return
  end
  local ShopGoodsIns = ConfigManager:GetConfigInsByName("ShopGoods")
  local goodsCfg = ShopGoodsIns:GetValue_ByGoodsGroupIDAndGoodsID(goodsGroupID, goodsID)
  if not goodsCfg then
    return
  end
  if goodsCfg:GetError() == true then
    return
  end
  local iBought = self:GetShopGoodsStockBought(shopID, goodsGroupID, goodsID) or 0
  local allBoughtNum = self:GetShopGoodsBought(shopID, goodsGroupID, goodsID) or 0
  local cfgMaxNum = goodsCfg.m_ItemQuantity
  if goodsCfg.m_ResType ~= 0 then
    local limitNum = goodsCfg.m_ResTimes
    if cfgMaxNum > limitNum then
      cfgMaxNum = limitNum
    end
  else
    return cfgMaxNum
  end
  cfgMaxNum = cfgMaxNum - (allBoughtNum - iBought)
  return cfgMaxNum
end

function ShopManager:CheckIsReachedPurchaseLimit(shopId, goodsGroupId, goodsId)
  local limit = false
  local ShopGoodsIns = ConfigManager:GetConfigInsByName("ShopGoods")
  local goodCfg = ShopGoodsIns:GetValue_ByGoodsGroupIDAndGoodsID(goodsGroupId, goodsId)
  if goodCfg and not goodCfg:GetError() then
    local boughtNum = self:GetShopGoodsBought(shopId, goodsGroupId, goodsId)
    if goodCfg.m_ResTimes ~= 0 and boughtNum >= goodCfg.m_ResTimes then
      limit = true
    end
  end
  return limit
end

function ShopManager:CheckHaveAnyStock(shopId, goodsGroupId, goodsId)
  local haveStock = true
  local ShopGoodsIns = ConfigManager:GetConfigInsByName("ShopGoods")
  local goodCfg = ShopGoodsIns:GetValue_ByGoodsGroupIDAndGoodsID(goodsGroupId, goodsId)
  if goodCfg and not goodCfg:GetError() then
    local boughtNum = self:GetShopGoodsStockBought(shopId, goodsGroupId, goodsId)
    local resTimes = self:GetShopGoodsBought(shopId, goodsGroupId, goodsId)
    if boughtNum >= goodCfg.m_ItemQuantity or resTimes >= goodCfg.m_ItemQuantity then
      haveStock = false
    end
  end
  return haveStock
end

function ShopManager:BuyGoods(shopId, goodsGroupId, goodsId, buyNum, bSkipVoice)
  local ShopGoodsIns = ConfigManager:GetConfigInsByName("ShopGoods")
  local goodCfg = ShopGoodsIns:GetValue_ByGoodsGroupIDAndGoodsID(goodsGroupId, goodsId)
  if goodCfg and not goodCfg:GetError() then
    local boughtNum = self:GetShopGoodsBought(shopId, goodsGroupId, goodsId)
    if goodCfg.m_ResTimes ~= 0 and boughtNum >= goodCfg.m_ResTimes then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
      return
    end
  end
  self:ReqShopBuy(shopId, goodsGroupId, goodsId, buyNum or 1, bSkipVoice)
end

function ShopManager:SetShopBuyChangeData(shopId, goodsGroupId, goodsId, iStockBought, iLimitBought)
  local shopData = self.m_allShopServerDataList[shopId]
  if shopData then
    local mGoodsBought = shopData.mGoodsBought
    if mGoodsBought == nil then
      mGoodsBought = {}
      shopData.mGoodsBought = mGoodsBought
    end
    local goodsGroupData = mGoodsBought[goodsGroupId]
    if goodsGroupData == nil then
      goodsGroupData = {}
      mGoodsBought[goodsGroupId] = goodsGroupData
    end
    goodsGroupData[goodsId] = iLimitBought
    local vGoods = shopData.vGoods
    for i, v in pairs(vGoods) do
      if v.iGroupId == goodsGroupId and v.iGoodsId == goodsId then
        v.iBought = iStockBought
      end
    end
  end
end

function ShopManager:GetShopConfigList(shop_type)
  local shop_list = {}
  local ShopIns = ConfigManager:GetConfigInsByName("Shop")
  local shopAllCfg = ShopIns:GetAll()
  for i, itemCfg in pairs(shopAllCfg) do
    local flag = UnlockSystemUtil:CheckShopIsOpenById(itemCfg.m_ShopID)
    if flag and itemCfg and (not shop_type or shop_type == itemCfg.m_Type) then
      shop_list[#shop_list + 1] = itemCfg
    end
  end
  return shop_list
end

function ShopManager:RefreshShopDataByType(refreshType)
  local shopList = self:GetShopConfigList()
  if shopList then
    for i, shopCfg in ipairs(shopList) do
      if shopCfg.m_RefreshType == refreshType then
        local shopId = 0
        if refreshType == ShopManager.REFRESH_TYPE.DailyRefresh then
          shopId = shopCfg.m_ShopID
        elseif refreshType == ShopManager.REFRESH_TYPE.WeeklyRefresh then
          shopId = shopCfg.m_ShopID
        elseif refreshType == ShopManager.REFRESH_TYPE.MonthlyRefresh then
          shopId = shopCfg.m_ShopID
        end
        if shopId ~= 0 then
          self:ReqGetShopData(shopId)
        end
      elseif shopCfg.m_Type == ShopManager.ShopType.ShopType_Activity then
        self:ReqGetShopData(shopCfg.m_ShopID)
      end
    end
  end
end

function ShopManager:ClearTimer()
  if self.m_iTimerHandlerTab ~= nil then
    for i = #self.m_iTimerHandlerTab, 1, -1 do
      TimeService:KillTimer(self.m_iTimerHandlerTab[i])
      self.m_iTimerHandlerTab[i] = nil
    end
    self.m_iTimerHandlerTab = {}
  end
end

function ShopManager:RefreshAppointedTimeShop()
  self:ClearTimer()
  local shopList = self:GetShopConfigList()
  if shopList then
    for i, shopCfg in ipairs(shopList) do
      if shopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.AppointedTime and shopCfg.m_RefreshParam ~= "" then
        local refreshTime = TimeUtil:TimeStringToTimeSec2(shopCfg.m_RefreshParam)
        local iServerTime = TimeUtil:GetServerTimeS()
        local iTime = refreshTime - iServerTime
        if 0 < iTime then
          local function OnTimerEnd(timerId)
            if self.m_iTimerHandlerTab then
              for m = #self.m_iTimerHandlerTab, 1, -1 do
                if self.m_iTimerHandlerTab[m] == timerId then
                  TimeService:KillTimer(self.m_iTimerHandlerTab[m])
                  
                  self.m_iTimerHandlerTab[m] = nil
                end
              end
            end
            if shopCfg and shopCfg.m_ShopID then
              self:ReqGetShopData(shopCfg.m_ShopID)
            end
          end
          
          self.m_iTimerHandlerTab[#self.m_iTimerHandlerTab + 1] = TimeService:SetTimer(2, 1, OnTimerEnd)
        end
      end
    end
  end
end

function ShopManager:CheckShopRedPointByShopId(shopId)
  local redFlag = false
  local shopGoods = self:GetShopGoodsByShopId(shopId)
  for i, goods in ipairs(shopGoods) do
    local goodCfg = self:GetShopGoodsConfig(goods.iGroupId, goods.iGoodsId)
    local currency = utils.changeCSArrayToLuaTable(goodCfg.m_Currency) or {}
    local finalPrice = currency[3]
    if finalPrice == 0 then
      local limit = self:CheckHaveAnyStock(shopId, goods.iGroupId, goods.iGoodsId)
      if limit then
        redFlag = true
        return redFlag
      end
    end
  end
  return redFlag
end

function ShopManager:GetAllShopRedPointInfo()
  local shopCfgList = self:GetShopConfigList(ShopManager.ShopType.ShopType_Normal)
  local redFlag = 0
  for i, goods in ipairs(shopCfgList) do
    local flag = self:CheckShopRedPointByShopId(goods.m_ShopID)
    if flag then
      redFlag = 1
      return redFlag
    end
  end
  return redFlag
end

function ShopManager:GetShopIdsByWindowId(winId)
  local idList = {}
  local ShopIns = ConfigManager:GetConfigInsByName("Shop")
  local shopAllCfg = ShopIns:GetAll()
  for i, itemCfg in pairs(shopAllCfg) do
    if itemCfg.m_WindowID == winId then
      idList[#idList + 1] = itemCfg.m_ShopID
    end
  end
  return idList
end

function ShopManager:CheckShopIsOpenByWinId(winId)
  local openFlag = false
  local idList = self:GetShopIdsByWindowId(winId)
  if #idList == 0 then
    return openFlag
  end
  for i, shopId in ipairs(idList) do
    local flag = UnlockSystemUtil:CheckShopIsOpenById(shopId)
    if flag then
      openFlag = true
      return openFlag
    end
  end
  return openFlag
end

return ShopManager
