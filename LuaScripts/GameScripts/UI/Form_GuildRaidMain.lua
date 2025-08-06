local Form_GuildRaidMain = class("Form_GuildRaidMain", require("UI/UIFrames/Form_GuildRaidMainUI"))
local GuildBattleDataCD = ConfigManager:GetGlobalSettingsByKey("GuildBattleDataCD")
local PVP_NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")) or 0

function Form_GuildRaidMain:SetInitParam(param)
end

local selectBossAnim = "m_pnl_raidmain_right_in"

function Form_GuildRaidMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1115)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
  }
  self.m_BossListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_scrollView_InfinityGrid, "Guild/UIGuildBossItem")
  self.m_BossListInfinityGrid:RegisterButtonCallback("c_btn_item", handler(self, self.OnBossItemClk))
end

function Form_GuildRaidMain:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_guildBossData = {}
  self.m_guildBossInfoList = {}
  self.m_selItemIndex = self:GetBossIndexById(tParam.selBossID) or 1
  self.m_requestFlag = tParam.requestFlag
  self.m_curMonsterTypeTipsList = {}
  self.m_selReward = {}
  self.m_GuildBtnClick = false
  self.m_RoleBtnClick = false
  self.m_selBossHp = nil
  self.m_startBattle = false
  self:RefreshUI()
  if self.m_BossListInfinityGrid then
    self.m_BossListInfinityGrid:LocateTo(self.m_selItemIndex - 1)
  end
  self:RefreshBossItemSelectedState(self.m_selItemIndex)
  self:AddEventListeners()
  if self.m_requestFlag then
    local allianceId = RoleManager:GetRoleAllianceInfo()
    GuildManager:ReqGetOwnerAllianceDetailOnExitRaidMan(allianceId)
    GuildManager:ReqAllianceGetBattleBossData()
  end
  GlobalManagerIns:TriggerWwiseBGMState(13)
  GlobalManagerIns:TriggerWwiseBGMState(208)
end

function Form_GuildRaidMain:OnInactive()
  self.super.OnInactive(self)
  self.m_startBattle = false
  self.m_guildBossData = {}
  self.m_guildBossInfoList = {}
  self.m_selReward = {}
  if self.m_BossListInfinityGrid and self.m_selItemIndex then
    self.m_BossListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  end
  self.m_curMonsterTypeTipsList = {}
  self.m_selItemIndex = nil
  self.m_GuildBtnClick = false
  self.m_RoleBtnClick = false
  self.m_selBossHp = nil
  self:RemoveAllEventListeners()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_cutDownTime = nil
end

function Form_GuildRaidMain:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataGuildBossRankList", handler(self, self.OnUpDateRankBack))
  self:addEventListener("eGameEvent_Alliance_GetBossData", handler(self, self.OnRefreshUI))
  self:addEventListener("eGameEvent_GetGuildBossPersonalHistory", handler(self, self.OnBossPersonalHistoryCB))
  self:addEventListener("eGameEvent_PushAllianceBattleNewRound", handler(self, self.OnPushAllianceBattleNewRound))
  self:addEventListener("eGameEvent_GetAllianceBattleNewRound", handler(self, self.OnGetAllianceBattleNewRound))
  self:addEventListener("eGameEvent_Alliance_UpdateBattleBoss", handler(self, self.OnUpdateBattleBoss))
end

function Form_GuildRaidMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildRaidMain:CutDownTimeGuildBattleHistoryCD()
  if self.m_cutDownHistoryCD == nil then
    self.m_cutDownHistoryCD = TimeService:SetTimer(tonumber(GuildBattleDataCD or 0), 1, function()
      TimeService:KillTimer(self.m_cutDownHistoryCD)
      self.m_cutDownHistoryCD = nil
    end)
  end
end

function Form_GuildRaidMain:CutDownTimeGuildBattleRefreshCD()
  if self.m_cutDownRefreshCD == nil then
    self.m_cutDownRefreshCD = TimeService:SetTimer(tonumber(GuildBattleDataCD or 0), 1, function()
      TimeService:KillTimer(self.m_cutDownRefreshCD)
      self.m_cutDownRefreshCD = nil
    end)
  end
end

function Form_GuildRaidMain:RefreshUI()
  self.m_guildBossData = GuildManager:GetGuildBossData()
  self.m_guildBossInfoList = self:GenerateBossCfg()
  self.m_BossListInfinityGrid:ShowItemList(self.m_guildBossInfoList)
  self:RefreshRightUI()
  self.m_txt_timeleft_Text.text = ""
  self.m_txt_boss_round_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20072), self.m_guildBossData.iCurRound)
  self:RefreshTime()
end

function Form_GuildRaidMain:RefreshTime()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  local isOpen = GuildManager:CheckGuildBossIsOpen()
  if isOpen and activity and activity.GetGuildBossBattleEndTime then
    local actBattleEndTime = activity:GetGuildBossBattleEndTime()
    local serverTime = TimeUtil:GetServerTimeS()
    self.m_cutDownTime = actBattleEndTime - serverTime
    if self.m_cutDownTime > 0 then
      self.m_txt_timeleft_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_cutDownTime)
      if self.m_cutDownTime > 0 then
        self.m_downTimer = TimeService:SetTimer(1, -1, function()
          self.m_cutDownTime = self.m_cutDownTime - 1
          if self.m_cutDownTime <= 0 then
            self.m_txt_timeleft_Text.text = ConfigManager:GetCommonTextById(20083)
            return
          end
          self.m_txt_timeleft_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_cutDownTime)
        end)
      end
    else
      self.m_txt_timeleft_Text.text = ConfigManager:GetCommonTextById(20083)
    end
  else
    self.m_txt_timeleft_Text.text = ConfigManager:GetCommonTextById(20083)
  end
end

function Form_GuildRaidMain:RefreshRightUI()
  local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
  local isKill = false
  self.m_bg_tips:SetActive(false)
  if bossData then
    local bossCfg = bossData.bossCfg
    local levelCfg = bossData.levelCfg
    local serverData = bossData.serverData
    local maxHp = GuildManager:GetBossMaxHp(levelCfg.m_LevelID)
    ResourceUtil:CreateGuildBossIconByName(self.m_img_role_Image, bossCfg.m_BG)
    if serverData then
      self.m_img_roledeath:SetActive(serverData.bKill)
      self.m_btn_bossreward:SetActive(not serverData.bKill)
      self.m_btn_bossreward_receive:SetActive(serverData.bKill)
      self.m_img_slider_bosslive_Image.fillAmount = serverData.iBossHp / maxHp
      self.m_txt_heartbosslive_Text.text = string.format(ConfigManager:GetCommonTextById(20048), serverData.iBossHp, maxHp)
      isKill = serverData.bKill
      local lastRoleUid = serverData.stLastRole.iUid
      local uid = RoleManager:GetUID()
      if lastRoleUid ~= uid and TimeUtil:GetServerTimeS() - serverData.iLastTime < 120 then
        self.m_bg_tips:SetActive(true)
      end
    else
      self.m_img_roledeath:SetActive(false)
      self.m_btn_bossreward:SetActive(true)
      self.m_btn_bossreward_receive:SetActive(false)
      self.m_img_slider_bosslive_Image.fillAmount = 1
      self.m_txt_heartbosslive_Text.text = string.format(ConfigManager:GetCommonTextById(20048), maxHp, maxHp)
    end
    self.m_txt_levelbosslive_Text.text = levelCfg.m_BossLevel
    self.m_txt_namebosslive_Text.text = bossCfg.m_mName
    local monsterType = utils.changeCSArrayToLuaTable(bossCfg.m_MonsterTypeID)
    self.m_curMonsterTypeTipsList = {}
    for i = 1, 2 do
      local id = monsterType[i]
      local cfg = GuildManager:GetMonsterTypeCfgByID(id)
      self.m_curMonsterTypeTipsList[i] = cfg
      CS.UI.UILuaHelper.SetAtlasSprite(self["m_icon_leveltype" .. i .. "_Image"], cfg.m_Icon, nil, nil, true)
    end
    local reward = utils.changeCSArrayToLuaTable(levelCfg.m_ClientMustDrop)[1]
    if reward then
      ResourceUtil:CreatIconById(self.m_icon_bossreward_Image, reward[1])
      ResourceUtil:CreatIconById(self.m_icon_bossreward_receive_Image, reward[1])
      self.m_txt_bossrewardnum_Text.text = reward[2]
      self.m_txt_bossrewardnum_reveive_Text.text = reward[2]
      self.m_pnl_noreward:SetActive(false)
    else
      self.m_img_roledeath:SetActive(false)
      self.m_btn_bossreward:SetActive(false)
      self.m_pnl_noreward:SetActive(true)
      self.m_btn_bossreward:SetActive(false)
      self.m_btn_bossreward_receive:SetActive(false)
    end
    self.m_selReward = reward
    local heroModify = levelCfg.m_HeroModify
    if heroModify ~= 0 then
      local heroModifyCfg = LevelManager:GetHeroModifyCfg(heroModify) or {}
      if heroModifyCfg then
        self.m_txt_levellock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
        self.m_txt_levellocklock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
      end
    else
      self.m_txt_levellock_Text.text = ""
      self.m_txt_levellocklock_Text.text = ""
    end
    local effectId = levelCfg.m_BattleGlobalEffectID
    if effectId and effectId ~= 0 then
      UILuaHelper.SetActive(self.m_btn_leveltype3, true)
      local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(effectId)
      if effectCfg then
        UILuaHelper.SetAtlasSprite(self.m_icon_leveltype3_Image, effectCfg.m_Icon)
      end
    else
      UILuaHelper.SetActive(self.m_btn_leveltype3, false)
    end
  end
  local isOpen = GuildManager:CheckGuildBossIsOpen()
  local battleCount = GuildManager:GuildBossIsHaveRedDot()
  self.m_btn_start:SetActive(isOpen and 0 < battleCount and not isKill)
  self.m_btn_startlock:SetActive(battleCount <= 0 or isKill)
  self.m_img_roledeath:SetActive(isKill)
  local rank = GuildManager:GetMyBossRank()
  self.m_txt_rankingnum_Text.text = tostring(rank == 0 and "" or rank)
  self.m_btn_ranking_none:SetActive(rank == 0)
  self.m_btn_ranking:SetActive(rank ~= 0)
  self.m_txt_tips_Text.text = ConfigManager:GetCommonTextById(20074)
  local maxCount = GuildManager:GetGuildBossBattleCfgCount()
  self.m_txt_starnum_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100087), battleCount, maxCount)
  self.m_txt_starnumlock_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100087), battleCount, maxCount)
end

function Form_GuildRaidMain:GenerateBossCfg()
  local bossParamList = {}
  self.m_bossIds = GuildManager:GetGuildBossIds()
  if self.m_bossIds then
    for i, bossId in ipairs(self.m_bossIds) do
      local cfg = GuildManager:GetGuildBattleBossCfgByID(bossId)
      local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(bossId)
      local serverData = GuildManager:GetBossServerDataByID(bossId)
      local maxHp = GuildManager:GetBossMaxHp(levelCfg.m_LevelID)
      bossParamList[#bossParamList + 1] = {
        id = bossId,
        bossCfg = cfg,
        levelCfg = levelCfg,
        serverData = serverData,
        maxHp = maxHp
      }
    end
  end
  return bossParamList
end

function Form_GuildRaidMain:GetBossIndexById(bossId)
  if not bossId then
    return
  end
  self.m_bossIds = GuildManager:GetGuildBossIds()
  for i, v in ipairs(self.m_bossIds) do
    if v == bossId then
      return i
    end
  end
end

function Form_GuildRaidMain:OnBossItemClk(index, go, notRes)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  if self.m_selItemIndex == fjItemIndex then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, selectBossAnim)
  local chooseFJItemData = self.m_guildBossInfoList[fjItemIndex]
  self.m_BossListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  self.m_BossListInfinityGrid:OnChooseItem(fjItemIndex, true)
  self.m_selItemIndex = fjItemIndex
  if self.m_cutDownRefreshCD == nil and not notRes then
    self:CutDownTimeGuildBattleRefreshCD()
    GuildManager:ReqAllianceGetBattleBossData()
  elseif chooseFJItemData then
    self:RefreshRightUI()
  end
end

function Form_GuildRaidMain:RefreshBossItemSelectedState(fjItemIndex)
  local chooseFJItemData = self.m_guildBossInfoList[fjItemIndex]
  if chooseFJItemData then
    self.m_BossListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
    self.m_BossListInfinityGrid:OnChooseItem(fjItemIndex, true)
    self.m_selItemIndex = fjItemIndex
  end
end

function Form_GuildRaidMain:GoToBattle(simFlag)
  local isOpen = GuildManager:CheckGuildBossIsOpen()
  local battleCount = GuildManager:GuildBossIsHaveRedDot()
  if isOpen then
    local isSettlementTime = GuildManager:IsGuildBossSettlementTime()
    if isSettlementTime and not simFlag then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10408)
      return
    end
    if 0 < battleCount or simFlag then
      local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
      if bossData and bossData.levelCfg then
        GuildManager:GotoBattle(bossData.levelCfg.m_LevelID, simFlag)
      end
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10402)
    end
  else
    self:RefreshUI()
  end
end

function Form_GuildRaidMain:OnBtncheckrankClicked()
  local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
  if bossData and bossData.levelCfg then
    local levelCfg = bossData.levelCfg
    local bossCfg = bossData.bossCfg
    StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
      battleWorldID = levelCfg.m_MapID,
      stageStr = bossCfg.m_mName
    })
  end
end

function Form_GuildRaidMain:OnBtnleveltype1Clicked()
  if self.m_curMonsterTypeTipsList and self.m_curMonsterTypeTipsList[1] then
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDTIP, {
      cfg = self.m_curMonsterTypeTipsList[1],
      click_transform = self.m_btn_leveltype1.transform,
      rootTrans = self.m_rootTrans
    })
  end
end

function Form_GuildRaidMain:OnBtnleveltype2Clicked()
  if self.m_curMonsterTypeTipsList and self.m_curMonsterTypeTipsList[2] then
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDTIP, {
      cfg = self.m_curMonsterTypeTipsList[2],
      click_transform = self.m_btn_leveltype2.transform,
      rootTrans = self.m_rootTrans
    })
  end
end

function Form_GuildRaidMain:OnBtnleveltype3Clicked()
  local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
  if bossData then
    local levelCfg = bossData.levelCfg
    if levelCfg then
      local effectId = levelCfg.m_BattleGlobalEffectID
      StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDTIP, {
        effectId = effectId,
        click_transform = self.m_btn_leveltype3.transform,
        rootTrans = self.m_rootTrans
      })
    end
  end
end

function Form_GuildRaidMain:OnBtnstartClicked()
  if not self.m_startBattle then
    self.m_startBattle = true
    self.m_selBossHp = self:GetSelBossHp()
    GuildManager:ReqAllianceUpdateBattleBossData()
    GlobalManagerIns:TriggerWwiseBGMState(42)
  end
end

function Form_GuildRaidMain:GetSelBossHp()
  local hp = -1
  local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
  if bossData and bossData.serverData then
    hp = bossData.serverData.iBossHp
  end
  return hp
end

function Form_GuildRaidMain:OnUpdateBattleBoss()
  self.m_startBattle = false
  self.m_guildBossData = GuildManager:GetGuildBossData()
  self.m_guildBossInfoList = self:GenerateBossCfg()
  if self.m_selBossHp == self:GetSelBossHp() then
    self:GoToBattle()
  else
    self.m_BossListInfinityGrid:ShowItemList(self.m_guildBossInfoList)
    self:RefreshRightUI()
    self:RefreshBossItemSelectedState(self.m_selItemIndex)
    utils.popUpDirectionsUI({tipsID = 1510})
  end
end

function Form_GuildRaidMain:OnBtnstartlockClicked()
  local isOpen = GuildManager:CheckGuildBossIsOpen()
  if not isOpen then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10408)
  else
    local isSettlementTime = GuildManager:IsGuildBossSettlementTime()
    local bossData = self.m_guildBossInfoList[self.m_selItemIndex]
    if isSettlementTime then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10408)
    elseif bossData and bossData.serverData and bossData.serverData.bKill then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10401)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10402)
    end
  end
end

function Form_GuildRaidMain:OnBtnsimClicked()
  local flag = TimeUtil:GetServerTimeS() > LocalDataManager:GetIntSimple("GuildRaidMain_SimBattle", 0)
  if flag then
    LocalDataManager:SetIntSimple("GuildRaidMain_SimBattle", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
    utils.popUpDirectionsUI({
      tipsID = 1509,
      func1 = function()
        self:GoToBattle(true)
      end
    })
  else
    self:GoToBattle(true)
  end
  GlobalManagerIns:TriggerWwiseBGMState(42)
end

function Form_GuildRaidMain:OnBtnbossrewardClicked()
  if table.getn(self.m_selReward) > 0 then
    utils.openItemDetailPop({
      iID = self.m_selReward[1],
      iNum = self.m_selReward[2]
    })
  end
end

function Form_GuildRaidMain:OnBtnrankingClicked()
  GuildManager:ReqAllianceGetBattleBossRankList(self.m_guildBossData.iActivityId, 1, PVP_NEW_RANK_PAGE_CNT)
end

function Form_GuildRaidMain:OnBtnrankingnoneClicked()
  self:OnBtnrankingClicked()
end

function Form_GuildRaidMain:OnBtnguildlistClicked()
  if self.m_cutDownHistoryCD == nil then
    self:CutDownTimeGuildBattleHistoryCD()
    self.m_GuildBtnClick = true
    self.m_RoleBtnClick = false
    GuildManager:GetAllianceBattleBossHistory(self.m_guildBossData.iActivityId)
  else
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDCLANRECORD)
  end
end

function Form_GuildRaidMain:OnBtnrolelistClicked()
  if self.m_cutDownHistoryCD == nil then
    self:CutDownTimeGuildBattleHistoryCD()
    self.m_GuildBtnClick = false
    self.m_RoleBtnClick = true
    GuildManager:GetAllianceBattleBossHistory(self.m_guildBossData.iActivityId)
  else
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDMEMBERLIST)
  end
end

function Form_GuildRaidMain:OnUpDateRankBack()
  StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDRANKPOP)
end

function Form_GuildRaidMain:OnBossPersonalHistoryCB(isOver)
  if isOver then
    if self.m_RoleBtnClick then
      StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDMEMBERLIST)
    elseif self.m_GuildBtnClick then
      StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDCLANRECORD)
    end
  end
end

function Form_GuildRaidMain:PopNewRoundWnd()
  local newRound = self:SetNewRoundRecord()
  if newRound then
    local bossIds = GuildManager:GetGuildBossIds() or {}
    if table.getn(bossIds) > 0 then
      local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(bossIds[1])
      StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDBOSSROUNDTIPS, {
        level = levelCfg.m_BossLevel,
        activityId = self.m_guildBossData.iActivityId
      })
    end
  end
end

function Form_GuildRaidMain:OnPushAllianceBattleNewRound(activityId)
  GuildManager:ReqPushAllianceBattleNewRoundData(activityId)
end

function Form_GuildRaidMain:OnGetAllianceBattleNewRound()
  self.m_selItemIndex = 1
  self.m_GuildBtnClick = false
  self.m_RoleBtnClick = false
  self:RefreshUI()
  if self.m_BossListInfinityGrid then
    self.m_BossListInfinityGrid:LocateTo(0)
  end
  self:RefreshBossItemSelectedState(self.m_selItemIndex)
  self:PopNewRoundWnd()
  local bossIds = GuildManager:GetGuildBossIds() or {}
  local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(bossIds[1])
  StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDBOSSROUNDTIPS, {
    level = levelCfg.m_BossLevel,
    activityId = self.m_guildBossData.iActivityId
  })
end

function Form_GuildRaidMain:OnRefreshUI()
  local localRank = LocalDataManager:GetIntSimple("Form_GuildRaidMainRank" .. tostring(self.m_guildBossData.iActivityId), 9999)
  LocalDataManager:SetIntSimple("Form_GuildRaidMainRank" .. tostring(self.m_guildBossData.iActivityId), GuildManager:GetMyBossRank())
  if localRank > GuildManager:GetMyBossRank() and localRank ~= 9999 and GuildManager:GetMyBossRank() ~= 0 then
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDRANKCHANGETIPS, {
      oldLevel = localRank,
      newLevel = GuildManager:GetMyBossRank()
    })
  end
  self:RefreshUI()
  self:PopNewRoundWnd()
  self:RefreshBossItemSelectedState(self.m_selItemIndex)
end

function Form_GuildRaidMain:SetNewRoundRecord()
  local newFlag = false
  local round = LocalDataManager:GetIntSimple("FORM_GUILDRAIDBOSSROUNDTIPS" .. tostring(self.m_guildBossData.iActivityId), -1)
  if round < self.m_guildBossData.iCurRound then
    LocalDataManager:SetIntSimple("FORM_GUILDRAIDBOSSROUNDTIPS" .. tostring(self.m_guildBossData.iActivityId), self.m_guildBossData.iCurRound)
    if round ~= -1 then
      newFlag = true
    end
  end
  return newFlag
end

function Form_GuildRaidMain:IsFullScreen()
  return true
end

function Form_GuildRaidMain:OnBackClk()
  StackFlow:Push(UIDefines.ID_FORM_GUILD)
  self:CloseForm()
  self:DestroyBigSystemUIImmediately()
end

function Form_GuildRaidMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
  self:DestroyBigSystemUIImmediately()
end

function Form_GuildRaidMain:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidMain", Form_GuildRaidMain)
return Form_GuildRaidMain
