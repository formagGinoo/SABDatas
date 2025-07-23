local UIItemBase = require("UI/Common/UIItemBase")
local UIWhackMoleTaskItem = class("UIWhackMoleTaskItem", UIItemBase)

function UIWhackMoleTaskItem:OnInit()
end

function UIWhackMoleTaskItem:OnFreshData()
  self.m_taskCfg = self.m_itemData.cfg
  self.m_txt_taskName_Text.text = self.m_taskCfg.m_mTaskName
  local taskState = self.m_itemData.serverData.iState
  UILuaHelper.SetActive(self.m_pnl_uncomplete, not taskState or taskState == TaskManager.TaskState.Doing)
  UILuaHelper.SetActive(self.m_btn_receive, taskState == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(self.m_task_already, taskState == TaskManager.TaskState.Completed)
  local rewardList = utils.changeCSArrayToLuaTable(self.m_taskCfg.m_Reward)
  for i, v in ipairs(rewardList) do
    local widget = self:createCommonItem(self.m_item_task)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    })
    widget:SetItemInfo(processData)
    widget:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  end
  local step = self.m_itemData.serverData.vCondStep[1]
  local total = self.m_taskCfg.m_ObjectiveCount
  local ratio = step / total
  self.m_img_slider_Image.fillAmount = 1 < ratio and 1 or ratio
  self.m_txt_tasknum_Text.text = step .. "/" .. total
end

function UIWhackMoleTaskItem:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function UIWhackMoleTaskItem:OnBtnreceiveClicked()
  HeroActivityManager:ReqLamiaGameQuestGetAwardCS(self.m_itemData.activeId, self.m_itemData.serverData.iId)
end

return UIWhackMoleTaskItem
