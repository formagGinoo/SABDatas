local UIItemBase = require("UI/Common/UIItemBase")
local UIWhackMoleTaskItem = class("UIWhackMoleTaskItem", UIItemBase)

function UIWhackMoleTaskItem:OnInit()
  self.itemTempCache = self.m_rewardItemList.transform:Find("c_common_item").gameObject
  UILuaHelper.SetActive(self.itemTempCache, false)
end

function UIWhackMoleTaskItem:OnFreshData()
  self.m_taskCfg = self.m_itemData.cfg
  self.m_txt_taskName_Text.text = self.m_taskCfg.m_mTaskName
  UILuaHelper.SetActive(self.m_btn_receive, self.m_itemData.serverData.state == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(self.m_task_already, self.m_itemData.serverData.state == TaskManager.TaskState.Completed)
  local rewardList = utils.changeCSArrayToLuaTable(self.m_taskCfg.m_Reward)
  local reward = rewardList
  local parentTran = self.m_rewardItemList.transform
  local childCount = parentTran.childCount
  for i = 0, childCount - 1 do
    local child = parentTran:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local elementCount = #reward
  for i = childCount, elementCount - 1 do
    GameObject.Instantiate(self.itemTempCache, parentTran)
  end
  for i, v in ipairs(reward) do
    local child = parentTran:GetChild(i - 1).gameObject
    UILuaHelper.SetActive(child, true)
    local widget = self:createCommonItem(child)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    })
    widget:SetItemInfo(processData)
    widget:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
  end
end

function UIWhackMoleTaskItem:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function UIWhackMoleTaskItem:OnBtnreceiveClicked()
  HeroActivityManager:ReqLamiaQuestGetAwardCS(self.m_itemData.activeId, self.m_itemData.serverData.iId)
end

return UIWhackMoleTaskItem
