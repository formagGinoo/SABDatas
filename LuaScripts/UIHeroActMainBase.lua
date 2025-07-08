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
  self:createBackButton(self.goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), config.m_TipsID)
  self:addEventListener("eGameEvent_RefreshShopData", handler(self, self.OnEventShopRefresh))
  self:RegisterRedDot()
  self:CheckAndCreatBg()
  self:FreshUI()
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
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
  self:CheckRecycleBgNode()
  self:clearEventListener()
end

function UIHeroActMainBase:OnDestroy()
  UIHeroActMainBase.super.OnDestroy(self)
  self:CheckRecycleBgNode()
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
end

function UIHeroActMainBase:CheckRecycleBgNode()
  if self.m_curBgPrefabStr and self.m_curBgObj then
    utils.RecycleInParentUIPrefab(self.m_curBgPrefabStr, self.m_curBgObj)
  end
  self.m_curBgPrefabStr = nil
  self.m_curBgObj = nil
end

function UIHeroActMainBase:CheckAndCreatBg()
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
  self.m_txt_title_Text.text = config.m_mActivityTitle
  self.m_txt_des_Text.text = config.m_mActivityDes
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
  if open_state == HeroActivityManager.ActOpenState.Normal then
    self.m_txt_remaining_time_Text.text = ConfigManager:GetCommonTextById(100072)
  elseif open_state == HeroActivityManager.ActOpenState.WaitingClose then
    self.m_txt_remaining_time_Text.text = ConfigManager:GetCommonTextById(100073)
  end
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  if self.timer then
    TimeService:KillTimer(self.timer)
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
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  end)
  if open_state == HeroActivityManager.ActOpenState.Normal then
    local challenge_config_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
    local unlock_flag, unlock_type, lock_str = HeroActivityManager:IsSubActIsOpenByID(self.act_id, challenge_config_id)
    self.m_txt_challenge_tips:SetActive(not unlock_flag)
    self.m_img_lock:SetActive(not unlock_flag)
    self.m_txt_new:SetActive(false)
    if not unlock_flag then
      local challenge_config = HeroActivityManager:GetSubInfoByID(challenge_config_id)
      self.m_txt_challenge_tips_Text.text = lock_str or ""
      local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, challenge_config_id)
      if is_corved then
        self.m_txt_challenge_tips_time_Text.text = TimeUtil:TimerToString3(t1)
      else
        self.m_txt_challenge_tips_time_Text.text = challenge_config.m_OpenTime
      end
    end
  else
    self.m_z_txt_challenge_end:SetActive(true)
    self.m_img_activity_end:SetActive(true)
    self.m_txt_challenge_tips:SetActive(false)
    self.m_txt_new:SetActive(false)
  end
  local itemCfg = ItemIns:GetValue_ByItemID(config.m_ShopItem)
  UILuaHelper.SetAtlasSprite(self.m_icon1_Image, "Atlas_Item/" .. itemCfg.m_IconPath)
  self.m_txt_num1_Text.text = ItemManager:GetItemNum(config.m_ShopItem)
end

function UIHeroActMainBase:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_login_redpoint, RedDotDefine.ModuleType.HeroActSignEntry, self.act_id)
  self:RegisterOrUpdateRedDotItem(self.m_task_redpoint, RedDotDefine.ModuleType.HeroActTaskEntry, self.act_id)
  local challengeSubActID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.ChallengeLevel)
  self:RegisterOrUpdateRedDotItem(self.m_challenge_redpoint, RedDotDefine.ModuleType.HeroActChallengeEntry, challengeSubActID)
  local hardSubActID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.DiffLevel)
  self:RegisterOrUpdateRedDotItem(self.m_activity_redpoint, RedDotDefine.ModuleType.HeroActActivityEntry, hardSubActID)
  self:RegisterOrUpdateRedDotItem(self.m_storyentry_redpoint, RedDotDefine.ModuleType.HeroActMemoryEntry, self.act_id)
  self:RegisterOrUpdateRedDotItem(self.m_store_redpoint, RedDotDefine.ModuleType.HeroActShopEntry, self.act_id)
end

function UIHeroActMainBase:OnBtnintroductionClicked()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local time_line = config.m_ActivityAnimation
  CS.UI.UILuaHelper.PlayTimeline(time_line, true, "", function()
  end)
end

function UIHeroActMainBase:OnBackClk()
  self:clearEventListener()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
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
  local windowId = jump_item.m_WindowID
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
  ShopManager:ReqGetShopData(shop_id)
  self.bIsWaitingShopData = true
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

function UIHeroActMainBase:OnBtngachaClicked()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
  local m_gachaAllCfg = GachaIns:GetAll()
  local gacha_id
  for _, v in pairs(m_gachaAllCfg) do
    if v.m_ActId and v.m_ActId == self.act_id then
      gacha_id = v.m_GachaID
    end
  end
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
    id = self.act_id,
    gacha_id = gacha_id
  })
  if is_corved and not TimeUtil:IsInTime(t1, t2) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
    return
  end
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  QuickOpenFuncUtil:OpenFunc(gachaJumpIDArray[1])
end

function UIHeroActMainBase:OnBtnactivityClicked()
  if self.act_id then
    local reportStr = "click_" .. tostring(self.act_id) .. "_4"
    local params = {Event_id = reportStr}
    ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
  end
  local subActivityID = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.NormalLevel)
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
  return vPackage, vResourceExtra
end

function UIHeroActMainBase:IsFullScreen()
  return true
end

return UIHeroActMainBase
