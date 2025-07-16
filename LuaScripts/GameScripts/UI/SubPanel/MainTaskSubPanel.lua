local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MainTaskSubPanel = class("MainTaskSubPanel", UISubPanelBase)

function MainTaskSubPanel:OnInit()
end

function MainTaskSubPanel:OnActivePanel()
  self:AddEventListeners()
end

function MainTaskSubPanel:OnHidePanel()
  self:RemoveAllEventListeners()
end

function MainTaskSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Task_Change_State", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_Group_Main_Task_Reward", handler(self, self.OnLastTaskGroupGetReward))
  self:addEventListener("eGameEvent_Task_GetRewardFailed", handler(self, self.OnFreshData))
end

function MainTaskSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function MainTaskSubPanel:OnFreshData()
  self:refreshLoopScroll()
end

function MainTaskSubPanel:OnLastTaskGroupGetReward()
  local isOver = TaskManager:CheckMainTaskGroupIsOver(TaskManager:GetCurMainTaskGroupId())
  if isOver then
    self:refreshLoopScroll()
    TaskManager:CheckMainTaskRedDot()
  end
end

function MainTaskSubPanel:OnEventGetReward()
  self:OnFreshData()
end

function MainTaskSubPanel:refreshLoopScroll()
  local data = TaskManager:GetMainTaskGroupItemData()
  if #data == 0 then
    self.m_empty_maintask:SetActive(true)
    self.m_task_list:SetActive(false)
    self.m_bg_getall_grey:SetActive(true)
    self.m_bg_getall_normal:SetActive(false)
    return
  else
    self.m_empty_maintask:SetActive(false)
    self.m_task_list:SetActive(true)
  end
  local all_cell_size = {}
  for i, v in ipairs(data or {}) do
    if v.showGroup and not v.receiveMainGroupReward then
      all_cell_size[i] = Vector2.New(1830, 422)
    elseif v.receiveMainGroupReward then
      all_cell_size[i] = Vector2.New(1830, 206)
    else
      all_cell_size[i] = Vector2.New(1830, 216)
    end
  end
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_task_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      all_cell_size = all_cell_size,
      init_cell = function(index, cell_object)
        local initGridData = {
          itemClkBackFun = handler(self, self.OnRewardItemClk)
        }
        self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
        self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
      end,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "m_btn_go" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
          local cfg = TaskManager:GetTaskCfgById(cell_data.cfg.m_ID)
          if cfg and cfg.m_Jump then
            QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
            StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TASK)
          end
        elseif click_name == "m_btn_receive" then
          TaskManager:ReqTakeReward(TaskManager.TaskType.MainTask, cell_data.cfg.m_ID)
        elseif click_name == "m_btn_group_receive" then
          TaskManager:ReqTakeMainGroupReward()
        elseif click_name == "m_btn_receivetitle" then
          TaskManager:ReqTakeMainGroupReward()
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data, nil, all_cell_size)
  end
  if GuideManager:CheckGuideIsActive(83) then
    self.m_task_list:GetComponent("ScrollRect").enabled = false
  else
    self.m_task_list:GetComponent("ScrollRect").enabled = true
  end
  local idList, canGetMainGroupTaskReward = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.MainTask)
  self.m_bg_getall_normal:SetActive(0 < #idList or canGetMainGroupTaskReward)
  self.m_bg_getall_grey:SetActive(#idList == 0 and not canGetMainGroupTaskReward)
end

function MainTaskSubPanel:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local itemCfg = cell_data.cfg
  local serverData = cell_data.serverData
  if serverData then
    local iNum = serverData.vCondStep[1] or 0
    local completed = serverData.iState or 1
    if iNum == TaskManager.TaskStepOver then
      iNum = itemCfg.m_ObjectiveCount
    end
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_content", tostring(TaskManager:GetTaskNameById(itemCfg.m_ID, itemCfg)))
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_num_percentage", string.format(ConfigManager:GetCommonTextById(20048), iNum, itemCfg.m_ObjectiveCount))
    LuaBehaviourUtil.setImgFillAmount(luaBehaviour, "m_img_line_b", iNum / itemCfg.m_ObjectiveCount)
    self:SetBtnState(luaBehaviour, completed, cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_item_lock", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_btn", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_line_a", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_complete_bg_a_mask", false)
  else
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_content", ConfigManager:GetCommonTextById(20202))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_item_lock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_btn", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_line_a", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_complete_bg_a_mask", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_group_receive", cell_data.receiveMainGroupReward)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_receivetitle", cell_data.receiveMainGroupReward)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_Incompletetitle", not cell_data.receiveMainGroupReward)
  end
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_title", cell_data.showGroup)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_task_item", not cell_data.receiveMainGroupReward)
  self:RefreshTitle(luaBehaviour, cell_data)
  local rewardList = utils.changeCSArrayToLuaTable(itemCfg.m_Reward)
  self:CreateRewardItem(luaBehaviour, "m_common_item", rewardList)
  if cell_data.showGroup then
    local rewardCfg = cell_data.rewardCfg
    if rewardCfg then
      local groupRewardList = utils.changeCSArrayToLuaTable(rewardCfg.m_Reward)
      self:CreateRewardItem(luaBehaviour, "m_common_itemtitle", groupRewardList)
    end
  end
end

function MainTaskSubPanel:CreateRewardItem(luaBehaviour, itemName, rewardList)
  local iRewardCount = math.min(#rewardList, 3)
  for iRewardIndex = 1, iRewardCount do
    local stReward = rewardList[iRewardIndex]
    local panelRewardItem = luaBehaviour:FindGameObject(itemName .. iRewardIndex)
    panelRewardItem.gameObject:SetActive(true)
    self:removeWidget(panelRewardItem.gameObject)
    local commonItem = self:createCommonItem(panelRewardItem.gameObject)
    local processData = ResourceUtil:GetProcessRewardData(stReward)
    commonItem:SetItemInfo(processData)
    commonItem:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  end
  for iRewardIndex = iRewardCount + 1, 3 do
    local panelRewardItem = luaBehaviour:FindGameObject(itemName .. iRewardIndex)
    panelRewardItem.gameObject:SetActive(false)
  end
end

function MainTaskSubPanel:RefreshTitle(luaBehaviour, itemData)
  if itemData.showGroup then
    local cfg = TaskManager:GetMainTaskRewardCfgById(itemData.groupId)
    if not cfg:GetError() then
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_level_num", tostring(cfg.m_Title))
      local taskCount = cfg.m_TaskList.Length
      local count = TaskManager:GetMainTaskOverByGroup(itemData.groupId)
      LuaBehaviourUtil.setImgFillAmount(luaBehaviour, "m_slider_task", count / taskCount)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_dot1", 0 < count)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_dot2", count == taskCount)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_bghard", count == taskCount)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_level_normal", tostring(cfg.m_mName))
      local str = string.format(ConfigManager:GetCommonTextById(20048), count, taskCount)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_slidernum", count == taskCount and str or "")
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_slidernumgrey", count ~= taskCount and str or "")
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_done", count == taskCount)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_get", itemData.serverData and count ~= taskCount)
    end
  end
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_title_lock", not itemData.serverData and not itemData.receiveMainGroupReward)
end

function MainTaskSubPanel:SetBtnState(luaBehaviour, state, cell_data)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_receive", TaskManager.TaskState.Finish == state)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_complete", TaskManager.TaskState.Completed == state)
  local canJump = TaskManager:CheckTaskIsCanJump(cell_data.cfg.m_ID)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_go", TaskManager.TaskState.Doing == state and canJump)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_group_receive", cell_data.receiveMainGroupReward)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_receivetitle", cell_data.receiveMainGroupReward)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_Incompletetitle", not cell_data.receiveMainGroupReward)
end

function MainTaskSubPanel:OnItemIconClicked(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function MainTaskSubPanel:OnBtngetallClicked()
  local idList, canGetMainGroupTaskReward = TaskManager:GetCanCollectedTaskIdsByType(TaskManager.TaskType.MainTask)
  if idList and 0 < #idList then
    TaskManager:ReqTakeReward(TaskManager.TaskType.MainTask, idList)
  elseif canGetMainGroupTaskReward then
    TaskManager:ReqTakeMainGroupReward()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20041)
  end
end

return MainTaskSubPanel
