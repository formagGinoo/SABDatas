local UIItemBase = require("UI/Common/UIItemBase")
local UIMainTaskItem = class("UIMainTaskItem", UIItemBase)

function UIMainTaskItem:OnInit()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function UIMainTaskItem:OnFreshData()
  self.m_rewardItemList = {}
  self:SetTaskInfo(self.m_itemData)
end

function UIMainTaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData
  if serverData then
    local iNum = serverData.vCondStep[1] or 0
    local completed = serverData.iState or 1
    if iNum == TaskManager.TaskStepOver then
      iNum = itemCfg.m_ObjectiveCount
    end
    self.m_txt_content_Text.text = tostring(itemCfg.m_mTaskName)
    self.m_num_percentage_Text.text = string.format(ConfigManager:GetCommonTextById(20048), iNum, itemCfg.m_ObjectiveCount)
    self.m_img_line_b_Image.fillAmount = iNum / itemCfg.m_ObjectiveCount
    self:SetBtnState(completed)
    self.m_img_item_lock:SetActive(false)
    self.m_pnl_btn:SetActive(true)
    self.m_img_line_a:SetActive(true)
  else
    self.m_txt_content_Text.text = "???"
    self.m_img_item_lock:SetActive(true)
    self.m_pnl_btn:SetActive(false)
    self.m_img_line_a:SetActive(false)
  end
  self.m_pnl_title:SetActive(itemData.showGroup)
  if itemData.showGroup then
    self:RefreshTitle(itemData)
  end
  local rewardList = utils.changeCSArrayToLuaTable(itemCfg.m_Reward)
  for i, v in ipairs(rewardList) do
    local rewardData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    })
    self.m_rewardItemList[#self.m_rewardItemList + 1] = rewardData
  end
  self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardItemList)
end

function UIMainTaskItem:RefreshTitle(itemData)
  self.m_img_titlebg_lock:SetActive(not itemData.serverData)
  local cfg = TaskManager:GetMainTaskRewardCfgById(itemData.groupId)
  if not cfg:GetError() then
    self.m_txt_level_num_Text.text = cfg.m_Title
    self.m_txt_level_normal_Text.text = cfg.m_mName
    local count = TaskManager:GetMainTaskOverByGroup(itemData.groupId)
    local taskCount = cfg.m_TaskList.Length
    local value = math.floor(count / taskCount * 100)
    self.m_txt_level_percent_Text.text = string.format(ConfigManager:GetCommonTextById(100009), tostring(value))
  end
  self.m_img_title_lock:SetActive(not itemData.serverData)
end

function UIMainTaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  self.m_btn_complete:SetActive(TaskManager.TaskState.Completed == state)
  local canJump = TaskManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_ID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
end

function UIMainTaskItem:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardItemList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function UIMainTaskItem:OnBtnreceiveClicked()
  if self.m_itemData then
    TaskManager:ReqTakeReward(TaskManager.TaskType.MainTask, self.m_itemData.cfg.m_ID)
  end
end

function UIMainTaskItem:OnBtngoClicked()
  local cfg = TaskManager:GetTaskCfgById(self.m_itemData.cfg.m_ID)
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TASK)
  end
end

return UIMainTaskItem
