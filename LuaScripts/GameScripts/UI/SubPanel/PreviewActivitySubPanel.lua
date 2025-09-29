local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PreviewActivitySubPanel = class("PreviewActivitySubPanel", UISubPanelBase)
local iDaySecond = 86400
local sPreviewInAniName = "Activity_EvenTcalendar_preview_in01B"
local sPreviewOutAniName = "Activity_EvenTcalendar_preview_out01B"

function PreviewActivitySubPanel:OnInit()
  self.m_PreviewInfinity = self:CreateInfinityGrid(self.m_pnl_preview_InfinityGrid, "ActivityPreview/ActivityPriviewItem")
end

function PreviewActivitySubPanel:OnInActive()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

function PreviewActivitySubPanel:OnDestroy()
  PreviewActivitySubPanel.super.OnDestroy(self)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

function PreviewActivitySubPanel:OnFreshData()
  self.m_stActivity = self.m_panelData.activity
  if not self.m_stActivity then
    return
  end
  self.vAllWeekPreviewList = self.m_stActivity:GetAllWeekPreviewList()
  self.iCurWeekIdx = 1
  self.iMaxWeekIdx = #self.vAllWeekPreviewList
  if #self.vAllWeekPreviewList <= 0 then
    self:FreshTopInfo()
    self.m_PreviewInfinity:ShowItemList({})
    self.m_btn_lastweek:SetActive(false)
    self.m_btn_nextweek:SetActive(false)
    return
  end
  if #self.vAllWeekPreviewList < 2 then
    self.iCurWeekIdx = 1
  end
  UILuaHelper.PlayAnimationByName(self.m_pnl_preview, sPreviewInAniName)
  self:RefreshUI()
end

function PreviewActivitySubPanel:RefreshUI()
  local info = self.vAllWeekPreviewList[self.iCurWeekIdx]
  local vPreviewList = info and info.vActivityList or {}
  self.m_PreviewInfinity:ShowItemList(vPreviewList)
  self.m_PreviewInfinity:LocateTo(0)
  self:FreshTopInfo()
end

function PreviewActivitySubPanel:FreshTopInfo()
  local iTodayZeroClockTime = TimeUtil:GetZeroClockTimeS()
  local iStartTime = TimeUtil:GetMonday0Clock(iTodayZeroClockTime)
  local info = self.vAllWeekPreviewList[self.iCurWeekIdx]
  if info then
    iStartTime = info.iStartTime
  end
  for i = 0, 6 do
    local iTempTime = iStartTime + i * iDaySecond
    local date = TimeUtil:GetServerDate(iTempTime)
    self["m_txt_week" .. i + 1 .. "_Text"].text = string.format("%s.%s", date.month, date.day)
    self["m_img_bg_select" .. i + 1].gameObject:SetActive(iTempTime == iTodayZeroClockTime)
  end
  self.m_btn_lastweek:SetActive(self.iCurWeekIdx > 1)
  self.m_btn_nextweek:SetActive(self.iCurWeekIdx < self.iMaxWeekIdx)
end

function PreviewActivitySubPanel:OnBtnlastweekClicked()
  self.iCurWeekIdx = self.iCurWeekIdx - 1
  if self.iCurWeekIdx < 1 then
    self.iCurWeekIdx = 1
  end
  self:PlayChangeAni()
end

function PreviewActivitySubPanel:OnBtnnextweekClicked()
  self.iCurWeekIdx = self.iCurWeekIdx + 1
  if self.iCurWeekIdx > self.iMaxWeekIdx then
    self.iCurWeekIdx = self.iMaxWeekIdx
  end
  self:PlayChangeAni()
end

function PreviewActivitySubPanel:PlayChangeAni()
  local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_pnl_preview, sPreviewOutAniName)
  UILockIns:Lock(fAniLength)
  UILuaHelper.PlayAnimationByName(self.m_pnl_preview, sPreviewOutAniName)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  self.m_timer = TimeService:SetTimer(fAniLength, 1, function()
    self:RefreshUI()
    UILuaHelper.PlayAnimationByName(self.m_pnl_preview, sPreviewInAniName)
  end)
end

function PreviewActivitySubPanel:OnBtnpreviewClicked()
  StackPopup:Push(UIDefines.ID_FORM_ACTIVITYEVENTCALENDARPOP, {
    activity = self.m_stActivity
  })
end

return PreviewActivitySubPanel
