local BaseActivity = require("Base/BaseActivity")
local TrialActivity = class("TrialActivity", BaseActivity)
local ETaskType = {
  TrainTaskType_Hero = 1,
  TrainTaskType_HeroBreak = 2,
  TrainTaskType_SkillLevel = 3,
  TrainTaskType_UltLevel = 4,
  TrainTaskType_Attract = 5
}

function TrialActivity.getActivityType(_)
  return MTTD.ActivityType_Train
end

function TrialActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgTrain
end

function TrialActivity.getStatusProto(_)
  return MTTDProto.CmdActTrain_Status
end

function TrialActivity:RequestGetReward(iLevelId)
end

function TrialActivity:OnResetSdpConfig(m_stSdpConfig)
  if m_stSdpConfig and m_stSdpConfig.stCommonCfg then
    self.mTrianCommonData = m_stSdpConfig.stCommonCfg
    self.mTrianClientData = m_stSdpConfig.stClientCfg
  end
  self:broadcastEvent("eGameEvent_Activity_TrainUpdate", self:getID())
end

function TrialActivity:OnResetStatusData()
  self:broadcastEvent("eGameEvent_Activity_TrainUpdate", self:getID())
end

function TrialActivity:RequestGetReward(iIndexId)
  local reqMsg = MTTDProto.Cmd_Act_Train_TakeTaskReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iIndexId = iIndexId
  RPCS():Act_Train_TakeTaskReward(reqMsg, handler(self, self.OnRequestGetRewardSC))
end

function TrialActivity:GetTaskGroup()
  return self.mTrianCommonData.mTaskGroup
end

function TrialActivity:SetStoreData(storeData)
  self.m_storeData = storeData
end

function TrialActivity:GetStoreData()
  return self.m_storeData
end

function TrialActivity:GetGroupConfigByGroupId(iGroupId)
  for _, v in pairs(self.mTrianCommonData.mTaskGroup) do
    if v.iGroupId == iGroupId then
      return v
    end
  end
  return nil
end

function TrialActivity:GetTrainsByGroupId(iGroupId)
  local trains = {}
  for _, v in pairs(self.mTrianCommonData.mTrain) do
    if v.iTaskGroup == iGroupId then
      table.insert(trains, v)
    end
  end
  table.sort(trains, function(a, b)
    return a.iId < b.iId
  end)
  return trains
end

function TrialActivity:IsTaskCanGetReward(iTrainId)
  local heroData = HeroManager:GetHeroDataByID(self.mTrianCommonData.iHeroId)
  if not heroData then
    return false
  end
  for _, v in pairs(self.mTrianCommonData.mTrain) do
    if v.iId == iTrainId then
      if v.iTaskType == ETaskType.TrainTaskType_Hero then
        return true
      elseif v.iTaskType == ETaskType.TrainTaskType_HeroBreak then
        if heroData.serverData.iBreak >= v.vTaskParam[1] then
          return true
        end
      elseif v.iTaskType == ETaskType.TrainTaskType_SkillLevel then
        for skillId, skillLevel in pairs(heroData.serverData.mSkill) do
          if HeroManager:GetSkillTypeById(skillId) ~= 2 and skillLevel >= v.vTaskParam[1] then
            return true
          end
        end
      elseif v.iTaskType == ETaskType.TrainTaskType_UltLevel then
        for skillId, skillLevel in pairs(heroData.serverData.mSkill) do
          if HeroManager:GetSkillTypeById(skillId) == 2 and skillLevel >= v.vTaskParam[1] then
            return true
          end
        end
      elseif v.iTaskType == ETaskType.TrainTaskType_Attract and heroData.serverData.iAttractRank >= v.vTaskParam[1] then
        return true
      end
    end
  end
  return false
end

function TrialActivity:GetTrainStatusByTrainId(iTrainId)
  for _, v in pairs(self.m_stStatusData.mTask) do
    if v.iIndexId == iTrainId then
      return v
    end
  end
  return nil
end

function TrialActivity:GetTaskTypeConfigByTaskType(iTaskType)
  for _, v in pairs(self.mTrianCommonData.mTaskType) do
    if v.iTaskType == iTaskType then
      return v
    end
  end
  return nil
end

function TrialActivity:RequestGetReward(iIndexId)
  local reqMsg = MTTDProto.Cmd_Act_Train_TakeTaskReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iIndexId = iIndexId
  RPCS():Act_Train_TakeTaskReward(reqMsg, handler(self, self.OnRequestGetRewardSC))
end

local WindowRedEnum = {
  [1] = RedDotDefine.ModuleType.MallNewbieGiftPackTabl,
  [2] = RedDotDefine.ModuleType.ActivityGiftPackTabl,
  [3] = RedDotDefine.ModuleType.MallDailyPackTabl,
  [8] = RedDotDefine.ModuleType.MallFashionTab,
  [9] = RedDotDefine.ModuleType.MallReturnTaskTab
}

function TrialActivity:OnRequestGetRewardSC(sc, msg)
  local vReward = sc.vReward
  utils.popUpRewardUI(vReward)
  self.m_stStatusData.mTask[sc.iIndexId] = sc.stTask
  self:broadcastEvent("eGameEvent_Activity_TrainUpdate", self:getID())
  self:broadcastEvent("eGameEvent_PayStore_RedDot_ChangeCount")
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity then
    for i, v in ipairs(payStoreActivity.m_NewSortConfig) do
      local redDotEnum
      if v[1] then
        redDotEnum = WindowRedEnum[v[1].iWindowID]
      end
      if redDotEnum then
        self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
          redDotKey = redDotEnum,
          count = payStoreActivity:GetRedDotCount(v)
        })
      end
    end
  end
end

function TrialActivity:OnRequestPurchaseCallback(iTrainId)
  log.info("OnRequestPurchaseCallback", iTrainId)
  log.info("self.m_stStatusData.mTask", table.serialize(self.m_stStatusData.mTask))
end

function TrialActivity:checkCondition(bIsShow)
  return true
end

function TrialActivity:checkShowRed()
  local hasRewardCanGet = false
  for _, v in pairs(self.mTrianCommonData.mTrain) do
    local taskAchieved = self:IsTaskCanGetReward(v.iId)
    local taskStatus = self:GetTrainStatusByTrainId(v.iId)
    if taskAchieved and (not taskStatus or taskStatus.iTakeTime <= 0) then
      hasRewardCanGet = true
    end
  end
  return hasRewardCanGet
end

function TrialActivity:GetTrainRedByGroupId(iGroupId)
  local hasRewardCanGet = false
  for _, v in pairs(self.mTrianCommonData.mTrain) do
    if v.iTaskGroup == iGroupId then
      local taskAchieved = self:IsTaskCanGetReward(v.iId)
      local taskStatus = self:GetTrainStatusByTrainId(v.iId)
      if taskAchieved and (not taskStatus or taskStatus.iTakeTime <= 0) then
        hasRewardCanGet = true
      end
    end
  end
  return hasRewardCanGet
end

function TrialActivity:GeStatusByLevelId(levelID)
  return 0
end

return TrialActivity
