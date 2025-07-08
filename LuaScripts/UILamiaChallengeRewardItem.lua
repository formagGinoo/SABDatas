local UIItemBase = require("UI/Common/UIItemBase")
local UILamiaChallengeRewardItem = class("UILamiaChallengeRewardItem", UIItemBase)

function UILamiaChallengeRewardItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelCfg = nil
  self.m_FirstItemWidgetList = {}
  local itemWidget = self:createCommonItem(self.m_reward_item)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  self.m_itemNameStr = self.m_reward_item.name
  self.m_reward_item.name = self.m_itemNameStr .. 1
  self.m_FirstItemWidgetList[#self.m_FirstItemWidgetList + 1] = itemWidget
  self.m_ItemRewardWidgetList = {}
end

function UILamiaChallengeRewardItem:OnFreshData()
  self.m_levelCfg = self.m_itemData
  self:FreshItemUI()
end

function UILamiaChallengeRewardItem:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  UILuaHelper.SetActive(self.m_img_type1, self.m_itemIndex % 2 == 0)
  UILuaHelper.SetActive(self.m_img_type2, self.m_itemIndex % 2 == 1)
  self.m_txt_level_Text.text = self.m_levelCfg.m_LevelRef
  self:FreshFirstRewardItems(self.m_levelCfg.m_FirstBonus)
  self:FreshRewardItems(self.m_levelCfg.m_Rewards)
end

function UILamiaChallengeRewardItem:FreshFirstRewardItems(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_FirstItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_first_reward
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_reward_item, parentTrans.transform).gameObject
      itemObj.name = self.m_itemNameStr .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
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

function UILamiaChallengeRewardItem:FreshRewardItems(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_ItemRewardWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_reward_item, parentTrans.transform).gameObject
      itemObj.name = self.m_itemNameStr .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
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

function UILamiaChallengeRewardItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UILamiaChallengeRewardItem
