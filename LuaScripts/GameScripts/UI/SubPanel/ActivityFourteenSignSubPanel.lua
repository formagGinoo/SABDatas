local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityFourteenSignSubPanel = class("ActivityFourteenSignSubPanel", UISubPanelBase)
local SignMaxNum = 14

function ActivityFourteenSignSubPanel:OnInit()
  self:AddEventListeners()
  self.m_rewardInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_reward_InfinityGrid, "ActivityReward/ActFourteenSignRewardItem")
end

function ActivityFourteenSignSubPanel:AddEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function ActivityFourteenSignSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ActivityFourteenSignSubPanel:OnFreshData()
  self:RefreshUI()
  self:AutoRequestSign()
end

function ActivityFourteenSignSubPanel:RefreshUI()
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if self.m_stActivity == nil then
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
end

function ActivityFourteenSignSubPanel:RefreshReward()
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

function ActivityFourteenSignSubPanel:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  PushFaceManager:RemoveShowPopPanelList(UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE, self.m_stActivity:getSubPanelName())
  if self.m_rootObj.activeInHierarchy then
    utils.popUpRewardUI(stParam.vReward)
    self:RefreshReward()
  end
end

function ActivityFourteenSignSubPanel:OnEventActivityReload()
  if self.m_rootObj.activeInHierarchy then
    self:RefreshUI()
    self:AutoRequestSign()
  end
end

function ActivityFourteenSignSubPanel:AutoRequestSign()
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

function ActivityFourteenSignSubPanel:RefreshRemainTime()
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
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    return
  end
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
  self.remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
    if remainTime <= 0 then
      self:killRemainTimer()
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    end
  end)
end

function ActivityFourteenSignSubPanel:killRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function ActivityFourteenSignSubPanel:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return ActivityFourteenSignSubPanel
