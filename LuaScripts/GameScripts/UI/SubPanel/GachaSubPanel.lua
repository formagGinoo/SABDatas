local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GachaSubPanel = class("GachaSubPanel", UISubPanelBase)
local GachaDisplayIns = ConfigManager:GetConfigInsByName("GachaDisplay")
local DeltaFrameNum = 10

function GachaSubPanel:OnInit()
  self.m_curFrameNum = 0
  self.m_nextDayDownTimer = nil
  self.m_nextDayDiscountDownTimer = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_curShowSpineStr = nil
  if self.m_initData and self.m_initData.m_Spine then
    self:LoadShowSpine(self.m_initData.m_Spine)
  end
end

function GachaSubPanel:OnFreshData()
  self.m_gachaConfig = self.m_panelData.gachaConfig or {}
  self.m_freeGacha10CDFlag = false
  self:RefreshUI()
  self:RefreshTime()
  self:CheckFreshDiscountBtnShow()
  self:CheckFreshClearBtnShow()
  self:CheckFreshFreeBtnShow()
end

function GachaSubPanel:OnDestroy()
  GachaSubPanel.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function GachaSubPanel:OnActivePanel()
  self.m_openTime = TimeUtil:GetServerTimeS()
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.Gacha, self.m_openTime, self.m_gachaConfig.m_GachaID)
end

function GachaSubPanel:OnHidePanel()
  ReportManager:ReportSystemClose(GlobalConfig.SYSTEM_ID.Gacha, self.m_openTime, self.m_gachaConfig.m_GachaID)
end

function GachaSubPanel:RefreshTime()
end

function GachaSubPanel:GetGachaBtnState()
  local gacha1 = true
  local gacha10 = true
  if self.m_gachaConfig.m_DailyMax > 0 then
    local dailyTimes = GachaManager:GetGachaDailyTimesById(self.m_gachaConfig.m_GachaID)
    dailyTimes = self.m_gachaConfig.m_DailyMax - dailyTimes
    if dailyTimes < 10 and 1 <= dailyTimes then
      gacha10 = false
    elseif dailyTimes < 1 then
      gacha1 = false
      gacha10 = false
    end
    if not gacha1 and not gacha10 then
      return gacha1, gacha10
    end
  end
  local gachaCount = GachaManager:GetGachaCountById(self.m_gachaConfig.m_GachaID)
  if 0 < self.m_gachaConfig.m_WishTimesRes and 10 > self.m_gachaConfig.m_WishTimesRes - gachaCount then
    gacha10 = false
  end
  return gacha1, gacha10
end

function GachaSubPanel:FreshGachaBtn()
  local consume1Active, consume10Active = self:GetGachaBtnState()
  self.m_btn_consume1:SetActive(consume1Active)
  self.m_btn_consumegray1:SetActive(not consume1Active)
  self.m_btn_consume10:SetActive(consume10Active)
  self.m_btn_consumegray10:SetActive(not consume10Active)
end

function GachaSubPanel:CheckFreshDiscountBtnShow()
  local isShowDiscountBtn = false
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  if self.m_gachaConfig.m_DayCheapTimes > 0 and openFlag then
    local wishCost = self.m_gachaConfig.m_WishCost
    local wishItemID = wishCost[0]
    ResourceUtil:CreateItemIcon(self.m_dailycount_icon_Image, wishItemID)
    local wishNum = wishCost[1]
    local cheapCost = self.m_gachaConfig.m_CheapCost
    local cheapCostNum = cheapCost[1]
    self.m_dailycount_num_Text.text = cheapCostNum
    self.m_txt_dailycount02_Text.text = wishNum
    local curDayUseCheapTimes = GachaManager:GetGachaCheapTimes(self.m_gachaConfig.m_GachaID)
    local leftCheapTimes = self.m_gachaConfig.m_DayCheapTimes - curDayUseCheapTimes
    isShowDiscountBtn = true
    if 0 < leftCheapTimes then
      UILuaHelper.SetActive(self.m_btn_dailycount, true)
      UILuaHelper.SetActive(self.m_btn_dailycount_gray, false)
      local disCountTipsStr = string.CS_Format(ConfigManager:GetCommonTextById(20341), self.m_gachaConfig.m_DayCheapTimes)
      self.m_txt_dailycount_tips01_Text.text = disCountTipsStr
    else
      UILuaHelper.SetActive(self.m_btn_dailycount, false)
      UILuaHelper.SetActive(self.m_btn_dailycount_gray, true)
      self.m_nextDayDiscountDownTimer = TimeUtil:GetServerNextCommonResetTime()
      self:FreshShowDiscountLeftTimeStr()
    end
  end
  UILuaHelper.SetActive(self.m_pnl_dailycount, isShowDiscountBtn)
end

function GachaSubPanel:FreshShowDiscountLeftTimeStr()
  if not self.m_nextDayDiscountDownTimer then
    return
  end
  local leftSecNum = self.m_nextDayDiscountDownTimer - TimeUtil:GetServerTimeS()
  if 0 < leftSecNum then
    local timeStr = TimeUtil:SecondsToFormatStrDHOrHMS(leftSecNum)
    timeStr = string.CS_Format(ConfigManager:GetCommonTextById(20344), timeStr)
    self.m_txt_dailycount_tips02_Text.text = timeStr
  else
    self:CheckFreshDiscountBtnShow()
  end
end

function GachaSubPanel:CheckFreshClearBtnShow()
  local have_special10Token, itemId, itemNum, userNum = GachaManager:IsHaveSpecialGacha10(self.m_gachaConfig.m_GachaID)
  if have_special10Token then
    ResourceUtil:CreateItemIcon(self.m_clear_icon10_Image, itemId)
    self.m_clear_num10_Text.text = itemNum .. " / " .. userNum
    UILuaHelper.SetColor(self.m_clear_num10_Text, 247, 246, 244, 1)
    self.m_txt_clear10_Text.text = string.gsub(ConfigManager:GetCommonTextById(20356), "{0}", ItemManager:GetItemName(itemId))
  end
  UILuaHelper.SetActive(self.m_img_txt_clear10, have_special10Token)
  UILuaHelper.SetActive(self.m_redpoint_clearR, have_special10Token)
  UILuaHelper.SetActive(self.m_pnl_clear10, have_special10Token)
  UILuaHelper.SetActive(self.m_pnl_comsumeR, not have_special10Token)
end

function GachaSubPanel:CheckFreshFreeBtnShow()
  self.m_nextDayDownTimer = nil
  self.m_freeGacha10CDFlag = false
  local isShowFreeBtn = false
  local originalComsumeRActive = self.m_pnl_comsumeR.activeSelf
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  if self.m_gachaConfig.m_FreeTimes > 0 and openFlag then
    local curDayUseFreeTimes = GachaManager:GetGachaFreeTimes(self.m_gachaConfig.m_GachaID)
    local leftFreeTimes = self.m_gachaConfig.m_FreeTimes - curDayUseFreeTimes
    if 0 < leftFreeTimes then
      isShowFreeBtn = true
      local freeNumStr = string.CS_Format(ConfigManager:GetCommonTextById(20342), leftFreeTimes, self.m_gachaConfig.m_FreeTimes)
      self.m_txt_dailyfreenum_Text.text = freeNumStr
    else
      self.m_nextDayDownTimer = TimeUtil:GetServerNextCommonResetTime()
      self:FreshShowFreeLeftTimeStr()
    end
  end
  UILuaHelper.SetActive(self.m_pnl_dailyfree, isShowFreeBtn)
  UILuaHelper.SetActive(self.m_redpoint_dailyfree, isShowFreeBtn)
  UILuaHelper.SetActive(self.m_pnl_comsumeL, not isShowFreeBtn)
  UILuaHelper.SetActive(self.m_img_txt_bg, self.m_nextDayDownTimer ~= nil)
  local iDailyFreeTimesTen = GachaManager:GetGacha10DailyFreeCfgTimesById(self.m_gachaConfig.m_GachaID)
  isShowFreeBtn = false
  if iDailyFreeTimesTen and 0 < iDailyFreeTimesTen and openFlag then
    local curDayUseFreeTimes = GachaManager:GetGacha10FreeTimes(self.m_gachaConfig.m_GachaID)
    local leftFreeTimes = iDailyFreeTimesTen - curDayUseFreeTimes
    if 0 < leftFreeTimes then
      isShowFreeBtn = true
      local freeNumStr = string.CS_Format(ConfigManager:GetCommonTextById(20348), leftFreeTimes, iDailyFreeTimesTen)
      self.m_txt_dailyfreenum10_Text.text = freeNumStr
      UILuaHelper.SetActive(self.m_pnl_clear10, false)
    elseif not GachaManager:CheckIsLastDayById(self.m_gachaConfig.m_GachaID) then
      self.m_freeGacha10CDFlag = true
      if not self.m_nextDayDownTimer then
        self.m_nextDayDownTimer = TimeUtil:GetServerNextCommonResetTime()
      end
      self:FreshShowGacha10FreeTimeStr()
    end
  end
  UILuaHelper.SetActive(self.m_pnl_dailyfree10, isShowFreeBtn)
  UILuaHelper.SetActive(self.m_redpoint_dailyfree10, isShowFreeBtn)
  UILuaHelper.SetActive(self.m_pnl_comsumeR, not isShowFreeBtn and originalComsumeRActive)
  UILuaHelper.SetActive(self.m_img_txt_bg10, self.m_nextDayDownTimer ~= nil)
end

function GachaSubPanel:FreshShowGacha10FreeTimeStr()
  if not self.m_nextDayDownTimer or not self.m_freeGacha10CDFlag then
    return
  end
  local leftSecNum = self.m_nextDayDownTimer - TimeUtil:GetServerTimeS()
  if 0 < leftSecNum then
    local timeStr = TimeUtil:SecondsToFormatStrDHOrHMS(leftSecNum)
    timeStr = string.CS_Format(ConfigManager:GetCommonTextById(20349), timeStr)
    self.m_txt_dailyfree_countdown10_Text.text = timeStr
  else
    self:CheckFreshFreeBtnShow()
  end
end

function GachaSubPanel:FreshShowFreeLeftTimeStr()
  if not self.m_nextDayDownTimer then
    return
  end
  local leftSecNum = self.m_nextDayDownTimer - TimeUtil:GetServerTimeS()
  if 0 < leftSecNum then
    local timeStr = TimeUtil:SecondsToFormatStrDHOrHMS(leftSecNum)
    timeStr = string.CS_Format(ConfigManager:GetCommonTextById(20343), timeStr)
    self.m_txt_dailyfree_countdown_Text.text = timeStr
  else
    self:CheckFreshFreeBtnShow()
  end
end

function GachaSubPanel:OnDailyReset()
  self:RefreshUI()
  self:CheckFreshDiscountBtnShow()
  self:CheckFreshClearBtnShow()
  self:CheckFreshFreeBtnShow()
end

function GachaSubPanel:OnUpdate(dt)
  self:NextFreeDayUpdate()
end

function GachaSubPanel:NextFreeDayUpdate()
  if not self.m_nextDayDownTimer and not self.m_nextDayDiscountDownTimer then
    return
  end
  if self.m_curFrameNum < DeltaFrameNum then
    self.m_curFrameNum = self.m_curFrameNum + 1
    return
  end
  self.m_curFrameNum = 0
  self:FreshShowFreeLeftTimeStr()
  self:FreshShowDiscountLeftTimeStr()
  self:FreshShowGacha10FreeTimeStr()
end

function GachaSubPanel:RefreshUI()
  self:FreshGachaBtn()
  self:RefreshInCensorOpen()
  local have_Token = false
  local wish1Token = utils.changeCSArrayToLuaTable(self.m_gachaConfig.m_Wish1Token)
  if wish1Token and 0 < #wish1Token then
    local itemId = wish1Token[1]
    local itemNum = wish1Token[2]
    local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
    ResourceUtil:CreateItemIcon(self.m_consume_icon1_Image, itemId)
    self.m_consume_num1_Text.text = itemNum
    if itemNum <= userNum then
      UILuaHelper.SetColor(self.m_consume_num1_Text, 247, 246, 244, 1)
      self.m_redpoint_L:SetActive(false)
    else
      UILuaHelper.SetColor(self.m_consume_num1_Text, 178, 69, 43, 1)
      self.m_redpoint_L:SetActive(false)
    end
    have_Token = true
  end
  local wish10Token = utils.changeCSArrayToLuaTable(self.m_gachaConfig.m_Wish10Token)
  if wish10Token and 0 < #wish10Token then
    local itemId = wish10Token[1]
    local itemNum = wish10Token[2]
    local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
    ResourceUtil:CreateItemIcon(self.m_consume_icon10_Image, itemId)
    self.m_consume_num10_Text.text = itemNum
    if itemNum <= userNum and self.m_btn_consume10.activeSelf then
      UILuaHelper.SetColor(self.m_consume_num10_Text, 247, 246, 244, 1)
      self.m_redpoint_R:SetActive(true)
    else
      UILuaHelper.SetColor(self.m_consume_num10_Text, 178, 69, 43, 1)
      self.m_redpoint_R:SetActive(false)
    end
    have_Token = true
  end
  if not have_Token then
    local wishCost = utils.changeCSArrayToLuaTable(self.m_gachaConfig.m_WishCost)
    if wishCost then
      local itemId = wishCost[1]
      local itemNum = wishCost[2]
      ResourceUtil:CreateItemIcon(self.m_consume_icon1_Image, itemId)
      ResourceUtil:CreateItemIcon(self.m_consume_icon10_Image, itemId)
      self.m_consume_num1_Text.text = itemNum
      self.m_consume_num10_Text.text = tonumber(itemNum) * 10
      local userNum = ItemManager:GetItemNum(tonumber(itemId), true)
      if itemNum <= userNum then
        UILuaHelper.SetColor(self.m_consume_num1_Text, 198, 181, 144, 1)
      else
        UILuaHelper.SetColor(self.m_consume_num1_Text, 178, 69, 43, 1)
      end
      if userNum >= tonumber(itemNum) * 10 then
        UILuaHelper.SetColor(self.m_consume_num10_Text, 198, 181, 144, 1)
      else
        UILuaHelper.SetColor(self.m_consume_num10_Text, 178, 69, 43, 1)
      end
    end
  end
  if self.m_gachaConfig.m_WishTimesRes ~= 0 then
    local gachaCount = GachaManager:GetGachaCountById(self.m_gachaConfig.m_GachaID)
    self.m_txt_num_Text.text = self.m_gachaConfig.m_WishTimesRes - gachaCount
    self.m_txt_countnum_Text.text = ConfigManager:GetCommonTextById(20109)
  end
  self:DealNewGachaPoolJump()
  self:FreshEmbbounsState()
end

function GachaSubPanel:FreshEmbbounsState()
  if utils.isNull(self.m_btn_embbouns) then
    return
  end
  self.m_btn_embbouns:SetActive(false)
  local activityList = ActivityManager:GetMainActivityList()
  if not activityList then
    return
  end
  for i, v in ipairs(activityList) do
    if v.SubPanelName and v.Activity:checkCondition(true) then
      local act = v.Activity
      if act and act.GetClientCfg then
        local cfg = act:GetClientCfg()
        if cfg.iShowType == 4 then
          local quest = {}
          quest = act.m_stSdpConfig.mQuest
          local firstQuestId = act:GetRedQuestId()
          local questList = {}
          for _, vv in pairs(quest) do
            if tonumber(vv.iId) ~= firstQuestId then
              questList[#questList + 1] = vv
            end
          end
          if 1 <= #questList then
            table.sort(questList, function(a, b)
              return a.iId < b.iId
            end)
          end
          for _, info in ipairs(questList) do
            local questState = act:GetQuestState(info.iId)
            if questState and (questState.iState == TaskManager.TaskState.Doing or questState.iState == TaskManager.TaskState.Finish) then
              local force = act:GetQuestState(questList[#questList].iId).vCondStep[1] or 0
              if force < info.iObjectiveCount then
                self.m_txt_embnum_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(2111), force, info.iObjectiveCount)
              else
                self.m_txt_embnum_Text.text = force .. "/" .. info.iObjectiveCount
              end
              self.m_btn_embbouns:SetActive(true)
              self.iActivityId = act:getID()
              self.m_wish_redpoint:SetActive(questState.iState == TaskManager.TaskState.Finish)
              self.m_vx_glow:SetActive(questState.iState == TaskManager.TaskState.Finish)
              break
            end
          end
        end
      end
    end
  end
end

function GachaSubPanel:GoGacha(gachaType, discountType)
  GachaManager:SetSkippedInteract(false)
  local params = {
    iGachaId = self.m_gachaConfig.m_GachaID,
    iTimesType = gachaType,
    iDiscountType = discountType
  }
  GachaManager:RequestGachaResult(params)
end

function GachaSubPanel:OnBtnconsume10Clicked()
  self:GoGacha(10)
end

function GachaSubPanel:OnBtngrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30026)
end

function GachaSubPanel:OnBtnconsumegray10Clicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13017)
end

function GachaSubPanel:OnBtnconsumegray1Clicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13017)
end

function GachaSubPanel:OnBtnconsume1Clicked()
  self:GoGacha(1)
end

function GachaSubPanel:OnBtnmoreClicked()
  local displayCfg = GachaDisplayIns:GetValue_ByDisplayID(self.m_gachaConfig.m_DisplayID)
  if displayCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByDisplayID is error " .. tostring(self.m_gachaConfig.m_DisplayID))
    return
  end
  local character = utils.changeCSArrayToLuaTable(displayCfg.m_PreviewCharacter)
  utils.openItemDetailPop({
    iID = character[1],
    iNum = 1
  })
end

function GachaSubPanel:OnbtnvideoClicked()
end

function GachaSubPanel:OnBtngetClicked()
  if self.m_gachaConfig and self.m_gachaConfig.m_ShopJump and self.m_gachaConfig.m_ShopJump ~= 0 then
    QuickOpenFuncUtil:OpenFunc(self.m_gachaConfig.m_ShopJump)
  end
end

function GachaSubPanel:OnBtnAttrDetailClicked()
end

function GachaSubPanel:OnBtnembbounsClicked()
  QuickOpenFuncUtil:OpenFunc(30001, {
    activityId = tonumber(self.iActivityId)
  })
end

function GachaSubPanel:OnBtndailyfreeClicked()
  self:GoGacha(1, GachaManager.GachaDiscountType.Free)
end

function GachaSubPanel:OnBtndailyfree10Clicked()
  if not GachaManager:GetGacha10DailyFreeActiveById(self.m_gachaConfig.m_GachaID) then
    utils.CheckAndPushCommonTips({
      tipsID = 1231,
      func1 = function()
        self:CheckFreshFreeBtnShow()
      end
    })
    return
  end
  self:GoGacha(10, GachaManager.GachaDiscountType.Free)
end

function GachaSubPanel:OnBtndailycountClicked()
  if not self.m_gachaConfig then
    return
  end
  if self.m_gachaConfig.m_DayCheapTimes <= 0 then
    return
  end
  local cheapCost = self.m_gachaConfig.m_CheapCost
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
  utils.ShowCommonTipCost({
    beforeItemID = needCostItemID,
    beforeItemNum = needCostNum,
    confirmCommonTipsID = 1206,
    funSure = function()
      self:GoGacha(1, GachaManager.GachaDiscountType.Cheap)
    end
  })
end

function GachaSubPanel:OnBtndailycountgrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13021)
end

function GachaSubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(self.m_curShowSpineStr, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
    self.m_curShowSpineStr = nil
  end
end

function GachaSubPanel:LoadShowSpine(spineStr)
  if not spineStr then
    return
  end
  self.m_HeroSpineDynamicLoader:GetObjectByName(spineStr, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    UILuaHelper.SetSpineTimeScale(object, 1)
    if UILuaHelper.CheckIsHaveSpineAnim(object, "idle2") then
      UILuaHelper.SpinePlayAnimWithBack(object, 0, "idle2", true, false)
    else
      UILuaHelper.SpinePlayAnimWithBack(object, 0, "idle", true, false)
    end
    self.m_curHeroSpineObj = object
    self.m_curShowSpineStr = nameStr
  end)
end

function GachaSubPanel:RefreshInCensorOpen()
  if not utils.isNull(self.m_img_bg01) and ActivityManager:IsInCensorOpen() then
    UILuaHelper.SetActive(self.m_img_bg01, ActivityManager:IsInCensorOpen())
    if not utils.isNull(self.m_img_bg) then
      UILuaHelper.SetActive(self.m_img_bg, false)
    end
  elseif not utils.isNull(self.m_img_bg) then
    UILuaHelper.SetActive(self.m_img_bg, true)
  end
end

function GachaSubPanel:DealNewGachaPoolJump()
  if self.m_gachaConfig.m_ShopJump and self.m_gachaConfig.m_ShopJump ~= 0 then
    local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
    if payStoreActivity then
      local isCanJump = payStoreActivity:GetChainPackState()
      if not utils.isNull(self.m_z_txt_get) then
        UILuaHelper.SetActive(self.m_z_txt_get, isCanJump)
      end
      if not utils.isNull(self.m_z_txt_got) then
        UILuaHelper.SetActive(self.m_z_txt_got, not isCanJump)
      end
      if not utils.isNull(self.m_vx_glow2) then
        UILuaHelper.SetActive(self.m_vx_glow2, isCanJump)
      end
      if not utils.isNull(self.m_vx_glow1) then
        UILuaHelper.SetActive(self.m_vx_glow1, isCanJump)
      end
      if not utils.isNull(self.m_img_bg3) and not isCanJump then
        UILuaHelper.StopAnimation(self.m_img_bg3)
      end
    end
  end
end

function GachaSubPanel:GetDownloadResourceExtra(subPanelCfg)
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return GachaSubPanel
