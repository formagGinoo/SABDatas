local BaseManager = require("Manager/Base/BaseManager")
local HangUpManager = class("HangUpManager", BaseManager)

function HangUpManager:OnCreate()
  self.m_iOldAfkLevel = nil
  self.m_iAfkLevel = 1
  self.m_iOldAfkExp = nil
  self.m_iAfkExp = 0
  self.m_iTakeRewardTime = 0
  self.m_iInstantTimes = 0
  self.m_iSeeRewardTime = 0
  self.m_Reward = {}
end

function HangUpManager:OnInitNetwork()
  RPCS():Listen_Push_AfkLevel(handler(self, self.OnPushAfkLevel), "HangUpManager")
  self:addEventListener("eGameEvent_HangUp_GetData", handler(self, self.OnEventHangUpGetData))
end

function HangUpManager:OnInitMustRequestInFetchMore()
  self:ReqInitHangUpData()
end

function HangUpManager:OnEventHangUpGetData()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
  if not openFlag then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HANGUP)
end

function HangUpManager:OnDailyReset()
  self.m_iInstantTimes = 0
  self:ReqGetHangUpDataOnUnlockSystem()
end

function HangUpManager:OnPushAfkLevel(stAfkData, msg)
  if self.m_iAfkLevel == 0 then
    self:ReqGetHangUpDataOnUnlockSystem()
  end
  if stAfkData.iAfkLevel > 1 and stAfkData.iAfkLevel > self.m_iAfkLevel and self.m_iAfkLevel ~= 0 then
    self:broadcastEvent("eGameEvent_HangUp_LevelChanged", {
      oldLv = self.m_iAfkLevel,
      newLv = stAfkData.iAfkLevel
    })
  end
  self.m_iAfkLevel = stAfkData.iAfkLevel
  self.m_iAfkExp = stAfkData.iAfkExp
end

function HangUpManager:ReqInitHangUpData()
  local afkGetInfoCSMsg = MTTDProto.Cmd_Afk_GetData_CS()
  afkGetInfoCSMsg.bAuto = true
  RPCS():Afk_GetData(afkGetInfoCSMsg, handler(self, self.OnInitAfkInfoSC))
end

function HangUpManager:OnInitAfkInfoSC(afkData, msg)
  local stAfkData = afkData.stAfkData
  self.m_iAfkLevel = stAfkData.iAfkLevel
  self.m_iAfkExp = stAfkData.iAfkExp
  self.m_iTakeRewardTime = stAfkData.iTakeRewardTime
  self.m_iInstantTimes = stAfkData.iInstantTimes
  self.m_iSeeRewardTime = stAfkData.iSeeRewardTime
  self.m_Reward = self:SortAndFormatRewardTab2(stAfkData.mReward)
  self:CheckHangUpHaveFreeGetNum()
end

function HangUpManager:ReqGetHangUpData()
  local afkGetInfoCSMsg = MTTDProto.Cmd_Afk_GetData_CS()
  afkGetInfoCSMsg.bAuto = false
  RPCS():Afk_GetData(afkGetInfoCSMsg, handler(self, self.OnAfkGetInfoSC))
end

function HangUpManager:OnAfkGetInfoSC(afkData, msg)
  log.info("HangUpManager OnAfkGetInfoSC afkData: ", tostring(afkData))
  local stAfkData = afkData.stAfkData
  self.m_iAfkLevel = stAfkData.iAfkLevel
  self.m_iAfkExp = stAfkData.iAfkExp
  self.m_iTakeRewardTime = stAfkData.iTakeRewardTime
  self.m_iInstantTimes = stAfkData.iInstantTimes
  self.m_iSeeRewardTime = stAfkData.iSeeRewardTime
  self.m_Reward = self:SortAndFormatRewardTab2(stAfkData.mReward)
  self:broadcastEvent("eGameEvent_HangUp_GetData")
  self:CheckHangUpHaveFreeGetNum()
end

function HangUpManager:ReqGetHangUpDataOnUnlockSystem()
  local afkGetInfoCSMsg = MTTDProto.Cmd_Afk_GetData_CS()
  afkGetInfoCSMsg.bAuto = true
  RPCS():Afk_GetData(afkGetInfoCSMsg, handler(self, self.OnAfkDataOnUnlockSystemSC))
end

function HangUpManager:OnAfkDataOnUnlockSystemSC(afkData, msg)
  local stAfkData = afkData.stAfkData
  self.m_iAfkLevel = stAfkData.iAfkLevel
  self.m_iAfkExp = stAfkData.iAfkExp
  self.m_iTakeRewardTime = stAfkData.iTakeRewardTime
  self.m_iInstantTimes = stAfkData.iInstantTimes
  self.m_iSeeRewardTime = stAfkData.iSeeRewardTime
  self.m_Reward = self:SortAndFormatRewardTab2(stAfkData.mReward)
  self:CheckHangUpHaveFreeGetNum()
  self:broadcastEvent("eGameEvent_HangUp_Unlock")
end

function HangUpManager:ReqTakeReward()
  local reqMsg = MTTDProto.Cmd_Afk_TakeReward_CS()
  RPCS():Afk_TakeReward(reqMsg, handler(self, self.OnReqTakeRewardSC), handler(self, self.OnReqTakeRewardFailedSC))
end

function HangUpManager:OnReqTakeRewardSC(tableRewardData, msg)
  local rewardList = tableRewardData.vReward
  self.m_iTakeRewardTime = TimeUtil:GetServerTimeS()
  self.m_Reward = {}
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(self:SortAndFormatRewardTab(rewardList))
  end
  self:broadcastEvent("eGameEvent_HangUp_GetReward")
end

function HangUpManager:OnReqTakeRewardFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  self:ReqGetHangUpDataOnUnlockSystem()
  NetworkManager:OnRpcCallbackFail(msg)
end

function HangUpManager:ReqTakeInstant()
  local reqMsg = MTTDProto.Cmd_Afk_TakeInstant_CS()
  RPCS():Afk_TakeInstant(reqMsg, handler(self, self.OnReqTakeInstantSC))
end

function HangUpManager:OnReqTakeInstantSC(tableRewardData, msg)
  local rewardList = tableRewardData.vReward
  self.m_iInstantTimes = tableRewardData.iInstantTimes
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(self:SortAndFormatRewardTab(rewardList))
  end
  self:broadcastEvent("eGameEvent_HangUp_GetInstantRewards")
  self:CheckHangUpHaveFreeGetNum()
end

function HangUpManager:SortAndFormatRewardTab(serverRewardTab)
  local commonRewardIdTab = self:GetCommonRewardIdTab()
  local rewardTab = {}
  local commonRewardTab = {}
  for k, v in pairs(serverRewardTab) do
    if commonRewardIdTab[v.iID] then
      commonRewardTab[commonRewardIdTab[v.iID]] = {
        iID = v.iID,
        iNum = v.iNum
      }
    else
      rewardTab[#rewardTab + 1] = {
        iID = v.iID,
        iNum = v.iNum
      }
    end
  end
  table.insertto(commonRewardTab, rewardTab)
  return commonRewardTab
end

function HangUpManager:SortAndFormatRewardTab2(serverRewardTab)
  local commonRewardIdTab = self:GetCommonRewardIdTab()
  local rewardTab = {}
  local commonRewardTab = {}
  for k, v in pairs(serverRewardTab) do
    if commonRewardIdTab[k] then
      commonRewardTab[commonRewardIdTab[k]] = {k, v}
    else
      rewardTab[#rewardTab + 1] = {k, v}
    end
  end
  table.insertto(commonRewardTab, rewardTab)
  return commonRewardTab
end

function HangUpManager:GetCommonRewardIdTab()
  local commonRewardIdTab = {}
  local AFKLevelConfigInstance = ConfigManager:GetConfigInsByName("AFKLevel")
  local levelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_iAfkLevel)
  if levelCfg and levelCfg.m_Reward then
    local commonRewardList = utils.changeCSArrayToLuaTable(levelCfg.m_Reward)
    for i, v in ipairs(commonRewardList) do
      commonRewardIdTab[v[1]] = i
    end
  else
    log.info("get AFKLevelConfig error id = " .. self.m_iAfkLevel)
  end
  return commonRewardIdTab
end

function HangUpManager:GetAFKLevel()
  if not self.m_iAfkLevel then
    return
  end
  return self.m_iAfkLevel
end

function HangUpManager:GetOldAFKLevel()
  return self.m_iOldAfkLevel
end

function HangUpManager:ClearOldAFKLevel()
  self.m_iOldAfkLevel = nil
end

function HangUpManager:CacheAFKLevelAndExpAsOld()
  self.m_iOldAfkLevel = self.m_iAfkLevel
  self.m_iOldAfkExp = self.m_iAfkExp
end

function HangUpManager:GetAFKExp()
  if not self.m_iAfkExp then
    return
  end
  return self.m_iAfkExp
end

function HangUpManager:GetOldAFKExp()
  return self.m_iOldAfkExp
end

function HangUpManager:ClearOldAFKExp()
  self.m_iOldAfkExp = nil
end

function HangUpManager:GetItemProductionByIdAndSeconds(itemId, second)
  local count = 0
  local AFKLevelConfigInstance = ConfigManager:GetConfigInsByName("AFKLevel")
  local levelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_iAfkLevel)
  local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.HangUp)
  if levelCfg and levelCfg.m_Reward then
    local rewardList = utils.changeCSArrayToLuaTable(levelCfg.m_Reward)
    for i, v in ipairs(rewardList) do
      if v[1] == itemId and v[2] and v[3] then
        local starEffect = ((starEffectMap[v[1]] or 0) + 100) / 100
        count = math.floor(math.floor(v[2] * starEffect) * second / v[3])
      end
    end
  else
    log.info("get AFKLevelConfig error id = " .. self.m_iAfkLevel)
  end
  return count
end

function HangUpManager:CheckHangUpHaveFreeGetNum()
  local AFKInstantRewardConfigInstance = ConfigManager:GetConfigInsByName("AFKInstantReward")
  local instantRewardCfg = AFKInstantRewardConfigInstance:GetValue_ByTimes(self.m_iInstantTimes + 1)
  if instantRewardCfg then
    local consumptionCfg = utils.changeCSArrayToLuaTable(instantRewardCfg.m_Consumption)
    if consumptionCfg then
      local consumption = consumptionCfg[1][2]
      if consumption == 0 then
        self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
          redDotKey = RedDotDefine.ModuleType.HangUpBattle,
          count = 1
        })
        return 1
      end
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.HangUpBattle,
    count = 0
  })
  return 0
end

return HangUpManager
