local UIItemBase = require("UI/Common/UIItemBase")
local UIReturnBackSignItem = class("UIReturnBackSignItem", UIItemBase)

function UIReturnBackSignItem:OnInit()
  if self.m_itemInitData then
    self.m_itemNodeClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_returnBackItemData = nil
  self.m_ItemNodeList = {}
  local itemNode = self:InitRewardItem(self.m_item_base)
  self.m_ItemNodeList[#self.m_ItemNodeList + 1] = itemNode
end

function UIReturnBackSignItem:OnFreshData()
end

function UIReturnBackSignItem:FreshItemShow(itemData)
  if not itemData then
    return
  end
  self.m_returnBackItemData = itemData
  self.m_itemDataList = self.m_returnBackItemData.itemData
  self:FreshItemUI()
end

function UIReturnBackSignItem:SetActive(isActive)
  UILuaHelper.SetActive(self.m_itemRootObj, isActive)
end

function UIReturnBackSignItem:FreshItemUI()
  if not self.m_returnBackItemData then
    return
  end
  self:FreshStatus()
  self:FreshRewardItems()
end

function UIReturnBackSignItem:FreshStatus()
  if not self.m_returnBackItemData then
    return
  end
  local haveRcv = self.m_returnBackItemData.isRcv
  local isCanGet = self.m_returnBackItemData.isCanGet
  UILuaHelper.SetActive(self.m_bg_normal, not isCanGet)
  UILuaHelper.SetActive(self.m_bg_light, isCanGet)
  UILuaHelper.SetActive(self.m_Btn_Get, isCanGet)
  UILuaHelper.SetActive(self.m_img_mask, haveRcv)
  self.m_txt_day_Text.text = "0" .. self.m_itemIndex
end

function UIReturnBackSignItem:InitRewardItem(itemObj)
  if not itemObj then
    return
  end
  local itemTrans = itemObj.transform
  local itemCommonItem = itemTrans:Find("m_common_item")
  local itemWidget = self:createCommonItem(itemCommonItem.gameObject)
  itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  local rewardLightNode = itemTrans:Find("m_reward_light")
  return {
    rootNode = itemTrans,
    itemWidget = itemWidget,
    rewardLightNode = rewardLightNode
  }
end

function UIReturnBackSignItem:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local itemNodes = self.m_ItemNodeList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_list_itemreward.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshRewardItemShow(itemNode, self.m_itemDataList[i])
      UILuaHelper.SetActive(itemNode.rootNode, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_item_base, parentTrans).gameObject
      local itemNode = self:InitRewardItem(itemObj)
      self:FreshRewardItemShow(itemNode, self.m_itemDataList[i])
      itemNodes[#itemNodes + 1] = itemNode
      UILuaHelper.SetActive(itemNode.rootNode, true)
    elseif i <= childCount and i > dataLen then
      UILuaHelper.SetActive(itemNodes[i].rootNode, false)
    end
  end
end

function UIReturnBackSignItem:FreshRewardItemShow(itemNode, itemData)
  if not self.m_returnBackItemData then
    return
  end
  if not itemNode then
    return
  end
  if not itemData then
    return
  end
  local processItemData = ResourceUtil:GetProcessRewardData(itemData)
  itemNode.itemWidget:SetItemInfo(processItemData)
  local isRcv = self.m_returnBackItemData.isRcv
  itemNode.itemWidget:SetItemHaveGetActive(isRcv)
  UILuaHelper.SetActive(itemNode.rewardLightNode, self.m_returnBackItemData.isCanGet)
end

function UIReturnBackSignItem:OnRewardItemClick(iID, iNum, itemCom)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function UIReturnBackSignItem:OnBtnGetClicked()
  if not self.m_returnBackItemData then
    return
  end
  if self.m_itemNodeClkBackFun then
    self.m_itemNodeClkBackFun(self.m_itemIndex)
  end
end

return UIReturnBackSignItem
