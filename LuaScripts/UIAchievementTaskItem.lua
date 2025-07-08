local UIItemBase = require("UI/Common/UIItemBase")
local UIAchievementTaskItem = class("UIAchievementTaskItem", UIItemBase)

function UIAchievementTaskItem:OnInit()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function UIAchievementTaskItem:OnFreshData()
  UILuaHelper.SetColor(self.m_itemRootObj, 255, 255, 255, 1)
  local cg = self.m_task_info_node:GetComponent("CanvasGroup")
  if cg then
    cg.alpha = 1
  end
  self.m_rewardItemList = {}
  self:SetTaskInfo(self.m_itemData)
end

function UIAchievementTaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local iNum = serverData.vCondStep[1] or 0
  if iNum == TaskManager.TaskStepOver then
    iNum = itemCfg.m_ObjectiveCount
  end
  local completed = serverData.iState or 1
  self.m_txt_content_Text.text = tostring(TaskManager:GetTaskNameById(itemCfg.m_ID, itemCfg))
  self.m_txt_number_Text.text = tostring(itemCfg.m_Score)
  self.m_num_percentage_Text.text = string.format(ConfigManager:GetCommonTextById(100077), iNum, itemCfg.m_ObjectiveCount)
  self.m_img_line_b_Image.fillAmount = iNum / itemCfg.m_ObjectiveCount
  self:SetBtnState(completed)
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

function UIAchievementTaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = TaskManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_ID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_z_txt_Incomplete:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_btn_complete:SetActive(TaskManager.TaskState.Completed == state)
  self.m_img_complete_bg_b:SetActive(TaskManager.TaskState.Completed == state)
  self.m_num_percentage:SetActive(TaskManager.TaskState.Doing == state)
end

function UIAchievementTaskItem:OnBtngoClicked()
  local cfg = TaskManager:GetTaskCfgById(self.m_itemData.cfg.m_ID)
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TASK)
  end
end

function UIAchievementTaskItem:OnBtnreceiveClicked()
  TaskManager:ReqTakeReward(self.m_itemData.serverData.iType, self.m_itemData.cfg.m_ID)
  self:RefreshItemFx()
end

function UIAchievementTaskItem:RefreshItemFx()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "m_task_item_Get_to")
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(0.5)
  sequence:OnComplete(function()
    if not utils.isNull(self.m_itemRootObj) then
      UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "m_task_item_Get_in")
    end
  end)
  sequence:SetAutoKill(true)
end

function UIAchievementTaskItem:OnRewardItemClk(index, go)
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

return UIAchievementTaskItem
