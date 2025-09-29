local UISubPanelBase = require("UI/Common/UISubPanelBase")
local MallMonthlyCardMainSubPanelNew = class("MallMonthlyCardMainSubPanelNew", UISubPanelBase)

function MallMonthlyCardMainSubPanelNew:OnInit()
  self.m_paidGiftPoint = self:createPackGiftPoint(self.m_packgift_point)
  self.m_paidGiftPoint2 = self:createPackGiftPoint(self.m_packgift_point2)
  self.m_paidGiftPoint3 = self:createPackGiftPoint(self.m_packgift_point3)
  self:RefreshByConfig()
  self:RefreshByUserInfo()
end

function MallMonthlyCardMainSubPanelNew:OnFreshData()
end

function MallMonthlyCardMainSubPanelNew:OnInactivePanel()
  MonthlyCardManager:EnableExhibitionRewardInHall(true)
  self:clearEventListener()
end

function MallMonthlyCardMainSubPanelNew:OnActivePanel()
  self:RefreshByUserInfo()
  self:addEventListener("eGameEvent_MonthlyCardRefresh", handler(self, self.RefreshByUserInfo))
end

function MallMonthlyCardMainSubPanelNew:RefreshByConfig()
  local whiteElement = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Small)
  local middleElement = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Middle)
  local blackElement = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Big)
  if whiteElement:GetError() or blackElement:GetError() or middleElement:GetError() then
    return
  end
  self.m_white_name_Text.text = whiteElement.m_mItemName
  local whitCardReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Small, false)
  local whitCardDailyReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Small, true)
  ResourceUtil:CreatIconById(self.m_white_reward_icon_Image, whitCardReward[1])
  ResourceUtil:CreatIconById(self.m_white_daily_reward_icon_Image, whitCardDailyReward[1])
  self.m_white_reward_num_Text.text = whitCardReward[2]
  self.m_white_daily_reward_num_Text.text = whitCardDailyReward[2]
  self.m_txt_white_price_Text.text = IAPManager:GetProductPrice(whiteElement.m_ProductID, true)
  self.m_txt_profit1_Text.text = whiteElement.m_DiscountNum .. "%"
  self.m_black_name_Text.text = blackElement.m_mItemName
  self.m_txt_black_price_Text.text = IAPManager:GetProductPrice(blackElement.m_ProductID, true)
  local blackCardReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Big, false)
  local blackCardDailyReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Big, true)
  ResourceUtil:CreatIconById(self.m_black_reward_icon_Image, blackCardReward[1])
  self.m_black_reward_num_Text.text = blackCardReward[2]
  ResourceUtil:CreatIconById(self.m_btn_BlackDailyReward_Image, blackCardDailyReward[1])
  self.m_txt_profit3_Text.text = blackElement.m_DiscountNum .. "%"
  self.m_white_name2_Text.text = middleElement.m_mItemName
  self.m_txt_white_price2_Text.text = IAPManager:GetProductPrice(middleElement.m_ProductID, true)
  local white2CardReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Middle, false)
  local white2CardDailyReward = MonthlyCardManager:GetRewardCfg(GlobalConfig.MonthlyType.Middle, true)
  ResourceUtil:CreatIconById(self.m_white_reward_icon2_Image, white2CardReward[1])
  self.m_white_reward_num2_Text.text = white2CardReward[2]
  ResourceUtil:CreatIconById(self.m_white_daily_reward_icon2_Image, white2CardDailyReward[1])
  self.m_white_daily_reward_num2_Text.text = white2CardDailyReward[2]
  self.m_txt_profit2_Text.text = middleElement.m_DiscountNum .. "%"
  self.m_paidGiftPoint:SetFreshInfo({
    productId = whiteElement.m_ProductID
  })
  self.m_paidGiftPoint2:SetFreshInfo({
    productId = middleElement.m_ProductID
  })
  self.m_paidGiftPoint3:SetFreshInfo({
    productId = blackElement.m_ProductID
  })
end

function MallMonthlyCardMainSubPanelNew:RefreshByUserInfo()
  local addCardId = MonthlyCardManager:GetAddCardId()
  local smallCardDays = MonthlyCardManager:GetCardRemainingDayTextByType(GlobalConfig.MonthlyType.Small)
  local isPrivilege, num = MonthlyCardManager:IsPrivilegeEffect()
  MonthlyCardManager:SetAddCardId(-1)
  if smallCardDays == nil then
    self.m_white_lock:SetActive(true)
    self.m_white_time:SetActive(false)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.m_white_lock.transform)
    self.m_UIEff_Unlock01_loop:SetActive(false)
  else
    self.m_white_lock:SetActive(false)
    self.m_white_time:SetActive(true)
    self.m_white_valid_time_Text.text = smallCardDays
    self.m_UIEff_Unlock01_loop:SetActive(true)
    local cardCfg = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Small)
    if cardCfg.m_GoodsID == addCardId then
      UILuaHelper.PlayAnimationByName(self.m_white_time, "Mall_MonthlyCardMain_TimeRefresh")
      UILuaHelper.PlayAnimationByName(self.m_btn_white, "Mall_MonthlyCardMain_Unlock01")
      if isPrivilege then
        UILuaHelper.PlayAnimationByName(self.m_pnl_info, "Mall_MallMonthCardMain_pnl_unlock")
      end
    end
  end
  local bigCardDays = MonthlyCardManager:GetCardRemainingDayTextByType(GlobalConfig.MonthlyType.Big)
  if bigCardDays == nil then
    self.m_black_lock:SetActive(true)
    self.m_black_time:SetActive(false)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.m_black_lock.transform)
    self.m_UIEff_Unlock03_loop:SetActive(false)
  else
    self.m_black_lock:SetActive(false)
    self.m_black_time:SetActive(true)
    self.m_black_valid_time_Text.text = bigCardDays
    self.m_UIEff_Unlock03_loop:SetActive(true)
    local cardCfg = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Big)
    if cardCfg.m_GoodsID == addCardId then
      UILuaHelper.PlayAnimationByName(self.m_black_time, "Mall_MonthlyCardMain_TimeRefresh")
      UILuaHelper.PlayAnimationByName(self.m_btn_black, "Mall_MonthlyCardMain_Unlock03")
      if isPrivilege then
        UILuaHelper.PlayAnimationByName(self.m_pnl_info, "Mall_MallMonthCardMain_pnl_unlock")
      end
    end
  end
  local middleCardDays = MonthlyCardManager:GetCardRemainingDayTextByType(GlobalConfig.MonthlyType.Middle)
  if middleCardDays == nil then
    self.m_white_lock2:SetActive(true)
    self.m_white_time2:SetActive(false)
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.m_white_lock2.transform)
    self.m_UIEff_Unlock02_loop:SetActive(false)
  else
    self.m_white_lock2:SetActive(false)
    self.m_white_time2:SetActive(true)
    self.m_white_valid_time2_Text.text = middleCardDays
    self.m_UIEff_Unlock02_loop:SetActive(true)
    local cardCfg = MonthlyCardManager:GetMonthlyCardByType(GlobalConfig.MonthlyType.Middle)
    if cardCfg.m_GoodsID == addCardId then
      UILuaHelper.PlayAnimationByName(self.m_white_time2, "Mall_MonthlyCardMain_TimeRefresh")
      UILuaHelper.PlayAnimationByName(self.m_btn_white2, "Mall_MonthlyCardMain_Unlock02")
      if isPrivilege then
        UILuaHelper.PlayAnimationByName(self.m_pnl_info, "Mall_MallMonthCardMain_pnl_unlock")
      end
    end
  end
  self.m_img_bg_normal:SetActive(not isPrivilege)
  self.m_img_bg_unlock:SetActive(isPrivilege)
  self.m_z_txt_lock:SetActive(not isPrivilege)
  self.m_icon_info_normal:SetActive(not isPrivilege)
  self.m_z_txt_unlock:SetActive(isPrivilege)
  self.m_icon_info_unlock:SetActive(isPrivilege)
  local numTxt = GlobalConfig.MonthlyCardPrivilege
  if not isPrivilege then
    numTxt = num
  end
  self.m_txt_info_Text.text = tostring(numTxt) .. "/" .. GlobalConfig.MonthlyCardPrivilege
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteRewardClicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Small, false)
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteDailyRewardClicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Small, true)
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteBuyClicked()
  MonthlyCardManager:BuyCard(GlobalConfig.MonthlyType.Small, self.m_panelData.storeData.iStoreId)
end

function MallMonthlyCardMainSubPanelNew:OnBtnBlackRewardClicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Big, false)
end

function MallMonthlyCardMainSubPanelNew:OnBtnBlackDailyRewardClicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Big, true)
end

function MallMonthlyCardMainSubPanelNew:OnBtnBlackBuyClicked()
  MonthlyCardManager:BuyCard(GlobalConfig.MonthlyType.Big, self.m_panelData.storeData.iStoreId)
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteReward2Clicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Middle, false)
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteDailyReward2Clicked()
  self:OpenRewardTips(GlobalConfig.MonthlyType.Middle, true)
end

function MallMonthlyCardMainSubPanelNew:OnBtnWhiteBuy2Clicked()
  MonthlyCardManager:BuyCard(GlobalConfig.MonthlyType.Middle, self.m_panelData.storeData.iStoreId)
end

function MallMonthlyCardMainSubPanelNew:OpenRewardTips(cardType, dailyReward)
  local cfg = MonthlyCardManager:GetMonthlyCardByType(cardType)
  if cfg:GetError() then
    return
  end
  local rewardCfg = MonthlyCardManager:GetRewardCfg(cardType, dailyReward)
  utils.openItemDetailPop({
    iID = rewardCfg[1],
    iNum = rewardCfg[2]
  })
end

function MallMonthlyCardMainSubPanelNew:OnBuyResult(isSuccess, msg, res)
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

function MallMonthlyCardMainSubPanelNew:OnBtninfoClicked()
  StackPopup:Push(UIDefines.ID_FORM_MALLMONTHCARDENDPOP)
end

return MallMonthlyCardMainSubPanelNew
