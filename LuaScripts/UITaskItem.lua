local UIItemBase = require("UI/Common/UIItemBase")
local UITaskItem = class("UITaskItem", UIItemBase)

function UITaskItem:OnInit()
end

function UITaskItem:OnFreshData()
  UILuaHelper.SetColor(self.m_itemRootObj, 255, 255, 255, 1)
  local cg = self.m_task_info_node:GetComponent("CanvasGroup")
  if cg then
    cg.alpha = 1
  end
  self:SetTaskInfo(self.m_itemData)
end

function UITaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local iNum = serverData.vCondStep[1] or 0
  if iNum == TaskManager.TaskStepOver then
    iNum = itemCfg.m_ObjectiveCount
  end
  local completed = serverData.iState or 1
  self.m_txt_content_Text.text = tostring(TaskManager:GetTaskNameById(itemCfg.m_ID, itemCfg))
  self.m_txt_number_Text.text = tostring(itemCfg.m_Score)
  self.m_num_percentage_Text.text = string.format(ConfigManager:GetCommonTextById(20045), iNum, itemCfg.m_ObjectiveCount)
  self.m_img_line_b_Image.fillAmount = iNum / itemCfg.m_ObjectiveCount
  self:SetBtnState(completed)
end

function UITaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = TaskManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_ID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_z_txt_Incomplete:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_btn_complete:SetActive(TaskManager.TaskState.Completed == state)
  self.m_img_complete_bg_b:SetActive(TaskManager.TaskState.Completed == state)
end

function UITaskItem:OnBtnfinishClicked()
end

function UITaskItem:OnBtngoClicked()
  local cfg = TaskManager:GetTaskCfgById(self.m_itemData.cfg.m_ID)
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TASK)
  end
end

function UITaskItem:OnBtnreceiveClicked()
  TaskManager:ReqTakeReward(self.m_itemData.serverData.iType, self.m_itemData.cfg.m_ID)
  self.m_btn_receive:SetActive(false)
  self:RefreshItemFx()
end

function UITaskItem:RefreshItemFx()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "m_task_item_Get_to")
  local animationTime = UILuaHelper.GetAnimationLengthByName(self.m_itemRootObj, "m_task_item_Get_to")
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(animationTime)
  sequence:OnComplete(function()
    if not utils.isNull(self.m_itemRootObj) then
      UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "m_task_item_Get_in")
    end
  end)
  sequence:SetAutoKill(true)
end

return UITaskItem
