local Form_PersonalRaidBoss = class("Form_PersonalRaidBoss", require("UI/UIFrames/Form_PersonalRaidBossUI"))
local PVP_NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")) or 0
local SOLO_RAID_DAY_END_HINT = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidDayEndHint"))
local SOLO_RAID_SEASON_END_HINT = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidSeasonEndHint"))

function Form_PersonalRaidBoss:SetInitParam(param)
end

function Form_PersonalRaidBoss:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1141)
end

function Form_PersonalRaidBoss:OnActive()
  self.super.OnActive(self)
  self.m_challengeTimes = 0
  self.m_challengeMaxTimes = 0
  self.m_activeBattleEndTime = 0
  self.m_levelId = PersonalRaidManager:GetCurRaidId()
  self.m_curStageCfg = PersonalRaidManager:GetSoloRaidLevelCfgById(self.m_levelId)
  if not self.m_curStageCfg then
    log.error("PersonalRaidBoss curStageCfg == nil" .. tostring(self.m_levelId))
    return
  end
  self.m_curRaidData = PersonalRaidManager:GetPersonalRaidData()
  self:RefreshUI()
  self:AddEventListeners()
  self.m_txt_rank_Text.text = ""
  PersonalRaidManager:ReqSoloRaidGetMyRankCS()
end

function Form_PersonalRaidBoss:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_downTimer2 then
    TimeService:KillTimer(self.m_downTimer2)
    self.m_downTimer2 = nil
  end
end

function Form_PersonalRaidBoss:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.OnUpDateRankBack))
  self:addEventListener("eGameEvent_SoloRaid_GetMyRank", handler(self, self.OnGetMyRank))
  self:addEventListener("eGameEvent_SoloRaid_Reset", handler(self, self.OnSoloRaidResetBack))
  self:addEventListener("eGameEvent_SoloRaid_DailyRefresh", handler(self, self.OnBackClk))
  self:addEventListener("eGameEvent_FinishExitBattle", handler(self, self.OnFinishExitBattle))
end

function Form_PersonalRaidBoss:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRaidBoss:RefreshUI()
  local cfg = PersonalRaidManager:GetSoloRaidBossCfgById(self.m_curStageCfg.m_BOSSID)
  if cfg then
    self.m_txt_rolename_Text.text = tostring(cfg.m_mName)
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_role_bg_Image, cfg.m_Background)
    self.m_txt_bossdes_Text.text = tostring(cfg.m_mDesc)
  end
  self.m_txt_levelnum_Text.text = self.m_curStageCfg.m_mName
  self.m_pnl_bg_normal:SetActive(self.m_curStageCfg.m_LevelMode ~= PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  self.m_pnl_bg_difficult:SetActive(self.m_curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  self.m_img_bg_difficult1:SetActive(self.m_curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  self.m_pnl_righttop:SetActive(self.m_curStageCfg.m_LevelMode ~= PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  self.m_pnl_bossheart:SetActive(self.m_curStageCfg.m_LevelMode ~= PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  local curHp, maxHp = PersonalRaidManager:GetBossHp()
  local hpPercent = string.format("%.2f", curHp / maxHp)
  self.m_img_slider_Image.fillAmount = hpPercent
  self.m_txt_sliderboss_Text.text = string.format(ConfigManager:GetCommonTextById(20048), curHp, maxHp)
  self.m_pnl_levellock:SetActive(self.m_curStageCfg.m_HeroModify ~= 0)
  if self.m_curStageCfg.m_HeroModify ~= 0 then
    local heroModifyCfg = LevelManager:GetHeroModifyCfg(self.m_curStageCfg.m_HeroModify) or {}
    self.m_txt_levellock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), heroModifyCfg.m_ForceLevel)
  end
  self.m_challengeTimes = PersonalRaidManager:GetCurStageBattleNum()
  self.m_challengeMaxTimes = PersonalRaidManager:GetOnceBattleTimes()
  self.m_txt_battlenum_Text.text = string.format(ConfigManager:GetCommonTextById(20048), self.m_challengeMaxTimes - self.m_challengeTimes, self.m_challengeMaxTimes)
  self:ShowActiveBattleTime()
  self:ShowActiveTime()
  self.m_btn_battle_gary:SetActive(self.m_challengeTimes >= self.m_challengeMaxTimes or 0 >= self.m_activeBattleEndTime)
  self.m_btn_battle:SetActive(self.m_challengeTimes < self.m_challengeMaxTimes and 0 < self.m_activeBattleEndTime)
  if self.m_challengeMaxTimes == self.m_challengeTimes then
    local tips = self.m_curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard and 1161 or 1160
    utils.popUpDirectionsUI({
      tipsID = tips,
      func1 = function()
        PersonalRaidManager:ReqSoloRaidResetCS(self.m_curStageCfg.m_LevelID)
      end
    })
  end
  self.m_pnl_damage:SetActive(self.m_curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  if self.m_curStageCfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard and self.m_curRaidData.stCurRaid then
    self.m_txt_damagepower_Text.text = tostring(self.m_curRaidData.stCurRaid.iDamage)
    self.m_pnl_damage:SetActive(self.m_curRaidData.stCurRaid.iDamage ~= 0)
  else
    self.m_txt_damagepower_Text.text = ""
  end
  self:RefreshFireUI()
end

function Form_PersonalRaidBoss:RefreshFireUI()
  local hideNum = self.m_challengeMaxTimes
  local haveNum = self.m_challengeMaxTimes - self.m_challengeTimes
  for i = 1, 5 do
    if i > hideNum then
      self["m_img_fire_dark0" .. i]:SetActive(false)
    else
      self["m_img_fire_dark0" .. i]:SetActive(true)
      self["m_fx_fire_out0" .. i]:SetActive(i <= haveNum)
      UILuaHelper.ResetAnimationByName(self["m_fx_fire_out0" .. i], "m_fx_fire_light_out")
    end
  end
end

function Form_PersonalRaidBoss:OnFinishExitBattle()
  local haveNum = self.m_challengeMaxTimes - self.m_challengeTimes
  local times = PersonalRaidManager:GetCurBattleTimes()
  local frontTime = haveNum + 1
  if times and times ~= self.m_challengeTimes and not utils.isNull(self["m_fx_fire_out0" .. frontTime]) then
    self:ClearTimer()
    self["m_fx_fire_out0" .. frontTime]:SetActive(true)
    self.m_AnimTimer = TimeService:SetTimer(0.5, 1, function()
      if not utils.isNull(self["m_fx_fire_out0" .. frontTime]) then
        UILuaHelper.PlayAnimationByName(self["m_fx_fire_out0" .. frontTime], "m_fx_fire_light_out")
      end
    end)
  end
end

function Form_PersonalRaidBoss:ClearTimer()
  if self.m_AnimTimer then
    TimeService:KillTimer(self.m_AnimTimer)
    self.m_AnimTimer = nil
  end
end

function Form_PersonalRaidBoss:ShowActiveBattleTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  if activity and activity.GetPersonalRaidBattleEndTime then
    local endTime = activity:GetPersonalRaidBattleEndTime()
    self.m_activeBattleEndTime = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_txt_rankleft_Text.text = TimeUtil:SecondsToFormatCNStr(self.m_activeBattleEndTime)
    self.m_pnl_timeleft:SetActive(self.m_activeBattleEndTime > 0)
    if self.m_downTimer then
      TimeService:KillTimer(self.m_downTimer)
      self.m_downTimer = nil
    end
    self.m_downTimer = TimeService:SetTimer(1, -1, function()
      self.m_activeBattleEndTime = self.m_activeBattleEndTime - 1
      if self.m_activeBattleEndTime < 0 then
        TimeService:KillTimer(self.m_downTimer)
        utils.popUpDirectionsUI({
          tipsID = 1147,
          func1 = function()
            if self.CloseForm then
              self:CloseForm()
              PersonalRaidManager:OpenPersonalRaidUI()
            end
          end
        })
        self.m_pnl_timeleft:SetActive(false)
      end
      self.m_txt_txt_rankleft_Text.text = TimeUtil:SecondsToFormatCNStr(self.m_activeBattleEndTime)
    end)
  else
    self.m_pnl_timeleft:SetActive(false)
  end
end

function Form_PersonalRaidBoss:ShowActiveTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  if activity and activity.GetPersonalRaidEndTime then
    local endTime = activity:GetPersonalRaidEndTime()
    self.m_activeEndTime = endTime - TimeUtil:GetServerTimeS()
    if self.m_downTimer2 then
      TimeService:KillTimer(self.m_downTimer2)
      self.m_downTimer2 = nil
    end
    self.m_downTimer2 = TimeService:SetTimer(self.m_activeEndTime, 1, function()
      TimeService:KillTimer(self.m_downTimer2)
      if self.CloseForm then
        self:CloseForm()
      end
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13004)
    end)
  end
end

function Form_PersonalRaidBoss:RefreshOwnerRankInfo(data)
  if not data.iMyRank or data.iMyRank == 0 or data.iMyRank == "0" then
    self.m_txt_rank_Text.text = ""
  else
    local str = PersonalRaidManager:GetRankNameByRankAndTotal(data.iMyRank, data.iRankSize)
    self.m_txt_rank_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20303), str)
  end
end

function Form_PersonalRaidBoss:OnGetMyRank(data)
  self:RefreshOwnerRankInfo(data)
end

function Form_PersonalRaidBoss:OnUpDateRankBack(rankType)
  if rankType == RankManager.RankType.PersonalRaid then
    StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDRANKLIST)
  end
end

function Form_PersonalRaidBoss:OnBtnrankClicked()
  RankManager:ReqArenaRankListCS(RankManager.RankType.PersonalRaid, 1, PVP_NEW_RANK_PAGE_CNT)
end

function Form_PersonalRaidBoss:OnBtnteamClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TEAM, {
    FormTypeBase = HeroManager.TeamTypeBase.SoloRaid
  })
end

function Form_PersonalRaidBoss:OnBtnrecordClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDBATTLEINFO, {
    stTargetId = {
      iZoneId = UserDataManager:GetZoneID(),
      iUid = RoleManager:GetUID()
    }
  })
end

function Form_PersonalRaidBoss:OnBtndetailClicked()
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curStageCfg.m_MapID,
    stageStr = self.m_curStageCfg.m_mName
  })
end

function Form_PersonalRaidBoss:OnBtnbattleClicked()
  local serverTime = TimeUtil:GetServerTimeS()
  local commonResetTime = TimeUtil:GetCommonResetTimeSecond()
  local time = LocalDataManager:GetIntSimple("SOLO_RAID_END", 0)
  if self.m_activeBattleEndTime < SOLO_RAID_SEASON_END_HINT and commonResetTime > time then
    LocalDataManager:GetIntSimple("SOLO_RAID_END", serverTime)
    utils.popUpDirectionsUI({
      tipsID = 1151,
      func1 = function()
        self:GotoBattle()
      end
    })
    return
  end
  local resetTime = TimeUtil:GetServerNextCommonResetTime() - serverTime
  if resetTime < SOLO_RAID_DAY_END_HINT and commonResetTime > time then
    utils.popUpDirectionsUI({
      tipsID = 1150,
      func1 = function()
        self:GotoBattle()
      end
    })
    return
  end
  self:GotoBattle()
end

function Form_PersonalRaidBoss:GotoBattle()
  PersonalRaidManager:SetCurBattleTimes(self.m_challengeTimes)
  PersonalRaidManager:EnterBattleBefore()
  BattleFlowManager:StartEnterBattle(PersonalRaidManager.FightType_SoloRaid, self.m_curStageCfg.m_LevelID)
end

function Form_PersonalRaidBoss:OnBtnsimulateClicked()
  PersonalRaidManager:SetCurBattleTimes(self.m_challengeTimes)
  PersonalRaidManager:EnterBattleBefore(true)
  BattleFlowManager:StartEnterBattle(PersonalRaidManager.FightType_SoloRaid, self.m_curStageCfg.m_LevelID)
end

function Form_PersonalRaidBoss:OnBtnbattlegaryClicked()
  if self.m_activeBattleEndTime <= 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13004)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13002)
  end
end

function Form_PersonalRaidBoss:OnBtngiveupClicked()
  utils.popUpDirectionsUI({
    tipsID = 1143,
    func1 = function()
      PersonalRaidManager:ReqSoloRaidResetCS(self.m_curStageCfg.m_LevelID)
    end
  })
  PersonalRaidManager:SetCurBattleTimes(self.m_challengeTimes)
end

function Form_PersonalRaidBoss:OnSoloRaidResetBack()
  self:OnBackClk()
  PersonalRaidManager:OpenPersonalRaidUI()
end

function Form_PersonalRaidBoss:OnBackClk()
  self:CloseForm()
  PersonalRaidManager:SetCurBattleTimes(self.m_challengeTimes)
  self:ClearTimer()
end

function Form_PersonalRaidBoss:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
  PersonalRaidManager:SetCurBattleTimes(self.m_challengeTimes)
  self:ClearTimer()
end

function Form_PersonalRaidBoss:OnDestroy()
  self.super.OnDestroy(self)
  self:ClearTimer()
end

function Form_PersonalRaidBoss:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra("LevelDetailSubPanel")
  if vPackageSub ~= nil then
    for i = 1, #vPackageSub do
      vPackage[#vPackage + 1] = vPackageSub[i]
    end
  end
  if vResourceExtraSub ~= nil then
    for i = 1, #vResourceExtraSub do
      vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
    end
  end
  return vPackage, vResourceExtra
end

function Form_PersonalRaidBoss:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidBoss", Form_PersonalRaidBoss)
return Form_PersonalRaidBoss
