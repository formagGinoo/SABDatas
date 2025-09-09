local UIItemBase = require("UI/Common/UIItemBase")
local PushGiftItem = class("PushGiftItem", UIItemBase)

function PushGiftItem:OnInit()
  self.m_Activity = ActivityManager:GetActivityByType(MTTD.ActivityType_PushGift)
end

function PushGiftItem:OnUpdate(dt)
end

function PushGiftItem:OnFreshData()
  local config = self.m_itemData
  self.m_txt_profit_num_Text.text = tonumber(config.iGiftDiscount) .. "%"
  if config.sIcon ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, config.sIcon)
    UILuaHelper.SetAtlasSprite(self.m_vx_loop_Image, config.sIcon)
  end
  self.m_img_bg1:SetActive(config.sortIndex == 1)
  self.m_img_bg2:SetActive(config.sortIndex == 2)
  self.m_img_bg3:SetActive(config.sortIndex == 3)
  self.m_img_cutline:SetActive(config.sortIndex ~= 3)
  self.m_img_soldoutmask:SetActive(false)
  if config.sProductID == "" then
    self.m_txt_price_Text.text = ConfigManager:GetCommonTextById(20041)
  else
    local goodsData = self.m_Activity:GetGiftDataByGroupAndGiftIndex(config.iTriggerIndex, config.iGiftIndex)
    if goodsData then
      self.m_txt_price_Text.text = IAPManager:GetProductPrice(goodsData.sProductID, true)
    end
  end
  local itemRoot = self.m_pnl_itemgift.transform
  local count = #config.sGiftItems
  self:UpdateChildCount(itemRoot, count)
  for i, v in ipairs(config.sGiftItems) do
    local itemObj = itemRoot:GetChild(i - 1).gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = v.iID,
      iNum = v.iNum
    })
    common_item:SetItemInfo(processItemData)
  end
  self:FreshPointReward()
end

function PushGiftItem:FreshPointReward()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  local productId = self.m_itemData.sProductID
  if not productId then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(productId)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    self.m_packgift_point:SetActive(true)
    if self.m_paidGiftPoint then
      self.m_paidGiftPoint:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point, pointParams)
    end
  else
    self.m_packgift_point:SetActive(false)
  end
end

function PushGiftItem:UpdateChildCount(transform, count)
  local childCount = transform.childCount
  if count > childCount then
    local itemInstance = transform:GetChild(0)
    for i = 1, count - childCount do
      GameObject.Instantiate(itemInstance, transform)
    end
    childCount = count
  end
  for i = 1, childCount do
    local child = transform:GetChild(i - 1)
    child.gameObject:SetActive(count >= i)
  end
end

function PushGiftItem:OnBtnbuyClicked()
  local config = self.m_itemData
  local inTime = TimeUtil:IsInTime(TimeUtil:GetServerTimeS(), config.iExpireTime)
  if not inTime then
    self:broadcastEvent("eGameEvent_Activity_ResetStatus")
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30025)
    return
  end
  if not self.m_Activity then
    return
  end
  local rewardList = {}
  for i, v in ipairs(config.sGiftItems) do
    table.insert(rewardList, v)
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(config.sProductID)
  if isShowPoint then
    table.insert(rewardList, pointReward)
  end
  local ProductInfo = {
    productId = config.sProductID,
    productSubId = config.iSubProductID,
    iStoreType = MTTDProto.IAPStoreType_ActPushGift,
    productName = self.m_Activity:getLangText(config.sGiftName),
    productDesc = self.m_Activity:getLangText(config.sGiftStr),
    giftPackType = 2,
    rewardList = rewardList
  }
  local baseStoreBuyParam = MTTDProto.CmdActPushGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.m_Activity:getID()
  baseStoreBuyParam.sExtraData = config.giftPushForm
  local storeParam = sdp.pack(baseStoreBuyParam)
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
      return
    end
    self:broadcastEvent("eGameEvent_Buy_Gift_Success")
  end)
end

return PushGiftItem
