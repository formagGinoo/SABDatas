local UIItemBase = require("UI/Common/UIItemBase")
local ActivityIntegrationItem = class("ActivityIntegrationItem", UIItemBase)
local ShowType = {
  UpActivity = 1,
  UpSubActivity = 2,
  GMActivity = 3,
  GachaType = 4,
  MainChapter = 5,
  FourteenUpTask = 6
}

function ActivityIntegrationItem:OnInit()
  self.m_btn_Extension = self.m_btn_actJump:GetComponent("ButtonExtensions")
  self.m_btn_Extension.Clicked = handler(self, self.OnBtnItemClk)
end

function ActivityIntegrationItem:OnFreshData()
  self.m_data = self.m_itemData
  local isShowTime = true
  local isOpen = TimeUtil:IsInTime(self.m_data.iOpenTime, self.m_data.iCloseTime)
  local isEnd = TimeUtil:GetServerTimeS() > self.m_data.iCloseTime and self.m_data.iCloseTime ~= 0
  if self.m_data.iOpenTime == 0 or self.m_data.iCloseTime == 0 or isOpen or isEnd then
    isShowTime = false
  end
  if isShowTime then
    self.m_txt_time_Text.text = TimeUtil:ServerTimerToServerString2(self.m_data.iOpenTime)
  end
  UILuaHelper.SetActive(self.m_lock, isShowTime)
  UILuaHelper.SetActive(self.m_txt_time, isShowTime)
  self.m_txt_name_Text.text = self.m_data.act:getLangText(self.m_data.sActivityName)
  UILuaHelper.SetActive(self.m_end, isEnd)
  self:FreshRed()
  UILuaHelper.SetActive(self.m_lock, not isOpen and not isEnd)
  local isShowRed = self.m_data.act:DealRedWithAct(self.m_data.Index)
  UILuaHelper.SetActive(self.m_red, isShowRed)
  UILuaHelper.SetAtlasSprite(self.m_bg_Image, self.m_data.sActivityPic)
end

function ActivityIntegrationItem:OnBtnItemClk()
  local isOpen = TimeUtil:IsInTime(self.m_data.iOpenTime, self.m_data.iCloseTime)
  local isEnd = TimeUtil:GetServerTimeS() > self.m_data.iCloseTime and self.m_data.iCloseTime ~= 0
  if not isOpen and not isEnd then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40059), TimeUtil:ServerTimerToServerString2(self.m_data.iOpenTime)))
    return
  end
  if isEnd then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40060)
    return
  end
  if self.m_data.act then
    self.m_data.act:DealJump(self.m_data)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYINTEGRATION)
  end
end

function ActivityIntegrationItem:FreshRed()
  UILuaHelper.SetActive(self.m_red, false)
end

return ActivityIntegrationItem
