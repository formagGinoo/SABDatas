local BaseActivity = require("Base/BaseActivity")
local ReturnTaskActivity = class("ReturnTaskActivity", BaseActivity)

function ReturnTaskActivity.getActivityType(_)
  return MTTD.ActivityType_ReturnTask
end

function ReturnTaskActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgReturnTask
end

function ReturnTaskActivity.getStatusProto(_)
  return MTTDProto.CmdActReturnTask_Status
end

function ReturnTaskActivity:AddItem(list, item)
  for i, v in ipairs(list) do
    if v.iID == item.iID then
      v.iNum = v.iNum + item.iNum
      return
    end
  end
  table.insert(list, {
    iID = item.iID,
    iNum = item.iNum
  })
end

function ReturnTaskActivity:OnResetSdpConfig()
  self.maxProgress = 0
  self.lowPackRewards = {}
  self.heighPackRewards = {}
  self.taskInfo = {}
  self.rewards = {}
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    local questMap = self.m_stSdpConfig.stCommonCfg.mQuest or {}
    for k, v in pairs(questMap) do
      local element = CS.CData_Task.GetInstance():GetValue_ByID(v.iTaskID)
      if not element:GetError() then
        local info = {
          Index = v.iIndex,
          TaskID = v.iTaskID,
          Element = element,
          ProgressValue = v.iProgressValue,
          MaxFinishTimes = v.iMaxFinishTimes,
          Cfg = self.m_stSdpConfig.stCommonCfg.mQuest[v.iIndex],
          Reward = v.vReward[1],
          FinishTimes = 0,
          AwardedTimes = 0,
          Step = 0,
          IsFinished = false
        }
        table.insert(self.taskInfo, info)
      end
    end
    table.sort(self.taskInfo, function(a, b)
      return a.Index < b.Index
    end)
    local rewardMap = self.m_stSdpConfig.stCommonCfg.mReward or {}
    for k, v in pairs(rewardMap) do
      table.insert(self.rewards, v)
      for _, item in ipairs(v.vLowerPayReward) do
        self:AddItem(self.lowPackRewards, item)
      end
      for _, item in ipairs(v.vHigherPayReward) do
        self:AddItem(self.heighPackRewards, item)
      end
      if v.iProgressValue > self.maxProgress then
        self.maxProgress = v.iProgressValue
      end
    end
    table.sort(self.rewards, function(a, b)
      return a.iProgressValue < b.iProgressValue
    end)
  end
  self.isModify = true
end

function ReturnTaskActivity:OnResetStatusData()
  for i, v in ipairs(self.m_stStatusData.vAllQuest) do
    for _, task in ipairs(self.taskInfo) do
      if task.Index == v.iIndex then
        self:FillTaskDynamicInfo(v, task)
        break
      end
    end
  end
  local unlockLow = self:IsGoodUnlock(1)
  local unlockHeigh = self:IsGoodUnlock(2)
  if self.progressValue == nil then
    self.progressValue = 0
  end
  if unlockLow and self.unlockLow ~= nil and self.unlockLow == false then
    self:broadcastEvent("eGameEvent_Activity_RefreshReturnBuyPackage", 1, self.progressValue, self.m_stStatusData.iCurlProgressValue)
  end
  self.unlockLow = unlockLow
  if unlockHeigh and self.unlockHeigh ~= nil and self.unlockHeigh == false then
    self:broadcastEvent("eGameEvent_Activity_RefreshReturnBuyPackage", 2, self.progressValue, self.m_stStatusData.iCurlProgressValue)
  end
  self.unlockHeigh = unlockHeigh
  self.progressValue = self.m_stStatusData.iCurlProgressValue or 0
  self:RefreshRedDot()
  if self.taskRequestInfo ~= nil then
    return
  end
  if self.isModify then
    self.isModify = false
    self:broadcastEvent("eGameEvent_Activity_RefreshReturnTask")
  else
    self:broadcastEvent("eGameEvent_Activity_RefreshReturnTaskStatus")
  end
end

function ReturnTaskActivity:FillTaskDynamicInfo(questData, info)
  info.FinishTimes = questData.iFinishTimes
  info.AwardedTimes = questData.iAwardedTimes
  info.Step = questData.iCurProgress
end

function ReturnTaskActivity:IsActive()
  if self.m_stSdpConfig == nil or self.m_stSdpConfig.stCommonCfg == nil then
    return false
  end
  if self.m_stStatusData == nil then
    return false
  end
  local currentTime = TimeUtil:GetServerTimeS()
  return currentTime >= self.m_stStatusData.iOpenTime and currentTime <= self.m_stStatusData.iCloseTime
end

function ReturnTaskActivity:GetEndTime()
  if self.m_stStatusData == nil then
    return 0
  end
  return self.m_stStatusData.iCloseTime
end

function ReturnTaskActivity:GetRemindKey()
  if self.m_stStatusData == nil then
    return "ReturnTaskActivity_Remind_0"
  end
  return "ReturnTaskActivity_Remind_" .. tostring(self.m_stStatusData.iOpenTime)
end

function ReturnTaskActivity:GetGoodCfg(index)
  if self.m_stSdpConfig == nil or self.m_stSdpConfig.stCommonCfg == nil then
    return nil
  end
  local goods = self.m_stSdpConfig.stCommonCfg.mGoods or {}
  for k, v in pairs(goods) do
    if v.iIndex == index then
      return v
    end
  end
  return nil
end

function ReturnTaskActivity:IsGoodUnlock(index)
  if index == 0 then
    return true
  else
    return self.m_stStatusData ~= nil and self.m_stStatusData.mGoodsBought[index] ~= nil
  end
end

function ReturnTaskActivity:GetLowRewardItems()
  return self.lowPackRewards or {}
end

function ReturnTaskActivity:GetHeighRewardItems()
  return self.heighPackRewards or {}
end

function ReturnTaskActivity:IsRewardTake(progress, index)
  if self.m_stStatusData == nil or self.m_stStatusData.mQuestAwarded == nil then
    return false
  end
  local rewardInfo = self.m_stStatusData.mQuestAwarded[index]
  if rewardInfo == nil then
    return false
  end
  local time = rewardInfo[progress]
  return time ~= nil and 0 < time
end

function ReturnTaskActivity:IsAnyRewardCanTake()
  if self.m_stStatusData == nil or self.m_stStatusData.mQuestAwarded == nil then
    return false
  end
  local rewards = self.m_stSdpConfig.stCommonCfg.mReward or {}
  local progress = self.m_stStatusData.iCurlProgressValue or 0
  local unlockLow = self:IsGoodUnlock(1)
  local unlockHeigh = self:IsGoodUnlock(2)
  for k, v in pairs(rewards) do
    if progress >= v.iProgressValue then
      if not self:IsRewardTake(v.iProgressValue, 0) then
        return true
      end
      if unlockLow and not self:IsRewardTake(v.iProgressValue, 1) then
        return true
      end
      if unlockHeigh and not self:IsRewardTake(v.iProgressValue, 2) then
        return true
      end
    end
  end
  return false
end

function ReturnTaskActivity:GetTaskInfoList()
  return self.taskInfo or {}
end

function ReturnTaskActivity:GetRewardList()
  return self.rewards or {}
end

function ReturnTaskActivity:NeedRemindGift()
  local unlockLow = self:IsGoodUnlock(1)
  local unlockHeigh = self:IsGoodUnlock(2)
  if unlockLow and unlockHeigh then
    return false
  end
  local currentTime = TimeUtil:GetServerTimeS()
  local currentDay = currentTime / 86400
  local endDay = self.m_stStatusData.iCloseTime / 86400
  if endDay - currentDay > self.m_stSdpConfig.stCommonCfg.iLeftDayRemind then
    return false
  end
  local progress = self.m_stStatusData.iCurlProgressValue or 0
  local maxProgress = self.maxProgress or 0
  local remindProgress = false
  if not unlockLow then
    local lowCfg = self:GetGoodCfg(1)
    if lowCfg and progress >= maxProgress - lowCfg.iExtraBonusProgressValue then
      remindProgress = true
    end
  end
  if not unlockHeigh then
    local heighCfg = self:GetGoodCfg(2)
    if heighCfg and progress >= maxProgress - heighCfg.iExtraBonusProgressValue then
      remindProgress = true
    end
  end
  if not remindProgress then
    return false
  end
  local key = self:GetRemindKey()
  return CS.UI.UILuaHelper.GetPlayerPreference(key) == 0
end

function ReturnTaskActivity:SetReminded()
  if self.m_stStatusData ~= nil then
    local key = self:GetRemindKey()
    CS.UI.UILuaHelper.SetPlayerPreference(key, 1)
    self:RefreshRedDot()
  end
end

function ReturnTaskActivity:GetCurrentProgress()
  if self.m_stStatusData == nil then
    return 0
  end
  return self.m_stStatusData.iCurlProgressValue or 0
end

function ReturnTaskActivity:IncressByBuyPackage(value)
  if self.m_stStatusData ~= nil then
    self.m_stStatusData.iCurlProgressValue = self.m_stStatusData.iCurlProgressValue + value
  end
end

function ReturnTaskActivity:checkShowRed()
  if not self:IsActive() then
    return false
  end
  local taskList = self.m_stStatusData.vAllQuest or {}
  for i, v in ipairs(taskList) do
    if v.iAwardedTimes < v.iFinishTimes then
      return true
    end
  end
  if self:IsAnyRewardCanTake() then
    return true
  end
  if self:NeedRemindGift() then
    return true
  end
  return false
end

function ReturnTaskActivity:RefreshRedDot()
  local count = 0
  if self:checkShowRed() then
    count = 1
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MallReturnTaskTab,
    count = count
  })
end

function ReturnTaskActivity:TakeReward()
  local reqMsg = MTTDProto.Cmd_Act_ReturnTask_GetReward_CS()
  reqMsg.iActivityId = self:getID()
  RPCS():Act_ReturnTask_GetReward(reqMsg, function(sc, msg)
    if self.m_stStatusData ~= nil then
      self.m_stStatusData.mQuestAwarded = sc.mQuestAwarded
    end
    self:RefreshRedDot()
    utils.popUpRewardUI(sc.vReward)
    self:broadcastEvent("eGameEvent_Activity_RefreshReturnTaskStatus")
  end)
end

function ReturnTaskActivity:TaskQuestReward(taskIndex, onFinished)
  local reqMsg = MTTDProto.Cmd_Act_ReturnTask_GetQuestReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iQuestIndex = taskIndex
  self.taskRequestInfo = {
    Index = taskIndex,
    CurrentProgress = self.m_stStatusData.iCurlProgressValue
  }
  local count = 0
  for i, v in ipairs(self.taskInfo) do
    if v.AwardedTimes < v.FinishTimes then
      count = count + 1
      break
    end
  end
  if count == #self.taskInfo then
    self.taskRequestInfo.Index = self.taskInfo[1].Index
    return
  end
  RPCS():Act_ReturnTask_GetQuestReward(reqMsg, function(sc, msg)
    local function callBack()
      local from = self.taskRequestInfo.CurrentProgress
      
      local to = self.m_stStatusData.iCurlProgressValue
      to = math.min(to, self.maxProgress)
      onFinished(self.taskRequestInfo.Index, from, to)
      self.taskRequestInfo = nil
    end
    
    self:RefreshRedDot()
    utils.popUpRewardUI(sc.vReward, callBack)
  end)
end

function ReturnTaskActivity:BuyGiftPackage(index)
  local payStoreAct = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  local cfg = self:GetGoodCfg(index)
  local ProductInfo = {
    StoreID = payStoreAct:GetReturnTaskStoreId(),
    productId = cfg.sProductId,
    productSubId = cfg.iSubProductId,
    iStoreType = MTTDProto.IAPStoreType_ActReturnTask,
    productName = self:getLangText(cfg.iGiftName) or "",
    productDesc = ""
  }
  local param = MTTDProto:CmdStoreCommonBuyParam()
  param.iActivityId = self:getID()
  local storeParam = sdp.pack(param)
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    else
    end
  end)
end

return ReturnTaskActivity
