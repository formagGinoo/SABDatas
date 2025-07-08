local BaseActivity = require("Base/BaseActivity")
local LevelAwardActivity = class("LevelAwardActivity", BaseActivity)
local TypeEnum = {
  Normal = 1,
  SingleHero = 2,
  MultiHero = 3,
  EmbraceBonus = 4,
  FirstRecharge = 5
}
local Num2NormalType = {
  [7] = ActivityManager.ActivitySubPanelName.ActivitySPName_LevelAwardActivity2,
  [8] = ActivityManager.ActivitySubPanelName.ActivitySPName_LevelAwardActivity
}

function LevelAwardActivity.getActivityType(_)
  return MTTD.ActivityType_LevelAward
end

function LevelAwardActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgLevelAward
end

function LevelAwardActivity.getStatusProto(_)
  return MTTDProto.CmdActLevelAward_Status
end

function LevelAwardActivity:RequestGetReward(iId, callback)
  local reqMsg = MTTDProto.Cmd_Act_LevelAward_GetAward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iID = iId
  
  local function OnRequestGetRewardSC(sc, msg)
    if callback then
      callback(sc, {
        iActivityID = self:getID(),
        iId = iId
      })
      return
    end
    self:OnRequestGetRewardSC(sc, msg)
    self:broadcastEvent("eGameEvent_Activity_LevelAwardUpdate", {
      iActivityID = self:getID(),
      iId = iId
    })
  end
  
  RPCS():Act_LevelAward_GetAward(reqMsg, OnRequestGetRewardSC)
end

function LevelAwardActivity:OnRequestGetRewardSC(sc, msg)
  local vReward = sc.vReward
  utils.popUpRewardUI(vReward)
end

function LevelAwardActivity:OnResetSdpConfig()
  self.m_vQuestList = {}
  self.m_clientCfg = {}
  if self.m_stSdpConfig then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.mQuest) do
      stInfo.sName = self:getLangText(stInfo.sName)
      self.m_vQuestList[#self.m_vQuestList + 1] = stInfo
    end
    self.m_clientCfg = self.m_stSdpConfig.stClientCfg
  end
  if #self.m_vQuestList > 1 then
    table.sort(self.m_vQuestList, function(a, b)
      return a.iId < b.iId
    end)
  end
  self:broadcastEvent("eGameEvent_Activity_LevelAwardUpdate")
end

function LevelAwardActivity:GetQuestList()
  return self.m_vQuestList
end

function LevelAwardActivity:GetClientCfg()
  if self.m_clientCfg.iShowType == TypeEnum.SingleHero then
    return self.m_clientCfg.stOneHeroConfig
  elseif self.m_clientCfg.iShowType == TypeEnum.MultiHero then
    return self.m_clientCfg.stMultiHeroConfig
  end
  return self.m_clientCfg
end

function LevelAwardActivity:OnResetStatusData()
  self:broadcastEvent("eGameEvent_Activity_LevelAwardUpdate", {
    iActivityID = self:getID()
  })
end

function LevelAwardActivity:checkCondition(bIsShow)
  if not LevelAwardActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if bIsShow and (self.m_clientCfg.iShowType == TypeEnum.SingleHero or self.m_clientCfg.iShowType == TypeEnum.MultiHero or self.m_clientCfg.iShowType == TypeEnum.FirstRecharge or self.m_clientCfg.iShowType == TypeEnum.EmbraceBonus or self.m_clientCfg.iShowType == TypeEnum.Normal) then
    return not self:isAllTaskFinished()
  end
  return true
end

function LevelAwardActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() then
    openFlag = true
  end
  return openFlag
end

function LevelAwardActivity:GetQuestState(iId)
  local vQuest = self.m_stStatusData.vQuest
  for k, v in ipairs(vQuest) do
    if v.iId == iId then
      return v
    end
  end
  return nil
end

function LevelAwardActivity:checkQuestCanGetReward(iId)
  local vQuest = self.m_stStatusData.vQuest
  for k, v in ipairs(vQuest) do
    if v.iId == iId and v.iState == MTTDProto.QuestState_Finish then
      return true
    end
  end
end

function LevelAwardActivity:isAllTaskFinished()
  local vQuest = self.m_stStatusData.vQuest
  local isAllFinished = true
  for k, v in ipairs(vQuest) do
    if v.iState ~= MTTDProto.QuestState_Over then
      isAllFinished = false
    end
  end
  return isAllFinished
end

function LevelAwardActivity:checkShowRed()
  if not self:CheckActivityIsOpen() then
    return false
  end
  for _, stInfo in ipairs(self.m_vQuestList) do
    if self:checkQuestCanGetReward(stInfo.iId) then
      return true
    end
  end
  return false
end

function LevelAwardActivity:getSubPanelName()
  if self.m_clientCfg.iShowType == TypeEnum.Normal then
    return Num2NormalType[#self.m_vQuestList]
  elseif self.m_clientCfg.iShowType == TypeEnum.SingleHero then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_EmpousaActivity
  elseif self.m_clientCfg.iShowType == TypeEnum.MultiHero then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_CliveActivity
  elseif self.m_clientCfg.iShowType == TypeEnum.EmbraceBonus then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_EmbraceBonusActivity
  elseif self.m_clientCfg.iShowType == TypeEnum.FirstRecharge then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_FirstRechargeActivity
  end
end

function LevelAwardActivity:GetRedQuestId()
  if self.m_clientCfg and self.m_clientCfg.iRedQuestId then
    return self.m_clientCfg.iRedQuestId
  end
end

return LevelAwardActivity
