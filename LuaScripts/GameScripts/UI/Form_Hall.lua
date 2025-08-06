local Form_Hall = class("Form_Hall", require("UI/UIFrames/Form_HallUI"))
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local AFK_REQUEST_INTERVAL = tonumber(GlobalManagerIns:GetValue_ByName("AFKRequestInterval").m_Value) or 5
local WEB_URL = GlobalManagerIns:GetValue_ByName("Webtestsite").m_Value or "http://10.20.208.37:80"
local AFK_STORAGE = tonumber(GlobalManagerIns:GetValue_ByName("AFKStorage").m_Value) or 36000
local PROGRESS_UNIT = CommonTextIns:GetValue_ById(100009).m_mMessage
local GUILD_REFRESH_CD = tonumber(GlobalManagerIns:GetValue_ByName("GuildRefreshCD").m_Value)
local Banner_Scroll_Interval = 10
local PreHangUpStr = "xq_"
local PreHangUpAnimationStr_CN = "m_eff_sand"
local OneDayOfSecond = 86400
local DeltaGachaNum = 10
local HeroActChangeInt = tonumber(GlobalManagerIns:GetValue_ByName("HallActivitySwitchTime").m_Value) or 5
local ModuleManager = _ENV.ModuleManager
local HangUpManager = _ENV.HangUpManager

function Form_Hall:SetInitParam(param)
end

function Form_Hall:AfterInit()
  self.super.AfterInit(self)
  self.m_headFrameTrans = self.m_head_frame.transform
  self.m_vScrollActivityList = {}
  self.m_currentBannerIndex = 0
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_contentTrans = self.m_rootTrans:Find("content_node")
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_widgetTaskEnter = self:createTaskBar(self.m_common_task_enter)
  self.m_bgPanelCom = self:CreateSubPanel("HallBgSubPanel", self.m_bgPanel, self, nil, nil, nil)
  self.m_battlePassPanel = self:CreateSubPanel("HallBattlePassSubPanel", self.m_bpPanel, self, nil, nil, nil)
  self.m_isHideContent = false
  self.m_isShowSubPanelOther = false
  self.heroActTimer = nil
  self.m_headFrameEftStr = nil
  self.m_headFrameEftObj = nil
  self.m_gachaFrameNum = 0
  self.sufHangUpAnimationNum_CN = 0
  self.m_iTimeDurationOneSecond = 0
  UILuaHelper.SetActive(self.m_hangup_unlock, false)
  UILuaHelper.SetActive(self.m_img_lock_hangup, true)
  local hangupEx = self.m_btn_hangup:GetComponent("ButtonExtensions")
  
  function hangupEx.Down()
    self.m_btn_hangup_Click_FX:SetActive(false)
    self.m_btn_hangup_Click_FX:SetActive(true)
  end
  
  hangupEx.Clicked = handler(self, self.OnHangupClicked)
  self:AddEventListeners()
  self:CheckRegisterRedDot()
  utils.setScreenSize(self.m_rootTrans.rect.width, self.m_rootTrans.rect.height)
  utils.removeLoginDoor()
  ItemManager:CheckFragmentCertainRedPoint()
  if not CS.UI.UILuaHelper.IsUnityEditor() then
    self.m_btn_gm:SetActive(false)
  end
  local btnExtern = self.m_btn_img_banner:GetComponent("ButtonExtensions")
  if btnExtern then
    btnExtern.Clicked = handler(self, self.OnBannerClicked)
    btnExtern.BeginDrag = handler(self, self.OnBannerBeginDrag)
    btnExtern.EndDrag = handler(self, self.OnBannerEndDrag)
  end
  UserDataManager:SetLoginToHallFlag(true)
end

function Form_Hall:OnActive()
  self:InitFxStatus()
  self.iHeroActIdx = 1
  self:FreshUI()
  self:CheckFreshBattlePassSubPanelShow()
  self:CheckShowGachaDownTime()
  self:CheckFreshBgSubPanelShow()
  self:InitHangUpUI()
  if self.m_csui == StackFlow:GetTopUI() then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(13)
  end
  StackFlow:DestroyUI(UIDefines.ID_FORM_LOGINNEW)
  self:CheckAndRqsHeroAct()
  self:CheckAndShowTimelinePushface()
  RequestLuaCodeStatus(function(iSeverityMax)
    if iSeverityMax == 3 then
      utils.CheckAndPushCommonTips({
        tipsID = 9969,
        bLockBack = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
    elseif iSeverityMax == 2 then
      utils.CheckAndPushCommonTips({
        tipsID = 9968,
        bLockBack = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
    end
  end)
  self.m_iHandlerBackPressed = self:addEventListener("eGameEvent_OnBackPressed", handler(self, self.OnBackPressed))
end

function Form_Hall:OnBackPressed()
  if ChannelManager:IsUsingQSDK() then
    QSDKManager:Exit()
  end
end

function Form_Hall:OnInactive()
  if self.m_bgPanelCom then
    self.m_bgPanelCom:OnInActive()
  end
  self:CheckRecycleHeadFrameNode()
  if self.heroActTimer then
    for i, v in pairs(self.heroActTimer) do
      TimeService:KillTimer(v)
    end
    self.heroActTimer = nil
  end
  SettingManager:SetEnterHallInLogin(false)
  if self.m_iHandlerBackPressed then
    self:removeEventListener("eGameEvent_OnBackPressed", self.m_iHandlerBackPressed)
    self.m_iHandlerBackPressed = nil
  end
  if self.iHeroActChangeTimer then
    TimeService:KillTimer(self.iHeroActChangeTimer)
    self.iHeroActChangeTimer = nil
  end
  if self.ChangeActTimer then
    TimeService:KillTimer(self.ChangeActTimer)
    self.ChangeActTimer = nil
  end
  self:ClearEmergencyGiftTimer()
  self:ClearActEnterTimer()
end

function Form_Hall:ClearUI3DModel()
  local bossModule = ModuleManager:GetModuleByName("BossModule")
  if not bossModule then
    return
  end
  bossModule:ClearAllBossRes()
  bossModule:ForceRemoveBossPosNode()
end

function Form_Hall:CheckAndRqsHeroAct()
  if self.bIsWaittingActData then
    return
  end
  self.heroActTimer = {}
  local allCfg = HeroActivityManager:GetAllMainInfoConfig()
  local list = HeroActivityManager:GetOpenActList()
  for _, v in pairs(allCfg) do
    if v.m_ActivityID and v.m_ActivityID > 0 then
      if not list[v.m_ActivityID] then
        local startTime = TimeUtil:TimeStringToTimeSec2(v.m_OpenTime) or 0
        local endTime = TimeUtil:TimeStringToTimeSec2(v.m_EndTime) or 0
        local closeTime = TimeUtil:TimeStringToTimeSec2(v.m_CloseTime) or 0
        local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.main, v.m_ActivityID)
        if is_corved then
          startTime, closeTime = t1, t2
        end
        local temp_time = closeTime ~= 0 and closeTime or endTime
        local main_open_flag = TimeUtil:IsInTime(startTime, temp_time)
        if main_open_flag then
          if self.heroActTimer[v.m_ActivityID] then
            TimeService:KillTimer(self.heroActTimer[v.m_ActivityID])
            self.heroActTimer[v.m_ActivityID] = nil
          end
          self.bIsWaittingActData = true
          HeroActivityManager:OnDailyReset()
        else
          local cur_time = TimeUtil:GetServerTimeS()
          if 0 < startTime - cur_time then
            local last_time = startTime - cur_time + 10
            if self.heroActTimer[v.m_ActivityID] then
              TimeService:KillTimer(self.heroActTimer[v.m_ActivityID])
              self.heroActTimer[v.m_ActivityID] = nil
            end
            self.heroActTimer[v.m_ActivityID] = TimeService:SetTimer(last_time, 1, function()
              self.bIsWaittingActData = true
              HeroActivityManager:OnDailyReset()
            end)
          end
        end
      end
      local jumpIns = ConfigManager:GetConfigInsByName("Jump")
      local jump_item = jumpIns:GetValue_ByJumpID(v.m_ShopJumpID)
      local windowId = 0 < jump_item.m_Param.Length and tonumber(jump_item.m_Param[0]) or 0
      local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
      local shop_id
      for i, vv in ipairs(shop_list) do
        if vv.m_WindowID == windowId then
          shop_id = vv.m_ShopID
        end
      end
      local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
        id = v.m_ActivityID,
        shop_id = shop_id
      })
      if is_corved and TimeUtil:IsInTime(t1, t2) then
        ShopManager:ReqGetShopData(shop_id)
      end
    end
  end
end

function Form_Hall:CheckAndShowTimelinePushface()
  local vActList = ActivityManager:GetActivityListByType(MTTD.ActivityType_TimelineJump)
  if not vActList or #vActList == 0 then
    return
  end
  for index, value in ipairs(vActList) do
    value:OnPushPanel()
  end
end

function Form_Hall:OnUncoverd()
  self:FreshUI()
  ActivityManager:CheckEmergencyGift()
  self:RefreshHallActivityStatus()
  self:InitHangUpUI()
  self:CheckShowNextPopPanel()
end

function Form_Hall:OnActiveTransitionDone()
  self:CheckClearPopPanelStatus()
  self:CheckSystemPopup()
  ActivityManager:CheckEmergencyGift()
  self:RefreshHallActivityStatus()
  self:CheckShowNextPopPanel()
  self:ClearUI3DModel()
end

function Form_Hall:InitHangUpUI()
  local openFlag3 = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
  if openFlag3 then
    self.m_iTimeDurationOneSecond = 0
    self.m_iTimeTick = TimeUtil:GetServerTimeS() - (HangUpManager.m_iTakeRewardTime or TimeUtil:GetServerTimeS())
    self.m_hangUpFullState = false
    local progress = math.min(self.m_iTimeTick / AFK_STORAGE, 1)
    local progressNum = math.floor(progress * 100)
    if progress ~= 1 then
      self.m_hangUpFullState = false
    else
      self.m_hangUpFullState = true
    end
    self:ShowHangUpBoxAnim(progressNum)
  end
end

function Form_Hall:ShowHangUpBoxAnim(progressNum)
  if self.m_hangUpProgressNum == progressNum then
    return
  end
  local showProgressNum = 0
  local sufHangUpAnimationNum_CN = 2
  if 0 <= progressNum and progressNum < 25 then
    showProgressNum = 0
    sufHangUpAnimationNum_CN = 1
  elseif 25 <= progressNum and progressNum < 50 then
    showProgressNum = 25
  elseif 50 <= progressNum and progressNum < 75 then
    showProgressNum = 50
  elseif 75 <= progressNum and progressNum < 100 then
    showProgressNum = 75
  elseif 100 <= progressNum then
    showProgressNum = 100
    sufHangUpAnimationNum_CN = 3
  end
  if self.sufHangUpAnimationNum_CN ~= sufHangUpAnimationNum_CN then
    local preHangUpAnimationStr = PreHangUpAnimationStr_CN .. self.sufHangUpAnimationNum_CN
    local curHangUpAnimationStr = PreHangUpAnimationStr_CN .. sufHangUpAnimationNum_CN
    if self[preHangUpAnimationStr] then
      UILuaHelper.SetActive(self[preHangUpAnimationStr], false)
    end
    if self[curHangUpAnimationStr] then
      UILuaHelper.SetActive(self[curHangUpAnimationStr], true)
    end
    self.sufHangUpAnimationNum_CN = sufHangUpAnimationNum_CN
  end
  UILuaHelper.SpinePlayAnimWithBack(self.m_spine_global, 0, PreHangUpStr .. showProgressNum, true, false)
  self.m_txt_percentage_Text.text = progressNum .. "%"
  self.m_hangUpProgressNum = progressNum
end

function Form_Hall:GachaDowTimeUpdate()
  if not self.m_isShowGachaDownTime then
    return
  end
  if self.m_gachaFrameNum < DeltaGachaNum then
    self.m_gachaFrameNum = self.m_gachaFrameNum + 1
    return
  end
  self.m_gachaFrameNum = 0
  self:FreshGachaDownTimeShow()
end

function Form_Hall:OnUpdate(dt)
  self:GachaDowTimeUpdate()
  self:RefreshResourceDownloadButtonStatus()
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick + dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeTick >= AFK_STORAGE then
    if self.m_hangUpFullState == false then
      self.m_hangUpFullState = true
      self:ShowHangUpBoxAnim(100)
    end
  elseif self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    local progress = math.min(self.m_iTimeTick / AFK_STORAGE, 1)
    local progressNum = math.floor(progress * 100)
    if self.m_hangUpFullState == true then
      self.m_hangUpFullState = false
    end
    self:ShowHangUpBoxAnim(progressNum)
  end
  self:OnBannerTick(dt)
end

function Form_Hall:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleHeadFrameNode()
  self:RemoveAllEventListeners()
  if self.iHeroActChangeTimer then
    TimeService:KillTimer(self.iHeroActChangeTimer)
    self.iHeroActChangeTimer = nil
  end
  if self.ChangeActTimer then
    TimeService:KillTimer(self.ChangeActTimer)
    self.ChangeActTimer = nil
  end
  if self.banelAnim then
    TimeService:KillTimer(self.banelAnim)
    self.banelAnim = nil
  end
end

function Form_Hall:InitFxStatus()
  UILuaHelper.SetActive(self.m_btn_hangup_Click_FX, false)
end

function Form_Hall:FreshUI()
  self:FreshRoleLevel()
  self:FreshRoleExp()
  self:FreshRoleName()
  self:FreshHeadShow()
  self:FreshHeadFrameShow()
  self:RefreshMainActivityUI()
  self:RefreshLockIconState()
  self:RefreshHangUpText()
  self:RefreshHallBannerStatus()
  self:FreshMainStoryProcess()
  self:RefreshResourceDownloadButtonStatus()
  self.m_isHideContent = false
  self:FreshContentAndBackShow()
  self.m_isShowSubPanelOther = false
  self:FreshSubPanelOtherShow()
  self:CheckSystemRedPoint()
  self:OnFullBurstDayUpdate()
  self:CheckAndShowLetter()
end

function Form_Hall:CheckSystemRedPoint()
  local redPoint = CastleDispatchManager:CheckDispatchRedPoint()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.DispatchEntry,
    count = redPoint
  })
end

function Form_Hall:CheckFreshBgSubPanelShow()
  if self.m_bgPanelCom then
    self.m_bgPanelCom:OnActive()
  end
end

function Form_Hall:CheckFreshBattlePassSubPanelShow()
  if self.m_battlePassPanel then
    self.m_battlePassPanel:OnActive()
  end
end

function Form_Hall:FreshContentAndBackShow()
  UILuaHelper.SetActive(self.m_contentTrans, not self.m_isHideContent)
  UILuaHelper.SetActive(self.m_back_Detail, self.m_isHideContent)
end

function Form_Hall:FreshSubPanelOtherShow()
  UILuaHelper.SetActive(self.m_pnl_other, self.m_isShowSubPanelOther)
end

function Form_Hall:RefreshHallBannerStatus()
  local activeBanner = #self.m_vScrollActivityList > 0
  self.m_pnl_banner:SetActive(activeBanner)
  self.m_txt_bannertitle.gameObject:GetComponent("CanvasGroup").alpha = 1
end

function Form_Hall:OnBannerClicked(pointerEventData)
  if self.m_bannerLockTime or self.m_bannerStartDragPos then
    return
  end
  local params = {
    Event_id = "click_act_all"
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  local activityId = self.m_vScrollActivityList[self.m_currentBannerIndex]
  if not activityId then
    return
  end
  local activityCom = ActivityManager:GetActivityByID(activityId)
  if not activityCom then
    return
  end
  local activityData = activityCom:getData()
  if not activityData then
    return
  end
  local jumpType = activityData.iJumpType
  local jumpParam = activityData.sJumpParam
  if jumpType and jumpParam then
    ActivityManager:DealJump(jumpType, jumpParam)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMAIN, {activityId = activityId})
  end
end

function Form_Hall:OnBannerBeginDrag(pointerEventData)
  if self.m_bannerLockTime then
    return
  end
  if not pointerEventData then
    return
  end
  self.m_bannerStartDragPos = pointerEventData.position
end

function Form_Hall:OnBannerEndDrag(pointerEventData)
  if not pointerEventData or not self.m_bannerStartDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_bannerStartDragPos.x
  if 0 < deltaNum then
    self:ScrollBanner(true)
  elseif deltaNum < 0 then
    self:ScrollBanner(false)
  end
  self.m_bannerStartDragPos = nil
end

function Form_Hall:ScrollBanner(isRight)
  local count = #self.m_vScrollActivityList
  local nextIndex = self.m_currentBannerIndex
  if isRight then
    nextIndex = nextIndex + 1
    if count < nextIndex then
      nextIndex = 1
    end
  else
    nextIndex = nextIndex - 1
    if nextIndex < 1 then
      nextIndex = count
    end
  end
  self.m_curBannerImg = self.m_btn_img_banner3_Image
  if not isRight then
    self.m_curBannerImg = self.m_btn_img_banner2_Image
  end
  self.m_currentBannerIndex = nextIndex
  if 1 < count then
    self.m_bannerScrollTime = Banner_Scroll_Interval
  end
  local starRootTrans = self.m_pnl_list_banner_star.transform
  for i = 1, count do
    local star = starRootTrans:GetChild(i - 1):GetChild(0)
    star.gameObject:SetActive(i == self.m_currentBannerIndex)
  end
  local activityId = self.m_vScrollActivityList[nextIndex]
  local pic = ActivityManager:GetBannerPic(activityId)
  local picCdn = ActivityManager:GetBannerCdnPic(activityId)
  local act = ActivityManager:GetActivityByID(self.m_vScrollActivityList[nextIndex])
  if act and act:getData().sBriefDesc then
    UILuaHelper.SetActive(self.m_txt_bannertitle, true)
    UILuaHelper.PlayAnimationByName(self.m_txt_bannertitle, "m_txt_bannertitle_once")
    self.m_bannerTextTimer = TimeService:SetTimer(0.1, 1, function()
      self.curActivityDesc = act:getLangText(tostring(act:getData().sBriefDesc))
      self.m_txt_bannertitle_Text.text = self.curActivityDesc
      self.m_bannerTextTimer = nil
    end)
  else
    self.curActivityDesc = ""
    self.m_txt_bannertitle_Text.text = ""
  end
  
  local function PlayAnim()
    if self.m_curBannerImg then
      local animString = "ActivityMain_banner_down"
      if not isRight then
        animString = "ActivityMain_banner_up"
      end
      UILuaHelper.PlayAnimationByName(self.m_curBannerImg.gameObject, animString)
      self.banelAnim = nil
      self.banelAnim = TimeService:SetTimer(0.05, 1, function()
        self.m_curBannerImg.gameObject:SetActive(true)
        TimeService.KillTimer(self.banelAnim)
        self.banelAnim = nil
      end)
      self.m_bannerLockTime = UILuaHelper.GetAnimationLengthByName(self.m_curBannerImg, nil) + 0.2
      if self.m_bannerScrollTime then
        self.m_bannerScrollTime = self.m_bannerScrollTime + self.m_bannerLockTime
      end
    end
  end
  
  if picCdn ~= "" then
    local actData = ActivityManager:GetActivityDataByID(activityId)
    if actData then
      ActivityManager:SetActivityImage(actData, self.m_curBannerImg, picCdn, PlayAnim)
    end
  else
    UILuaHelper.SetAtlasSprite(self.m_curBannerImg, pic, PlayAnim)
  end
end

function Form_Hall:OnBannerTick(dt)
  if self.m_bannerScrollTime then
    self.m_bannerScrollTime = self.m_bannerScrollTime - dt
    if self.m_bannerScrollTime <= 0 then
      self.m_bannerScrollTime = Banner_Scroll_Interval
      self:ScrollBanner(true)
    end
  end
  if self.m_bannerLockTime then
    self.m_bannerLockTime = self.m_bannerLockTime - dt
    if 0 >= self.m_bannerLockTime then
      if self.m_curBannerImg then
        self.m_btn_img_banner_Image.sprite = self.m_curBannerImg.sprite
        self.m_curBannerImg.gameObject:SetActive(false)
        self.m_curBannerImg = nil
      end
      self.m_bannerLockTime = nil
    end
  end
end

function Form_Hall:RefreshResourceDownloadButtonStatus()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.DownloadTask)
  if not openFlag then
    self.m_btn_download:SetActive(false)
    return
  end
  local vTaskDownloadResourceAll = DownloadManager:GetTaskDownloadResourceAll()
  local bShow = false
  local bRed = false
  local lCurBytes, lTotalBytes = DownloadManager:GetDownloadAddResAllStatus()
  for _, stTaskDownloadResourceInfo in pairs(vTaskDownloadResourceAll) do
    if stTaskDownloadResourceInfo.iState ~= MTTDProto.QuestState_Over then
      bShow = true
    end
    if stTaskDownloadResourceInfo.iState == MTTDProto.QuestState_Finish then
      bRed = true
    end
  end
  if (bShow or lCurBytes < lTotalBytes) and 0 < lTotalBytes then
    self.m_btn_download:SetActive(true)
    self.m_bar_dwonload_percentage_Image.fillAmount = lCurBytes / lTotalBytes
    self.m_txt_download_percentage_Text.text = math.floor(lCurBytes / lTotalBytes * 100) .. "%"
    self.m_redpint_download:SetActive(bRed)
  else
    self.m_btn_download:SetActive(false)
  end
end

function Form_Hall:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_hero_red_dot, RedDotDefine.ModuleType.HeroEntry)
  self:RegisterOrUpdateRedDotItem(self.m_mail_red_dot, RedDotDefine.ModuleType.MailEntry)
  self:RegisterOrUpdateRedDotItem(self.m_bag_red_dot, RedDotDefine.ModuleType.BagEntry)
  self:RegisterOrUpdateRedDotItem(self.m_level_main_red_dot, RedDotDefine.ModuleType.LevelEntry, {
    LevelManager.LevelType.MainLevel
  })
  self:RegisterOrUpdateRedDotItem(self.m_mission_red_dot, RedDotDefine.ModuleType.TaskEntry)
  self:RegisterOrUpdateRedDotItem(self.m_hangup_red_dot, RedDotDefine.ModuleType.HangUpEntry)
  self:RegisterOrUpdateRedDotItem(self.m_hall_activity_red_dot, RedDotDefine.ModuleType.HallActivityEntry, {
    LevelManager.LevelType.Tower,
    LevelManager.LevelType.Dungeon,
    BattleFlowManager.ArenaType.Arena,
    LegacyLevelManager.LevelType.LegacyLevel,
    RogueStageManager.BattleType
  })
  self:RegisterOrUpdateRedDotItem(self.m_hero_red_dot4, RedDotDefine.ModuleType.GuildEntry)
  self:RegisterOrUpdateRedDotItem(self.m_shopfree_red_dot, RedDotDefine.ModuleType.FreeShop)
  self:RegisterOrUpdateRedDotItem(self.m_hero_circulation_red_dot, RedDotDefine.ModuleType.HeroCirculationEntry)
  self:RegisterOrUpdateRedDotItem(self.m_shopmoney_red_dot, RedDotDefine.ModuleType.HallMallMainEntry)
  self:RegisterOrUpdateRedDotItem(self.m_setting_red_dot, RedDotDefine.ModuleType.SettingEntry)
  self:RegisterOrUpdateRedDotItem(self.m_announcement_red_dot, RedDotDefine.ModuleType.AnnouncementEntry)
  self:RegisterOrUpdateRedDotItem(self.m_red_dot_castle, RedDotDefine.ModuleType.CastleEntry)
  self:RegisterOrUpdateRedDotItem(self.m_bp_red_dot, RedDotDefine.ModuleType.BattlePass)
  self:RegisterOrUpdateRedDotItem(self.m_friend_red_dot, RedDotDefine.ModuleType.FriendEntry)
  self:RegisterOrUpdateRedDotItem(self.m_role_head_red_dot, RedDotDefine.ModuleType.PersonalCardEntry)
  self:RegisterOrUpdateRedDotItem(self.m_decorate_red_dot, RedDotDefine.ModuleType.HallDecorateEntry)
  self:RegisterOrUpdateRedDotItem(self.m_all_red_dot, RedDotDefine.ModuleType.HallFunctionEntry)
end

function Form_Hall:RefreshHangUpText()
  self.m_iTimeTick = TimeUtil:GetServerTimeS() - (HangUpManager.m_iTakeRewardTime or TimeUtil:GetServerTimeS())
  self.m_txt_lv_Text.text = HangUpManager.m_iAfkLevel or 0
end

function Form_Hall:RefreshLockIconState()
  local openFlagCharacter = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Character)
  self.m_pnl_icon01:SetActive(openFlagCharacter)
  self.m_img_lock_01:SetActive(not openFlagCharacter)
  local openFlagForm = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  local openFlag3 = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
  UILuaHelper.SetActive(self.m_img_lock_hangup, not openFlag3)
  UILuaHelper.SetActive(self.m_hangup_unlock, openFlag3)
  local openFlagCastle = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Castle)
  self.m_pnl_icon03:SetActive(openFlagCastle)
  self.m_img_lock_03:SetActive(not openFlagCastle)
  UILuaHelper.SetActive(self.m_pnl_unlock_3, openFlagCastle)
  local openFlag8 = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Shop)
  self.m_btn_store_free:SetActive(openFlag8)
  local m_PayStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if m_PayStoreActivity then
    local m_StoreList = m_PayStoreActivity:GetNewStoreList()
    self.m_btn_store_money:SetActive(0 < #m_StoreList and m_PayStoreActivity:CheckActivityIsOpen() and m_PayStoreActivity:GetIsAnyStoreISOpen())
    m_PayStoreActivity:OnGetMallStoreOtherActRed()
  else
    self.m_btn_store_money:SetActive(false)
  end
  local openFlagGuild = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Guild)
  self.m_pnl_icon04:SetActive(openFlagGuild)
  self.m_img_lock_04:SetActive(not openFlagGuild)
  local openFlagInherit = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Inherit)
  self.m_pnl_icon05:SetActive(openFlagInherit)
  self.m_img_lock_05:SetActive(not openFlagInherit)
  local openFlagGacha = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  self.m_pnl_icon06:SetActive(openFlagGacha)
  self.m_img_lock_06:SetActive(not openFlagGacha)
  self.m_hero_red_dot6:SetActive(GachaManager:CheckGachaPoolHaveRedDot())
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  self.m_icon1_lock:SetActive(not openFlag)
  local openFlagActivity = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Activity)
  self.m_z_txt_fight_hall_activity:SetActive(openFlagActivity)
  self.m_icon_hall_activity_lock:SetActive(not openFlagActivity)
  local openFlagAnnouncement = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Notice)
  self.m_btn_left_top_05:SetActive(openFlagAnnouncement)
  self.m_btn_store_push:SetActive(false)
end

function Form_Hall:CheckSystemPopup()
  local systemIdList = {}
  for i, systemId in pairs(GlobalConfig.SYSTEM_ID) do
    local openFlag, _, isPop = UnlockSystemUtil:IsSystemOpen(systemId)
    if openFlag and isPop == 1 then
      local flag = UnlockManager:CheckSystemIsPopup(systemId)
      if not flag then
        systemIdList[#systemIdList + 1] = systemId
      end
    end
  end
  if 0 < #systemIdList then
    self:broadcastEvent("eGameEvent_HallPopupUnlockSystem", systemIdList)
  end
end

function Form_Hall:FreshRoleName()
  local roleName = RoleManager:GetName() or ""
  self.m_txt_name_Text.text = roleName
end

function Form_Hall:FreshRoleLevel()
  local curLevel = RoleManager:GetLevel() or 0
  self.m_txt_lv_num_Text.text = curLevel
end

function Form_Hall:FreshRoleExp()
  local roleExp = RoleManager:GetRoleExp() or 0
  local maxExp = RoleManager:GetRoleMaxExpNum(RoleManager:GetLevel())
  if maxExp then
    self.m_role_exp_Image.fillAmount = math.min(roleExp / maxExp, 1)
  else
    self.m_role_exp_Image.fillAmount = 1
  end
end

function Form_Hall:FreshHeadShow()
  local headID = RoleManager:GetHeadID()
  local roleHeadCfg = RoleManager:GetPlayerHeadCfg(headID)
  if not roleHeadCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, roleHeadCfg.m_HeadPic)
end

function Form_Hall:CheckRecycleHeadFrameNode()
  if self.m_headFrameEftStr and self.m_headFrameEftObj then
    utils.RecycleInParentUIPrefab(self.m_headFrameEftStr, self.m_headFrameEftObj)
  end
  self.m_headFrameEftStr = nil
  self.m_headFrameEftObj = nil
end

function Form_Hall:FreshHeadFrameShow()
  local headFrameID = RoleManager:GetHeadFrameID()
  local roleHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not roleHeadFrameCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_head_frame_Image, roleHeadFrameCfg.m_HeadFramePic, function()
    if not UILuaHelper.IsNull(self.m_head_frame_Image) then
      UILuaHelper.SetNativeSize(self.m_head_frame_Image)
    end
  end)
  if roleHeadFrameCfg.m_HeadFrameEft and roleHeadFrameCfg.m_HeadFrameEft ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_headFrameTrans, roleHeadFrameCfg.m_HeadFrameEft, function(nameStr, gameObject)
      self.m_headFrameEftStr = nameStr
      self.m_headFrameEftObj = gameObject
      self:FreshShowLeftHeadFrameChild()
    end)
  else
    UILuaHelper.SetActiveChildren(self.m_headFrameTrans, false)
  end
end

function Form_Hall:FreshShowLeftHeadFrameChild()
  local headFrameID = RoleManager:GetHeadFrameID()
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_headFrameTrans, false)
  if playerHeadFrameCfg.m_HeadFrameEft then
    local subNode = self.m_headFrameTrans:Find(playerHeadFrameCfg.m_HeadFrameEft)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function Form_Hall:RefreshHallActivityStatus()
  self:RefreshHallActivityStatus_CommonQuest()
  self:RefreshHallActivityStatus_LoginSelect()
  self:RefreshHallActivityStatus_LevelAward()
  self:RefreshHallActivityStatus_HeroAct()
  self:FreshHeroActSignPush()
  self:RefreshHallActivityStatus_Announment()
  self:RefreshMainActivityUI()
  self:ReFreshWelFareShow()
  self:OnRefreshEmergencyGift(false)
  self:CheckFreshBattlePassSubPanelShow()
end

function Form_Hall:RefreshHallActivityStatus_Announment()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  local openFlagAnnouncement = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Notice)
  if openFlagAnnouncement then
    local m_totalDataList = ActivityManager:GetActivityListByType(MTTD.ActivityType_GameNotice)
    if m_totalDataList then
      local curShouldShow = 0
      for i = 1, #m_totalDataList do
        if m_totalDataList[i]:checkCondition() and ActivityManager:CanShowRedCurrentLogin(m_totalDataList[i].m_stActivityData.iActivityId) then
          curShouldShow = curShouldShow + 1
        end
      end
      local getNextOpenUnReadAnnouTime = LocalDataManager:GetIntSimple("NextOpenUnReadAnnouTime", 0)
      local curTime = TimeUtil:GetServerTimeS()
      if getNextOpenUnReadAnnouTime < curTime then
        LocalDataManager:SetIntSimple("NextOpenUnReadAnnouTime", TimeUtil:GetServerNextCommonResetTime())
        if 0 < curShouldShow then
          self:broadcastEvent("eGameEvent_UnReadAccountment")
        end
      end
      self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
        redDotKey = RedDotDefine.ModuleType.AnnouncementEntry,
        count = curShouldShow
      })
    end
  end
end

function Form_Hall:RefreshHallActivityStatus_LoginSelect()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_LoginSelect)
  if stActivity then
    self.m_btnActSSR:SetActive(true)
    local bShowRed = stActivity:checkShowRed()
    self.m_imageActSSRRed:SetActive(bShowRed)
  else
    self.m_btnActSSR:SetActive(false)
  end
end

function Form_Hall:RefreshHallActivityStatus_CommonQuest()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  self.m_btnActQuest14:SetActive(false)
  for _, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_7 then
      local bShowRed = act:checkShowRed()
      self.m_QuestAct7 = act
    end
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_14 and act:checkCondition(true) then
      self.m_btnActQuest14:SetActive(true)
      local bShowRed = act:checkShowRed()
      self.m_imageActQuest14:SetActive(bShowRed)
      self.m_QuestAct14 = act
    end
  end
end

function Form_Hall:RefreshHallActivityStatus_LevelAward()
end

function Form_Hall:RefreshHeroAct()
  self.bIsWaittingActData = false
  self:RefreshHallActivityStatus_HeroAct()
  self:FreshHeroActSignPush()
end

function Form_Hall:ChangeHeroActShow()
  if not self.heroAct_List or #self.heroAct_List == 0 or not self.iHeroActIdx then
    return
  end
  local actInfo = self.heroAct_List[self.iHeroActIdx]
  if not actInfo then
    return
  end
  local config = actInfo.config
  self.m_HeroActID = config.m_ActivityID
  self:RegisterOrUpdateRedDotItem(self.m_activity_redpoint, RedDotDefine.ModuleType.HeroActHallEntry, {config = config})
  if self.ChangeActTimer then
    TimeService:KillTimer(self.ChangeActTimer)
    self.ChangeActTimer = nil
  end
  if #self.heroAct_List == 2 then
    if self.iHeroActIdx == 1 then
      UILuaHelper.PlayAnimationByName(self.m_btn_activity, "hall_activity_cut2")
      self.ChangeActTimer = TimeService:SetTimer(0.2, 1, function()
        self.m_activity2.transform:SetAsFirstSibling()
        self.m_img_mask1:SetActive(false)
        self.m_img_mask2:SetActive(true)
        self.m_bg_activityfarme_infront1:SetActive(true)
        self.m_bg_activityfarme_behind1:SetActive(false)
        self.m_bg_activityfarme_infront2:SetActive(false)
        self.m_bg_activityfarme_behind2:SetActive(true)
        self.m_pnl_101lamia1:SetActive("Atlas_ActivityBanner/1010" == config.m_ActivityBanner)
        self.m_pnl_101lamia2:SetActive(false)
        self.m_txt_activity2:SetActive(false)
        self.m_txt_activity1:SetActive(true)
      end)
      self.bIsChanging = true
      local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_btn_activity, "hall_activity_cut2")
      TimeService:SetTimer(aniLen, 1, function()
        self.bIsChanging = false
      end)
    else
      UILuaHelper.PlayAnimationByName(self.m_btn_activity, "hall_activity_cut")
      self.ChangeActTimer = TimeService:SetTimer(0.2, 1, function()
        self.m_activity1.transform:SetAsFirstSibling()
        self.m_img_mask1:SetActive(true)
        self.m_img_mask2:SetActive(false)
        self.m_bg_activityfarme_infront2:SetActive(true)
        self.m_bg_activityfarme_behind2:SetActive(false)
        self.m_bg_activityfarme_infront1:SetActive(false)
        self.m_bg_activityfarme_behind1:SetActive(true)
        self.m_pnl_101lamia2:SetActive("Atlas_ActivityBanner/1010" == config.m_ActivityBanner)
        self.m_pnl_101lamia1:SetActive(false)
        self.m_txt_activity2:SetActive(true)
        self.m_txt_activity1:SetActive(false)
      end)
      self.bIsChanging = true
      local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_btn_activity, "hall_activity_cut")
      TimeService:SetTimer(aniLen, 1, function()
        self.bIsChanging = false
      end)
    end
  end
end

function Form_Hall:RefreshHallActivityStatus_HeroAct()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  self.m_btn_activity:SetActive(false)
  self.m_activity1:SetActive(false)
  self.m_activity2:SetActive(false)
  local list = HeroActivityManager:GetOpenActList()
  if self.iHeroActChangeTimer then
    TimeService:KillTimer(self.iHeroActChangeTimer)
    self.iHeroActChangeTimer = nil
  end
  if list and next(list) then
    local heroAct_List = {}
    for k, v in pairs(list) do
      local config = HeroActivityManager:GetMainInfoByActID(k)
      if not config then
        log.error("Form_Hall:RefreshHallActivityStatus_HeroAct error! k = " .. tostring(k))
        return
      end
      local is_open = HeroActivityManager:IsMainActIsOpenByID(k)
      if is_open then
        local startTime = TimeUtil:TimeStringToTimeSec(config.m_OpenTime) or 0
        table.insert(heroAct_List, {config = config, startTime = startTime})
      end
    end
    table.sort(heroAct_List, function(a, b)
      return a.startTime > b.startTime
    end)
    self.m_btn_activity:SetActive(0 < #heroAct_List)
    self.m_btn_switch:SetActive(1 < #heroAct_List)
    if 0 < #heroAct_List then
      self:CheckShowActEnterTimer()
    end
    if self.iHeroActIdx > #heroAct_List then
      self.iHeroActIdx = 1
    end
    for i, v in ipairs(heroAct_List) do
      if 2 < i then
        break
      end
      local config = v.config
      local bIsSecondHalf = HeroActivityManager:IsSecondHalf(config.m_ActivityID)
      self["m_txt_activity" .. i .. "_Text"].text = bIsSecondHalf and config.m_mActivityTitleExtra or config.m_mActivityTitle
      UILuaHelper.SetAtlasSprite(self["m_bg_activity" .. i .. "_Image"], config.m_ActivityBanner)
      self["m_activity" .. i]:SetActive(true)
      self["m_img_mask" .. i]:SetActive(false)
      self["m_pnl_101lamia" .. i]:SetActive(false)
    end
    self.heroAct_List = heroAct_List
    self:ChangeHeroActShow()
    if 1 < #heroAct_List then
      self.iHeroActChangeTimer = TimeService:SetTimer(HeroActChangeInt, -1, function()
        self:OnBtnswitchClicked()
      end)
    end
  end
end

function Form_Hall:FreshHeroActSignPush()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  local list = HeroActivityManager:GetOpenActList()
  if list and next(list) then
    local heroAct_List = {}
    for k, v in pairs(list) do
      local config = HeroActivityManager:GetMainInfoByActID(k)
      if not config then
        log.error("Form_Hall:FreshHeroActSignPush error! k = " .. tostring(k))
        return
      end
      local is_open = HeroActivityManager:IsMainActIsOpenByID(k)
      if is_open then
        table.insert(heroAct_List, {config = config})
      end
    end
    if 0 < #heroAct_List and not HeroActivityManager:GetPushFlag() then
      for i, v in ipairs(heroAct_List) do
        local config = v.config
        local main_id = config.m_ActivityID
        if 0 < HeroActivityManager:IsHeroActSignEntryHaveRedDot(main_id) then
          do
            local subID = HeroActivityManager:GetSubFuncID(main_id, HeroActivityManager.SubActTypeEnum.Sign)
            local _, _, ui_id = HeroActivityManager:GetActJumpInfo(main_id, subID)
            TimeService:SetTimer(i * 0.1, 1, function()
              self:broadcastEvent("eGameEvent_HeroActSign", {
                FormID = ui_id,
                main_id = main_id,
                sub_id = subID,
                is_pushFace = true
              })
            end)
            HeroActivityManager:SetPushFlag()
          end
        end
      end
    end
  end
end

function Form_Hall:RefreshMainActivityUI()
  if self.m_vScrollActivityList == nil then
    return
  end
  local activityBannerList = ActivityManager:GetMainBannerActivityList()
  local redDotCount = 0
  local activeCount = 0
  local bannerCount = 0
  local bannerModify = false
  for _, v in ipairs(activityBannerList) do
    if v.Activity:checkCondition(true) then
      bannerCount = bannerCount + 1
      if self.m_vScrollActivityList[bannerCount] ~= v.Id then
        bannerModify = true
        self.m_vScrollActivityList[bannerCount] = v.Id
      end
    end
  end
  local activityList = ActivityManager:GetMainActivityList()
  for _, v in ipairs(activityList) do
    if v.Activity:checkCondition(true) then
      local subPanelName
      if v.Activity and v.Activity.getSubPanelName then
        subPanelName = v.Activity:getSubPanelName()
      end
      if subPanelName and subPanelName ~= "" then
        activeCount = activeCount + 1
        if v.Activity:checkShowRed() then
          redDotCount = redDotCount + 1
        end
      end
    end
  end
  self.m_btnActSign:SetActive(0 < activeCount)
  self.m_imageActSignRed:SetActive(0 < redDotCount)
  self:CheckShowActEnterTimer()
  local scrollCount = #self.m_vScrollActivityList
  while bannerCount < scrollCount do
    table.remove(self.m_vScrollActivityList, scrollCount)
    scrollCount = scrollCount - 1
    bannerModify = true
  end
  if bannerModify then
    self.m_bannerLockTime = nil
    self.m_currentBannerIndex = 1
    if 1 < bannerCount then
      self.m_bannerScrollTime = Banner_Scroll_Interval
    else
      self.m_bannerScrollTime = nil
    end
    if 0 < bannerCount then
      local cdnPic = ActivityManager:GetBannerCdnPic(self.m_vScrollActivityList[1])
      local pic = ActivityManager:GetBannerPic(self.m_vScrollActivityList[1])
      if cdnPic ~= "" then
        local actData = ActivityManager:GetActivityDataByID(self.m_vScrollActivityList[1])
        if actData then
          ActivityManager:SetActivityImage(actData, self.m_btn_img_banner_Image, cdnPic)
        end
      else
        UILuaHelper.SetAtlasSprite(self.m_btn_img_banner_Image, pic)
      end
      local act = ActivityManager:GetActivityByID(self.m_vScrollActivityList[1])
      if act and act:getData().sBriefDesc then
        UILuaHelper.SetActive(self.m_txt_bannertitle, true)
        self.m_txt_bannertitle_Text.text = act:getLangText(tostring(act:getData().sBriefDesc))
        UILuaHelper.PlayAnimationByName(self.m_txt_bannertitle, "m_txt_bannertitle_once")
      else
        self.m_txt_bannertitle_Text.text = ""
      end
    end
    local starRootTrans = self.m_pnl_list_banner_star.transform
    local childCount = starRootTrans.childCount
    while bannerCount > childCount do
      GameObject.Instantiate(self.m_img_star_grey, starRootTrans)
      childCount = childCount + 1
    end
    for i = 1, childCount do
      local child = starRootTrans:GetChild(i - 1)
      child.gameObject:SetActive(bannerCount >= i)
      local star = child:GetChild(0)
      star.gameObject:SetActive(i == self.m_currentBannerIndex)
    end
    self.m_btn_img_banner3:SetActive(false)
    self.m_btn_img_banner2:SetActive(false)
  end
  local openSoloRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_SoloRaid) ~= nil
  self.m_btnSoloRaid:SetActive(openSoloRaid)
  self.m_imageSoloRaidRed:SetActive(0 < PersonalRaidManager:IsHaveRedDot())
  local openHuntingRaid = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_Hunting) ~= nil
  self.m_btnHuntingNight:SetActive(openHuntingRaid)
  self.m_imageHuntingNight:SetActive(0 < HuntingRaidManager:IsHaveRedDot())
end

function Form_Hall:ReFreshWelFareShow()
  if self.m_csui ~= StackFlow:GetTopUI() then
    return
  end
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_WelfareShow)
  if stActivity then
    local bNeedShow = stActivity:checkShowActivity()
    self.m_btnParty:SetActive(bNeedShow)
    local bShowRed = stActivity:checkShowRed()
    self.m_imageParty:SetActive(bShowRed)
    if stActivity:IsNeedPushFace() then
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITYPARTY, {m_stActivity = stActivity})
    end
  else
    self.m_btnParty:SetActive(false)
  end
end

function Form_Hall:OnBtnswitchClicked()
  if self.bIsChanging then
    return
  end
  self.iHeroActIdx = self.iHeroActIdx == 1 and 2 or 1
  self:ChangeHeroActShow()
  if self.iHeroActChangeTimer then
    TimeService:KillTimer(self.iHeroActChangeTimer)
    self.iHeroActChangeTimer = nil
  end
  if #self.heroAct_List == 2 then
    self.iHeroActChangeTimer = TimeService:SetTimer(HeroActChangeInt, -1, function()
      self:OnBtnswitchClicked()
    end)
  end
end

function Form_Hall:FreshMainStoryProcess()
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  if not levelMainHelper then
    return
  end
  local nextLevelInfo = levelMainHelper:GetNextShowLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if nextLevelInfo then
    UILuaHelper.SetActive(self.m_txt_fight, true)
    self.m_txt_fight_Text.text = nextLevelInfo.m_LevelName
  else
    UILuaHelper.SetActive(self.m_txt_fight, false)
  end
end

function Form_Hall:CheckClearPopPanelStatus()
  PushFaceManager:CheckClearPopPanelStatus()
  PushFaceManager:CheckClearRewardPopList()
end

function Form_Hall:CheckShowNextPopPanel()
  PushFaceManager:CheckIsNotShowAndPopPanel()
end

function Form_Hall:CheckShowGachaDownTime()
  self:ClearGachaDownTimeData()
  local isShowDownTime = false
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  if openFlag then
    local firstEndGachaData = GachaManager:GetHallDownTimePoolAndLeftTime()
    if firstEndGachaData then
      local endTimer = firstEndGachaData.endTimer
      local leftSecNum = endTimer - TimeUtil:GetServerTimeS()
      if leftSecNum <= OneDayOfSecond then
        isShowDownTime = true
        self.m_isShowGachaDownTime = true
        self.m_curGachaEndTimer = endTimer
        self:FreshGachaDownTimeShow()
      else
        self.m_NextGachaDownTimer = TimeService:SetTimer(leftSecNum - OneDayOfSecond, 1, function()
          self.m_NextGachaDownTimer = nil
          self:CheckShowGachaDownTime()
        end)
      end
    end
  end
  UILuaHelper.SetActive(self.m_bg_countdown, isShowDownTime)
end

function Form_Hall:ClearGachaDownTimeData()
  self.m_isShowGachaDownTime = nil
  self.m_curGachaEndTimer = nil
end

function Form_Hall:FreshGachaDownTimeShow()
  if not self.m_isShowGachaDownTime then
    return
  end
  if not self.m_curGachaEndTimer then
    return
  end
  local leftSecNum = self.m_curGachaEndTimer - TimeUtil:GetServerTimeS()
  if 0 < leftSecNum then
    local showTimeStr = TimeUtil:SecondsToFormatStrDHOrHMS(leftSecNum)
    self.m_txt_countdown_Text.text = showTimeStr
  else
    self:CheckShowGachaDownTime()
  end
end

function Form_Hall:AddEventListeners()
  self:addEventListener("eGameEvent_Role_SetLevel", handler(self, self.OnEventRoleSetLevel))
  self:addEventListener("eGameEvent_Activity_HallActivityChange", handler(self, self.OnEventHallActivityChange))
  self:addEventListener("eGameEvent_Activity_CommonQuest_UpdateQuest", handler(self, self.OnEventActivityRefreshCommonQuest))
  self:addEventListener("eGameEvent_Activity_CommonQuest_TakeQuestReward", handler(self, self.OnEventActivityRefreshCommonQuest))
  self:addEventListener("eGameEvent_Activity_CommonQuest_TakeDailyReward", handler(self, self.OnEventActivityRefreshCommonQuest))
  self:addEventListener("eGameEvent_Activity_CommonQuest_TakeFinalReward", handler(self, self.OnEventActivityRefreshCommonQuest))
  self:addEventListener("eGameEvent_Activity_LoginSelectUpdate", handler(self, self.OnEventActivityLoginSelectUpdate))
  self:addEventListener("eGameEvent_Activity_LevelAwardUpdate", handler(self, self.OnEventActivityLevelAwardUpdate))
  self:addEventListener("eGameEvent_Inherit_UnLock", handler(self, self.OnInheritUnLockResponse))
  self:addEventListener("eGameEvent_HangUp_GetReward", handler(self, self.OnEventHangUpRefreshUI))
  self:addEventListener("eGameEvent_Alliance_OwnerDetail", handler(self, self.OnGetOwnerAllianceData))
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.RefreshHeroAct))
  self:addEventListener("eGameEvent_SoloRaid_GetData", handler(self, self.OnGetSoloRaidData))
  self:addEventListener("eGameEvent_RoleSetCard", handler(self, self.OnRoleSetCard))
  self:addEventListener("eGameEvent_HeroActTimeCfgUpdate", handler(self, self.CheckAndRqsHeroAct))
  self:addEventListener("eGameEvent_CastleDispatchStatueLevelUpRedPoint", handler(self, self.CheckSystemRedPoint))
  self:addEventListener("eGameEvent_Rename_SetName", handler(self, self.FreshRoleName))
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
  self:addEventListener("eGameEvent_Activity_EmergencyGiftPush", handler(self, self.OnEmergencyGift))
end

function Form_Hall:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Hall:OnEventRoleSetLevel(param)
  if not param then
    return
  end
  self:FreshRoleLevel()
end

function Form_Hall:OnEventHallActivityChange()
  self:RefreshHallActivityStatus()
end

function Form_Hall:OnEventActivityRefreshCommonQuest()
  self:RefreshHallActivityStatus_CommonQuest()
end

function Form_Hall:OnEventActivityLoginSelectUpdate()
  self:RefreshHallActivityStatus_LoginSelect()
end

function Form_Hall:OnEventActivityLevelAwardUpdate()
  self:RefreshHallActivityStatus_LevelAward()
end

function Form_Hall:OnInheritUnLockResponse()
  StackFlow:Push(UIDefines.ID_FORM_INHERIT)
end

function Form_Hall:OnEventHangUpRefreshUI()
  self:InitHangUpUI()
end

function Form_Hall:OnGetOwnerAllianceData(data)
  StackFlow:Push(UIDefines.ID_FORM_GUILD, data)
end

function Form_Hall:OnGetSoloRaidData()
  PersonalRaidManager:OpenPersonalRaidUI()
end

function Form_Hall:OnRoleSetCard(paramTab)
  if not paramTab then
    return
  end
  self:FreshHeadShow()
  self:FreshHeadFrameShow()
end

function Form_Hall:OnFullBurstDayUpdate()
  self.m_doublereward:SetActive(ActivityManager:IsFullBurstDayOpen())
end

function Form_Hall:OnBtnstorebpClicked()
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_BattlePass)
  if stActivity then
    if stActivity:GetCurLevel() > 0 then
      stActivity:RequestQuests(false, function()
        StackFlow:Push(UIDefines.ID_FORM_BATTLEPASS, {stActivity = stActivity})
      end)
    else
      stActivity:RequestActData(function()
        StackFlow:Push(UIDefines.ID_FORM_BATTLEPASS, {stActivity = stActivity})
      end)
    end
  end
end

function Form_Hall:OnBtnroleinfoClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD)
end

function Form_Hall:OnBtnfightClicked()
  if self.m_isInLoadScene then
    return
  end
  self.m_isInLoadScene = true
  if self.m_loadOverTime then
    TimeService:KillTimer(self.m_loadOverTime)
    self.m_loadOverTime = nil
  end
  self.m_loadOverTime = TimeService:SetTimer(3, 1, function()
    self.m_isInLoadScene = false
    self.m_loadOverTime = nil
  end)
  LevelManager:LoadLevelMapScene(function()
    log.info("Form_Hall OnBtnfightClicked LevelMap LoadBack")
    self.m_isInLoadScene = false
    BattleFlowManager:CheckSetEnterTimer(LevelManager.LevelType.MainLevel)
    StackFlow:Push(UIDefines.ID_FORM_LEVELMAIN)
    if self.m_loadOverTime then
      TimeService:KillTimer(self.m_loadOverTime)
      self.m_loadOverTime = nil
    end
  end)
end

function Form_Hall:OnBtnPartyClicked()
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_WelfareShow)
  if stActivity then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYPARTY, {m_stActivity = stActivity})
  end
end

function Form_Hall:OnBtnexpeditonClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Tower)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  BattleFlowManager:CheckSetEnterTimer(LevelManager.LevelType.Tower)
  StackFlow:Push(UIDefines.ID_FORM_TOWER)
end

function Form_Hall:OnBtnleftdown01Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Character)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HEROLIST, {is_from_hall = true})
end

function Form_Hall:OnBtnleftdown03Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Castle)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  SettingManager:SetEnterCastleInHall(true)
  ModuleManager:GetModuleByName("CastleModule"):EnterModule()
end

function Form_Hall:OnBtnleftdown04Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Guild)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local m_iAllianceId = RoleManager:GetRoleAllianceInfo()
  if not m_iAllianceId or tostring(m_iAllianceId) == "0" then
    local time = GuildManager:GetRecommendGuildTimer()
    if GUILD_REFRESH_CD and TimeUtil:GetServerTimeS() - time > GUILD_REFRESH_CD then
      GuildManager:ReqAllianceGetRecommendList()
    else
      local data = GuildManager:GetRecommendGuildList()
      if data then
        self:OnGetGuildListData(data)
      else
        log.error("GetRecommendGuild  is error")
      end
    end
  else
    GuildManager:ReqGetOwnerAllianceDetail(m_iAllianceId)
  end
end

function Form_Hall:OnBtnleftdown05Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Inherit)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  if InheritManager.m_inherit_level == 0 then
    InheritManager:ReqUnLockSystemInheritData()
  else
    StackFlow:Push(UIDefines.ID_FORM_INHERIT)
  end
end

function Form_Hall:OnBtnleftdown06Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  GachaManager:GetGachaData()
end

function Form_Hall:OnBtnleftdown07Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Circulation)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_CIRCULATIONMAIN)
end

function Form_Hall:OnBtnhallactivityClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Activity)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
end

function Form_Hall:OnBtnActSignClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMAIN)
end

function Form_Hall:OnBtnActQuest14Clicked()
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  local stActivity
  for key, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_14 then
      stActivity = act
      break
    end
  end
  if stActivity then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYDAYTASK14)
  else
    local paramData = {delayClose = 2, prompts = 30014}
    utils.createPromptTips(paramData)
    self:RefreshHallActivityStatus_CommonQuest()
  end
end

function Form_Hall:OnBtnActCommonQuestClicked()
  local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  local stActivity
  for key, act in pairs(act_list) do
    if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_7 then
      stActivity = act
      break
    end
  end
  if stActivity then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYDAYTASK)
  else
    local paramData = {delayClose = 2, prompts = 30014}
    utils.createPromptTips(paramData)
    self:RefreshHallActivityStatus_CommonQuest()
  end
end

function Form_Hall:OnBtnActSSRClicked()
  local stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_LoginSelect)
  if stActivity then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITYDAYTASKCHOOSE)
  else
    local paramData = {delayClose = 2, prompts = 30014}
    utils.createPromptTips(paramData)
    self:RefreshHallActivityStatus_CommonQuest()
  end
end

function Form_Hall:OnBtnActLevelClicked()
end

function Form_Hall:OnBtnlefttop01Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TASK)
end

function Form_Hall:OnBtnlefttop02Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Mail)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_EMAIL)
end

function Form_Hall:OnBtnlefttop03Clicked()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.Setting, true) then
    return
  end
  if ChannelManager:IsWindows() then
    StackFlow:Push(UIDefines.ID_FORM_BATTLESETTING, {
      hideTypeList = {5, 6}
    })
  else
    StackFlow:Push(UIDefines.ID_FORM_BATTLESETTING)
  end
end

function Form_Hall:OnBtnlefttop04Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Bag)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BAGNEW)
end

function Form_Hall:OnBtnlefttop05Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Notice)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITYANNOUNCELOTTERYPAGE)
end

function Form_Hall:OnBtnlefttop06Clicked()
  QuickOpenFuncUtil:OpenFunc(23)
end

function Form_Hall:OnBtnstorefreeClicked()
  StackFlow:Push(UIDefines.ID_FORM_SHOP)
end

function Form_Hall:OnBtnSoloRaidClicked()
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SoloRaid)
  if isOpen then
    PersonalRaidManager:ReqSoloRaidGetDataCS()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function Form_Hall:OnBtnHuntingNightClicked()
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen then
    HuntingRaidManager:OpenHuntingRaidUI()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function Form_Hall:OnHangupClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  if TimeUtil:GetServerTimeS() - tonumber(HangUpManager.m_iSeeRewardTime) > AFK_REQUEST_INTERVAL then
    HangUpManager:ReqGetHangUpData()
  else
    StackFlow:Push(UIDefines.ID_FORM_HANGUP)
  end
end

function Form_Hall:OnBtndownloadClicked()
  StackFlow:Push(UIDefines.ID_FORM_DOWNLOADPOPUP)
end

function Form_Hall:OnBtngmClicked()
  StackFlow:Push(UIDefines.ID_FORM_STAGESELECT_NEW)
end

function Form_Hall:OnBtnactivityClicked()
  if self.m_HeroActID then
    HeroActivityManager:GotoHeroActivity({
      main_id = self.m_HeroActID,
      isPlayTimeLine = true
    })
    local reportStr = "click_" .. tostring(self.m_HeroActID) .. "_1"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
    LocalDataManager:SetIntSimple("HeroActHallEntry_Red_Point" .. self.m_HeroActID, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
  end
end

function Form_Hall:OnBtnstoremoneyClicked()
  StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW)
end

function Form_Hall:OnBtnlefttopdecorateClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Decorate)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  local curMainBgCfgID
  if self.m_bgPanelCom then
    curMainBgCfgID = self.m_bgPanelCom:GetCurUseMainBackgroundID()
  end
  StackFlow:Push(UIDefines.ID_FORM_HALLDECORATE, {userMainBackgroundID = curMainBgCfgID})
end

function Form_Hall:OnBtnlefttop7Clicked()
  self.m_isHideContent = true
  self:FreshContentAndBackShow()
end

function Form_Hall:OnBtnbackClicked()
  self.m_isHideContent = false
  self:FreshContentAndBackShow()
end

function Form_Hall:OnBtnlefttopallClicked()
  self.m_isShowSubPanelOther = not self.m_isShowSubPanelOther
  self:FreshSubPanelOtherShow()
end

function Form_Hall:OnBtnstorepushClicked()
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_EmergencyGift)
  if act then
    local isCan = act:IsCanPushFace()
    if isCan then
      StackPopup:Push(UIDefines.ID_FORM_PUSH_GIFT_RESERVE, {
        activityId = act:getID()
      })
    end
  end
end

function Form_Hall:OnEmergencyGift(params)
  self:OnRefreshEmergencyGift(params.isPush)
end

function Form_Hall:OnRefreshEmergencyGift(isPush)
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_EmergencyGift)
  if act then
    local pushGift = act:GetPackList()
    if pushGift and 0 < #pushGift then
      if isPush then
        self:broadcastEvent("eGameEvent_EmergencyGiftPushFace", {
          activityId = act:getID(),
          isPush = true
        })
      end
      local packGiftDataFirst = pushGift[1]
      local giftInfo = packGiftDataFirst.GiftInfo
      self.m_txt_tag_Text.text = giftInfo.iDiscount .. "%"
      local giftInfo = packGiftDataFirst.GiftInfo
      local productInfo = packGiftDataFirst.ProductInfo
      local endTime = productInfo.iTriggerTime + giftInfo.iGiftDuration
      local lastTime = endTime - TimeUtil:GetServerTimeS()
      self.m_txt_shop_push_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(lastTime)
      self:ClearEmergencyGiftTimer()
      self.m_countDownTimer = TimeService:SetTimer(1, -1, function()
        local time = endTime - TimeUtil:GetServerTimeS()
        if self.m_txt_shop_push then
          self.m_txt_shop_push_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(time)
        end
        if time <= 0 then
          self:ClearEmergencyGiftTimer()
          self:OnRefreshEmergencyGift(false)
        end
      end)
      self.m_btn_store_push:SetActive(true)
    else
      self.m_btn_store_push:SetActive(false)
    end
  else
    self.m_btn_store_push:SetActive(false)
  end
end

function Form_Hall:ClearEmergencyGiftTimer()
  if self.m_countDownTimer ~= nil then
    TimeService:KillTimer(self.m_countDownTimer)
    self.m_countDownTimer = nil
  end
end

function Form_Hall:CheckShowActEnterTimer()
  self.m_z_txt_ActSign:SetActive(true)
  self.m_txt_ActSign:SetActive(false)
  local isShowTimer = false
  local actList = ActivityManager:GetActivityListByType(MTTD.ActivityType_Sign)
  local endTime = 0
  for _, v in pairs(actList) do
    if v and v:checkCondition() and 0 < v:GetShowHallActTimer() and v:GetShowHallActTimer() > TimeUtil:GetServerTimeS() then
      isShowTimer = true
      endTime = v:GetShowHallActTimer()
    end
  end
  if isShowTimer then
    self.m_z_txt_ActSign:SetActive(false)
    self.m_txt_ActSign:SetActive(true)
    local lastTime = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_ActSign_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(lastTime)
    self:ClearActEnterTimer()
    self.m_actEnterTimer = TimeService:SetTimer(1, -1, function()
      lastTime = endTime - TimeUtil:GetServerTimeS()
      if lastTime < 0 then
        self:ClearActEnterTimer()
        self.m_z_txt_ActSign:SetActive(true)
        self.m_txt_ActSign:SetActive(false)
      end
      self.m_txt_ActSign_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(lastTime)
    end)
  else
    self.m_z_txt_ActSign:SetActive(true)
    self.m_txt_ActSign:SetActive(false)
  end
end

function Form_Hall:ClearActEnterTimer()
  if self.m_actEnterTimer then
    TimeService:KillTimer(self.m_actEnterTimer)
    self.m_actEnterTimer = nil
  end
end

function Form_Hall:CheckAndShowLetter()
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AttractMail)
  if not isOpen then
    self.m_btn_Attract:SetActive(false)
    return
  end
  local letterHeroList = AttractManager:GetLetterHeroList()
  if letterHeroList and 0 < #letterHeroList then
    self.m_btn_Attract:SetActive(true)
    local cfg = UnlockSystemUtil:GetSystemUnlockConfig(GlobalConfig.SYSTEM_ID.AttractMail)
    self.m_txt_Attract_Text.text = cfg.m_mName
  else
    self.m_btn_Attract:SetActive(false)
  end
end

function Form_Hall:OnBtnAttractClicked()
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTLETTER, {bIsInAttract = false, isReading = true})
end

function Form_Hall:GetDownloadResourceExtra(tParam)
end

function Form_Hall:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Hall", Form_Hall)
return Form_Hall
