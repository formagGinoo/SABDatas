local UIItemBase = require("UI/Common/UIItemBase")
local UIEuipCrossTaskItem = class("UIEuipCrossTaskItem", UIItemBase)

function UIEuipCrossTaskItem:OnInit()
  if self.m_itemInitData then
    self.OnReceiveReward = self.m_itemInitData.OnReceiveReward
  end
  self.m_PrefabHelper = self.m_reward:GetComponent("PrefabHelper")
  self.m_rewardList = nil
end

function UIEuipCrossTaskItem:OnFreshData()
  UILuaHelper.SetActive(self.m_btn_receive, self.m_itemData.state == MTTDProto.QuestState_Finish)
  UILuaHelper.SetActive(self.m_pnl_complete, self.m_itemData.state == MTTDProto.QuestState_Over)
  UILuaHelper.SetActive(self.m_z_txt_Incomplete, self.m_itemData.state == MTTDProto.QuestState_Doing)
  self.m_txt_content_Text.text = TaskManager:GetTaskNameById(self.m_itemData.id)
  self.m_rewardList = self.m_itemData.rewards
  self.m_id = self.m_itemData.id
  self:FreshewardList()
end

function UIEuipCrossTaskItem:FreshewardList()
  if not utils.isNull(self.m_PrefabHelper) and self.m_rewardList and #self.m_rewardList > 0 then
    self.m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
    self.m_PrefabHelper:CheckAndCreateObjs(#self.m_rewardList)
  end
end

function UIEuipCrossTaskItem:OnInitRewardItem(go, index)
  index = index + 1
  local data = self.m_rewardList[index]
  go.transform.localScale = Vector3.one * 0.75
  local reward_item = self:createCommonItem(go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data[1],
    iNum = data[2]
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

function UIEuipCrossTaskItem:OnBtnreceiveClicked()
  self.OnReceiveReward(self.m_id)
end

return UIEuipCrossTaskItem
