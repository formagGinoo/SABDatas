local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PVPEnterSubPanel = class("PVPEnterSubPanel", UISubPanelBase)
local UpdateDeltaNum = 3

function PVPEnterSubPanel:OnInit()
  self.m_curSeasonID = nil
  self.m_isReqSeasonInfo = false
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_isCurSeason = nil
  self.m_showSeasonTime = nil
  self:AddEventListeners()
  self:FreshArenaStaticInfo()
  self:RegisterRedDot()
end

function PVPEnterSubPanel:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_PVP_red_dot, RedDotDefine.ModuleType.LevelEntry, BattleFlowManager.ArenaType.Arena)
end

function PVPEnterSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Arena_SeasonInit", handler(self, self.OnEventArenaSeasonInit))
end

function PVPEnterSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function PVPEnterSubPanel:OnEventArenaSeasonInit()
  self:FreshArena()
end

function PVPEnterSubPanel:OnFreshData()
end

function PVPEnterSubPanel:Update()
  self:CheckUpdateLeftTime()
end

function PVPEnterSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  PVPEnterSubPanel.super.OnDestroy(self)
end

function PVPEnterSubPanel:FreshArenaStaticInfo()
  local systemUnlockCfg = UnlockSystemUtil:GetSystemUnlockConfig(GlobalConfig.SYSTEM_ID.Arena)
  if systemUnlockCfg then
    self.m_txt_activity_pvp_Text.text = systemUnlockCfg.m_mName
  end
end

function PVPEnterSubPanel:FreshArena()
  UILuaHelper.SetActive(self.m_Btn_Card_PvP, true)
  self.m_curSeasonID = ArenaManager:GetSeasonID()
  local curSeasonEndTime = ArenaManager:GetCurSeasonEndTime() or 0
  local nextSeasonStartTime = ArenaManager:GetNextSeasonStartTime() or 0
  local curServerTime = TimeUtil:GetServerTimeS()
  local mineSeasonEndTime = ArenaManager:GetMineSeasonEndTime() or 0
  local isNotJoin = curServerTime > mineSeasonEndTime
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
  UILuaHelper.SetActive(self.m_pvp_time_bg, self.m_isCurSeason and self.m_showSeasonTime)
  UILuaHelper.SetActive(self.m_pvp_time_next_bg, not self.m_isCurSeason and self.m_showSeasonTime)
  UILuaHelper.SetActive(self.m_pvp_not_join, isNotJoin)
  UILuaHelper.SetActive(self.m_pvp_rank, not isNotJoin)
  UILuaHelper.SetActive(self.m_pvp_num_bg, not isNotJoin and self.m_isCurSeason)
  self:FreshShowArenaDetail()
end

function PVPEnterSubPanel:CheckUpdateLeftTime()
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

function PVPEnterSubPanel:ShowLeftTimeStr()
  local nextResetTimer = self.m_showSeasonTime
  local curTimer = TimeUtil:GetServerTimeS()
  local leftTimeSec = nextResetTimer - curTimer
  if leftTimeSec <= 0 then
    leftTimeSec = 0
    self.m_isCanUpdateLeftTime = false
    self:FreshArena()
  end
  local showText = self.m_pvp_time_Text
  if not self.m_isCurSeason then
    showText = self.m_pvp_time_next_Text
  end
  showText.text = TimeUtil:SecondsToFormatStrDHOrHMS(leftTimeSec)
end

function PVPEnterSubPanel:FreshShowArenaDetail()
  local rank = ArenaManager:GetSeasonRank()
  if rank == 0 then
    rank = "- -"
  end
  self.m_txt_rank_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20351), rank)
  local ticketFreeCount = ArenaManager:GetSeasonTicketFreeCount() or 0
  local totalFreeNum = ArenaManager:GetFreeCountMaxNum() or 3
  if ticketFreeCount < 0 then
    ticketFreeCount = 0
  end
  self.m_pvp_num_Text.text = math.floor(ticketFreeCount) .. "/" .. totalFreeNum
end

function PVPEnterSubPanel:ClearArenaReqStatus()
  self.m_curSeasonID = nil
  self.m_isReqSeasonInfo = false
end

function PVPEnterSubPanel:CheckReqArenaSeason()
  if self.m_isReqSeasonInfo then
    return
  end
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena)
  UILuaHelper.SetActive(self.m_pnl_pvp_a, true)
  UILuaHelper.SetActive(self.m_pnl_pvp_b, not openFlag)
  self.m_txt_activity_pvp_lock_Text.text = UnlockSystemUtil:GetLockClientMessage(tips_id)
  if openFlag then
    UILuaHelper.SetActive(self.m_Btn_Card_PvP, false)
    if self.m_curSeasonID then
      self:FreshArena()
    else
      ArenaManager:ReqOriginalArenaGetInit()
    end
  else
    UILuaHelper.SetActive(self.m_Btn_Card_PvP, true)
  end
  self.m_isReqSeasonInfo = true
end

function PVPEnterSubPanel:OnBtnCardPvPClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  if not self.m_isCurSeason then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40014)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_PVPMAIN)
end

function PVPEnterSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return PVPEnterSubPanel
