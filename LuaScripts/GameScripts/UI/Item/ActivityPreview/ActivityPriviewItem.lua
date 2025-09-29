local UIItemBase = require("UI/Common/UIItemBase")
local ActivityPriviewItem = class("ActivityPriviewItem", UIItemBase)
local iDaySecond = 86400
local iGrayColorIdx = 5
local fItemWidth = 202.5
local fItemWidthOffset = 15
local fItemPosOffset = 10

function ActivityPriviewItem:OnInit()
  self.m_BgMC = self.m_img_bg:GetComponent("MultiColorChange")
  self.m_LineMC = self.m_img_bgline:GetComponent("MultiColorChange")
  self.m_RootRectTransform = self.m_pnl_previewItem:GetComponent("RectTransform")
  self.m_pnl_previewItem:SetActive(true)
end

function ActivityPriviewItem:OnFreshData()
  local itemData = self.m_itemData
  if not itemData then
    return
  end
  local activity = itemData.activity
  if not activity then
    return
  end
  self:FreshBg()
  self:FreshActivity()
  self:FreshRootSizeDelta()
end

function ActivityPriviewItem:FreshBg()
  local iTodayZeroClockTime = TimeUtil:GetZeroClockTimeS()
  local iStartTime = self.m_itemData.iWeekMonday0Clock
  for i = 0, 6 do
    local iTempTime = iStartTime + i * iDaySecond
    self["m_img_select" .. i + 1]:SetActive(iTempTime == iTodayZeroClockTime)
  end
end

function ActivityPriviewItem:FreshActivity()
  local activity = self.m_itemData.activity
  if not activity then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_bgicon_Image, self.m_itemData.stStyle.sIcon)
  self.m_txt_preview_Text.text = activity:getLangText(activity:getTitle())
  local iActStartTime = activity.m_stActivityData.iBeginTime
  local iActEndTime = activity.m_stActivityData.iEndTime
  local dateStart = TimeUtil:GetServerDate(iActStartTime)
  local dateEnd = TimeUtil:GetServerDate(iActEndTime)
  self.m_txt_previewnum_Text.text = string.format("%s.%s - %s.%s", dateStart.month, dateStart.day, dateEnd.month, dateEnd.day)
  local iColorIdx = self.m_itemData.stStyle.iUiType or 0
  self.m_BgMC:SetColorByIndex(iColorIdx)
  self.m_LineMC:SetColorByIndex(iColorIdx)
end

function ActivityPriviewItem:FreshRootSizeDelta()
  local activity = self.m_itemData.activity
  if not activity then
    return
  end
  local iActStartTime = activity.m_stActivityData.iBeginTime
  local iActEndTime = activity.m_stActivityData.iEndTime
  local iActStartDay0Clock = TimeUtil:GetZeroClockTimeSParam(iActStartTime)
  local iActDuration, iActDurationDay = 0, 0
  if iActStartTime >= self.m_itemData.iWeekMonday0Clock and iActEndTime <= self.m_itemData.iWeekSunday0Clock then
    iActDuration = iActEndTime - iActStartTime
    iActDurationDay = math.ceil(iActDuration / iDaySecond)
    self.m_RootRectTransform.sizeDelta = Vector2.New(fItemWidth * iActDurationDay + fItemPosOffset, self.m_RootRectTransform.sizeDelta.y)
    local iActStartWday = math.floor((iActStartDay0Clock - self.m_itemData.iWeekMonday0Clock) / iDaySecond)
    self.m_RootRectTransform.anchoredPosition = Vector2.New(iActStartWday * fItemWidth, 0)
    self.m_txt_preview:SetActive(1 < iActDurationDay)
    self.m_txt_previewnum:SetActive(1 < iActDurationDay)
  elseif iActStartTime < self.m_itemData.iWeekMonday0Clock and iActEndTime > self.m_itemData.iWeekSunday0Clock then
    iActDurationDay = 7
    self.m_RootRectTransform.sizeDelta = Vector2.New(fItemWidth * iActDurationDay + fItemWidthOffset * 2, self.m_RootRectTransform.sizeDelta.y)
    self.m_RootRectTransform.anchoredPosition = Vector2.New(-fItemWidthOffset, 0)
  elseif iActStartTime < self.m_itemData.iWeekMonday0Clock and iActEndTime <= self.m_itemData.iWeekSunday0Clock then
    iActDuration = iActEndTime - self.m_itemData.iWeekMonday0Clock
    iActDurationDay = math.ceil(iActDuration / iDaySecond)
    self.m_RootRectTransform.sizeDelta = Vector2.New(fItemWidth * iActDurationDay + fItemWidthOffset + fItemPosOffset, self.m_RootRectTransform.sizeDelta.y)
    self.m_RootRectTransform.anchoredPosition = Vector2.New(-fItemWidthOffset, 0)
  elseif iActStartTime >= self.m_itemData.iWeekMonday0Clock and iActEndTime > self.m_itemData.iWeekSunday0Clock then
    iActDuration = self.m_itemData.iWeekSunday0Clock - iActStartTime
    iActDurationDay = math.ceil(iActDuration / iDaySecond)
    self.m_RootRectTransform.sizeDelta = Vector2.New(fItemWidth * iActDurationDay + fItemWidthOffset + fItemPosOffset, self.m_RootRectTransform.sizeDelta.y)
    local iActStartWday = math.floor((iActStartDay0Clock - self.m_itemData.iWeekMonday0Clock) / iDaySecond)
    self.m_RootRectTransform.anchoredPosition = Vector2.New(iActStartWday * fItemWidth, 0)
  end
  self.m_txt_preview:SetActive(1 < iActDurationDay)
  self.m_txt_previewnum:SetActive(1 < iActDurationDay)
end

return ActivityPriviewItem
