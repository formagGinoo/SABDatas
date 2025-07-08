local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PVPReplaceSubPanel = class("PVPReplaceSubPanel", UISubPanelBase)
local UpdateDeltaNum = 3
local UpdateRewardDeltaNum = 60

function PVPReplaceSubPanel:OnInit()
  self.m_curSeasonID = nil
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_isCurSeason = nil
  self.m_showSeasonTime = nil
  self:AddEventListeners()
  self:FreshArenaStaticInfo()
  self:RegisterRedDot()
  self.m_isCanUpdateReward = false
  self.m_curDeltaRewardTime = 0
  self.m_isFreshSeasonInfo = false
  self.m_isReqSeeAfk = false
end

function PVPReplaceSubPanel:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_PVP_replace_reward_red_dot, RedDotDefine.ModuleType.PvpReplaceHangUpReward)
end

function PVPReplaceSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_ReplaceArena_SeasonInit", handler(self, self.OnEventArenaSeasonInit))
  self:addEventListener("eGameEvent_ReplaceArena_RankChange", handler(self, self.OnEventReplaceRankChange))
  self:addEventListener("eGameEvent_Level_ArenaReplaceSeeAfk", handler(self, self.OnEventReplaceSeeAfk))
  self:addEventListener("eGameEvent_Level_ArenaReplaceAFKFresh", handler(self, self.OnEventReplaceAFKFresh))
end

function PVPReplaceSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function PVPReplaceSubPanel:OnEventArenaSeasonInit()
  self:FreshArena()
end

function PVPReplaceSubPanel:OnEventReplaceRankChange()
  self:FreshRankInfo()
end

function PVPReplaceSubPanel:OnEventReplaceSeeAfk(replaceArenaAfkInfo)
  if not self.m_isReqSeeAfk then
    return
  end
  if not replaceArenaAfkInfo then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEINFORPOP, {})
  self.m_isReqSeeAfk = false
end

function PVPReplaceSubPanel:OnEventReplaceAFKFresh()
  self:FreshRewardStatus()
end

function PVPReplaceSubPanel:OnFreshData()
end

function PVPReplaceSubPanel:Update()
  self:CheckUpdateLeftTime()
  self:CheckUpdateReward()
end

function PVPReplaceSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  PVPReplaceSubPanel.super.OnDestroy(self)
end

function PVPReplaceSubPanel:FreshArenaStaticInfo()
  local systemUnlockCfg = UnlockSystemUtil:GetSystemUnlockConfig(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if systemUnlockCfg then
    self.m_txt_activity_pvprep_Text.text = systemUnlockCfg.m_mName
  end
end

function PVPReplaceSubPanel:ClearFreshStatus()
  self.m_isFreshSeasonInfo = false
end

function PVPReplaceSubPanel:CheckFreshArena()
  self.m_isReqSeeAfk = false
  if self.m_isFreshSeasonInfo then
    return
  end
  self.m_isFreshSeasonInfo = true
  self:FreshArena()
end

function PVPReplaceSubPanel:FreshArena()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  UILuaHelper.SetActive(self.m_pnl_pvp_replace_a, true)
  UILuaHelper.SetActive(self.m_pnl_pvp_replace_b, not openFlag)
  self.m_txt_activity_pvp_replace_lock_Text.text = UnlockSystemUtil:GetLockClientMessage(tips_id)
  if openFlag then
    self.m_curSeasonID = PvpReplaceManager:GetSeasonID()
    local curSeasonEndTime, nextSeasonStartTime = PvpReplaceManager:GetSeasonTimeByCfg()
    if not self.m_curSeasonID and PvpReplaceManager:IsInSeasonGameTime() == true then
      UILuaHelper.SetActive(self.m_Btn_Card_PvP_Replace, false)
      PvpReplaceManager:ReqReplaceArenaGetInit()
      return
    end
    UILuaHelper.SetActive(self.m_Btn_Card_PvP_Replace, true)
    local curServerTime = TimeUtil:GetServerTimeS()
    self.m_showSeasonTime = nil
    if curSeasonEndTime > curServerTime then
      self.m_isCurSeason = true
      self.m_showSeasonTime = curSeasonEndTime
    elseif curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
      self.m_isCurSeason = false
      self.m_showSeasonTime = nextSeasonStartTime
    else
      self.m_isCurSeason = false
    end
    self.m_isCanUpdateLeftTime = true
    UILuaHelper.SetActive(self.m_pvprep_time_bg, self.m_isCurSeason and self.m_showSeasonTime)
    UILuaHelper.SetActive(self.m_pvprep_time_next_bg, not self.m_isCurSeason and self.m_showSeasonTime)
    UILuaHelper.SetActive(self.m_pvprep_num_bg, self.m_isCurSeason)
    self:FreshShowArenaDetail()
    self:FreshRankInfo()
    self:FreshRewardStatus()
  end
end

function PVPReplaceSubPanel:CheckUpdateReward()
  if not self.m_isCanUpdateReward then
    return
  end
  if self.m_curDeltaRewardTime <= UpdateRewardDeltaNum then
    self.m_curDeltaRewardTime = self.m_curDeltaRewardTime + 1
  else
    self.m_curDeltaRewardTime = 0
    self:FreshRewardStatus()
  end
end

function PVPReplaceSubPanel:CheckUpdateLeftTime()
  if not self.m_isCanUpdateLeftTime then
    return
  end
  if not self.m_showSeasonTime then
    return
  end
  if self.m_curDeltaTimeNum <= UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowLeftTimeStr()
  end
end

function PVPReplaceSubPanel:ShowLeftTimeStr()
  local nextResetTimer = self.m_showSeasonTime
  local curTimer = TimeUtil:GetServerTimeS()
  local leftTimeSec = nextResetTimer - curTimer
  if leftTimeSec <= 0 then
    leftTimeSec = 0
    self.m_isCanUpdateLeftTime = false
    self:FreshArena()
  end
  local showText = self.m_pvprep_time_Text
  if not self.m_isCurSeason then
    showText = self.m_pvprep_time_next_Text
  end
  showText.text = TimeUtil:SecondsToFormatStrDHOrHMS(leftTimeSec)
end

function PVPReplaceSubPanel:FreshShowArenaDetail()
  local ticketFreeCount = PvpReplaceManager:GetSeasonTicketFreeCount() or 0
  local totalFreeNum = ConfigManager:GetGlobalSettingsByKey("ReplaceArenaDailyFreeTime") or 2
  local leftFreeCount = totalFreeNum - ticketFreeCount
  if leftFreeCount < 0 then
    leftFreeCount = 0
  end
  self.m_pvprep_num_Text.text = math.floor(leftFreeCount) .. "/" .. totalFreeNum
end

function PVPReplaceSubPanel:FreshRankInfo()
  local rankNum = PvpReplaceManager:GetSeasonRank() or 0
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum, PvpReplaceManager:GetSeasonArenPlay() or 0)
  self.m_txt_pvprep_rank_Text.text = rankCfg.m_mName
  UILuaHelper.SetAtlasSprite(self.m_icon_pvprep_rank_Image, rankCfg.m_RankIcon)
end

function PVPReplaceSubPanel:FreshRewardStatus()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    UILuaHelper.SetActive(self.m_btn_reward, false)
    return
  end
  local isRankHaveReward = PvpReplaceManager:IsAfkRankCanReward()
  if isRankHaveReward then
    local curServerTime = TimeUtil:GetServerTimeS()
    local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
    local lastTakeTime = afkData.iTakeRewardTime
    local fullTime = lastTakeTime + limitTimeSecNum
    local isFull = curServerTime >= fullTime
    if not isFull then
      local percentNum = math.floor((curServerTime - lastTakeTime) / limitTimeSecNum * 100)
      if percentNum < 0 then
        percentNum = 0
      end
      self.m_txt_reward_nml_Text.text = percentNum .. "%"
    end
    self.m_isCanUpdateReward = not isFull
    UILuaHelper.SetActive(self.m_btn_reward, true)
    UILuaHelper.SetActive(self.m_bg_reward_nml, not isFull)
    UILuaHelper.SetActive(self.m_bg_reward_100, isFull)
    if isFull then
      self.m_txt_reward_100_Text.text = 100 .. "%"
    end
  else
    UILuaHelper.SetActive(self.m_btn_reward, false)
  end
end

function PVPReplaceSubPanel:OnBtnCardPvPReplaceClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ReplaceArena)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  if not self.m_isCurSeason then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40014)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEMAIN)
end

function PVPReplaceSubPanel:OnBtnrewardClicked()
  self.m_isReqSeeAfk = true
  PvpReplaceManager:ReqReplaceArenaSeeAfk()
end

function PVPReplaceSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return PVPReplaceSubPanel
