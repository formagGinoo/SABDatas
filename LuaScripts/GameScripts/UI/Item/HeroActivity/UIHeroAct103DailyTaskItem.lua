local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroAct103DailyTaskItem = class("UIHeroAct103DailyTaskItem", UIItemBase)

function UIHeroAct103DailyTaskItem:OnInit()
end

function UIHeroAct103DailyTaskItem:OnFreshData()
  self:SetTaskInfo(self.m_itemData)
end

function UIHeroAct103DailyTaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local vCondStep = serverData.vCondStep
  local iNum = vCondStep[1]
  local completed = serverData.iState or 1
  self.m_txt_content1_Text.text = tostring(itemCfg.m_mTaskName)
  self.m_txt_contentnum1_Text.text = iNum .. "/" .. itemCfg.m_ObjectiveCount
  self.m_txt_point_Text.text = itemCfg.m_Score
  self:SetBtnState(completed)
end

function UIHeroAct103DailyTaskItem:SetBtnState(state)
  self.m_btn_receive1:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = HeroActivityManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_UID)
  self.m_btn_go1:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_img_tag_done1:SetActive(TaskManager.TaskState.Completed == state)
  self.m_UIFX_task_nml_loop1:SetActive(TaskManager.TaskState.Finish == state)
end

function UIHeroAct103DailyTaskItem:OnBtngo1Clicked()
  local cfg = self.m_itemData.cfg
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITY101LAMIA_TASK)
  end
end

function UIHeroAct103DailyTaskItem:OnBtnreceive1Clicked()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "luoleilai_achievement_task_to")
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.timer = TimeService:SetTimer(0.15, 1, function()
    HeroActivityManager:ReqLamiaDailyQuestGetAwardCS(self.m_itemData.activeId, {
      self.m_itemData.cfg.m_UID
    })
  end)
end

function UIHeroAct103DailyTaskItem:dispose()
  UIHeroAct103DailyTaskItem.super.dispose(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.needPlayAni = false
end

function UIHeroAct103DailyTaskItem:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

return UIHeroAct103DailyTaskItem
