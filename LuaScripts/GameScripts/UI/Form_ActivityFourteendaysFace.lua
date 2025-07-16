local Form_ActivityFourteendaysFace = class("Form_ActivityFourteendaysFace", require("UI/UIFrames/Form_ActivityFourteendaysFaceUI"))
local SignMaxNum = 14

function Form_ActivityFourteendaysFace:SetInitParam(param)
end

function Form_ActivityFourteendaysFace:AfterInit()
  self.super.AfterInit(self)
  self.m_rewardInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_reward_InfinityGrid, "ActivityReward/ActFourteenSignRewardItem")
end

function Form_ActivityFourteendaysFace:AddEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function Form_ActivityFourteendaysFace:AutoRequestSign()
  if self.m_stActivity then
    local iSignNum = self.m_stActivity:GetSignNum()
    local bSignToday = self.m_stActivity:IsSignToday()
    local vSignInfoList = self.m_stActivity:GetSignInfoList()
    if not bSignToday and iSignNum < #vSignInfoList then
      local stSignInfo = vSignInfoList[iSignNum + 1]
      self.m_stActivity:RequestSign(stSignInfo.iIndex)
    end
  end
end

function Form_ActivityFourteendaysFace:RefreshUI()
  if self.m_stActivity == nil then
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE)
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
end

function Form_ActivityFourteendaysFace:RemoveEventListeners()
  if self.m_iHandlerIDUpdateSign then
    self:removeEventListener("eGameEvent_Activity_Sign_UpdateSign", self.m_iHandlerIDUpdateSign)
    self.m_iHandlerIDUpdateSign = nil
  end
  if self.m_iHandlerIDReload then
    self:removeEventListener("eGameEvent_Activity_Reload", self.m_iHandlerIDReload)
    self.m_iHandlerIDReload = nil
  end
end

function Form_ActivityFourteendaysFace:OnActive()
  self.super.OnActive(self)
  self:RemoveEventListeners()
  self:AddEventListeners()
  self.subPanelLuaName = self.m_csui.m_param
  local signActivityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_Sign)
  for _, v in ipairs(signActivityList) do
    if v:getSubPanelName() == self.subPanelLuaName then
      self.m_stActivity = v
    end
  end
  self:RefreshUI()
  self:AutoRequestSign()
end

function Form_ActivityFourteendaysFace:OnInactive()
  self:RemoveEventListeners()
  self:killRemainTimer()
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_ActivityFourteendaysFace:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityFourteendaysFace:OnUpdate(dt)
  self:RefreshRemainTime()
end

function Form_ActivityFourteendaysFace:RefreshReward()
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  local itemDataList = {}
  for i = 1, SignMaxNum do
    local itemData = {}
    local stSignInfo = vSignInfoList[i]
    local itemInfo = ResourceUtil:GetProcessRewardData({
      iID = stSignInfo.stRewardInfo[1].iID,
      iNum = stSignInfo.stRewardInfo[1].iNum
    })
    itemData.Day = i
    itemData.rewardInfo = itemInfo
    if i <= iSignNum then
      itemData.state = ActivityManager.SignTaken
    elseif i == iSignNum + 1 and not bSignToday then
      itemData.state = ActivityManager.SignCanTaken
    elseif i == iSignNum + 1 and bSignToday then
      itemData.state = ActivityManager.SignCanTaken
    else
      itemData.state = ActivityManager.SignCannotTaken
    end
    itemData.maxRewarDay = SignMaxNum
    table.insert(itemDataList, itemData)
  end
  self.m_rewardInfinityGrid:ShowItemList(itemDataList)
end

function Form_ActivityFourteendaysFace:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  local activityId = self.m_stActivity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  utils.popUpRewardUI(stParam.vReward)
  self:RefreshReward()
end

function Form_ActivityFourteendaysFace:OnEventActivityReload()
  self:RefreshUI()
  self:AutoRequestSign()
end

function Form_ActivityFourteendaysFace:OnBtncloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE)
end

function Form_ActivityFourteendaysFace:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self:killRemainTimer()
  self.endTime = self.m_stActivity:getActivityEndTime()
  if self.endTime == 0 then
    self.m_PanelRemainTime:SetActive(false)
    return
  end
  self.m_PanelRemainTime:SetActive(true)
  local remainTime = 0 < self.endTime - TimeUtil:GetServerTimeS() and self.endTime - TimeUtil:GetServerTimeS() or 0
  if not remainTime or remainTime <= 0 then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE)
    return
  end
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
  self.remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
    if remainTime <= 0 then
      self:killRemainTimer()
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE)
    end
  end)
end

function Form_ActivityFourteendaysFace:killRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function Form_ActivityFourteendaysFace:IsOpenGuassianBlur()
  return true
end

function Form_ActivityFourteendaysFace:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

local fullscreen = true
ActiveLuaUI("Form_ActivityFourteendaysFace", Form_ActivityFourteendaysFace)
return Form_ActivityFourteendaysFace
