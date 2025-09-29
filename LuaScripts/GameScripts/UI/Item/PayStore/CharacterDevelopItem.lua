local UIItemBase = require("UI/Common/UIItemBase")
local CharacterDevelopItem = class("CharacterDevelopItem", UIItemBase)

function CharacterDevelopItem:OnInit()
  self.cacheProductItems = {}
  self.cacheRewardItems = {}
  for i = 1, 4 do
    table.insert(self.cacheProductItems, self:createCommonItem(self["m_gift_item" .. i]))
    self.cacheProductItems[i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClk(itemID, itemNum, itemCom)
    end)
  end
  for i = 1, 2 do
    table.insert(self.cacheRewardItems, self:createCommonItem(self["m_common_item" .. i]))
    self.cacheRewardItems[i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClk(itemID, itemNum, itemCom)
    end)
  end
end

function CharacterDevelopItem:OnUpdate(dt)
end

function CharacterDevelopItem:OnFreshData()
  local itemData = self.m_itemData
  self.payStoreActivity = itemData.activityData
  if itemData.isTitle then
    self.m_img_bg_tile:SetActive(true)
    self.m_pnl_spacing:SetActive(false)
    self.m_pnl_pack:SetActive(false)
    self.m_txt_tile_Text.text = self.payStoreActivity:getLangText(itemData.data.sTitle)
    return
  else
    self.m_img_bg_tile:SetActive(false)
  end
  if itemData.isEnd then
    self.m_pnl_spacing:SetActive(true)
    self.m_img_bg_tile:SetActive(false)
    self.m_pnl_pack:SetActive(false)
    return
  else
    self.m_pnl_spacing:SetActive(false)
  end
  self.m_pnl_spacing:SetActive(false)
  self.m_img_bg_tile:SetActive(false)
  self.m_img_soldout:SetActive(false)
  self.m_pnl_pack:SetActive(true)
  local dataCount = #itemData.data.vProductReward
  for i = 1, #self.cacheProductItems do
    local dataIndex = dataCount - i + 1
    if 1 <= dataIndex and dataCount >= dataIndex and itemData.data.vProductReward[dataIndex] ~= nil then
      local processItemData = ResourceUtil:GetProcessRewardData(itemData.data.vProductReward[dataIndex])
      self.cacheProductItems[i]:SetItemInfo(processItemData)
      self.cacheProductItems[i]:SetActive(true)
    else
      self.cacheProductItems[i]:SetActive(false)
    end
  end
  local rewardDataCount = #itemData.data.vTaskReward
  for i = 1, #self.cacheRewardItems do
    local dataIndex
    if rewardDataCount == 1 then
      dataIndex = i == 2 and 1 or nil
    else
      dataIndex = i
    end
    if dataIndex and rewardDataCount >= dataIndex and itemData.data.vTaskReward[dataIndex] ~= nil then
      local processItemData = ResourceUtil:GetProcessRewardData(itemData.data.vTaskReward[dataIndex])
      self.cacheRewardItems[i]:SetItemInfo(processItemData)
      self.cacheRewardItems[i]:SetActive(true)
    else
      self.cacheRewardItems[i]:SetActive(false)
    end
  end
  if itemData.isTask then
    local stageName = ConfigManager:GetCommonTextById(220033)
    self.m_txt_stage1_Text.text = string.gsubNumberReplace(stageName, itemData.iTaskIndex)
  end
  self.taskCfg = self.payStoreActivity:GetTaskTypeConfigByTaskType(itemData.data.iTaskType)
  local heroCfg = HeroManager:GetHeroConfigByID(self.payStoreActivity.mTrianCommonData.iHeroId)
  local taskStatus = self.payStoreActivity:GetTrainStatusByTrainId(itemData.data.iId)
  local taskAchieved = self.payStoreActivity:IsTaskCanGetReward(itemData.data.iId)
  self.m_txt_packname_Text.text = self.payStoreActivity:getLangText(itemData.data.sProductName)
  local combinedParameters = {
    heroCfg.m_mName,
    table.unpack(itemData.data.vTaskParam)
  }
  self.m_txt_task_Text.text = string.gsubNumberReplace(self.payStoreActivity:getLangText(self.taskCfg.sDesc), table.unpack(combinedParameters))
  self.m_txt_price_Text.text = IAPManager:GetProductPrice(itemData.data.sProductId, true)
  local iBought = 0
  if taskStatus and taskStatus.iBought then
    iBought = taskStatus.iBought
  end
  self.m_txt_pricenum_Text.text = string.format(ConfigManager:GetCommonTextById(20047), itemData.data.iLimitNum - iBought, itemData.data.iLimitNum)
  if self.m_txt_pricenum2_Text then
    self.m_txt_pricenum2_Text.text = ""
  end
  self.m_txt_enhance_Text.text = itemData.data.iDiscount .. "%"
  self.m_btn_gift:SetActive(true)
  self.m_txt_price:SetActive(true)
  self.m_txt_pricenum:SetActive(true)
  self.m_btn_receive:SetActive(false)
  self.m_img_mask_get1:SetActive(false)
  self.m_img_mask_os:SetActive(false)
  self.m_img_mask_lock:SetActive(true)
  self.m_btn_go:SetActive(false)
  self.m_timerefresh:SetActive(false)
  self:RefreshClientData()
  if not taskAchieved then
    self.m_btn_go:SetActive(true)
    return
  end
  local canReceive = not taskStatus or not (0 < taskStatus.iTakeTime)
  if not canReceive then
    self.m_img_mask_get1:SetActive(true)
  else
    self.m_btn_receive:SetActive(true)
  end
  local isUnLocked = LocalDataManager:GetIntSimple("Activity_ID_" .. self.payStoreActivity:getID() .. "_" .. itemData.data.iId, 0) ~= 0
  local isSoldOut = taskStatus and taskStatus.iBought >= itemData.data.iLimitNum
  if isUnLocked or isSoldOut then
    self.m_img_mask_lock:SetActive(false)
  else
    UILuaHelper.PlayAnimationByName(self.m_img_mask_lock, "Activity_panel_LVL_look_in")
    LocalDataManager:SetIntSimple("Activity_ID_" .. self.payStoreActivity:getID() .. "_" .. itemData.data.iId, 1)
    local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_img_mask_lock, "Activity_panel_LVL_look_in")
    self.m_timer = TimeService:SetTimer(fAniLength, 1, function()
      if not utils.isNull(self.m_img_mask_lock) then
        UILuaHelper.SetActive(self.m_img_mask_lock, false)
      end
    end)
  end
  if not taskStatus or not isSoldOut then
    self.m_timerefresh:SetActive(true)
  end
  if isSoldOut then
    self.m_img_mask_os:SetActive(true)
    self.m_img_soldout:SetActive(true)
    self.m_txt_pricenum:SetActive(false)
  end
end

function CharacterDevelopItem:OnBtngiftClicked()
  local trainId = self.m_itemData.data.iId
  local taskStatus = self.payStoreActivity:GetTrainStatusByTrainId(trainId)
  local achieved = self.payStoreActivity:IsTaskCanGetReward(trainId)
  if not achieved then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52013))
    return
  end
  if taskStatus and taskStatus.iBought >= self.m_itemData.data.iLimitNum then
    return
  end
  local storeData = self.payStoreActivity:GetStoreData()
  local ProductInfo = {
    StoreID = storeData.iStoreId,
    GoodsID = storeData.iStoreId,
    productId = self.m_itemData.data.sProductId,
    productSubId = self.m_itemData.data.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActTrain,
    productName = self.payStoreActivity:getLangText(self.m_itemData.data.sProductName),
    productDesc = self.payStoreActivity:getLangText(self.m_itemData.data.sProductName),
    iActivityId = self.payStoreActivity:getID(),
    GiftPackType = 1
  }
  IAPManager:BuyProductByStoreType(ProductInfo, self.payStoreActivity:getID(), function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    else
      self.payStoreActivity:OnRequestPurchaseCallback(trainId)
    end
    self.payStoreActivity:broadcastEvent("eGameEvent_Activity_TrainUpdate", self.payStoreActivity:getID())
  end)
end

function CharacterDevelopItem:RefreshClientData()
  local clientData = self.payStoreActivity.mTrianClientData
  if not string.IsNullOrEmpty(clientData.sGiftPackMask) then
  end
  if not string.IsNullOrEmpty(clientData.sTaskTypeTextColor) then
    self.m_txt_tile_Text.color = utils.hex2color(clientData.sTaskTypeTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sTaskPhaseTextColor) then
    self.m_txt_stage1_Text.color = utils.hex2color(clientData.sTaskPhaseTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sTaskTextColor) then
    self.m_txt_task_Text.color = utils.hex2color(clientData.sTaskTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sTaskPlate) then
  end
  if not string.IsNullOrEmpty(clientData.sGiftPackNameTextColor) then
    self.m_txt_packname_Text.color = utils.hex2color(clientData.sGiftPackNameTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sGiftPackPlate) then
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_pnl_item2_Image, clientData.sGiftPackPlate, nil, nil, true)
  end
  if not string.IsNullOrEmpty(clientData.sStockTextColor) then
    self.m_txt_pricenum_Text.color = utils.hex2color(clientData.sStockTextColor)
    if self.m_txt_pricenum2_Text then
      self.m_txt_pricenum2_Text.color = utils.hex2color(clientData.sStockTextColor)
    end
  end
  if not string.IsNullOrEmpty(clientData.sPurchasePriceTextColor) then
    self.m_txt_price_Text.color = utils.hex2color(clientData.sPurchasePriceTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sValueForMoneyTextColor) then
    self.m_txt_enhance_Text.color = utils.hex2color(clientData.sValueForMoneyTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sValueForMoneyBaseImage) then
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_pnl_item2_Image, clientData.sValueForMoneyBaseImage, nil, nil, true)
  end
  if not string.IsNullOrEmpty(clientData.sSoldOutTextColor) then
    self.m_txt_soldout_Text.color = utils.hex2color(clientData.sSoldOutTextColor)
  end
  if not string.IsNullOrEmpty(clientData.sSoldOutPic) then
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_soldout_Image, clientData.sSoldOutPic, nil, nil, true)
  end
end

function CharacterDevelopItem:OnItemClk(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function CharacterDevelopItem:OnBtnreceiveClicked()
  self.payStoreActivity:RequestGetReward(self.m_itemData.data.iId)
end

function CharacterDevelopItem:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(self.taskCfg.iJump)
end

return CharacterDevelopItem
