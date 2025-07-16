local UIItemBase = require("UI/Common/UIItemBase")
local UIBossRewardItem = class("UIBossRewardItem", UIItemBase)

function UIBossRewardItem:OnInit()
  self.m_dungeonLevelPhaseCfg = nil
  local itemWidget = self:createCommonItem(self.m_reward_item)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  self.m_itemNameStr = self.m_reward_item.name
  self.m_reward_item.name = self.m_itemNameStr .. 1
  self.m_ItemRewardWidgetList = {}
  self.m_ItemRewardWidgetList[#self.m_ItemRewardWidgetList + 1] = itemWidget
end

function UIBossRewardItem:OnFreshData()
  self.m_dungeonLevelPhaseCfg = self.m_itemData
  self:FreshItemUI()
end

function UIBossRewardItem:FreshItemUI()
  if not self.m_dungeonLevelPhaseCfg then
    return
  end
  self.m_txt_level_Text.text = self.m_dungeonLevelPhaseCfg.m_Phase
  self:FreshRewardList()
end

function UIBossRewardItem:FreshRewardList()
  if not self.m_dungeonLevelPhaseCfg then
    return
  end
  local rewardList = utils.changeCSArrayToLuaTable(self.m_dungeonLevelPhaseCfg.m_ClientMustDrop)
  local proRewardList = utils.changeCSArrayToLuaTable(self.m_dungeonLevelPhaseCfg.m_ClientProDrop)
  local rewardTab = {}
  local customDataTab = {}
  for i, v in ipairs(proRewardList) do
    rewardTab[#rewardTab + 1] = {
      v[1],
      1
    }
    customDataTab[#customDataTab + 1] = {
      percentage = v[2]
    }
  end
  for i, v in ipairs(rewardList) do
    customDataTab[#customDataTab + 1] = {percentage = 100}
  end
  table.insertto(rewardTab, rewardList)
  self:FreshRewardItems(rewardTab, customDataTab)
end

function UIBossRewardItem:FreshRewardItems(rewardList, customDataTab)
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
      }, customDataTab[i])
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
      }, customDataTab[i])
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

function UIBossRewardItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UIBossRewardItem
