local UIHeroActMainSecondBase = class("UIHeroActMainSecondBase", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function UIHeroActMainSecondBase:AfterInit()
  UIHeroActMainSecondBase.super.AfterInit(self)
  self.iInterval = 10
end

function UIHeroActMainSecondBase:OnUpdate(dt)
  self:OnBannerTick(dt)
end

function UIHeroActMainSecondBase:OnActive()
  UIHeroActMainSecondBase.super.OnActive(self)
  self:addEventListener("eGameEvent_ActExploreUIVisuable", handler(self, self.OnUIActiveEvent))
  self:addEventListener("eGameEvent_ActExplorePickupCountChanged", handler(self, self.OnPickupCountChanged))
  self.m_pnl_right:SetActive(true)
  self.bIsShowUI = true
  self:OnPickupCountChanged()
end

function UIHeroActMainSecondBase:OnInactive()
  UIHeroActMainSecondBase.super.OnInactive(self)
end

function UIHeroActMainSecondBase:OnDestroy()
  UIHeroActMainSecondBase.super.OnDestroy(self)
end

function UIHeroActMainSecondBase:FreshUI()
  UIHeroActMainSecondBase.super.FreshUI(self)
  self:FreshGachaBanner()
  self:FreshSecondHalf()
  if not utils.isNull(self.m_txt_title) then
    UILuaHelper.SetActive(self.m_txt_title, false)
  end
  self.miniGameIsOpen = HeroActivityManager:IsSubActIsOpenByID(self.act_id, HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame))
end

function UIHeroActMainSecondBase:RegisterRedDot()
  UIHeroActMainSecondBase.super.RegisterRedDot(self)
  local normalSubActID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.NormalLevel, 2)
  self:RegisterOrUpdateRedDotItem(self.m_activity2_redpoint, RedDotDefine.ModuleType.HeroActActivityEntry, normalSubActID)
  self:RegisterOrUpdateRedDotItem(self.m_storyentry_redpoint2, RedDotDefine.ModuleType.HeroActMemoryEntry, self.act_id)
end

function UIHeroActMainSecondBase:FreshSecondHalf()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if config.m_ActivityType ~= HeroActivityManager.ActivityType.Stages then
    return
  end
  if not utils.isNull(self.m_img_lock_activity) then
    self.m_img_lock_activity:SetActive(false)
  end
  local open_state, endTime = HeroActivityManager:GetActOpenState(self.act_id, true)
  if open_state == HeroActivityManager.ActOpenState.Normal then
    if not utils.isNull(self.m_img_lock_activity2) then
      self.m_img_lock_activity2:SetActive(false)
    end
  elseif not utils.isNull(self.m_img_lock_activity2) then
    self.m_img_lock_activity2:SetActive(true)
  end
  if self.m_img_title1 then
    if not utils.isNull(self.m_img_title1) then
      self.m_img_title1:SetActive(open_state == HeroActivityManager.ActOpenState.Normal)
    end
    if not utils.isNull(self.m_img_title) then
      self.m_img_title:SetActive(open_state ~= HeroActivityManager.ActOpenState.Normal)
    end
  end
end

function UIHeroActMainSecondBase:FreshGachaBanner()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if config.m_ActivityType ~= HeroActivityManager.ActivityType.Stages then
    return
  end
  if utils.isNull(self.m_pnl_banner) then
    return
  end
  if not utils.isNull(self.m_btn_img_banner1) then
    local btnExtern1 = self.m_btn_img_banner1:GetComponent("ButtonExtensions")
    if btnExtern1 then
      btnExtern1.Clicked = handler(self, self.OnBannerClicked)
      btnExtern1.BeginDrag = handler(self, self.OnBannerBeginDrag)
      btnExtern1.EndDrag = handler(self, self.OnBannerEndDrag)
    end
  end
  if not utils.isNull(self.m_btn_img_banner2) then
    local btnExtern2 = self.m_btn_img_banner2:GetComponent("ButtonExtensions")
    if btnExtern2 then
      btnExtern2.Clicked = handler(self, self.OnBannerClicked)
      btnExtern2.BeginDrag = handler(self, self.OnBannerBeginDrag)
      btnExtern2.EndDrag = handler(self, self.OnBannerEndDrag)
    end
  end
  UILuaHelper.SetActive(self.m_pnl_banner, true)
  self.iCurBannerIdx = 1
  local bIsSecondHalf = HeroActivityManager:IsSecondGachaOpen(self.act_id)
  self.bannerCount = 1
  if bIsSecondHalf then
    self.bannerCount = 2
    self.iBannerChangeTime = self.iInterval
    self.bIsBannerScroll = true
    UILuaHelper.SetActive(self.m_btn_img_banner2, true)
    UILuaHelper.SetActive(self.m_pnl_list_banner_star, true)
  else
    self.bIsBannerScroll = false
    UILuaHelper.SetActive(self.m_btn_img_banner2, false)
    UILuaHelper.SetActive(self.m_pnl_list_banner_star, false)
  end
  if self.iCurBannerIdx == 1 then
    UILuaHelper.SetActive(self.m_btn_img_banner1, true)
    UILuaHelper.SetActive(self.m_btn_img_banner2, false)
    UILuaHelper.SetActive(self.m_img_star_light1, true)
    UILuaHelper.SetActive(self.m_img_star_light2, false)
  elseif self.iCurBannerIdx == 2 then
    UILuaHelper.SetActive(self.m_btn_img_banner1, false)
    UILuaHelper.SetActive(self.m_btn_img_banner2, true)
    UILuaHelper.SetActive(self.m_img_star_light1, false)
    UILuaHelper.SetActive(self.m_img_star_light2, true)
  end
end

function UIHeroActMainSecondBase:OnBannerTick(dt)
  if not self.bIsBannerScroll then
    return
  end
  if self.iBannerChangeTime then
    self.iBannerChangeTime = self.iBannerChangeTime - dt
    if self.iBannerChangeTime <= 0 then
      self.iBannerChangeTime = self.iInterval
      self:ChangeBanner(true)
    end
  end
end

function UIHeroActMainSecondBase:OnBannerClicked(pointerEventData)
  if self.m_bannerLockTime or self.m_bannerStartDragPos then
    return
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  local gachaInfo = gachaJumpIDArray[self.iCurBannerIdx]
  self:GotoGacha(gachaInfo)
end

function UIHeroActMainSecondBase:OnBannerBeginDrag(pointerEventData)
  if self.m_bannerLockTime then
    return
  end
  if not pointerEventData then
    return
  end
  self.m_bannerStartDragPos = pointerEventData.position
end

function UIHeroActMainSecondBase:OnBannerEndDrag(pointerEventData)
  if not pointerEventData or not self.m_bannerStartDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_bannerStartDragPos.x
  if 0 < deltaNum then
    self:ChangeBanner(true)
  elseif deltaNum < 0 then
    self:ChangeBanner(false)
  end
  self.m_bannerStartDragPos = nil
end

function UIHeroActMainSecondBase:ChangeBanner(isRight)
  local count = self.bannerCount
  local iNextIndex = self.iCurBannerIdx
  if isRight then
    iNextIndex = count < iNextIndex + 1 and 1 or iNextIndex + 1
  else
    iNextIndex = iNextIndex - 1 < 1 and count or iNextIndex - 1
  end
  self.iCurBannerIdx = iNextIndex
  if 1 < count then
    self.iBannerChangeTime = self.iInterval
  end
  self.m_curBannerImg = self.m_btn_img_banner2_Image
  if isRight then
    self.m_curBannerImg = self.m_btn_img_banner1_Image
  else
  end
  if self.iCurBannerIdx == 1 then
    UILuaHelper.SetActive(self.m_btn_img_banner1, true)
    UILuaHelper.SetActive(self.m_btn_img_banner2, false)
    UILuaHelper.SetActive(self.m_img_star_light1, true)
    UILuaHelper.SetActive(self.m_img_star_light2, false)
  elseif self.iCurBannerIdx == 2 then
    UILuaHelper.SetActive(self.m_btn_img_banner1, false)
    UILuaHelper.SetActive(self.m_btn_img_banner2, true)
    UILuaHelper.SetActive(self.m_img_star_light1, false)
    UILuaHelper.SetActive(self.m_img_star_light2, true)
  end
end

function UIHeroActMainSecondBase:OnBtnactivity2Clicked()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if not config then
    return
  end
  if config.m_ActivityType ~= HeroActivityManager.ActivityType.Stages then
    return
  end
  local open_state, endTime = HeroActivityManager:GetActOpenState(self.act_id, true)
  if open_state ~= HeroActivityManager.ActOpenState.Normal then
    local str = TimeUtil:TimerToString3(endTime)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40044), str))
    return
  end
  self:GotoNormalLevel(2)
end

function UIHeroActMainSecondBase:OnBtntaskClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.Task),
    iDailySubActId = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.DailyTask)
  })
end

function UIHeroActMainSecondBase:OnUIActiveEvent(active)
  local content_node = self.m_csui.m_uiGameObject.transform:Find("content_node").gameObject
  if content_node then
    content_node:SetActive(active)
  end
end

function UIHeroActMainSecondBase:OnPartUIActiveEvent(active)
  self.m_pnl_right:SetActive(active)
end

function UIHeroActMainSecondBase:OnPickupCountChanged()
  local scene = GameSceneManager:GetGameScene(GameSceneManager.SceneID.ActExplore)
  local world = scene:GetWorld()
  if not world then
    self:GoBackFormHall()
    return
  end
  local info = world:GetPickupInfo()
  local showTxt = string.format("%d/%d", info.Count, info.Amount)
  if not utils.isNull(self.m_txt_collectnum_Text) then
    self.m_txt_collectnum_Text.text = showTxt
  end
end

function UIHeroActMainSecondBase:OnBtnhideClicked()
  if utils.isNull(self.m_pnl_right) then
    return
  end
  self.bIsShowUI = not self.bIsShowUI
  self.m_pnl_right:SetActive(self.bIsShowUI)
  self:broadcastEvent("eGameEvent_ActExploreIconVisuable", not self.bIsShowUI)
end

function UIHeroActMainSecondBase:OnBtnhammersirenClicked()
  local sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  local iDailySubActId = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.DailyTask)
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame),
    iDailySubActId = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.DailyTask)
  })
end

function UIHeroActMainSecondBase:IsFullScreen()
  return true
end

return UIHeroActMainSecondBase
