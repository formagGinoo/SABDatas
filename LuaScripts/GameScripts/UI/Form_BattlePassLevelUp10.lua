local Form_BattlePassLevelUp10 = class("Form_BattlePassLevelUp10", require("UI/UIFrames/Form_BattlePassLevelUp10UI"))
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function Form_BattlePassLevelUp10:SetInitParam(param)
end

function Form_BattlePassLevelUp10:AfterInit()
  self.super.AfterInit(self)
  self.m_stActivity = nil
  self.m_upItemDataList = nil
  self.m_downItemDataList = nil
  self.m_curBuyStatus = nil
  self:InitUpAndDownItem()
end

function Form_BattlePassLevelUp10:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_BattlePassLevelUp10:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_BattlePassLevelUp10:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattlePassLevelUp10:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self.m_isReachMax = self.m_stActivity:ReachMaxLevel()
    self.m_curBuyStatus = self.m_stActivity:GetBuyStatus()
    self:FreshUpItemDataList()
    self:FreshDownItemDataList()
    self.m_csui.m_param = nil
  end
end

function Form_BattlePassLevelUp10:ClearCacheData()
end

function Form_BattlePassLevelUp10:GetAllPaidRewardItemDataList()
  if not self.m_stActivity then
    return {}
  end
  local tempItemDataList = {}
  local levelCfgDic = self.m_stActivity.m_vLevelCfg
  local tempAllItemDic = {}
  for _, v in pairs(levelCfgDic) do
    local tempCmdLevelBPCfg = v
    local paidRewardList = tempCmdLevelBPCfg.vPaidReward
    for _, tempCmdIDNum in ipairs(paidRewardList) do
      local itemID = tempCmdIDNum.iID
      local itemNum = tempCmdIDNum.iNum
      if tempAllItemDic[itemID] == nil then
        tempAllItemDic[itemID] = {iID = itemID, iNum = itemNum}
      else
        tempAllItemDic[itemID].iNum = tempAllItemDic[itemID].iNum + itemNum
      end
    end
  end
  for i, v in pairs(tempAllItemDic) do
    local processItemData = ResourceUtil:GetProcessRewardData(v)
    v.itemData = processItemData
    tempItemDataList[#tempItemDataList + 1] = v
  end
  table.sort(tempItemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
  return tempItemDataList
end

function Form_BattlePassLevelUp10:GetAllFinalAdvanceAddLvRewardDataList()
  if not self.m_stActivity then
    return {}
  end
  local tempItemDataList = {}
  local maxLv = self.m_stActivity:GetMaxLevel()
  local advanceAddLv = self.m_stActivity:GetAdvancedAddLv()
  local tempAllItemDic = {}
  for i = 1, advanceAddLv do
    local tempLvNum = maxLv - (i - 1)
    local tempLevelCfg = self.m_stActivity:GetLevelCfg(tempLvNum)
    if tempLevelCfg then
      local freeRewardList = tempLevelCfg.vFreeReward
      for _, tempCmdIDNum in ipairs(freeRewardList) do
        local itemID = tempCmdIDNum.iID
        local itemNum = tempCmdIDNum.iNum
        if tempAllItemDic[itemID] == nil then
          tempAllItemDic[itemID] = {iID = itemID, iNum = itemNum}
        else
          tempAllItemDic[itemID].iNum = tempAllItemDic[itemID].iNum + itemNum
        end
      end
      local paidRewardList = tempLevelCfg.vPaidReward
      for _, tempCmdIDNum in ipairs(paidRewardList) do
        local itemID = tempCmdIDNum.iID
        local itemNum = tempCmdIDNum.iNum
        if tempAllItemDic[itemID] == nil then
          tempAllItemDic[itemID] = {iID = itemID, iNum = itemNum}
        else
          tempAllItemDic[itemID].iNum = tempAllItemDic[itemID].iNum + itemNum
        end
      end
    end
  end
  for i, v in pairs(tempAllItemDic) do
    local processItemData = ResourceUtil:GetProcessRewardData(v)
    v.itemData = processItemData
    tempItemDataList[#tempItemDataList + 1] = v
  end
  table.sort(tempItemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
  return tempItemDataList
end

function Form_BattlePassLevelUp10:GetAllFinalFreeAndAllPaidRewardItemDataList()
  if not self.m_stActivity then
    return {}
  end
  local tempItemDataList = {}
  local levelCfgDic = self.m_stActivity.m_vLevelCfg
  local tempAllItemDic = {}
  for _, v in pairs(levelCfgDic) do
    local tempCmdLevelBPCfg = v
    local paidRewardList = tempCmdLevelBPCfg.vPaidReward
    for _, tempCmdIDNum in ipairs(paidRewardList) do
      local itemID = tempCmdIDNum.iID
      local itemNum = tempCmdIDNum.iNum
      if tempAllItemDic[itemID] == nil then
        tempAllItemDic[itemID] = {iID = itemID, iNum = itemNum}
      else
        tempAllItemDic[itemID].iNum = tempAllItemDic[itemID].iNum + itemNum
      end
    end
  end
  local maxLv = self.m_stActivity:GetMaxLevel()
  local advanceAddLv = self.m_stActivity:GetAdvancedAddLv()
  for i = 1, advanceAddLv do
    local tempLvNum = maxLv - (i - 1)
    local tempLevelCfg = self.m_stActivity:GetLevelCfg(tempLvNum)
    if tempLevelCfg then
      local freeRewardList = tempLevelCfg.vFreeReward
      for _, tempCmdIDNum in ipairs(freeRewardList) do
        local itemID = tempCmdIDNum.iID
        local itemNum = tempCmdIDNum.iNum
        if tempAllItemDic[itemID] == nil then
          tempAllItemDic[itemID] = {iID = itemID, iNum = itemNum}
        else
          tempAllItemDic[itemID].iNum = tempAllItemDic[itemID].iNum + itemNum
        end
      end
    end
  end
  for i, v in pairs(tempAllItemDic) do
    local processItemData = ResourceUtil:GetProcessRewardData(v)
    v.itemData = processItemData
    tempItemDataList[#tempItemDataList + 1] = v
  end
  table.sort(tempItemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
  return tempItemDataList
end

function Form_BattlePassLevelUp10:FreshUpItemDataList()
  if not self.m_stActivity then
    return
  end
  self.m_upItemDataList = {}
  if self.m_isReachMax then
    self.m_upItemDataList = self:GetAllPaidRewardItemDataList()
  elseif self.m_curBuyStatus == BattlePassBuyStatus.Free then
    self.m_upItemDataList = self:GetAllFinalFreeAndAllPaidRewardItemDataList()
  elseif self.m_curBuyStatus == BattlePassBuyStatus.Paid then
    self.m_upItemDataList = self:GetAllFinalAdvanceAddLvRewardDataList()
  end
end

function Form_BattlePassLevelUp10:FreshDownItemDataList()
  if not self.m_stActivity then
    return
  end
  local tempItemList = self.m_stActivity:GetAdvancedExtraReward()
  local showList = {}
  for i, v in ipairs(tempItemList) do
    showList[#showList + 1] = {
      iID = v.iID,
      iNum = v.iNum,
      itemData = ResourceUtil:GetProcessRewardData(v)
    }
  end
  table.sort(showList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
  self.m_downItemDataList = showList
end

function Form_BattlePassLevelUp10:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.OnAdvancedPassBought))
end

function Form_BattlePassLevelUp10:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattlePassLevelUp10:OnAdvancedPassBought()
  self:CloseForm()
end

function Form_BattlePassLevelUp10:InitUpAndDownItem()
  self.m_upItemDataList = {}
  self.m_upRewardItemBase = self.m_item_now.transform
  self.m_upItemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_upRewardItemBase)
  self.m_upItemNameStr = self.m_upRewardItemBase.name
  self.m_upItemNodeList[#self.m_upItemNodeList + 1] = itemNode
  UILuaHelper.SetActive(self.m_upRewardItemBase, false)
  self.m_downItemDataList = {}
  self.m_downRewardItemBase = self.m_item_high.transform
  self.m_downItemNodeList = {}
  local downItemNode = self:CreateItemNode(self.m_downRewardItemBase)
  self.m_downItemNameStr = self.m_downRewardItemBase.name
  self.m_downItemNodeList[#self.m_downItemNodeList + 1] = downItemNode
  UILuaHelper.SetActive(self.m_downRewardItemBase, false)
end

function Form_BattlePassLevelUp10:FreshUI()
  if self.m_curBuyStatus == BattlePassBuyStatus.Advanced then
    self:CloseForm()
    return
  end
  self:FreshUpRewardItems()
  self:FreshDownRewardItems()
  self:FreshTypeUIShow()
end

function Form_BattlePassLevelUp10:FreshTypeUIShow()
  local isReachMax = self.m_isReachMax
  UILuaHelper.SetActive(self.m_img_bg1, isReachMax)
  UILuaHelper.SetActive(self.m_img_bg2, not isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_leveluptitle1, isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_leveluptitle2, not isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_levelnow1, isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_levelnow2, not isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_levelother1, isReachMax)
  UILuaHelper.SetActive(self.m_z_txt_levelother2, not isReachMax)
  UILuaHelper.SetActive(self.m_img_bg1, isReachMax)
  UILuaHelper.SetActive(self.m_img_bg2, not isReachMax)
  UILuaHelper.SetActive(self.m_item_level10, not isReachMax)
  UILuaHelper.SetChildIndex(self.m_item_level10, -1)
  UILuaHelper.SetActive(self.m_btn_confirm, isReachMax)
  UILuaHelper.SetActive(self.m_btn_price, not isReachMax)
  if not isReachMax then
    local priceNum = 0
    if self.m_curBuyStatus == BattlePassBuyStatus.Free then
      priceNum = self.m_stActivity:GetAdvancedPrice()
    elseif self.m_curBuyStatus == BattlePassBuyStatus.Paid then
      priceNum = self.m_stActivity:GetAdvancedDifferencePrice()
    end
    self.m_txt_price_Text.text = priceNum
    self.m_txt_addlevel_Text.text = self.m_stActivity:GetAdvancedAddLv()
  end
end

function Form_BattlePassLevelUp10:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return widget
end

function Form_BattlePassLevelUp10:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode
  itemWidget:SetItemInfo(itemData.itemData)
end

function Form_BattlePassLevelUp10:FreshUpRewardItems()
  if not self.m_upItemDataList then
    return
  end
  local itemNodes = self.m_upItemNodeList
  local dataLen = #self.m_upItemDataList
  local parentTrans = self.m_list_itemnow.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_upItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_upRewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_upItemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_upItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BattlePassLevelUp10:FreshDownRewardItems()
  if not self.m_downItemDataList then
    return
  end
  local itemNodes = self.m_downItemNodeList
  local dataLen = #self.m_downItemDataList
  local parentTrans = self.m_list_itemhigh.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_downItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_downRewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_downItemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_downItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BattlePassLevelUp10:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_BattlePassLevelUp10:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_BattlePassLevelUp10:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_BattlePassLevelUp10:OnBtnpriceClicked()
  if not self.m_stActivity then
    return
  end
  local productID, productSubID
  if self.m_curBuyStatus == BattlePassBuyStatus.Free then
    productID, productSubID = self.m_stActivity:GetAdvancedProductID()
  elseif self.m_curBuyStatus == BattlePassBuyStatus.Paid then
    productID, productSubID = self.m_stActivity:GetAdvancedDifferenceProductID()
  end
  if not productID then
    return
  end
  local remainTime = self.m_stActivity:getActivityRemainTime()
  if remainTime <= 7200 then
    utils.CheckAndPushCommonTips({
      tipsID = 1752,
      func1 = function()
        self.m_stActivity:BuyAdvancedPass(productID, productSubID)
      end
    })
    return
  end
  self.m_stActivity:BuyAdvancedPass(productID, productSubID)
end

function Form_BattlePassLevelUp10:OnBtnconfirmClicked()
  if not self.m_stActivity then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSBENEFITS, {
    stActivity = self.m_stActivity
  })
  self:CloseForm()
end

function Form_BattlePassLevelUp10:OnBtnquitClicked()
  if not self.m_stActivity then
    return
  end
  self:CloseForm()
end

function Form_BattlePassLevelUp10:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattlePassLevelUp10", Form_BattlePassLevelUp10)
return Form_BattlePassLevelUp10
