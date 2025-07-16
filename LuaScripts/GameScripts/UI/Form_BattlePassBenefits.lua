local Form_BattlePassBenefits = class("Form_BattlePassBenefits", require("UI/UIFrames/Form_BattlePassBenefitsUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function Form_BattlePassBenefits:SetInitParam(param)
end

function Form_BattlePassBenefits:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1129)
  self.m_stActivity = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self:InitPaidAndAdvancedItem()
  self.m_stopUpdate = false
end

function Form_BattlePassBenefits:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_BattlePassBenefits:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_BattlePassBenefits:OnUpdate(dt)
  if self.m_stopUpdate then
    return
  end
  self.m_dt = self.m_dt - dt
  if self.m_dt <= 0 then
    self.m_dt = 1
    self:RefreshRemainTime()
  end
end

function Form_BattlePassBenefits:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattlePassBenefits:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self:FreshRewardItemData()
    self.m_csui.m_param = nil
  end
  self.m_dt = 0
end

function Form_BattlePassBenefits:ClearCacheData()
end

function Form_BattlePassBenefits:FreshRewardItemData()
  if not self.m_stActivity then
    return
  end
  self.m_paidItemDataList = {}
  self.m_advancedUpItemDataList = {}
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
    self.m_paidItemDataList[#self.m_paidItemDataList + 1] = v
    self.m_advancedUpItemDataList[#self.m_advancedUpItemDataList + 1] = v
  end
  table.sort(self.m_paidItemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
  table.sort(self.m_advancedUpItemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
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
  self.m_advancedItemDataList = showList
end

function Form_BattlePassBenefits:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.OnAdvancedPassBought))
end

function Form_BattlePassBenefits:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattlePassBenefits:OnAdvancedPassBought()
  self:CloseForm()
end

function Form_BattlePassBenefits:InitPaidAndAdvancedItem()
  self.m_paidItemDataList = {}
  self.m_paidRewardItemBase = self.m_item_up.transform
  self.m_paidItemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_paidRewardItemBase)
  self.m_paidItemNameStr = self.m_paidRewardItemBase.name
  self.m_paidItemNodeList[#self.m_paidItemNodeList + 1] = itemNode
  UILuaHelper.SetActive(self.m_paidRewardItemBase, false)
  self.m_advancedItemDataList = {}
  self.m_advancedRewardItemBase = self.m_item_now.transform
  self.m_advancedItemNodeList = {}
  local advancedItemNode = self:CreateItemNode(self.m_advancedRewardItemBase)
  self.m_advancedItemNameStr = self.m_advancedRewardItemBase.name
  self.m_advancedItemNodeList[#self.m_advancedItemNodeList + 1] = advancedItemNode
  UILuaHelper.SetActive(self.m_advancedRewardItemBase, false)
  self.m_advancedUpItemDataList = {}
  self.m_advancedUpRewardItemBase = self.m_item_levelupget.transform
  self.m_advancedUpItemNodeList = {}
  local advancedUpItemNode = self:CreateItemNode(self.m_advancedUpRewardItemBase)
  self.m_advancedUpItemNameStr = self.m_advancedUpRewardItemBase.name
  self.m_advancedUpItemNodeList[#self.m_advancedUpItemNodeList + 1] = advancedUpItemNode
  UILuaHelper.SetActive(self.m_advancedUpRewardItemBase, false)
end

function Form_BattlePassBenefits:FreshUI()
  self:FreshShowActSpineInfo()
  self:FreshPaidRewardItems()
  self:FreshAdvanceRewardItems()
  self:CheckFreshAdvanceUpShow()
  self:FreshAdvanceAddLevelShow()
  self:FreshPriceShow()
end

function Form_BattlePassBenefits:CheckFreshAdvanceUpShow()
  local curBuyStatus = self.m_stActivity:GetBuyStatus()
  if curBuyStatus == BattlePassBuyStatus.Paid then
    UILuaHelper.SetActive(self.m_z_txt_bp_tips, true)
    UILuaHelper.SetActive(self.m_pnl_levelup_get, false)
  else
    UILuaHelper.SetActive(self.m_z_txt_bp_tips, false)
    UILuaHelper.SetActive(self.m_pnl_levelup_get, true)
    self:FreshAdvanceUpRewardItems()
  end
end

function Form_BattlePassBenefits:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  local remainTime = self.m_stActivity:getActivityRemainTime()
  if 0 < remainTime then
    local showTimeStr = TimeUtil:SecondsToFormatCNStr(remainTime)
    showTimeStr = string.CS_Format(ConfigManager:GetCommonTextById(220018), showTimeStr)
    self.m_txt_time_Text.text = showTimeStr
  else
    self.m_stopUpdate = true
    utils.CheckAndPushCommonTips({
      tipsID = 1751,
      func1 = function()
        self:CloseForm()
      end
    })
  end
end

function Form_BattlePassBenefits:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return widget
end

function Form_BattlePassBenefits:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode
  itemWidget:SetItemInfo(itemData.itemData)
end

function Form_BattlePassBenefits:FreshPaidRewardItems()
  if not self.m_paidItemDataList then
    return
  end
  local itemNodes = self.m_paidItemNodeList
  local dataLen = #self.m_paidItemDataList
  local parentTrans = self.m_img_bg_reward.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_paidItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_paidRewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_paidItemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_paidItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BattlePassBenefits:FreshAdvanceRewardItems()
  if not self.m_advancedItemDataList then
    return
  end
  local itemNodes = self.m_advancedItemNodeList
  local dataLen = #self.m_advancedItemDataList
  local parentTrans = self.m_img_bg_reward2.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_advancedItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_advancedRewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_advancedItemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_advancedItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BattlePassBenefits:FreshAdvanceUpRewardItems()
  if not self.m_advancedUpItemDataList then
    return
  end
  local itemNodes = self.m_advancedUpItemNodeList
  local dataLen = #self.m_advancedUpItemDataList
  local parentTrans = self.m_img_bg_reward3.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_advancedUpItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_advancedUpRewardItemBase, parentTrans).gameObject
      itemObj.name = self.m_advancedUpItemNameStr .. i
      local itemNode = self:CreateItemNode(itemObj)
      itemNodes[#itemNodes + 1] = itemNode
      local itemData = self.m_advancedUpItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function Form_BattlePassBenefits:FreshAdvanceAddLevelShow()
  if not self.m_stActivity then
    return
  end
  local extraLv = self.m_stActivity:GetAdvancedAddLv()
  self.m_txt_addlevel_Text.text = extraLv
  UILuaHelper.SetActive(self.m_item_level10, true)
  UILuaHelper.SetChildIndex(self.m_item_level10, -1)
end

function Form_BattlePassBenefits:FreshPriceShow()
  if not self.m_stActivity then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  UILuaHelper.SetActive(self.m_btn_price1, buyStatus <= BattlePassBuyStatus.Free)
  UILuaHelper.SetActive(self.m_pnl_soldout1, buyStatus > BattlePassBuyStatus.Free)
  if buyStatus <= BattlePassBuyStatus.Free then
    self.m_txt_price1_Text.text = self.m_stActivity:GetSalePrice()
  end
  UILuaHelper.SetActive(self.m_btn_price2, buyStatus < BattlePassBuyStatus.Advanced)
  UILuaHelper.SetActive(self.m_pnl_soldout2, buyStatus >= BattlePassBuyStatus.Advanced)
  if buyStatus < BattlePassBuyStatus.Advanced then
    local showPrice
    if buyStatus == BattlePassBuyStatus.Free then
      showPrice = self.m_stActivity:GetAdvancedPrice()
    else
      showPrice = self.m_stActivity:GetAdvancedDifferencePrice()
    end
    self.m_txt_price2_Text.text = showPrice
  end
  self.m_txt_sale1_Text.text = self.m_stActivity:GetNormalCostRatio() .. "%"
  self.m_txt_sale2_Text.text = self.m_stActivity:GetAdvancedCostRatio() .. "%"
end

function Form_BattlePassBenefits:FreshShowActSpineInfo()
  local iAvatarId = self.m_stActivity:GetAvatarId()
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(iAvatarId)
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_BattlePassBenefits:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroDetail
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function Form_BattlePassBenefits:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_BattlePassBenefits:OnBackClk()
  self:CloseForm()
end

function Form_BattlePassBenefits:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_BattlePassBenefits:OnBtnprice1Clicked()
  if not self.m_stActivity then
    return
  end
  local productID, productSubID = self.m_stActivity:GetProductID()
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

function Form_BattlePassBenefits:OnBtnprice2Clicked()
  if not self.m_stActivity then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  if buyStatus == BattlePassBuyStatus.Advanced then
    return
  end
  local productID, productSubID
  if buyStatus == BattlePassBuyStatus.Free then
    productID, productSubID = self.m_stActivity:GetAdvancedProductID()
  elseif buyStatus == BattlePassBuyStatus.Paid then
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

function Form_BattlePassBenefits:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

local fullscreen = true
ActiveLuaUI("Form_BattlePassBenefits", Form_BattlePassBenefits)
return Form_BattlePassBenefits
