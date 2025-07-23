local Form_Push_Gift_Reserve = class("Form_Push_Gift_Reserve", require("UI/UIFrames/Form_Push_Gift_ReserveUI"))
local defaultIndex = 1

function Form_Push_Gift_Reserve:SetInitParam(param)
end

function Form_Push_Gift_Reserve:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_packList = nil
  self.m_curSelectPackData = nil
  self.m_rewardItemCache = {}
  self.m_tempRewardItem = self.m_pnl_reward.transform:Find("c_common_item").gameObject
  self.m_rewardItemParent = self.m_pnl_reward.transform
  self.m_pointItemParent = self.m_pnl_switch.transform
  self.m_pnl_switch:SetActive(true)
end

function Form_Push_Gift_Reserve:OnActive()
  self.super.OnActive(self)
  self.m_isPush = false
  self.m_curSelectIndex = defaultIndex
  self.m_curSelectPackData = {}
  self:AddEventListeners()
  self:OnRefreshData()
  self:OnRefreshUI(true)
end

function Form_Push_Gift_Reserve:OnInactive()
  self.super.OnInactive(self)
  self:ClearTimer()
  PushFaceManager:CheckShowNextPopPanel()
  PushFaceManager:CheckShowNextPopPanel()
  self:RemoveAllEventListeners()
end

function Form_Push_Gift_Reserve:OnDestroy()
end

function Form_Push_Gift_Reserve:OnRefreshData()
  if self.m_csui.m_param then
    self.m_activityId = tonumber(self.m_csui.m_param.activityId)
    if self.m_csui.m_param.isPush then
      self.m_isPush = true
    end
    self.m_csui.m_param = nil
  end
  if not self.m_activityId then
    self:CloseForm()
    return
  end
  self.m_activity = ActivityManager:GetActivityByID(self.m_activityId)
  if not self and not self.m_activity then
    self:CloseForm()
    return
  end
  self.m_packList = self.m_activity:GetPackList()
  if self.m_isPush then
    self.m_curSelectIndex = #self.m_packList or defaultIndex
  end
end

function Form_Push_Gift_Reserve:OnRefreshUI(isPlayAnim)
  if isPlayAnim then
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, "Push_Gift_Reserve_in")
  end
  self.m_curSelectPackData = self.m_packList[self.m_curSelectIndex]
  if not self.m_curSelectPackData then
    self:CloseForm()
    return
  end
  local giftInfo = self.m_curSelectPackData.GiftInfo
  self.m_img_bg02:SetActive(tonumber(giftInfo.iPushStyle) == 1)
  self.m_img_bg:SetActive(tonumber(giftInfo.iPushStyle) == 2)
  self.m_txt_title_num_shadow01_Text.text = giftInfo.iDiscount .. "<size=36>%</size>"
  self.m_txt_title_num01_Text.text = giftInfo.iDiscount .. "<size=36>%</size>"
  self:DealCountDownTimer()
  self:RefreshReward()
  self:RefreshPrice()
  self:RefreshPoint()
  self:UpdateArrowVisibility()
end

function Form_Push_Gift_Reserve:DealCountDownTimer()
  local giftInfo = self.m_curSelectPackData.GiftInfo
  local productInfo = self.m_curSelectPackData.ProductInfo
  self.m_endTime = productInfo.iTriggerTime + giftInfo.iGiftDuration
  local timeFirst = self.m_endTime - TimeUtil:GetServerTimeS()
  self.m_txt_remainingtime01_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(timeFirst)
  self:ClearTimer()
  self.m_countDownTimer = TimeService:SetTimer(1, -1, function()
    local time = self.m_endTime - TimeUtil:GetServerTimeS()
    self.m_txt_remainingtime01_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(time)
    if time <= 0 then
      self:OnRefreshData()
      self:OnRefreshUI()
    end
  end)
end

function Form_Push_Gift_Reserve:RefreshReward()
  local childCount = self.m_rewardItemParent.childCount
  for i = 0, childCount - 1 do
    local child = self.m_rewardItemParent:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local rewardList = self.m_curSelectPackData.GiftInfo.stItem
  if childCount <= #rewardList then
    for index = childCount, #rewardList do
      GameObject.Instantiate(self.m_tempRewardItem, self.m_rewardItemParent)
    end
  end
  for i, v in ipairs(rewardList) do
    local child = self.m_rewardItemParent:GetChild(i - 1).gameObject
    child:SetActive(true)
    self:OnInitTabItem(child, v)
  end
end

function Form_Push_Gift_Reserve:OnInitTabItem(go, reward)
  local itemIcon = self:createCommonItem(go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = reward.iID,
    iNum = reward.iNum
  })
  itemIcon:SetItemInfo(processData)
  itemIcon:SetItemIconClickCB(function(itemID, itemNum)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

function Form_Push_Gift_Reserve:RefreshPrice()
  self.m_txt_Text.text = IAPManager:GetProductPrice(self.m_curSelectPackData.GiftInfo.sProductId, true)
end

function Form_Push_Gift_Reserve:RefreshPoint()
  self.tempPointCache = {}
  local childCount = self.m_pointItemParent.childCount
  for i = 0, childCount - 1 do
    local child = self.m_pointItemParent:GetChild(i)
    child.gameObject:SetActive(false)
    child.transform:Find("m_img_point_dark").gameObject:SetActive(false)
    self.tempPointCache[#self.tempPointCache + 1] = child.gameObject
  end
  for i = childCount + 1, #self.m_packList do
    local pointObj = GameObject.Instantiate(self.m_img_point, self.m_pointItemParent)
    self.tempPointCache[#self.tempPointCache + 1] = pointObj
  end
  for index, _ in ipairs(self.m_packList) do
    local pointObj = self.tempPointCache[index]
    pointObj:SetActive(true)
    pointObj.transform:Find("m_img_point_dark").gameObject:SetActive(self.m_curSelectIndex ~= index)
  end
end

function Form_Push_Gift_Reserve:ClearTimer()
  if self.m_countDownTimer ~= nil then
    TimeService:KillTimer(self.m_countDownTimer)
    self.m_countDownTimer = nil
  end
end

function Form_Push_Gift_Reserve:OnBtnarrowlClicked()
  self.m_curSelectIndex = self.m_curSelectIndex - 1
  if self.m_curSelectIndex < 1 then
    self.m_curSelectIndex = #self.m_packList
  end
  self:UpdateArrowVisibility()
  self:OnRefreshUI(true)
end

function Form_Push_Gift_Reserve:OnBtnarrowrClicked()
  self.m_curSelectIndex = self.m_curSelectIndex + 1
  if self.m_curSelectIndex > #self.m_packList then
    self.m_curSelectIndex = 1
  end
  self:UpdateArrowVisibility()
  self:OnRefreshUI(true)
end

function Form_Push_Gift_Reserve:UpdateArrowVisibility()
  self.m_btn_arrow_l:SetActive(self.m_curSelectIndex > 1)
  self.m_btn_arrow_r:SetActive(self.m_curSelectIndex < #self.m_packList)
end

function Form_Push_Gift_Reserve:OnBtncloseClicked()
  self:CloseForm()
end

function Form_Push_Gift_Reserve:OnBtnpushgiftClicked()
  local baseStoreBuyParam = MTTDProto.CmdActEmergencyGiftBuyParam()
  baseStoreBuyParam.iActivityId = self.m_activity:getID()
  local storeParam = sdp.pack(baseStoreBuyParam)
  local productNameTemp = "Lucky Gift"
  local productDescTemp = "Lucky Gift"
  if ChannelManager:IsChinaChannel() then
    productNameTemp = "神秘好礼"
    productDescTemp = "神秘好礼"
  end
  if self.m_curSelectPackData then
    local ProductInfo = {
      productId = self.m_curSelectPackData.GiftInfo.sProductId,
      productSubId = self.m_curSelectPackData.ProductInfo.iSubProductId,
      iStoreType = MTTDProto.IAPStoreType_ActEmergencyGift,
      rewardList = self.m_curSelectPackData.GiftInfo.stItem,
      productName = productNameTemp,
      productDesc = productDescTemp
    }
    IAPManager:BuyProductByStoreType(ProductInfo, storeParam, handler(self, self.OnBuyResult))
  end
end

function Form_Push_Gift_Reserve:OnBuyResult(isSuccess, param1, param2)
  if not isSuccess then
    IAPManager:OnCallbackFail(param1, param2)
    return
  end
  self.m_curSelectIndex = 1
  self:OnRefreshData()
  self:OnRefreshUI(false)
  self:broadcastEvent("eGameEvent_Activity_EmergencyGiftPush", {isPush = false})
end

function Form_Push_Gift_Reserve:AddEventListeners()
  self:addEventListener("eGameEvent_Buy_EmergencyGift_Success", function(param)
    self.m_curSelectIndex = defaultIndex
    self:OnRefreshData()
    self:OnRefreshUI(false)
    self:broadcastEvent("eGameEvent_Activity_EmergencyGiftPush", {isPush = false})
  end)
end

function Form_Push_Gift_Reserve:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Push_Gift_Reserve:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Push_Gift_Reserve", Form_Push_Gift_Reserve)
return Form_Push_Gift_Reserve
