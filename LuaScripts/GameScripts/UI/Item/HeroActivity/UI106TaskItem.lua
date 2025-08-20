local UIItemBase = require("UI/Item/HeroActivity/UIHeroActTaskItem")
local UI106TaskItem = class("UI106TaskItem", UIItemBase)

function UI106TaskItem:OnInit()
  UI106TaskItem.super.OnInit(self)
  self.sAniIn = "luoleilai_achievement_task_in"
  self.sAniOut = "luoleilai_achievement_task_to"
end

function UI106TaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = HeroActivityManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_UID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_pnl_uncomplete2:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_img_tag_done:SetActive(TaskManager.TaskState.Completed == state)
end

return UI106TaskItem
