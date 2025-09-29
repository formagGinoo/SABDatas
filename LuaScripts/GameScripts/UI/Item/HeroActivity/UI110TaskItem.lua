local UIItemBase = require("UI/Item/HeroActivity/UIHeroActTaskItem")
local UI110TaskItem = class("UI110TaskItem", UIItemBase)

function UI110TaskItem:OnInit()
  UI110TaskItem.super.OnInit(self)
  self.sAniIn = "luoleilai_achievement_task_in"
  self.sAniOut = "luoleilai_achievement_task_to"
end

function UI110TaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = HeroActivityManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_UID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_pnl_uncomplete2:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_img_tag_done:SetActive(TaskManager.TaskState.Completed == state)
  self.m_UIFX_task_nml_loop:SetActive(TaskManager.TaskState.Finish == state)
end

return UI110TaskItem
