local UIItemBase = require("UI/Common/UIItemBase")
local Minigame108TaskItem = class("Minigame108TaskItem", UIItemBase)

function Minigame108TaskItem:OnInit()
  self.m_btnClickBtn = self.m_btnClick:GetComponent("ButtonExtensions")
  if self.m_btnClickBtn then
    self.m_btnClickBtn.Clicked = handler(self, self.ShowItemTips)
  end
end

function Minigame108TaskItem:OnFreshData()
  self.m_taskCfg = self.m_itemData.cfg
  self.m_taskState = self.m_itemData.serverData.iState
  self.m_stepRewardsList = utils.changeCSArrayToLuaTable(self.m_taskCfg.m_Reward)
  self.m_stepRewards = self.m_stepRewardsList[1]
  self:FreshUI()
end

function Minigame108TaskItem:FreshUI()
  self.m_txt_taskName_Text.text = self.m_taskCfg.m_mTaskName
  ResourceUtil:CreatIconById(self.m_item_Image, self.m_stepRewards[1])
  local isMiniGameItem = ResourceUtil:GetResourceTypeById(self.m_stepRewards[1]) == ResourceUtil.RESOURCE_TYPE.MiniGame108Item
  self.m_bg_component:SetActive(isMiniGameItem)
  self.m_txt_num_Text.text = tostring(self.m_stepRewards[2])
  local step = self.m_itemData.serverData.vCondStep[1]
  local total = self.m_taskCfg.m_ObjectiveCount
  local ratio = step / total
  self.m_img_slider_Image.fillAmount = 1 < ratio and 1 or ratio
  self.m_txt_tasknum_Text.text = step .. "/" .. total
  UILuaHelper.SetActive(self.m_pnl_uncomplete, not self.m_taskState or self.m_taskState == TaskManager.TaskState.Doing)
  UILuaHelper.SetActive(self.m_btn_receive, self.m_taskState == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(self.m_task_already, self.m_taskState == TaskManager.TaskState.Completed)
end

function Minigame108TaskItem:OnBtnreceiveClicked()
  HeroActivityManager:ReqLamiaGameQuestGetAwardCS(self.m_itemData.activeId, self.m_itemData.serverData.iId)
end

function Minigame108TaskItem:ShowItemTips()
  if self.m_stepRewards[1] then
    utils.openItemDetailPop({
      iID = self.m_stepRewards[1],
      iNum = self.m_stepRewards[2]
    })
  end
end

return Minigame108TaskItem
