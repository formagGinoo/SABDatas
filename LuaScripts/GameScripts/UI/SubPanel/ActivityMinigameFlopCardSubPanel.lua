local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityMinigameFlopCardSubPanel = class("MinigameFlopCardSubPanel", UISubPanelBase)
local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")

function ActivityMinigameFlopCardSubPanel:OnInit()
  local initGridData = {
    OnItemClk = function(m_itemData, m_itemIndex, is_select)
      self:OnItemClk(m_itemData, m_itemIndex, is_select)
    end
  }
  self.m_Grid = self:CreateInfinityGrid(self.m_card_list_InfinityGrid, "ActivityMinigame110/MinigameFlipItem", initGridData)
  self:AddEventListeners()
end

function ActivityMinigameFlopCardSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_MiniGameTaskGetReward", handler(self, self.OnFreshTaskRed))
  self:addEventListener("eGameEvent_Level_MinigameFinish", handler(self, self.OnMinigameFinish))
  self:addEventListener("eGameEvent_Level_MinigameLvIndex", handler(self, self.OnChooseLevelPop))
end

function ActivityMinigameFlopCardSubPanel:OnFreshTaskRed()
  local isShowRedTask = self.m_stActivity:GetPendingRewardTasks()
  UILuaHelper.SetActive(self.m_task_redpoint, isShowRedTask)
  if self.m_parentLua then
    self.m_parentLua:RefreshTableButtonList()
  end
end

function ActivityMinigameFlopCardSubPanel:OnChooseLevelPop(m_itemIndex)
  self.m_itemIndex = m_itemIndex
end

function ActivityMinigameFlopCardSubPanel:OnMinigameFinish(isGetClue, iLevelId)
  local script = self.m_Grid:GetShowItemByIndex(self.m_itemIndex)
  script:ShowFinished(isGetClue)
end

function ActivityMinigameFlopCardSubPanel:OnFreshData()
  GlobalManagerIns:TriggerWwiseBGMState(385)
  if self.m_parentLua then
    local curServerDate = TimeUtil:GetServerDate(TimeUtil:GetServerTimeS())
    local timeStr = curServerDate.year .. curServerDate.month .. curServerDate.day
    LocalDataManager:SetStringSimple("Activity_FlopCard_DayilyRedpointDt", timeStr)
    self.m_parentLua:RefreshTableButtonList()
  end
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  local endtime = self.m_stActivity:getActivityEndTime()
  if endtime == 0 then
    UILuaHelper.SetActive(self.m_img_bg_time, false)
  else
    UILuaHelper.SetActive(self.m_img_bg_time, true)
    local remainTimes = self.m_stActivity:getActivityRemainTime()
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(remainTimes)
  end
  self:OnFreshTaskRed()
  local arry = {}
  for k, v in pairs(self.m_stActivity.m_GameLevel) do
    v.activityId = activityId
    table.insert(arry, v)
  end
  table.sort(arry, function(a, b)
    return a.iLevelId < b.iLevelId
  end)
  self.m_Grid:ShowItemList(arry)
  local len = table.size(self.m_stActivity.m_lvStatusData)
  self.m_Grid:LocateTo(len - 1)
  self:ShowItemListAnim()
end

function ActivityMinigameFlopCardSubPanel:ShowItemListAnim()
  local ItemList = self.m_Grid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  for i, Item in ipairs(ItemList) do
    local tempObj = Item:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.051 * (i - 1), 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, "m_card_item_in")
    end)
  end
end

function ActivityMinigameFlopCardSubPanel:OnBtntaskClicked()
  local param = {
    act = self.m_stActivity
  }
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_WARMUP_TASK, param)
end

function ActivityMinigameFlopCardSubPanel:OnItemClk(m_itemData, m_itemIndex, is_select)
end

return ActivityMinigameFlopCardSubPanel
