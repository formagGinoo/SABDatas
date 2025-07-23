local BaseManager = require("Manager/Base/BaseManager")
local GlobalRankManager = class("GlobalRankManager", BaseManager)
GlobalRankManager.RankValueType = {
  MainLevel = 1,
  FactionDevelopment = 2,
  Tower = 3
}
GlobalRankManager.RankType2RankValueType = {
  [1002] = GlobalRankManager.RankValueType.MainLevel,
  [2001] = GlobalRankManager.RankValueType.FactionDevelopment,
  [2002] = GlobalRankManager.RankValueType.FactionDevelopment,
  [2003] = GlobalRankManager.RankValueType.FactionDevelopment,
  [2004] = GlobalRankManager.RankValueType.FactionDevelopment,
  [3001] = GlobalRankManager.RankValueType.Tower,
  [3002] = GlobalRankManager.RankValueType.Tower,
  [3003] = GlobalRankManager.RankValueType.Tower,
  [3004] = GlobalRankManager.RankValueType.Tower,
  [3005] = GlobalRankManager.RankValueType.Tower
}

function GlobalRankManager:OnCreate()
  self.mRankTopRole = nil
  self.mFormatCollectRankNum = nil
  self.mvDrawnTargetReward = nil
  self.mmTargetRankTopRole = nil
  self.mAllRankInfoCfg = nil
  self.mFormatRankCollectRewardCfgList = nil
  self.bHaveNewTargetReddot = false
end

function GlobalRankManager:OnInitNetwork()
  RPCS():Listen_Push_NewRankTarget(handler(self, self.OnPushNewRankTarget), "GlobalRankManager")
end

function GlobalRankManager:OnInitMustRequestInFetchMore()
  local null_data = MTTDProto.Cmd_Rank_GetList_SC()
  self.mRankTopRole = null_data.mRankTopRole
  self.mvDrawnTargetReward = null_data.mvDrawnTargetReward
  self.mmTargetRankTopRole = null_data.mmTargetRankTopRole
  self:RqsRankGetList()
end

function GlobalRankManager:GetRankListTopRole()
  return self.mRankTopRole
end

function GlobalRankManager:GetCollectRankNum()
  return self.mFormatCollectRankNum
end

function GlobalRankManager:GetDrawnTargetRewardData()
  return self.mvDrawnTargetReward
end

function GlobalRankManager:GetTargetRankTopRole()
  return self.mmTargetRankTopRole
end

function GlobalRankManager:GetHaveNewTargetFlag()
  return self.bHaveNewTargetReddot
end

function GlobalRankManager:RqsRankGetList()
  local msg = MTTDProto.Cmd_Rank_GetList_CS()
  RPCS():Rank_GetList(msg, handler(self, self.OnRankGetListSC))
end

function GlobalRankManager:OnRankGetListSC(data)
  self.mRankTopRole = data.mRankTopRole
  self.mvDrawnTargetReward = data.mvDrawnTargetReward
  self.mmTargetRankTopRole = data.mmTargetRankTopRole
  self:FreshmCollectRankNum(data.mCollectRankNum)
  self:broadcastEvent("eGameEvent_RankGetList")
  self.bHaveNewTargetReddot = false
  self:IsGlobalRankEntryHaveRedDot()
end

function GlobalRankManager:FreshmCollectRankNum(mCollectRankNum)
  self.mFormatCollectRankNum = {}
  local allCfg = self:FormatAndGetAllRankCollectRewardCfg()
  for _, cfgList in pairs(allCfg) do
    local mRank = cfgList[1].m_Rank
    for rank, num in pairs(mCollectRankNum) do
      if rank <= mRank then
        self.mFormatCollectRankNum[mRank] = self.mFormatCollectRankNum[mRank] or 0
        self.mFormatCollectRankNum[mRank] = self.mFormatCollectRankNum[mRank] + num
      end
    end
  end
end

function GlobalRankManager:RqsGetRankByiRankType(iRankType)
  local msg = MTTDProto.Cmd_Rank_GetRank_CS()
  msg.iRankType = iRankType
  RPCS():Rank_GetRank(msg, handler(self, self.OnRankGetRankSC))
end

function GlobalRankManager:OnRankGetRankSC(data)
  self:broadcastEvent("eGameEvent_RankGetRank", data)
  self:IsGlobalRankEntryHaveRedDot()
end

function GlobalRankManager:RqsRankGetRole(iRankType, iRoleId, callback)
  local msg = MTTDProto.Cmd_Rank_GetRole_CS()
  msg.iRankType = iRankType
  msg.iRoleId = iRoleId
  RPCS():Rank_GetRole(msg, function(data)
    self:broadcastEvent("eGameEvent_RankGetRole", data)
    if callback then
      callback(data)
    end
  end)
end

function GlobalRankManager:ReqRoleSeeBusinessCard(uid, zoneID, callback)
  if not uid then
    return
  end
  if not zoneID then
    return
  end
  local msg = MTTDProto.Cmd_Role_SeeBusinessCard_CS()
  msg.iUid = uid
  msg.iZoneId = zoneID
  RPCS():Role_SeeBusinessCard(msg, function(data)
    if callback then
      callback(data.stRoleBusinessCard)
    end
  end)
end

function GlobalRankManager:RqsRankDrawTargetReward(iRankType, vTargetId)
  local msg = MTTDProto.Cmd_Rank_DrawTargetReward_CS()
  msg.iRankType = iRankType
  msg.vTargetId = vTargetId
  RPCS():Rank_DrawTargetReward(msg, handler(self, self.OnRankDrawTargetRewardSC))
end

function GlobalRankManager:OnRankDrawTargetRewardSC(data)
  local reward_list = data.vReward
  if reward_list and next(reward_list) then
    utils.popUpRewardUI(reward_list)
  end
  self.mvDrawnTargetReward = data.mvDrawnTargetReward
  self:broadcastEvent("eGameEvent_DrawTargetReward", data)
  self:IsGlobalRankEntryHaveRedDot()
end

function GlobalRankManager:RqsRankGetTargetRank(iRankType, iTargetId)
  local msg = MTTDProto.Cmd_Rank_GetTargetRank_CS()
  msg.iRankType = iRankType
  msg.iTargetId = iTargetId
  RPCS():Rank_GetTargetRank(msg, handler(self, self.OnRankGetTargetRankSC))
end

function GlobalRankManager:OnRankGetTargetRankSC(data)
  local vRankRole = data.vRankRole
  self:broadcastEvent("eGameEvent_GetTargetRank", vRankRole)
end

function GlobalRankManager:OnPushNewRankTarget()
  self.bHaveNewTargetReddot = true
  self:IsGlobalRankEntryHaveRedDot()
end

function GlobalRankManager:GetNextRewardCfg(tabIdx, collectCount)
  local mAllCollectRewardCfg = self:FormatAndGetAllRankCollectRewardCfg()
  local cfgList = mAllCollectRewardCfg[tabIdx]
  local nextCfg = cfgList[1]
  for i, cfg in ipairs(cfgList) do
    if collectCount >= cfg.m_Number then
      nextCfg = cfgList[i + 1] or cfg
    end
  end
  return nextCfg
end

function GlobalRankManager:GetAllRankInfoConfig()
  if self.mAllRankInfoCfg then
    return self.mAllRankInfoCfg
  end
  local allRankInfoCfg = ConfigManager:GetConfigInsByName("RankInfo"):GetAll()
  local cfgList = {}
  for k, v in pairs(allRankInfoCfg) do
    if v.m_IsShow == 1 then
      cfgList[#cfgList + 1] = v
    end
  end
  table.sort(cfgList, function(a, b)
    if a.m_RankID < b.m_RankID then
      return true
    end
  end)
  self.mAllRankInfoCfg = cfgList
  return cfgList
end

function GlobalRankManager:GetRankInfoByRankID(iRankID)
  local config = ConfigManager:GetConfigInsByName("RankInfo"):GetValue_ByRankID(iRankID)
  if config:GetError() then
    log.error("获取全局排行榜配置失败，无效的iRankID：" .. tostring(iRankID))
    return
  end
  return config
end

function GlobalRankManager:FormatAndGetAllRankCollectRewardCfg()
  if self.mFormatRankCollectRewardCfgList then
    return self.mFormatRankCollectRewardCfgList
  end
  local allCfg = ConfigManager:GetConfigInsByName("RankCollectReward"):GetAll()
  local tempList = {}
  for k, v in pairs(allCfg) do
    for _, vv in pairs(v) do
      if vv.m_Rank then
        tempList[vv.m_Rank] = tempList[vv.m_Rank] or {}
        tempList[vv.m_Rank][#tempList[vv.m_Rank] + 1] = vv
      end
    end
  end
  local formatCfgList = {}
  for _, cfgList in pairs(tempList) do
    table.sort(cfgList, function(a, b)
      return a.m_Number < b.m_Number
    end)
    formatCfgList[#formatCfgList + 1] = cfgList
  end
  table.sort(formatCfgList, function(a, b)
    return a[1].m_Rank < b[1].m_Rank
  end)
  self.mFormatRankCollectRewardCfgList = formatCfgList
  return formatCfgList
end

function GlobalRankManager:FormatAndGetAllRankTargetRewardCfg()
  if self.mFormatRankTargetRewardCfgList then
    return self.mFormatRankTargetRewardCfgList
  end
  local allCfg = ConfigManager:GetConfigInsByName("RankTargetReward"):GetAll()
  local tempList = {}
  for k, v in pairs(allCfg) do
    for key, vv in pairs(v) do
      if vv.m_RankID then
        tempList[vv.m_RankID] = tempList[vv.m_RankID] or {}
        tempList[vv.m_RankID][#tempList[vv.m_RankID] + 1] = vv
      end
    end
  end
  for _, v in pairs(tempList) do
    table.sort(v, function(a, b)
      return a.m_TargetID < b.m_TargetID
    end)
  end
  self.mFormatRankTargetRewardCfgList = tempList
  return tempList
end

function GlobalRankManager:GetRankTargetRewardCfgListByRankID(m_RankID)
  return self:FormatAndGetAllRankTargetRewardCfg()[m_RankID]
end

function GlobalRankManager:IsGlobalRankTargetCanRec(params)
  local rankID = params[1]
  local rankInfoCfg = self:GetRankInfoByRankID(rankID)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(rankInfoCfg.m_SystemID)
  if not openFlag then
    return 0, {}
  end
  local allCfg = self:FormatAndGetAllRankTargetRewardCfg()[rankID]
  local mvDrawnTargetReward = self:GetDrawnTargetRewardData()
  local mmTargetRankTopRole = self.mmTargetRankTopRole
  if not mmTargetRankTopRole then
    return 0, {}
  end
  local curRankTopRole = mmTargetRankTopRole[rankID]
  local list = {}
  if mvDrawnTargetReward then
    local curRewardData = mvDrawnTargetReward[rankID]
    for i, cfg in ipairs(allCfg) do
      if (not curRewardData or not curRewardData[i]) and curRankTopRole and curRankTopRole[cfg.m_TargetID] then
        list[#list + 1] = cfg.m_TargetID
      end
    end
  end
  return #list, list
end

function GlobalRankManager:IsGlobalRankEntryHaveRedDot()
  local allCfg = self:FormatAndGetAllRankTargetRewardCfg()
  local count = 0
  for rankID, cfgList in pairs(allCfg) do
    local num, list = self:IsGlobalRankTargetCanRec({rankID})
    if 0 < num then
      count = count + 1
      break
    end
  end
  if self.bHaveNewTargetReddot then
    count = count + 1
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.GlobalRankEntry,
    count = count
  })
  return count
end

return GlobalRankManager
