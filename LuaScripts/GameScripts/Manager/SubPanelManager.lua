local BaseManager = require("Manager/Base/BaseManager")
local SubPanelManager = class("SubPanelManager", BaseManager)

function SubPanelManager:OnCreate()
end

function SubPanelManager:OnUpdate(dt)
end

SubPanelManager.SubPanelCfg = {
  HeroBaseSubPanel = {
    PrefabPath = "ui_hero_panel_base",
    LuaPath = "UI/SubPanel/HeroBaseSubPanel"
  },
  HeroSkillSubPanel = {
    PrefabPath = "ui_hero_panel_skill",
    LuaPath = "UI/SubPanel/HeroSkillSubPanel"
  },
  HeroEquipSubPanel = {
    PrefabPath = "ui_hero_panel_equipment",
    LuaPath = "UI/SubPanel/HeroEquipSubPanel"
  },
  HeroBaseInfoSubPanel = {
    PrefabPath = "ui_hero_panel_base_info",
    LuaPath = "UI/SubPanel/HeroBaseInfoSubPanel"
  },
  HeroLvUpgradeSubPanel = {
    PrefabPath = "ui_hero_panel_lv_upgrade",
    LuaPath = "UI/SubPanel/HeroLvUpgradeSubPanel"
  },
  HeroBreakSubPanel = {
    PrefabPath = "ui_hero_panel_breakthrough",
    LuaPath = "UI/SubPanel/HeroBreakSubPanel"
  },
  HeroLegacySubPanel = {
    PrefabPath = "ui_hero_panel_legacy",
    LuaPath = "UI/SubPanel/HeroLegacySubPanel"
  },
  HeroFashionSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/HeroFashion/HeroFashionSubPanel"
  },
  HeroFashionVoiceSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/HeroFashion/HeroFashionVoiceSubPanel"
  },
  LevelDetailSubPanel = {
    PrefabPath = "ui_level_panel_detail",
    LuaPath = "UI/SubPanel/LevelDetailSubPanel"
  },
  LevelDetailLamiaSubPanel = {
    PrefabPath = "ui_Activity101Lamia_DialogueDetial",
    LuaPath = "UI/SubPanel/LevelDetailLamiaSubPanel"
  },
  LevelDetailDalcaroSubPanel = {
    PrefabPath = "ui_activity102dalcaro_dialoguedetial",
    LuaPath = "UI/SubPanel/LevelDetailDalcaroSubPanel"
  },
  LevelDetailLuoleilaiSubPanel = {
    PrefabPath = "ui_activity103Luoleilai_dialoguedetial",
    LuaPath = "UI/SubPanel/LevelDetailLuoleilaiSubPanel"
  },
  LevelDetailLuoleilaiSubPanel2 = {
    PrefabPath = "ui_activity103Luoleilai_exdialoguedetial",
    LuaPath = "UI/SubPanel/LevelDetailLuoleilaiSubPanel"
  },
  LevelDetail104SubPanel = {
    PrefabPath = "ui_activity104_dialoguedetial",
    LuaPath = "UI/SubPanel/LevelDetailLuoleilaiSubPanel"
  },
  LegacyLevelDetailSubPanel = {
    PrefabPath = "ui_legacy_panel_detail",
    LuaPath = "UI/SubPanel/LegacyLevelDetailSubPanel"
  },
  RogueStageDetailSubPanel = {
    PrefabPath = "ui_roguestage_detail",
    LuaPath = "UI/SubPanel/RogueStageDetailSubPanel"
  },
  DailyTaskSubPanel = {
    PrefabPath = "ui_task_panel_day",
    LuaPath = "UI/SubPanel/DailyTaskSubPanel"
  },
  WeeklyTaskSubPanel = {
    PrefabPath = "ui_task_panel_day",
    LuaPath = "UI/SubPanel/WeeklyTaskSubPanel"
  },
  AchievementTaskSubPanel = {
    PrefabPath = "ui_task_panel_achievement",
    LuaPath = "UI/SubPanel/AchievementTaskSubPanel"
  },
  MainTaskSubPanel = {
    PrefabPath = "ui_task_panel_level",
    LuaPath = "UI/SubPanel/MainTaskSubPanel"
  },
  GachaSubPanel1 = {
    PrefabPath = "ui_gacha_panel_1",
    LuaPath = "UI/SubPanel/GachaSubPanel"
  },
  GachaSubPanel2 = {
    PrefabPath = "ui_gacha_panel_2",
    LuaPath = "UI/SubPanel/GachaSubPanel"
  },
  GachaSubPanel3 = {
    PrefabPath = "ui_gacha_panel_3",
    LuaPath = "UI/SubPanel/GachaSubPanel"
  },
  GachaSubPanel1001 = {
    PrefabPath = "ui_gacha_panel_1001",
    LuaPath = "UI/SubPanel/GachaSubPanel"
  },
  GachaSubPanel1002 = {
    PrefabPath = "ui_gacha_panel_1002",
    LuaPath = "UI/SubPanel/GachaSubPanel"
  },
  GachaSubPanel1003 = {
    PrefabPath = "ui_gacha_panel_1003",
    LuaPath = "UI/SubPanel/GachaSubPanels/LoreleyGachaSubPanel"
  },
  GachaSubPanel1004 = {
    PrefabPath = "ui_gacha_panel_1004",
    LuaPath = "UI/SubPanel/GachaSubPanels/BellaSummerGachaSubPanel"
  },
  GachaDalCaroPushFaceSubPanel = {
    PrefabPath = "ui_activity_dalcaroface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  GachaLamiaPushFaceSubPanel = {
    PrefabPath = "ui_activity_lamiaface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityBoqinaFaceSubPanel = {
    PrefabPath = "ui_activity_boqinaface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityPersonalRaidSubPanel = {
    PrefabPath = "ui_activity_personalraidface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityHuntNightSubPanel = {
    PrefabPath = "ui_activity_huntingnightface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityBellaFaceSubPanel = {
    PrefabPath = "ui_activity_bellaface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityLoreleiFaceSubPanel = {
    PrefabPath = "ui_activity_loreleiface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityPersonalRaid2FaceSubPanel = {
    PrefabPath = "ui_activity_personalraidface2",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  ActivityQigeLunaSubPanel = {
    PrefabPath = "ui_activity_qigelunaface",
    LuaPath = "UI/SubPanel/PushJumpFaceActivity"
  },
  GuildActiveSubPanel = {
    PrefabPath = "ui_guild_panel_event",
    LuaPath = "UI/SubPanel/GuildActiveSubPanel"
  },
  GuildMemberSubPanel = {
    PrefabPath = "ui_guild_panel_member",
    LuaPath = "UI/SubPanel/GuildMemberSubPanel"
  },
  GuildNewsSubPanel = {
    PrefabPath = "ui_guild_panel_news",
    LuaPath = "UI/SubPanel/GuildNewsSubPanel"
  },
  MallMonthlyCardMainSubPanel = {
    PrefabPath = "ui_mall_MonthlyCardMain",
    LuaPath = "UI/SubPanel/MallMonthlyCardMainSubPanel"
  },
  MallNewbieGiftSubPanel = {
    PrefabPath = "ui_activity_panel_NewbieGift",
    LuaPath = "UI/SubPanel/MallNewbieGiftSubPanel"
  },
  MallDailyPackSubPanel = {
    PrefabPath = "ui_activity_panel_dailypack",
    LuaPath = "UI/SubPanel/MallDailyPackSubPanel"
  },
  MallGoodsChapterSubPanel = {
    PrefabPath = "ui_mall_goodschapternew",
    LuaPath = "UI/SubPanel/MallGoodsChapterNewSubPanel"
  },
  PushGiftSubPanel = {
    PrefabPath = "ui_activity_panel_flashsale",
    LuaPath = "UI/SubPanel/MallPushGiftSubPanel"
  },
  RechargeSubPanel = {
    PrefabPath = "ui_panel_recharge",
    LuaPath = "UI/SubPanel/RechargeSubPanel"
  },
  PickupGiftSubPanel = {
    PrefabPath = "ui_activity_panel_pickup_new",
    LuaPath = "UI/SubPanel/PickupGiftSubPanel"
  },
  StepGiftSubPanel = {
    PrefabPath = "ui_activity_panel_stagegift",
    LuaPath = "UI/SubPanel/StepGiftSubPanel"
  },
  GameOpenGiftSubPanel = {
    PrefabPath = "ui_activity_panel_gameopengift",
    LuaPath = "UI/SubPanel/GameOpenGiftSubPanel"
  },
  LimitUpPackSubPanel = {
    PrefabPath = "ui_activity_panel_limitUppack",
    LuaPath = "UI/SubPanel/LimitUpPackSubPanel"
  },
  CommonUpPackSubPanel = {
    PrefabPath = "ui_activity_panel_actuppack",
    LuaPath = "UI/SubPanel/CommonUpPackSubPanel"
  },
  ChainGiftPackSubPanel = {
    PrefabPath = "ui_mall_ChainPack",
    LuaPath = "UI/SubPanel/ChainGiftPackSubPanel"
  },
  SignGiftFiveSunPanel = {
    PrefabPath = "ui_mall_sign5day",
    LuaPath = "UI/SubPanel/SignGiftFiveSunPanel"
  },
  FashionStoreSubPanel = {
    PrefabPath = "ui_activity_panel_skinshop",
    LuaPath = "UI/SubPanel/FashionStoreSubPanel"
  },
  ActivitySevenDaysSubPanel_ByMain = {
    PrefabPath = "ui_activity_panel_sevendays",
    LuaPath = "UI/SubPanel/ActivitySevenDaysSubPanel_ByMain"
  },
  ActivityFourteenSignSubPanel = {
    PrefabPath = "ui_activity_panel_fourteendays",
    LuaPath = "UI/SubPanel/ActivityFourteenSignSubPanel"
  },
  ActivitySignTenDaySubPanel = {
    PrefabPath = "ui_activity_panel_sign10day",
    LuaPath = "UI/SubPanel/ActivitySignTenDaySubPanel"
  },
  ActivityLoginSendItemSubPanel = {
    PrefabPath = "ui_activity_panel_loginSendItem",
    LuaPath = "UI/SubPanel/ActivityLoginSendItemSubPanel"
  },
  ActivitySignSixPuzzleSubPanel = {
    PrefabPath = "ui_activity_panel_puzzle",
    LuaPath = "UI/SubPanel/ActivitySignSixPuzzleSubPanel"
  },
  EmbraceBonusSubPanel = {
    PrefabPath = "ui_activity_embracebonus",
    LuaPath = "UI/SubPanel/EmbraceBonusSubPanel"
  },
  PvPEnterSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/PVPEnterSubPanel"
  },
  PvPReplaceSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/PVPReplaceSubPanel"
  },
  ActivityRebateSubPanel = {
    PrefabPath = "ui_activity_rebate",
    LuaPath = "UI/SubPanel/ActivityRebateSubPanel"
  },
  ActivityCommunityEntranceSubPanel = {
    PrefabPath = "ui_activity_socialmedia",
    LuaPath = "UI/SubPanel/ActivityCommunityEntranceSubPanel"
  },
  HallBgSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/HallBgSubPanel"
  },
  HallBattlePassSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/HallBattlePassSubPanel"
  },
  OnePicActivitySubPanel = {
    PrefabPath = "ui_activity_single_pic",
    LuaPath = "UI/SubPanel/OnePicActivitySubPanel"
  },
  LevelAwardActivitySubPanel = {
    PrefabPath = "ui_activity_panel_levelreward",
    LuaPath = "UI/SubPanel/LevelAwardActivitySubPanel"
  },
  LevelAwardActivitySubPanel2 = {
    PrefabPath = "ui_activity_panel_levelreward2",
    LuaPath = "UI/SubPanel/LevelAwardActivitySubPanel"
  },
  EmpousaActivitySubPanel = {
    PrefabPath = "ui_activity_empousa",
    LuaPath = "UI/SubPanel/EmpousaActivitySubPanel"
  },
  CliveActivitySubPanel = {
    PrefabPath = "ui_activity_clive",
    LuaPath = "UI/SubPanel/CliveActivitySubPanel"
  },
  FirstRechargeActivitySubPanel = {
    PrefabPath = "ui_activity_panel_firstrecharge",
    LuaPath = "UI/SubPanel/FirstRechargeActivitySubPanel"
  },
  RogueGridSubPanel = {
    PrefabPath = nil,
    LuaPath = "UI/SubPanel/RogueChoose/RogueGridSubPanel"
  },
  RogueTechTreeDetailSubPanel = {
    PrefabPath = "ui_rogue_talentwindow",
    LuaPath = "UI/SubPanel/RogueTechTreeDetailSubPanel"
  }
}

function SubPanelManager:LoadSubUIPrefab(prefabStr, subBack, failBack)
  if not prefabStr then
    return
  end
  UIManager:LoadUIPrefab(prefabStr, function(uiName, uiObject)
    if subBack then
      subBack(uiObject)
    end
  end, function(errorStr)
    log.info("ModuleManger LoadSubUIPrefab Load Fail errorStr: ", errorStr)
    if failBack then
      failBack(errorStr)
    end
  end)
end

function SubPanelManager:LoadSubPanel(subPanelName, parentObj, parentLua, initData, paramData, loadBack)
  if not subPanelName then
    return
  end
  local subPaneCfg = self.SubPanelCfg[subPanelName]
  if not subPaneCfg then
    return
  end
  self:LoadSubUIPrefab(subPaneCfg.PrefabPath, function(uiObject)
    local luaPath = subPaneCfg.LuaPath
    local subPanelLua = require(luaPath).new()
    subPanelLua:Init(parentObj, uiObject, parentLua, initData, paramData)
    if loadBack then
      loadBack(subPanelLua)
    end
  end)
end

function SubPanelManager:LoadSubPanelWithPanelRoot(subPanelName, panelRoot, parentLua, initData, paramData)
  if not subPanelName then
    return
  end
  local subPaneCfg = self.SubPanelCfg[subPanelName]
  if not subPaneCfg then
    return
  end
  local luaPath = subPaneCfg.LuaPath
  local subPanelLua = require(luaPath).new()
  subPanelLua:Init(nil, panelRoot, parentLua, initData, paramData)
  return subPanelLua
end

function SubPanelManager:GetSubPanelDownloadResourceExtra(subPanelName)
  if not subPanelName then
    return nil, nil
  end
  local subPaneCfg = self.SubPanelCfg[subPanelName]
  if not subPaneCfg then
    return nil, nil
  end
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = subPaneCfg.PrefabPath,
    eType = DownloadManager.ResourceType.UI
  }
  local luaPath = subPaneCfg.LuaPath
  local subPanelLua = require(luaPath).new()
  local vPackageSub, vResourceExtraSub = subPanelLua:GetDownloadResourceExtra(subPaneCfg)
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

return SubPanelManager
