local UIItemBase = require("UI/Common/UIItemBase")
local UILevelGoblinRewardItem = class("UILevelGoblinRewardItem", UIItemBase)
local string_format = string.format

function UILevelGoblinRewardItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  self.m_ItemWidgetList[#self.m_ItemWidgetList + 1] = self:createCommonItem(self.m_rewardItemBase.gameObject)
end

function UILevelGoblinRewardItem:OnFreshData()
  self:FreshBaseInfo()
  self:FreshRewardList(self.m_itemData.rewardCfg.m_FirstBonusClient)
end

function UILevelGoblinRewardItem:FreshBaseInfo()
  if not self.m_itemData then
    return
  end
  self.m_txt_damage_num_Text.text = self.m_itemData.rewardCfg.m_CountMin .. "-" .. self.m_itemData.nextCount
  self.m_txt_level_num_Text.text = string_format(ConfigManager:GetCommonTextById(20044), self.m_itemData.rewardCfg.m_StageID)
end

function UILevelGoblinRewardItem:FreshRewardList(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
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
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      itemObj.name = self.m_rewardItemBase.name .. i
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

function UILevelGoblinRewardItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UILevelGoblinRewardItem
