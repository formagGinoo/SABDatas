local M = {}
M.__MAX_SAFE_INT = 9007199254740991
M.__MAX_SAFE_INT_STR = "9007199254740991"
M.SYSTEM_ID = {
  Task = 1,
  MainLevel = 2,
  Form = 3,
  AFK = 4,
  Tower = 5,
  Equip = 6,
  Interception = 7,
  Mail = 8,
  RoleName = 9,
  Sign = 10,
  AutoBattle = 11,
  DoubleSpeedBattle = 12,
  Dungeon = 13,
  MainTask = 17,
  Bag = 18,
  LevelReset = 19,
  Activity = 20,
  Breakthrough = 22,
  SkillLevelUp = 23,
  Inherit = 24,
  Gacha = 25,
  Shop = 26,
  Guild = 27,
  Arena = 28,
  ChapterReward = 29,
  Circulation = 30,
  GuildSign = 31,
  GuildBattle = 32,
  Legacy = 33,
  Attract = 37,
  MainExplore = 38,
  Castle = 39,
  CastleStar = 40,
  Setting = 44,
  Notice = 45,
  ReplaceArena = 46,
  LegacyLevel = 47,
  SoloRaid = 48,
  GachaWishList = 50,
  CastleDispatch = 51,
  NightConversation = 52,
  DownloadTask = 54,
  Decorate = 56,
  GachaShow = 57,
  RogueStage = 58,
  RedemptionCode = 59,
  HuntingRaid = 60,
  AttractMail = 61,
  Ancient = 62,
  HeroFashion = 63,
  Character = 101,
  CharacterLevel = 102,
  CharacterHeat = 103,
  Goblin = 200,
  Goblin1 = 201,
  Goblin2 = 202,
  Goblin3 = 203,
  Goblin4 = 204,
  Goblin5 = 205,
  SimRoom = 300,
  SimRoomSweep = 306,
  GuideDefeatJump = 904,
  GachaFree = 905,
  ReName = 90001,
  PushGift = 90002,
  Mall = 90003
}
M.EQUIP_QUALITY_STYLE = {Default = 1, Line = 2}
M.RECHARGE_JUMP = 40006
local Color = CS.UnityEngine.Color
M.COMMON_COLOR = {
  Normal = {
    84,
    78,
    71
  },
  Normal2 = {
    237,
    215,
    193
  },
  Red = {
    178,
    69,
    43
  },
  Green = {
    54,
    142,
    114
  },
  Yellow = {
    166,
    95,
    48
  }
}
M.COMMON_COLOR2 = {
  Normal = Color(0.32941176470588235, 0.3058823529411765, 0.2784313725490196),
  Normal2 = Color(0.9294117647058824, 0.8431372549019608, 0.7568627450980392),
  Red = Color(0.6980392156862745, 0.27058823529411763, 0.16862745098039217),
  Green = Color(0.21176470588235294, 0.5568627450980392, 0.4470588235294118),
  Yellow = Color(0.6509803921568628, 0.37254901960784315, 0.18823529411764706)
}
M.QUALITY_EQUIP_SETTING = {
  {
    name = 1101,
    icon = "Atlas_Equipment/Quality_1",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg1",
    itemIcon = "Atlas_Item/Quality_equipment_01",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1102,
    icon = "Atlas_Equipment/Quality_2",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg2",
    itemIcon = "Atlas_Item/Quality_equipment_01",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1103,
    icon = "Atlas_Equipment/Quality_3",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg3",
    itemIcon = "Atlas_Item/Quality_equipment_01",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1104,
    icon = "Atlas_Equipment/Quality_4",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg4",
    itemIcon = "Atlas_Item/Quality_equipment_02",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1105,
    icon = "Atlas_Equipment/Quality_5",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg5",
    itemIcon = "Atlas_Item/Quality_equipment_03",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1106,
    icon = "Atlas_Equipment/Quality_6",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg6",
    itemIcon = "Atlas_Item/Quality_equipment_04",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1107,
    icon = "Atlas_Equipment/Quality_7",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg7",
    itemIcon = "Atlas_Item/Quality_equipment_05",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_CharacterQuality/common_icon_item_bg"
  },
  {
    name = 1108,
    icon = "Atlas_Equipment/Quality_8",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg8",
    itemIcon = "Atlas_Item/Quality_equipment_05",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_Equipment/Quality_8b"
  },
  {
    name = 1109,
    icon = "Atlas_Equipment/Quality_9",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg9",
    itemIcon = "Atlas_Item/Quality_equipment_06",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_Equipment/Quality_8b"
  },
  {
    name = 1110,
    icon = "Atlas_Equipment/Quality_10",
    icon2 = "Atlas_Equipment/bag_icon_tier_bg10",
    itemIcon = "Atlas_Item/Quality_equipment_07",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E",
    BgImage = "Atlas_Equipment/Quality_10b"
  }
}
M.QUALITY_EQUIP_ENUM = {
  T1 = 1,
  T2 = 2,
  T3 = 3,
  T4 = 4,
  T5 = 5,
  T6 = 6,
  T7 = 7,
  T8 = 8,
  T9 = 9,
  T10 = 10
}
M.QUALITY_COMMON_SETTING = {
  {
    name = 1001,
    icon = "Atlas_Item/common_icon_item_n",
    character_icon = "Atlas_CharacterQuality/common_img_r",
    tips_bg = "Atlas_CharacterQuality/ingamebattle_card_light_r",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E"
  },
  {
    name = 1002,
    icon = "Atlas_Item/common_icon_item_r",
    character_icon = "Atlas_CharacterQuality/common_img_r",
    tips_bg = "Atlas_CharacterQuality/ingamebattle_card_light_r",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E"
  },
  {
    name = 1003,
    icon = "Atlas_Item/common_icon_item_sr",
    character_icon = "Atlas_CharacterQuality/common_img_sr",
    tips_bg = "Atlas_CharacterQuality/ingamebattle_card_light_sr",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E"
  },
  {
    name = 1004,
    icon = "Atlas_Item/common_icon_item_ssr",
    character_icon = "Atlas_CharacterQuality/common_img_ssr",
    tips_bg = "Atlas_CharacterQuality/ingamebattle_card_light_ssr",
    item_effect = nil,
    RGBA = Color(0.22745098039215686, 0.2823529411764706, 0.3686274509803922),
    HC = "3A485E"
  }
}
M.QUALITY_SIM_ROOM_SETTING = {
  {name = 1001},
  {name = 1002},
  {name = 1003},
  {name = 1004},
  {name = 1005}
}
M.QUALITY_COMMON_ENUM = {
  Default = 1,
  R = 2,
  SR = 3,
  SSR = 4,
  UR = 5
}
M.ROLE_EXP_ITEM_ID = 1
M.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST = {
  40001,
  40002,
  40003,
  40004
}
M.LOGIN_SCENE_CAMERA_PARAMS = {
  position = {
    0,
    4,
    28.3
  },
  rotation = {
    -6,
    180,
    0
  },
  fov = 35,
  physical_camera = true,
  cullingMask = 3
}
M.REPORT_SYSTEM_ID_MAP = {
  [UIDefines.ID_FORM_TASK] = M.SYSTEM_ID.Task,
  [UIDefines.ID_FORM_LEVELMAIN] = M.SYSTEM_ID.MainLevel,
  [UIDefines.ID_FORM_TEAM] = M.SYSTEM_ID.Form,
  [UIDefines.ID_FORM_HANGUP] = M.SYSTEM_ID.AFK,
  [UIDefines.ID_FORM_TOWER] = M.SYSTEM_ID.Tower,
  [UIDefines.ID_FORM_EQUIPMENTCOPYMAIN] = M.SYSTEM_ID.Dungeon,
  [UIDefines.ID_FORM_BAGNEW] = M.SYSTEM_ID.Bag,
  [UIDefines.ID_FORM_POPUPLEVELRESET] = M.SYSTEM_ID.LevelReset,
  [UIDefines.ID_FORM_HEROLIST] = M.SYSTEM_ID.Character,
  [UIDefines.ID_FORM_PUSH_GIFT] = M.SYSTEM_ID.PushGift,
  [UIDefines.ID_FORM_GACHAMAIN] = M.SYSTEM_ID.Gacha,
  [UIDefines.ID_FORM_SHOP] = M.SYSTEM_ID.Shop,
  [UIDefines.ID_FORM_MALLMAINNEW] = M.SYSTEM_ID.Mall,
  [UIDefines.ID_FORM_PVPMAIN] = M.SYSTEM_ID.Arena,
  [UIDefines.ID_FORM_HEROHEAT] = M.SYSTEM_ID.CharacterHeat,
  [UIDefines.ID_FORM_CASTLEDISPATCHMAP] = M.SYSTEM_ID.CastleDispatch,
  [UIDefines.ID_FORM_EMAIL] = M.SYSTEM_ID.Mail,
  [UIDefines.ID_FORM_HEROBREAKTHROUGHPOP] = M.SYSTEM_ID.Breakthrough,
  [UIDefines.ID_FORM_HEROBREAKTHROUGHPOP] = M.SYSTEM_ID.SkillLevelUp,
  [UIDefines.ID_FORM_INHERIT] = M.SYSTEM_ID.Inherit,
  [UIDefines.ID_FORM_GUILD] = M.SYSTEM_ID.Guild,
  [UIDefines.ID_FORM_ATTRACTMAIN2] = M.SYSTEM_ID.Attract,
  [UIDefines.ID_FORM_BATTLESETTING] = M.SYSTEM_ID.Setting,
  [UIDefines.ID_FORM_ACTIVITYANNOUNCELOTTERYPAGE] = M.SYSTEM_ID.Notice,
  [UIDefines.ID_FORM_CASTLEEVENTMAIN] = M.SYSTEM_ID.NightConversation
}
M.SKILL_UPGRADE_PARAM_TYPE = {
  Fixed = 1,
  TenThousandPercent = 2,
  TenThousandPercent2 = 3
}
M.SKILL_UPGRADE_PARAM_NUMBER = {
  [M.SKILL_UPGRADE_PARAM_TYPE.Fixed] = 1,
  [M.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent] = 100,
  [M.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent2] = 10000
}
M.HERO_SKILL_COUNT = 4
M.HERO_BATTLE_STAR = 3
M.COLOR_GRADIENT_TOP = {
  {
    202,
    69,
    33
  },
  {
    233,
    210,
    147
  },
  {
    233,
    177,
    227
  }
}
M.COLOR_GRADIENT_BOTTOM = {
  {
    188,
    30,
    27
  },
  {
    218,
    175,
    83
  },
  {
    172,
    83,
    218
  }
}
M.COLOR_CAMP_BG = {
  [M.QUALITY_COMMON_ENUM.SR] = {
    151,
    127,
    77
  },
  [M.QUALITY_COMMON_ENUM.R] = {
    108,
    62,
    106
  },
  [M.QUALITY_COMMON_ENUM.SSR] = {
    112,
    34,
    34
  }
}
M.CommonQuestActType = {DayTask_7 = 0, DayTask_14 = 1}
M.RomaSymbols = {
  "Ⅰ",
  "Ⅱ",
  "Ⅲ",
  "Ⅳ",
  "Ⅴ",
  "Ⅵ",
  "Ⅶ",
  "Ⅷ",
  "Ⅸ",
  "Ⅹ"
}
return M
