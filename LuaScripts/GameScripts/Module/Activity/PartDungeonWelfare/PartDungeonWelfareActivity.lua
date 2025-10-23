local BaseActivity = require("Base/BaseActivity")
local PartDungeonWelfareActivity = class("PartDungeonWelfareActivity", BaseActivity)

function PartDungeonWelfareActivity.getActivityType(_)
  return MTTD.ActivityType_PartDungeonWelfare
end

function PartDungeonWelfareActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgPartDungeonWelfare
end

function PartDungeonWelfareActivity.getStatusProto(_)
  return MTTDProto.CmdActPartDungeonWelfare_Status
end

function PartDungeonWelfareActivity:OnCreate()
  self.m_totalScore = 0
  self.m_drawScore = 0
  self.m_selfScore = 0
  self.m_toBeClaimedRewards = false
  self.init = false
  RPCS():Listen_Push_SetQuestDataBatch(handler(self, self.OnPushSetQuestDataBatch), "PartDungeonWelfareActivity")
  RPCS():Listen_Push_Act_PartDungeonWelfareTotalScoreUpdate(handler(self, self.OnPushPartDungeonWelfareTotalScoreUpdate), "PartDungeonWelfareActivity")
end

function PartDungeonWelfareActivity:OnResetSdpConfig(m_stSdpConfig)
  self.m_PartDungeonWelfareCfg = {}
  if m_stSdpConfig and m_stSdpConfig.stCommonCfg then
    self.m_PartDungeonWelfareCfg = m_stSdpConfig.stCommonCfg
    if not self.init then
      self.init = true
      self:RequestQuestsCS()
    end
  end
end

function PartDungeonWelfareActivity:GetWelfareCfg()
  return self.m_PartDungeonWelfareCfg
end

function PartDungeonWelfareActivity:OnResetStatusData(m_stStatusData)
  if m_stStatusData then
    self.m_drawScore = m_stStatusData.iDrawScore
    self.m_selfScore = m_stStatusData.iSelfScore
    self:GetTotalScoreCS(self:getID())
    if self:checkShowRed() then
      self:broadcastEvent("eGameEvent_Activity_PartDungeonWelfare_TotalScoreChange_FreshRedDot", GlobalConfig.SYSTEM_ID.Dungeon)
    end
  end
end

function PartDungeonWelfareActivity:checkCondition()
  if not PartDungeonWelfareActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityShowTime() then
    return false
  end
  return true
end

function PartDungeonWelfareActivity:checkShowRed()
  local bHaveAward = false
  local mRewardConfig = self.m_PartDungeonWelfareCfg.mRewardConfig
  for i, v in pairs(mRewardConfig) do
    if i <= self.m_totalScore and not (i <= self.m_drawScore) then
      bHaveAward = true
    end
  end
  return bHaveAward or self:HaveTaskRedDot()
end

function PartDungeonWelfareActivity:GetTotalScoreCS(iActivityId)
  local reqMsg = MTTDProto.Cmd_Act_PartDungeonWelfare_GetTotalScore_CS()
  reqMsg.iActivityId = iActivityId
  RPCS():Act_PartDungeonWelfare_GetTotalScore(reqMsg, handler(self, self.OnGetTotalScoreSC))
end

function PartDungeonWelfareActivity:OnGetTotalScoreSC(sc, msg)
  self.m_totalScore = sc.iTotalScore
end

function PartDungeonWelfareActivity:DrawRewardCS(iActivityId, score)
  local reqMsg = MTTDProto.Cmd_Act_PartDungeonWelfare_DrawReward_CS()
  reqMsg.iActivityId = iActivityId
  reqMsg.iDrawScore = score
  RPCS():Act_PartDungeonWelfare_DrawReward(reqMsg, handler(self, self.OnDrawRewardSC))
end

function PartDungeonWelfareActivity:OnDrawRewardSC(sc, msg)
  self:broadcastEvent("eGameEvent_Activity_PartDungeonWelfare_GetReward", sc.vReward)
end

function PartDungeonWelfareActivity:RequestQuestsCS()
  self.m_questStatus = {}
  self.m_overQuests = {}
  local reqMsg = MTTDProto.Cmd_Quest_GetList_CS()
  reqMsg.iQuestType = self:getID()
  RPCS():Quest_GetList(reqMsg, handler(self, self.OnRequestQuestsSC))
end

function PartDungeonWelfareActivity:OnRequestQuestsSC(sc, msg)
  local vQuest = sc.vQuest
  local vOver = sc.vOver
  for k, v in ipairs(vQuest) do
    self.m_questStatus[v.iId] = v
    if v.iState == MTTDProto.QuestState_Finish then
      self.m_toBeClaimedRewards = true
    end
  end
  for _, v in ipairs(vOver) do
    table.insert(self.m_overQuests, v)
  end
end

function PartDungeonWelfareActivity:RequestReceiveTask(vQuestId)
  local reqMsg = MTTDProto.Cmd_Quest_TakeReward_CS()
  reqMsg.iQuestType = self:getID()
  reqMsg.vQuestId = {vQuestId}
  RPCS():Quest_TakeReward(reqMsg, handler(self, self.OnRequestReceiveTaskSC))
end

function PartDungeonWelfareActivity:OnRequestReceiveTaskSC(sc, msg)
  if sc then
    utils.popUpRewardUI(sc.vReward)
  end
end

function PartDungeonWelfareActivity:OnPushPartDungeonWelfareTotalScoreUpdate(sc, msg)
  if sc and sc.iActivityId == self:getID() then
    self.m_totalScore = sc.iTotalScore
    self:broadcastEvent("eGameEvent_Activity_PartDungeonWelfare_TotalScoreChange")
    if self:checkShowRed() then
      self:broadcastEvent("eGameEvent_Activity_PartDungeonWelfare_TotalScoreChange_FreshRedDot", GlobalConfig.SYSTEM_ID.Dungeon)
    end
  end
end

function PartDungeonWelfareActivity:OnPushSetQuestDataBatch(sc, msg)
  local vQuest = sc.vCmdQuestInfo
  self.m_toBeClaimedRewards = false
  local isChange = false
  if vQuest then
    for _, stQuestStatus in pairs(vQuest) do
      if stQuestStatus.iType == self:getID() and self.m_questStatus then
        for k, stQuestStatusTmp in pairs(self.m_questStatus) do
          if stQuestStatusTmp.iId == stQuestStatus.iId then
            if stQuestStatus.iState == MTTDProto.QuestState_Finish then
              self.m_toBeClaimedRewards = true
            end
            if stQuestStatus.iState == MTTDProto.QuestState_Over then
              table.insert(self.m_overQuests, stQuestStatus.iId)
              self.m_questStatus[k] = nil
            end
            stQuestStatusTmp.iState = stQuestStatus.iState
            stQuestStatusTmp.vCondStep = stQuestStatus.vCondStep
            isChange = true
          elseif stQuestStatusTmp.iState == MTTDProto.QuestState_Finish then
            self.m_toBeClaimedRewards = true
          end
        end
      end
    end
  end
  if isChange then
    self:broadcastEvent("eGameEvent_Activity_PartDungeonWelfare_QuestStatuChange")
  end
end

function PartDungeonWelfareActivity:GetFightSubType()
  return self.m_PartDungeonWelfareCfg.vFightSubType
end

function PartDungeonWelfareActivity:GetTotalScore()
  return self.m_totalScore
end

function PartDungeonWelfareActivity:GetDrawScore()
  return self.m_drawScore
end

function PartDungeonWelfareActivity:GetSelfScore()
  return self.m_selfScore
end

function PartDungeonWelfareActivity:GetDetailDesc()
  return self:getLangText(self.m_stActivityData.sDetailDesc)
end

function PartDungeonWelfareActivity:GetActivityPic()
  return self.m_stActivityData.sActivityPic
end

function PartDungeonWelfareActivity:GetIcon()
  return self.m_stActivityData.sIcon
end

function PartDungeonWelfareActivity:GetEndTime()
  local endTime = 0
  local endTimeStr = ""
  if self:isInActivityTime() then
    endTimeStr = ConfigManager:GetCommonTextById(20395)
    endTime = self.m_stActivityData.iEndTime
  elseif self:isInActivityShowTime() then
    endTimeStr = ConfigManager:GetCommonTextById(20396)
    endTime = self.m_stActivityData.iShowTimeEnd
  end
  return endTime, endTimeStr
end

function PartDungeonWelfareActivity:GetQuestStatus()
  return self.m_questStatus
end

function PartDungeonWelfareActivity:GetOverQuests()
  return self.m_overQuests
end

function PartDungeonWelfareActivity:HaveTaskRedDot()
  return self.m_toBeClaimedRewards
end

return PartDungeonWelfareActivity
