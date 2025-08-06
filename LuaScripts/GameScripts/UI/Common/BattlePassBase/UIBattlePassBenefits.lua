local UIBattlePassBenefits = class("UIBattlePassBenefits", require("UI/Common/UIBase"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function UIBattlePassBenefits:SetInitParam(param)
end

function UIBattlePassBenefits:AfterInit()
  UIBattlePassBenefits.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_stActivity = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_stopUpdate = true
  self.m_hasAdvanced = false
  self.m_isInitTopBtn = false
  self.m_isInitRewardItem = false
  self.m_isInitRewardItemAdvanced = false
  self.m_titleType = 1
end

function UIBattlePassBenefits:OnActive()
  UIBattlePassBenefits.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function UIBattlePassBenefits:OnInactive()
  UIBattlePassBenefits.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function UIBattlePassBenefits:OnUpdate(dt)
  if self.m_stopUpdate then
    return
  end
  if self.m_dt then
    self.m_dt = self.m_dt - dt
    if self.m_dt <= 0 then
      self.m_dt = 1
      self:RefreshRemainTime()
    end
  end
end

function UIBattlePassBenefits:OnDestroy()
  UIBattlePassBenefits.super.OnDestroy(self)
end

function UIBattlePassBenefits:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self:InitPaidItem()
    self.m_stActivity = tParam.stActivity
    if self.m_stActivity then
      self.m_hasAdvanced = self.m_stActivity:GetBattlePassHasAdvance()
    end
    if self.m_hasAdvanced then
      self:InitPaidAndAdvancedItem()
    end
    self.m_titleType = self.m_stActivity:GetTitleType()
    self:FreshRewardItemData()
    self.m_csui.m_param = nil
    self.m_stopUpdate = self.m_titleType ~= 2 and self.m_titleType ~= 0
    self.m_iActivityId = self.m_stActivity:getID()
  end
  self.m_dt = 0
end

function UIBattlePassBenefits:ClearCacheData()
end

function UIBattlePassBenefits:FreshRewardItemData()
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
  table.sort(self.m_paidItemDataList, self.SortComparator)
  table.sort(self.m_advancedUpItemDataList, self.SortComparator)
  local tempItemList = self.m_stActivity:GetAdvancedExtraReward()
  local showList = {}
  for i, v in ipairs(tempItemList) do
    showList[#showList + 1] = {
      iID = v.iID,
      iNum = v.iNum,
      itemData = ResourceUtil:GetProcessRewardData(v)
    }
  end
  table.sort(showList, self.SortComparator)
  self.m_advancedItemDataList = showList
end

function UIBattlePassBenefits:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.OnAdvancedPassBought))
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnFreshActivity))
end

function UIBattlePassBenefits:OnFreshActivity()
  if self.m_iActivityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    if not self.m_stActivity then
      self:CloseForm()
    end
  end
end

function UIBattlePassBenefits:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIBattlePassBenefits:OnAdvancedPassBought()
  self:CloseForm()
end

function UIBattlePassBenefits:OnBtncheck3Clicked()
  if not self.m_stActivity then
    return
  end
  local heroId = self.m_stActivity:GetHeroId()
  local skinId = self.m_stActivity:GetSkinId()
  if heroId and skinId then
    StackFlow:Push(UIDefines.ID_FORM_FASHION, {heroID = heroId, fashionID = skinId})
  end
end

function UIBattlePassBenefits:InitPaidItem()
  if self.m_isInitRewardItem then
    return
  end
  self.m_isInitRewardItem = true
  self.m_paidItemDataList = {}
  self.m_paidRewardItemBase = self.m_item_up.transform
  self.m_paidItemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_paidRewardItemBase)
  self.m_paidItemNameStr = self.m_paidRewardItemBase.name
  self.m_paidItemNodeList[#self.m_paidItemNodeList + 1] = itemNode
  UILuaHelper.SetActive(self.m_paidRewardItemBase, false)
end

function UIBattlePassBenefits:InitPaidAndAdvancedItem()
  if self.m_isInitRewardItemAdvanced then
    return
  end
  self.m_isInitRewardItemAdvanced = true
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

function UIBattlePassBenefits:FreshUI()
  self:FreshTitlePanel()
  self:FreshTopTipsAndClose()
  self:FreshShowActSpineInfo()
  self:FreshPaidRewardItems()
  self:FreshAdvancePanel()
  self:FreshPriceShow()
  self:FreshBgPic()
  self:OnRefreshGiftPoint()
end

function UIBattlePassBenefits:CheckFreshAdvanceUpShow()
  if not self.m_stActivity then
    return
  end
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

function UIBattlePassBenefits:FreshTitlePanel()
  if not self.m_stActivity then
    return
  end
  self.m_pnl_title1:SetActive(false)
  self.m_pnl_title2:SetActive(false)
  if self.m_titleType == 2 then
    self.m_pnl_title1:SetActive(false)
    self.m_pnl_title2:SetActive(true)
    local roleName = self.m_stActivity:GetRoleName()
    local isShowRoleName = roleName and roleName ~= ""
    self.m_txt_role2:SetActive(isShowRoleName)
    if isShowRoleName then
      self.m_txt_role2_Text.text = roleName
    end
    local skinName = self.m_stActivity:GetSkinName()
    local isShowSkinName = skinName and skinName ~= ""
    self.m_txt_bp_titlle2:SetActive(isShowSkinName)
    if isShowSkinName then
      self.m_txt_bp_titlle2_Text.text = skinName
    end
  else
    self.m_pnl_title1:SetActive(true)
    self.m_pnl_title2:SetActive(false)
    local titleName = self.m_stActivity:GetTitleAndEnterName()
    if titleName and titleName ~= "" then
      self.m_pnl_name1:SetActive(false)
      self.m_pnl_name2:SetActive(true)
      self.m_txt_bp_titlle_Text.text = titleName
    else
      self.m_pnl_name1:SetActive(true)
      self.m_pnl_name2:SetActive(false)
    end
  end
end

function UIBattlePassBenefits:FreshBgPic()
  if self.m_stActivity then
    local bg, bg1 = self.m_stActivity:GetBpBuyBgPic()
    if bg and bg ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg_Image, bg, function()
        self.m_img_bg:SetActive(true)
      end)
    end
    if bg1 and bg1 ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg1_Image, bg1, function()
        self.m_img_bg1:SetActive(true)
      end)
    end
  end
end

function UIBattlePassBenefits:RefreshRemainTime()
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

function UIBattlePassBenefits:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return widget
end

function UIBattlePassBenefits:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode
  itemWidget:SetItemInfo(itemData.itemData)
end

function UIBattlePassBenefits:FreshPaidRewardItems()
  if not self.m_paidItemDataList then
    return
  end
  local itemNodes = self.m_paidItemNodeList
  local dataLen = #self.m_paidItemDataList
  local parentTrans = self.m_pnl_itemgift.transform
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

function UIBattlePassBenefits:FreshAdvancePanel()
  if not self.m_hasAdvanced then
    self.m_pnl_pass2:SetActive(false)
    return
  end
  self:FreshAdvanceRewardItems()
  self:CheckFreshAdvanceUpShow()
  self:FreshAdvanceAddLevelShow()
end

function UIBattlePassBenefits:FreshAdvanceRewardItems()
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

function UIBattlePassBenefits:FreshAdvanceUpRewardItems()
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

function UIBattlePassBenefits:FreshAdvanceAddLevelShow()
  if not self.m_stActivity then
    return
  end
  local extraLv = self.m_stActivity:GetAdvancedAddLv()
  self.m_txt_addlevel_Text.text = extraLv
  UILuaHelper.SetActive(self.m_item_level10, true)
  UILuaHelper.SetChildIndex(self.m_item_level10, -1)
end

function UIBattlePassBenefits:FreshPriceShow()
  if not self.m_stActivity then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  UILuaHelper.SetActive(self.m_btn_price1, buyStatus <= BattlePassBuyStatus.Free)
  UILuaHelper.SetActive(self.m_pnl_soldout1, buyStatus > BattlePassBuyStatus.Free)
  if buyStatus <= BattlePassBuyStatus.Free then
    self.m_txt_price1_Text.text = self.m_stActivity:GetSalePrice()
  end
  self.m_txt_sale1_Text.text = self.m_stActivity:GetNormalCostRatio() .. "%"
  if self.m_hasAdvanced then
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
    self.m_txt_sale2_Text.text = self.m_stActivity:GetAdvancedCostRatio() .. "%"
  end
end

function UIBattlePassBenefits:FreshShowActSpineInfo()
  if self.m_stActivity then
    local spineStr = self.m_stActivity:GetAvatarSpineName()
    if spineStr and spineStr ~= "" then
      self:ShowHeroSpine(self.m_stActivity:GetAvatarSpineName())
    end
  end
end

function UIBattlePassBenefits:FreshTopTipsAndClose()
  local tipsId
  if self.m_stActivity then
    tipsId = self.m_stActivity:GetTipsID()
  end
  if not self.m_isInitTopBtn then
    local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), tipsId)
    self.m_isInitTopBtn = true
  end
end

function UIBattlePassBenefits:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroBpBenefits
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function UIBattlePassBenefits:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function UIBattlePassBenefits:OnBackClk()
  self:CloseForm()
end

function UIBattlePassBenefits:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function UIBattlePassBenefits:OnBtnprice1Clicked()
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

function UIBattlePassBenefits:OnBtnprice2Clicked()
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

function UIBattlePassBenefits:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function UIBattlePassBenefits:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  if not self.m_stActivity then
    self.m_packgift_point:SetActive(false)
  end
  local productID, productSubID = self.m_stActivity:GetProductID()
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(productID)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    if self.m_paidGiftPoint then
      self.m_paidGiftPoint:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point, pointParams)
    end
  else
    self.m_packgift_point:SetActive(false)
  end
end

function UIBattlePassBenefits.SortComparator(a, b)
  local aIsFashion = ResourceUtil:GetResourceTypeById(a.iID) == ResourceUtil.RESOURCE_TYPE.Fashion
  local bIsFashion = ResourceUtil:GetResourceTypeById(b.iID) == ResourceUtil.RESOURCE_TYPE.Fashion
  if aIsFashion ~= bIsFashion then
    return aIsFashion
  end
  if a.itemData.quality ~= b.itemData.quality then
    return a.itemData.quality > b.itemData.quality
  end
  return a.iID < b.iID
end

function UIBattlePassBenefits:IsFullScreen()
  return true
end

return UIBattlePassBenefits
