local UIItemBase = require("UI/Common/UIItemBase")
local Act110TaskItem = class("Act110TaskItem", UIItemBase)

function Act110TaskItem:OnInit()
  local m_PrefabHelper = self.m_reward:GetComponent("PrefabHelper")
  self.m_PrefabHelper = m_PrefabHelper
end

function Act110TaskItem:OnFreshData()
  self.m_taskCfg = self.m_itemData.cfg
  self.m_stActivity = self.m_itemData.act
  self.m_rewardList = utils.changeCSArrayToLuaTable(self.m_taskCfg.m_Rewards)
  self:FreshUI()
end

function Act110TaskItem:FreshUI()
  self.m_txt_content_Text.text = self.m_taskCfg.m_mDesc
  local groupList = utils.changeCSArrayToLuaTable(self.m_taskCfg.m_ClueID)
  local groupCount = table.getn(groupList)
  local curFinish = 0
  for _, v in pairs(groupList) do
    if self.m_stActivity:IsGroupFinished(v) then
      curFinish = curFinish + 1
    end
  end
  local ratio = curFinish / groupCount
  self.m_img_slider_Image.fillAmount = 1 < ratio and 1 or ratio
  self.m_num_percentage_Text.text = curFinish .. "/" .. groupCount
  local isFinish = self.m_stActivity:IsRewardClaimed(self.m_taskCfg.m_GroupID)
  local isCanReward = ratio == 1 and not isFinish
  UILuaHelper.SetActive(self.m_z_txt_Incomplete, not isCanReward and not isFinish)
  UILuaHelper.SetActive(self.m_btn_receive, isCanReward)
  UILuaHelper.SetActive(self.m_pnl_complete, isFinish)
  self:RewardList()
end

function Act110TaskItem:OnBtnreceiveClicked()
  local groupList = {}
  groupList[self.m_taskCfg.m_GroupID] = true
  self.m_stActivity:RequestGroupRewardCS(groupList)
end

function Act110TaskItem:RewardList()
  if not utils.isNull(self.m_PrefabHelper) and self.m_rewardList and #self.m_rewardList > 0 then
    self.m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
    self.m_PrefabHelper:CheckAndCreateObjs(#self.m_rewardList)
  end
end

function Act110TaskItem:OnInitRewardItem(go, index)
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

function Act110TaskItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return Act110TaskItem
