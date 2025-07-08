local Form_Gacha10 = class("Form_Gacha10", require("UI/UIFrames/Form_Gacha10UI"))

function Form_Gacha10:SetInitParam(param)
end

function Form_Gacha10:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self.m_vHeroListItem = {}
end

function Form_Gacha10:OnActive()
  self.super.OnActive(self)
  self.tParam = self.m_csui.m_param
  self.m_gachaIdList = self.tParam.vGachaItem
  self.m_changeItemList = self.tParam.vRealItem
  self.m_scroreItem = self.tParam.vScoreItem
  self.m_discountType = self.tParam.iDiscountType
  self.m_vHeroListItem = {}
  self.m_wishCostId = 0
  self.m_wishCostNum = 0
  self.m_costItemId = 0
  self.m_costNum = 0
  self.m_showGachaFreeFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  self:StopSequence()
  self:RefreshHeroList()
  self:RefreshUI()
  self:FreshDiscountBtnShow()
  self:FreshGacha10FreeBtnShow()
  self:AddEventListeners()
  self:FreshMoreBtnStatus()
  local id = #self.m_vHeroListItem == 1 and 113 or 114
  GlobalManagerIns:TriggerWwiseBGMState(id)
end

function Form_Gacha10:OnInactive()
  self.super.OnInactive(self)
  if self.m_vHeroListItem then
    for i = 1, #self.m_vHeroListItem do
      GameObject.Destroy(self.m_vHeroListItem[i].go)
    end
  end
  self.m_vHeroListItem = {}
  self.m_wishCostId = 0
  self.m_wishCostNum = 0
  self.m_costItemId = 0
  self.m_costNum = 0
  self.m_btn_panel:SetActive(true)
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
  sequence:AppendInterval(0.12 * table.getn(self.m_gachaIdList))
  sequence:OnComplete(function()
    if not utils.isNull(self.m_btn_panel) then
      self.m_btn_panel:SetActive(true)
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
    end
  end
  UILuaHelper.SetActive(self.m_pnl_dailyfree10, isShowFreeBtn)
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
  local iCount = 0
  self.m_pnl_card:SetActive(false)
  local layout = self.m_list_card.transform:GetComponent(T_HorizontalLayoutGroup)
  if 1 < #mItemInfo then
    layout.childAlignment = CS.UnityEngine.TextAnchor.MiddleLeft
  else
    layout.childAlignment = CS.UnityEngine.TextAnchor.MiddleCenter
  end
  for i = 1, table.getn(mItemInfo) do
    local vItemInfo = mItemInfo[i]
    if vItemInfo then
      iCount = iCount + 1
      local panelProbabilityItemInfo = self.m_vHeroListItem[iCount]
      if panelProbabilityItemInfo == nil then
        panelProbabilityItemInfo = {}
        panelProbabilityItemInfo.go = CS.UnityEngine.GameObject.Instantiate(self.m_pnl_card, self.m_list_card.transform)
        self.m_vHeroListItem[iCount] = panelProbabilityItemInfo
      end
      local goProbabilityItemInfo = panelProbabilityItemInfo.go
      goProbabilityItemInfo:SetActive(i == 1)
      local heroData = ResourceUtil:GetProcessRewardData(vItemInfo)
      if heroData == nil then
        goProbabilityItemInfo:SetActive(false)
        log.error("can not find heroId == " .. tostring(vItemInfo.iID) .. " cfg")
        break
      end
      local img_head = goProbabilityItemInfo.transform:Find("mask_head/m_img_head"):GetComponent(T_Image)
      ResourceUtil:CreatHeroBust(img_head, heroData.data_id)
      local sequenceNew = Tweening.DOTween.Sequence()
      sequenceNew:AppendInterval(0.11 * i)
      sequenceNew:OnComplete(function()
        if not utils.isNull(goProbabilityItemInfo) then
          goProbabilityItemInfo:SetActive(true)
        end
      end)
      local icon_up = goProbabilityItemInfo.transform:Find("m_icon_up").gameObject
      local isUp = GachaManager:CheckIsUpHero(self.tParam.iGachaId, heroData.data_id)
      icon_up:SetActive(isUp)
      sequenceNew:SetAutoKill(true)
      self.m_sequenceList[#self.m_sequenceList + 1] = sequenceNew
      local item_debris = goProbabilityItemInfo.transform:Find("m_pnl_card_transform").gameObject
      local icon_new = goProbabilityItemInfo.transform:Find("m_icon_new").gameObject
      if self.m_changeItemList[i] and self.m_changeItemList[i].iID ~= 0 then
        icon_new:SetActive(false)
        local item_icon = goProbabilityItemInfo.transform:Find("m_pnl_card_transform/m_item_icon"):GetComponent(T_Image)
        local txt_iconnum = goProbabilityItemInfo.transform:Find("m_pnl_card_transform/m_txt_iconnum"):GetComponent(T_TextMeshProUGUI)
        ResourceUtil:CreatIconById(item_icon, self.m_changeItemList[i].iID)
        txt_iconnum.text = string.format(ConfigManager:GetCommonTextById(20049), tostring(self.m_changeItemList[i].iNum))
        local sequence2 = Tweening.DOTween.Sequence()
        sequence2:AppendInterval(0.11 * (table.getn(mItemInfo) - 1))
        sequence2:OnComplete(function()
          if not utils.isNull(item_debris) and not utils.isNull(self.m_btn_panel) then
            item_debris:SetActive(true)
            UILuaHelper.PlayAnimationByName(item_debris, "m_pnl_card_transform_in")
            self.m_btn_panel:SetActive(true)
          end
          if not utils.isNull(goProbabilityItemInfo) then
            goProbabilityItemInfo:SetActive(true)
          end
        end)
        sequence2:SetAutoKill(true)
        self.m_sequenceList[#self.m_sequenceList + 1] = sequence2
      else
        icon_new:SetActive(true)
        item_debris:SetActive(false)
        icon_up:SetActive(false)
      end
      local img_bg_ssr = goProbabilityItemInfo.transform:Find("m_img_bg_ssr").gameObject
      local img_bg_r = goProbabilityItemInfo.transform:Find("m_img_bg_r").gameObject
      img_bg_ssr:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      img_bg_r:SetActive(heroData.quality ~= GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      local m_img_r = goProbabilityItemInfo.transform:Find("m_icon_qualitylist/m_img_r").gameObject
      local m_img_sr = goProbabilityItemInfo.transform:Find("m_icon_qualitylist/m_img_sr").gameObject
      local m_img_srr = goProbabilityItemInfo.transform:Find("m_icon_qualitylist/m_img_srr").gameObject
      m_img_r:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
      m_img_sr:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
      m_img_srr:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      local img_frame_ssr = goProbabilityItemInfo.transform:Find("m_img_frame_ssr").gameObject
      local img_frame_r = goProbabilityItemInfo.transform:Find("m_img_frame_r").gameObject
      img_frame_ssr:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      img_frame_r:SetActive(heroData.quality ~= GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      local m_FX_Card_SSR = goProbabilityItemInfo.transform:Find("m_FX_Card_SSR").gameObject
      local m_FX_Card_SR = goProbabilityItemInfo.transform:Find("m_FX_Card_SR").gameObject
      local m_FX_Card_R = goProbabilityItemInfo.transform:Find("m_FX_Card_R").gameObject
      m_FX_Card_SSR:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
      m_FX_Card_SR:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
      m_FX_Card_R:SetActive(heroData.quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
      local m_btn_click_hero = goProbabilityItemInfo.transform:Find("m_btn_click_hero"):GetComponent(T_Button)
      m_btn_click_hero.onClick:RemoveAllListeners()
      UILuaHelper.BindButtonClickManual(self, m_btn_click_hero, function()
        utils.openItemDetailPop({
          iID = heroData.data_id,
          iNum = 1
        })
      end)
      local isWish = GachaManager:CheckIsWishHero(self.tParam.iGachaId, heroData.data_id)
      local m_img_wish = goProbabilityItemInfo.transform:Find("m_img_wish").gameObject
      m_img_wish:SetActive(isWish)
    end
  end
  for i = iCount + 1, #self.m_vHeroListItem do
    self.m_vHeroListItem[i].go:SetActive(false)
  end
end

function Form_Gacha10:OnDestroy()
  self.super.OnDestroy(self)
  self.m_vHeroListItem = nil
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
