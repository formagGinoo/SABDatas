local Form_HallActivityMain = class("Form_HallActivityMain", require("UI/UIFrames/Form_HallActivityMainUI"))
local __pnl_enter_info = {
  {
    system_id = GlobalConfig.SYSTEM_ID.Tower,
    btn = "m_btn_tower",
    btn_lock = "m_btn_towerlock",
    item = "m_item_tower",
    item_lock = "m_item_locktower",
    reward_icon = "m_icon_rewardtower",
    lock_reward_icon = "m_icon_rewardlocktower"
  },
  {
    system_id = GlobalConfig.SYSTEM_ID.LegacyLevel,
    btn = "m_btn_legacy",
    btn_lock = "m_btn_legacylock",
    item = "m_item_legacy",
    item_lock = "m_item_locklegacy",
    reward_icon = "m_icon_rewardlegacy",
    lock_reward_icon = "m_icon_rewardlocklegacy"
  },
  {
    system_id = GlobalConfig.SYSTEM_ID.Dungeon,
    btn = "m_btn_boss",
    btn_lock = "m_btn_bosslock",
    item = "m_item_boss",
    item_lock = "m_item_lockboss",
    reward_icon = "m_icon_rewardboss",
    lock_reward_icon = "m_icon_rewardlockboss"
  },
  {
    system_id = GlobalConfig.SYSTEM_ID.Arena,
    btn = "m_btn_pvp",
    btn_lock = "m_btn_pvplock",
    item = "m_item_pvp",
    item_lock = "m_item_lockpvp",
    reward_icon = "m_icon_reward_pvp",
    lock_reward_icon = "m_icon_rewardlockpvp"
  },
  {
    system_id = GlobalConfig.SYSTEM_ID.RogueStage,
    btn = "m_btn_roguestage",
    btn_lock = "m_btn_roguestagelock",
    item = "m_item_roguestage",
    item_lock = "m_item_lock_roguestage",
    reward_icon = "m_icon_reward_roguestage",
    lock_reward_icon = "m_icon_rewardlock_roguestage"
  }
}

function Form_HallActivityMain:SetInitParam(param)
end

function Form_HallActivityMain:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_widgetTaskEnter = self:createTaskBar(self.m_common_task_enter)
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self:CheckRegisterRedDot()
end

function Form_HallActivityMain:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param or {}
  self.m_openPvp = param.openPvp
  self.m_csui.m_param = nil
  self:RefreshUI()
  self:AddEventListeners()
  self.m_widgetResourceBar:FreshChangeItems()
  if self.m_openPvp then
    self.m_openPvp = false
    self:OnBtnpvpClicked()
  end
  GlobalManagerIns:TriggerWwiseBGMState(254)
end

function Form_HallActivityMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HallActivityMain:AddEventListeners()
  self:addEventListener("eGameEvent_RankGetList", handler(self, self.OnEventRankGetList))
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
end

function Form_HallActivityMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HallActivityMain:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_redpoint_pvp, RedDotDefine.ModuleType.LevelEntry, BattleFlowManager.ArenaType.Arena)
  self:RegisterOrUpdateRedDotItem(self.m_redpoint_ranklist, RedDotDefine.ModuleType.GlobalRankEntry)
end

function Form_HallActivityMain:OnFullBurstDayUpdate()
  self.m_doublereward_simroon:SetActive(ActivityManager:IsFullBurstDayOpen())
  self.m_doublereward_boss:SetActive(ActivityManager:IsFullBurstDayOpen())
end

function Form_HallActivityMain:RefreshUI()
  for i, v in ipairs(__pnl_enter_info) do
    self:RefreshEnterUI(i)
    local redPoint = ActivityManager:CheckHallActivityHaveRedPointBySystemID(v.system_id) or 0
    self:ShowRedPoint(v.system_id, redPoint)
  end
  self:OnFullBurstDayUpdate()
  self:RefreshPvpRewardEnterUI()
end

function Form_HallActivityMain:RefreshPvpRewardEnterUI()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    self.m_btn_reward_pvp:SetActive(false)
    return
  end
  local isRankHaveReward = PvpReplaceManager:IsAfkRankCanReward()
  if isRankHaveReward then
    local curServerTime = TimeUtil:GetServerTimeS()
    local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
    local lastTakeTime = afkData.iTakeRewardTime
    local fullTime = lastTakeTime + limitTimeSecNum
    local isFull = curServerTime >= fullTime
    self.m_bg_reward_100_pvp:SetActive(isFull)
    self.m_bg_reward_nml_pvp:SetActive(not isFull)
    if not isFull then
      local percentNum = math.floor((curServerTime - lastTakeTime) / limitTimeSecNum * 100)
      if percentNum < 0 then
        percentNum = 0
      end
      self.m_txt_rewardpercent_pvp_Text.text = percentNum .. "%"
    else
      self.m_txt_rewardpercent_pvp_Text.text = 100 .. "%"
    end
  else
    self.m_btn_reward_pvp:SetActive(false)
  end
end

function Form_HallActivityMain:RefreshEnterUI(index)
  local info = __pnl_enter_info[index]
  if not info then
    return
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(info.system_id)
  local sysCfg = self:GetSystemCfgByID(info.system_id)
  self[info.btn]:SetActive(isOpen and sysCfg.m_IsShow == 1)
  self[info.btn_lock]:SetActive(not isOpen or sysCfg.m_IsShow ~= 1)
  if sysCfg then
    local rewards = utils.changeCSArrayToLuaTable(sysCfg.m_Rewards)
    if isOpen then
      for i = 1, 2 do
        if rewards[i] then
          self[info.item .. i]:SetActive(true)
          ResourceUtil:CreatIconById(self[info.reward_icon .. i .. "_Image"], rewards[i])
          self[info.item .. i .. "_Button"].onClick:RemoveAllListeners()
          UILuaHelper.BindButtonClickManual(self, self[info.item .. i .. "_Button"], function()
            self:OnItemClk(rewards[i])
          end)
        else
          self[info.item .. i]:SetActive(false)
        end
      end
    else
      for i = 1, 2 do
        if rewards[i] then
          self[info.item_lock .. i]:SetActive(true)
          ResourceUtil:CreatIconById(self[info.lock_reward_icon .. i .. "_Image"], rewards[i])
          self[info.item_lock .. i .. "_Button"].onClick:RemoveAllListeners()
          UILuaHelper.BindButtonClickManual(self, self[info.item_lock .. i .. "_Button"], function()
            self:OnItemClk(rewards[i])
          end)
        else
          self[info.item_lock .. i]:SetActive(false)
        end
      end
    end
  end
end

function Form_HallActivityMain:ShowRedPoint(systemID, redPoint)
  local showFlag1 = 0 < redPoint
  if systemID == GlobalConfig.SYSTEM_ID.Dungeon then
    self.m_redpoint_boss:SetActive(showFlag1)
  elseif systemID == GlobalConfig.SYSTEM_ID.Tower then
    self.m_redpoint_tower:SetActive(showFlag1)
  elseif systemID == GlobalConfig.SYSTEM_ID.RogueStage then
    self.m_redpoint_roguestage:SetActive(showFlag1)
  elseif systemID == GlobalConfig.SYSTEM_ID.LegacyLevel then
    self.m_redpoint_legacy:SetActive(showFlag1)
  end
end

function Form_HallActivityMain:GetSystemCfgByID(system_id)
  local HallEventIns = ConfigManager:GetConfigInsByName("HallEvent")
  local activityInfoAll = HallEventIns:GetAll()
  for i, v in pairs(activityInfoAll) do
    if v.m_SystemID == system_id then
      return v
    end
  end
end

function Form_HallActivityMain:OnBtnranklistClicked()
  local time = self.iLastRqsTime or 0
  local cur_time = TimeUtil:GetServerTimeS()
  if 30 <= cur_time - time or GlobalRankManager:GetHaveNewTargetFlag() then
    GlobalRankManager:RqsRankGetList()
    self.iLastRqsTime = TimeUtil:GetServerTimeS()
  else
    StackFlow:Push(UIDefines.ID_FORM_RANKLISTMAIN)
  end
end

function Form_HallActivityMain:OnEventRankGetList()
  StackFlow:Push(UIDefines.ID_FORM_RANKLISTMAIN)
end

function Form_HallActivityMain:OnItemClk(itemId)
  if not itemId then
    return
  end
  utils.openItemDetailPop({iID = itemId})
end

function Form_HallActivityMain:GotoSystem(systemId, param)
  if systemId ~= GlobalConfig.SYSTEM_ID.Dungeon then
    local bossModule = ModuleManager:GetModuleByName("BossModule")
    if not bossModule then
      return
    end
    bossModule:ClearAllBossRes()
    bossModule:ForceRemoveBossPosNode()
  end
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(systemId)
  if isOpen then
    local cfg = ActivityManager:GetHallEventCfgBySystemId(systemId)
    if cfg.m_Jump then
      QuickOpenFuncUtil:OpenFunc(cfg.m_Jump, param)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function Form_HallActivityMain:OnBtntowerClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Tower)
  LocalDataManager:SetIntSimple("TowerEnterRed", TimeUtil:GetServerNextCommonResetTime())
end

function Form_HallActivityMain:OnBtntowerlockClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Tower)
end

function Form_HallActivityMain:OnBtnpvpClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Arena, {isNeedReqArena = true})
end

function Form_HallActivityMain:OnBtnpvplockClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Arena)
end

function Form_HallActivityMain:OnBtnlegacyClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.LegacyLevel)
end

function Form_HallActivityMain:OnBtnlegacylockClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.LegacyLevel)
end

function Form_HallActivityMain:OnBtnbossClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Dungeon)
end

function Form_HallActivityMain:OnBtnbosslockClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Dungeon)
end

function Form_HallActivityMain:OnBtnroguestageClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.RogueStage)
end

function Form_HallActivityMain:OnBtnroguestagelockClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.RogueStage)
end

function Form_HallActivityMain:OnBackHome()
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_HallActivityMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_HallActivityMain:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HallActivityMain", Form_HallActivityMain)
return Form_HallActivityMain
