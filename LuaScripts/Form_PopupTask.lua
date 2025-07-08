local Form_PopupTask = class("Form_PopupTask", require("UI/UIFrames/Form_PopupTaskUI"))

function Form_PopupTask:SetInitParam(param)
end

function Form_PopupTask:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_taskInfoItemList = {}
  for i = 1, 3 do
    self.m_taskInfoItemList[i] = {}
    self.m_taskInfoItemList[i].taskItem = self["m_img_list_bg_" .. i]
    self.m_taskInfoItemList[i].common_item = self.m_taskInfoItemList[i].taskItem.transform:Find("c_common_item").gameObject
    self.m_taskInfoItemList[i].txt_level = self.m_taskInfoItemList[i].taskItem.transform:Find("m_txt_level"):GetComponent(T_TextMeshProUGUI)
    self.m_taskInfoItemList[i].progress_num = self.m_taskInfoItemList[i].taskItem.transform:Find("m_txt_level/m_txt_progress_num"):GetComponent(T_TextMeshProUGUI)
    self.m_taskInfoItemList[i].received_bg = self.m_taskInfoItemList[i].taskItem.transform:Find("m_received_bg").gameObject
    self.m_taskInfoItemList[i].undone_bg = self.m_taskInfoItemList[i].taskItem.transform:Find("m_undone_bg").gameObject
    self.m_taskInfoItemList[i].btn_receive = self.m_taskInfoItemList[i].taskItem.transform:Find("m_btn_receive").gameObject
    self.m_taskInfoItemList[i].btn_jump = self.m_taskInfoItemList[i].taskItem.transform:Find("m_btn_jump").gameObject
    UILuaHelper.BindButtonClickManual(self, self.m_taskInfoItemList[i].taskItem.transform:Find("m_btn_receive"):GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:OnTaskItemReceiveBtnClicked(i)
    end)
    UILuaHelper.BindButtonClickManual(self, self.m_taskInfoItemList[i].taskItem.transform:Find("m_btn_jump"):GetComponent("Button"), function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      self:OnTaskItemGoBtnClicked(i)
    end)
  end
  self.m_taskGroupRewardItemList = {}
  self.m_taskProgressPoint = {}
  self.m_taskProgressPoint2 = {}
  for i = 1, 3 do
    self.m_taskGroupRewardItemList[i] = self.m_img_award_bg.transform:Find("c_common_item" .. i).gameObject
    self.m_taskProgressPoint[i] = self["m_icon_schedule_red" .. i]
    self.m_taskProgressPoint2[i] = self["m_icon_schedule" .. i]
  end
end

function Form_PopupTask:AddEventListeners()
  self:addEventListener("eGameEvent_Task_Change_State", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_Group_Main_Task_Reward", handler(self, self.OnBtnreturnClicked))
end

function Form_PopupTask:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PopupTask:OnActive()
  self.super.OnActive(self)
  self.m_taskDataList = {}
  self:AddEventListeners()
  self:RefreshUI()
end

function Form_PopupTask:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PopupTask:OnEventGetReward()
  local isOver = TaskManager:CheckMainTaskIsOver()
  if isOver then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_POPUPTASK)
    return
  end
  self:RefreshUI()
end

function Form_PopupTask:RefreshUI()
  local dataList = TaskManager:GetMainTaskGroupItemData()
  self.m_taskDataList = dataList
  for i = 1, 3 do
    local itemData = dataList[i]
    if itemData then
      self.m_taskInfoItemList[i].taskItem:SetActive(true)
      self:SetTaskInfo(itemData, i)
    else
      self.m_taskInfoItemList[i].taskItem:SetActive(false)
    end
  end
  self:RefreshTaskGroupInfo()
end

function Form_PopupTask:RefreshTaskGroupInfo()
  local taskGroupData = TaskManager:GetMainTaskGroupData()
  local cfg = taskGroupData.cfg
  local state = taskGroupData.state
  if cfg then
    local rewardList = utils.changeCSArrayToLuaTable(cfg.m_Reward)
    for m = 1, 3 do
      local itemWidget = self:createCommonItem(self.m_taskGroupRewardItemList[m])
      if rewardList and rewardList[m] then
        local processItemData = ResourceUtil:GetProcessRewardData(rewardList[m])
        itemWidget:SetItemInfo(processItemData)
        itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          self:OnRewardItemClick(itemID, itemNum, itemCom)
        end)
        itemWidget:SetActive(true)
      else
        itemWidget:SetActive(false)
      end
    end
    self.m_txt_chapter_name_Text.text = cfg.m_mName
    self.m_txt_chapter_num_Text.text = cfg.m_Title
  end
  self.m_btn_received_group_reward:SetActive(TaskManager.TaskState.Finish == state)
  self.m_btn_unaccalimed:SetActive(TaskManager.TaskState.Doing == state)
  local num = 0
  for i, v in pairs(self.m_taskDataList) do
    if v.serverData and v.serverData.iState == TaskManager.TaskState.Completed then
      num = num + 1
    end
  end
  for i = 1, 3 do
    if i <= num then
      self.m_taskProgressPoint[i]:SetActive(true)
      self.m_taskProgressPoint2[i]:SetActive(false)
    else
      self.m_taskProgressPoint[i]:SetActive(false)
      self.m_taskProgressPoint2[i]:SetActive(true)
    end
  end
end

function Form_PopupTask:SetTaskInfo(itemData, index)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local iNum = 0
  local completed = serverData.iState or 1
  if iNum == TaskManager.TaskStepOver then
    iNum = itemCfg.m_ObjectiveCount
  end
  local taskInfoItem = self.m_taskInfoItemList[index]
  taskInfoItem.txt_level.text = tostring(itemCfg.m_mTaskName)
  taskInfoItem.progress_num.text = iNum .. "/" .. itemCfg.m_ObjectiveCount
  self:SetBtnState(completed, index, itemCfg.m_ID)
  self:RefreshReward(itemCfg.m_Reward, index)
end

function Form_PopupTask:SetBtnState(state, index, taskId)
  local taskInfoItem = self.m_taskInfoItemList[index]
  taskInfoItem.btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  taskInfoItem.received_bg:SetActive(TaskManager.TaskState.Completed == state)
  local canJump = TaskManager:CheckTaskIsCanJump(taskId)
  taskInfoItem.btn_jump:SetActive(TaskManager.TaskState.Doing == state and canJump)
  taskInfoItem.undone_bg:SetActive(TaskManager.TaskState.Doing == state and not canJump)
end

function Form_PopupTask:RefreshReward(rewards, index)
  local taskInfoItem = self.m_taskInfoItemList[index]
  local rewardList = utils.changeCSArrayToLuaTable(rewards)
  for i = 1, 1 do
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(rewardList[i][1]),
      iNum = tonumber(rewardList[i][2])
    })
    local itemWidget = require("UI/Widgets/CommonItem").new(taskInfoItem.common_item)
    itemWidget:SetItemInfo(processItemData)
    itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardItemClick(itemID, itemNum, itemCom)
    end)
  end
end

function Form_PopupTask:OnDestroy()
  self.super.OnDestroy(self)
  self.m_taskInfoItemList = {}
  self.m_taskGroupRewardItemList = {}
  self.m_taskProgressPoint = {}
  self.m_taskDataList = {}
end

function Form_PopupTask:OnTaskItemReceiveBtnClicked(index)
  if self.m_taskDataList and self.m_taskDataList[index] then
    TaskManager:ReqTakeReward(TaskManager.TaskType.MainTask, self.m_taskDataList[index].cfg.m_ID)
  end
end

function Form_PopupTask:OnTaskItemGoBtnClicked(index)
  if self.m_taskDataList and self.m_taskDataList[index] then
    local taskId = self.m_taskDataList[index].cfg.m_ID
    local cfg = TaskManager:GetTaskCfgById(taskId)
    if cfg and cfg.m_Jump then
      if cfg.m_Jump ~= 99999 then
        QuickOpenFuncUtil:OpenFunc(cfg.m_Jump, {guideTaskId = taskId})
      else
        self:broadcastEvent("eGameEvent_MainTask_Jump_Guide", {taskId = taskId})
      end
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_POPUPTASK)
    end
  end
end

function Form_PopupTask:OnBtnreceivedgrouprewardClicked()
  TaskManager:ReqTakeMainGroupReward()
end

function Form_PopupTask:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

function Form_PopupTask:OnBtnreturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_POPUPTASK)
end

function Form_PopupTask:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_POPUPTASK)
end

ActiveLuaUI("Form_PopupTask", Form_PopupTask)
return Form_PopupTask
