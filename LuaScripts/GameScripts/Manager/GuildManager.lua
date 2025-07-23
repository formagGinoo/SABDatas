local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local GuildManager = class("GuildManager", BaseLevelManager)
GuildManager.AllianceJoinType = {
  AllianceJoinType_Review = 0,
  AllianceJoinType_All = 1,
  AllianceJoinType_None = 2
}
GuildManager.AllianceMemberSortType = {
  Login = 1,
  Activity = 2,
  Level = 3,
  Combat = 4
}
GuildManager.GuildJoinType = {
  {
    iIndex = 1,
    sTitle = 20052,
    joinType = GuildManager.AllianceJoinType.AllianceJoinType_Review
  },
  {
    iIndex = 2,
    sTitle = 20051,
    joinType = GuildManager.AllianceJoinType.AllianceJoinType_All
  },
  {
    iIndex = 3,
    sTitle = 20053,
    joinType = GuildManager.AllianceJoinType.AllianceJoinType_None
  }
}
GuildManager.GuildMemberFilter = {
  {
    iIndex = 1,
    sTitle = 20059,
    sortType = GuildManager.AllianceMemberSortType.Login
  },
  {
    iIndex = 2,
    sTitle = 20058,
    sortType = GuildManager.AllianceMemberSortType.Activity
  },
  {
    iIndex = 3,
    sTitle = 20057,
    sortType = GuildManager.AllianceMemberSortType.Level
  },
  {
    iIndex = 4,
    sTitle = 20056,
    sortType = GuildManager.AllianceMemberSortType.Combat
  }
}
GuildManager.AlliancePost = {
  Master = 1,
  Vice = 2,
  Member = 3
}
GuildManager.AlliancePostInfo = {
  [GuildManager.AlliancePost.Master] = {
    icon = "Atlas_Guild/guild_icon_gold",
    name = 10227
  },
  [GuildManager.AlliancePost.Vice] = {
    icon = "Atlas_Guild/guild_icon_silver",
    name = 10228
  },
  [GuildManager.AlliancePost.Member] = {icon = "", name = 10229}
}
GuildManager.AllianceHistoryType = {
  Create = 1,
  Transfer = 2,
  PostToLeader = 3,
  PostToNormal = 4,
  JoinAlliance = 5,
  LeaveAlliance = 6,
  KickAlliance = 7,
  LevelUp = 8,
  Like = 9,
  AutoTransfer = 99,
  StageOpen = 100,
  StageFinish = 101,
  StageRollReward = 102
}
GuildManager.AllianceHistoryTypeStr = {
  [GuildManager.AllianceHistoryType.Create] = 10201,
  [GuildManager.AllianceHistoryType.Transfer] = 10230,
  [GuildManager.AllianceHistoryType.PostToLeader] = 10205,
  [GuildManager.AllianceHistoryType.JoinAlliance] = 10202,
  [GuildManager.AllianceHistoryType.LeaveAlliance] = 10203,
  [GuildManager.AllianceHistoryType.KickAlliance] = 10204,
  [GuildManager.AllianceHistoryType.LevelUp] = 10206,
  [GuildManager.AllianceHistoryType.AutoTransfer] = 10230
}
GuildManager.AllianceSettingsType = {
  Name = 1,
  Badge = 2,
  JoinType = 3,
  JoinLevel = 4,
  LanguageId = 5,
  Recruit = 6,
  Bulletin = 7
}

function GuildManager:OnCreate()
  self.m_ownerGuildDetail = nil
  self.m_initGuildData = nil
  self.m_recommendGuildList = {}
  self.m_recommendGuildTimer = nil
  self.m_ownerGuildHistory = {}
  self.m_bLikeHistory = {}
  self.m_roleApplyIdList = {}
  self.m_AllianceInviteList = nil
  self.m_likeMemberList = nil
  self.m_iLikeTimes = 0
  self.m_iSignNum = nil
  self.m_iSignTime = nil
  self.m_vApplyList = nil
  self.m_guildBossData = {}
  self.m_dailyChallengeTimes = 0
  self.m_usedFightHero = {}
  self.m_guildBossHistory = {}
  self.m_guildBossRankList = {}
  self.m_myBossRank = 0
  self.m_battleResultData = {}
end

function GuildManager:OnInitNetwork()
  RPCS():Listen_Push_Alliance_SettingChange(handler(self, self.OnPushAllianceSettingChange), "GuildManager")
  RPCS():Listen_Push_Alliance_MemberJoin(handler(self, self.OnPushAllianceMemberJoin), "GuildManager")
  RPCS():Listen_Push_Alliance_PostChange(handler(self, self.OnPushAlliancePostChange), "GuildManager")
  RPCS():Listen_Push_Alliance_MemberLeave(handler(self, self.OnPushAllianceMemberLeave), "GuildManager")
  RPCS():Listen_Push_Alliance_BeInvite(handler(self, self.OnPushAllianceBeInvite), "GuildManager")
  RPCS():Listen_Push_Alliance_Transfer(handler(self, self.OnPushAllianceTransfer), "GuildManager")
  RPCS():Listen_Push_Alliance_Destroy(handler(self, self.OnPushAllianceDestroy), "GuildManager")
  RPCS():Listen_Push_Alliance_DelRoleApply(handler(self, self.OnPushDelRoleApply), "GuildManager")
  RPCS():Listen_Push_AllianceBattle_NewRound(handler(self, self.OnPushAllianceBattleNewRound), "GuildManager")
  RPCS():Listen_Push_Alliance_Battle_Boss(handler(self, self.OnPushAllianceBattleBoss), "GuildManager")
  self:addEventListener("eGameEvent_Alliance_GetRecommendList", handler(self, self.OnGetGuildListData))
end

function GuildManager:OnInitMustRequestInFetchMore()
  self:ReqAllianceGetInit()
end

function GuildManager:OnAfterInitConfig()
  self.m_guildBattleTimesCfgNum = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildBattleTimes"))
  GuildManager.FightType_AllianceBattle = MTTDProto.FightType_AllianceBattle
  GuildManager.FightAllianceBattleSubType_Battle = MTTDProto.FightAllianceBattleSubType_Battle
end

function GuildManager:OnDailyReset()
  self.m_likeMemberList = nil
  self.m_iLikeTimes = 0
  self:ReqAllianceGetInit()
end

function GuildManager:OnGetGuildListData(data)
  StackFlow:Push(UIDefines.ID_FORM_GUILDLIST, data)
end

function GuildManager:OnPushAllianceSettingChange(data, msg)
  local guildData = self:GetOwnerGuildDetail()
  if not guildData then
    return
  end
  local stBriefData = guildData.stBriefData
  for i, settingType in ipairs(data.vChangeSettingsType) do
    if GuildManager.AllianceSettingsType.Name == settingType then
      stBriefData.sName = data.sName
    elseif GuildManager.AllianceSettingsType.Badge == settingType then
      stBriefData.iBadgeId = data.iBadgeId
    elseif GuildManager.AllianceSettingsType.JoinType == settingType then
      stBriefData.iJoinType = data.iJoinType
    elseif GuildManager.AllianceSettingsType.JoinLevel == settingType then
      stBriefData.iJoinLevel = data.iJoinLevel
    elseif GuildManager.AllianceSettingsType.LanguageId == settingType then
      stBriefData.iLanguageId = data.iLanguageId
    elseif GuildManager.AllianceSettingsType.Recruit == settingType then
      stBriefData.sRecruit = data.sRecruit
    elseif GuildManager.AllianceSettingsType.Bulletin == settingType then
      guildData.sBulletin = data.sBulletin
    end
  end
end

function GuildManager:OnPushAllianceMemberJoin(data)
  local stMemberData = data.stMemberData
  local id, lv = RoleManager:GetRoleAllianceInfo()
  if stMemberData.stRoleId.iUid == RoleManager:GetUID() then
    RoleManager:SetRoleAllianceInfo({
      iAllianceId = data.iAllianceId,
      iLevel = lv
    })
    self.m_AllianceInviteList = {}
    self.m_roleApplyIdList = {}
  else
    local guildData = self:GetOwnerGuildDetail()
    if guildData then
      table.insert(guildData.vMember, stMemberData)
    end
  end
  self:broadcastEvent("eGameEvent_Alliance_Join")
end

function GuildManager:OnPushAlliancePostChange(data)
  local guildData = self:GetOwnerGuildDetail()
  if guildData then
    for i, v in ipairs(guildData.vMember) do
      if v.stRoleId.iUid == data.stRoleId.iUid and v.stRoleId.iZoneId == data.stRoleId.iZoneId then
        v.iPost = data.iPost
        if v.stRoleId.iUid == RoleManager:GetUID() then
          self:broadcastEvent("eGameEvent_Alliance_ChangePost")
        end
        return
      end
    end
  end
end

function GuildManager:OnPushAllianceMemberLeave(data)
  if data.stRoleId.iUid == RoleManager:GetUID() then
    RoleManager:SetRoleAllianceInfo({})
    self.m_ownerGuildDetail = nil
    self.m_AllianceInviteList = {}
    self.m_roleApplyIdList = {}
    self:broadcastEvent("eGameEvent_Alliance_Leave")
    return
  end
  local guildData = self:GetOwnerGuildDetail()
  if guildData then
    for i, v in ipairs(guildData.vMember) do
      if v.stRoleId.iUid == data.stRoleId.iUid and v.stRoleId.iZoneId == data.stRoleId.iZoneId then
        table.remove(guildData.vMember, i)
        return
      end
    end
  end
end

function GuildManager:OnPushAllianceBeInvite(data)
  self:ReqAllianceGetInviteListCS()
end

function GuildManager:OnPushAllianceTransfer(data)
  local guildData = self:GetOwnerGuildDetail()
  if self.m_ownerGuildDetail then
    self.m_ownerGuildDetail.iTransferEffectTime = 0
  end
  if guildData then
    for i, v in ipairs(guildData.vMember) do
      if v.stRoleId.iUid == data.stOldMaster.iUid then
        v.iPost = data.iOldMasterPost or GuildManager.AlliancePost.Member
      end
      if v.stRoleId.iUid == data.stNewMaster.iUid then
        v.iPost = GuildManager.AlliancePost.Master
      end
    end
  end
end

function GuildManager:OnPushAllianceDestroy(data)
  self.m_ownerGuildDetail = nil
  RoleManager:SetRoleAllianceInfo({})
  self:broadcastEvent("eGameEvent_Alliance_Leave")
end

function GuildManager:OnPushDelRoleApply(data)
  if self.m_roleApplyIdList then
    for i = #self.m_roleApplyIdList, 1, -1 do
      if self.m_roleApplyIdList[i] == data.iAllianceId then
        table.remove(self.m_roleApplyIdList, i)
        break
      end
    end
  end
end

function GuildManager:OnPushAllianceBattleNewRound(data)
  self:broadcastEvent("eGameEvent_PushAllianceBattleNewRound", data.iActivityId)
end

function GuildManager:OnPushAllianceBattleBoss(data)
  self.m_battleResultData = data
end

function GuildManager:ReqAllianceGetInit()
  local reqMsg = MTTDProto.Cmd_Alliance_GetInit_CS()
  RPCS():Alliance_GetInit(reqMsg, handler(self, self.OnReqAlliance_GetInitSC))
end

function GuildManager:OnReqAlliance_GetInitSC(stData, msg)
  self.m_initGuildData = stData
  self.m_roleApplyIdList = stData.vAllianceApplyList
  self.m_likeMemberList = stData.vLikedOther
  self.m_iLikeTimes = stData.iLikeTimes
  self.m_iSignNum = stData.iSignNum
  self.m_iSignTime = stData.iSignTime
  self.m_dailyChallengeTimes = stData.iBattleTimes
  if stData.bHaveInvite then
    self:ReqAllianceGetInviteListCS()
  end
end

function GuildManager:ReqAllianceGetRoleApplyListCS()
  local reqMsg = MTTDProto.Cmd_Alliance_GetRoleApplyList_CS()
  RPCS():Alliance_GetRoleApplyList(reqMsg, handler(self, self.OnReqAllianceGetRoleApplyListSC))
end

function GuildManager:OnReqAllianceGetRoleApplyListSC(stData, msg)
  self.m_roleApplyIdList = stData.vAllianceId
end

function GuildManager:ReqAllianceGetRecommendList()
  local reqMsg = MTTDProto.Cmd_Alliance_GetRecommendList_CS()
  RPCS():Alliance_GetRecommendList(reqMsg, handler(self, self.OnReqAllianceGetRecommendListSC))
end

function GuildManager:OnReqAllianceGetRecommendListSC(stData, msg)
  self.m_recommendGuildList = stData.vAllianceBriefData
  self.m_recommendGuildTimer = TimeUtil:GetServerTimeS()
  self:broadcastEvent("eGameEvent_Alliance_GetRecommendList", stData.vAllianceBriefData)
end

function GuildManager:ReqRefreshRecommendList()
  local reqMsg = MTTDProto.Cmd_Alliance_GetRecommendList_CS()
  RPCS():Alliance_GetRecommendList(reqMsg, handler(self, self.OnReqRefreshRecommendListSC))
end

function GuildManager:ReqCancelTranGuild()
  local reqMsg = MTTDProto.Cmd_Alliance_CancelTransfer_CS()
  RPCS():Alliance_CancelTransfer(reqMsg, handler(self, self.OnReqCancelTransGuildSC))
end

function GuildManager:OnReqCancelTransGuildSC(stData)
  if self.m_ownerGuildDetail then
    self.m_ownerGuildDetail.iTransferEffectTime = stData.iTransferEffectTime
    self:broadcastEvent("eGameEvent_Alliance_CancelTransformGuild")
  end
end

function GuildManager:OnReqRefreshRecommendListSC(stData, msg)
  self.m_recommendGuildList = stData.vAllianceBriefData
  self.m_recommendGuildTimer = TimeUtil:GetServerTimeS()
  self:broadcastEvent("eGameEvent_Alliance_RefreshRecommendList", stData.vAllianceBriefData)
end

function GuildManager:ReqGetOwnerAllianceDetail(iAllianceId)
  local reqMsg = MTTDProto.Cmd_Alliance_GetDetail_CS()
  reqMsg.iAllianceId = iAllianceId
  RPCS():Alliance_GetDetail(reqMsg, handler(self, self.OnReqGetOwnerAllianceDetailSC))
end

function GuildManager:OnReqGetOwnerAllianceDetailSC(stData, msg)
  self.m_ownerGuildDetail = stData.stAllianceData
  RoleManager:SetRoleAllianceInfo(stData.stAllianceData.stBriefData)
  self:broadcastEvent("eGameEvent_Alliance_OwnerDetail", stData.stAllianceData)
end

function GuildManager:ReqGetOwnerAllianceDetailOnExitRaidMan(iAllianceId)
  local reqMsg = MTTDProto.Cmd_Alliance_GetDetail_CS()
  reqMsg.iAllianceId = iAllianceId
  RPCS():Alliance_GetDetail(reqMsg, handler(self, self.OnReqGetOwnerAllianceDetailSCOnExitRaidMan))
end

function GuildManager:OnReqGetOwnerAllianceDetailSCOnExitRaidMan(stData, msg)
  self.m_ownerGuildDetail = stData.stAllianceData
  RoleManager:SetRoleAllianceInfo(stData.stAllianceData.stBriefData)
end

function GuildManager:ReqGetOwnerAllianceDetailOnTransformGuide(iAllianceId)
  local reqMsg = MTTDProto.Cmd_Alliance_GetDetail_CS()
  reqMsg.iAllianceId = iAllianceId
  RPCS():Alliance_GetDetail(reqMsg, handler(self, self.OnReqGetOwnerAllianceDetailSCTransformGuild))
end

function GuildManager:OnReqGetOwnerAllianceDetailSCTransformGuild(stData, msg)
  self.m_ownerGuildDetail = stData.stAllianceData
  RoleManager:SetRoleAllianceInfo(stData.stAllianceData.stBriefData)
  self:broadcastEvent("eGameEvent_Alliance_RefreshTransformGuild")
end

function GuildManager:ReqDetailAlliance(iAllianceId)
  local reqMsg = MTTDProto.Cmd_Alliance_GetDetail_CS()
  reqMsg.iAllianceId = iAllianceId
  RPCS():Alliance_GetDetail(reqMsg, handler(self, self.OnReqDetailAllianceSC))
end

function GuildManager:OnReqDetailAllianceSC(stData, msg)
  self:broadcastEvent("eGameEvent_Alliance_Detail", stData.stAllianceData)
end

function GuildManager:ReqCreateAlliance(name, banner, joinType, iJoinLevel)
  local reqMsg = MTTDProto.Cmd_Alliance_Create_CS()
  reqMsg.sAllianceName = name
  reqMsg.iBadgeId = banner
  reqMsg.iJoinType = joinType
  reqMsg.iJoinLevel = iJoinLevel
  RPCS():Alliance_Create(reqMsg, handler(self, self.OnReqCreateAllianceSC))
end

function GuildManager:OnReqCreateAllianceSC(stData, msg)
  RoleManager:SetRoleAllianceInfo(stData.stAllianceData.stBriefData)
  self.m_ownerGuildDetail = stData.stAllianceData
  self:broadcastEvent("eGameEvent_Alliance_Create_Detail", stData.stAllianceData)
end

function GuildManager:ReqLeaveAlliance()
  local reqMsg = MTTDProto.Cmd_Alliance_Leave_CS()
  RPCS():Alliance_Leave(reqMsg, handler(self, self.OnReqLeaveAllianceSC))
end

function GuildManager:OnReqLeaveAllianceSC(stData, msg)
  RoleManager:SetRoleAllianceInfo({})
  self.m_ownerGuildDetail = nil
  self:broadcastEvent("eGameEvent_Alliance_Leave")
end

function GuildManager:OnReqAllianceApplyCS(iAllianceId)
  local reqMsg = MTTDProto.Cmd_Alliance_Apply_CS()
  reqMsg.iAllianceId = iAllianceId
  RPCS():Alliance_Apply(reqMsg, handler(self, self.OnReqAllianceApplySC), handler(self, self.OnReqAllianceApplyFailedSC))
end

function GuildManager:OnReqAllianceApplySC(stData, msg)
  if stData.iJoinType == GuildManager.AllianceJoinType.AllianceJoinType_Review then
    self.m_roleApplyIdList[#self.m_roleApplyIdList + 1] = stData.iAllianceId
  end
  self:broadcastEvent("eGameEvent_Alliance_Apply", stData)
end

function GuildManager:OnReqAllianceApplyFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  if iErrorCode == MTTD.Error_Alliance_Null or iErrorCode == MTTD.Error_Alliance_MaxMember or iErrorCode == MTTD.Error_Alliance_NotAllowApply or iErrorCode == MTTD.Error_Alliance_MaxApplyer or iErrorCode == MTTD.Error_Alliance_JoinLevelLow then
    self:broadcastEvent("eGameEvent_Alliance_RemoveGuildData")
    NetworkManager:OnRpcCallbackFail(msg)
  else
    NetworkManager:OnRpcCallbackFail(msg)
  end
end

function GuildManager:OnReqAllianceHistoryCS()
  local reqMsg = MTTDProto.Cmd_Alliance_AllianceHistory_CS()
  RPCS():Alliance_AllianceHistory(reqMsg, handler(self, self.OnReqAllianceHistorySC))
end

function GuildManager:OnReqAllianceHistorySC(stData)
  local historyList = {}
  local timeMap = {}
  table.sort(stData.vHistory, function(a, b)
    return a.iTime > b.iTime
  end)
  for i, v in ipairs(stData.vHistory) do
    local id = GuildManager.AllianceHistoryTypeStr[v.iType]
    if id then
      local time = TimeUtil:TimerToString2(v.iTime)
      if not timeMap[time] then
        timeMap[time] = true
        v.showTime = true
      end
      historyList[#historyList + 1] = v
    end
  end
  self.m_bLikeHistory = {}
  local uid = RoleManager:GetUID()
  for i, v in ipairs(stData.vHistory) do
    if v.iType == GuildManager.AllianceHistoryType.Like then
      local iCurZeroTime = TimeUtil:GetServerToDayCommonResetTime()
      if v.stMember.iUid == uid and iCurZeroTime < v.iTime then
        self.m_bLikeHistory[#self.m_bLikeHistory + 1] = v
      end
    end
  end
  self.m_ownerGuildHistory = historyList
  self:broadcastEvent("eGameEvent_Alliance_History")
end

function GuildManager:OnReqAllianceLikedHistoryCS()
  local reqMsg = MTTDProto.Cmd_Alliance_AllianceHistory_CS()
  RPCS():Alliance_AllianceHistory(reqMsg, handler(self, self.OnReqAllianceLikedHistorySC))
end

function GuildManager:OnReqAllianceLikedHistorySC(stData)
  table.sort(stData.vHistory, function(a, b)
    return a.iTime > b.iTime
  end)
  self.m_bLikeHistory = {}
  local uid = RoleManager:GetUID()
  for i, v in ipairs(stData.vHistory) do
    if v.iType == GuildManager.AllianceHistoryType.Like then
      local iCurZeroTime = TimeUtil:GetServerToDayCommonResetTime()
      if v.stMember.iUid == uid and iCurZeroTime < v.iTime then
        self.m_bLikeHistory[#self.m_bLikeHistory + 1] = v
      end
    end
  end
  self:broadcastEvent("eGameEvent_Alliance_Like_History")
end

function GuildManager:ReqChangeBulletin(sBulletin)
  local reqMsg = MTTDProto.Cmd_Alliance_ChangeBulletin_CS()
  reqMsg.sBulletin = sBulletin
  RPCS():Alliance_ChangeBulletin(reqMsg, handler(self, self.OnReqChangeBulletinSC))
end

function GuildManager:OnReqChangeBulletinSC(stData, msg)
  self:broadcastEvent("eGameEvent_Alliance_ChangeBulletin")
end

function GuildManager:ReqChangeRecruit(sRecruit)
  local reqMsg = MTTDProto.Cmd_Alliance_ChangeRecruit_CS()
  reqMsg.sRecruit = sRecruit
  RPCS():Alliance_ChangeRecruit(reqMsg, handler(self, self.OnReqChangeRecruitSC))
end

function GuildManager:OnReqChangeRecruitSC(stData, msg)
  self:broadcastEvent("eGameEvent_Alliance_ChangeRecruit")
end

function GuildManager:ReqAllianceDestroy()
  local reqMsg = MTTDProto.Cmd_Alliance_Destroy_CS()
  RPCS():Alliance_Destroy(reqMsg, handler(self, self.OnReqAllianceDestroySC))
end

function GuildManager:OnReqAllianceDestroySC(stData, msg)
  self.m_ownerGuildDetail = nil
  RoleManager:SetRoleAllianceInfo({})
  self:broadcastEvent("eGameEvent_Alliance_Destroy")
end

function GuildManager:ReqAllianceChangeName(nameStr)
  local reqMsg = MTTDProto.Cmd_Alliance_ChangeName_CS()
  reqMsg.sName = nameStr
  RPCS():Alliance_ChangeName(reqMsg, handler(self, self.OnReqAllianceChangeNameSC))
end

function GuildManager:OnReqAllianceChangeNameSC(stData, msg)
  self:broadcastEvent("eGameEvent_Alliance_ChangeName")
end

function GuildManager:ReqAllianceChangeSetting(data)
  local reqMsg = MTTDProto.Cmd_Alliance_ChangeSetting_CS()
  reqMsg.vChangeSettingsType = data.vChangeSettingsType
  reqMsg.iBadgeId = data.iBadgeId
  reqMsg.iLanguageId = data.iLanguageId
  reqMsg.iJoinType = data.iJoinType
  reqMsg.iJoinLevel = data.iJoinLevel
  RPCS():Alliance_ChangeSetting(reqMsg, handler(self, self.OnReqAllianceChangeSettingSC))
end

function GuildManager:OnReqAllianceChangeSettingSC(stData, msg)
  self:broadcastEvent("eGameEvent_Alliance_ChangeSetting")
end

function GuildManager:ReqAllianceSearchCS(guildId)
  local reqMsg = MTTDProto.Cmd_Alliance_Search_CS()
  reqMsg.sInput = guildId
  RPCS():Alliance_Search(reqMsg, handler(self, self.OnReqAllianceSearchSC))
end

function GuildManager:OnReqAllianceSearchSC(stData)
  self:broadcastEvent("eGameEvent_Alliance_RefreshRecommendList", stData.vAllianceBriefData)
end

function GuildManager:ReqAllianceChangePostCS(iUid, iPost, iZoneId)
  local reqMsg = MTTDProto.Cmd_Alliance_ChangePost_CS()
  reqMsg.iUid = iUid
  reqMsg.iPost = iPost
  reqMsg.iZoneId = iZoneId
  RPCS():Alliance_ChangePost(reqMsg, handler(self, self.OnReqAllianceChangePostSC))
end

function GuildManager:OnReqAllianceChangePostSC()
  self:broadcastEvent("eGameEvent_Alliance_ChangePost")
end

function GuildManager:ReqAllianceTransferCS(iUid, iZoneId)
  local reqMsg = MTTDProto.Cmd_Alliance_Transfer_CS()
  reqMsg.iUid = iUid
  reqMsg.iZoneId = iZoneId
  RPCS():Alliance_Transfer(reqMsg, handler(self, self.OnReqAllianceTransferSC))
end

function GuildManager:OnReqAllianceTransferSC(stData)
  if self.m_ownerGuildDetail then
    self.m_ownerGuildDetail.iTransferEffectTime = stData.iTransferEffectTime
    self.m_ownerGuildDetail.stNewTransferMaster = stData.stNewTransferMaster
    self:broadcastEvent("eGameEvent_Alliance_StartTransformGuild")
  end
end

function GuildManager:ReqAllianceKickCS(iBeKickUid, iBeKickZoneId)
  local reqMsg = MTTDProto.Cmd_Alliance_Kick_CS()
  reqMsg.iBeKickUid = iBeKickUid
  reqMsg.iBeKickZoneId = iBeKickZoneId
  RPCS():Alliance_Kick(reqMsg, handler(self, self.OnReqAllianceKickSC))
end

function GuildManager:OnReqAllianceKickSC()
  self:broadcastEvent("eGameEvent_Alliance_Kick")
end

function GuildManager:ReqAllianceGetApplyListCS()
  local reqMsg = MTTDProto.Cmd_Alliance_GetApplyList_CS()
  RPCS():Alliance_GetApplyList(reqMsg, handler(self, self.OnReqAllianceGetApplyListSC))
end

function GuildManager:OnReqAllianceGetApplyListSC(data)
  self.m_vApplyList = data.vApplyList
  self:broadcastEvent("eGameEvent_Alliance_GetApplyList", data)
end

function GuildManager:ReqOpenAllianceGetApplyListCS()
  local reqMsg = MTTDProto.Cmd_Alliance_GetApplyList_CS()
  RPCS():Alliance_GetApplyList(reqMsg, handler(self, self.OnReqOpenAllianceGetApplyListSC))
end

function GuildManager:OnReqOpenAllianceGetApplyListSC(data)
  self.m_vApplyList = data.vApplyList
  self:broadcastEvent("eGameEvent_Alliance_GetApplyList_RedPoint", data)
end

function GuildManager:ReqAllianceOperateApplyCS(iOperUid, bAccept, iOperZoneId)
  local reqMsg = MTTDProto.Cmd_Alliance_OperateApply_CS()
  reqMsg.iOperUid = iOperUid
  reqMsg.bAccept = bAccept
  reqMsg.iOperZoneId = iOperZoneId
  RPCS():Alliance_OperateApply(reqMsg, handler(self, self.OnReqAllianceOperateApplySC), handler(self, self.OnReqAllianceOperateApplyFailedSC))
end

function GuildManager:OnReqAllianceOperateApplySC(data)
  self:broadcastEvent("eGameEvent_Alliance_OperateApply", data)
end

function GuildManager:OnReqAllianceOperateApplyFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  if iErrorCode == MTTD.Error_Alliance_NotInApplyList or iErrorCode == MTTD.Error_Alliance_HasJoin then
    local reqMsg = MTTDProto.Cmd_Alliance_GetApplyList_CS()
    RPCS():Alliance_GetApplyList(reqMsg, handler(self, self.OnReReqAllianceGetApplyListSC))
    NetworkManager:OnRpcCallbackFail(msg)
  else
    NetworkManager:OnRpcCallbackFail(msg)
  end
end

function GuildManager:OnReReqAllianceGetApplyListSC(data)
  self:broadcastEvent("eGameEvent_Alliance_ReGetApplyList", data)
end

function GuildManager:ReqAllianceRefuseAllCS()
  local reqMsg = MTTDProto.Cmd_Alliance_RefuseAll_CS()
  RPCS():Alliance_RefuseAll(reqMsg, handler(self, self.OnReqAllianceRefuseAllSC))
end

function GuildManager:OnReqAllianceRefuseAllSC(data)
  self:broadcastEvent("eGameEvent_Alliance_RefuseAll", data)
end

function GuildManager:ReqAllianceInviteCS(playerIDType)
  local reqMsg = MTTDProto.Cmd_Alliance_Invite_CS()
  reqMsg.stRoleId = playerIDType
  RPCS():Alliance_Invite(reqMsg, handler(self, self.OnReqAllianceInviteSC))
end

function GuildManager:OnReqAllianceInviteSC(data)
  self:broadcastEvent("eGameEvent_Alliance_Invite", data)
end

function GuildManager:ReqAllianceGetInviteListCS()
  local reqMsg = MTTDProto.Cmd_Alliance_GetInviteList_CS()
  RPCS():Alliance_GetInviteList(reqMsg, handler(self, self.OnReqAllianceGetInviteListSC))
end

function GuildManager:OnReqAllianceGetInviteListSC(data)
  self.m_AllianceInviteList = data.vList
end

function GuildManager:ReqAllianceReplyInviteCS(iAllianceId, bAccept)
  local reqMsg = MTTDProto.Cmd_Alliance_ReplyInvite_CS()
  reqMsg.iAllianceId = iAllianceId
  reqMsg.bAccept = bAccept
  RPCS():Alliance_ReplyInvite(reqMsg, handler(self, self.OnReqAllianceReplyInviteSC), handler(self, self.OnReqAllianceReplyInviteFailedSC))
end

function GuildManager:OnReqAllianceReplyInviteSC(data)
  if data.bAccept then
    RoleManager:SetRoleAllianceInfo({
      iAllianceId = data.iAllianceId
    })
  end
  self:broadcastEvent("eGameEvent_Alliance_ReplyInvite", data)
end

function GuildManager:OnReqAllianceReplyInviteFailedSC(msg)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  self:broadcastEvent("eGameEvent_Alliance_Refresh_Invitations")
  NetworkManager:OnRpcCallbackFail(msg)
end

function GuildManager:ReqSearchRoleCS(iRoleId)
  local reqMsg = MTTDProto.Cmd_Friend_SearchRole_CS()
  reqMsg.iRoleId = iRoleId
  RPCS():Friend_SearchRole(reqMsg, handler(self, self.OnReqSearchRoleSC))
end

function GuildManager:OnReqSearchRoleSC(data)
  local vRole = data.vRole
  if vRole and 0 < #vRole then
    local function sortFun(data1, data2)
      return data1.iLoginTime > data2.iLoginTime
    end
    
    table.sort(vRole, sortFun)
    if vRole[1] then
      self:ReqAllianceInviteCS(vRole[1].stRoleId)
    end
  end
end

function GuildManager:ReqAllianceLikeCS(playerIDType)
  local reqMsg = MTTDProto.Cmd_Alliance_Like_CS()
  reqMsg.stOther = playerIDType
  RPCS():Alliance_Like(reqMsg, handler(self, self.OnReqAllianceLikeSC))
end

function GuildManager:OnReqAllianceLikeSC(data)
  self:SetAllianceDailyLiked(data.stOther, data.iLikeTimes)
  self:broadcastEvent("eGameEvent_Alliance_Like", data.vReward)
end

function GuildManager:ReqAllianceSignCS()
  local reqMsg = MTTDProto.Cmd_Alliance_Sign_CS()
  RPCS():Alliance_Sign(reqMsg, handler(self, self.OnReqAllianceSignSC))
end

function GuildManager:OnReqAllianceSignSC(data)
  self.m_iSignNum = data.iSignNum
  self.m_iSignTime = data.iSignTime
  self:broadcastEvent("eGameEvent_Alliance_Sign", data.vReward)
end

function GuildManager:ReqAllianceGetBattleBossData()
  local activity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_AllianceBattle)
  if activity then
    local reqMsg = MTTDProto.Cmd_Alliance_Battle_GetBattleData_CS()
    reqMsg.iActivityId = activity:getID()
    RPCS():Alliance_Battle_GetBattleData(reqMsg, handler(self, self.OnReqAllianceGetBattleBossDataSC))
  end
end

function GuildManager:OnReqAllianceGetBattleBossDataSC(stData, msg)
  self.m_guildBossData = stData.stBattle
  self.m_dailyChallengeTimes = stData.iChallengeTimes
  self.m_usedFightHero = stData.vFightHero
  self.m_myBossRank = stData.iMyRank
  self:broadcastEvent("eGameEvent_Alliance_GetBossData")
end

function GuildManager:ReqPushAllianceBattleNewRoundData(activityId)
  if activityId then
    local reqMsg = MTTDProto.Cmd_Alliance_Battle_GetBattleData_CS()
    reqMsg.iActivityId = activityId
    RPCS():Alliance_Battle_GetBattleData(reqMsg, handler(self, self.OnReqPushAllianceBattleNewRoundDataSC))
  end
end

function GuildManager:OnReqPushAllianceBattleNewRoundDataSC(stData, msg)
  self.m_guildBossData = stData.stBattle
  self.m_dailyChallengeTimes = stData.iChallengeTimes
  self.m_usedFightHero = stData.vFightHero
  self.m_myBossRank = stData.iMyRank
  self:broadcastEvent("eGameEvent_GetAllianceBattleNewRound")
end

function GuildManager:ReqAllianceUpdateBattleBossData()
  local activity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_AllianceBattle)
  if activity then
    local reqMsg = MTTDProto.Cmd_Alliance_Battle_GetBattleData_CS()
    reqMsg.iActivityId = activity:getID()
    RPCS():Alliance_Battle_GetBattleData(reqMsg, handler(self, self.OnReqAllianceUpdateBattleBossDataSC))
  end
end

function GuildManager:OnReqAllianceUpdateBattleBossDataSC(stData, msg)
  self.m_guildBossData = stData.stBattle
  self.m_dailyChallengeTimes = stData.iChallengeTimes
  self.m_usedFightHero = stData.vFightHero
  self.m_myBossRank = stData.iMyRank
  self:broadcastEvent("eGameEvent_Alliance_UpdateBattleBoss")
end

function GuildManager:GetAllianceBattleBossHistory(iActivityId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = self:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossBeginTime then
    local actBeginTime = activity:GetGuildBossBeginTime()
    local actBattleEndTime = activity:GetGuildBossBattleEndTime()
    local restTime = TimeUtil:GetSpecifiedDateResetTime(actBeginTime)
    local serverTime = TimeUtil:GetServerTimeS()
    
    local function callFun(startTime, endTime)
      self:ReqAllianceGetBattleBossHistory(iActivityId, startTime, endTime)
    end
    
    local day = TimeUtil:GetAFewDayDifference(actBeginTime, actBattleEndTime)
    for i = 1, day do
      local beginTime = i == 1 and actBeginTime or restTime + 86400 * (i - 1)
      local endTime = i == day and actBattleEndTime or restTime + 86400 * i
      if table.getn(self.m_guildBossHistory[beginTime]) == 0 and serverTime > endTime then
        callFun(beginTime, endTime)
      elseif serverTime >= beginTime and serverTime <= endTime then
        callFun(beginTime, endTime)
        return
      elseif table.getn(self.m_guildBossHistory[beginTime]) == 0 and actBattleEndTime < serverTime then
        callFun(beginTime, endTime)
      end
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10408)
  end
end

function GuildManager:ReqAllianceGetBattleBossHistory(iActivityId, iBeginTime, iEndTime)
  local reqMsg = MTTDProto.Cmd_Alliance_Battle_GetBattleHistory_CS()
  reqMsg.iActivityId = iActivityId
  reqMsg.iBeginTime = iBeginTime
  reqMsg.iEndTime = iEndTime
  RPCS():Alliance_Battle_GetBattleHistory(reqMsg, handler(self, self.OnReqAllianceGetBattleHistorySC))
end

function GuildManager:OnReqAllianceGetBattleHistorySC(stData, msg)
  local iBeginTime = stData.iBeginTime
  local iEndTime = stData.iEndTime
  self.m_guildBossHistory[iBeginTime] = stData.vHistory
  local isOver = TimeUtil:IsInTime(iBeginTime, iEndTime)
  local actBattleEndTime = self:GetActivityBattleEndTime()
  if iEndTime == actBattleEndTime then
    isOver = true
  end
  self:broadcastEvent("eGameEvent_GetGuildBossPersonalHistory", isOver)
end

function GuildManager:ReqAllianceGetBattleBossRankList(iActivityId, iBeginRank, iEndRank)
  local reqMsg = MTTDProto.Cmd_Alliance_Battle_GetRankList_CS()
  reqMsg.iActivityId = iActivityId
  reqMsg.iBeginRank = iBeginRank
  reqMsg.iEndRank = iEndRank
  RPCS():Alliance_Battle_GetRankList(reqMsg, handler(self, self.OnReqAllianceGetBattleBossRankListSC))
end

function GuildManager:OnReqAllianceGetBattleBossRankListSC(stData, msg)
  self.m_guildBossRankList = stData.vRankList
  self.m_myBossRank = stData.iMyRank
  self.m_myBossScore = stData.iMyScore
  self.m_myBossRankSize = stData.iRankSize
  self:broadcastEvent("eGameEvent_UpDataGuildBossRankList", stData.vRankList)
end

function GuildManager:GetActivityBattleEndTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = self:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossBattleEndTime then
    local actEndTime = activity:GetGuildBossBattleEndTime()
    return actEndTime
  end
  return 0
end

function GuildManager:GetActivityEndTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = self:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossEndTime then
    local actEndTime = activity:GetGuildBossEndTime()
    return actEndTime
  end
  return 0
end

function GuildManager:IsGuildBossTime()
  local time = self:GetActivityEndTime()
  local serverTime = TimeUtil:GetServerTimeS()
  local inTime = time - serverTime
  if time == 0 then
    return false
  end
  if inTime <= 0 then
    return false
  end
  return true
end

function GuildManager:IsGuildBossBattleTime()
  local time = self:GetActivityBattleEndTime()
  local serverTime = TimeUtil:GetServerTimeS()
  local inTime = time - serverTime
  if time == 0 then
    return false
  end
  if inTime <= 0 then
    return false
  end
  return true
end

function GuildManager:IsGuildBossSettlementTime()
  local time = self:GetActivityBattleEndTime()
  if time == 0 then
    return false
  end
  local endTime = self:GetActivityEndTime()
  local serverTime = TimeUtil:GetServerTimeS()
  local inBattleTime = time - serverTime
  local inEndTime = endTime - serverTime
  if inBattleTime <= 0 and 0 < inEndTime then
    return true
  end
  return false
end

function GuildManager:GetAllianceDailyLikedInfo()
  return self.m_likeMemberList, self.m_iLikeTimes
end

function GuildManager:SetAllianceDailyLiked(playerIDType, num)
  if self.m_likeMemberList and #self.m_likeMemberList > 0 then
    table.insert(self.m_likeMemberList, playerIDType)
  else
    self.m_likeMemberList = {playerIDType}
  end
  self.m_iLikeTimes = num
end

function GuildManager:CheckIsLikedByMemberId(iUid, iZoneId)
  if self.m_likeMemberList then
    for i, v in ipairs(self.m_likeMemberList) do
      if v.iUid == iUid and v.iZoneId == iZoneId then
        return true
      end
    end
  end
  return false
end

function GuildManager:GetGuildLevelConfigByLv(guildLv)
  if not guildLv then
    log.error("GuildManager GetGuildLevelConfigByLv guildLv = nil")
    return
  end
  local configInstance = ConfigManager:GetConfigInsByName("GuildLevel")
  return configInstance:GetValue_ByLevel(guildLv)
end

function GuildManager:GetOwnerGuildDetail()
  return self.m_ownerGuildDetail
end

function GuildManager:GetOwnerGuildMemberDataByUID(uid)
  local guildData = self:GetOwnerGuildDetail()
  if guildData then
    for i, v in ipairs(guildData.vMember) do
      if v.stRoleId.iUid == uid then
        return v
      end
    end
  end
end

function GuildManager:GetRecommendGuildTimer()
  return self.m_recommendGuildTimer or 0
end

function GuildManager:GetRecommendGuildList()
  return self.m_recommendGuildList
end

function GuildManager:GetInitGuildData()
  return self.m_initGuildData
end

function GuildManager:IsInApplyList(guildId)
  if self.m_roleApplyIdList then
    for i, v in pairs(self.m_roleApplyIdList) do
      if guildId == v then
        return true
      end
    end
  end
  return false
end

function GuildManager:SortMemberData(memberList, filterType, bFilterDown)
  if GuildManager.AllianceMemberSortType.Login == filterType then
    memberList = self:SortMemberByLogin(memberList, bFilterDown)
  elseif GuildManager.AllianceMemberSortType.Activity == filterType then
    memberList = self:SortMemberByActivity(memberList, bFilterDown)
  elseif GuildManager.AllianceMemberSortType.Level == filterType then
    memberList = self:SortMemberByLevel(memberList, bFilterDown)
  elseif GuildManager.AllianceMemberSortType.Combat == filterType then
    memberList = self:SortMemberByPower(memberList, bFilterDown)
  end
  return memberList
end

function GuildManager:SortMemberByLogin(memberList, bFilterDown)
  local function sortFun(data1, data2)
    local member1 = data1
    
    local member2 = data2
    local online1 = member1.bOnline and 1 or 0
    local online2 = member2.bOnline and 1 or 0
    if bFilterDown then
      if online1 == online2 then
        return member1.iLastLogoutTime < member2.iLastLogoutTime
      else
        return online1 < online2
      end
    elseif online1 == online2 then
      return member1.iLastLogoutTime > member2.iLastLogoutTime
    else
      return online1 > online2
    end
  end
  
  table.sort(memberList, sortFun)
  return memberList
end

function GuildManager:SortMemberByActivity(memberList, bFilterDown)
  local function sortFun(data1, data2)
    local member1 = data1
    
    local member2 = data2
    local iActive1 = member1.iTodayActive or 0
    local iActive2 = member2.iTodayActive or 0
    if iActive1 == iActive2 then
      return member1.iLevel > member2.iLevel
    elseif bFilterDown then
      return iActive1 < iActive2
    else
      return iActive1 > iActive2
    end
  end
  
  table.sort(memberList, sortFun)
  return memberList
end

function GuildManager:SortMemberByLevel(memberList, bFilterDown)
  local function sortFun(data1, data2)
    local member1 = data1
    
    local member2 = data2
    local iLevel1 = member1.iLevel
    local iLevel2 = member2.iLevel
    if iLevel1 == iLevel2 then
      return member1.iPost > member2.iPost
    elseif bFilterDown then
      return iLevel1 < iLevel2
    else
      return iLevel1 > iLevel2
    end
  end
  
  table.sort(memberList, sortFun)
  return memberList
end

function GuildManager:SortMemberByPower(memberList, bFilterDown)
  local function sortFun(data1, data2)
    local member1 = data1
    
    local member2 = data2
    local iPower1 = member1.iPower
    local iPower2 = member2.iPower
    if iPower1 == iPower2 then
      return member1.iPost > member2.iPost
    elseif bFilterDown then
      return iPower1 < iPower2
    else
      return iPower1 > iPower2
    end
  end
  
  table.sort(memberList, sortFun)
  return memberList
end

function GuildManager:GetGuildHistory()
  return self.m_ownerGuildHistory
end

function GuildManager:GetRoleApplyIdList()
  return self.m_roleApplyIdList
end

function GuildManager:GetAllianceInviteList()
  return self.m_AllianceInviteList
end

function GuildManager:GetLastAllianceInvite()
  local inviteData
  local inviteList = self:GetAllianceInviteList()
  if inviteList and 0 < #inviteList then
    local function sortFun(data1, data2)
      return data1.stInviteUser.iInviteTime < data2.stInviteUser.iInviteTime
    end
    
    table.sort(inviteList, sortFun)
    inviteData = inviteList[#inviteList]
    inviteList[#inviteList] = nil
    return inviteData
  end
end

function GuildManager:GetOpenedGuildEventList()
  local cfgList = {}
  local GuildEventIns = ConfigManager:GetConfigInsByName("GuildEvent")
  local cfgAll = GuildEventIns:GetAll()
  for i, v in pairs(cfgAll) do
    cfgList[#cfgList + 1] = v
  end
  return cfgList
end

function GuildManager:GetBLikeHistoryList()
  return self.m_bLikeHistory
end

function GuildManager:GetGuildSignNum()
  return self.m_iSignNum, self.m_iSignTime
end

function GuildManager:GetGuildApplyList()
  return self.m_vApplyList
end

function GuildManager:CheckGuildIsCanSign()
  local flag = 0
  local _, time = self:GetGuildSignNum()
  local id = RoleManager:GetRoleAllianceInfo()
  if id and id ~= 0 and id ~= "0" and time then
    flag = TimeUtil:CheckTimeIsToDay(time) and 0 or 1
  end
  return flag
end

function GuildManager:CheckGuildEntryHaveRedPoint()
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Guild)
  if isOpen ~= true then
    return 0
  end
  local flag = self:CheckGuildIsCanSign()
  if 0 < flag then
    return flag
  end
  flag = self:GuildBossIsHaveRedDot()
  if 0 < flag then
    return flag
  end
  flag = AncientManager:CheckAncientEnterRedDot()
  return flag
end

function GuildManager:GetGuildBossData()
  return self.m_guildBossData
end

function GuildManager:GetMyBossRank()
  return self.m_myBossRank
end

function GuildManager:GetGuildBossChallengeTimes()
  return self.m_dailyChallengeTimes
end

function GuildManager:GetGuildBossUsedFightHero()
  return self.m_usedFightHero
end

function GuildManager:GetGuildBossMyRank()
  return self.m_myBossRank, self.m_myBossScore, self.m_myBossRankSize
end

function GuildManager:GetGuildBossRankList()
  return self.m_guildBossRankList
end

function GuildManager:GetGuildBossBattleCfgCount()
  return self.m_guildBattleTimesCfgNum
end

function GuildManager:GetGuildBossBattleMaxNum()
  local guildData = self:GetOwnerGuildDetail()
  if not guildData then
    return 0
  end
  local stBriefData = guildData.stBriefData
  return self.m_guildBattleTimesCfgNum * stBriefData.iCurrMemberCount
end

function GuildManager:GetGuildMemberCount()
  local guildData = self:GetOwnerGuildDetail()
  if not guildData then
    return 0
  end
  local stBriefData = guildData.stBriefData
  return stBriefData.iCurrMemberCount
end

function GuildManager:GuildBossIsHaveRedDot()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = self:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossBattleEndTime then
    local endTime = activity:GetGuildBossBattleEndTime()
    if endTime - TimeUtil:GetServerTimeS() > 0 then
      return self.m_guildBattleTimesCfgNum - self.m_dailyChallengeTimes
    end
  end
  return 0
end

function GuildManager:CheckGuildBossIsOpen()
  local openBoss = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_AllianceBattle) ~= nil
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuildBattle)
  local id = RoleManager:GetRoleAllianceInfo()
  if id and id ~= 0 and id ~= "0" and isOpen and openBoss then
    return true
  end
  return false
end

function GuildManager:GetGuildBossIds()
  local guildBoss = self:GetGuildBossData()
  if guildBoss and guildBoss.iBattleId then
    local cfg = self:GetGuildBattleCfgByID(guildBoss.iBattleId)
    if cfg then
      return utils.changeCSArrayToLuaTable(cfg.m_BossID)
    end
  end
end

function GuildManager:GetPersonalHistory()
  local personalHistoryList = {}
  local personalHistoryTab = {}
  if table.getn(self.m_guildBossHistory) > 0 then
    for beginTime, v in pairs(self.m_guildBossHistory) do
      for m, n in pairs(v) do
        if not personalHistoryTab[n.stRoleId.iUid] then
          personalHistoryTab[n.stRoleId.iUid] = {}
        end
        table.insert(personalHistoryTab[n.stRoleId.iUid], n)
      end
    end
  end
  for i, v in pairs(personalHistoryTab) do
    local personalInfo = {}
    for m, n in pairs(v) do
      if not personalInfo.stRoleId then
        personalInfo.stRoleId = n.stRoleId
        personalInfo.sName = n.sName
        personalInfo.battleCount = table.getn(v)
        personalInfo.iRealDamage = 0
      end
      personalInfo.iRealDamage = tonumber(n.iRealDamage) + tonumber(personalInfo.iRealDamage)
      local memberData = self:GetOwnerGuildMemberDataByUID(personalInfo.stRoleId.iUid)
      if memberData then
        personalInfo.iPower = memberData.iPower
      end
    end
    personalHistoryList[#personalHistoryList + 1] = personalInfo
  end
  return personalHistoryList, personalHistoryTab
end

function GuildManager:GetGuildBossDifficultyByRound(round)
  if round then
    local GuildBattleDifficultyIns = ConfigManager:GetConfigInsByName("GuildBattleDifficulty")
    local cfgAll = GuildBattleDifficultyIns:GetAll()
    for i, v in pairs(cfgAll) do
      local rounds = utils.changeCSArrayToLuaTable(v.m_Rounds)
      if round >= rounds[1] and (round <= rounds[2] or rounds[2] == 0) then
        return i
      end
    end
  end
end

function GuildManager:GetGuildBossDifficulty()
  local guildBoss = self:GetGuildBossData()
  if guildBoss and guildBoss.iCurRound then
    local GuildBattleDifficultyIns = ConfigManager:GetConfigInsByName("GuildBattleDifficulty")
    local cfgAll = GuildBattleDifficultyIns:GetAll()
    for i, v in pairs(cfgAll) do
      local round = utils.changeCSArrayToLuaTable(v.m_Rounds)
      if round[1] <= guildBoss.iCurRound and (round[2] >= guildBoss.iCurRound or round[2] == 0) then
        return i
      end
    end
  end
end

function GuildManager:GetGuildBossLevelInfoByBossId(bossId, round)
  local difficulty = 0
  if round then
    difficulty = self:GetGuildBossDifficultyByRound(round)
  else
    difficulty = self:GetGuildBossDifficulty()
  end
  if difficulty then
    local GuildBattleLevelIns = ConfigManager:GetConfigInsByName("GuildBattleLevel")
    local cfgAll = GuildBattleLevelIns:GetAll()
    for i, v in pairs(cfgAll) do
      if v.m_BossID == bossId and v.m_Difficulty == difficulty then
        return v, v.m_LevelID
      end
    end
  end
end

function GuildManager:GetBossServerDataByID(bossId)
  local guildBoss = self:GetGuildBossData()
  if guildBoss and guildBoss.mBoss then
    local bossList = guildBoss.mBoss
    for id, v in pairs(bossList) do
      if id == bossId then
        return v
      end
    end
  end
end

function GuildManager:GetGuildBattleCfgByID(battleId)
  local GuildBattleIns = ConfigManager:GetConfigInsByName("GuildBattle")
  local cfg = GuildBattleIns:GetValue_ByID(battleId)
  if cfg:GetError() then
    log.error(" GetGuildBattleCfgByID can not find id " .. tostring(battleId))
    return
  end
  return cfg
end

function GuildManager:GetGuildBattleBossCfgByID(bossId)
  local GuildBattleBossIns = ConfigManager:GetConfigInsByName("GuildBattleBoss")
  local cfg = GuildBattleBossIns:GetValue_ByID(bossId)
  if cfg:GetError() then
    log.error(" GetGuildBattleCfgByID can not find id " .. tostring(bossId))
    return
  end
  return cfg
end

function GuildManager:GetGuildBattleDifficultyCfgByID(difficulty)
  local GuildBattleDifficultyIns = ConfigManager:GetConfigInsByName("GuildBattleDifficulty")
  local cfg = GuildBattleDifficultyIns:GetValue_ByDifficulty(difficulty)
  if cfg:GetError() then
    log.error(" GetGuildBattleDifficultyCfgByID can not find id " .. tostring(difficulty))
    return
  end
  return cfg
end

function GuildManager:GetGuildBattleGradeCfgByID(gradeID)
  local GuildBattleGradeIns = ConfigManager:GetConfigInsByName("GuildBattleGrade")
  local cfg = GuildBattleGradeIns:GetValue_ByGradeID(gradeID)
  if cfg:GetError() then
    log.error(" GetGuildBattleGradeCfgByID can not find id " .. tostring(gradeID))
    return
  end
  return cfg
end

function GuildManager:GetGuildBattleLevelCfgByID(levelID)
  local GuildBattleLevelIns = ConfigManager:GetConfigInsByName("GuildBattleLevel")
  local cfg = GuildBattleLevelIns:GetValue_ByLevelID(levelID)
  if cfg:GetError() then
    log.error(" GetGuildBattleLevelCfgByID can not find id " .. tostring(levelID))
    return
  end
  return cfg
end

function GuildManager:GetGuildBattleRewardCfgByID(id)
  local GuildBattleRewardIns = ConfigManager:GetConfigInsByName("GuildBattleReward")
  local cfg = GuildBattleRewardIns:GetValue_ByID(id)
  if cfg:GetError() then
    log.error(" GetGuildBattleRewardCfgByID can not find id " .. tostring(id))
    return
  end
  return cfg
end

function GuildManager:GetMonsterTypeCfgByID(id)
  local MonsterTypeIns = ConfigManager:GetConfigInsByName("MonsterType")
  local cfg = MonsterTypeIns:GetValue_ByID(id)
  if cfg:GetError() then
    log.error(" GetMonsterTypeCfgByID can not find id " .. tostring(id))
    return
  end
  return cfg
end

function GuildManager:GetGuildBossRankNumStr(rank, rankNum)
  if not (rank and rankNum) or rank == 0 or rankNum == 0 then
    return 0
  end
  local rankMaxNum = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildBattleRanklist"))
  if rank <= rankMaxNum then
    return rank
  else
    local num = math.floor(rank * 10000 / rankNum) / 100
    return string.format(ConfigManager:GetCommonTextById(100009), num)
  end
end

function GuildManager:GetGuildBossGradeByRank(rank, rankCountMax)
  if rank == 0 then
    return 0
  end
  local configInstance = ConfigManager:GetConfigInsByName("GuildBattleReward")
  local rankAllCfg = configInstance:GetAll()
  local gradeID = 0
  for i, v in pairs(rankAllCfg) do
    local minStr = 0
    local maxStr = 0
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      if rank >= minStr and rank <= maxStr then
        gradeID = v.m_GradeID
        return gradeID, v
      end
    elseif rankCountMax ~= 0 and v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 10000
      maxStr = v.m_RankPercent[1] / 10000
      local num = rank / rankCountMax
      if minStr <= num and maxStr >= num then
        gradeID = v.m_GradeID
        return gradeID, v
      end
    end
  end
  return gradeID
end

function GuildManager:GetGuildBossHistory()
  return self.m_guildBossHistory
end

function GuildManager:GetBossMaxHp(levelId)
  local levelCfg = self:GetGuildBattleLevelCfgByID(levelId)
  local maxHp = 0
  if levelCfg then
    local mainTargetIDList = utils.changeCSArrayToLuaTable(levelCfg.m_MainTargetID)
    local attrList = CS.BattleGlobalManager.Instance:GetLevelMonstersMaxHP(levelCfg.m_MapID)
    for i, v in pairs(attrList) do
      for m, n in pairs(mainTargetIDList) do
        if n == i then
          maxHp = maxHp + v
        end
      end
    end
  end
  if maxHp == 0 then
    maxHp = 1
    log.error("GuildManager:GetBossMaxHp is error levelId = " .. tostring(levelId))
  end
  return maxHp
end

function GuildManager:GetAllianceBattleBossSeveralDay(iActivityId)
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = self:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossBeginTime then
    local actBeginTime = activity:GetGuildBossBeginTime()
    local actBattleEndTime = activity:GetGuildBossBattleEndTime()
    local day = TimeUtil:GetAFewDayDifference(actBeginTime, actBattleEndTime)
    local passDay = TimeUtil:GetPassedServerDay(actBeginTime)
    return day, passDay
  end
end

function GuildManager:IsGuildRankDataActive(guildBriefData)
  if not guildBriefData then
    return
  end
  if guildBriefData.iLastBattleRankTime == 0 then
    return
  end
  if guildBriefData.iLastBattleRank == 0 then
    return
  end
  local expirationTimeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildBattleRankExpirationTime") or 0)
  local endActiveTime = guildBriefData.iLastBattleRankTime + expirationTimeNum
  local curServerTime = TimeUtil:GetServerTimeS()
  return endActiveTime > curServerTime
end

function GuildManager:GetGuildBossBattleResult()
  return self.m_battleResultData
end

function GuildManager:GotoBattle(levelID, simFlag)
  self:EnterBattleBefore(levelID, simFlag)
  BattleFlowManager:StartEnterBattle(GuildManager.FightType_AllianceBattle, levelID)
end

function GuildManager:GetLevelMapID(levelType, levelID)
  local levelCfg = self:GetGuildBattleLevelCfgByID(levelID)
  if levelCfg then
    return levelCfg.m_MapID
  end
end

function GuildManager:EnterBattleBefore(levelID, simFlag)
  local guildBoss = self:GetGuildBossData()
  local vUseHero = self:GetGuildBossUsedFightHero()
  local levelCfg = self:GetGuildBattleLevelCfgByID(levelID)
  local cfg = self:GetGuildBattleBossCfgByID(levelCfg.m_BossID)
  if simFlag == nil then
    simFlag = false
  end
  local levelName = cfg.m_mName
  if simFlag then
    levelName = cfg.m_mName .. tostring(ConfigManager:GetCommonTextById(10005))
  end
  local data = {
    vUseHero = vUseHero,
    mFightingMonster = guildBoss.mBoss,
    mapId = levelCfg.m_MapID,
    simFlag = simFlag,
    iCurRound = guildBoss.iCurRound,
    bossID = levelCfg.m_BossID,
    iActivityId = guildBoss.iActivityId,
    levelName = levelName,
    levelID = levelID
  }
  BattleGuildRaidManager:EnterBattleBefore(data)
  self.m_seliBossId = levelCfg.m_BossID
end

function GuildManager:StartEnterBattle(levelType, levelID)
  if not levelType then
    levelType = GuildManager.FightType_AllianceBattle
    return
  end
  local cfg = self:GetGuildBattleLevelCfgByID(levelID)
  self:BeforeEnterBattle(levelType, levelID)
  if cfg then
    self:EnterPVEBattle(cfg.m_MapID)
  end
end

function GuildManager:BeforeEnterBattle(levelType, levelID)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = GuildManager.FightAllianceBattleSubType_Battle or 0,
    levelID = levelID,
    heroList = HeroManager:GetHeroServerList()
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function GuildManager:GetTransGuildInfo()
  if self.m_ownerGuildDetail then
    return self.m_ownerGuildDetail.iTransferEffectTime, self.m_ownerGuildDetail.stNewTransferMaster.iUid
  end
end

function GuildManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID, fightingMonster)
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    local iErrorCode = msg.rspcode
    log.error("Message Error Code: ", iErrorCode)
    if iErrorCode == 1508 or iErrorCode == 1509 then
      utils.popUpDirectionsUI({
        tipsID = 1514,
        bLockBack = true,
        func1 = function()
          BattleFlowManager:ExitBattle()
        end
      })
    elseif iErrorCode == 1502 then
      utils.popUpDirectionsUI({
        tipsID = 1512,
        bLockBack = true,
        func1 = function()
          BattleFlowManager:ExitBattle()
        end
      })
    else
      NetworkManager:OnRpcCallbackFail(msg, function()
        BattleFlowManager:ExitBattle()
      end)
    end
  else
    local battleData = self:GetGuildBossBattleResult()
    stageFinishChallengeSc = stageFinishChallengeSc or {}
    local param
    if 0 < table.getn(battleData) then
      param = {
        iActivityId = battleData.iActivityId,
        levelID = stageFinishChallengeSc.stFinishChallengeInfoSC.stVerifyInfo.iFightId,
        iBossId = battleData.iBossId,
        iDamage = battleData.iDamage,
        iRealDamage = battleData.iRealDamage,
        iBossHp = battleData.iBossHp,
        bKill = battleData.bKill,
        showHeroID = randomShowHeroID
      }
    elseif stageFinishChallengeSc and stageFinishChallengeSc.stFinishChallengeInfoSC then
      local guildBossData = self:GetGuildBossData()
      local serverData = self:GetBossServerDataByID(stageFinishChallengeSc.iBossId)
      local maxHp = serverData and serverData.iBossHp or self:GetBossMaxHp(stageFinishChallengeSc.stFinishChallengeInfoSC.stVerifyInfo.iFightId)
      local curHp = math.max(tonumber(maxHp) - tonumber(stageFinishChallengeSc.iScore), 0)
      param = {
        iActivityId = guildBossData.iActivityId,
        levelID = stageFinishChallengeSc.stFinishChallengeInfoSC.stVerifyInfo.iFightId,
        iBossId = stageFinishChallengeSc.iBossId,
        iDamage = stageFinishChallengeSc.iScore,
        iRealDamage = stageFinishChallengeSc.iScore,
        iBossHp = curHp,
        bKill = curHp == 0,
        showHeroID = randomShowHeroID
      }
    end
    StackFlow:Push(UIDefines.ID_FORM_GUILDRAIDBATTLEDETIAL, param)
    self.m_battleResultData = {}
  end
end

function GuildManager:OnBackLobby(fCB)
  local formStr
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      formStr = "Form_Hall"
      StackFlow:Push(UIDefines.ID_FORM_HALL)
      local bossId = self.m_seliBossId
      if self:IsGuildBossBattleTime() then
        formStr = "Form_GuildRaidMain"
        StackFlow:Push(UIDefines.ID_FORM_GUILDRAIDMAIN, {selBossID = bossId, requestFlag = true})
      else
        formStr = "Form_Guild"
        StackFlow:Push(UIDefines.ID_FORM_GUILD)
      end
      self.m_seliBossId = nil
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end, true)
end

function GuildManager:EnterNextBattle(levelType, ...)
end

function GuildManager:FromBattleToHall()
  self:ExitBattle()
end

function GuildManager:GetAssignLevelParams()
  return {
    GuildManager.FightType_AllianceBattle,
    GuildManager.FightAllianceBattleSubType_Battle,
    0,
    0
  }
end

function GuildManager:GetDownloadResourceExtra()
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = "Form_GuildRaidBattleDetial",
    eType = DownloadManager.ResourcePackageType.UI
  }
  return vPackage, nil
end

return GuildManager
