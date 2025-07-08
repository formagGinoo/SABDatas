local BaseManager = require("Manager/Base/BaseManager")
local RankManager = class("RankManager", BaseManager)
RankManager.RankType = {
  Arena = 1,
  ReplacePVPGrade = 2,
  ReplacePVPScore = 3,
  PersonalRaid = 4,
  HuntingRaid = 5
}
RankManager.RankPanelReportType = {
  RankList = 1,
  RankListGift = 2,
  RankListReward = 3
}
RankManager.ColorEnum = {
  first = Color(0.9647058823529412, 0.9215686274509803, 0.7568627450980392),
  second = Color(0.8117647058823529, 0.8235294117647058, 0.8862745098039215),
  third = Color(0.8196078431372549, 0.7254901960784313, 0.6509803921568628),
  normal = Color(0.37254901960784315, 0.3333333333333333, 0.3333333333333333),
  firstbg = Color(0.9725490196078431, 0.9686274509803922, 0.9490196078431372),
  normalbg = Color(0.9058823529411765, 0.8980392156862745, 0.8862745098039215)
}

function RankManager:OnCreate()
  self.m_RankDataList = {}
  self.m_MyRankDataList = {}
  self.rankListReqCDInfo = {}
end

function RankManager:OnInitNetwork()
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  self.iMaxWaitTime = tonumber(GlobalManagerIns:GetValue_ByName("RanklistCommonPushCD").m_Value) or 30
end

function RankManager:ReqArenaRankListCS(rankType, iBeginRank, iEndRank, extData)
  if not self:CheckIsCanReqRankList(rankType, iBeginRank, extData) then
    self:broadcastEvent("eGameEvent_UpDataRankList", rankType)
    return
  end
  if iBeginRank == 1 then
    self:ResetRankDataListBySystemId(rankType, extData)
    self:ResetOwnerRankDataListBySystemId(rankType, extData)
  end
  if rankType == RankManager.RankType.Arena then
    self:ReqOriginalArenaRankListCS(tonumber(iBeginRank), tonumber(iEndRank))
  elseif rankType == RankManager.RankType.ReplacePVPGrade then
    self:ReqReplaceArenaGradeRankList(tonumber(iBeginRank), tonumber(iEndRank))
  elseif rankType == RankManager.RankType.ReplacePVPScore then
    self:ReqReplaceArenaScoreRankList(tonumber(iBeginRank), tonumber(iEndRank))
  elseif rankType == RankManager.RankType.ReplacePVPScore then
    self:ReqReplaceArenaScoreRankList(tonumber(iBeginRank), tonumber(iEndRank))
  elseif rankType == RankManager.RankType.PersonalRaid then
    self:ReqSoloRaidGetRankListCS(tonumber(iBeginRank), tonumber(iEndRank))
  elseif rankType == RankManager.RankType.HuntingRaid then
    self:ReqHuntingGetRankListCS(tonumber(iBeginRank), tonumber(iEndRank), extData)
  end
end

function RankManager:CheckIsCanReqRankList(rankType, iBeginRank, extData)
  local cacheTime = self.rankListReqCDInfo[rankType] and self.rankListReqCDInfo[rankType][iBeginRank]
  local time
  if extData ~= nil then
    time = cacheTime and cacheTime[extData] or 0
  else
    time = cacheTime or 0
  end
  local cur_time = TimeUtil:GetServerTimeS()
  if cur_time - time <= self.iMaxWaitTime then
    return false
  end
  self.rankListReqCDInfo[rankType] = self.rankListReqCDInfo[rankType] or {}
  if extData ~= nil then
    self.rankListReqCDInfo[rankType][iBeginRank] = self.rankListReqCDInfo[rankType][iBeginRank] or {}
    self.rankListReqCDInfo[rankType][iBeginRank][extData] = cur_time
  else
    self.rankListReqCDInfo[rankType][iBeginRank] = cur_time
  end
  return true
end

function RankManager:UpDataArenaRankData(rankType, vRankList)
  local arenaData = self.m_RankDataList[rankType]
  local newRankDataList = {}
  if arenaData then
    local dataList = {}
    for i, v in pairs(vRankList) do
      local isHave = false
      for m, n in ipairs(arenaData) do
        if v.iRank == n.iRank then
          v = n
          isHave = true
        end
      end
      if not isHave then
        dataList[#dataList + 1] = v
      end
    end
    if 0 < #dataList then
      newRankDataList = arenaData
      for i, v in ipairs(dataList) do
        newRankDataList[#newRankDataList + 1] = v
      end
    else
      newRankDataList = arenaData
    end
  else
    for i, v in pairs(vRankList) do
      newRankDataList[#newRankDataList + 1] = v
    end
  end
  self.m_RankDataList[rankType] = newRankDataList
end

function RankManager:UpDataArenaRankDataExt(rankType, vRankList, rankKey)
  local arenaDataList = self.m_RankDataList[rankType]
  if not arenaDataList then
    self.m_RankDataList[rankType] = {}
  end
  local arenaData = self.m_RankDataList[rankType][rankKey]
  local newRankDataList = {}
  if arenaData then
    local dataList = {}
    for i, v in pairs(vRankList) do
      local isHave = false
      for m, n in ipairs(arenaData) do
        if v.iRank == n.iRank then
          v = n
          isHave = true
        end
      end
      if not isHave then
        dataList[#dataList + 1] = v
      end
    end
    if 0 < #dataList then
      newRankDataList = arenaData
      for i, v in ipairs(dataList) do
        newRankDataList[#newRankDataList + 1] = v
      end
    else
      newRankDataList = arenaData
    end
  else
    for i, v in pairs(vRankList) do
      newRankDataList[#newRankDataList + 1] = v
    end
  end
  self.m_RankDataList[rankType][rankKey] = newRankDataList
end

function RankManager:UpDataOwnerArenaRankData(rankType, stData)
  local iMyRank = stData.iMyRank
  local iMyScore = stData.iMyScore
  local iMyPower = stData.iMyPower
  local iRankSize = stData.iRankSize
  self.m_MyRankDataList[rankType] = {
    iMyRank = iMyRank,
    iMyScore = iMyScore,
    iMyPower = iMyPower,
    iRankSize = iRankSize
  }
end

function RankManager:UpDataOwnerArenaRankDataExt(rankType, stData, rankKey)
  local iMyRank = stData.iMyRank
  local iMyScore = stData.iMyScore
  local iMyPower = stData.iMyPower
  local iRankSize = stData.iRankSize
  local iBossId = stData.iBossId
  local iMyValue = stData.iMyValue
  if not self.m_MyRankDataList[rankType] then
    self.m_MyRankDataList[rankType] = {}
  end
  self.m_MyRankDataList[rankType][rankKey] = {
    iMyRank = iMyRank,
    iMyScore = iMyScore,
    iMyPower = iMyPower,
    iRankSize = iRankSize,
    iBossId = iBossId,
    iMyValue = iMyValue
  }
end

function RankManager:GetRankDataListBySystemId(rankType)
  return self.m_RankDataList[rankType] or {}
end

function RankManager:GetOwnerRankDataListBySystemId(rankType)
  return self.m_MyRankDataList[rankType]
end

function RankManager:GetRankDataListBySystemIdAndRankKey(rankType, rankKey)
  if self.m_RankDataList[rankType] and self.m_RankDataList[rankType][rankKey] then
    return self.m_RankDataList[rankType][rankKey]
  end
  return {}
end

function RankManager:GetOwnerRankDataListBySystemIdAndRankKey(rankType, rankKey)
  if self.m_MyRankDataList[rankType] and self.m_MyRankDataList[rankType][rankKey] then
    return self.m_MyRankDataList[rankType][rankKey]
  end
  return {}
end

function RankManager:ResetRankDataListBySystemId(rankType, extData)
  if not self.m_RankDataList[rankType] then
    return
  end
  if rankType == RankManager.RankType.HuntingRaid then
    if extData ~= nil then
      self.m_RankDataList[rankType][extData] = nil
    else
      self.m_RankDataList[rankType] = nil
    end
  else
    self.m_RankDataList[rankType] = nil
  end
end

function RankManager:ResetOwnerRankDataListBySystemId(rankType, extData)
  if not self.m_MyRankDataList[rankType] then
    return
  end
  if rankType == RankManager.RankType.HuntingRaid then
    if extData ~= nil then
      self.m_MyRankDataList[rankType][extData] = nil
    else
      self.m_MyRankDataList[rankType] = nil
    end
  else
    self.m_MyRankDataList[rankType] = nil
  end
end

function RankManager:ReqOriginalArenaRankListCS(iBeginRank, iEndRank)
  local reqMsg = MTTDProto.Cmd_OriginalArena_RankList_CS()
  reqMsg.iBeginRank = iBeginRank
  reqMsg.iEndRank = iEndRank
  RPCS():OriginalArena_RankList(reqMsg, handler(self, self.OnReqOriginalArenaRankListSC))
end

function RankManager:OnReqOriginalArenaRankListSC(stData, msg)
  local vRankList = stData.vRankList
  self:UpDataArenaRankData(RankManager.RankType.Arena, vRankList)
  self:UpDataOwnerArenaRankData(RankManager.RankType.Arena, stData)
  self:broadcastEvent("eGameEvent_UpDataRankList", RankManager.RankType.Arena)
end

function RankManager:ReqReplaceArenaGradeRankList(iBeginRank, iEndRank)
  local reqMsg = MTTDProto.Cmd_ReplaceArena_GetRankList_CS()
  reqMsg.iRankType = MTTDProto.ReplaceArenaRankType_GradeRank
  reqMsg.iBeginRank = iBeginRank
  reqMsg.iEndRank = iEndRank
  RPCS():ReplaceArena_GetRankList(reqMsg, handler(self, self.OnReplaceArenaGradeRankListSC))
end

function RankManager:OnReplaceArenaGradeRankListSC(stData, msg)
  local vRankList = stData.vRankList
  self:UpDataArenaRankData(RankManager.RankType.ReplacePVPGrade, vRankList)
  self:UpDataOwnerArenaRankData(RankManager.RankType.ReplacePVPGrade, stData)
  self:broadcastEvent("eGameEvent_UpDataRankList", RankManager.RankType.ReplacePVPGrade)
end

function RankManager:ReqReplaceArenaScoreRankList(iBeginRank, iEndRank)
  local reqMsg = MTTDProto.Cmd_ReplaceArena_GetRankList_CS()
  reqMsg.iRankType = MTTDProto.ReplaceArenaRankType_ScoreRank
  reqMsg.iBeginRank = iBeginRank
  reqMsg.iEndRank = iEndRank
  RPCS():ReplaceArena_GetRankList(reqMsg, handler(self, self.OnReplaceArenaScoreRankListSC))
end

function RankManager:OnReplaceArenaScoreRankListSC(stData, msg)
  local vRankList = stData.vRankList
  self:UpDataArenaRankData(RankManager.RankType.ReplacePVPScore, vRankList)
  self:UpDataOwnerArenaRankData(RankManager.RankType.ReplacePVPScore, stData)
  self:broadcastEvent("eGameEvent_UpDataRankList", RankManager.RankType.ReplacePVPScore)
end

function RankManager:ReqSoloRaidGetRankListCS(iBeginRank, iEndRank)
  local dataCSMsg = MTTDProto.Cmd_SoloRaid_GetRankList_CS()
  dataCSMsg.iBeginRank = iBeginRank
  dataCSMsg.iEndRank = iEndRank
  RPCS():SoloRaid_GetRankList(dataCSMsg, handler(self, self.OnSoloGetRankListSC))
end

function RankManager:OnSoloGetRankListSC(stData, msg)
  local vRankList = stData.vRankList
  self:UpDataArenaRankData(RankManager.RankType.PersonalRaid, vRankList)
  self:UpDataOwnerArenaRankData(RankManager.RankType.PersonalRaid, stData)
  self:broadcastEvent("eGameEvent_UpDataRankList", RankManager.RankType.PersonalRaid)
end

function RankManager:ReqHuntingGetRankListCS(iBeginRank, iEndRank, iBossId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if activity then
    local dataCSMsg = MTTDProto.Cmd_Hunting_GetRankList_CS()
    dataCSMsg.iBeginRank = iBeginRank
    dataCSMsg.iEndRank = iEndRank
    dataCSMsg.iBossId = iBossId
    dataCSMsg.iActivityId = activity:getID()
    RPCS():Hunting_GetRankList(dataCSMsg, handler(self, self.OnHuntingGetRankListSC))
  else
    log.error("RankManager can not get ActivityType_Hunting !!!")
  end
end

function RankManager:OnHuntingGetRankListSC(stData, msg)
  local vRankList = stData.vRankList
  self:UpDataArenaRankDataExt(RankManager.RankType.HuntingRaid, vRankList, stData.iBossId)
  self:UpDataOwnerArenaRankDataExt(RankManager.RankType.HuntingRaid, stData, stData.iBossId)
  self:broadcastEvent("eGameEvent_UpDataRankList", RankManager.RankType.HuntingRaid)
end

function RankManager:SendRankReport(rankId, rankPanelType, stayTime)
  local params = {
    Rankid = rankId,
    Type = rankPanelType,
    Stay_time = tonumber(stayTime)
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.Rank_stay_time, params)
end

return RankManager
