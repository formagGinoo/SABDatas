local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroActTaskItem = class("UIHeroActTaskItem", UIItemBase)

function UIHeroActTaskItem:OnInit()
  self.m_rewardObjList = {}
  self.m_common_item:SetActive(false)
  for i = 1, 2 do
    local cloneObj = ResourceUtil:CreateItem(self.m_common_item, self.m_reward_node.transform)
    self.m_rewardObjList[#self.m_rewardObjList + 1] = {
      obj = cloneObj,
      commonItem = self:createCommonItem(cloneObj)
    }
  end
  self.sAniIn = "Lamiri_Task_scrollview_in"
  self.sAniOut = "Lamiri_Task_scrollview_to"
end

function UIHeroActTaskItem:OnFreshData()
  if self.needPlayAni then
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, self.sAniIn)
  end
  self.needPlayAni = true
  self:SetTaskInfo(self.m_itemData)
end

function UIHeroActTaskItem:SetTaskInfo(itemData)
  local itemCfg = itemData.cfg
  local serverData = itemData.serverData or {}
  local vCondStep = serverData.vCondStep
  local iNum = vCondStep[1]
  local completed = serverData.iState or 1
  self.m_txt_content_Text.text = tostring(itemCfg.m_mTaskName)
  self.m_txt_progress_cur_Text.text = iNum
  self.m_txt_progress_max_Text.text = itemCfg.m_ObjectiveCount
  if not utils.isNull(self.m_img_bar_Image) then
    self.m_img_bar_Image.fillAmount = iNum / itemCfg.m_ObjectiveCount
  end
  self:SetBtnState(completed)
  local rewardList = utils.changeCSArrayToLuaTable(itemCfg.m_Reward)
  for i = 1, 2 do
    if rewardList[i] then
      self.m_rewardObjList[i].obj:SetActive(true)
      local rewardData = ResourceUtil:GetProcessRewardData({
        iID = rewardList[i][1],
        iNum = rewardList[i][2]
      })
      self.m_rewardObjList[i].commonItem:SetItemInfo(rewardData)
      self.m_rewardObjList[i].commonItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
    else
      self.m_rewardObjList[i].obj:SetActive(false)
    end
  end
  if not utils.isNull(self.m_tag_day) then
    self.m_tag_day:SetActive(HeroActivityManager.HeroActTaskType.daily == itemCfg.m_Type)
  end
end

function UIHeroActTaskItem:SetBtnState(state)
  self.m_btn_receive:SetActive(TaskManager.TaskState.Finish == state)
  local canJump = HeroActivityManager:CheckTaskIsCanJump(self.m_itemData.cfg.m_UID)
  self.m_btn_go:SetActive(TaskManager.TaskState.Doing == state and canJump)
  self.m_z_txt_doing:SetActive(TaskManager.TaskState.Doing == state and not canJump)
  self.m_img_complete:SetActive(TaskManager.TaskState.Completed == state)
  self.m_txt_progress_cur:SetActive(TaskManager.TaskState.Doing == state)
  self.m_img_bg_bar:SetActive(TaskManager.TaskState.Doing == state)
  self.m_redpoint:SetActive(false)
  self.m_tag_new:SetActive(false)
  self.m_img_tag_done:SetActive(TaskManager.TaskState.Completed == state)
  self.m_UIFX_task_nml_loop:SetActive(TaskManager.TaskState.Finish == state)
end

function UIHeroActTaskItem:OnBtngoClicked()
  local cfg = self.m_itemData.cfg
  if cfg and cfg.m_Jump then
    QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITY101LAMIA_TASK)
  end
end

function UIHeroActTaskItem:OnBtnreceiveClicked()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, self.sAniOut)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.timer = TimeService:SetTimer(0.8, 1, function()
    HeroActivityManager:ReqLamiaQuestGetAwardCS(self.m_itemData.activeId, self.m_itemData.cfg.m_UID)
  end)
end

function UIHeroActTaskItem:dispose()
  UIHeroActTaskItem.super.dispose(self)
  if self.m_rewardObjList then
    for i, v in pairs(self.m_rewardObjList) do
      if not utils.isNull(v.obj) then
        GameObject.Destroy(v.obj)
        v.obj = nil
      end
    end
  end
  self.m_rewardObjList = nil
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.needPlayAni = false
end

function UIHeroActTaskItem:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

return UIHeroActTaskItem
