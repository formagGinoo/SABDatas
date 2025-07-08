local Form_DownloadPopup = class("Form_DownloadPopup", require("UI/UIFrames/Form_DownloadPopupUI"))
local TaskStatePriority = {
  [MTTDProto.QuestState_Finish] = 1,
  [MTTDProto.QuestState_Doing] = 2,
  [MTTDProto.QuestState_Over] = 3
}

function Form_DownloadPopup:SetInitParam(param)
end

function Form_DownloadPopup:AfterInit()
  self.super.AfterInit(self)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "Task/UITaskResourceItem")
  self:addEventListener("eGameEvent_ResourceDownload_QuestRefresh", handler(self, self.OnEventQuestRefresh))
  self:addEventListener("eGameEvent_ResourceDownload_QuestFinish", handler(self, self.OnEventQuestFinish))
  self:addEventListener("eGameEvent_ResourceDownload_QuestTakeReward", handler(self, self.OnEventQuestTakeReward))
end

function Form_DownloadPopup:OnActive()
  self.super.OnActive(self)
  self:RefreshTaskDownloadResourceAll()
end

function Form_DownloadPopup:OnInactive()
  self.super.OnInactive(self)
end

function Form_DownloadPopup:OnUpdate(dt)
  self.m_TaskListInfinityGrid:update(dt)
  if not CS.DeviceUtil.IsWIFIConnected() and not DownloadManager:CanDownloadInMobile() then
    self.m_tips_network:SetActive(true)
  else
    self.m_tips_network:SetActive(false)
  end
end

function Form_DownloadPopup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_DownloadPopup:RefreshTaskDownloadResourceAll()
  local vTaskDownloadResourceAll = DownloadManager:GetTaskDownloadResourceAll()
  local iDownloadingIndex = -1
  local iDownloadingMinPriority = 9999
  for iIndex, stTaskDownloadResourceInfo in ipairs(vTaskDownloadResourceAll) do
    stTaskDownloadResourceInfo.bDownloading = false
    if stTaskDownloadResourceInfo.iState == MTTDProto.QuestState_Doing and DownloadManager:IsAutoDownloadAddResAllSingle(stTaskDownloadResourceInfo.iID) and iDownloadingMinPriority > stTaskDownloadResourceInfo.tConfig.m_Priority then
      iDownloadingIndex = iIndex
      iDownloadingMinPriority = stTaskDownloadResourceInfo.tConfig.m_Priority
    end
  end
  if 0 < iDownloadingIndex then
    vTaskDownloadResourceAll[iDownloadingIndex].bDownloading = true
  end
  table.sort(vTaskDownloadResourceAll, function(a, b)
    if a.bDownloading and not b.bDownloading then
      return true
    elseif not a.bDownloading and b.bDownloading then
      return false
    elseif a.iState == b.iState then
      return a.tConfig.m_Priority < b.tConfig.m_Priority
    else
      return TaskStatePriority[a.iState] < TaskStatePriority[b.iState]
    end
  end)
  self.m_TaskListInfinityGrid:ShowItemList(vTaskDownloadResourceAll)
end

function Form_DownloadPopup:OnEventQuestRefresh(stEventInfo)
  self:RefreshTaskDownloadResourceAll()
end

function Form_DownloadPopup:OnEventQuestFinish(stEventInfo)
  self:RefreshTaskDownloadResourceAll()
end

function Form_DownloadPopup:OnEventQuestTakeReward(stEventInfo)
  local vReward = stEventInfo.vReward
  if vReward ~= nil then
    utils.popUpRewardUI(vReward, handler(self, self.RefreshTaskDownloadResourceAll))
  end
end

function Form_DownloadPopup:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_DownloadPopup:OnBtnReturnClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_DownloadPopup", Form_DownloadPopup)
return Form_DownloadPopup
