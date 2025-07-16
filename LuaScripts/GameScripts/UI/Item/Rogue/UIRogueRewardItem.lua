local UIItemBase = require("UI/Common/UIItemBase")
local UIRogueRewardItem = class("UIRogueRewardItem", UIItemBase)

function UIRogueRewardItem:OnInit()
  self.m_rogueStageRewardGroupCfg = nil
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

function UIRogueRewardItem:OnFreshData()
  self.m_rogueStageRewardGroupCfg = self.m_itemData.cfg
  self.m_state = self.m_itemData.state
  self.m_curLevel = self.m_itemData.curLevel
  self:FreshItemUI()
end

function UIRogueRewardItem:PlayEnterAnim(index)
  UILuaHelper.SetActive(self.m_itemRootObj, false)
  local m_sequence = Tweening.DOTween.Sequence()
  m_sequence:AppendInterval(0.06 * index)
  m_sequence:OnComplete(function()
    if not utils.isNull(self.m_itemRootObj) then
      UILuaHelper.SetActive(self.m_itemRootObj, true)
      UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "m_roguereward_item_in")
    end
  end)
  m_sequence:SetAutoKill(true)
end

function UIRogueRewardItem:FreshItemUI()
  if not self.m_rogueStageRewardGroupCfg then
    return
  end
  self.m_txt_level_Text.text = self.m_rogueStageRewardGroupCfg.m_KeyLevel
  self:FreshRewardList()
  self.m_pnl_got:SetActive(self.m_state == 1)
  self.m_pnl_get:SetActive(self.m_state == 2)
  self.m_pnl_unget:SetActive(self.m_state == 3)
  self.m_pnl_lock:SetActive(self.m_state == 4)
  self.m_fx_getaward:SetActive(self.m_state == 2)
  self.m_line:SetActive((self.m_state == 1 or self.m_state == 2) and self.m_curLevel ~= self.m_rogueStageRewardGroupCfg.m_KeyLevel)
  self.m_line_gary:SetActive(self.m_state == 3 or self.m_state == 4 or self.m_curLevel == self.m_rogueStageRewardGroupCfg.m_KeyLevel)
  self.m_multiColorChange:SetColorByIndex(self.m_state == 4 and 1 or 0)
  self.m_img_lock3:SetActive(self.m_state == 4)
end

function UIRogueRewardItem:FreshRewardList()
  if not self.m_rogueStageRewardGroupCfg then
    return
  end
  local rewardList = utils.changeCSArrayToLuaTable(self.m_rogueStageRewardGroupCfg.m_Rewards)
  self:FreshRewardItems(rewardList)
end

function UIRogueRewardItem:FreshRewardItems(rewardList)
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
        is_have_get = self.m_state == 1,
        is_can_get = self.m_state == 2
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
        is_have_get = self.m_state == 1,
        is_can_get = self.m_state == 2
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

function UIRogueRewardItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UIRogueRewardItem
