local UIHeroActMainBase = class("UIHeroActMainBase", require("UI/Common/UIBase"))
local ItemIns = ConfigManager:GetConfigInsByName("Item")

function UIHeroActMainBase:AfterInit()
  UIHeroActMainBase.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_curBgPrefabStr = nil
  self.m_curBgObj = nil
end

function UIHeroActMainBase:OnActive()
  UIHeroActMainBase.super.OnActive(self)
  self.iCurGachaIndex = 1
  self.act_id = self.m_csui.m_param.main_id
  self.openTime = TimeUtil:GetServerTimeS()
  self.report_name = self.act_id .. "/" .. self:GetFramePrefabName()
  HeroActivityManager:ReportActOpen(self.report_name, {
    openTime = self.openTime
  })
  if self.act_id then
    local reportStr = "click_" .. tostring(self.act_id) .. "_2"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.m_csui.m_param.main_id)
  self:createBackButton(self.goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, config.m_TipsID)
  self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.FreshExtraAct))
  self:addEventListener("eGameEvent_RefreshShopData", handler(self, self.OnEventShopRefresh))
  self:RegisterRedDot()
  self:CheckAndCreatBg()
  self:FreshUI()
  self:FreshExtraAct()
end

function UIHeroActMainBase:FreshExtraAct()
  self:Fresh14DaysActState()
end

function UIHeroActMainBase:OnGetGachaData(windowId)
  local form = StackFlow:GetOpenUIInstanceLua(UIDefines.ID_FORM_HALL)
  if form ~= nil then
    return
  end
  local isPlayAudio = true
  StackFlow:Push(UIDefines.ID_FORM_GACHAMAIN, {windowId = windowId, isPlayAudio = isPlayAudio})
end

function UIHeroActMainBase:OnInactive()
  UIHeroActMainBase.super.OnInactive(self)
  self:CloseTimer()
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
  self:CheckRecycleBgNode()
  self:clearEventListener()
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
end

function UIHeroActMainBase:OnDestroy()
  UIHeroActMainBase.super.OnDestroy(self)
  self:CheckRecycleBgNode()
  self:CloseTimer()
end

function UIHeroActMainBase:CloseTimer()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  if self.i14Daytimer then
    TimeService:KillTimer(self.i14Daytimer)
    self.i14Daytimer = nil
  end
  if self.iGuildRaidtimer then
    TimeService:KillTimer(self.iGuildRaidtimer)
    self.iGuildRaidtimer = nil
  end
  if self.iSoloRaidtimer then
    TimeService:KillTimer(self.iSoloRaidtimer)
    self.iSoloRaidtimer = nil
  end
end

function UIHeroActMainBase:CheckRecycleBgNode()
  if self.m_curBgPrefabStr and not utils.isNull(self.m_curBgObj) then
    utils.RecycleInParentUIPrefab(self.m_curBgPrefabStr, self.m_curBgObj)
  end
  self.m_curBgPrefabStr = nil
  self.m_curBgObj = nil
end

function UIHeroActMainBase:CheckAndCreatBg()
  if utils.isNull(self.m_BGRoot) then
    return
  end
  if self.m_BGRoot.transform.childCount > 0 then
    return
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local tempPrefabStr = config.m_BCPrefab
  if tempPrefabStr and tempPrefabStr ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_BGRoot.transform, tempPrefabStr, function(nameStr, gameObject)
      self.m_curBgPrefabStr = nameStr
      self.m_curBgObj = gameObject
    end)
  end
end

function UIHeroActMainBase:FreshUI()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if not utils.isNull(self.m_txt_title_Text) then
    self.m_txt_title_Text.text = config.m_mActivityTitle
  end
  if not utils.isNull(self.m_txt_des_Text) then
    self.m_txt_des_Text.text = config.m_mActivityDes
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local open_state, endTime = HeroActivityManager:GetActOpenState(self.act_id)
  if not endTime then
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    return
  end
  local left_time = endTime - curTimer
  if left_time <= 0 then
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    return
  end
  if not utils.isNull(self.m_txt_remaining_time_Text) then
    if open_state == HeroActivityManager.ActOpenState.Normal then
      self.m_txt_remaining_time_Text.text = ConfigManager:GetCommonTextById(100072)
    elseif open_state == HeroActivityManager.ActOpenState.WaitingClose then
      self.m_txt_remaining_time_Text.text = ConfigManager:GetCommonTextById(100073)
    end
  end
  if not utils.isNull(self.m_txt_time_Text) then
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  end
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.timer)
      if open_state == HeroActivityManager.ActOpenState.WaitingClose then
        StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
        return
      else
        self:FreshUI()
      end
    end
    if not utils.isNull(self.m_txt_time_Text) then
      self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
    end
  end)
  if open_state == HeroActivityManager.ActOpenState.Normal then
    local challenge_config_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
    local unlock_flag, unlock_type, lock_str = HeroActivityManager:IsSubActIsOpenByID(self.act_id, challenge_config_id)
    if not utils.isNull(self.m_txt_challenge_tips) then
      self.m_txt_challenge_tips:SetActive(not unlock_flag)
    end
    if not utils.isNull(self.m_img_lock) then
      self.m_img_lock:SetActive(not unlock_flag)
    end
    if not utils.isNull(self.m_txt_new) then
      self.m_txt_new:SetActive(false)
    end
    if not unlock_flag then
      local challenge_config = HeroActivityManager:GetSubInfoByID(challenge_config_id)
      if not utils.isNull(self.m_txt_challenge_tips_Text) then
        self.m_txt_challenge_tips_Text.text = lock_str or ""
      end
      local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, challenge_config_id)
      if is_corved then
        if not utils.isNull(self.m_txt_challenge_tips_time_Text) then
          self.m_txt_challenge_tips_time_Text.text = TimeUtil:TimerToString3(t1)
        end
      elseif not utils.isNull(self.m_txt_challenge_tips_time_Text) then
        self.m_txt_challenge_tips_time_Text.text = challenge_config.m_OpenTime
      end
    end
  else
    if not utils.isNull(self.m_z_txt_challenge_end) then
      self.m_z_txt_challenge_end:SetActive(true)
    end
    if not utils.isNull(self.m_img_activity_end) then
      self.m_img_activity_end:SetActive(true)
    end
    if not utils.isNull(self.m_txt_challenge_tips) then
      self.m_txt_challenge_tips:SetActive(false)
    end
    if not utils.isNull(self.m_txt_new) then
      self.m_txt_new:SetActive(false)
    end
  end
  local itemCfg = ItemIns:GetValue_ByItemID(config.m_ShopItem)
  if not itemCfg then
    log.error("UIHeroActMainBase:FreshUI Shop itemCfg is nil ItemID: " .. config.m_ShopItem)
    return
  end
  if not utils.isNull(self.m_icon1_Image) then
    UILuaHelper.SetAtlasSprite(self.m_icon1_Image, "Atlas_Item/" .. itemCfg.m_IconPath)
  end
  if not utils.isNull(self.m_txt_num1_Text) then
    self.m_txt_num1_Text.text = ItemManager:GetItemNum(config.m_ShopItem)
  end
  local time_line = config.m_ActivityAnimation
  if not time_line or time_line == "" then
    if not utils.isNull(self.m_btn_introduction) then
      self.m_btn_introduction:SetActive(false)
    end
  elseif not utils.isNull(self.m_btn_introduction) then
    self.m_btn_introduction:SetActive(true)
  end
  self:FreshGachaUI()
end

function UIHeroActMainBase:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_login_redpoint, RedDotDefine.ModuleType.HeroActSignEntry, self.act_id)
  self:RegisterOrUpdateRedDotItem(self.m_task_redpoint, RedDotDefine.ModuleType.HeroActTaskEntry, self.act_id)
  local challengeSubActID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
  self:RegisterOrUpdateRedDotItem(self.m_challenge_redpoint, RedDotDefine.ModuleType.HeroActChallengeEntry, challengeSubActID)
  local normalSubActID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.NormalLevel)
  self:RegisterOrUpdateRedDotItem(self.m_activity_redpoint, RedDotDefine.ModuleType.HeroActActivityEntry, normalSubActID)
  self:RegisterOrUpdateRedDotItem(self.m_storyentry_redpoint, RedDotDefine.ModuleType.HeroActMemoryEntry, self.act_id)
  self:RegisterOrUpdateRedDotItem(self.m_store_redpoint, RedDotDefine.ModuleType.HeroActShopEntry, self.act_id)
  self:RegisterOrUpdateRedDotItem(self.m_free_redpoint, RedDotDefine.ModuleType.HeroActFreeEntry, self.act_id)
end

function UIHeroActMainBase:OnBtnintroductionClicked()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local time_line = config.m_ActivityAnimation
  if not time_line or time_line == "" then
    return
  end
  CS.UI.UILuaHelper.PlayTimeline(time_line, true, "", function()
  end)
end

function UIHeroActMainBase:OnBackClk()
  self:clearEventListener()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  self:GoBackFormHall()
end

function UIHeroActMainBase:OnEventShopRefresh()
  if self.bIsWaitingShopData then
    local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
    QuickOpenFuncUtil:OpenFunc(config.m_ShopJumpID)
    self.bIsWaitingShopData = false
  end
end

function UIHeroActMainBase:OnBtnstoreClicked()
  if self.act_id then
    local reportStr = "click_" .. tostring(self.act_id) .. "_3"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local jumpIns = ConfigManager:GetConfigInsByName("Jump")
  local jump_item = jumpIns:GetValue_ByJumpID(config.m_ShopJumpID)
  local windowId = jump_item.m_Param.Length > 0 and tonumber(jump_item.m_Param[0]) or 0
  local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
  local shop_id
  for i, v in ipairs(shop_list) do
    if v.m_WindowID == windowId then
      shop_id = v.m_ShopID
    end
  end
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
    id = self.act_id,
    shop_id = shop_id
  })
  if is_corved and not TimeUtil:IsInTime(t1, t2) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  self.bIsWaitingShopData = true
  ShopManager:ReqGetShopData(shop_id)
end

function UIHeroActMainBase:OnBtnloginClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.Sign)
  })
end

function UIHeroActMainBase:OnBtntaskClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.Task)
  })
end

function UIHeroActMainBase:FreshGachaUI()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if not config then
    return
  end
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  if #gachaJumpIDArray <= 1 then
    return
  end
  if utils.isNull(self.m_DoubleGacha) or utils.isNull(self.m_Gacha) or utils.isNull(self.m_btn_convert) then
    return
  end
  local bIsSecondGachaOpen = HeroActivityManager:IsSecondGachaOpen(self.act_id)
  if not bIsSecondGachaOpen then
    self.m_DoubleGacha:SetActive(false)
    self.m_Gacha:SetActive(true)
    self.m_btn_convert:SetActive(false)
  else
    self.m_DoubleGacha:SetActive(true)
    self.m_Gacha:SetActive(false)
    self.m_btn_convert:SetActive(true)
  end
  self.m_img_bom_icon01:SetActive(self.iCurGachaIndex ~= 1)
  self.m_img_bom_icon02:SetActive(self.iCurGachaIndex ~= 2)
  self.m_img_top_icon01:SetActive(self.iCurGachaIndex == 1)
  self.m_img_top_icon02:SetActive(self.iCurGachaIndex == 2)
end

function UIHeroActMainBase:OnBtnconvertClicked()
  if utils.isNull(self.m_DoubleGacha) then
    return
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  self.iCurGachaIndex = self.iCurGachaIndex + 1
  if self.iCurGachaIndex > #gachaJumpIDArray then
    self.iCurGachaIndex = 1
  end
  local sAniName = self.iCurGachaIndex == 1 and "Activity106Main_GachaBtn_switch2" or "Activity106Main_GachaBtn_switch1"
  UILuaHelper.PlayAnimationByName(self.m_DoubleGacha, sAniName)
  local fAniLen = UILuaHelper.GetAnimationLengthByName(self.m_DoubleGacha, sAniName)
  self.m_UILockID = UILockIns:Lock(fAniLen)
  self:FreshGachaUI()
end

function UIHeroActMainBase:OnBtngachaClicked()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  if self.iCurGachaIndex > #gachaJumpIDArray then
    self.iCurGachaIndex = 1
  end
  self:GotoGacha(gachaJumpIDArray[self.iCurGachaIndex])
end

function UIHeroActMainBase:GotoGacha(gachaInfo)
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
    id = self.act_id,
    gacha_id = gachaInfo[1]
  })
  if is_corved and not TimeUtil:IsInTime(t1, t2) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
    return
  end
  QuickOpenFuncUtil:OpenFunc(gachaInfo[2])
end

function UIHeroActMainBase:OnBtnactivityClicked()
  self:GotoNormalLevel(1)
end

function UIHeroActMainBase:GotoNormalLevel(idx)
  if self.act_id then
    local reportStr = "click_" .. tostring(self.act_id) .. "_4"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  end
  local subActivityID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.NormalLevel, idx)
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = subActivityID
  })
  LocalDataManager:SetIntSimple("SubActEnter_Red_Point" .. self.act_id, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
end

function UIHeroActMainBase:OnBtnchallengeClicked()
  if self.act_id then
    local reportStr = "click_" .. tostring(self.act_id) .. "_5"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  end
  local subActivityID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = subActivityID
  })
  LocalDataManager:SetIntSimple("SubActLeftTimesEntry_Red_Point" .. self.act_id, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
end

function UIHeroActMainBase:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    self:GoBackFormHall()
  end
end

function UIHeroActMainBase:Fresh14DaysActState()
  local list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
  local curAct
  for _, act in pairs(list) do
    if act:GetUpActivityID() == self.act_id then
      curAct = act
      break
    end
  end
  self.cur14DayAct = curAct
  local state, iTime = HeroActivityManager:GetActState(curAct)
  if 0 < state then
    self.m_btn_free:SetActive(true)
    local bIsLock = state == HeroActivityManager.ExtraActState.Lock
    self.m_time_node:SetActive(bIsLock)
    self.m_img_free_light:SetActive(not bIsLock)
    self.m_img_free_gray:SetActive(bIsLock)
    if bIsLock then
      if self.i14Daytimer then
        TimeService:KillTimer(self.i14Daytimer)
        self.i14Daytimer = nil
      end
      if iTime <= 0 then
        self.m_btn_free:SetActive(false)
        return
      end
      self.m_txt_free_time_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20358), TimeUtil:SecondsToFormatCNStr(iTime))
      self.i14Daytimer = TimeService:SetTimer(1, -1, function()
        iTime = iTime - 1
        if iTime <= 0 then
          TimeService:KillTimer(self.i14Daytimer)
        end
        if utils.isNull(self.m_txt_free_time_Text) then
          TimeService:KillTimer(self.i14Daytimer)
          return
        end
        self.m_txt_free_time_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20358), TimeUtil:SecondsToFormatCNStr(iTime))
      end)
    end
  elseif not utils.isNull(self.m_btn_free) then
    self.m_btn_free:SetActive(false)
  end
end

function UIHeroActMainBase:OnBtnfreeClicked()
  if self.cur14DayAct then
    local state = HeroActivityManager:GetActState(self.cur14DayAct)
    if state == HeroActivityManager.ExtraActState.Normal then
      QuickOpenFuncUtil:JumpUpActivity14DayTaskForm(self.act_id)
      local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
      local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("HeroActFreeEntry_Red_Point_" .. self.act_id, 0)
      if bIsNewDay then
        LocalDataManager:SetIntSimple("HeroActFreeEntry_Red_Point_" .. self.act_id, nextDayResetTime, true)
      end
    else
      StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20068))
    end
  else
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20068))
  end
end

function UIHeroActMainBase:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.main_id then
    local act_id = tParam.main_id
    local config = HeroActivityManager:GetMainInfoByActID(act_id)
    vResourceExtra[#vResourceExtra + 1] = {
      sName = config.m_BCPrefab,
      eType = DownloadManager.ResourceType.UI
    }
  end
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "Form_InteractiveGame",
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

function UIHeroActMainBase:IsFullScreen()
  return true
end

return UIHeroActMainBase
