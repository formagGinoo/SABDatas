local BaseActivity = require("Base/BaseActivity")
local CountConsumeActivity = class("CountConsumeActivity", BaseActivity)

function CountConsumeActivity.getActivityType(_)
  return MTTD.ActivityType_CountConsume
end

function CountConsumeActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgCountConsume
end

function CountConsumeActivity.getStatusProto(_)
  return MTTDProto.CmdActCountConsume_Status
end

function CountConsumeActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.m_pointItemId = self.m_stSdpConfig.stCommonCfg.iPointItem
    self.m_rewardDic = self.m_stSdpConfig.stCommonCfg.mReward
    self.m_productsListInfo = self.m_stSdpConfig.stCommonCfg.mProducts
    self.m_redPointRewardList = self.m_stSdpConfig.stCommonCfg.vRedpointReward
    self.m_skinID = self.m_stSdpConfig.stCommonCfg.iAvatarId
    self.m_iPopNeedStage = self.m_stSdpConfig.stCommonCfg.iPopNeedStage
    self:FreshFirstAndPointReward()
  end
end

function CountConsumeActivity:OnResetStatusData()
  self.m_takenRewardList = self.m_stStatusData.vTakenReward
  self.m_pointNum = self.m_stStatusData.iPoint or 0
  self.m_isGetRedPointReward = self.m_stStatusData.bRedpointReward
end

function CountConsumeActivity:CheckPushFacePanel()
  if not self:checkCondition() then
    return
  end
  local curPoint = self:GetCurPoint()
  if 0 < curPoint then
    return
  end
  local popNeedPassLevelID = self.m_iPopNeedStage
  if 0 < popNeedPassLevelID then
    local isPass = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, popNeedPassLevelID)
    if isPass ~= true then
      return
    end
  end
  local isHavePop = LocalDataManager:GetIntSimple("CountConsumeActivity_Have_Pop", 0) == 1
  if isHavePop then
    return
  end
  self:broadcastEvent("eGameEvent_Activity_CountConsumeActivity_PushFace", {isPop = true})
end

function CountConsumeActivity:checkCondition()
  if not CountConsumeActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if self:IsAllRewardGet() == true then
    return false
  end
  return true
end

function CountConsumeActivity:GetPointItemId()
  return self.m_pointItemId or -1
end

function CountConsumeActivity:GetIsRedPointRewardGet()
  return self.m_isGetRedPointReward
end

function CountConsumeActivity:GetRedPointRewardList()
  if not self.m_redPointRewardList then
    return
  end
  return self.m_redPointRewardList
end

function CountConsumeActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  if not self:CheckHasRewardGet() then
    return false
  end
  return true
end

function CountConsumeActivity:IsAllRewardGet()
  local isGetRedPointReward = self:GetIsRedPointRewardGet()
  if isGetRedPointReward ~= true then
    return false
  end
  local firstRewardList = self.m_firstRewardList
  if firstRewardList then
    for k, v in ipairs(firstRewardList) do
      if not self:CheckRewardIsGet(v.iId) then
        return false
      end
    end
  end
  local pointRewardList = self.m_pointRewardList
  for k, v in ipairs(pointRewardList) do
    if not self:CheckRewardIsGet(v.iId) then
      return false
    end
  end
  return true
end

function CountConsumeActivity:CheckHasRewardGet()
  local isGetRedPointReward = self:GetIsRedPointRewardGet()
  if isGetRedPointReward ~= true then
    return true
  end
  local curPoint = self:GetCurPoint()
  if 0 < curPoint then
    local curLoginDay = RoleManager:GetTotalLoginDays()
    local firstRewardList = self.m_firstRewardList
    if firstRewardList then
      for k, v in ipairs(firstRewardList) do
        if curLoginDay >= v.iNeedLoginDays and not self:CheckRewardIsGet(v.iId) then
          return true
        end
      end
    end
  end
  local pointRewardList = self.m_pointRewardList
  for k, v in ipairs(pointRewardList) do
    if curPoint >= v.iNeedPoint and not self:CheckRewardIsGet(v.iId) then
      return true
    end
  end
  return false
end

function CountConsumeActivity:CheckRewardIsGet(id)
  if not id then
    return false
  end
  local takenRewardIDList = self:GetTakenRewardList()
  for k, v in ipairs(takenRewardIDList) do
    if v == id then
      return true
    end
  end
  return false
end

function CountConsumeActivity:IsFirstRewardCanGet(id)
  if not id then
    return false
  end
  if not self.m_firstRewardList then
    return
  end
  local curPoint = self:GetCurPoint()
  if curPoint <= 0 then
    return false
  end
  local curDayNum = RoleManager:GetTotalLoginDays()
  for i, v in ipairs(self.m_firstRewardList) do
    if v.iId == id then
      if curDayNum >= v.iNeedLoginDays then
        return true
      else
        return false
      end
    end
  end
end

function CountConsumeActivity:IsPointRewardCanGet(id)
  if not id then
    return false
  end
  if not self.m_pointRewardList then
    return
  end
  local curPoint = self:GetCurPoint()
  if curPoint <= 0 then
    return false
  end
  for i, v in ipairs(self.m_pointRewardList) do
    if v.iId == id then
      if curPoint >= v.iNeedPoint then
        return true
      else
        return false
      end
    end
  end
end

function CountConsumeActivity:FreshFirstAndPointReward()
  if not self.m_rewardDic then
    return
  end
  self.m_firstRewardList = {}
  self.m_pointRewardList = {}
  for id, v in pairs(self.m_rewardDic) do
    if v.iShowType == 1 then
      self.m_firstRewardList[#self.m_firstRewardList + 1] = v
    else
      self.m_pointRewardList[#self.m_pointRewardList + 1] = v
    end
  end
  table.sort(self.m_firstRewardList, function(a, b)
    return a.iId < b.iId
  end)
  table.sort(self.m_pointRewardList, function(a, b)
    return a.iId < b.iId
  end)
end

function CountConsumeActivity:GetTakenRewardList()
  return self.m_takenRewardList
end

function CountConsumeActivity:GetFirstRewardList()
  return self.m_firstRewardList
end

function CountConsumeActivity:GetPointRewardList()
  return self.m_pointRewardList
end

function CountConsumeActivity:GetRewardList()
  local rewardList = {}
  if self.m_rewardDic then
    for k, _ in pairs(self.m_rewardDic) do
      table.insert(rewardList, k)
    end
  end
  table.sort(rewardList, function(a, b)
    if a ~= b then
      return a < b
    end
  end)
  local showDataList = {}
  for k, _ in ipairs(rewardList) do
    table.insert(showDataList, self.m_rewardDic[rewardList[k]])
  end
  return showDataList
end

function CountConsumeActivity:GetCurPoint()
  if self:GetPointItemId() then
    return self.m_pointNum
  end
  return 0
end

function CountConsumeActivity:GetProductPointList()
  return self.m_productsListInfo
end

function CountConsumeActivity:GetProductPointInfo(sProductId)
  if self.m_productsListInfo then
    for k, v in pairs(self.m_productsListInfo) do
      if v.sProductId and v.sProductId == sProductId then
        return v.iPoint
      end
    end
  end
end

function CountConsumeActivity:GetSkinId()
  return self.m_skinID
end

function CountConsumeActivity:GetSkinName()
  local skinID = self:GetSkinId()
  if not skinID then
    return ""
  end
  local heroFashion = HeroManager:GetHeroFashion()
  if not heroFashion then
    return ""
  end
  local fashionInfoCfg = heroFashion:GetFashionInfoByID(skinID)
  if not fashionInfoCfg then
    return ""
  end
  return fashionInfoCfg.m_mFashionName or ""
end

function CountConsumeActivity:GetSpineAssetStr()
  local skinID = self:GetSkinId()
  if not skinID then
    return ""
  end
  local heroFashion = HeroManager:GetHeroFashion()
  if not heroFashion then
    return ""
  end
  local fashionInfoCfg = heroFashion:GetFashionInfoByID(skinID)
  if not fashionInfoCfg then
    return ""
  end
  return fashionInfoCfg.m_Spine or ""
end

function CountConsumeActivity:RequestRewardCS()
  local reqMsg = MTTDProto.Cmd_Act_CountConsume_TakeReward_CS()
  reqMsg.iActivityId = self:getID()
  RPCS():Act_CountConsume_TakeReward(reqMsg, handler(self, self.OnGetRewardSC))
end

function CountConsumeActivity:OnGetRewardSC(stGetReward, msg)
  if not stGetReward then
    return
  end
  if stGetReward.iActivityId ~= self:getID() then
    return
  end
  self.m_takenRewardList = stGetReward.vTakenReward
  utils.popUpRewardUI(stGetReward.vShowReward, function()
    self:broadcastEvent("eGameEvent_Activity_CountConsume_TakeReward", {
      iActivityID = self:getID()
    })
    self:broadcastEvent("eGameEvent_Activity_CountConsume_HallStatusFresh")
  end)
end

function CountConsumeActivity:ReqTakeRedPointReward()
  local activityID = self:getID()
  local reqMsg = MTTDProto.Cmd_Act_CountConsume_TakeRedpointReward_CS()
  reqMsg.iActivityId = activityID
  RPCS():Act_CountConsume_TakeRedpointReward(reqMsg, handler(self, self.OnReqTakeRedPointRewardSC))
end

function CountConsumeActivity:OnReqTakeRedPointRewardSC(stGetReward, msg)
  if not stGetReward then
    return
  end
  if self:getID() ~= stGetReward.iActivityId then
    return
  end
  self.m_isGetRedPointReward = true
  utils.popUpRewardUI(stGetReward.vShowReward, function()
    self:broadcastEvent("eGameEvent_Activity_CountConsume_RedPointReward", {
      iActivityID = self:getID()
    })
    self:broadcastEvent("eGameEvent_Activity_CountConsume_HallStatusFresh")
  end)
end

function CountConsumeActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_CountConsumeActivity
end

return CountConsumeActivity
