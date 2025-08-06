local Form_Gacha10 = class("Form_Gacha10", require("UI/UIFrames/Form_Gacha10UI"))

function Form_Gacha10:SetInitParam(param)
end

function Form_Gacha10:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self:HideHeroItems()
end

function Form_Gacha10:OnActive()
  self.super.OnActive(self)
  self.tParam = self.m_csui.m_param
  self.m_gachaIdList = self.tParam.vGachaItem
  self.m_changeItemList = self.tParam.vRealItem
  self.m_scroreItem = self.tParam.vScoreItem
  self.m_discountType = self.tParam.iDiscountType
  self.m_wishCostId = 0
  self.m_wishCostNum = 0
  self.m_costItemId = 0
  self.m_costNum = 0
  self.m_showGachaFreeFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  self:HideHeroItems()
  self:StopSequence()
  self:RefreshHeroList()
  self:RefreshUI()
  self:FreshDiscountBtnShow()
  self:FreshGacha10SpecialBtnShow()
  self:FreshGacha10FreeBtnShow()
  self:AddEventListeners()
  self:FreshMoreBtnStatus()
  local id = table.getn(self.m_gachaIdList) == 1 and 113 or 114
  GlobalManagerIns:TriggerWwiseBGMState(id)
end

function Form_Gacha10:OnInactive()
  self.super.OnInactive(self)
  self.m_wishCostId = 0
  self.m_wishCostNum = 0
  self.m_costItemId = 0
  self.m_costNum = 0
  self.m_btn_panel:SetActive(true)
  self:HideHeroItems()
  self:StopSequence()
  self:RemoveAllEventListeners()
end

function Form_Gacha10:AddEventListeners()
  self:addEventListener("eGameEvent_DoGachaEnd", handler(self, self.OnEventGachaResult))
  self:addEventListener("eGameEvent_PauseGame", handler(self, self.OnPauseGame))
end

function Form_Gacha10:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Gacha10:HideHeroItems()
  for i = 1, 10 do
    if not utils.isNull(self["m_pnl_card" .. i]) then
      UILuaHelper.SetActive(self["m_pnl_card" .. i], false)
    end
  end
end

function Form_Gacha10:OnPauseGame(bPaused)
  if not bPaused then
    self:StopSequence()
    self:RefreshHeroList()
  end
end

function Form_Gacha10:RefreshResourceBar()
  local gachaConfig = GachaManager:GetGachaConfig(self.tParam.iGachaId)
  if gachaConfig then
    local mainCurrency = utils.changeCSArrayToLuaTable(gachaConfig.m_MainCurrency)
    self.m_widgetResourceBar:FreshChangeItems(mainCurrency)
  end
end

function Form_Gacha10:OnEventGachaResult()
  self:CloseForm()
end

function Form_Gacha10:StopSequence()
  if self.m_sequenceList and #self.m_sequenceList > 0 then
    for i = #self.m_sequenceList, 1, -1 do
      if not utils.isNull(self.m_sequenceList[i]) then
        self.m_sequenceList[i]:Kill()
        self.m_sequenceList[i] = nil
      else
        self.m_sequenceList[i] = nil
      end
    end
  end
  self.m_sequenceList = {}
end

local function pendingStoreReview()
  if ChannelManager:IsAndroid() and tonumber(CS.DeviceUtil:GetPackageVersionCode()) < 200000505 then
    return
  end
  local lastPendingTime = CS.UnityEngine.PlayerPrefs.GetInt("lastPendingReviewTime", 0)
  local currentTime = os.time()
  if 900 < currentTime - lastPendingTime then
    CS.UnityEngine.PlayerPrefs.SetInt("lastPendingReviewTime", currentTime)
  else
    return
  end
  local pendingReviewCount = CS.UnityEngine.PlayerPrefs.GetInt("pendingReviewCount", 0)
  if 2 <= pendingReviewCount then
    return
  end
  pendingReviewCount = pendingReviewCount + 1
  CS.UnityEngine.PlayerPrefs.SetInt("pendingReviewCount", pendingReviewCount)
  if ChannelManager:IsAndroid() and not ChannelManager:IsChinaChannel() then
    CS.MSDKManager.Instance:RequestReview()
  elseif ChannelManager:IsChinaChannel() and ChannelManager:IsAndroid() then
    if QSDKManager:IsFunctionSupport(207) then
      utils.CheckAndPushCommonTips({
        tipsID = 1233,
        bLockBack = true,
        func1 = function()
          QSDKManager:CallTapTap()
        end
      })
    end
  elseif ChannelManager:IsIOS() then
    CS.UnityEngine.iOS.Device.RequestStoreReview()
  end
end

function Form_Gacha10:RefreshUI()
  if self.m_scroreItem and self.m_scroreItem[1] then
    ResourceUtil:CreatIconById(self.m_icon_jifen_Image, self.m_scroreItem[1].iID)
    self.m_txt_num_Text.text = self.m_scroreItem[1].iNum
    self.m_tips_jifen:SetActive(true)
  else
    self.m_tips_jifen:SetActive(false)
  end
  local gachaConfig = GachaManager:GetGachaConfig(self.tParam.iGachaId)
  local wishToken = {}
  if self.tParam.iTimesType == 1 then
    wishToken = utils.changeCSArrayToLuaTable(gachaConfig.m_Wish1Token)
  else
    wishToken = utils.changeCSArrayToLuaTable(gachaConfig.m_Wish10Token)
  end
  if not wishToken or #wishToken < 1 then
    wishToken = utils.changeCSArrayToLuaTable(gachaConfig.m_WishCost)
  end
  ResourceUtil:CreateItemIcon(self.m_consume_icon_Image, tonumber(wishToken[1]))
  self.m_consume_quantity_Text.text = wishToken[2]
  local needCount = tonumber(wishToken[2])
  local userNum = ItemManager:GetItemNum(tonumber(wishToken[1]), true)
  if needCount > userNum then
    UILuaHelper.SetColor(self.m_consume_quantity_Text, 178, 69, 43, 1)
  else
    UILuaHelper.SetColor(self.m_consume_quantity_Text, 255, 255, 255, 1)
  end
  local isHide = self:IsHideBtnMore()
  if isHide then
    self.m_btn_more:SetActive(false)
  else
    local flag = UnlockSystemUtil:CheckGachaIsOpenById(self.tParam.iGachaId)
    local gachaCount = GachaManager:GetGachaCountById(self.tParam.iGachaId)
    if not flag or gachaConfig.m_WishTimesRes > 0 and gachaConfig.m_WishTimesRes - gachaCount < self.tParam.iTimesType then
      self.m_btn_more:SetActive(false)
    else
      self.m_btn_more:SetActive(true)
    end
  end
  self.m_btn_panel:SetActive(false)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(0.1 * table.getn(self.m_gachaIdList))
  sequence:OnComplete(function()
    if not utils.isNull(self.m_btn_panel) then
      self.m_btn_panel:SetActive(true)
      if GuideManager:CheckGuideIsActive(82) then
        pendingStoreReview()
      else
        local count = 0
        local mItemInfo = self.tParam.vGachaItem
        for i = 1, table.getn(mItemInfo) do
          local vItemInfo = mItemInfo[i]
          if vItemInfo then
            local heroData = ResourceUtil:GetProcessRewardData(vItemInfo)
            if heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
              count = count + 1
            end
            if 2 <= count then
              pendingStoreReview()
              break
            end
          end
        end
      end
    end
  end)
  sequence:SetAutoKill(true)
  self.m_sequenceList[#self.m_sequenceList + 1] = sequence
  self:RefreshResourceBar()
end

function Form_Gacha10:IsHideBtnMore()
  local hide = false
  if self.m_discountType == GachaManager.GachaDiscountType.Cheap and self.m_showGachaFreeFlag then
    hide = true
  elseif self.m_discountType == GachaManager.GachaDiscountType.Free and self.tParam.iTimesType == 10 and self.m_showGachaFreeFlag then
    local isHave = GachaManager:CheckGacha10HaveFreeTimesById(self.tParam.iGachaId)
    hide = isHave
  end
  if not hide and self.tParam.iTimesType == 10 then
    local isHave = GachaManager:IsHaveSpecialGacha10(self.tParam.iGachaId)
    hide = isHave
  end
  return hide
end

function Form_Gacha10:FreshGacha10FreeBtnShow()
  local isShowFreeBtn = false
  local gachaId = self.tParam.iGachaId
  local iDailyFreeTimesTen = GachaManager:GetGacha10DailyFreeCfgTimesById(gachaId)
  if iDailyFreeTimesTen and 0 < iDailyFreeTimesTen and self.m_showGachaFreeFlag and self.m_discountType == GachaManager.GachaDiscountType.Free and self.tParam.iTimesType == 10 then
    local curDayUseFreeTimes = GachaManager:GetGacha10FreeTimes(gachaId)
    local leftFreeTimes = iDailyFreeTimesTen - curDayUseFreeTimes
    if 0 < leftFreeTimes then
      isShowFreeBtn = true
      local freeNumStr = string.CS_Format(ConfigManager:GetCommonTextById(20348), leftFreeTimes, iDailyFreeTimesTen)
      self.m_txt_dailyfreenum10_Text.text = freeNumStr
      UILuaHelper.SetActive(self.m_pnl_clear10, false)
    end
  end
  UILuaHelper.SetActive(self.m_pnl_dailyfree10, isShowFreeBtn)
end

function Form_Gacha10:FreshGacha10SpecialBtnShow()
  if self.tParam.iTimesType == 10 then
    local have_special10Token, itemId, itemNum, userNum = GachaManager:IsHaveSpecialGacha10(self.tParam.iGachaId)
    if have_special10Token then
      ResourceUtil:CreateItemIcon(self.m_clear_icon10_Image, itemId)
      self.m_clear_num10_Text.text = itemNum .. " / " .. userNum
      UILuaHelper.SetColor(self.m_clear_num10_Text, 247, 246, 244, 1)
      UILuaHelper.SetActive(self.m_pnl_clear10, have_special10Token)
      self.m_txt_clear10_Text.text = string.gsub(ConfigManager:GetCommonTextById(20356), "{0}", ItemManager:GetItemName(itemId))
    end
    UILuaHelper.SetActive(self.m_pnl_clear10, have_special10Token)
  else
    UILuaHelper.SetActive(self.m_pnl_clear10, false)
  end
end

function Form_Gacha10:FreshDiscountBtnShow()
  local gachaConfig = GachaManager:GetGachaConfig(self.tParam.iGachaId)
  local isShowDiscountBtn = false
  if gachaConfig.m_DayCheapTimes > 0 and self.m_discountType == GachaManager.GachaDiscountType.Cheap and self.m_showGachaFreeFlag then
    local wishCost = gachaConfig.m_WishCost
    local wishItemID = wishCost[0]
    ResourceUtil:CreateItemIcon(self.m_count_icon_Image, wishItemID)
    local curDayUseCheapTimes = GachaManager:GetGachaCheapTimes(gachaConfig.m_GachaID)
    local leftCheapTimes = gachaConfig.m_DayCheapTimes - curDayUseCheapTimes
    if 0 < leftCheapTimes then
      isShowDiscountBtn = true
      local wishNum = wishCost[1]
      local cheapCost = gachaConfig.m_CheapCost
      local cheapCostNum = cheapCost[1]
      self.m_count_quantity_Text.text = cheapCostNum
      self.m_txt_dailycount_Text.text = "X" .. wishNum
    end
  end
  UILuaHelper.SetActive(self.m_btn_count, isShowDiscountBtn)
end

function Form_Gacha10:RefreshHeroList()
  local mItemInfo = self.m_gachaIdList
  for i = 1, table.getn(mItemInfo) do
    local vItemInfo = mItemInfo[i]
    if vItemInfo then
      local heroData = ResourceUtil:GetProcessRewardData(vItemInfo)
      if heroData == nil then
        log.error("can not find heroId == " .. tostring(vItemInfo.iID) .. " cfg")
        break
      end
      ResourceUtil:CreatHeroBust(self["m_img_head" .. i .. "_Image"], heroData.data_id)
      local isUp = GachaManager:CheckIsUpHero(self.tParam.iGachaId, heroData.data_id)
      UILuaHelper.SetActive(self["m_icon_up" .. i], isUp)
      UILuaHelper.SetActive(self["m_pnl_card_transform" .. i], false)
      if self.m_changeItemList[i] and self.m_changeItemList[i].iID ~= 0 then
        UILuaHelper.SetActive(self["m_icon_new" .. i], false)
        ResourceUtil:CreatIconById(self["m_item_icon" .. i .. "_Image"], self.m_changeItemList[i].iID)
        self["m_txt_iconnum" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20049), tostring(self.m_changeItemList[i].iNum))
        local sequence2 = Tweening.DOTween.Sequence()
        sequence2:AppendInterval(0.1 * (table.getn(mItemInfo) - 1))
        sequence2:OnComplete(function()
          if not utils.isNull(self["m_pnl_card_transform" .. i]) and not utils.isNull(self.m_btn_panel) then
            UILuaHelper.SetActive(self["m_pnl_card_transform" .. i], true)
            UILuaHelper.PlayAnimationByName(self["m_pnl_card_transform" .. i], "m_pnl_card_transform_in")
            self.m_btn_panel:SetActive(true)
          end
        end)
        sequence2:SetAutoKill(true)
        self.m_sequenceList[#self.m_sequenceList + 1] = sequence2
      else
        UILuaHelper.SetActive(self["m_icon_new" .. i], true)
        UILuaHelper.SetActive(self["m_icon_up" .. i], false)
      end
      UILuaHelper.SetActive(self["m_img_bg_ssr" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      UILuaHelper.SetActive(self["m_img_bg_r" .. i], heroData.quality ~= GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      UILuaHelper.SetActive(self["m_img_r" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
      UILuaHelper.SetActive(self["m_img_sr" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
      UILuaHelper.SetActive(self["m_img_srr" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      UILuaHelper.SetActive(self["m_img_frame_r" .. i], heroData.quality ~= GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      UILuaHelper.SetActive(self["m_img_frame_ssr" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      UILuaHelper.SetActive(self["m_FX_Card_R" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
      UILuaHelper.SetActive(self["m_FX_Card_SR" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
      UILuaHelper.SetActive(self["m_FX_Card_SSR" .. i], heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      self["m_btn_click_hero" .. i .. "_Button"].onClick:RemoveAllListeners()
      UILuaHelper.BindButtonClickManual(self, self["m_btn_click_hero" .. i .. "_Button"], function()
        utils.openItemDetailPop({
          iID = heroData.data_id,
          iNum = 1
        })
      end)
      local isWish = GachaManager:CheckIsWishHero(self.tParam.iGachaId, heroData.data_id)
      UILuaHelper.SetActive(self["m_img_wish" .. i], isWish)
    end
  end
  local animName = 1 < #mItemInfo and "Gacha10_in_10" or "Gacha10_in_1"
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, animName)
end

function Form_Gacha10:OnDestroy()
  self.super.OnDestroy(self)
  self:RemoveAllEventListeners()
end

function Form_Gacha10:IsFullScreen()
  return true
end

function Form_Gacha10:OnBtnyesClicked()
  GachaManager:SetGachaGuideCheckFlag(false)
  GachaManager:SetSkippedHeroShow(false)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHA10)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(52)
end

function Form_Gacha10:OnBtnconsumeClicked()
  if not UnlockSystemUtil:CheckGachaIsOpenById(self.tParam.iGachaId) then
    utils.CheckAndPushCommonTips({
      tipsID = 1209,
      func1 = function()
      end
    })
    return
  end
  GachaManager:SetSkippedInteract(true)
  GachaManager:SetSkippedHeroShow(false)
  UILuaHelper.SetPlayVideoIsSkipped(false)
  local iDiscountType
  if self.m_discountType == GachaManager.GachaDiscountType.Free and self.tParam.iTimesType == 1 and GachaManager:CheckGacha1HaveRedDotById(self.tParam.iGachaId) then
    iDiscountType = self.m_discountType
  end
  local params = {
    iGachaId = self.tParam.iGachaId,
    iTimesType = self.tParam.iTimesType,
    iDiscountType = iDiscountType
  }
  GachaManager:RequestGachaResult(params)
end

function Form_Gacha10:OnBtncountitemClicked()
  GachaManager:SetSkippedInteract(true)
  GachaManager:SetSkippedHeroShow(false)
  UILuaHelper.SetPlayVideoIsSkipped(false)
  local gachaConfig = GachaManager:GetGachaConfig(self.tParam.iGachaId)
  if gachaConfig.m_DayCheapTimes <= 0 then
    return
  end
  local cheapCost = gachaConfig.m_CheapCost
  local needCostItemID = cheapCost[0]
  local needCostNum = cheapCost[1]
  local curHaveNum = ItemManager:GetItemNum(needCostItemID, true)
  if needCostNum > curHaveNum then
    utils.CheckAndPushCommonTips({
      tipsID = 1222,
      func1 = function()
        QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
      end
    })
    return
  end
  local gachaID = self.tParam.iGachaId
  local timesType = self.tParam.iTimesType
  local discountType = self.tParam.iDiscountType
  utils.ShowCommonTipCost({
    beforeItemID = needCostItemID,
    beforeItemNum = needCostNum,
    confirmCommonTipsID = 1206,
    funSure = function()
      local params = {
        iGachaId = gachaID,
        iTimesType = timesType,
        iDiscountType = discountType
      }
      GachaManager:RequestGachaResult(params)
    end
  })
end

function Form_Gacha10:OnBtnclear10Clicked()
  GachaManager:SetSkippedInteract(true)
  GachaManager:SetSkippedHeroShow(false)
  UILuaHelper.SetPlayVideoIsSkipped(false)
  local params = {
    iGachaId = self.tParam.iGachaId,
    iTimesType = self.tParam.iTimesType,
    iDiscountType = self.tParam.iDiscountType
  }
  GachaManager:RequestGachaResult(params)
end

function Form_Gacha10:OnBtndailyfree10Clicked()
  if not GachaManager:GetGacha10DailyFreeActiveById(self.tParam.iGachaId) then
    utils.CheckAndPushCommonTips({
      tipsID = 1231,
      func1 = function()
        self:RefreshUI()
        self:FreshGacha10FreeBtnShow()
      end
    })
    return
  end
  GachaManager:SetSkippedInteract(true)
  GachaManager:SetSkippedHeroShow(false)
  UILuaHelper.SetPlayVideoIsSkipped(false)
  local params = {
    iGachaId = self.tParam.iGachaId,
    iTimesType = self.tParam.iTimesType,
    iDiscountType = self.tParam.iDiscountType
  }
  GachaManager:RequestGachaResult(params)
end

function Form_Gacha10:GetGuideConditionIsOpen(conditionType, conditionParam)
  local flag = false
  if self.tParam.iGachaId then
    local config = GachaManager:GetGachaConfig(self.tParam.iGachaId)
    if config and conditionParam == tostring(config.m_WishListID) then
      local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaWishList)
      if isOpen and config.m_WishListID and config.m_WishListID ~= 0 then
        flag = GachaManager:CheckGachaWishListUnlock(config.m_WishListID)
      end
    end
  end
  return flag
end

function Form_Gacha10:FreshMoreBtnStatus()
  local gachaConfig = GachaManager:GetGachaConfig(self.tParam.iGachaId)
  local freeNum = gachaConfig.m_FreeTimes
  local isFreeReqAndHaveLeftTimes = self.tParam.iTimesType == 1
  isFreeReqAndHaveLeftTimes = isFreeReqAndHaveLeftTimes and 0 < freeNum and 0 < freeNum - GachaManager:GetGachaFreeTimes(gachaConfig.m_GachaID)
  if isFreeReqAndHaveLeftTimes and self.m_showGachaFreeFlag then
    UILuaHelper.SetActive(self.m_txt_dailyfreenum, true)
    UILuaHelper.SetActive(self.m_txt_lefttips.transform.parent, false)
    self.m_btn_grey:SetActive(false)
    self.m_btn_consume:SetActive(true)
    local curDayUseFreeTimes = GachaManager:GetGachaFreeTimes(gachaConfig.m_GachaID)
    local leftNum = freeNum - curDayUseFreeTimes
    local freeNumStr = string.CS_Format(ConfigManager:GetCommonTextById(20342), leftNum, freeNum)
    self.m_txt_dailyfreenum_Text.text = freeNumStr
    UILuaHelper.SetActive(self.m_consume_quantity, false)
  else
    UILuaHelper.SetActive(self.m_consume_quantity, true)
    UILuaHelper.SetActive(self.m_txt_dailyfreenum, false)
    if 0 >= gachaConfig.m_DailyMax then
      UILuaHelper.SetActive(self.m_txt_lefttips.transform.parent, false)
      self.m_btn_grey:SetActive(false)
      self.m_btn_consume:SetActive(true)
    else
      local dailyTimes = GachaManager:GetGachaDailyTimesById(self.tParam.iGachaId)
      local leftTimes = gachaConfig.m_DailyMax - dailyTimes
      if leftTimes >= self.tParam.iTimesType then
        self.m_btn_grey:SetActive(false)
        self.m_btn_consume:SetActive(true)
        UILuaHelper.SetActive(self.m_txt_lefttips.transform.parent, false)
      else
        self.m_btn_grey:SetActive(true)
        self.m_btn_consume:SetActive(false)
        UILuaHelper.SetActive(self.m_txt_lefttips.transform.parent, true)
        self.m_txt_lefttips_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100095), dailyTimes, gachaConfig.m_DailyMax)
        local _, color = CS.UnityEngine.ColorUtility.TryParseHtmlString("#B2452B")
        self.m_txt_lefttips_Text.color = color
      end
    end
  end
end

function Form_Gacha10:OnBtngreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13017)
end

local fullscreen = true
ActiveLuaUI("Form_Gacha10", Form_Gacha10)
return Form_Gacha10
