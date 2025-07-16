local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PickupGiftSubPanel = class("PickupGiftSubPanel", UISubPanelBase)

function PickupGiftSubPanel:OnInit()
end

local iMaxGiftNum = 3

function PickupGiftSubPanel:OnInactivePanel()
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
      self["m_txt_sale_num" .. i .. "_Text"].text = giftData.iDiscount .. "%"
      self["m_img_bk" .. i]:SetActive(true)
    else
      self["m_img_bk" .. i]:SetActive(false)
    end
    local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftData.iBuyLimit
    iDefaultIdx = iDefaultIdx or not isSoldOut and i
    self["m_txt_normal" .. i]:SetActive(not isSoldOut)
    self["m_soldout" .. i]:SetActive(isSoldOut)
    self["m_img_icon_soldout" .. i]:SetActive(isSoldOut)
    if 0 < giftData.iBuyLimit then
      local v = giftData.iBuyLimit - giftInfo.iBoughtNum
      if v < 0 then
        v = 0
      end
      self["m_txt_limit_num" .. i .. "_Text"].text = string.format("%d/%d", v, giftData.iBuyLimit)
    else
      self["m_txt_limit_num" .. i .. "_Text"].text = ""
    end
  end
  self.iCurSelectIdx = iDefaultIdx or self.iCurSelectIdx or 1
  self:OnClickTab(self.iCurSelectIdx)
  for i = 1, iMaxGiftNum do
    self["m_img_select" .. i]:SetActive(i == self.iCurSelectIdx)
    if i == self.iCurSelectIdx then
      UILuaHelper.PlayAnimationByName(self["m_pnl_item" .. i], "activity_panel_pickup_select")
    else
      UILuaHelper.StopAnimation(self["m_pnl_item" .. i])
    end
  end
  UILuaHelper.SetAtlasSprite(self.m_item_big_icon_Image, self.giftList[self.iCurSelectIdx].sIcon)
  self:RefreshInfo()
end

function PickupGiftSubPanel:RefreshInfo()
  if not self.giftList or not self.giftInfo then
    return
  end
  local giftData = self.giftList[self.iCurSelectIdx]
  local giftInfo = self.giftInfo[giftData.iGiftId]
  local isSoldOut = giftInfo and giftInfo.iBoughtNum >= giftData.iBuyLimit
  if isSoldOut then
    self.m_btn_soldout:SetActive(true)
    self.m_btn_buy:SetActive(false)
    self.m_img_soldout:SetActive(true)
  else
    self.m_btn_soldout:SetActive(false)
    self.m_btn_buy:SetActive(true)
    self.m_img_soldout:SetActive(false)
    self.m_txt_upgrade_Text.text = IAPManager:GetProductPrice(giftData.sProductId, true)
  end
  local prefabHelper = self.m_pnl_itemgift:GetComponent("PrefabHelper")
  utils.ShowPrefabHelper(prefabHelper, function(go, index, cfg)
    local transform = go.transform
    transform.localScale = Vector3.one
    local c_pickup_itemnormal = transform:Find("c_common_item").gameObject
    local giftIdx = giftInfo and giftInfo.mGridRewardIndex[index + 1] or nil
    if not giftIdx then
      local emptyBtn = transform:Find("c_img_square"):GetComponent("Button")
      emptyBtn.onClick:RemoveAllListeners()
      emptyBtn.onClick:AddListener(function()
        self:OnBtnbuyClicked()
      end)
      c_pickup_itemnormal:SetActive(false)
      return
    end
    local pickUpReward = cfg[giftIdx + 1]
    pickUpReward = pickUpReward or cfg[1]
    c_pickup_itemnormal:SetActive(true)
    local item = self:createCommonItem(c_pickup_itemnormal)
    local processData = ResourceUtil:GetProcessRewardData(pickUpReward)
    item:SetItemInfo(processData)
    item:SetItemIconClickCB(function(itemID, itemNum)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
  end, giftData.stGrids.mGridCfg)
end

function PickupGiftSubPanel:OnClickTab(idx)
  if self.iCurSelectIdx == idx then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_item_big_icon_Image, self.giftList[idx].sIcon)
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "activity_panel_pickup_sweitch")
  self.iCurSelectIdx = idx
  for i = 1, iMaxGiftNum do
    self["m_img_select" .. i]:SetActive(i == idx)
    if i == idx then
      UILuaHelper.PlayAnimationByName(self["m_pnl_item" .. i], "activity_panel_pickup_select")
    else
      UILuaHelper.StopAnimation(self["m_pnl_item" .. i])
    end
  end
  self:RefreshInfo()
end

function PickupGiftSubPanel:OnBtnClick1Clicked()
  self:OnClickTab(1)
end

function PickupGiftSubPanel:OnBtnClick2Clicked()
  self:OnClickTab(2)
end

function PickupGiftSubPanel:OnBtnClick3Clicked()
  self:OnClickTab(3)
end

function PickupGiftSubPanel:OnBtnbuyClicked()
  self:OpenPickUpPop(self.iCurSelectIdx)
end

function PickupGiftSubPanel:OpenPickUpPop(idx)
  local giftInfo = self.giftInfo[self.giftList[idx].iGiftId]
  local isSoldOut = giftInfo and giftInfo.iBoughtNum >= self.giftList[idx].iBuyLimit
  if isSoldOut then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_PICKUPWINDOW_NEW, {
    giftCfg = self.giftList[idx],
    giftInfo = giftInfo,
    activity = self.activity
  })
end

function PickupGiftSubPanel:OnBtntipspickupClicked()
  utils.popUpDirectionsUI({tipsID = 1199})
end

return PickupGiftSubPanel
