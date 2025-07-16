local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroAct103TaskItem = class("UIHeroAct103TaskItem", UIItemBase)

function UIHeroAct103TaskItem:OnInit()
  self.prefabHelper = self.m_reward_node:GetComponent("PrefabHelper")
end

function UIHeroAct103TaskItem:OnFreshData()
  self:SetTaskInfo(self.m_itemData)
end

function UIHeroAct103TaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local vCondStep = serverData.vCondStep
  local iNum = vCondStep[1]
  local completed = serverData.iState or 1
  if itemCfg.m_Pin == 1 then
    self.m_bg_task_nml1specia2:SetActive(true)
    self.m_bg_task_nml2:SetActive(false)
    self.m_txt_content_sp_Text.text = tostring(itemCfg.m_mTaskName)
    self.m_txt_content_sp:SetActive(true)
    self.m_txt_content:SetActive(false)
    self.m_img_bg_bar:SetActive(true)
  else
    self.m_bg_task_nml1specia2:SetActive(false)
    self.m_bg_task_nml2:SetActive(true)
    self.m_txt_content_Text.text = tostring(itemCfg.m_mTaskName)
    self.m_txt_content_sp:SetActive(false)
    self.m_txt_content:SetActive(true)
    self.m_img_bg_bar:SetActive(false)
  end
  self.m_txt_dailyreward_progress_max_Text.text = iNum .. "/" .. itemCfg.m_ObjectiveCount
  self.m_img_bar_Image.fillAmount = iNum / itemCfg.m_ObjectiveCount
  self:SetBtnState(completed)
  local rewardList = utils.changeCSArrayToLuaTable(itemCfg.m_Reward)
  local scale
  utils.ShowPrefabHelper(self.prefabHelper, function(go, index, data)
    if not scale then
      scale = go.transform.localScale
    end
    go.transform.localScale = scale
    local rewardData = ResourceUtil:GetProcessRewardData({
      iID = data[1],
      iNum = data[2]
    })
    local commonItem = self:createCommonItem(go)
    commonItem:SetItemInfo(rewardData)
    commonItem:SetItemHaveGetActive(completed == TaskManager.TaskState.Completed)
    commonItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardItemClick(itemID, itemNum, itemCom)
    end)
  end, rewardList)
end

function UIHeroAct103TaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = HeroActivityManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_UID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_pnl_uncomplete2:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_img_tag_done:SetActive(TaskManager.TaskState.Completed == state)
  self.m_UIFX_special_loop:SetActive(TaskManager.TaskState.Finish == state)
  self.m_UIFX_task_nml_loop2:SetActive(TaskManager.TaskState.Finish == state)
end

function UIHeroAct103TaskItem:OnBtngoClicked()
  local cfg = self.m_itemData.cfg
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITY101LAMIA_TASK)
  end
end

function UIHeroAct103TaskItem:OnBtnreceiveClicked()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "luoleilai_achievement_task_to")
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.timer = TimeService:SetTimer(0.15, 1, function()
    HeroActivityManager:ReqLamiaQuestGetAwardCS(self.m_itemData.activeId, self.m_itemData.cfg.m_UID)
  end)
end

function UIHeroAct103TaskItem:dispose()
  UIHeroAct103TaskItem.super.dispose(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.needPlayAni = false
end

function UIHeroAct103TaskItem:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

return UIHeroAct103TaskItem
