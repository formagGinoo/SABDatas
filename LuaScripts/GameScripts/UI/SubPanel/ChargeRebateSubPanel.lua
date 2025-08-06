local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ChargeRebateSubPanel = class("ChargeRebateSubPanel", UISubPanelBase)

function ChargeRebateSubPanel:OnInit()
  self.m_iActivityId = nil
  self.m_rewardInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_reward_InfinityGrid, "ActivityReward/ActChargeRebateRewardItem")
end

function ChargeRebateSubPanel:OnFreshData()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:RefreshData()
  if not self.m_stActivity then
    return
  end
  self:RefreshUI()
end

function ChargeRebateSubPanel:RefreshData()
  if self.m_panelData and self.m_panelData.activity then
    self.m_iActivityId = self.m_panelData.activity:getID()
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    self.rewardList = self.m_stActivity:GetRewardList()
  end
end

function ChargeRebateSubPanel:RefreshUI()
  local isMoveToIndex = 0
  local showRewardData = {}
  local lastPoint = 0
  local isGetIndex = false
  if self.rewardList then
    for k, v in pairs(self.rewardList) do
      showRewardData[#showRewardData + 1] = v
      showRewardData[#showRewardData].stActivity = self.m_stActivity
      showRewardData[#showRewardData].lastPoint = lastPoint
      lastPoint = v.iNeedPoint
      if not isGetIndex then
        local isGet = self.m_stActivity:CheckPointRewardIsGet(v.iNeedPoint)
        if not isGet then
          isGetIndex = true
          isMoveToIndex = k
        end
      end
    end
    self.m_rewardInfinityGrid:ShowItemList(showRewardData)
  end
  isMoveToIndex = 0 < isMoveToIndex - 1 and isMoveToIndex - 1 or 0
  self.m_rewardInfinityGrid:LocateTo(isMoveToIndex)
  self:FreshCurPoint()
  self:RefreshRemainTime()
end

function ChargeRebateSubPanel:OnEventGetReward(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  if self.m_parentLua then
    self.m_parentLua:RefreshTableButtonList()
  end
  self:RefreshUI()
end

function ChargeRebateSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_ChargeRebateReward", handler(self, self.OnEventGetReward))
end

function ChargeRebateSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ChargeRebateSubPanel:FreshCurPoint()
  self.m_txt_bigrewardnum_Text.text = self.m_stActivity:GetCurPoint()
  local itemId = self.m_stActivity:GetPointItemId()
  if itemId then
    local iconPath = ItemManager:GetItemIconPathByID(itemId)
    if iconPath then
      UILuaHelper.SetAtlasSprite(self.m_icon_big_reward_Image, iconPath)
    end
  end
end

function ChargeRebateSubPanel:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self:KillRemainTimer()
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
  local formatText = ConfigManager:GetCommonTextById(220018)
  local showTimeStr = TimeUtil:SecondsToFormatCNStr4(remainTime)
  showTimeStr = string.CS_Format(formatText, showTimeStr)
  self.m_txtRemainTime_Text.text = showTimeStr
  self.remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    local showTimeStr = TimeUtil:SecondsToFormatCNStr4(remainTime)
    showTimeStr = string.CS_Format(formatText, showTimeStr)
    self.m_txtRemainTime_Text.text = showTimeStr
    if remainTime <= 0 then
      self:KillRemainTimer()
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    end
  end)
end

function ChargeRebateSubPanel:KillRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function ChargeRebateSubPanel:OnBtnbigrewardClicked()
  if self.m_stActivity then
    local id = self.m_stActivity:GetPointItemId()
    local iNum = self.m_stActivity:GetCurPoint()
    utils.openItemDetailPop({iID = id, iNum = iNum})
  end
end

function ChargeRebateSubPanel:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(40001)
end

function ChargeRebateSubPanel:OnBtntipsClicked()
  local id = tonumber(self.m_stActivity:GetTipsId())
  if id then
    utils.popUpDirectionsUI({tipsID = id})
  end
end

function ChargeRebateSubPanel:OnGetReward()
  if self.m_stActivity then
    self.m_stActivity:RequestRewardCS(function()
      self:RefreshUI()
    end)
  end
end

function ChargeRebateSubPanel:GetDownloadResourceExtra(param)
end

function ChargeRebateSubPanel:OnInactive()
  self:KillRemainTimer()
  self:RemoveAllEventListeners()
end

return ChargeRebateSubPanel
