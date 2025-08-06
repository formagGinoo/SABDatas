local Form_HuntingNight = class("Form_HuntingNight", require("UI/UIFrames/Form_HuntingNightUI"))
local STAGE_NUM = 5
local SKILL_NUM = 2
local NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("HuntingRaidAwardRanklist")) or 0
local HuntingNight_in1 = "HuntingNight_in1"
local HuntingNight_in2 = "HuntingNight_in2"

function Form_HuntingNight:SetInitParam(param)
end

function Form_HuntingNight:AfterInit()
  self.super.AfterInit(self)
  self.m_showHeroIdList = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_activeBattleEndTime = 0
  self.m_activeEndTime = 0
end

function Form_HuntingNight:OnActive()
  self.super.OnActive(self)
  self.m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if not self.m_activity then
    log.error("get ActivityType_Hunting error !!!")
    return
  end
  self.m_iActivityId = self.m_activity:getID()
  self.m_curStageCfg = nil
  self.m_bossCfg = nil
  self.m_bossList = self.m_activity:GetHuntingRaidBossList()
  self.m_selStageIndex = self:GetStageOpenIndex()
  self:InitUI()
  if not self.m_bossList[self.m_selStageIndex] then
    log.error("get Hunting boss error !!!")
    return
  end
  self.m_selBossId = self.m_bossList[self.m_selStageIndex].iBossId
  self:StopTimer()
  self:RefreshUI()
  self:ShowActiveCutDownTime()
  self:AddEventListeners()
  self:RefreshMyRankUI()
  self:FreshShowSpine()
  HuntingRaidManager:SetDailyRedPointFlag()
end

function Form_HuntingNight:RefreshMyRankUI()
  if HuntingRaidManager:GetMyRankGroupId() ~= 0 then
    HuntingRaidManager:ReqHuntingGetMyRankCS(self.m_selBossId)
  end
  self:RefreshMyRank()
end

function Form_HuntingNight:GetStageOpenIndex()
  local bossId = HuntingRaidManager:GetEnterStageBossId()
  if bossId then
    for i = 1, STAGE_NUM do
      if self.m_bossList[i] and self.m_bossList[i].iBossId == bossId then
        local showTime = self.m_activity:CheckBossInShowAndChallengeTime(bossId)
        if showTime ~= 0 then
          return i
        end
      end
    end
  end
  for i = 1, STAGE_NUM do
    if self.m_bossList[i] then
      local showTime = self.m_activity:CheckBossInShowAndChallengeTime(self.m_bossList[i].iBossId)
      if showTime ~= 0 then
        return i
      end
    end
  end
  return 1
end

function Form_HuntingNight:OnInactive()
  self.super.OnInactive(self)
  self:StopTimer()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine()
end

function Form_HuntingNight:AddEventListeners()
  self:addEventListener("eGameEvent_Hunting_ChooseBuff", handler(self, self.RefreshSkillInfo))
  self:addEventListener("eGameEvent_HuntingRaid_GetMyRank", handler(self, self.RefreshMyRank))
  self:addEventListener("eGameEvent_HuntingRaid_GetTotalRank", handler(self, self.OnPullOpenUI))
  self:addEventListener("eGameEvent_Hunting_TakeBossReward", handler(self, self.OnTakeBossReward))
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnAnywayReload))
end

function Form_HuntingNight:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HuntingNight:OnAnywayReload()
  if self.m_iActivityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    if not self.m_stActivity then
      self:CloseForm()
    else
      self:RefreshUI()
    end
  end
end

function Form_HuntingNight:InitUI()
  UILuaHelper.SetActive(self.m_txt_rankmine, false)
  UILuaHelper.SetActive(self.m_z_txt_ranknone, true)
  local redFlag = HuntingRaidManager:CheckHaveReceiveAward()
  self.m_reward_reddot:SetActive(redFlag and 0 < redFlag)
  local redDot = HuntingRaidManager:CheckDailyRedPoint()
  local animName = 0 < redDot and HuntingNight_in1 or HuntingNight_in2
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, animName)
  local id = 0 < redDot and 281 or 282
  GlobalManagerIns:TriggerWwiseBGMState(id)
end

function Form_HuntingNight:OnTakeBossReward()
  local redFlag = HuntingRaidManager:CheckHaveReceiveAward()
  self.m_reward_reddot:SetActive(redFlag and 0 < redFlag)
end

function Form_HuntingNight:RefreshUI()
  self.m_selBossId = self.m_bossList[self.m_selStageIndex].iBossId
  self:RefreshLevelItem()
  self:RefreshStageUI()
  self:RefreshSkillInfo()
  self.m_txt_boss_information_Text.text = ConfigManager:GetCommonTextById(20330)
end

function Form_HuntingNight:RefreshMyRank()
  local rankData = HuntingRaidManager:GetHuntingMayRankByBossId(self.m_selBossId)
  if rankData and rankData.iMyRank ~= 0 then
    local iMyRank = rankData.iMyRank
    local iRankSize = rankData.iRankSize
    local rankStr = HuntingRaidManager:GetHuntingRaidRankStrAndPointsByRank(iMyRank, iRankSize)
    self.m_txt_rankmine_Text.text = rankStr
    UILuaHelper.SetActive(self.m_txt_rankmine, true)
    UILuaHelper.SetActive(self.m_z_txt_ranknone, false)
  else
    UILuaHelper.SetActive(self.m_txt_rankmine, false)
    UILuaHelper.SetActive(self.m_z_txt_ranknone, true)
  end
end

function Form_HuntingNight:RefreshSkillInfo()
  local chooseBuffList = HuntingRaidManager:GetBossBuffById(self.m_selBossId)
  for i = 1, SKILL_NUM do
    UILuaHelper.SetActive(self["m_img_iconskillbuff" .. i], chooseBuffList[i])
    if chooseBuffList[i] then
      local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(chooseBuffList[i])
      if effectCfg then
        UILuaHelper.SetAtlasSprite(self["m_img_iconskillbuff" .. i .. "_Image"], effectCfg.m_Icon)
      end
    end
  end
end

function Form_HuntingNight:RefreshLevelItem()
  for i = 1, STAGE_NUM do
    UILuaHelper.SetActive(self["m_level_item" .. i], self.m_bossList[i])
    if self.m_bossList[i] then
      local showTime = self.m_activity:CheckBossInShowAndChallengeTime(self.m_bossList[i].iBossId)
      UILuaHelper.SetActive(self["m_pnl_close" .. i], showTime == 0)
      UILuaHelper.SetActive(self["m_pnl_closesel" .. i], showTime == 0 and self.m_selStageIndex == i)
      UILuaHelper.SetActive(self["m_pnl_open" .. i], showTime ~= 0)
      UILuaHelper.SetActive(self["m_pnl_opensel" .. i], showTime ~= 0 and self.m_selStageIndex == i)
    end
  end
end

function Form_HuntingNight:RefreshStageUI()
  self.m_bossCfg = HuntingRaidManager:GetHuntingRaidBossCfgById(self.m_selBossId)
  if self.m_bossCfg then
    self.m_txt_chaptername_Text.text = tostring(self.m_bossCfg.m_mName)
    self.m_txt_des_Text.text = tostring(self.m_bossCfg.m_mDesc)
    self.m_txt_damagemax_Text.text = tostring(self.m_bossCfg.m_mTitle1)
    self.m_curStageCfg = HuntingRaidManager:GetHuntingRaidLevelCfgById(self.m_bossCfg.m_LevelID)
    local damage = HuntingRaidManager:GetBossRealDamageById(self.m_selBossId)
    self.m_txt_damage_Text.text = tostring(damage)
    UILuaHelper.SetActive(self.m_txt_damage, damage ~= "0")
    UILuaHelper.SetActive(self.m_z_txt_damage, damage == "0")
    if self.m_curStageCfg then
      local heroModify = self.m_curStageCfg.m_HeroModify
      self.m_pnl_levellock:SetActive(heroModify ~= 0)
      if heroModify ~= 0 then
        local heroModifyCfg = LevelManager:GetHeroModifyCfg(heroModify) or {}
        self.m_txt_levellock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), heroModifyCfg.m_ForceLevel)
      end
    end
    self.m_txt_boss_words_Text.text = self.m_bossCfg.m_mRequire
  end
  local inTime = self.m_activity:IsInActivityTime()
  UILuaHelper.SetActive(self.m_z_txt_end, not inTime)
  local showTime, challengeTime = self.m_activity:CheckBossInShowAndChallengeTime(self.m_selBossId)
  UILuaHelper.SetActive(self.m_txt_opentime, 0 < challengeTime and inTime)
  UILuaHelper.SetActive(self.m_txt_openday, showTime == 0 and inTime)
  UILuaHelper.SetActive(self.m_btn_battle, 0 < challengeTime and inTime)
  UILuaHelper.SetActive(self.m_btn_battle_gary, challengeTime <= 0 or not inTime)
  UILuaHelper.SetActive(self.m_z_txt_result, 0 < showTime and challengeTime <= 0)
  local timeStr = self.m_activity:getLangText(tostring(self.m_bossList[self.m_selStageIndex].sDate))
  self.m_txt_openday_Text.text = timeStr
  self.m_activeBattleEndTime = challengeTime
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if 0 < self.m_activeBattleEndTime then
    self.m_txt_opentime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(challengeTime)
    self.m_downTimer = TimeService:SetTimer(1, -1, function()
      self.m_activeBattleEndTime = self.m_activeBattleEndTime - 1
      if self.m_activeBattleEndTime < 0 then
        TimeService:KillTimer(self.m_downTimer)
        self.m_downTimer = nil
        self:RefreshStageUI()
      end
      self.m_txt_opentime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_activeBattleEndTime)
    end)
  end
end

function Form_HuntingNight:ShowActiveCutDownTime()
  local showTime, challengeTime = self.m_activity:GetHuntingRaidEndTime()
  local time = 0
  if 0 < challengeTime then
    time = challengeTime
    self.m_txt_seasonleft_Text.text = ConfigManager:GetCommonTextById(20331)
  elseif 0 < showTime then
    time = showTime
    self.m_txt_seasonleft_Text.text = ConfigManager:GetCommonTextById(20332)
  end
  if time == 0 then
    self.m_txt_seasonleft_Text.text = ConfigManager:GetCommonTextById(20332)
    self.m_txt_rankleft_Text = TimeUtil:SecondsToFormatStrDHOrHMS(0)
    return
  end
  self.m_activeEndTime = time
  self.m_txt_rankleft_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(time)
  if self.m_showDownTimer then
    TimeService:KillTimer(self.m_showDownTimer)
    self.m_showDownTimer = nil
  end
  if 0 < self.m_activeEndTime then
    self.m_showDownTimer = TimeService:SetTimer(1, -1, function()
      self.m_activeEndTime = self.m_activeEndTime - 1
      if self.m_activeEndTime < 0 then
        TimeService:KillTimer(self.m_showDownTimer)
        self.m_showDownTimer = nil
        self:ShowActiveCutDownTime()
      end
      self.m_txt_rankleft_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_activeEndTime)
    end)
  end
end

function Form_HuntingNight:StopTimer()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_showDownTimer then
    TimeService:KillTimer(self.m_showDownTimer)
    self.m_showDownTimer = nil
  end
end

function Form_HuntingNight:GetSpineHeroID()
  local list = HuntingRaidManager:GetShowHeroSpineId()
  for i, v in ipairs(list) do
    if v.iBossId == self.m_selBossId then
      return v.heroId
    end
  end
end

function Form_HuntingNight:GetShowSpine()
  local heroID = self:GetSpineHeroID()
  local heroCfg
  if not heroID then
    return
  end
  heroCfg = HeroManager:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  return spineStr
end

function Form_HuntingNight:FreshShowSpine()
  self:CheckRecycleSpine()
  local spineStr = self:GetShowSpine()
  if not spineStr then
    return
  end
  self:LoadHeroSpine(spineStr, SpinePlaceCfg.HuntingRaid, self.m_role_bg)
end

function Form_HuntingNight:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine(true)
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
      UILuaHelper.SetSpineTimeScale(spineLoadObj.spineObj, 1)
    end)
  end
end

function Form_HuntingNight:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HuntingNight:OnBtndetailClicked()
  if HuntingRaidManager:GetMyRankGroupId() ~= 0 then
    self.m_ShowBossRank = true
    HuntingRaidManager:ReqHuntingGetRankListCS(1, NEW_RANK_PAGE_CNT)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54003)
  end
end

function Form_HuntingNight:OnBtnteamClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TEAM, {
    FormTypeBase = HeroManager.TeamTypeBase.Default
  })
end

function Form_HuntingNight:OnBtnrewardClicked()
  StackPopup:Push(UIDefines.ID_FORM_HUNTINGNIGHTREWARD, {
    bossId = self.m_selBossId
  })
end

function Form_HuntingNight:OnPullOpenUI()
  local params
  if self.m_ShowBossRank then
    params = {
      bossId = self.m_selBossId
    }
  end
  StackPopup:Push(UIDefines.ID_FORM_HUNTINGNIGHTRANKLIST, params)
end

function Form_HuntingNight:OnBtnrankClicked()
  if HuntingRaidManager:GetMyRankGroupId() ~= 0 then
    self.m_ShowBossRank = nil
    HuntingRaidManager:ReqHuntingGetRankListCS(1, NEW_RANK_PAGE_CNT)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54003)
  end
end

function Form_HuntingNight:OnSkilltemplate1Clicked()
  StackFlow:Push(UIDefines.ID_FORM_HUNTINGNIGHTBUFFCHOOSE, {
    bossId = self.m_selBossId,
    idx = self.m_selStageIndex
  })
end

function Form_HuntingNight:OnSkilltemplate2Clicked()
  StackFlow:Push(UIDefines.ID_FORM_HUNTINGNIGHTBUFFCHOOSE, {
    bossId = self.m_selBossId,
    idx = self.m_selStageIndex
  })
end

function Form_HuntingNight:OnBtnbattleClicked()
  if self.m_curStageCfg then
    local chooseBuffList = HuntingRaidManager:GetBossBuffById(self.m_selBossId)
    if table.getn(chooseBuffList) < 2 then
      utils.popUpDirectionsUI({
        tipsID = 1208,
        func1 = function()
          HuntingRaidManager:SetEnterStageBossId(self.m_selBossId)
          BattleFlowManager:StartEnterBattle(HuntingRaidManager.FightType_Hunting, self.m_curStageCfg.m_LevelID, self.m_selBossId)
        end
      })
    else
      HuntingRaidManager:SetEnterStageBossId(self.m_selBossId)
      BattleFlowManager:StartEnterBattle(HuntingRaidManager.FightType_Hunting, self.m_curStageCfg.m_LevelID, self.m_selBossId)
    end
  end
end

function Form_HuntingNight:OnBtnbattlegaryClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54002)
end

function Form_HuntingNight:OnChooseLevel(index)
  self.m_selStageIndex = index
  self:RefreshUI()
  self:RefreshMyRankUI()
  self:FreshShowSpine()
end

function Form_HuntingNight:OnLevelitem1Clicked()
  if self.m_selStageIndex == 1 then
    return
  end
  self:OnChooseLevel(1)
end

function Form_HuntingNight:OnLevelitem2Clicked()
  if self.m_selStageIndex == 2 then
    return
  end
  self:OnChooseLevel(2)
end

function Form_HuntingNight:OnLevelitem3Clicked()
  if self.m_selStageIndex == 3 then
    return
  end
  self:OnChooseLevel(3)
end

function Form_HuntingNight:OnLevelitem4Clicked()
  if self.m_selStageIndex == 4 then
    return
  end
  self:OnChooseLevel(4)
end

function Form_HuntingNight:OnLevelitem5Clicked()
  if self.m_selStageIndex == 5 then
    return
  end
  self:OnChooseLevel(5)
end

function Form_HuntingNight:OnBtnbackClicked()
  self:CloseForm()
  HuntingRaidManager:SetEnterStageBossId(nil)
  self:GoBackFormHall()
  self:DestroyBigSystemUIImmediately()
end

function Form_HuntingNight:OnBtnhomeClicked()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
  HuntingRaidManager:SetEnterStageBossId(nil)
  self:DestroyBigSystemUIImmediately()
end

function Form_HuntingNight:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine()
end

function Form_HuntingNight:OnBtnsymbolClicked()
  utils.popUpDirectionsUI({tipsID = 1207})
end

function Form_HuntingNight:IsFullScreen()
  return true
end

function Form_HuntingNight:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  local list = HuntingRaidManager:GetShowHeroSpineId()
  for i, v in ipairs(list) do
    vPackage[#vPackage + 1] = {
      sName = tostring(v.heroId),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNight", Form_HuntingNight)
return Form_HuntingNight
