local UIItemBase = require("UI/Common/UIItemBase")
local UIRankRewardItem = class("UIRankRewardItem", UIItemBase)

function UIRankRewardItem:OnInit()
  local itemTrans = self.m_itemRootObj.transform
  self.m_rewardObj = self.m_itemTemplateCache:GameObject("c_reward_item1")
  self.m_txt_num_Text = self.m_itemTemplateCache:TMPPro("c_txt_num1")
  self.m_multiColor = self.m_txt_num_Text:GetComponent("MultiColorChange")
end

function UIRankRewardItem:OnFreshData()
  local cfg = self.m_itemData
  local data = utils.changeCSArrayToLuaTable(cfg.m_Reward)[1]
  local reward_item = self:createCommonItem(self.m_rewardObj)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data[1],
    iNum = data[2]
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
  local cur_count = GlobalRankManager:GetCollectRankNum()[cfg.m_Rank] or 0
  reward_item:SetItemHaveGetActive(cur_count >= cfg.m_Number)
  self.m_multiColor:SetColorByIndex(cur_count >= cfg.m_Number and 0 or 1)
  self.m_txt_num_Text.text = cfg.m_Number
end

return UIRankRewardItem
