local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AnnouncementPushFaceSubPanelBase = class("AnnouncementPushFaceSubPanelBase", UISubPanelBase)
local EndTips = ConfigManager:GetCommonTextById(220018)

function AnnouncementPushFaceSubPanelBase:OnInit()
end

function AnnouncementPushFaceSubPanelBase:OnFreshData()
  self.m_curAct = self.m_panelData.activity
  if not self.m_curAct then
    self:broadcastEvent("eGameEvent_Activity_CloseActivityAnnouncement")
    return
  end
  self.m_pushFaceData = self.m_curAct:GetPushJumpData()
  if not self.m_pushFaceData then
    self:broadcastEvent("eGameEvent_Activity_CloseActivityAnnouncement")
    log.error("Please Check Announcement Config")
    return
  end
  local serverTime = TimeUtil:GetServerTimeS()
  self.m_isLeft = self.m_pushFaceData.portraitPosition == 1
  self.m_openTime, self.m_endTime = self.m_curAct:GetPushJumpTimeWindow()
  self.m_isOpen = serverTime > self.m_openTime and serverTime < self.m_endTime
  self.m_isEnd = TimeUtil:GetServerTimeS() > self.m_endTime
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:FreshUI()
end

function AnnouncementPushFaceSubPanelBase:FreshUI()
  self:FreshReward()
  self:FreshBg()
  UILuaHelper.SetActive(self.m_pnl_infor_right, not self.m_isLeft)
  UILuaHelper.SetActive(self.m_pnl_infor_left, self.m_isLeft)
  if self.m_isLeft then
    self:UpdateLeftPanel()
  else
    self:UpdateRightPanel()
  end
end

function AnnouncementPushFaceSubPanelBase:StartCountdown(endTime, updateCallback)
  self:StopCountdown()
  self.m_endTimer = TimeService:SetTimer(1, -1, function()
    local remainTime = endTime - TimeUtil:GetServerTimeS()
    if remainTime < 0 then
      self.m_isEnd = true
      if self.m_isLeft then
        if not utils.isNull(self.m_pnl_timeLeft) then
          self.m_pnl_timeLeft:SetActive(false)
        end
        if not utils.isNull(self.m_pnl_btnLeft) then
          self.m_pnl_btnLeft:SetActive(false)
        end
      else
        if not utils.isNull(self.m_pnl_timeRight) then
          self.m_pnl_timeRight:SetActive(false)
        end
        if not utils.isNull(self.m_pnl_btnRight) then
          self.m_pnl_btnRight:SetActive(false)
        end
      end
      self:StopCountdown()
    else
      updateCallback(remainTime)
    end
  end)
end

function AnnouncementPushFaceSubPanelBase:StopCountdown()
  if self.m_endTimer then
    TimeService:KillTimer(self.m_endTimer)
    self.m_endTimer = nil
  end
end

function AnnouncementPushFaceSubPanelBase:FreshReward()
  local reward = self.m_curAct:GetPushJumpWindowRewardReward()
  local isShowReward = reward and table.getn(reward) > 0
  if not utils.isNull(self.m_pnl_reward) then
    self.m_pnl_reward:SetActive(isShowReward)
  end
  if not isShowReward then
    return
  end
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = reward[1].iID,
    iNum = reward[1].iNum
  })
  local arriveRewardTime = self.m_curAct:GetPushJumpWindowRewardTime()
  if arriveRewardTime < TimeUtil:GetServerTimeS() then
    local isGot = self.m_curAct:GetPushJumpIsGotReward()
    if isGot then
      self.m_pnl_received:SetActive(true)
      self.m_btn_reward:SetActive(false)
      UILuaHelper.SetAtlasSprite(self.m_img_reward03_Image, processItemData.icon_name, function()
        if not utils.isNull(self.m_img_reward03) then
          self.m_img_reward03_Image:SetNativeSize()
        end
      end)
    else
      self.m_itemNum_Text.text = tostring(reward[1].iNum)
      self.m_pnl_received:SetActive(false)
      self.m_btn_reward:SetActive(true)
      UILuaHelper.SetAtlasSprite(self.m_img_reward02_Image, processItemData.icon_name, function()
        if not utils.isNull(self.m_img_reward02) then
          self.m_img_reward02_Image:SetNativeSize()
        end
      end)
    end
    self.m_pnl_reward_tips:SetActive(false)
  else
    self.m_pnl_reward_tips:SetActive(true)
    self.m_txt_reward2_Text.text = "x" .. tostring(reward[1].iNum)
    UILuaHelper.SetAtlasSprite(self.m_img_reward01_Image, processItemData.icon_name, function()
      if not utils.isNull(self.m_img_reward01) then
        self.m_img_reward01_Image:SetNativeSize()
      end
    end)
    self.m_pnl_received:SetActive(false)
    self.m_btn_reward:SetActive(false)
  end
end

function AnnouncementPushFaceSubPanelBase:FreshBg()
  local actData = ActivityManager:GetActivityDataByID(self.m_curAct:getID())
  ActivityManager:SetActivityImage(actData, self.m_img_bg_Image, self.m_pushFaceData.sBackgroundPic)
end

function AnnouncementPushFaceSubPanelBase:OnInactivePanel()
  self:RemoveAllEventListeners()
  self:StopCountdown()
end

function AnnouncementPushFaceSubPanelBase:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_PushFaceReserve", handler(self, self.OnEventGetReward))
end

function AnnouncementPushFaceSubPanelBase:RemoveAllEventListeners()
  self:clearEventListener()
end

function AnnouncementPushFaceSubPanelBase:OnEventGetReward(stParam)
  if self.m_curAct and self.m_curAct:getID() == stParam.iActivityID then
    self:FreshReward()
  end
end

function AnnouncementPushFaceSubPanelBase:OnBtngotoLeftClicked()
  QuickOpenFuncUtil:OpenFunc(self.m_pushFaceData.iJumpActivityId)
end

function AnnouncementPushFaceSubPanelBase:OnBtngotoRightClicked()
  QuickOpenFuncUtil:OpenFunc(self.m_pushFaceData.iJumpActivityId)
end

function AnnouncementPushFaceSubPanelBase:OnBtnrewardClicked()
  if not self.m_curAct or self.m_isEnd then
    return
  end
  self.m_curAct:ReqGetRewardCS()
end

function AnnouncementPushFaceSubPanelBase:UpdateLeftPanel()
  if self.m_isOpen then
    self:StartCountdown(self.m_endTime, function(remainTime)
      if not utils.isNull(self.m_txt_timeLeft) then
        self.m_txt_timeLeft_Text.text = string.CS_Format(EndTips, TimeUtil:SecondsToFormatCNStr4(remainTime))
      end
    end)
    self.m_btn_readyLeft:SetActive(false)
    self.m_btn_gotoLeft:SetActive(true)
  else
    self:StopCountdown()
    self.m_btn_readyLeft:SetActive(true)
    self.m_btn_gotoLeft:SetActive(false)
    self.m_txt_timeLeft_Text.text = TimeUtil:ServerTimerToServerString2(self.m_openTime) .. "-" .. TimeUtil:ServerTimerToServerString2(self.m_endTime)
  end
end

function AnnouncementPushFaceSubPanelBase:UpdateRightPanel()
  if self.m_isOpen then
    self:StartCountdown(self.m_endTime, function(remainTime)
      if not utils.isNull(self.m_txt_timeRight) then
        self.m_txt_timeRight_Text.text = string.CS_Format(EndTips, TimeUtil:SecondsToFormatCNStr4(remainTime))
      end
    end)
    self.m_btn_readyRight:SetActive(false)
    self.m_btn_gotoRight:SetActive(true)
  else
    self:StopCountdown()
    self.m_btn_readyRight:SetActive(true)
    self.m_btn_gotoRight:SetActive(false)
    self.m_txt_timeRight_Text.text = TimeUtil:ServerTimerToServerString2(self.m_openTime) .. "-" .. TimeUtil:ServerTimerToServerString2(self.m_endTime)
  end
end

return AnnouncementPushFaceSubPanelBase
