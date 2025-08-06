local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallMonthlyCardMainSubPanel = class("MallMonthlyCardMainSubPanel", UISubPanelBase)

function MallMonthlyCardMainSubPanel:OnInit()
  self:RefreshByConfig()
  self:RefreshByUserInfo()
end

function MallMonthlyCardMainSubPanel:OnFreshData()
  local config = self.m_panelData.storeData
  local loginContext = CS.LoginContext.GetContext()
  self.m_txt_uid_Text.text = "UID:" .. loginContext.AccountID
end

function MallMonthlyCardMainSubPanel:OnInactivePanel()
  MonthlyCardManager:EnableExhibitionRewardInHall(true)
  self:clearEventListener()
end

function MallMonthlyCardMainSubPanel:OnActivePanel()
  self:RefreshByUserInfo()
  self:addEventListener("eGameEvent_MonthlyCardRefresh", handler(self, self.RefreshByUserInfo))
end

function MallMonthlyCardMainSubPanel:RefreshByConfig()
  local whiteElement = MonthlyCardManager:GetSmallCardCfg()
  local blackElement = MonthlyCardManager:GetBigCardCfg()
  if whiteElement:GetError() or blackElement:GetError() then
    return
  end
  self.m_white_name_Text.text = whiteElement.m_mItemName
  local whitCardReward = MonthlyCardManager:GetRewardCfg(true, false)
  local whitCardDailyReward = MonthlyCardManager:GetRewardCfg(true, true)
  ResourceUtil:CreatIconById(self.m_white_reward_icon_Image, whitCardReward[1])
  ResourceUtil:CreatIconById(self.m_white_daily_reward_icon_Image, whitCardDailyReward[1])
  self.m_white_reward_num_Text.text = whitCardReward[2]
  self.m_white_daily_reward_num_Text.text = whitCardDailyReward[2]
  self.m_txt_white_price_Text.text = IAPManager:GetProductPrice(whiteElement.m_ProductID, true)
  self.m_black_name_Text.text = blackElement.m_mItemName
  self.m_txt_black_price_Text.text = IAPManager:GetProductPrice(blackElement.m_ProductID, true)
  local blackCardReward = MonthlyCardManager:GetRewardCfg(false, false)
  local blackCardDailyReward = MonthlyCardManager:GetRewardCfg(false, true)
  ResourceUtil:CreatIconById(self.m_black_reward_icon_Image, blackCardReward[1])
  self.m_black_reward_num_Text.text = blackCardReward[2]
  ResourceUtil:CreatIconById(self.m_btn_BlackDailyReward_Image, blackCardDailyReward[1])
end

function MallMonthlyCardMainSubPanel:RefreshByUserInfo()
  local smallCardDays = MonthlyCardManager:GetSmallCardRemainingDayText()
  if smallCardDays == nil then
    self.m_white_lock:SetActive(true)
    self.m_white_time:SetActive(false)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.m_white_lock.transform)
  else
    self.m_white_lock:SetActive(false)
    self.m_white_time:SetActive(true)
    self.m_white_valid_time_Text.text = smallCardDays
  end
  local bigCardDays = MonthlyCardManager:GetBigCardRemainingDayText()
  if bigCardDays == nil then
    self.m_black_lock:SetActive(true)
    self.m_black_time:SetActive(false)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.m_black_lock.transform)
  else
    self.m_black_lock:SetActive(false)
    self.m_black_time:SetActive(true)
    self.m_black_valid_time_Text.text = bigCardDays
  end
  self:OnRefreshGiftPointAll()
end

function MallMonthlyCardMainSubPanel:OnBtnWhiteRewardClicked()
  local whiteElement = MonthlyCardManager:GetSmallCardCfg()
  if whiteElement:GetError() then
    return
  end
  local rewardCfg = MonthlyCardManager:GetRewardCfg(true, false)
  utils.openItemDetailPop({
    iID = rewardCfg[1],
    iNum = rewardCfg[2]
  })
end

function MallMonthlyCardMainSubPanel:OnBtnWhiteDailyRewardClicked()
  local whiteElement = MonthlyCardManager:GetSmallCardCfg()
  if whiteElement:GetError() then
    return
  end
  local rewardCfg = MonthlyCardManager:GetRewardCfg(true, true)
  utils.openItemDetailPop({
    iID = rewardCfg[1],
    iNum = rewardCfg[2]
  })
end

function MallMonthlyCardMainSubPanel:OnBtnWhiteBuyClicked()
  MonthlyCardManager:BuyCard(true, self.m_panelData.storeData.iStoreId)
end

function MallMonthlyCardMainSubPanel:OnBtnBlackRewardClicked()
  local blackElement = MonthlyCardManager:GetBigCardCfg()
  if blackElement:GetError() then
    return
  end
  local rewardCfg = MonthlyCardManager:GetRewardCfg(false, false)
  utils.openItemDetailPop({
    iID = rewardCfg[1],
    iNum = rewardCfg[2]
  })
end

function MallMonthlyCardMainSubPanel:OnBtnBlackDailyRewardClicked()
  local blackElement = MonthlyCardManager:GetBigCardCfg()
  if blackElement:GetError() then
    return
  end
  local rewardCfg = MonthlyCardManager:GetRewardCfg(false, true)
  utils.openItemDetailPop({
    iID = rewardCfg[1],
    iNum = rewardCfg[2]
  })
end

function MallMonthlyCardMainSubPanel:OnBtnBlackBuyClicked()
  MonthlyCardManager:BuyCard(false, self.m_panelData.storeData.iStoreId)
end

function MallMonthlyCardMainSubPanel:OnBuyResult(isSuccess, msg, res)
  if not isSuccess then
    if not res then
      NetworkManager:OnRpcCallbackFail({
        rspcode = msg.rspcode
      })
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, res)
    end
  end
end

function MallMonthlyCardMainSubPanel:OnRefreshGiftPointAll()
  if utils.isNull(self.m_packgift_point) then
    return
  end
  self:OnRefreshGiftPoint()
  self:OnRefreshGiftPoint1()
end

function MallMonthlyCardMainSubPanel:OnRefreshGiftPoint()
  local whiteElement = MonthlyCardManager:GetSmallCardCfg()
  if whiteElement:GetError() or not whiteElement.m_ProductID then
    self.m_packgift_point:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(whiteElement.m_ProductID)
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

function MallMonthlyCardMainSubPanel:OnRefreshGiftPoint1()
  if utils.isNull(self.m_packgift_point1) then
    return
  end
  local blackElement = MonthlyCardManager:GetBigCardCfg()
  if blackElement:GetError() or not blackElement.m_ProductID then
    self.m_packgift_point1:SetActive(false)
    return
  end
  local isShowPoint, pointReward = ActivityManager:GetPayPointsCondition(blackElement.m_ProductID)
  local pointParams = {pointReward = pointReward}
  if isShowPoint then
    self.m_packgift_point1:SetActive(true)
    if self.m_paidGiftPoint1 then
      self.m_paidGiftPoint1:SetFreshInfo(pointParams)
    else
      self.m_paidGiftPoint1 = self:createPackGiftPoint(self.m_packgift_point1, pointParams)
    end
  else
    self.m_packgift_point1:SetActive(false)
  end
end

return MallMonthlyCardMainSubPanel
