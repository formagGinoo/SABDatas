local BaseManager = require("Manager/Base/BaseManager")
local ConfigManager = class("ConfigManager", BaseManager)

function ConfigManager:OnCreate()
  self.m_bCacheInstance = false
  self.m_vConfigInitStep = nil
  self.m_mConfigInstanceCache = nil
  self.m_updateQueueInitConfig = self:addComponent("UpdateQueue")
  self.m_FirstMustInitCfg = {
    {
      "UILanguage",
      "CommonText",
      "ShowMessage"
    },
    {
      "GlobalSettings",
      "UISfxes",
      "BGMStateGroup",
      "ConfirmCommonTips"
    }
  }
  self.m_CN_UnitWan = nil
  self.m_CN_UnitYi = nil
end

function ConfigManager:OnUpdate(dt)
end

function ConfigManager:CacheInstance()
  if self.m_bCacheInstance then
    return
  end
  self.m_vConfigInitStep = {
    {
      Head = CS.CData_Head.GetInstance(),
      UILanguage = CS.CData_UILanguage.GetInstance(),
      ShowMessage = CS.CData_ShowMessage.GetInstance(),
      PlotText = CS.CData_PlotText.GetInstance(),
      Item = CS.CData_Item.GetInstance(),
      Randompool = CS.CData_ItemRandompool.GetInstance(),
      MultiLanguagePic = CS.CData_MultiLanguagePic.GetInstance()
    },
    {
      CharacterInfo = CS.CData_CharacterInfo.GetInstance(),
      CharacterLevel = CS.CData_CharacterLevel.GetInstance(),
      CharacterLevelTemplate = CS.CData_CharacterLevelTemplate.GetInstance(),
      FashionInfo = CS.CData_FashionInfo.GetInstance(),
      FashionVoiceInfo = CS.CData_FashionVoiceInfo.GetInstance(),
      FashionVoiceText = CS.CData_FashionVoiceText.GetInstance(),
      FashionEffects = CS.CData_FashionEffects.GetInstance(),
      Skill = CS.CData_Skill.GetInstance(),
      SkillBuff = CS.CData_SkillBuff.GetInstance(),
      Presentation = CS.CData_Presentation.GetInstance(),
      CineInLoading = CS.CData_CineInLoading.GetInstance(),
      MainLevel = CS.CData_MainLevel.GetInstance(),
      MainChapter = CS.CData_MainChapter.GetInstance(),
      LevelMapConfig = CS.CData_LevelMapConfig.GetInstance(),
      TribeTowerLevel = CS.CData_TribeTowerLevel.GetInstance(),
      Tower = CS.CData_Tower.GetInstance(),
      GoblinLevel = CS.CData_GoblinLevel.GetInstance(),
      GoblinReward = CS.CData_GoblinReward.GetInstance(),
      CharacterCareer = CS.CData_CharacterCareer.GetInstance(),
      CharacterCamp = CS.CData_CharacterCamp.GetInstance(),
      CharacterLimitBreak = CS.CData_CharacterLimitBreak.GetInstance(),
      CharacterBattleStar = CS.CData_CharacterBattleStar.GetInstance(),
      CharacterLevelLock = CS.CData_CharacterLevelLock.GetInstance(),
      CharacterTrial = CS.CData_CharacterTrial.GetInstance(),
      CharacterTag = CS.CData_CharacterTag.GetInstance(),
      CharacterCampSub = CS.CData_CharacterCampSub.GetInstance(),
      CirculationType = CS.CData_CirculationType.GetInstance(),
      CirculationLevel = CS.CData_CirculationLevel.GetInstance(),
      Legacy = CS.CData_Legacy.GetInstance(),
      LegacyLevel = CS.CData_LegacyLevel.GetInstance(),
      LineUpRecommend = CS.CData_LineUpRecommend.GetInstance()
    },
    {
      LegacyStageLevelInfo = CS.CData_LegacyStageLevelInfo.GetInstance(),
      LegacyStageChapterInfo = CS.CData_LegacyStageChapterInfo.GetInstance(),
      LegacyStageCharacter = CS.CData_LegacyStageCharacter.GetInstance(),
      LegacyStageInteractive = CS.CData_LegacyStageInteractive.GetInstance(),
      LegacyStageMonster = CS.CData_LegacyStageMonster.GetInstance(),
      LegacyEnemyLine = CS.CData_LegacyEnemyLine.GetInstance(),
      LegacyGameSkill = CS.CData_LegacyGameSkill.GetInstance(),
      LegacyStageLevelTips = CS.CData_LegacyStageLevelTips.GetInstance(),
      ResourcesCheckSwitch = CS.CData_ResourcesCheckSwitch.GetInstance(),
      InteractiveGameDialog = CS.CData_InteractiveGameDialog.GetInstance()
    },
    {
      BattleMD5 = CS.CData_BattleMD5.GetInstance(),
      Monster = CS.CData_Monster.GetInstance(),
      ResultConditionType = CS.CData_ResultConditionType.GetInstance(),
      MonsterLevel = CS.CData_MonsterLevel.GetInstance(),
      SkillDamage = CS.CData_SkillDamage.GetInstance(),
      SkillGroup = CS.CData_SkillGroup.GetInstance(),
      MonsterMob = CS.CData_MonsterMob.GetInstance(),
      MonsterGroup = CS.CData_MonsterGroup.GetInstance(),
      StarParm = CS.CData_StarParm.GetInstance(),
      BattleRepress = CS.CData_BattleRepress.GetInstance(),
      MonsterTips = CS.CData_MonsterTips.GetInstance(),
      SkillTemplate = CS.CData_SkillTemplate.GetInstance(),
      SkillValue = CS.CData_SkillValue.GetInstance(),
      AttributeLimit = CS.CData_AttributeLimit.GetInstance(),
      PlayerHead = CS.CData_PlayerHead.GetInstance(),
      PlayerHeadFrame = CS.CData_PlayerHeadFrame.GetInstance(),
      PlayerBackground = CS.CData_PlayerBackground.GetInstance(),
      MonsterType = CS.CData_MonsterType.GetInstance(),
      MainBackground = CS.CData_MainBackground.GetInstance()
    },
    {
      UISfxes = CS.CData_UISfxes.GetInstance(),
      BattleWorld = CS.CData_BattleWorld.GetInstance(),
      BattleWorldConfig = CS.CData_BattleWorldConfig.GetInstance(),
      BattleGlobalEffect = CS.CData_BattleGlobalEffect.GetInstance(),
      BattleResultCondition = CS.CData_BattleResultCondition.GetInstance(),
      BattleResultIndex = CS.CData_BattleResultIndex.GetInstance(),
      IngamePresentationBase = CS.CData_PresentationBase.GetInstance(),
      GlobalSettings = CS.CData_GlobalSettings.GetInstance(),
      EditorExportSetting = CS.CData_EditorExportSetting.GetInstance(),
      CineVoiceExpression = CS.CData_CineVoiceExpression.GetInstance(),
      CineDialogueOption = CS.CData_CineDialogueOption.GetInstance(),
      CineRoleFace = CS.CData_CineRoleFace.GetInstance(),
      CineExpressionAnimation = CS.CData_CineExpressionAnimation.GetInstance(),
      ActionSoundEffects = CS.CData_ActionSoundEffects.GetInstance(),
      BGMStateGroup = CS.CData_BGMStateGroup.GetInstance(),
      Property = CS.CData_Property.GetInstance(),
      PropertyIndex = CS.CData_PropertyIndex.GetInstance(),
      BattleDefeatPrompt = CS.CData_BattleDefeatPrompt.GetInstance(),
      CommonText = CS.CData_CommonText.GetInstance(),
      GameScene = CS.CData_GameScene.GetInstance()
    },
    {
      AutoPVEBattle = CS.CData_AutoPVEBattle.GetInstance(),
      AutoBattleGroup = CS.CData_AutoBattleGroup.GetInstance(),
      StandardBattleValue = CS.CData_StandardBattleValue.GetInstance()
    },
    {
      InBattleBattleMode = CS.CData_BattleMode.GetInstance(),
      InBattleCineStep = CS.CData_BattleCineStep.GetInstance(),
      InBattleCineSubStep = CS.CData_BattleCineSubStep.GetInstance(),
      GuideStep = CS.CData_GuideStep.GetInstance(),
      GuideSubStep = CS.CData_GuideSubStep.GetInstance(),
      TutorialTips = CS.CData_TutorialTips.GetInstance(),
      HeroModify = CS.CData_HeroModify.GetInstance(),
      MLActionTask = CS.CData_MLActionTask.GetInstance(),
      PVPSeasonBuff = CS.CData_PVPSeasonBuff.GetInstance(),
      PlotPlay = CS.CData_PlotPlay.GetInstance(),
      PlotStep = CS.CData_PlotStep.GetInstance(),
      MailTemplate = CS.CData_MailTemplate.GetInstance(),
      ClientMessage = CS.CData_ClientMessage.GetInstance(),
      ConfirmCommonTips = CS.CData_ConfirmCommonTips.GetInstance(),
      AFKLevel = CS.CData_AFKLevel.GetInstance(),
      AFKInstantReward = CS.CData_AFKInstantReward.GetInstance(),
      Equipment = CS.CData_Equipment.GetInstance(),
      EquipLevel = CS.CData_EquipLevel.GetInstance(),
      EquipPos = CS.CData_EquipPos.GetInstance(),
      EquipType = CS.CData_EquipType.GetInstance(),
      EquipEffect = CS.CData_EquipEffect.GetInstance(),
      EquipEffectSlotLock = CS.CData_EquipEffectSlotLock.GetInstance(),
      EquipEffectGroup = CS.CData_EquipEffectGroup.GetInstance(),
      EquipEffectSlot = CS.CData_EquipEffectSlot.GetInstance(),
      MoonType = CS.CData_MoonType.GetInstance(),
      CharacterDamageType = CS.CData_CharacterDamageType.GetInstance(),
      SystemUnlock = CS.CData_SystemUnlock.GetInstance(),
      AccountLevel = CS.CData_AccountLevel.GetInstance(),
      Task = CS.CData_Task.GetInstance(),
      MainTaskReward = CS.CData_TaskMainReward.GetInstance(),
      DailyTaskReward = CS.CData_TaskDailyReward.GetInstance(),
      WeeklyTaskReward = CS.CData_TaskWeeklyReward.GetInstance(),
      TaskAchieve = CS.CData_TaskAchieve.GetInstance(),
      TaskAchieveReward = CS.CData_TaskAchieveReward.GetInstance(),
      Jump = CS.CData_Jump.GetInstance(),
      DunChapter = CS.CData_DungeonChapter.GetInstance(),
      DunLevel = CS.CData_DungeonLevel.GetInstance(),
      DungeonLevelPhase = CS.CData_DungeonLevelPhase.GetInstance(),
      GridEffect = CS.CData_GridEffect.GetInstance(),
      SpineRole = CS.CData_SpineRole.GetInstance(),
      HallEvent = CS.CData_Event.GetInstance(),
      Gacha = CS.CData_Gacha.GetInstance(),
      GachaDisplay = CS.CData_GachaDisplay.GetInstance(),
      GachaPool = CS.CData_GachaPool.GetInstance(),
      GachaTemplate = CS.CData_GachaTemplate.GetInstance(),
      GachaWishList = CS.CData_GachaWishList.GetInstance(),
      Shop = CS.CData_Shop.GetInstance(),
      ShopGoods = CS.CData_ShopGoods.GetInstance(),
      TaskResourceDownload = CS.CData_TaskResourceDownload.GetInstance(),
      PVPNewRank = CS.CData_PVPNewRank.GetInstance(),
      PVPNewChallengeCost = CS.CData_PVPNewChallengeCost.GetInstance(),
      SettingPush = CS.CData_SettingPush.GetInstance(),
      SettingGraphicsInfo = CS.CData_SettingGraphicsInfo.GetInstance(),
      SettingGraphicsChoice = CS.CData_SettingGraphicsChoice.GetInstance(),
      SettingLanguage = CS.CData_SettingLanguage.GetInstance(),
      AttractStory = CS.CData_AttractStory.GetInstance(),
      AttractRank = CS.CData_AttractRank.GetInstance(),
      AttractVoiceInfo = CS.CData_AttractVoiceInfo.GetInstance(),
      AttractVoiceText = CS.CData_AttractVoiceText.GetInstance(),
      AttractAdd = CS.CData_AttractAdd.GetInstance(),
      AttractTouch = CS.CData_AttractTouch.GetInstance(),
      AttractArchive = CS.CData_AttractArchive.GetInstance(),
      AttractLetter = CS.CData_AttractLetter.GetInstance(),
      AttractStudyRoleSize = CS.CData_AttractStudyRoleSize.GetInstance(),
      AttractTask = CS.CData_AttractTask.GetInstance(),
      ActivityMainInfo = CS.CData_ActivityMainInfo.GetInstance(),
      ActivitySubInfo = CS.CData_ActivitySubInfo.GetInstance(),
      ActSignin = CS.CData_ActSignin.GetInstance(),
      ActMemoryInfo = CS.CData_ActMemoryInfo.GetInstance(),
      ActMemoryText = CS.CData_ActMemoryText.GetInstance(),
      ActMemoryChoice = CS.CData_ActMemoryChoice.GetInstance(),
      ActLamiaBonusCha = CS.CData_ActLamiaBonusCha.GetInstance(),
      ActTask = CS.CData_ActTask.GetInstance(),
      ActTaskDailyReward = CS.CData_ActTaskDailyReward.GetInstance(),
      Act4Clue = CS.CData_Act4Clue.GetInstance(),
      SkillTip = CS.CData_SkillTip.GetInstance(),
      GMCommand = CS.CData_GMCommand.GetInstance(),
      GMShortcuts = CS.CData_GMShortcuts.GetInstance()
    },
    {
      CastleStatue = CS.CData_CastleStatue.GetInstance(),
      CastleStatueLevel = CS.CData_CastleStatueLevel.GetInstance(),
      Store = CS.CData_Store.GetInstance(),
      StoreBaseGoodsChapter = CS.CData_StoreBaseGoodsChapter.GetInstance(),
      StoreBaseGoodsChapterList = CS.CData_StoreBaseGoodsChapterList.GetInstance(),
      StoreBaseGoodsMonthly = CS.CData_StoreBaseGoodsMonthly.GetInstance(),
      CastlePlace = CS.CData_CastlePlace.GetInstance(),
      CastleStarInfo = CS.CData_CastleStarInfo.GetInstance(),
      CastleStarTech = CS.CData_CastleStarTech.GetInstance(),
      MainExplore = CS.CData_MainExplore.GetInstance(),
      MainLostStory = CS.CData_MainLostStory.GetInstance(),
      MainExploreReward = CS.CData_MainExploreReward.GetInstance(),
      CastleDispatchEvent = CS.CData_CastleDispatchEvent.GetInstance(),
      CastleDispatchLevel = CS.CData_CastleDispatchLevel.GetInstance(),
      CastleDispatchLocation = CS.CData_CastleDispatchLocation.GetInstance(),
      CastleStoryInfo = CS.CData_CastleStoryInfo.GetInstance(),
      CastleStoryPerform = CS.CData_CastleStoryPerform.GetInstance(),
      ActExploreInteractive = CS.CData_ActExploreInteractive.GetInstance()
    },
    {
      GuildLevel = CS.CData_GuildLevel.GetInstance(),
      GuildBadge = CS.CData_GuildBadge.GetInstance(),
      GuildEvent = CS.CData_GuildEvent.GetInstance(),
      GuildSign = CS.CData_GuildSign.GetInstance(),
      GuildBattle = CS.CData_GuildBattle.GetInstance(),
      GuildBattleBoss = CS.CData_GuildBattleBoss.GetInstance(),
      GuildBattleDifficulty = CS.CData_GuildBattleDifficulty.GetInstance(),
      GuildBattleGrade = CS.CData_GuildBattleGrade.GetInstance(),
      GuildBattleLevel = CS.CData_GuildBattleLevel.GetInstance(),
      GuildBattleReward = CS.CData_GuildBattleReward.GetInstance(),
      AncientCharacter = CS.CData_AncientCharacter.GetInstance(),
      AncientTask = CS.CData_AncientTask.GetInstance(),
      ActLamiaLevel = CS.CData_ActLamiaLevel.GetInstance(),
      ActLamiaBonusCha = CS.CData_ActLamiaBonusCha.GetInstance(),
      ActLamiaPowerCha = CS.CData_ActLamiaPowerCha.GetInstance(),
      HuntingRaidBoss = CS.CData_HuntingRaidBoss.GetInstance(),
      HuntingRaidLevel = CS.CData_HuntingRaidLevel.GetInstance(),
      HuntingRaidRank = CS.CData_HuntingRaidRank.GetInstance(),
      HuntingRaidReward = CS.CData_HuntingRaidReward.GetInstance(),
      HuntingRaidAchieve = CS.CData_HuntingRaidAchieve.GetInstance(),
      RogueStageItemInfo = CS.CData_RogueStageItemInfo.GetInstance(),
      RogueStageItemDrop = CS.CData_RogueStageItemDrop.GetInstance(),
      RogueStageDropInfo = CS.CData_RogueStageDropInfo.GetInstance(),
      RogueStageItemRandomGroup = CS.CData_RogueStageItemRandomGroup.GetInstance(),
      SkillBulletProperty = CS.CData_SkillBulletProperty.GetInstance(),
      RougeItemSubTypeInfo = CS.CData_RougeItemSubTypeInfo.GetInstance(),
      RogueStageItemCombination = CS.CData_RogueStageItemCombination.GetInstance(),
      RogueStageChapter = CS.CData_RogueStageChapter.GetInstance(),
      RogueStageRewardGroup = CS.CData_RogueStageRewardGroup.GetInstance(),
      RogueStageLevelTips = CS.CData_RogueStageLevelTips.GetInstance(),
      RogueTechTreeInfo = CS.CData_RogueTechTreeInfo.GetInstance(),
      RogueTaskAchieveReward = CS.CData_RogueTaskAchieveReward.GetInstance(),
      RogueStageReward = CS.CData_RogueStageReward.GetInstance(),
      RogueTaskAchieve = CS.CData_RogueTaskAchieve.GetInstance(),
      RogueItemIconPos = CS.CData_RogueItemIconPos.GetInstance(),
      ReplaceArenaRank = CS.CData_ReplaceArenaRank.GetInstance(),
      ReplaceArenaReward = CS.CData_ReplaceArenaReward.GetInstance(),
      SoloRaidBoss = CS.CData_SoloRaidBoss.GetInstance(),
      SoloRaidLevel = CS.CData_SoloRaidLevel.GetInstance(),
      SoloRaidReward = CS.CData_SoloRaidReward.GetInstance(),
      RankInfo = CS.CData_RankInfo.GetInstance(),
      RankCollectReward = CS.CData_RankCollectReward.GetInstance(),
      RankTargetReward = CS.CData_RankTargetReward.GetInstance(),
      CouncilHallIssue = CS.CData_CouncilHallIssue.GetInstance(),
      CouncilHallPosition = CS.CData_CouncilHallPosition.GetInstance(),
      CouncilHallText = CS.CData_CouncilHallText.GetInstance(),
      CouncilHallRoleSize = CS.CData_CouncilHallRoleSize.GetInstance(),
      InheritLevel = CS.CData_InheritLevel.GetInstance(),
      MiniGameA3WhackaMoleLevel = CS.CData_MiniGameA3WhackaMoleLevel.GetInstance(),
      MiniGameA3WhackaMoleEnemy = CS.CData_MiniGameA3WhackaMoleEnemy.GetInstance(),
      RegionMapping = CS.CData_RegionMapping.GetInstance(),
      CharacterViewMode = CS.CData_CharacterViewMode.GetInstance()
    }
  }
  self.m_mConfigInstanceCache = {}
  for _, stConfigInitStep in pairs(self.m_vConfigInitStep) do
    for sConfigInsName, stConfigIns in pairs(stConfigInitStep) do
      if stConfigIns then
        self.m_mConfigInstanceCache[sConfigInsName] = stConfigIns
      end
    end
  end
  self.m_bCacheInstance = true
end

function ConfigManager:InitFirstMustCfg(fProgressCB, fFinishCB)
  self:CacheInstance()
  self.m_updateQueueInitConfig:clear()
  for iStepIndex, firstMustInitCfg in pairs(self.m_FirstMustInitCfg) do
    self.m_updateQueueInitConfig:add(function()
      for _, cfgStr in pairs(firstMustInitCfg) do
        local cfgIns = self:GetConfigInsByName(cfgStr)
        if cfgIns then
          cfgIns:Init()
        end
      end
      if fProgressCB then
        fProgressCB(iStepIndex / #self.m_FirstMustInitCfg)
      end
      if iStepIndex == #self.m_FirstMustInitCfg and fFinishCB then
        fFinishCB()
      end
    end)
  end
end

function ConfigManager:InitConfig(fProgressCB, fFinishCB)
  self.m_updateQueueInitConfig:clear()
  self:CacheInstance()
  for iStepIndex, stConfigInitStep in pairs(self.m_vConfigInitStep) do
    self.m_updateQueueInitConfig:add(function()
      for sConfigName, stConfigIns in pairs(stConfigInitStep) do
        if stConfigIns then
          stConfigIns:Init()
        end
      end
      if fProgressCB then
        fProgressCB(iStepIndex / #self.m_vConfigInitStep)
      end
      if iStepIndex == #self.m_vConfigInitStep and fFinishCB then
        fFinishCB()
      end
    end)
  end
  self.InitConfigFinish = true
end

function ConfigManager:RefreshConfigMultiLan(fProgressCB, fFinishCB)
  self.m_updateQueueInitConfig:clear()
  self:CacheInstance()
  for iStepIndex, stConfigInitStep in pairs(self.m_vConfigInitStep) do
    self.m_updateQueueInitConfig:add(function()
      for sConfigName, stConfigIns in pairs(stConfigInitStep) do
        if stConfigIns then
          stConfigIns:ReloadMultiLan()
        end
      end
      if fProgressCB then
        fProgressCB(iStepIndex / #self.m_vConfigInitStep)
      end
      if iStepIndex == #self.m_vConfigInitStep and fFinishCB then
        fFinishCB()
      end
    end)
  end
end

function ConfigManager:GetConfigInsByName(configName)
  if not configName then
    return
  end
  return self.m_mConfigInstanceCache[configName]
end

function ConfigManager:GetCommonTextById(id)
  local text = "???"
  local CommonTextIns = self:GetConfigInsByName("CommonText")
  if CommonTextIns:GetCount() <= 0 then
    CommonTextIns:Init()
  end
  local showMessageCfg = CommonTextIns:GetValue_ById(id)
  if showMessageCfg and showMessageCfg.m_mMessage then
    text = showMessageCfg.m_mMessage
  end
  return text
end

function ConfigManager:GetConfirmCommonTipsById(id)
  local text = "???"
  local CommonTextIns = self:GetConfigInsByName("ConfirmCommonTips")
  if CommonTextIns:GetCount() <= 0 then
    CommonTextIns:Init()
  end
  local showMessageCfg = CommonTextIns:GetValue_ByID(id)
  if showMessageCfg and showMessageCfg:GetError() ~= true then
    text = showMessageCfg.m_mcontent
  end
  return text
end

function ConfigManager:GetClientMessageTextById(id)
  local text = "???"
  local ClientMessageIns = self:GetConfigInsByName("ClientMessage")
  local showMessageCfg = ClientMessageIns:GetValue_ByID(id)
  if showMessageCfg and showMessageCfg:GetError() ~= true then
    text = showMessageCfg.m_mContent
  end
  return text
end

function ConfigManager:GetGlobalSettingsByKey(key)
  local globalSettingsIns = self:GetConfigInsByName("GlobalSettings")
  local value
  local tempCfg = globalSettingsIns:GetValue_ByName(tostring(key))
  if tempCfg and tempCfg:GetError() ~= true then
    value = tempCfg.m_Value
  end
  return value
end

function ConfigManager:GetEditorExportSettingByKey(key)
  local editorExportSettingIns = self:GetConfigInsByName("EditorExportSetting")
  local value
  local tempCfg = editorExportSettingIns:GetValue_ByKeyName(tostring(key))
  if tempCfg:GetError() ~= true then
    value = tempCfg.m_ValueName
  end
  return value
end

function ConfigManager:GetCNUnit(num, unitType)
  if not self.m_CN_UnitWan then
    self.m_CN_UnitWan = self:GetCommonTextById(100603)
  end
  if not self.m_CN_UnitYi then
    self.m_CN_UnitYi = self:GetCommonTextById(100602)
  end
  local unit = unitType == 2 and self.m_CN_UnitYi or self.m_CN_UnitWan
  local str = string.gsubNumberReplace(unit, num)
  return str
end

function ConfigManager:GetBattleWorldCfgById(battleWorldId)
  local battleWorldCfg = self:GetConfigInsByName("BattleWorld"):GetValue_ByMapID(battleWorldId)
  return battleWorldCfg
end

function ConfigManager:BattleWorldMonsterGroupList(battleWorldCfg)
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  return battleWorldConfigCfg.m_MonsterGroupList
end

function ConfigManager:BattleWorldAreaIDList(battleWorldCfg)
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  return battleWorldConfigCfg.m_AreaIDList
end

function ConfigManager:BattleWorldMapName(battleWorldCfg)
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  return battleWorldConfigCfg.m_MapName
end

function ConfigManager:BattleWorldResultConditionType(battleWorldCfg)
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  return battleWorldConfigCfg.m_ResultConditionType
end

function ConfigManager:BattleWorldMaxRound(battleWorldCfg)
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  return battleWorldConfigCfg.m_MaxRound
end

function ConfigManager:BattleConditionStart(battleWorldCfg)
  local tempMaxId = 1
  local battleWorldConfigCfg = self:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(battleWorldCfg.m_ConfigID)
  if battleWorldConfigCfg:GetError() then
    log.error("BattleConditionStart Get BattleWorldConfigCfg Error, Wrong MapID: " .. battleWorldCfg.m_MapID)
    return
  end
  local battleResultConditonId = battleWorldConfigCfg.m_ResultCondition[0]
  local tempFilter = {}
  local tempFilterSet = {}
  if battleResultConditonId then
    local battleResultConditonCfg = self:GetConfigInsByName("BattleResultCondition"):GetValue_ByID(battleResultConditonId)
    local successDataList = utils.changeCSArrayToLuaTable(battleResultConditonCfg.m_ConditonSuccess)
    local failDataList = utils.changeCSArrayToLuaTable(battleResultConditonCfg.m_ConditionFail)
    for _, value in ipairs(failDataList) do
      if not tempFilter[value] then
        table.insert(tempFilter, value)
        tempFilterSet[value] = true
      end
    end
    for _, value in ipairs(successDataList) do
      if not tempFilter[value] then
        table.insert(tempFilter, value)
        tempFilterSet[value] = true
      end
    end
    for _, value in ipairs(tempFilter) do
      local conditionStart = self:GetConfigInsByName("BattleResultIndex"):GetValue_ByID(value)
      if tempMaxId < conditionStart.m_ConditionStart then
        tempMaxId = conditionStart.m_ConditionStart
      end
    end
  end
  return tempMaxId
end

function ConfigManager:_GetResourcesCheckSwitchValueByCache(sourceStr)
  if not sourceStr then
    return ""
  end
  if not self.m_resourcesCheckCache then
    self.m_resourcesCheckCache = {}
    local resourcesCheckSwitchIns = self:GetConfigInsByName("ResourcesCheckSwitch")
    local allValues = resourcesCheckSwitchIns:GetAll()
    for _, tempCfg in pairs(allValues) do
      if tempCfg and tempCfg:GetError() ~= true then
        self.m_resourcesCheckCache[tempCfg.m_OriginalResources] = {
          configData = tempCfg,
          CheckResources = tempCfg.m_CheckResources
        }
      end
    end
  end
  local tempSourceStr = ""
  if self.m_resourcesCheckCache[sourceStr] ~= nil then
    tempSourceStr = self.m_resourcesCheckCache[sourceStr].CheckResources or ""
  end
  return tempSourceStr
end

function ConfigManager:GetVerifyPathBySourceStr(sourceStr)
  if not sourceStr then
    return ""
  end
  if not ActivityManager then
    return ""
  end
  if ActivityManager:IsInCensorOpen() ~= true then
    return ""
  end
  return self:_GetResourcesCheckSwitchValueByCache(sourceStr)
end

return ConfigManager
