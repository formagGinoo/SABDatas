local BaseActivity = require("Base/BaseActivity")
local BattlePassActivity = class("BattlePassActivity", BaseActivity)

function BattlePassActivity.getActivityType(_)
  return MTTD.ActivityType_BattlePass
end

function BattlePassActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgBattlePass
end

function BattlePassActivity.getStatusProto(_)
  return MTTDProto.CmdActBattlePass_Status
end

function BattlePassActivity:RequestActData(cb)
  local reqMsg = MTTDProto.Cmd_Act_GetStatusById_CS()
  reqMsg.vActivityId = {
    self:getID()
  }
  RPCS():Act_GetStatusById(reqMsg, function(sc, msg)
    local vStatus = sc.vStatus
    for k, v in ipairs(vStatus) do
      if v.iActivityId == self:getID() then
        self.m_stActivityData.sStatusDataSdp = v.sStatusDataSdp
        self:resetStatusData()
        self:RequestQuests(true, function()
          if cb then
            cb()
          end
        end)
        break
      end
    end
  end)
end

function BattlePassActivity:RequestGetLevelReward(iLevel, callback)
  local reqMsg = MTTDProto.Cmd_Act_BattlePass_GetLevelReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iLevel = iLevel
  RPCS():Act_BattlePass_GetLevelReward(reqMsg, function(sc, msg)
    local vReward = sc.vReward
    local mChangeReward = sc.mChangeReward or nil
    utils.popUpRewardUI(vReward, nil, mChangeReward)
    if callback then
      callback()
    end
    self:broadcastEvent("eGameEvent_Activity_BattlePass_RedRefresh", self:getID())
    self:broadcastEvent("eGameEvent_Activity_BattlePass_RewardGet", self:getID())
  end)
end

function BattlePassActivity:RequestReceiveTask(vQuestId, callback)
  local reqMsg = MTTDProto.Cmd_Quest_TakeReward_CS()
  reqMsg.iQuestType = self:getID()
  reqMsg.vQuestId = vQuestId
  RPCS():Quest_TakeReward(reqMsg, function(sc, msg)
    if callback then
      callback()
    end
    self:broadcastEvent("eGameEvent_Activity_BattlePass_ReceiveTaskReward", {
      iActivityID = self:getID()
    })
    self:broadcastEvent("eGameEvent_Activity_BattlePass_RedRefresh", self:getID())
  end)
end

function BattlePassActivity:RequestBuyExp(buyExpNum, callback)
  local reqMsg = MTTDProto.Cmd_Act_BattlePass_BuyExp_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iBuyExp = buyExpNum
  RPCS():Act_BattlePass_BuyExp(reqMsg, function(sc, msg)
    if callback then
      callback()
    end
    self:broadcastEvent("eGameEvent_Activity_BattlePass_BuyExp", {
      iActivityID = self:getID()
    })
    self:broadcastEvent("eGameEvent_Activity_BattlePass_RedRefresh", self:getID())
  end)
end

function BattlePassActivity:RequestQuests(bForce, callback)
  if self.m_questStatus == nil or bForce then
    self.m_questStatus = {}
    local reqMsg = MTTDProto.Cmd_Quest_GetList_CS()
    reqMsg.iQuestType = self:getID()
    RPCS():Quest_GetList(reqMsg, function(sc, msg)
      local vQuest = sc.vQuest
      for k, v in ipairs(vQuest) do
        self.m_questStatus[v.iId] = v
      end
      self:broadcastEvent("eGameEvent_Activity_BattlePass_RedRefresh", self:getID())
      if callback then
        callback()
      end
    end)
  elseif callback then
    callback()
  end
end

function BattlePassActivity:OnResetSdpConfig()
  if self.m_stSdpConfig then
    self.m_stCommonCfg = self.m_stSdpConfig.stCommonCfg
    self.m_stClientCfg = self.m_stSdpConfig.stClientCfg
    self.m_vLevelCfg = {}
    local mLevelCfg = self.m_stSdpConfig.stCommonCfg.mLevelCfg
    for k, v in pairs(mLevelCfg) do
      self.m_vLevelCfg[checknumber(k)] = v
    end
  end
end

function BattlePassActivity:GetAllLevelReward()
  local maxLevel = self:GetMaxLevel()
  if maxLevel > self:GetCurLevel() then
    return false
  end
  for k = 1, maxLevel do
    if self:GetDrawStatus(k) ~= 2 then
      return false
    end
  end
  return true
end

function BattlePassActivity:DrawAllTask(callback)
  local vQuestId = {}
  if not self.m_questStatus then
    return
  end
  for k, v in pairs(self.m_questStatus) do
    if v.iState == MTTDProto.QuestState_Finish then
      table.insert(vQuestId, v.iId)
    end
  end
  self:RequestReceiveTask(vQuestId, callback)
end

function BattlePassActivity:ReachMaxLevel()
  return self:GetCurLevel() >= self:GetMaxLevel()
end

function BattlePassActivity:GetMaxLevel()
  return #self.m_vLevelCfg
end

function BattlePassActivity:GetCurLevel()
  return self.m_stStatusData.iCurLevel
end

function BattlePassActivity:GetCurExp()
  return self.m_stStatusData.iCurExp
end

function BattlePassActivity:GetBuyStatus()
  return self.m_stStatusData.iBuyStatus
end

function BattlePassActivity:IsHaveBuy()
  return self.m_stStatusData.iBuyStatus > ActivityManager.BattlePassBuyStatus.Free
end

function BattlePassActivity:GetQuests()
  return self.m_stStatusData.vQuestId
end

function BattlePassActivity:GetQuestStatus(iQuestId)
  return self.m_questStatus[iQuestId]
end

function BattlePassActivity:GetLevelCfg(iLevel)
  if iLevel == nil then
    return self.m_vLevelCfg
  end
  return self.m_vLevelCfg[iLevel]
end

function BattlePassActivity:GetFinalLevelCfg()
  return self.m_vLevelCfg[#self.m_vLevelCfg]
end

function BattlePassActivity:GetUpLevelExp()
  if not self.m_stSdpConfig then
    return
  end
  return self.m_stSdpConfig.stCommonCfg.iUpLevelExp
end

function BattlePassActivity:GetCostPerExp()
  return self.m_stSdpConfig.stCommonCfg.iCostPerExp
end

function BattlePassActivity:GetNormalCostRatio()
  return self.m_stSdpConfig.stCommonCfg.iNormalCostRatio
end

function BattlePassActivity:GetAdvancedCostRatio()
  return self.m_stSdpConfig.stCommonCfg.iAdvancedCostRatio
end

function BattlePassActivity:GetAdvancedExtraReward()
  return self.m_stSdpConfig.stCommonCfg.vAdvancedExtraReward
end

function BattlePassActivity:GetAdvancedAddLv()
  return self.m_stSdpConfig.stCommonCfg.iAdvancedExtraLevel
end

function BattlePassActivity:BuyAdvancedPass(productID, productSubID)
  if not productID then
    return
  end
  if not productSubID then
    return
  end
  local actBattlePassBuyParam = MTTDProto.CmdActBattlePassBuyParam()
  actBattlePassBuyParam.iActivityId = self:getID()
  local storeParam = sdp.pack(actBattlePassBuyParam)
  local ProductInfo = {
    productId = productID,
    productSubId = productSubID,
    iStoreType = MTTDProto.IAPStoreType_ActBattlePass,
    productName = self:GetBpName(),
    productDesc = self:GetBpName()
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

function BattlePassActivity:GetItemBaseId()
  return self.m_stCommonCfg and self.m_stCommonCfg.iItemBaseId or 0
end

function BattlePassActivity:GetProductID()
  return self.m_stCommonCfg.sProductId, self.m_stCommonCfg.iProductSubId
end

function BattlePassActivity:GetTitleType()
  return self.m_stSdpConfig.stClientCfg.iTitleType
end

function BattlePassActivity:GetBuyPanel2Prefab()
  local uiType = self:GetUiType()
  if uiType then
    local ui_name = ActivityManager.BattlePassUIType[uiType].BattlePassLevelUp
    local ui_id = UIDefines["ID_" .. string.upper(ui_name)]
    return ui_id
  end
end

function BattlePassActivity:GetMainPanelAnimaStr()
  local uiType = self:GetUiType()
  if uiType then
    local mainPanelAnim = ActivityManager.BattlePassUIType[uiType].UnlockAnimation
    return mainPanelAnim
  end
end

function BattlePassActivity:GetBuyPanelPrefab()
  local uiType = self:GetUiType()
  if uiType then
    local ui_name = ActivityManager.BattlePassUIType[uiType].BattlePassBenefits
    local ui_id = UIDefines["ID_" .. string.upper(ui_name)]
    return ui_id
  end
end

function BattlePassActivity:GetBattlePassMainPrefab()
  local uiType = self:GetUiType()
  if uiType then
    local ui_name = ActivityManager.BattlePassUIType[uiType].BattlePassMain
    local ui_id = UIDefines["ID_" .. string.upper(ui_name)]
    return ui_id
  end
end

function BattlePassActivity:GetAdvancedProductID()
  return self.m_stCommonCfg.sAdvancedProductId, self.m_stCommonCfg.iAdvancedProductSubId
end

function BattlePassActivity:GetAdvancedDifferenceProductID()
  return self.m_stCommonCfg.sAdvancedDifferenceProductId, self.m_stCommonCfg.iAdvancedDifferenceProductSubId
end

function BattlePassActivity:GetSalePrice()
  return IAPManager:GetProductPrice(self.m_stCommonCfg.sProductId, true)
end

function BattlePassActivity:GetAdvancedPrice()
  return IAPManager:GetProductPrice(self.m_stCommonCfg.sAdvancedProductId, true)
end

function BattlePassActivity:GetAdvancedDifferencePrice()
  return IAPManager:GetProductPrice(self.m_stCommonCfg.sAdvancedDifferenceProductId, true)
end

function BattlePassActivity:GetBpBgPic(data)
  return self.m_stSdpConfig.stClientCfg.sBackgroundPic, self.m_stSdpConfig.stClientCfg.sBackgroundPicMask
end

function BattlePassActivity:GetBpBuyBgPic(data)
  return self.m_stSdpConfig.stClientCfg.sBuyBackgroundPic, self.m_stSdpConfig.stClientCfg.sBuyBackgroundPicMask
end

function BattlePassActivity:GetDrawStatus(iLevel)
  if iLevel > #self.m_stStatusData.vDrawStatus then
    return 0
  end
  return self.m_stStatusData.vDrawStatus[iLevel]
end

function BattlePassActivity:GetBpName()
  return self:getLangText(self.m_stSdpConfig.stClientCfg.sName)
end

function BattlePassActivity:GetHeroId()
  return self.m_stSdpConfig.stClientCfg.iRoleId
end

function BattlePassActivity:GetRoleName()
  if not self.m_CharacterInfo then
    self.m_CharacterInfo = ConfigManager:GetConfigInsByName("CharacterInfo")
  end
  local roleId = self:GetHeroId()
  if roleId and self.m_CharacterInfo then
    local heroCfg = self.m_CharacterInfo:GetValue_ByHeroID(roleId)
    if heroCfg:GetError() then
      log.error("BattlePass heroCfgID Cannot Find Check Config: " .. roleId)
      return
    end
    return heroCfg.m_mShortname
  end
  return ""
end

function BattlePassActivity:GetSkinName()
  if not self.m_FashionInfo then
    self.m_FashionInfo = ConfigManager:GetConfigInsByName("FashionInfo")
  end
  local skinId = self:GetSkinId()
  if skinId and self.m_FashionInfo then
    local skinCfg = self.m_FashionInfo:GetValue_ByFashionID(skinId)
    if skinCfg:GetError() then
      log.error("BattlePass skinCfgID Cannot Find Check Config: " .. skinId)
      return
    end
    return skinCfg.m_mFashionName
  end
  return ""
end

function BattlePassActivity:GetAvatarSpineName()
  local skinId = self:GetSkinId()
  local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  local FashionInfoIns = ConfigManager:GetConfigInsByName("FashionInfo")
  if skinId and skinId ~= 0 and FashionInfoIns then
    local skinCfg = FashionInfoIns:GetValue_ByFashionID(skinId)
    if not skinCfg:GetError() and skinCfg.m_Spine then
      return skinCfg.m_Spine
    elseif CharacterInfoIns then
      local characterIdCfg = CharacterInfoIns:GetValue_ByHeroID(skinId)
      if not characterIdCfg:GetError() then
        return characterIdCfg.m_Spine
      end
    end
  end
  local characterId = self:GetHeroId()
  if characterId and characterId ~= 0 and CharacterInfoIns then
    local characterIdCfg = CharacterInfoIns:GetValue_ByHeroID(characterId)
    if not characterIdCfg:GetError() then
      return characterIdCfg.m_Spine
    end
  end
end

function BattlePassActivity:GetTitleAndEnterName()
  if not self.m_stSdpConfig then
    return
  end
  return self:getLangText(self.m_stSdpConfig.stClientCfg.sTitle)
end

function BattlePassActivity:GetTipsID()
  if self.m_stSdpConfig.stClientCfg.iActivityRulesPopupId and self.m_stSdpConfig.stClientCfg.iActivityRulesPopupId == 0 then
    return 1129
  end
  return self.m_stSdpConfig.stClientCfg.iActivityRulesPopupId or 1129
end

function BattlePassActivity:GetUiType()
  if not self.m_stSdpConfig then
    return
  end
  if self.m_stSdpConfig.stClientCfg.iUIType and self.m_stSdpConfig.stClientCfg.iUIType == 0 then
    return 1
  end
  return self.m_stSdpConfig.stClientCfg.iUIType or 1
end

function BattlePassActivity:GetSkinId()
  return self.m_stSdpConfig.stClientCfg.iAvatarId
end

function BattlePassActivity:GetFirstUnclaimedLevel()
  local curLevel = self:GetCurLevel()
  local maxLevel = self:GetMaxLevel()
  local isAdvanced = self:IsHaveBuy()
  local len = #self.m_stStatusData.vDrawStatus
  for k = 1, maxLevel do
    local drawStatus = self:GetDrawStatus(k)
    if k <= curLevel and (drawStatus == 0 or isAdvanced and drawStatus == 1) then
      return k
    end
  end
end

function BattlePassActivity:OnDispose()
  local actId = self:getID()
  self.m_initActivity = nil
  RPCS():RemoveListen_Push_SetQuestDataBatch_ByTag("BattlePass" .. actId)
  RPCS():RemoveListen_Push_DailyRefresh_ByTag("BattlePass" .. actId)
end

function BattlePassActivity:OnResetStatusData()
  if self.m_initActivity == nil then
    local actId = self:getID()
    RPCS():Listen_Push_SetQuestDataBatch(handler(self, self.OnPushSetQuestDataBatch), "BattlePass" .. actId)
    RPCS():Listen_Push_DailyRefresh(handler(self, self.OnPushDailyRefresh), "BattlePass" .. actId)
    self:addEventListener("eGameEvent_IAPDelivery_Push", handler(self, self.OnPushIAPDelivery))
    self.m_initActivity = true
  end
  if self:checkCondition() then
    self:RequestQuests()
  end
end

function BattlePassActivity:HasUnclaimedTask()
  if not self.m_questStatus then
    return false
  end
  for k, v in pairs(self.m_questStatus) do
    if v.iState == MTTDProto.QuestState_Finish then
      return true
    end
  end
  return false
end

function BattlePassActivity:HasRewardRed()
  local isRed = false
  local dataCfg = self:GetLevelCfg()
  local curLevel = self:GetCurLevel()
  local isHaveBuy = self:IsHaveBuy()
  for _, data in pairs(dataCfg) do
    local levelCfg = data.levelCfg
    local drawStatus = self:GetDrawStatus(data.iLevel)
    local isNotGetLevel = curLevel < data.iLevel
    if not isNotGetLevel then
      if drawStatus == 0 then
        return true
      elseif drawStatus == 1 and isHaveBuy then
        return true
      elseif drawStatus == 2 then
        isRed = false
      end
    end
  end
  return isRed
end

function BattlePassActivity:OnPushDailyRefresh(sc, msg)
  self:RequestQuests(true, function()
    self:broadcastEvent("eGameEvent_Activity_BattlePass_DailyTaskRefresh", {})
  end)
end

function BattlePassActivity:OnPushSetQuestDataBatch(sc, msg)
  local vQuestStatusChanged = {}
  local vQuest = sc.vCmdQuestInfo
  local bShowRed = false
  for _, stQuestStatus in pairs(vQuest) do
    if stQuestStatus.iType == self:getID() and self.m_questStatus then
      for _, stQuestStatusTmp in pairs(self.m_questStatus) do
        if stQuestStatusTmp.iId == stQuestStatus.iId then
          if stQuestStatus.iState == MTTDProto.QuestState_Finish then
            bShowRed = true
          end
          stQuestStatusTmp.iState = stQuestStatus.iState
          stQuestStatusTmp.vCondStep = stQuestStatus.vCondStep
          break
        end
      end
    end
  end
  if bShowRed and not self:ReachMaxLevel() then
    self:broadcastEvent("eGameEvent_Activity_BattlePass_RedRefresh", self:getID())
  end
  self:broadcastEvent("eGameEvent_Activity_BattlePass_TaskUpdate", {
    iActivityID = self:getID()
  })
end

function BattlePassActivity:checkCondition()
  if not BattlePassActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function BattlePassActivity:CheckRed()
  if self:GetFirstUnclaimedLevel() ~= nil then
    return 1
  end
  if not self:ReachMaxLevel() and self:HasUnclaimedTask() then
    return 1
  end
  return 0
end

function BattlePassActivity:checkShowRed()
  return false
end

function BattlePassActivity:GetBattlePassHasAdvance()
  local isHasAdvance = self.m_stCommonCfg.sAdvancedProductId or ""
  return isHasAdvance and isHasAdvance ~= ""
end

function BattlePassActivity:OnPushIAPDelivery(data)
  local isBattlePassPayed = false
  if data.sProductId == self.m_stCommonCfg.sProductId and data.iSubProductId == self.m_stCommonCfg.iProductSubId then
    self.m_stStatusData.iBuyStatus = ActivityManager.BattlePassBuyStatus.Paid
    isBattlePassPayed = true
  elseif data.sProductId == self.m_stCommonCfg.sAdvancedProductId and data.iSubProductId == self.m_stCommonCfg.iAdvancedProductSubId then
    self.m_stStatusData.iBuyStatus = ActivityManager.BattlePassBuyStatus.Advanced
    isBattlePassPayed = true
  elseif data.sProductId == self.m_stCommonCfg.sAdvancedDifferenceProductId and data.iSubProductId == self.m_stCommonCfg.iAdvancedDifferenceProductSubId then
    self.m_stStatusData.iBuyStatus = ActivityManager.BattlePassBuyStatus.Advanced
    isBattlePassPayed = true
  end
  if isBattlePassPayed then
    self:broadcastEvent("eGameEvent_Activity_BattlePass_AdvancedPassBought", {
      iActivityID = self:getID()
    })
  end
end

return BattlePassActivity
