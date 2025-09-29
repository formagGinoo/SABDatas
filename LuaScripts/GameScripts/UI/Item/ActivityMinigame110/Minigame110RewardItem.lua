local UIItemBase = require("UI/Common/UIItemBase")
local Minigame110RewardItem = class("Minigame110RewardItem", UIItemBase)

function Minigame110RewardItem:OnInit()
  self.m_rewardGroupCfg = nil
  local itemWidget = self:createCommonItem(self.m_reward_item)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  self.m_itemNameStr = self.m_reward_item.name
  self.m_reward_item.name = self.m_itemNameStr .. 1
  self.m_ItemRewardWidgetList = {}
  self.m_ItemRewardWidgetList[#self.m_ItemRewardWidgetList + 1] = itemWidget
  self.m_multiColorChange = self.m_txt_level:GetComponent("MultiColorChange")
end

function Minigame110RewardItem:OnFreshData()
  self.m_rewardGroupCfg = self.m_itemData.cfg
  self.m_iState = self.m_itemData.state
  self.m_isLast = self.m_itemData.isLast
  self:FreshRewardList()
end

function Minigame110RewardItem:FreshRewardList()
  if not self.m_rewardGroupCfg then
    return
  end
  local rewardList = utils.changeCSArrayToLuaTable(self.m_rewardGroupCfg.m_Rewards)
  UILuaHelper.SetActive(self.m_pnl_get, self.m_iState == 1)
  UILuaHelper.SetActive(self.m_pnl_unget, self.m_iState == 2)
  UILuaHelper.SetActive(self.m_txt_level, self.m_iState ~= 3)
  UILuaHelper.SetActive(self.m_img_bg_sel, self.m_iState ~= 3)
  UILuaHelper.SetActive(self.m_img_bg_grey, self.m_iState == 3)
  UILuaHelper.SetActive(self.m_pnl_lock, self.m_iState == 3)
  if self.m_iState ~= 3 then
    self.m_txt_level_Text.text = self.m_rewardGroupCfg.m_KeyLevel
    self.m_txt_reward1_Text.text = self.m_rewardGroupCfg.m_mDesc
  else
    self.m_txt_reward_Text.text = self.m_rewardGroupCfg.m_mDesc
  end
  local hasReward = table.getn(rewardList) > 0
  UILuaHelper.SetActive(self.m_reward_root, hasReward)
  if hasReward then
    self:FreshRewardItems(rewardList)
  end
  UILuaHelper.SetActive(self.m_line_gary, not self.m_isLast)
  UILuaHelper.SetActive(self.m_line, not self.m_isLast)
end

function Minigame110RewardItem:FreshRewardItems(rewardList)
  if not rewardList then
    return
  end
  if not rewardList or #rewardList <= 0 then
    return
  end
  local itemWidgets = self.m_ItemRewardWidgetList
  local dataLen = #rewardList
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemData = rewardList[i]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemData[1]),
        iNum = tonumber(itemData[2])
      }, {
        is_have_get = self.m_iState == 1
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_reward_item, parentTrans.transform).gameObject
      itemObj.name = self.m_itemNameStr .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemData = rewardList[i]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemData[1]),
        iNum = tonumber(itemData[2])
      }, {
        is_have_get = self.m_iState == 1
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function Minigame110RewardItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return Minigame110RewardItem
