local BaseManager = require("Manager/Base/BaseManager")
local GachaManager = class("GachaManager", BaseManager)
GachaManager.FirstGachaStr = "gacha"
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
GachaManager.WishListUnlockType = {GachaNum = 1}

function GachaManager:OnCreate()
  self.m_chooseWindowId = nil
  self.m_gachaAllCfg = nil
  self.m_passGachaGuideCheck = false
  self.m_gachaRecordList = {}
  self.m_gachaRecordTotal = {}
  self.m_gachaWishCount = {}
  self.mGachaPool = {}
  self:addEventListener("eGameEvent_GetGachaData", handler(self, self.OnGetGachaData))
  self:addEventListener("eGameEvent_VideoStart", handler(self, self.OnFirstGachaVideoPlayStart))
end

function GachaManager:OnInitNetwork()
end

function GachaManager:OnDailyReset()
  self:ReqGachaDataOnDailyReset()
end

function GachaManager:OnAfterInitConfig()
  GachaManager.GachaDiscountType = {
    Cheap = MTTDProto.GachaDiscountType_Cheap,
    Free = MTTDProto.GachaDiscountType_Free,
    SpecialTen = MTTDProto.GachaDiscountType_SpecialTen
  }
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  self.m_gachaAllCfg = GachaIns:GetAll()
end

function GachaManager:OnInitMustRequestInFetchMore()
  self.m_gachaClientData = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
  self:GetAllGachaWishList()
  self:GetGachaDataOnLogin()
end

function GachaManager:GetFirstGachaState()
  return self.m_gachaClientData
end

function GachaManager:SetFirstGachaState(str)
  self.m_gachaClientData = str
end

function GachaManager:ResetChooseWindowId()
  self.m_chooseWindowId = nil
end

function GachaManager:GetOpenGachPoolIDList()
  local gachaAllCfg = self:GetAllGacheCfg()
  local gachaIdList = {}
  for i, itemCfg in pairs(gachaAllCfg) do
    local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
      id = itemCfg.m_ActId,
      gacha_id = itemCfg.m_GachaID
    })
    if is_corved then
      if TimeUtil:IsInTime(t1, t2) then
        gachaIdList[#gachaIdList + 1] = itemCfg.m_GachaID
      end
    else
      gachaIdList[#gachaIdList + 1] = itemCfg.m_GachaID
    end
  end
  return gachaIdList
end

function GachaManager:GetGachaDataOnLogin()
  local gachaIdList = self:GetOpenGachPoolIDList()
  local reqMsg = MTTDProto.Cmd_Gacha_GetGacha_CS()
  reqMsg.vGachaId = gachaIdList
  RPCS():Gacha_GetGacha(reqMsg, function(sc)
    self.mGachaPool = sc.mGachaPool
  end)
end

function GachaManager:GetGachaData(chooseWindowId)
  local gachaIdList = self:GetOpenGachPoolIDList()
  self.m_chooseWindowId = chooseWindowId
  if #gachaIdList == 0 then
    return
  end
  self:ReqGetGachaData(gachaIdList)
end

function GachaManager:ReqGetGachaData(gachaIdList, callback)
  local reqMsg = MTTDProto.Cmd_Gacha_GetGacha_CS()
  reqMsg.vGachaId = gachaIdList
  RPCS():Gacha_GetGacha(reqMsg, function(sc)
    if callback then
      self.mGachaPool = sc.mGachaPool
      callback()
    else
      self:OnReqGetGachaDataSC(sc)
    end
  end)
end

function GachaManager:OnReqGetGachaDataSC(stData, msg)
  self.mGachaPool = stData.mGachaPool
  local windowId = self.m_chooseWindowId
  self:broadcastEvent("eGameEvent_GetGachaData", windowId)
  self.m_chooseWindowId = nil
end

function GachaManager:ReqGachaDataOnDailyReset()
  local gachaIdList = self:GetOpenGachPoolIDList()
  local reqMsg = MTTDProto.Cmd_Gacha_GetGacha_CS()
  reqMsg.vGachaId = gachaIdList
  RPCS():Gacha_GetGacha(reqMsg, handler(self, self.OnGachaDataDailyResetSc))
end

function GachaManager:OnGachaDataDailyResetSc(stData, msg)
  if not stData then
    return
  end
  self.mGachaPool = stData.mGachaPool
  self:broadcastEvent("eGameEvent_Gacha_DailyResetGetData")
end

function GachaManager:OnReqGetGachaDataFailed(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  self.m_chooseWindowId = nil
  NetworkManager:OnRpcCallbackFail(msg)
end

function GachaManager:ReqDoGacha(iGachaId, iTimesType, bUseCost, iDiscountType)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local reqMsg = MTTDProto.Cmd_Gacha_DoGacha_CS()
  reqMsg.iGachaId = iGachaId
  reqMsg.iTimesType = iTimesType
  reqMsg.bUseCost = bUseCost
  reqMsg.iDiscountType = iDiscountType or 0
  RPCS():Gacha_DoGacha(reqMsg, handler(self, self.OnReqDoGachaSC))
end

function GachaManager:OnReqDoGachaSC(stData, msg)
  self:SetGachaCountById(stData.iGachaId, stData.iGachaTimes)
  self:SetGachaDailyTimesById(stData.iGachaId, stData.iDailyTimes)
  self:SetGachaDailyCheapTimesById(stData.iGachaId, stData.iCheapTimes)
  self:SetGachDailyFreeTimesById(stData.iGachaId, stData.iFreeTimes)
  self:SetGacha10DailyFreeTimesById(stData.iGachaId, stData.iFreeTimesTen)
  self:broadcastEvent("eGameEvent_DoGacha", stData)
end

function GachaManager:ReqGachaSetWishList(iGachaId, vHeroIdList)
  local reqMsg = MTTDProto.Cmd_Gacha_SetWishList_CS()
  reqMsg.iGachaId = iGachaId
  reqMsg.vHeroIdList = vHeroIdList
  RPCS():Gacha_SetWishList(reqMsg, handler(self, self.OnReqGachaSetWishListSC))
end

function GachaManager:OnReqGachaSetWishListSC(stData, msg)
  local gachaPool = self.mGachaPool[stData.iGachaId] or {}
  gachaPool.vWishList = stData.vHeroIdList
  self.mGachaPool[stData.iGachaId] = gachaPool
  self:broadcastEvent("eGameEvent_SaveGachaWishHeroList")
end

function GachaManager:ReqGachaGetWishList(iGachaId)
  local reqMsg = MTTDProto.Cmd_Gacha_GetWishList_CS()
  reqMsg.iGachaId = iGachaId
  RPCS():Gacha_GetWishList(reqMsg, handler(self, self.OnReqGachaGetWishListSC))
end

function GachaManager:OnReqGachaGetWishListSC(stData, msg)
  local gachaPool = self.mGachaPool[stData.iGachaId] or {}
  gachaPool.vWishList = stData.vHeroIdList
  self.mGachaPool[stData.iGachaId] = gachaPool
  self:broadcastEvent("eGameEvent_GetGachaWishHeroList")
end

function GachaManager:ReqGachaGetRecordListCS(iGachaId, iBegin, iEnd)
  if iBegin == 1 then
    self:ResetGachaRecordById(iGachaId)
  end
  local reqMsg = MTTDProto.Cmd_Gacha_GetRecord_CS()
  reqMsg.iGachaId = iGachaId
  reqMsg.iBegin = iBegin
  reqMsg.iEnd = iEnd
  RPCS():Gacha_GetRecord(reqMsg, handler(self, self.OnReqGachaGetRecordListSC))
end

function GachaManager:OnReqGachaGetRecordListSC(stData, msg)
  if not self.m_gachaRecordList[stData.iGachaId] then
    self.m_gachaRecordList[stData.iGachaId] = stData.vRecord
  else
    table.insertto(self.m_gachaRecordList[stData.iGachaId], stData.vRecord)
  end
  self.m_gachaRecordTotal[stData.iGachaId] = stData.iTotal
  self:broadcastEvent("eGameEvent_GetGachaRecord", stData)
end

function GachaManager:ReqFirstGachaGetWishList(iGachaId)
  local reqMsg = MTTDProto.Cmd_Gacha_GetWishList_CS()
  reqMsg.iGachaId = iGachaId
  RPCS():Gacha_GetWishList(reqMsg, handler(self, self.OnReqFirstGachaGetWishListSC))
end

function GachaManager:OnReqFirstGachaGetWishListSC(stData, msg)
  local gachaPool = self.mGachaPool[stData.iGachaId] or {}
  gachaPool.vWishList = stData.vHeroIdList
  self.mGachaPool[stData.iGachaId] = gachaPool
end

function GachaManager:GetGachaWishListById(iGachaId)
  local gachaPool = self.mGachaPool[iGachaId] or {}
  return gachaPool.vWishList or {}
end

function GachaManager:GetGachaDailyTimesById(iGachaId)
  local gachaPool = self.mGachaPool[iGachaId] or {}
  return gachaPool.iDailyTimes or 0
end

function GachaManager:SetGachaDailyTimesById(gachaId, times)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.iDailyTimes = times
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:CheckIsWishHero(iGachaId, heroId)
  local isActivate = self:CheckWishHeroIsActivate(iGachaId)
  if isActivate then
    return table.indexof(self:GetGachaWishListById(iGachaId), heroId)
  end
end

function GachaManager:CheckIsUpHero(iGachaId, heroId)
  local cfg = self:GetGachaConfig(iGachaId)
  if not cfg then
    return false
  end
  local upHeroId = cfg.m_Upprotect
  if upHeroId == heroId then
    return true
  end
  return false
end

function GachaManager:GetAllGachaWishList()
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  local gachaAllCfg = GachaIns:GetAll()
  local gachaId
  for i, itemCfg in pairs(gachaAllCfg) do
    if itemCfg.m_WishListID and itemCfg.m_WishListID ~= 0 then
      gachaId = itemCfg.m_GachaID
      break
    end
  end
  self:ReqFirstGachaGetWishList(gachaId)
end

function GachaManager:GetWishHeroIdByCamp(gachaId, camp)
  local wishList = {}
  local gachaPool = self.mGachaPool[gachaId] or {}
  if gachaPool.vWishList then
    for i, v in pairs(gachaPool.vWishList) do
      local characterCfg = HeroManager:GetHeroConfigByID(v)
      if characterCfg.m_Camp == camp then
        wishList[#wishList + 1] = v
      end
    end
  end
  return wishList
end

function GachaManager:GetGachaConfig(gachaId)
  if not gachaId then
    log.error("UnlockSystemUtil GetGachaUnlockConfig gachaId = nil")
    return
  end
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  local gachaCfg = GachaIns:GetValue_ByGachaID(gachaId)
  if gachaCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByGachaID is error " .. tostring(gachaId))
    return
  end
  return gachaCfg
end

function GachaManager:GetGachaConfigByWindowId(windowId)
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  local gachaAllCfg = GachaIns:GetAll()
  for i, itemCfg in pairs(gachaAllCfg) do
    if itemCfg.m_windowID == windowId then
      return itemCfg
    end
  end
  return nil
end

function GachaManager:GetGachaCostDataByType(gachaID, gachaType)
  local costNum = 0
  local costItemId = 0
  local wishCostId = 0
  local wishCostNum = 0
  local gachaConfig = self:GetGachaConfig(gachaID)
  local wishToken = {}
  if gachaType == 1 then
    wishToken = utils.changeCSArrayToLuaTable(gachaConfig.m_Wish1Token)
  else
    wishToken = utils.changeCSArrayToLuaTable(gachaConfig.m_Wish10Token)
  end
  if wishToken and 0 < #wishToken then
    wishCostId = wishToken[1]
    local itemNum = wishToken[2]
    local userNum = ItemManager:GetItemNum(tonumber(wishCostId), true)
    if itemNum <= userNum then
      costNum = 0
      costItemId = 0
      wishCostNum = itemNum
    else
      costNum, costItemId = self:GetGachaCostNumByCount(gachaConfig, itemNum - userNum)
      wishCostNum = userNum
    end
  else
    wishCostId, wishCostNum = 0, 0
  end
  return wishCostId, wishCostNum, costItemId, costNum
end

function GachaManager:GetGachaCostNumByCount(gachaConfig, needCount)
  local costCount = 0
  local costId = -1
  local wishCost = utils.changeCSArrayToLuaTable(gachaConfig.m_WishCost)
  if wishCost and _G.next(wishCost) then
    local itemId = wishCost[1]
    local itemNum = wishCost[2]
    costCount = tonumber(itemNum) * needCount
    local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
    costId = costCount <= userNum and itemId or 0
  end
  return costCount, costId
end

function GachaManager:RequestGachaResult(param)
  local wishCostNum = param.wishCostNum
  local wishCostId = param.wishCostId
  local costNum = param.costNum
  local costItemId = param.costItemId
  local iGachaId = param.iGachaId
  local iTimesType = param.iTimesType
  local iDiscountType = param.iDiscountType or 0
  if not wishCostId and not costItemId then
    wishCostId, wishCostNum, costItemId, costNum = self:GetGachaCostDataByType(iGachaId, iTimesType)
  end
  if iTimesType == 1 and iDiscountType == 0 then
    local curGachaCfg = self:GetGachaConfig(iGachaId)
    if curGachaCfg and 0 < curGachaCfg.m_FreeTimes then
      local curDayUseFreeTimes = self:GetGachaFreeTimes(curGachaCfg.m_GachaID)
      local leftFreeTimes = curGachaCfg.m_FreeTimes - curDayUseFreeTimes
      if 0 < leftFreeTimes then
        self:ReqDoGacha(iGachaId, iTimesType, false, 0)
        return
      end
    end
  end
  if iTimesType == 10 and iDiscountType == 3 then
    self:ReqDoGacha(iGachaId, 10, false, 3)
    return
  end
  if iDiscountType ~= 0 then
    self:ReqDoGacha(iGachaId, iTimesType, true, iDiscountType)
  elseif wishCostNum and 0 < wishCostNum and costNum == 0 and costItemId ~= -1 then
    self:ReqDoGacha(iGachaId, iTimesType, false, 0)
  elseif wishCostId == 0 and wishCostNum == 0 and costNum and 0 < costNum and costItemId ~= 0 then
    self:ReqDoGacha(iGachaId, iTimesType, true, 0)
  elseif wishCostId and 0 < wishCostId and wishCostNum and 0 <= wishCostNum and costNum and 0 < costNum then
    local msg_id
    if costItemId == 0 then
      msg_id = 30004
      local gachaConfig = self:GetGachaConfig(iGachaId)
      local wishCost = utils.changeCSArrayToLuaTable(gachaConfig.m_WishCost)
      costItemId = wishCost[1]
    end
    local userNum = ItemManager:GetItemNum(tonumber(wishCostId), true)
    local itemCfg = ItemManager:GetItemConfigById(costItemId)
    if itemCfg == nil then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
      return
    end
    utils.ShowCommonTipCost({
      beforeItemID = costItemId,
      beforeItemNum = costNum,
      afterItemID = wishCostId,
      afterItemNum = iTimesType - userNum,
      commonTextID = 100067,
      formatFun = function(msg_str)
        local token_cfg = ItemManager:GetItemConfigById(wishCostId)
        return string.gsubnumberreplace(msg_str, tostring(iTimesType - userNum), tostring(token_cfg.m_mItemName), costNum, tostring(itemCfg.m_mItemName))
      end,
      funSure = function()
        if msg_id then
          utils.CheckAndPushCommonTips({
            tipsID = 1222,
            func1 = function()
              QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
            end
          })
          return
        end
        if not UnlockSystemUtil:CheckGachaIsOpenById(iGachaId) then
          utils.CheckAndPushCommonTips({
            tipsID = 1209,
            func1 = function()
            end
          })
          return
        end
        self:ReqDoGacha(iGachaId, iTimesType, true, 0)
      end
    })
  elseif costNum and 0 < costNum and costItemId == 0 then
    local gachaConfig = self:GetGachaConfig(iGachaId)
    local wishCost = utils.changeCSArrayToLuaTable(gachaConfig.m_WishCost)
    costItemId = wishCost[1]
    if costItemId == MTTDProto.SpecialItem_FreeDiamond or costItemId == MTTDProto.SpecialItem_Diamond then
      utils.CheckAndPushCommonTips({
        tipsID = 1222,
        func1 = function()
          QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
        end
      })
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
    end
  elseif costItemId == -1 then
    local gachaConfig = self:GetGachaConfig(iGachaId)
    if gachaConfig.m_ShopJump and gachaConfig.m_ShopJump ~= 0 then
      utils.popUpDirectionsUI({
        tipsID = gachaConfig.m_ConfirmText,
        func1 = function()
          local expra = {
            defeatShow = function()
              StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
            end
          }
          QuickOpenFuncUtil:OpenFunc(gachaConfig.m_ShopJump, expra)
        end
      })
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
    end
  end
end

function GachaManager:GetGachaCountById(gachaId)
  local gachaPool = self.mGachaPool[gachaId]
  if gachaPool then
    return gachaPool.iGachaTimes or 0
  end
  return 0
end

function GachaManager:SetGachaDailyCheapTimesById(gachaId, times)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.iCheapTimes = times
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:GetGachaCheapTimes(gachaId)
  local gachaPool = self.mGachaPool[gachaId]
  if gachaPool then
    return gachaPool.iCheapTimes or 0
  end
  return 0
end

function GachaManager:SetGachDailyFreeTimesById(gachaId, times)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.iFreeTimes = times
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:GetGachaFreeTimes(gachaId)
  local gachaPool = self.mGachaPool[gachaId]
  if gachaPool then
    return gachaPool.iFreeTimes or 0
  end
  return 0
end

function GachaManager:SetGachaCountById(gachaId, num)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.iGachaTimes = num
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:CheckGachaPoolHaveRedDotById(gachaId)
  local show = false
  local flag = UnlockSystemUtil:CheckGachaIsOpenById(gachaId)
  if flag then
    local cfg = self:GetGachaConfig(gachaId)
    local wish10Token = cfg.m_Wish10Token
    if wish10Token.Length > 0 then
      local itemId = wish10Token[0]
      local itemNum = wish10Token[1]
      local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
      if itemNum <= userNum then
        show = true
      end
    end
    if self:IsHaveSpecialGacha10(gachaId) then
      show = true
    end
    if 0 < cfg.m_DailyMax then
      local dailyTimes = self:GetGachaDailyTimesById(gachaId)
      dailyTimes = cfg.m_DailyMax - dailyTimes
      if dailyTimes < 10 then
        show = false
      end
    end
    if self:CheckStepGachaHaveRedPoint(gachaId) then
      show = true
    end
    local redDot = self:CheckDailyFreeGachaRedDotById(gachaId)
    if redDot then
      show = true
    end
  end
  return show
end

function GachaManager:CheckGachaPoolHaveRedDot()
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  local gachaAllCfg = GachaIns:GetAll()
  local gachaIdList = {}
  if gachaAllCfg then
    for i, itemCfg in pairs(gachaAllCfg) do
      local flag = UnlockSystemUtil:CheckGachaIsOpenById(itemCfg.m_GachaID)
      if flag then
        gachaIdList[#gachaIdList + 1] = itemCfg.m_GachaID
        local show = false
        local wish10Token = itemCfg.m_Wish10Token
        if wish10Token.Length > 0 then
          local itemId = wish10Token[0]
          local itemNum = wish10Token[1]
          local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
          if itemNum <= userNum then
            show = true
          end
        end
        if self:IsHaveSpecialGacha10(itemCfg.m_GachaID) then
          show = true
        end
        local gachaDailyMax = itemCfg.m_DailyMax
        if gachaDailyMax and 0 < tonumber(gachaDailyMax) then
          local dailyTimes = self:GetGachaDailyTimesById(itemCfg.m_GachaID)
          dailyTimes = gachaDailyMax - dailyTimes
          if dailyTimes < 10 then
            show = false
          end
        end
        if self:CheckStepGachaHaveRedPoint(itemCfg.m_GachaID) then
          show = true
        end
        if show then
          return show
        end
      end
    end
    for i, gachaId in ipairs(gachaIdList) do
      local isOpen = PlayerPrefs.GetInt("Gacha_" .. tostring(gachaId), 0)
      if isOpen ~= 1 then
        return true
      end
      local redDot = self:CheckDailyFreeGachaRedDotById(gachaId)
      if redDot then
        return true
      end
    end
  end
  return false
end

function GachaManager:CheckStepGachaHaveRedPoint(gachaId)
  local gachaConfig = self:GetGachaConfig(gachaId)
  if gachaConfig.m_StepID > 0 then
    local gachaCount = self:GetGachaCountById(gachaId)
    local gachaStepIns = ConfigManager:GetConfigInsByName("GachaStep")
    local gachaStepCfg = gachaStepIns:GetValue_ByStepID(gachaConfig.m_StepID) or {}
    for i, v in pairs(gachaStepCfg) do
      if gachaCount >= v.m_GachaNum and not self:IsStepReceived(gachaId, i) then
        return true
      end
    end
  end
  return false
end

function GachaManager:CheckGacha10ShowRedPoint(gachaConfig)
  local wish10Token = utils.changeCSArrayToLuaTable(gachaConfig.m_Wish10Token)
  if wish10Token and 0 < #wish10Token then
    local itemId = wish10Token[1]
    local itemNum = wish10Token[2]
    local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
    if itemNum <= userNum then
      return true
    end
  end
  return false
end

function GachaManager:CheckGachaResultShowSex(heroList)
  local quality = 0
  local sex = 2
  for i, v in ipairs(heroList) do
    if v.heroId then
      local cfg = HeroManager:GetHeroConfigByID(v.heroId)
      if quality < cfg.m_Quality then
        quality = cfg.m_Quality
        sex = cfg.m_Gender
      end
    end
  end
  return sex
end

function GachaManager:GetGachaWishListConfig(wishListID)
  local GachaWishListIns = ConfigManager:GetConfigInsByName("GachaWishList")
  local gachaCfg = GachaWishListIns:GetValue_ByWishListID(wishListID)
  if gachaCfg:GetError() then
    return
  end
  return gachaCfg
end

function GachaManager:CheckGachaWishListUnlock(wishListID)
  local unlockType = 0
  local unlockValue = {}
  local cfg = self:GetGachaWishListConfig(wishListID)
  if cfg then
    unlockType = cfg.m_UnlockType
    unlockValue = cfg.m_UnlockValue
  end
  if unlockType == GachaManager.WishListUnlockType.GachaNum and unlockValue and unlockValue[0] then
    local gachaPool = self.mGachaPool[unlockValue[0]] or {}
    if gachaPool.iGachaTimes and gachaPool.iGachaTimes >= unlockValue[1] then
      return true
    else
      return false, unlockValue[1] - (gachaPool.iGachaTimes or 0)
    end
  end
end

function GachaManager:GetGachaWishCfgHeroList(wishListID, heroCamp)
  local heroIdMap = {}
  local cfg = self:GetGachaWishListConfig(wishListID)
  if cfg then
    local GachaPoolIns = ConfigManager:GetConfigInsByName("GachaPool")
    local gachaPoolCfg = GachaPoolIns:GetValue_ByPoolID(cfg.m_PoolID)
    if gachaPoolCfg and not gachaPoolCfg:GetError() then
      local poolContent = utils.changeCSArrayToLuaTable(gachaPoolCfg.m_PoolContent)
      if ActivityManager:IsInCensorOpen() then
        poolContent = utils.changeCSArrayToLuaTable(gachaPoolCfg.m_CensorPoolContent)
      end
      for m, n in pairs(poolContent) do
        if heroCamp then
          local heroCfg = HeroManager:GetHeroConfigByID(n[1])
          if heroCfg and heroCamp == heroCfg.m_Camp then
            heroIdMap[n[1]] = {
              n[1],
              n[3]
            }
          end
        else
          heroIdMap[n[1]] = {
            n[1],
            n[3]
          }
        end
      end
    end
  end
  return heroIdMap
end

function GachaManager:GenerateGachaWishHeroData(params)
  local data = {
    serverData = {}
  }
  local heroData = HeroManager:GetHeroDataByID(params[1])
  if heroData then
    data.serverData = table.deepcopy(heroData.serverData)
    data.characterCfg = heroData.characterCfg
    if params[2] then
      data.serverData.chance = params[2] / 10000
    end
  else
    local chance
    if params[2] then
      chance = params[2] / 10000
    end
    data.serverData = {
      iHeroId = params[1],
      iLevel = nil,
      chance = chance,
      notHave = true
    }
    data.characterCfg = HeroManager:GetHeroConfigByID(params[1])
  end
  data.isShowMoon = true
  data.isHideLv = true
  return data
end

function GachaManager:CheckWishHeroIsActivate(gachaId)
  local gachaConfig = self:GetGachaConfig(gachaId)
  local wishList = self:GetGachaWishListById(gachaId)
  if gachaConfig then
    if not self.m_gachaWishCount[gachaConfig.m_WishListID] then
      local cfg = self:GetGachaWishListConfig(gachaConfig.m_WishListID)
      if cfg then
        local listNum = utils.changeCSArrayToLuaTable(cfg.m_ListNum)
        local num = 0
        for i, v in ipairs(listNum) do
          num = num + v[2]
        end
        self.m_gachaWishCount[gachaConfig.m_WishListID] = num
        if num <= table.getn(wishList) then
          return true
        end
      end
    elseif table.getn(wishList) >= self.m_gachaWishCount[gachaConfig.m_WishListID] then
      return true
    end
  end
  return false
end

function GachaManager:GetWishHeroChance(gachaId)
  local heroChanceTab = {}
  local gachaConfig = self:GetGachaConfig(gachaId)
  if gachaConfig and gachaConfig.m_WishListID ~= 0 then
    local flag = self:CheckGachaWishListUnlock(gachaConfig.m_WishListID)
    local activeFlag = self:CheckWishHeroIsActivate(gachaId)
    if flag and activeFlag then
      local heroIdList = self:GetGachaWishListById(gachaId)
      local idMap = self:GetGachaWishCfgHeroList(gachaConfig.m_WishListID)
      for i, v in pairs(heroIdList) do
        if idMap[v] and idMap[v][2] then
          heroChanceTab[v] = idMap[v][2]
        end
      end
    end
  end
  return heroChanceTab
end

function GachaManager:GetWishHeroCamp(gachaId)
  local gachaConfig = self:GetGachaConfig(gachaId)
  local campList = {}
  if gachaConfig then
    local cfg = self:GetGachaWishListConfig(gachaConfig.m_WishListID)
    if cfg then
      local listNum = utils.changeCSArrayToLuaTable(cfg.m_ListNum)
      for i, v in ipairs(listNum) do
        campList[v[1]] = v[1]
      end
    end
  end
  return campList
end

function GachaManager:SetGachaGuideCheckFlag(flag)
  self.m_passGachaGuideCheck = flag
end

function GachaManager:GetGachaGuideCheckFlag()
  return self.m_passGachaGuideCheck
end

function GachaManager:OnGetGachaData(windowId)
  local str = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
  if str ~= GachaManager.FirstGachaStr then
    if ActivityManager:IsInCensorOpen() then
      CS.UI.UILuaHelper.PlayFromAddRes("Censor_Black", "", true, handler(self, self.OnFirstGachaVideoPlayFinish), CS.UnityEngine.ScaleMode.ScaleToFit, false)
    else
      CS.UI.UILuaHelper.PlayFromAddRes("Gacha_Enter_1stTime", "Gacha_Enter_1stTime", true, handler(self, self.OnFirstGachaVideoPlayFinish), CS.UnityEngine.ScaleMode.ScaleToFit, false)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(91)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(92)
    end
  else
    self:OpenGachaMainUI(windowId)
  end
end

function GachaManager:OnFirstGachaVideoPlayStart(videoName)
  if (videoName == "Gacha_Enter_1stTime" or videoName == "Censor_Black") and not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHAMAIN) then
    self:OpenGachaMainUI()
  end
end

function GachaManager:OnFirstGachaVideoPlayFinish()
  if not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHAMAIN) then
    self:OpenGachaMainUI()
  end
  if not ActivityManager:IsInCensorOpen() then
    CS.GlobalManager.Instance:StopWwiseVoice("Gacha_Enter_1stTime")
    CS.GlobalManager.Instance:StopWwiseVoice("Vo_Gacha_Enter_1stTime")
  end
  self:broadcastEvent("eGameEvent_GachaFirstVideoFinish")
end

function GachaManager:OpenGachaMainUI(windowId)
  local isPlayAudio = true
  StackFlow:Push(UIDefines.ID_FORM_GACHAMAIN, {windowId = windowId, isPlayAudio = isPlayAudio})
end

function GachaManager:SetSkippedInteract(isSkip)
  self.m_SkippedInteract = isSkip
end

function GachaManager:IsSkippedInteract()
  return self.m_SkippedInteract
end

function GachaManager:SetSkippedHeroShow(isSkip)
  self.m_SkippedHeroShow = isSkip
end

function GachaManager:IsSkippedHeroShow()
  return self.m_SkippedHeroShow
end

function GachaManager:IsShippedALl()
  return self.m_SkippedHeroShow or UILuaHelper.PlayVideoIsSkipped()
end

function GachaManager:GetHeroDataAndPreLoadVideo(idList)
  local heroDataList = {}
  local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  for i, v in ipairs(idList) do
    local characterInfoCfg = CharacterInfoIns:GetValue_ByHeroID(v.iID)
    if not characterInfoCfg:GetError() then
      local video = characterInfoCfg.m_Video or ""
      if video ~= "" then
        CS.UI.UILuaHelper.PreLoadTimeLine(video)
      end
      heroDataList[#heroDataList + 1] = {
        video = video,
        heroId = v.iID,
        quality = characterInfoCfg.m_Quality
      }
    end
  end
  return heroDataList
end

function GachaManager:GetGachaRecordListById(gachaId)
  return self.m_gachaRecordList[gachaId]
end

function GachaManager:GetGachaRecordTotalById(gachaId)
  return self.m_gachaRecordTotal[gachaId]
end

function GachaManager:ResetGachaRecordById(gachaId)
  self.m_gachaRecordList[gachaId] = nil
  self.m_gachaRecordTotal[gachaId] = nil
end

function GachaManager:GetAllGacheCfg()
  if not self.m_gachaAllCfg then
    local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
    self.m_gachaAllCfg = GachaIns:GetAll()
  end
  return self.m_gachaAllCfg
end

function GachaManager:GetHallDownTimePoolAndLeftTime()
  local gachaAllCfg = self:GetAllGacheCfg()
  local tempCachaDataList = {}
  for i, itemCfg in pairs(gachaAllCfg) do
    local isCovered, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
      id = itemCfg.m_ActId,
      gacha_id = itemCfg.m_GachaID
    })
    if isCovered and TimeUtil:IsInTime(t1, t2) then
      local endTimer = t2
      tempCachaDataList[#tempCachaDataList + 1] = {
        endTimer = endTimer,
        gachaID = itemCfg.m_GachaID
      }
    end
  end
  table.sort(tempCachaDataList, function(a, b)
    if a.endTimer ~= b.endTimer then
      return a.endTimer < b.endTimer
    end
    return a.gachaID > b.gachaID
  end)
  return tempCachaDataList[1]
end

function GachaManager:SetGacha10DailyFreeTimesById(gachaId, times)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.iFreeTimesTen = times
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:GetGacha10FreeTimes(gachaId)
  local gachaPool = self.mGachaPool[gachaId]
  if gachaPool then
    return gachaPool.iFreeTimesTen or 0
  end
  return 0
end

function GachaManager:GetGacha10DailyFreeCfgTimesById(gachaId)
  local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_GachaFree)
  if table.getn(activityList) == 0 then
    return
  end
  for _, act in pairs(activityList) do
    if act:checkCondition() and act.GetActCommonCfg then
      local cfg = act:GetActCommonCfg()
      if cfg and cfg.iGachaId == gachaId then
        return cfg.iDailyFreeTimesTen
      end
    end
  end
end

function GachaManager:GetGacha10DailyFreeActiveById(gachaId)
  local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_GachaFree)
  if table.getn(activityList) == 0 then
    return
  end
  for _, act in pairs(activityList) do
    if act:checkCondition() and act.GetActCommonCfg then
      local cfg = act:GetActCommonCfg()
      if cfg and cfg.iGachaId == gachaId then
        return act, cfg
      end
    end
  end
end

function GachaManager:CheckGacha10HaveFreeTimesById(gachaId)
  local iDailyFreeTimesTen = self:GetGacha10DailyFreeCfgTimesById(gachaId)
  if not iDailyFreeTimesTen then
    return
  end
  local curDayUseFreeTimes = self:GetGacha10FreeTimes(gachaId)
  local leftFreeTimes = iDailyFreeTimesTen - curDayUseFreeTimes
  return 0 < leftFreeTimes
end

function GachaManager:CheckIsLastDayById(gachaId)
  local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_GachaFree)
  if table.getn(activityList) == 0 then
    return
  end
  for _, act in pairs(activityList) do
    if act:checkCondition() and act.GetActCommonCfg then
      local cfg = act:GetActCommonCfg()
      if cfg and cfg.iGachaId == gachaId then
        local endTime = act:GetActivityEndTime()
        if endTime == 0 then
          return false
        end
        local time = endTime - TimeUtil:GetServerTimeS()
        return time <= TimeUtil:GetOneDayOfSecond()
      end
    end
  end
end

function GachaManager:CheckDailyFreeGachaRedDotById(gachaId)
  local redDot = false
  redDot = self:CheckGacha1HaveRedDotById(gachaId)
  if redDot then
    return redDot
  end
  redDot = self:CheckGacha10HaveFreeTimesById(gachaId)
  return redDot
end

function GachaManager:CheckGacha1HaveRedDotById(gachaId)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  if openFlag then
    local cfg = self:GetGachaConfig(gachaId)
    if cfg then
      local curDayUseFreeTimes = self:GetGachaFreeTimes(cfg.m_GachaID)
      local leftFreeTimes = cfg.m_FreeTimes - curDayUseFreeTimes
      if 0 < leftFreeTimes then
        return true
      end
    end
  end
end

function GachaManager:IsHaveSpecialGacha10(gachaId)
  local gachaConfig = self:GetGachaConfig(gachaId)
  local specialWish10Token = utils.changeCSArrayToLuaTable(gachaConfig.m_Special10Token)
  if specialWish10Token and 0 < #specialWish10Token then
    local itemId = specialWish10Token[1]
    local itemNum = specialWish10Token[2]
    local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
    if itemNum <= userNum then
      return true, itemId, itemNum, userNum
    end
  end
  return false
end

function GachaManager:GetGachaTakenStepSeqById(iGachaId)
  local gachaPool = self.mGachaPool[iGachaId] or {}
  return gachaPool.vTakenStepSeq or {}
end

function GachaManager:SetGachaTakenStepSeqById(gachaId, takenStepSeq)
  local gachaPool = self.mGachaPool[gachaId] or {}
  gachaPool.vTakenStepSeq = takenStepSeq
  self.mGachaPool[gachaId] = gachaPool
end

function GachaManager:IsStepReceived(iGachaId, stepId)
  local takenStepSeq = self:GetGachaTakenStepSeqById(iGachaId)
  for _, claimedId in ipairs(takenStepSeq) do
    if claimedId == stepId then
      return true
    end
  end
  return false
end

return GachaManager
