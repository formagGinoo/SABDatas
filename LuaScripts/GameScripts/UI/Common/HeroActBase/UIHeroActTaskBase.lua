local UIHeroActTaskBase = class("UIHeroActTaskBase", require("UI/Common/UIBase"))

function UIHeroActTaskBase:AfterInit()
  UIHeroActTaskBase.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "HeroActivity/UIHeroActTaskItem")
  self.m_widgetItemIcon1 = self:createCommonItem(self.m_common_item1_sp)
  self.m_widgetItemIcon2 = self:createCommonItem(self.m_common_item2_sp)
  self.m_isInit = true
end

function UIHeroActTaskBase:OnActive()
  UIHeroActTaskBase.super.OnActive(self)
  self.m_actId = self.m_csui.m_param.main_id
  self.m_subId = self.m_csui.m_param.sub_id
  self.m_cfgList, self.m_pinCfgList = HeroActivityManager:GetActTaskCfgByActiveId(self.m_actId)
  self.m_pinTaskData = nil
  self.m_isActive = true
  self:RefreshUI()
  CS.UnityEngine.PlayerPrefs.SetInt("Activity101Lamia_Task", TimeUtil:GetServerTimeS())
  self:AddEventListeners()
  self:ShowCutDownTime()
end

function UIHeroActTaskBase:OnInactive()
  UIHeroActTaskBase.super.OnInactive(self)
  if self.m_TaskListInfinityGrid then
    self.m_TaskListInfinityGrid:dispose()
  end
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
  self:RemoveAllEventListeners()
end

function UIHeroActTaskBase:AddEventListeners()
  self:addEventListener("eGameEvent_ActTask_GetReward", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_ActTask_GetAllReward", handler(self, self.RefreshUI))
end

function UIHeroActTaskBase:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIHeroActTaskBase:CheckShowEnterAnim()
  local ItemList = self.m_TaskListInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  if self.m_isInit then
    TimeService:SetTimer(0.6, 1, function()
      self:ShowItemListAnim()
    end)
    self.m_isInit = false
  elseif self.m_isActive then
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
    self.m_isActive = false
  else
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
  end
end

function UIHeroActTaskBase:ShowItemListAnim()
  local ItemList = self.m_TaskListInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  for i, Item in ipairs(ItemList) do
    local tempObj = Item:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.1 * (i - 1), 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, "Lamiri_Task_scrollview_in")
    end)
  end
end

function UIHeroActTaskBase:RefreshUI()
  local taskDataList = HeroActivityManager:GetActTaskData(self.m_actId, self.m_cfgList)
  self.m_TaskListInfinityGrid:ShowItemList(taskDataList)
  self:CheckShowEnterAnim()
  self.m_TaskListInfinityGrid:LocateTo(0)
  local pinTaskDataList = HeroActivityManager:GetActTaskData(self.m_actId, self.m_pinCfgList)
  
  local function sortFun(data1, data2)
    local cfg1 = data1.cfg
    local cfg2 = data2.cfg
    local sort1 = cfg1.m_Sort
    local sort2 = cfg2.m_Sort
    if sort1 == sort2 then
      return cfg1.m_UID < cfg2.m_UID
    else
      return sort1 < sort2
    end
  end
  
  table.sort(pinTaskDataList, sortFun)
  self.m_pinTaskData = nil
  for i, v in ipairs(pinTaskDataList) do
    local preTaskState = HeroActivityManager:CheckTaskStateByTaskId(self.m_actId, v.cfg.m_PreTask)
    if (v.serverData.iState ~= TaskManager.TaskState.Completed or v.serverData.iState == TaskManager.TaskState.Completed and v.cfg.m_Invisible ~= 1) and preTaskState == TaskManager.TaskState.Completed then
      self.m_pinTaskData = v
    end
  end
  if self.m_pinTaskData then
    local pinTaskCfg = self.m_pinTaskData.cfg
    local pinTaskserverData = self.m_pinTaskData.serverData
    self.m_txt_content_sp_Text.text = pinTaskCfg.m_mTaskName
    local rewardList = utils.changeCSArrayToLuaTable(pinTaskCfg.m_Reward)
    for i = 1, 2 do
      if rewardList[i] then
        self["m_common_item" .. i .. "_sp"]:SetActive(true)
        local itemData = ResourceUtil:GetProcessRewardData({
          iID = rewardList[i][1],
          iNum = rewardList[i][2]
        })
        self["m_widgetItemIcon" .. i]:SetItemInfo(itemData)
        self["m_widgetItemIcon" .. i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          self:OnRewardItemClick(itemID, itemNum, itemCom)
        end)
      else
        self["m_common_item" .. i .. "_sp"]:SetActive(false)
      end
    end
    local vCondStep = pinTaskserverData.vCondStep
    local iNum = vCondStep[1]
    local completed = pinTaskserverData.iState or 1
    self.m_txt_dailyreward_progress_max_Text.text = iNum .. "/" .. pinTaskCfg.m_ObjectiveCount
    self.m_img_bar_progress_Image.fillAmount = iNum / pinTaskCfg.m_ObjectiveCount
    self:SetBtnState(completed)
  else
    log.error("pinTaskData is error")
  end
  local flag = HeroActivityManager:CheckTaskCanReceive(self.m_actId)
  self.m_bg_getall_normal:SetActive(flag)
  self.m_bg_getall_grey:SetActive(not flag)
end

function UIHeroActTaskBase:ShowCutDownTime()
  local sub_config = HeroActivityManager:GetSubInfoByID(self.m_subId)
  local endTime = TimeUtil:TimeStringToTimeSec2(sub_config.m_EndTime) or 0
  local curTimer = TimeUtil:GetServerTimeS()
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, self.m_subId)
  if is_corved then
    endTime = t2
  end
  local left_time = endTime - curTimer
  if left_time <= 0 then
    self.m_txt_time_Text.text = ""
    return
  end
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  self.m_timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.m_timer)
      self:OnBackClk()
    end
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  end)
end

function UIHeroActTaskBase:SetBtnState(state)
  self.m_btn_receive_sp:SetActive(TaskManager.TaskState.Finish == state)
  self.m_UIFX_special_loop:SetActive(TaskManager.TaskState.Finish == state)
  self.m_widgetItemIcon1:SetItemHaveGetActive(TaskManager.TaskState.Completed == state)
  self.m_widgetItemIcon2:SetItemHaveGetActive(TaskManager.TaskState.Completed == state)
end

function UIHeroActTaskBase:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

function UIHeroActTaskBase:OnDestroy()
  UIHeroActTaskBase.super.OnDestroy(self)
  if self.m_TaskListInfinityGrid then
    self.m_TaskListInfinityGrid:dispose()
    self.m_TaskListInfinityGrid = nil
  end
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

function UIHeroActTaskBase:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function UIHeroActTaskBase:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:PopAll()
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function UIHeroActTaskBase:OnBtngetallClicked()
  local flag = HeroActivityManager:CheckTaskCanReceive(self.m_actId)
  if flag then
    HeroActivityManager:ReqLamiaQuestGetAllAwardCS(self.m_actId)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20018))
  end
end

function UIHeroActTaskBase:OnBtnreceivespClicked()
  HeroActivityManager:ReqLamiaQuestGetAwardCS(self.m_actId, self.m_pinTaskData.cfg.m_UID)
end

function UIHeroActTaskBase:IsOpenGuassianBlur()
  return true
end

return UIHeroActTaskBase
