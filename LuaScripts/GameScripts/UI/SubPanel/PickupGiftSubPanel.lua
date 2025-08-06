local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PickupGiftSubPanel = class("PickupGiftSubPanel", UISubPanelBase)

function PickupGiftSubPanel:OnInit()
end

local iMaxGiftNum = 3
local iMaxGiftItemNum = 5

function PickupGiftSubPanel:OnInactivePanel()
  self.iCurSelectIdx = nil
end

function PickupGiftSubPanel:OnFreshData()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_PickupGift)
  if not activity then
    return
  end
  self.activity = activity
  self.giftList = activity:GetPickUpGiftList()
  self.giftInfo = activity:GetPickUpGifyInfo()
  self:RefreshList()
end

function PickupGiftSubPanel:RefreshList()
  if not self.giftList or not self.giftInfo then
    return
  end
  local iDefaultIdx
  for i = 1, iMaxGiftNum do
    local giftData = self.giftList[i]
    local giftInfo = self.giftInfo[giftData.iGiftId]
    if giftData.iDiscount and giftData.iDiscount > 0 then
      self["m_txt_sale_numsel" .. i .. "_Text"].text = giftData.iDiscount .. "%"
      self["m_img_bksel" .. i]:SetActive(true)
    else
      self["m_img_bksel" .. i]:SetActive(false)
    end
    self["m_txt_giftnamesel" .. i .. "_Text"].text = self.activity:getLangText(giftData.sGiftName)
    local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftData.iBuyLimit
    iDefaultIdx = iDefaultIdx or not isSoldOut and i
    self["m_txt_normal" .. i .. "sel"]:SetActive(not isSoldOut)
    self["m_soldoutsel" .. i]:SetActive(isSoldOut)
    if 0 < giftData.iBuyLimit then
      local v = giftData.iBuyLimit - giftInfo.iBoughtNum
      if v < 0 then
        v = 0
      end
      self["m_txt_limit_numsel" .. i .. "_Text"].text = string.format("%d/%d", v, giftData.iBuyLimit)
    else
      self["m_txt_limit_numsel" .. i .. "_Text"].text = ""
    end
    self["m_txt_pricesel" .. i .. "_Text"].text = IAPManager:GetProductPrice(giftData.sProductId, true)
  end
  self.iCurSelectIdx = self.iCurSelectIdx or iDefaultIdx or 1
  self:OnClickTab(self.iCurSelectIdx)
  for i = 1, iMaxGiftNum do
    if i == self.iCurSelectIdx then
      self["m_pnl_framesel" .. i]:SetActive(true)
      self["m_pnl_framesel" .. i .. i]:SetActive(true)
      UILuaHelper.PlayAnimationByName(self["m_pnl_itemsel" .. i], "activity_panel_pickup_cut_in1")
    else
      self["m_pnl_framesel" .. i]:SetActive(false)
      self["m_pnl_framesel" .. i .. i]:SetActive(false)
      UILuaHelper.PlayAnimationByName(self["m_pnl_itemsel" .. i], "activity_panel_pickup_cut_out1")
    end
  end
  self:RefreshInfo()
end

function PickupGiftSubPanel:RefreshChooseItemUI(oldChoose)
  for i = 1, iMaxGiftNum do
    if i == self.iCurSelectIdx then
      UILuaHelper.PlayAnimationByName(self["m_pnl_itemsel" .. i], "activity_panel_pickup_cut_in")
      self["m_pnl_framesel" .. i]:SetActive(true)
    end
    if i == oldChoose then
      UILuaHelper.PlayAnimationByName(self["m_pnl_itemsel" .. i], "activity_panel_pickup_cut_out")
      self["m_pnl_framesel" .. i]:SetActive(false)
    end
  end
end

function PickupGiftSubPanel:CheckBuyBtnState()
  local isShowBuyBtn = true
  if not self.giftList or not self.giftInfo then
    return false
  end
  local giftData = self.giftList[self.iCurSelectIdx]
  local giftInfo = self.giftInfo[giftData.iGiftId]
  local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftData.iBuyLimit
  if isSoldOut then
    return false
  end
  if giftInfo and giftInfo.mGridRewardIndex and giftData then
    local maxCount = table.getn(giftData.stGrids.mGridCfg)
    local count = table.getn(giftInfo.mGridRewardIndex)
    if maxCount > count then
      return false
    end
  end
  return isShowBuyBtn
end

function PickupGiftSubPanel:RefreshInfo()
  if not self.giftList or not self.giftInfo then
    return
  end
  self:OnRefreshGiftPoint()
  local giftData = self.giftList[self.iCurSelectIdx]
  local giftInfo = self.giftInfo[giftData.iGiftId]
  local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftData.iBuyLimit
  if isSoldOut then
    self.m_txt_upgrade_Text.text = ConfigManager:GetCommonTextById(220024)
  else
    self.m_txt_upgrade_Text.text = IAPManager:GetProductPrice(giftData.sProductId, true)
  end
  local isShowBuyBtn = self:CheckBuyBtnState()
  UILuaHelper.SetActive(self.m_img_bg_grey, not isShowBuyBtn)
  UILuaHelper.SetActive(self.m_img_bg_red, isShowBuyBtn)
  local mGridCfg = {}
  local num = table.getn(giftData.stGrids.mGridCfg)
  local count = num < iMaxGiftItemNum and iMaxGiftItemNum or num
  for i = 1, count do
    local itemList = giftData.stGrids.mGridCfg[i] or {}
    if i == 1 then
      if itemList[1] then
        local item = self:createCommonItem(self.m_rewarditem)
        local processData = ResourceUtil:GetProcessRewardData(itemList[1], {is_have_get = isSoldOut})
        item:SetItemInfo(processData)
        item:SetItemIconClickCB(function(itemID, itemNum)
          self:OnBtnChooseClicked()
        end)
      end
    else
      mGridCfg[i - 1] = itemList
    end
  end
  local prefabHelper = self.m_pnl_itemgift:GetComponent("PrefabHelper")
  utils.ShowPrefabHelper(prefabHelper, function(go, index, cfg)
    local transform = go.transform
    transform.localScale = Vector3.one
    local c_pickup_itemnormal = transform:Find("m_itemgift").gameObject
    local m_img_square = transform:Find("m_img_square").gameObject
    local m_img_choose = transform:Find("m_img_choose").gameObject
    local m_img_switch = transform:Find("m_img_switch").gameObject
    if table.getn(cfg) == 0 then
      UILuaHelper.SetActive(c_pickup_itemnormal, false)
      UILuaHelper.SetActive(m_img_square, false)
      UILuaHelper.SetActive(m_img_choose, true)
      UILuaHelper.SetActive(m_img_switch, false)
      return
    end
    local giftIdx = giftInfo and giftInfo.mGridRewardIndex[index + 2] or nil
    if not giftIdx then
      local emptyBtn = transform:Find("m_img_square"):GetComponent("Button")
      emptyBtn.onClick:RemoveAllListeners()
      emptyBtn.onClick:AddListener(function()
        self:OnBtnChooseClicked()
      end)
      UILuaHelper.SetActive(m_img_square, true)
      UILuaHelper.SetActive(m_img_choose, false)
      UILuaHelper.SetActive(c_pickup_itemnormal, false)
      UILuaHelper.SetActive(m_img_switch, false)
      return
    end
    local pickUpReward = cfg[giftIdx + 1]
    pickUpReward = pickUpReward or cfg[1]
    local item = self:createCommonItem(c_pickup_itemnormal)
    local processData = ResourceUtil:GetProcessRewardData(pickUpReward, {is_have_get = isSoldOut})
    item:SetItemInfo(processData)
    item:SetItemIconClickCB(function(itemID, itemNum)
      self:OnBtnChooseClicked()
    end)
    UILuaHelper.SetActive(m_img_square, false)
    UILuaHelper.SetActive(m_img_choose, false)
    UILuaHelper.SetActive(c_pickup_itemnormal, true)
    UILuaHelper.SetActive(m_img_switch, not isSoldOut)
  end, mGridCfg)
end

function PickupGiftSubPanel:OnClickTab(idx)
  if self.iCurSelectIdx == idx then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "activity_panel_pickup_sweitch")
  local oldChoose = self.iCurSelectIdx
  self.iCurSelectIdx = idx
  self:RefreshChooseItemUI(oldChoose)
  self:RefreshInfo()
end

function PickupGiftSubPanel:OnBtnClicksel1Clicked()
  self:OnClickTab(1)
end

function PickupGiftSubPanel:OnBtnClicksel2Clicked()
  self:OnClickTab(2)
end

function PickupGiftSubPanel:OnBtnClicksel3Clicked()
  self:OnClickTab(3)
end

function PickupGiftSubPanel:OnBtnChooseClicked()
  self:OpenPickUpPop(self.iCurSelectIdx)
end

function PickupGiftSubPanel:OpenPickUpPop(idx)
  local giftInfo = self.giftInfo[self.giftList[idx].iGiftId]
  StackPopup:Push(UIDefines.ID_FORM_PICKUPWINDOW_NEW, {
    giftCfg = self.giftList[idx],
    giftInfo = giftInfo,
    activity = self.activity
  })
end

function PickupGiftSubPanel:OnBtntipspickupClicked()
  utils.popUpDirectionsUI({tipsID = 1199})
end

function PickupGiftSubPanel:OnRefreshGiftPoint()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  if not self.giftList[self.iCurSelectIdx] or not self.giftList[self.iCurSelectIdx].sProductId then
    self.m_packgift_point:SetActive(false)
    return
  end
  self.m_packgift_point:SetActive(true)
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(self.giftList[self.iCurSelectIdx].sProductId)
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

function PickupGiftSubPanel:OnBtnbuyClicked()
  if not (self.giftList[self.iCurSelectIdx] and self.giftList[self.iCurSelectIdx].iGiftId) or not self.giftInfo[self.giftList[self.iCurSelectIdx].iGiftId] then
    log.error("PickupGiftSubPanel buy error")
    return
  end
  local giftCfg = self.giftList[self.iCurSelectIdx]
  local giftInfo = self.giftInfo[giftCfg.iGiftId]
  local maxCount = table.getn(giftCfg.stGrids.mGridCfg)
  local count = table.getn(giftInfo.mGridRewardIndex)
  if maxCount > count then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52004))
    return
  end
  local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftCfg.iBuyLimit
  if isSoldOut then
    return
  end
  local baseStoreBuyParam = MTTDProto.CmdActPickupGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.activity:getID()
  baseStoreBuyParam.mGridRewardIndex = giftInfo.mGridRewardIndex
  local storeParam = sdp.pack(baseStoreBuyParam)
  local reward = {}
  for index, v in ipairs(giftInfo.mGridRewardIndex) do
    if giftCfg.stGrids and giftCfg.stGrids.mGridCfg and giftCfg.stGrids.mGridCfg[index] and giftCfg.stGrids.mGridCfg[index][v + 1] then
      reward[#reward + 1] = giftCfg.stGrids.mGridCfg[index][v + 1]
    end
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(giftCfg.sProductId)
  if isShowPoint then
    reward[#reward + 1] = pointReward
  end
  local ProductInfo = {
    productId = giftCfg.sProductId,
    productSubId = giftCfg.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPickupGift,
    productName = self.activity:getLangText(giftCfg.sGiftName) or "",
    productDesc = self.activity:getLangText(giftCfg.sGiftDesc) or "",
    rewardList = reward
  }
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

return PickupGiftSubPanel
