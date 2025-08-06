local RedDotDefine = {}
RedDotDefine.ModuleType = {
  HeroEntry = "HeroEntry",
  HeroLevelUp = "HeroLevelUp",
  HeroBaseInfoTab = "HeroBaseInfoTab",
  HeroBreak = "HeroBreak",
  HeroEquipped = "HeroEquipped",
  HeroListItem = "HeroListItem",
  HeroSkillLevelUp = "HeroSkillLevelUp",
  HeroCirculationEntry = "HeroCirculationEntry",
  HeroCirculationUp = "HeroCirculationUp",
  HeroLegacyTab = "HeroLegacyTab",
  HeroLegacyWare = "HeroLegacyWare",
  LegacyUp = "LegacyUp",
  HeroFashion = "HeroFashion",
  HeroAttractEntry = "HeroAttractEntry",
  MailEntry = "MailEntry",
  CollectMailEntry = "CollectMailEntry",
  MailHaveRec = "MailHaveRec",
  MainItem = "MailItem",
  MainItemCanRec = "MainItemCanRec",
  TaskEntry = "TaskEntry",
  TaskDaily = "TaskDaily",
  TaskWeekly = "TaskWeekly",
  TaskChapterProgress = "TaskChapterProgress",
  TaskAchievement = "TaskAchievement",
  TaskMain = "TaskMain",
  LevelEntry = "LevelEntry",
  LevelSubTowerEntry = "LevelSubTowerEntry",
  HangUpEntry = "HangUpEntry",
  HangUpMain = "HangUpMain",
  HangUpBattle = "HangUpBattle",
  EquipmentChapterEntry = "EquipmentChapterEntry",
  EquipmentChapterBoss1 = "EquipmentChapterBoss1",
  EquipmentChapterBoss2 = "EquipmentChapterBoss2",
  EquipmentChapterBoss3 = "EquipmentChapterBoss3",
  BagEntry = "BagEntry",
  BagTab1 = "BagTab1",
  FreeShop = "FreeShop",
  HallActivityEntry = "HallActivityEntry",
  HeroActHallEntry = "HeroActHallEntry",
  HeroActSignEntry = "HeroActSignEntry",
  HeroActTaskEntry = "HeroActTaskEntry",
  HeroActSignItemCanRec = "HeroActSignItemCanRec",
  HeroActChallengeEntry = "HeroActChallengeEntry",
  HeroActActivityEntry = "HeroActActivityEntry",
  HeroActMemoryEntry = "HeroActMemoryEntry",
  HeroActMemoryCardCanRead = "HeroActMemoryCardCanRead",
  HeroActShopGoodsNew = "HeroActShopGoodsNew",
  HeroActShopEntry = "HeroActShopEntry",
  HeroActClueItemCanRec = "HeroActClueItemCanRec",
  HeroActMiniGameEntry = "HeroActMiniGameEntry",
  HeroActMiniGameTask = "HeroActMiniGameTask",
  HeroActMiniGamePuzzleEntry = "HeroActMiniGamePuzzleEntry",
  CastleStatueRewardEntry = "CastleStatueRewardEntry",
  CastleStatueReward = "CastleStatueReward",
  MainExploreEntry = "MainExploreEntry",
  MainExploreStoryEntry = "MainExploreStoryEntry",
  MainExploreStoryItem = "MainExploreStoryItem",
  HallMallMainEntry = "HallMallMainEntry",
  MallGoodsChapterTab = "MallGoodsChapterTab",
  MallMonthlyCardTab = "MallMonthlyCardTab",
  MallNewbieGiftPackTabl = "MallNewbieGiftPackTabl",
  MallNewStudentsSupplyPackTab = "MallNewStudentsSupplyPackTab",
  ActivityGiftPackTabl = "ActivityGiftPackTabl",
  MallPushGiftTab = "MallPushGiftTab",
  MallDailyPackTabl = "MallDailyPackTabl",
  MallFashionTab = "MallFashionTab",
  SettingEntry = "SettingEntry",
  SettingAccount = "SettingAccount",
  SettingCustomerService = "SettingCustomerService",
  LoginCustomerService = "LoginCustomerService",
  PayShopCustomerService = "PayShopCustomerService",
  PvpReplaceHangUpReward = "PvpReplaceHangUpReward",
  AnnouncementEntry = "AnnouncementEntry",
  AnnouncementTopTabActivity = "AnnouncementTopTabActivity",
  AnnouncementTopTabSystem = "AnnouncementTopTabSystem",
  AnnouncementTopTabConsult = "AnnouncementTopTabConsult",
  CastleEntry = "CastleEntry",
  StarPlatform = "StarPlatform",
  BattlePass = "BattlePass",
  DispatchEntry = "DispatchEntry",
  CastleEventEntry = "CastleEventEntry",
  CastlePlaceItem = "CastlePlaceItem",
  CastleCouncilEntry = "CastleCouncilEntry",
  GuildEntry = "GuildEntry",
  GlobalRankTab = "GlobalRankTab",
  GlobalRankEntry = "GlobalRankEntry",
  FriendEntry = "FriendEntry",
  FriendHaveHeart = "FriendHaveHeart",
  FriendHaveRqsAdd = "FriendHaveRqsAdd",
  LegacyLevelChapterEntry = "LegacyLevelChapterEntry",
  LegacyLevelChapterReward = "LegacyLevelChapterReward",
  LegacyGuideEntry = "LegacyGuideEntry",
  LegacyGuideNode = "LegacyGuideNode",
  PersonalCardEntry = "PersonalCardEntry",
  PersonalCardHeadTab = "PersonalCardHeadTab",
  PersonalCardHeadFrameTab = "PersonalCardHeadFrameTab",
  HallFunctionEntry = "HallFunctionEntry",
  HallDecorateEntry = "HallDecorateEntry",
  HallDecorateActTab = "HallDecorateActTab",
  HallDecorateFirstEnter = "HallDecorateFirstEnter",
  RogueAchievementEntry = "RogueAchievementEntry",
  RogueHandBookItemRedDot = "RogueHandBookItemRedDot",
  RogueHandBookTabRedDot = "RogueHandBookTabRedDot",
  RogueHandBookEntry = "RogueHandBookEntry",
  RogueRewardEntry = "RogueRewardEntry",
  RogueRewardBtnRedDot = "RogueRewardBtnRedDot",
  RogueTechEntry = "RogueTechEntry",
  RogueTechBtnRedDot = "RogueTechBtnRedDot",
  RogueDailyRedDot = "RogueDailyRedDot",
  RogueNewStage = "RogueNewStage",
  AttractBiographyEntry = "AttractBiographyEntry"
}
local ModuleType = RedDotDefine.ModuleType
RedDotDefine.ModuleDetail = {
  [ModuleType.CastleEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HeroEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HeroLevelUp] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroCanUpGrade"
  },
  [ModuleType.HeroBreak] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroCanBreakUp"
  },
  [ModuleType.HeroBaseInfoTab] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Hero_SetHeroFashionNewFlag",
      "eGameEvent_Hero_GetNewFashion"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroBaseInfoTabRedDot"
  },
  [ModuleType.HeroEquipped] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem"
    },
    isParamRedDot = true,
    managerName = "EquipManager",
    getCountFunName = "IsHeroCanEquipped"
  },
  [ModuleType.HeroSkillLevelUp] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroSkillCanUpGrade"
  },
  [ModuleType.HeroAttractEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_AttractRedCheck"
    },
    isParamRedDot = true,
    managerName = "AttractManager",
    getCountFunName = "CheckHeroRedDot"
  },
  [ModuleType.HeroListItem] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Equip_SetEquip",
      "eGameEvent_Hero_SetHeroFashionNewFlag",
      "eGameEvent_Hero_GetNewFashion"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroListItemHaveRedDot"
  },
  [ModuleType.HeroCirculationEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HeroCirculationUp] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_Inherit_Push",
      "eGameEvent_Inherit_Change",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Hero_CirculationUpgrade"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsCirculationIDHaveRedDot"
  },
  [ModuleType.HeroLegacyTab] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Legacy_Fresh"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroLegacyHaveRedDot"
  },
  [ModuleType.HeroLegacyWare] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Legacy_Fresh"
    },
    isParamRedDot = true,
    managerName = "LegacyManager",
    getCountFunName = "IsLegacyWareRedDot"
  },
  [ModuleType.LegacyUp] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_Item_SetItem",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Legacy_Fresh"
    },
    isParamRedDot = true,
    managerName = "LegacyManager",
    getCountFunName = "IsLegacyCanUpgrade"
  },
  [ModuleType.HeroFashion] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_SetHeroData",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Hero_SetHeroFashionNewFlag",
      "eGameEvent_Hero_GetNewFashion"
    },
    isParamRedDot = true,
    managerName = "HeroManager",
    getCountFunName = "IsHeroFashionHaveRedDot"
  },
  [ModuleType.MailEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.CollectMailEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MailHaveRec] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MainItem] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Email_ReadEmail",
      "eGameEvent_Email_DelEmail",
      "eGameEvent_Email_AttachEmail"
    },
    isParamRedDot = true,
    managerName = "EmailManager",
    getCountFunName = "IsEmailItemCanRecOrRead"
  },
  [ModuleType.MainItemCanRec] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Email_AttachEmail"
    },
    isParamRedDot = true,
    managerName = "EmailManager",
    getCountFunName = "IsEmailItemCanRec"
  },
  [ModuleType.TaskEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.TaskDaily] = {
    parent = ModuleType.TaskEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.TaskWeekly] = {
    parent = ModuleType.TaskEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.TaskAchievement] = {
    parent = ModuleType.TaskEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.TaskMain] = {
    parent = ModuleType.TaskEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.TaskChapterProgress] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Task_Change_State"
    },
    isParamRedDot = true,
    managerName = "LevelManager",
    getCountFunName = "IsLevelChapterTaskHaveRedDot"
  },
  [ModuleType.LevelEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_SetEnterTime",
      "eGameEvent_Level_DailyReset",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Level_ChangeState"
    },
    isParamRedDot = true,
    managerName = "BattleFlowManager",
    getCountFunName = "IsLevelEntryHaveRedDot"
  },
  [ModuleType.LevelSubTowerEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_SetEnterTime",
      "eGameEvent_Level_DailyReset",
      "eGameEvent_Level_ChangeState"
    },
    isParamRedDot = true,
    managerName = "LevelManager",
    getCountFunName = "IsLevelSubTowerHaveRedDot"
  },
  [ModuleType.HangUpEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HangUpMain] = {
    parent = ModuleType.HangUpEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HangUpBattle] = {
    parent = ModuleType.HangUpMain,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.EquipmentChapterEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.EquipmentChapterBoss1] = {
    parent = ModuleType.EquipmentChapterEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.EquipmentChapterBoss2] = {
    parent = ModuleType.EquipmentChapterEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.EquipmentChapterBoss3] = {
    parent = ModuleType.EquipmentChapterEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.BagEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.BagTab1] = {
    parent = ModuleType.BagEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.FreeShop] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RefreshShopItem",
      "eGameEvent_ShopBuy",
      "eGameEvent_RefreshShopData",
      "eGameEvent_ShopSoldOut"
    },
    isParamRedDot = true,
    managerName = "ShopManager",
    getCountFunName = "GetAllShopRedPointInfo"
  },
  [ModuleType.BattlePass] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Activity_BattlePass_RedRefresh"
    },
    isParamRedDot = true,
    managerName = "ActivityManager",
    getCountFunName = "OnCheckBattlePassRedInHall"
  },
  [ModuleType.HeroActSignEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_ActSign_GetReward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActSignEntryHaveRedDot"
  },
  [ModuleType.HeroActTaskEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActTask_GetReward",
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_ActTask_GetAllReward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActActTaskEntryHaveRedDot"
  },
  [ModuleType.HeroActChallengeEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_StageFresh",
      "eGameEvent_Level_Lamia_DailyReset"
    },
    isParamRedDot = true,
    managerName = "LevelHeroLamiaActivityManager",
    getCountFunName = "IsSubActLeftTimesEntryHaveRedDot"
  },
  [ModuleType.HeroActActivityEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_StageFresh",
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_Level_Lamia_SetSubActEnter"
    },
    isParamRedDot = true,
    managerName = "LevelHeroLamiaActivityManager",
    getCountFunName = "IsSubActEnterHaveRedDot"
  },
  [ModuleType.HeroActSignItemCanRec] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActSign_GetReward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActSignItemCanRec"
  },
  [ModuleType.HeroActShopGoodsNew] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_Level_Lamia_ShopGoodsClicked",
      "eGameEvent_RefreshShopData"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsShopGoodsHaveRedDot"
  },
  [ModuleType.HeroActShopEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_Level_Lamia_ShopGoodsClicked",
      "eGameEvent_RefreshShopData"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsActShopEntryHaveRedDot"
  },
  [ModuleType.HeroActHallEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActSign_GetReward",
      "eGameEvent_ActMemory_Readed",
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_Level_Lamia_StageFresh",
      "eGameEvent_Level_Lamia_SetSubActEnter"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "HeroActHallEntryHaveRedDot"
  },
  [ModuleType.HeroActMemoryEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_ActMinigame_Finish",
      "eGameEvent_Item_SetItem"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActMemoryEntryHaveRedDot"
  },
  [ModuleType.HeroActMemoryCardCanRead] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActMemory_Readed"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActMemoryCardCanRead"
  },
  [ModuleType.HeroActClueItemCanRec] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Act4ClueGetAward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActClueItemCanRec"
  },
  [ModuleType.HeroActMiniGameEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActTask_GetReward",
      "eGameEvent_ActMinigame_Finish"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActMiniGameEntryHaveRedDot"
  },
  [ModuleType.HeroActMiniGameTask] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActTask_GetReward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "CheckHaveFinishWhackMoleTask"
  },
  [ModuleType.HeroActMiniGamePuzzleEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_ActMinigame_Finish",
      "eGameEvent_ActMinigame_GetReward"
    },
    isParamRedDot = true,
    managerName = "HeroActivityManager",
    getCountFunName = "IsHeroActMiniGamePuzzleEntryHaveRedDot"
  },
  [ModuleType.CastleStatueRewardEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.CastleStatueReward] = {
    parent = ModuleType.CastleStatueRewardEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.DispatchEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.CastleEventEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.CastleCouncilEntry] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.CastlePlaceItem] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Item_SetItem",
      "eGameEvent_Castle_UnlockPlace"
    },
    isParamRedDot = true,
    managerName = "CastleStoryManager",
    getCountFunName = "IsPlaceCanUnlock"
  },
  [ModuleType.MainExploreEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MainExploreStoryEntry] = {
    parent = ModuleType.MainExploreEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MainExploreStoryItem] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_LostStory_GetReward"
    },
    isParamRedDot = true,
    managerName = "MainExploreManager",
    getCountFunName = "IsMainExploreStoryCanTakeReward"
  },
  [ModuleType.HallMallMainEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallGoodsChapterTab] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallPushGiftTab] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallFashionTab] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallNewStudentsSupplyPackTab] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallNewbieGiftPackTabl] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.ActivityGiftPackTabl] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallDailyPackTabl] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.MallMonthlyCardTab] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.SettingEntry] = {
    parent = ModuleType.HallFunctionEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.SettingAccount] = {
    parent = ModuleType.SettingEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.SettingCustomerService] = {
    parent = ModuleType.SettingAccount,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.LoginCustomerService] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.PayShopCustomerService] = {
    parent = ModuleType.HallMallMainEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.AnnouncementEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.AnnouncementTopTabActivity] = {
    parent = ModuleType.AnnouncementEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.AnnouncementTopTabSystem] = {
    parent = ModuleType.AnnouncementEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.AnnouncementTopTabConsult] = {
    parent = ModuleType.AnnouncementEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.StarPlatform] = {
    parent = ModuleType.CastleEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.PvpReplaceHangUpReward] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_ArenaReplaceAFKFresh",
      "eGameEvent_Level_ArenaReplaceAFKFull"
    },
    isParamRedDot = true,
    managerName = "PvpReplaceManager",
    getCountFunName = "IsHangUpHaveRedDot"
  },
  [ModuleType.HallActivityEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RankGetList",
      "eGameEvent_DrawTargetReward",
      "eGameEvent_RankGetRank",
      "eGameEvent_Level_SetEnterTime",
      "eGameEvent_Level_DailyReset",
      "eGameEvent_PopupUnlockSystem",
      "eGameEvent_Level_ChangeState",
      "eGameEvent_Legacy_Fresh",
      "eGameEvent_LegacyLevel_LevelWatchRecordFresh",
      "eGameEvent_RogueStage_TakeReward",
      "eGameEvent_RogueStage_ActiveTreeNode",
      "eGameEvent_RogueStage_RefreshDailyDot"
    },
    isParamRedDot = true,
    managerName = "ActivityManager",
    getCountFunName = "IsHallActivityEntryHaveRedDot"
  },
  [ModuleType.GuildEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_Lamia_DailyReset",
      "eGameEvent_Alliance_Sign",
      "eGameEvent_Alliance_Join",
      "eGameEvent_Alliance_Leave",
      "eGameEvent_Alliance_Destroy",
      "eGameEvent_Alliance_Create_Detail",
      "eGameEvent_Alliance_GetBossData",
      "eGameEvent_Alliance_UpdateBattleBoss",
      "eGameEvent_Ancient_TaskUpdate",
      "eGameEvent_Ancient_TakeQuestAward",
      "eGameEvent_Ancient_ChangeHero",
      "eGameEvent_Ancient_AddEnergy",
      "eGameEvent_Ancient_SummonHero",
      "eGameEvent_Alliance_GetApplyList_RedPoint"
    },
    isParamRedDot = true,
    managerName = "GuildManager",
    getCountFunName = "CheckGuildEntryHaveRedPoint"
  },
  [ModuleType.GlobalRankTab] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RankGetRank",
      "eGameEvent_DrawTargetReward"
    },
    isParamRedDot = true,
    managerName = "GlobalRankManager",
    getCountFunName = "IsGlobalRankTargetCanRec"
  },
  [ModuleType.GlobalRankEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.FriendEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.FriendHaveHeart] = {
    parent = ModuleType.FriendEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.FriendHaveRqsAdd] = {
    parent = ModuleType.FriendEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.LegacyLevelChapterEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_LegacyLevel_GetChapterReward",
      "eGameEvent_LegacyLevel_LegacyStagePush",
      "eGameEvent_LegacyLevel_LevelWatchRecordFresh"
    },
    isParamRedDot = true,
    managerName = "LegacyLevelManager",
    getCountFunName = "IsChapterEntryHaveRedDot"
  },
  [ModuleType.LegacyLevelChapterReward] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_LegacyLevel_GetChapterReward",
      "eGameEvent_LegacyLevel_LegacyStagePush"
    },
    isParamRedDot = true,
    managerName = "LegacyLevelManager",
    getCountFunName = "IsChapterHaveRewardRedDot"
  },
  [ModuleType.LegacyGuideEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Legacy_SetLegacyEnter",
      "eGameEvent_Legacy_Fresh"
    },
    isParamRedDot = true,
    managerName = "LegacyManager",
    getCountFunName = "IsAllLegacyEnterHaveRedDot"
  },
  [ModuleType.LegacyGuideNode] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Legacy_SetLegacyEnter",
      "eGameEvent_Legacy_Fresh"
    },
    isParamRedDot = true,
    managerName = "LegacyManager",
    getCountFunName = "IsLegacyEnterHaveRedDot"
  },
  [ModuleType.PersonalCardEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.PersonalCardHeadTab] = {
    parent = ModuleType.PersonalCardEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.PersonalCardHeadFrameTab] = {
    parent = ModuleType.PersonalCardEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HallFunctionEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HallDecorateEntry] = {
    parent = ModuleType.HallFunctionEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HallDecorateActTab] = {
    parent = ModuleType.HallDecorateEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.HallDecorateFirstEnter] = {
    parent = ModuleType.HallDecorateEntry,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.RogueAchievementEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.RogueHandBookItemRedDot] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RogueHandBookItem_StateChange"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsRogueHandBookItemHaveNew"
  },
  [ModuleType.RogueHandBookTabRedDot] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RogueHandBookItem_StateChange"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsRogueHandBookTabHaveNew"
  },
  [ModuleType.RogueHandBookEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.RogueRewardEntry] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.RogueRewardBtnRedDot] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RogueStage_TakeReward"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsHaveRogueRewardCanGet"
  },
  [ModuleType.RogueTechEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Item_SetItem",
      "eGameEvent_RogueStage_ActiveTreeNode"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsRogueTechCanUnlock"
  },
  [ModuleType.RogueTechBtnRedDot] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_RogueStage_ActiveTreeNode",
      "eGameEvent_Item_SetItem"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsRogueTechCanUnlock"
  },
  [ModuleType.RogueDailyRedDot] = {
    parent = nil,
    eventNameList = nil,
    isParamRedDot = false,
    managerName = nil,
    getCountFunName = nil
  },
  [ModuleType.RogueNewStage] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Level_SetEnterTime",
      "eGameEvent_RogueStage_RefreshDailyDot"
    },
    isParamRedDot = true,
    managerName = "RogueStageManager",
    getCountFunName = "IsRogueHaveNewStage"
  },
  [ModuleType.AttractBiographyEntry] = {
    parent = nil,
    eventNameList = {
      "eGameEvent_Hero_AttractRedCheck"
    },
    isParamRedDot = true,
    managerName = "AttractManager",
    getCountFunName = "IsAttractBiographyHaveRedDot"
  }
}
return RedDotDefine
