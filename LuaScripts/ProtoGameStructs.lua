local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
GenderType_NoSet = 0
GenderType_Male = 1
GenderType_Female = 2
GenderType_Other = 3
LoginType_Login = 0
LoginType_Reconnect = 1
LoginType_Zero = 2
ReportReasonType_Spamming = 1
ReportReasonType_Advertisment = 2
ReportReasonType_Abuse = 3
ReportReasonType_Sex = 4
ReportReasonType_Fake = 5
ReportReasonType_Other = 6
CmdSimpleDataType_OriginalPvpDefend = 1
CmdSimpleDataType_TopFiveHeroPower = 2
CmdSimpleDataType_ReplaceArenaDefence = 3
SystemType_DailyTask = 1
SystemType_MainLevel = 2
SystemType_Team = 3
SystemType_Afk = 4
SystemType_Tower = 5
SystemType_Equip = 6
SystemType_Mail = 8
SystemType_RoleName = 9
SystemType_Sign = 10
SystemType_AutoBattle = 11
SystemType_DoubleSpeedBattle = 12
SystemType_Dungeon = 13
SystemType_AutoForm = 15
SystemType_QuitBattle = 16
SystemType_MainTask = 17
SystemType_Bag = 18
SystemType_HeroReset = 19
SystemType_Activity = 20
SystemType_Test = 21
SystemType_HeroBreak = 22
SystemType_HeroSkillLevelUp = 23
SystemType_Inherit = 24
SystemType_Gacha = 25
SystemType_Shop = 26
SystemType_Alliance = 27
SystemType_OriginalArena = 28
SystemType_Circulation = 30
SystemType_AllianceSign = 31
SystemType_AllianceBattle = 32
SystemType_Legacy = 33
SystemType_BloodMoon = 36
SystemType_Attract = 37
SystemType_MainExplore = 38
SystemType_Castle = 39
SystemType_CastleStar = 40
SystemType_CastleStatue = 41
SystemType_CastleLab = 42
SystemType_CastleCollect = 43
SystemType_Settings = 44
SystemType_Notice = 45
SystemType_ReplaceArena = 46
SystemType_LegacyRaid = 47
SystemType_SoloRaid = 48
SystemType_GachaWish = 50
SystemType_CastleDispatch = 51
SystemType_Rogue = 58
SystemType_CDKey = 59
SystemType_Hunting = 60
SystemType_Hero = 101
SystemType_HeroLevel = 102
SystemType_Goblin = 200
SystemType_Goblin1 = 201
SystemType_Goblin2 = 202
SystemType_Goblin3 = 203
SystemType_Goblin4 = 204
SystemType_Goblin5 = 205
SystemType_FirstChapterUI1 = 901
SystemType_FirstChapterUI2 = 902
SystemType_AutoStar = 903
SystemUnlockCondition_Never = 0
SystemUnlockCondition_Open = 1
SystemUnlockCondition_RoleLevel = 2
SystemUnlockCondition_StageMain = 3
SystemUnlockCondition_Guide = 4
SystemUnlockCondition_Task = 5
SystemUnlockCondition_AllianceLevel = 6
SystemUnlockCondition_MainChapter = 7
SystemUnlockCondition_Attract = 20
SystemUnlockCondition_HasItemNum = 21
AttrType_Hero = 0
AttrType_HeroInit = 1
AttrType_HeroBase = 2
AttrType_Equip = 3
AttrType_Legacy = 4
AttrIndex_MaxHp = 1
AttrIndex_Attack = 2
AttrIndex_PhyDefence = 3
AttrIndex_MagDefence = 4
AttrIndex_AttackSpeed = 5
AttrIndex_Lv_MaxHp_Rate = 6
AttrIndex_Lv_Attack_Rate = 7
AttrIndex_Lv_PhyDefence_Rate = 8
AttrIndex_Lv_MagDefence_Rate = 9
AttrIndex_MaxHp_Rate = 10
AttrIndex_Attack_Rate = 11
AttrIndex_PhyDefence_Rate = 12
AttrIndex_MagDefence_Rate = 13
AttrIndex_Crit_Rate = 14
AttrIndex_AntiCrit_Rate = 15
AttrIndex_Crit_Ratio = 16
AttrIndex_AntiCrit_Ratio = 17
AttrIndex_AllPntrate_Rate = 18
AttrIndex_AntiAllPntrate_Rate = 19
AttrIndex_PhyPntrate_Rate = 20
AttrIndex_MagPntrate_Rate = 21
AttrIndex_AntiPhyPntrate_Rate = 22
AttrIndex_AntiMagPntrate_Rate = 23
AttrIndex_AllDmg_AddRate = 24
AttrIndex_AllDmg_ReduceRate = 25
AttrIndex_PhyDmg_AddRate = 26
AttrIndex_PhyDmg_ReduceRate = 27
AttrIndex_MagDmg_AddRate = 28
AttrIndex_MagDmg_ReduceRate = 29
AttrIndex_AllDmg_Add = 30
AttrIndex_AllDmg_Reduce = 31
AttrIndex_PhyDmg_Add = 32
AttrIndex_PhyDmg_Reduce = 33
AttrIndex_MagDmg_Add = 34
AttrIndex_MagDmg_Reduce = 35
AttrIndex_Cure_Rate = 36
AttrIndex_BearCure_Rate = 37
AttrIndex_CureCrit_Rate = 38
AttrIndex_BearCureCrit_Rate = 39
AttrIndex_CureCrit_Ratio = 40
AttrIndex_BearCureCrit_Ratio = 41
AttrIndex_Anger_Rate = 42
AttrIndex_HpRecover_Rate = 43
AttrIndex_Draw_Rate = 44
AttrIndex_ReboundDmg_Rate = 45
AttrIndex_RealDmg_Rate = 46
AttrIndex_AntiRealDmg_Rate = 47
AttrIndex_BonusDmg_Add = 48
AttrIndex_BonusDmg_Reduce = 49
AttrIndex_AllSpeed_Rate = 50
AttrIndex_Shield_Rate = 51
AttrIndex_MoveSpeed = 52
AttrIndex_InitialEnergy = 53
AttrIndex_Shield_AddRate = 54
AttrIndex_Shield_ReduceRate = 55
AttrIndex_Hit_AddRate = 56
AttrIndex_Dodge_AddRate = 57
AttrIndex_GetEnergySpeed = 58
AttrIndex_Hp = 100
AttrIndex_Anger = 101
AttrIndex_MaxAnger = 102
AttrIndex_MobInitialLifeTime = 103
AttrIndex_MobRemainLifeTime = 104
AttrIndex_AttackEnergyRate = 105
AttrIndex_DotDmg_ReduceRate = 106
AttrIndex_AttackDmg_Add = 107
AttrIndex_OgiDmg_Add = 108
AttrIndex_DebuffDmg_Add = 109
AttrIndex_CtrlDmg_Add = 110
AttrIndex_BuffTime_Add = 111
AttrIndex_DebuffTime_Add = 112
AttrIndex_AttackDmg_ReduceRate = 114
AttrIndex_SkillDmg_Add = 115
AttrIndex_SkillDmg_Reduce = 116
AttrIndex_OgiDmg_Reduce = 117
AttrIndex_DotDmg_Add = 118
AttrIndex_DebuffDmg_Reduce = 119
AttrIndex_CtrlDmg_Reduce = 120
AttrIndex_FinalDamage_Add = 121
AttrIndex_FinalDamage_Reduce = 122
FormHeroType_Normal = 1
FormHeroType_Necessary = 2
FormHeroType_Custom = 3
FormHeroType_Trial = 4
FormHeroType_Design = 5
CmdFormCampType_My = 1
CmdFormCampType_Enemy = 2
CmdFightBuffType_SimpleBuff = 0
CmdFightBuffType_GlobalEffect = 1
CmdRogueRecordType_Item = 1
CmdRogueRecordType_Monster = 2
FightSimpleParamType_PvPSeason = 1
CmdFightVerifyErrorType_Normal = 0
CmdFightVerifyErrorType_Fight = 1
CmdFightVerifyErrorType_OutRange = 2
CmdClientDataType_None = 0
CmdClientDataType_Unlock = 1
CmdClientDataType_Guide = 2
CmdClientDataType_MainEnter = 3
CmdClientDataType_Tower = 4
CmdClientDataType_Arena = 5
CmdClientDataType_Gacha = 6
CmdClientDataType_Statue = 7
CmdClientDataType_Explore = 8
CmdClientDataType_LamiaEnter = 9
CmdClientDataType_LegacyLevel = 10
CmdClientDataType_LegacyGuide = 11
CmdClientDataType_HallDecoration = 12
CmdClientDataType_TowerAuto = 13
CmdClientDataType_Max = 14
CmdClientDataSize_Alarm = 800
CmdClientDataSize_Invalid = 1024
SettingPushId_Afk = 1
SettingPushId_Mail = 2
SettingPushId_Elva = 3
SettingPushId_Normal = 4
PlayerIDType = sdp.SdpStruct("PlayerIDType")
PlayerIDType.Definition = {
  "iZoneId",
  "iUid",
  iZoneId = {
    0,
    1,
    8,
    0
  },
  iUid = {
    1,
    1,
    10,
    "0"
  }
}
CmdIDNum = sdp.SdpStruct("CmdIDNum")
CmdIDNum.Definition = {
  "iID",
  "iNum",
  iID = {
    0,
    0,
    8,
    0
  },
  iNum = {
    1,
    0,
    8,
    0
  }
}
CmdIDNumWeight = sdp.SdpStruct("CmdIDNumWeight")
CmdIDNumWeight.Definition = {
  "iID",
  "iNum",
  "iWeight",
  iID = {
    0,
    0,
    8,
    0
  },
  iNum = {
    1,
    0,
    8,
    0
  },
  iWeight = {
    2,
    0,
    8,
    0
  }
}
CmdHeroEquipData = sdp.SdpStruct("CmdHeroEquipData")
CmdHeroEquipData.Definition = {
  "iBaseId",
  "iParentBaseId",
  iBaseId = {
    0,
    0,
    8,
    0
  },
  iParentBaseId = {
    1,
    0,
    8,
    0
  }
}
CmdAttr = sdp.SdpStruct("CmdAttr")
CmdAttr.Definition = {
  "iMaxHp",
  "iAttack",
  "iPhyDefence",
  "iMagDefence",
  "iAttackSpeed",
  "iLv_MaxHp_Rate",
  "iLv_Attack_Rate",
  "iLv_PhyDefence_Rate",
  "iLv_MagDefence_Rate",
  "iCrit_Rate",
  "iAntiCrit_Rate",
  "iCrit_Ratio",
  "iAntiCrit_Ratio",
  "iAllPntrate_Rate",
  "iAntiAllPntrate_Rate",
  "iPhyPntrate_Rate",
  "iMagPntrate_Rate",
  "iAntiPhyPntrate_Rate",
  "iAntiMagPntrate_Rate",
  "iAllDmg_AddRate",
  "iAllDmg_ReduceRate",
  "iPhyDmg_AddRate",
  "iPhyDmg_ReduceRate",
  "iMagDmg_AddRate",
  "iMagDmg_ReduceRate",
  "iCure_Rate",
  "iBearCure_Rate",
  "iCureCrit_Rate",
  "iBearCureCrit_Rate",
  "iCureCrit_Ratio",
  "iBearCureCrit_Ratio",
  "iAnger_Rate",
  "iHpRecover_Rate",
  "iDraw_Rate",
  "iBonusDmg_Add",
  "iBonusDmg_Reduce",
  "iShield_Rate",
  "iMoveSpeed",
  "iInitialEnergy",
  "iGetEnergySpeed",
  "iHp",
  "iAnger",
  "iMaxAnger",
  "iMobInitialLifeTime",
  "iMobRemainLifeTime",
  "iAttackEnergyRate",
  "iDotDmg_ReduceRate",
  "iAttackDmg_Add",
  "iOgiDmg_Add",
  "iDebuffDmg_Add",
  "iCtrlDmg_Add",
  "iBuffTime_Add",
  "iDebuffTime_Add",
  "iAttackDmg_ReduceRate",
  "iSkillDmg_Add",
  "iSkillDmg_Reduce",
  "iOgiDmg_Reduce",
  "iDotDmg_Add",
  "iDebuffDmg_Reduce",
  "iCtrlDmg_Reduce",
  "iFinalDamage_Add",
  "iFinalDamage_Reduce",
  iMaxHp = {
    0,
    0,
    8,
    0
  },
  iAttack = {
    1,
    0,
    8,
    0
  },
  iPhyDefence = {
    2,
    0,
    8,
    0
  },
  iMagDefence = {
    3,
    0,
    8,
    0
  },
  iAttackSpeed = {
    4,
    0,
    8,
    0
  },
  iLv_MaxHp_Rate = {
    5,
    0,
    8,
    0
  },
  iLv_Attack_Rate = {
    6,
    0,
    8,
    0
  },
  iLv_PhyDefence_Rate = {
    7,
    0,
    8,
    0
  },
  iLv_MagDefence_Rate = {
    8,
    0,
    8,
    0
  },
  iCrit_Rate = {
    13,
    0,
    8,
    0
  },
  iAntiCrit_Rate = {
    14,
    0,
    8,
    0
  },
  iCrit_Ratio = {
    15,
    0,
    8,
    0
  },
  iAntiCrit_Ratio = {
    16,
    0,
    8,
    0
  },
  iAllPntrate_Rate = {
    17,
    0,
    8,
    0
  },
  iAntiAllPntrate_Rate = {
    18,
    0,
    8,
    0
  },
  iPhyPntrate_Rate = {
    19,
    0,
    8,
    0
  },
  iMagPntrate_Rate = {
    20,
    0,
    8,
    0
  },
  iAntiPhyPntrate_Rate = {
    21,
    0,
    8,
    0
  },
  iAntiMagPntrate_Rate = {
    22,
    0,
    8,
    0
  },
  iAllDmg_AddRate = {
    23,
    0,
    8,
    0
  },
  iAllDmg_ReduceRate = {
    24,
    0,
    8,
    0
  },
  iPhyDmg_AddRate = {
    25,
    0,
    8,
    0
  },
  iPhyDmg_ReduceRate = {
    26,
    0,
    8,
    0
  },
  iMagDmg_AddRate = {
    27,
    0,
    8,
    0
  },
  iMagDmg_ReduceRate = {
    28,
    0,
    8,
    0
  },
  iCure_Rate = {
    35,
    0,
    8,
    0
  },
  iBearCure_Rate = {
    36,
    0,
    8,
    0
  },
  iCureCrit_Rate = {
    37,
    0,
    8,
    0
  },
  iBearCureCrit_Rate = {
    38,
    0,
    8,
    0
  },
  iCureCrit_Ratio = {
    39,
    0,
    8,
    0
  },
  iBearCureCrit_Ratio = {
    40,
    0,
    8,
    0
  },
  iAnger_Rate = {
    41,
    0,
    8,
    0
  },
  iHpRecover_Rate = {
    42,
    0,
    8,
    0
  },
  iDraw_Rate = {
    43,
    0,
    8,
    0
  },
  iBonusDmg_Add = {
    47,
    0,
    8,
    0
  },
  iBonusDmg_Reduce = {
    48,
    0,
    8,
    0
  },
  iShield_Rate = {
    50,
    0,
    8,
    0
  },
  iMoveSpeed = {
    51,
    0,
    8,
    0
  },
  iInitialEnergy = {
    52,
    0,
    8,
    0
  },
  iGetEnergySpeed = {
    57,
    0,
    8,
    0
  },
  iHp = {
    100,
    0,
    8,
    0
  },
  iAnger = {
    101,
    0,
    8,
    0
  },
  iMaxAnger = {
    102,
    0,
    8,
    0
  },
  iMobInitialLifeTime = {
    103,
    0,
    8,
    0
  },
  iMobRemainLifeTime = {
    104,
    0,
    8,
    0
  },
  iAttackEnergyRate = {
    105,
    0,
    8,
    0
  },
  iDotDmg_ReduceRate = {
    106,
    0,
    8,
    0
  },
  iAttackDmg_Add = {
    107,
    0,
    8,
    0
  },
  iOgiDmg_Add = {
    108,
    0,
    8,
    0
  },
  iDebuffDmg_Add = {
    109,
    0,
    8,
    0
  },
  iCtrlDmg_Add = {
    110,
    0,
    8,
    0
  },
  iBuffTime_Add = {
    111,
    0,
    8,
    0
  },
  iDebuffTime_Add = {
    112,
    0,
    8,
    0
  },
  iAttackDmg_ReduceRate = {
    114,
    0,
    8,
    0
  },
  iSkillDmg_Add = {
    115,
    0,
    8,
    0
  },
  iSkillDmg_Reduce = {
    116,
    0,
    8,
    0
  },
  iOgiDmg_Reduce = {
    117,
    0,
    8,
    0
  },
  iDotDmg_Add = {
    118,
    0,
    8,
    0
  },
  iDebuffDmg_Reduce = {
    119,
    0,
    8,
    0
  },
  iCtrlDmg_Reduce = {
    120,
    0,
    8,
    0
  },
  iFinalDamage_Add = {
    121,
    0,
    8,
    0
  },
  iFinalDamage_Reduce = {
    122,
    0,
    8,
    0
  }
}
CmdHeroFightData = sdp.SdpStruct("CmdHeroFightData")
CmdHeroFightData.Definition = {
  "iCurrHP",
  iCurrHP = {
    0,
    0,
    8,
    0
  }
}
CmdHeroFightDamage = sdp.SdpStruct("CmdHeroFightDamage")
CmdHeroFightDamage.Definition = {
  "iId",
  "iDamage",
  iId = {
    0,
    0,
    8,
    0
  },
  iDamage = {
    1,
    0,
    8,
    0
  }
}
CmdEquipEffect = sdp.SdpStruct("CmdEquipEffect")
CmdEquipEffect.Definition = {
  "iGroupId",
  "iEffectLevel",
  "bLock",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iEffectLevel = {
    1,
    0,
    8,
    0
  },
  bLock = {
    2,
    0,
    1,
    false
  }
}
CmdEquip = sdp.SdpStruct("CmdEquip")
CmdEquip.Definition = {
  "iEquipUid",
  "iBaseId",
  "iHeroId",
  "iLevel",
  "iExp",
  "iOverloadHero",
  "mOverloadEffect",
  "mChangingEffect",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iHeroId = {
    2,
    0,
    8,
    0
  },
  iLevel = {
    3,
    0,
    8,
    0
  },
  iExp = {
    4,
    0,
    8,
    0
  },
  iOverloadHero = {
    5,
    0,
    8,
    0
  },
  mOverloadEffect = {
    6,
    0,
    sdp.SdpMap(8, CmdEquipEffect),
    nil
  },
  mChangingEffect = {
    7,
    0,
    sdp.SdpMap(8, CmdEquipEffect),
    nil
  }
}
CmdLegacy = sdp.SdpStruct("CmdLegacy")
CmdLegacy.Definition = {
  "iLegacyId",
  "iLevel",
  "vEquipBy",
  iLegacyId = {
    0,
    0,
    8,
    0
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  vEquipBy = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdHeroData = sdp.SdpStruct("CmdHeroData")
CmdHeroData.Definition = {
  "iHeroId",
  "iBaseId",
  "iLevel",
  "iTime",
  "iBreak",
  "iPower",
  "mHeroAttr",
  "mEquip",
  "mSkill",
  "iOriLevel",
  "bLove",
  "iAttractRank",
  "stLegacy",
  "iFashion",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iTime = {
    3,
    0,
    8,
    0
  },
  iBreak = {
    4,
    0,
    8,
    0
  },
  iPower = {
    5,
    0,
    8,
    0
  },
  mHeroAttr = {
    6,
    0,
    sdp.SdpMap(8, CmdAttr),
    nil
  },
  mEquip = {
    7,
    0,
    sdp.SdpMap(8, CmdEquip),
    nil
  },
  mSkill = {
    8,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iOriLevel = {
    9,
    0,
    8,
    0
  },
  bLove = {
    10,
    0,
    1,
    false
  },
  iAttractRank = {
    11,
    0,
    8,
    0
  },
  stLegacy = {
    12,
    0,
    CmdLegacy,
    nil
  },
  iFashion = {
    13,
    0,
    8,
    0
  }
}
CmdHeroBriefData = sdp.SdpStruct("CmdHeroBriefData")
CmdHeroBriefData.Definition = {
  "iHeroId",
  "iBaseId",
  "iLevel",
  "iBreak",
  "iPower",
  "iMaxHP",
  "mEquip",
  "mSkill",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iBreak = {
    3,
    0,
    8,
    0
  },
  iPower = {
    4,
    0,
    8,
    0
  },
  iMaxHP = {
    5,
    0,
    10,
    "0"
  },
  mEquip = {
    6,
    0,
    sdp.SdpMap(8, CmdEquip),
    nil
  },
  mSkill = {
    7,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdStageCampDataSimple = sdp.SdpStruct("CmdStageCampDataSimple")
CmdStageCampDataSimple.Definition = {
  "mHeroData",
  "mHeroFightData",
  mHeroData = {
    0,
    0,
    sdp.SdpMap(8, CmdHeroBriefData),
    nil
  },
  mHeroFightData = {
    1,
    0,
    sdp.SdpMap(8, CmdHeroFightData),
    nil
  }
}
CmdAntiCheatHeroStat = sdp.SdpStruct("CmdAntiCheatHeroStat")
CmdAntiCheatHeroStat.Definition = {
  "iHeroId",
  "iMaxDamage",
  "iAvgDamage",
  "iHPBeforeHurt",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iMaxDamage = {
    1,
    0,
    10,
    "0"
  },
  iAvgDamage = {
    2,
    0,
    10,
    "0"
  },
  iHPBeforeHurt = {
    3,
    0,
    10,
    "0"
  }
}
CmdFormHero = sdp.SdpStruct("CmdFormHero")
CmdFormHero.Definition = {
  "iHeroId",
  "iPos",
  "iRow",
  "iType",
  "iUnitID",
  "iStar",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  },
  iRow = {
    2,
    0,
    8,
    0
  },
  iType = {
    3,
    0,
    8,
    0
  },
  iUnitID = {
    4,
    0,
    8,
    0
  },
  iStar = {
    5,
    0,
    8,
    0
  }
}
CmdForm = sdp.SdpStruct("CmdForm")
CmdForm.Definition = {
  "vHero",
  "iPower",
  "vStarUp",
  "vCardHeroID",
  vHero = {
    0,
    0,
    sdp.SdpVector(CmdFormHero),
    nil
  },
  iPower = {
    1,
    0,
    8,
    0
  },
  vStarUp = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vCardHeroID = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdFormPreset = sdp.SdpStruct("CmdFormPreset")
CmdFormPreset.Definition = {
  "vHeroId",
  "iPower",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iPower = {
    1,
    0,
    8,
    0
  }
}
CmdAntiCheatSideStat = sdp.SdpStruct("CmdAntiCheatSideStat")
CmdAntiCheatSideStat.Definition = {
  "mHeroStat",
  mHeroStat = {
    0,
    0,
    sdp.SdpMap(8, CmdAntiCheatHeroStat),
    nil
  }
}
CmdAntiCheatAllStat = sdp.SdpStruct("CmdAntiCheatAllStat")
CmdAntiCheatAllStat.Definition = {
  "stMyStat",
  "stEnemyStat",
  "iUsedTime",
  stMyStat = {
    0,
    0,
    CmdAntiCheatSideStat,
    nil
  },
  stEnemyStat = {
    1,
    0,
    CmdAntiCheatSideStat,
    nil
  },
  iUsedTime = {
    2,
    0,
    8,
    0
  }
}
CmdFightReportSimple = sdp.SdpStruct("CmdFightReportSimple")
CmdFightReportSimple.Definition = {
  "sVersion",
  "iFightType",
  "iFightSubType",
  "iFightId",
  "iScore",
  "stAttackerCamp",
  "stDefenserCamp",
  "iRoleId",
  "vAttackerHeroDamage",
  "vDefenserHeroDamage",
  "iFightReportId",
  "iTime",
  sVersion = {
    0,
    0,
    13,
    ""
  },
  iFightType = {
    1,
    0,
    8,
    0
  },
  iFightSubType = {
    2,
    0,
    8,
    0
  },
  iFightId = {
    3,
    0,
    10,
    "0"
  },
  iScore = {
    4,
    0,
    8,
    0
  },
  stAttackerCamp = {
    5,
    0,
    CmdStageCampDataSimple,
    nil
  },
  stDefenserCamp = {
    6,
    0,
    CmdStageCampDataSimple,
    nil
  },
  iRoleId = {
    7,
    0,
    10,
    "0"
  },
  vAttackerHeroDamage = {
    8,
    0,
    sdp.SdpVector(CmdHeroFightDamage),
    nil
  },
  vDefenserHeroDamage = {
    9,
    0,
    sdp.SdpVector(CmdHeroFightDamage),
    nil
  },
  iFightReportId = {
    10,
    0,
    10,
    "0"
  },
  iTime = {
    11,
    0,
    8,
    0
  }
}
CmdFormationInfo = sdp.SdpStruct("CmdFormationInfo")
CmdFormationInfo.Definition = {
  "mCmdHero",
  "mEnemyCmdHero",
  "stEnemyForm",
  "vFormHero",
  "bAutoSkill",
  "stMyForm",
  "vFormNPC",
  mCmdHero = {
    1,
    0,
    sdp.SdpMap(8, CmdHeroData),
    nil
  },
  mEnemyCmdHero = {
    2,
    0,
    sdp.SdpMap(8, CmdHeroData),
    nil
  },
  stEnemyForm = {
    3,
    0,
    CmdForm,
    nil
  },
  vFormHero = {
    4,
    0,
    sdp.SdpVector(CmdFormHero),
    nil
  },
  bAutoSkill = {
    5,
    0,
    1,
    false
  },
  stMyForm = {
    6,
    0,
    CmdForm,
    nil
  },
  vFormNPC = {
    7,
    0,
    sdp.SdpVector(CmdFormHero),
    nil
  }
}
CmdFightRoleOpt = sdp.SdpStruct("CmdFightRoleOpt")
CmdFightRoleOpt.Definition = {
  "iTick",
  "iOpType",
  "vParam",
  iTick = {
    0,
    0,
    8,
    0
  },
  iOpType = {
    1,
    0,
    8,
    0
  },
  vParam = {
    2,
    0,
    sdp.SdpVector(7),
    nil
  }
}
CmdFightingHero = sdp.SdpStruct("CmdFightingHero")
CmdFightingHero.Definition = {
  "iStar",
  "iPosition",
  "stAttr",
  iStar = {
    0,
    0,
    8,
    0
  },
  iPosition = {
    1,
    0,
    8,
    0
  },
  stAttr = {
    2,
    0,
    CmdAttr,
    nil
  }
}
CmdFightingUnit = sdp.SdpStruct("CmdFightingUnit")
CmdFightingUnit.Definition = {
  "iGroupId",
  "stAttr",
  "stFormHero",
  "bNpcFormationPlayer",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  stAttr = {
    1,
    0,
    CmdAttr,
    nil
  },
  stFormHero = {
    2,
    0,
    CmdFormHero,
    nil
  },
  bNpcFormationPlayer = {
    3,
    0,
    1,
    false
  }
}
CmdFightingMonster = sdp.SdpStruct("CmdFightingMonster")
CmdFightingMonster.Definition = {
  "iID",
  "iHp",
  "iEnergy",
  "iMaxHp",
  iID = {
    0,
    0,
    8,
    0
  },
  iHp = {
    1,
    0,
    10,
    "0"
  },
  iEnergy = {
    2,
    0,
    8,
    0
  },
  iMaxHp = {
    3,
    0,
    10,
    "0"
  }
}
CmdFightBuffInfo = sdp.SdpStruct("CmdFightBuffInfo")
CmdFightBuffInfo.Definition = {
  "iCamp",
  "iBuffId",
  "iHeroId",
  "iBuffType",
  iCamp = {
    0,
    0,
    8,
    0
  },
  iBuffId = {
    1,
    0,
    8,
    0
  },
  iHeroId = {
    2,
    0,
    8,
    0
  },
  iBuffType = {
    3,
    0,
    8,
    0
  }
}
CmdFightCommonPassthrough = sdp.SdpStruct("CmdFightCommonPassthrough")
CmdFightCommonPassthrough.Definition = {
  "mFightingUnit",
  "iInitPower",
  "mFightingMonster",
  "vBuffInfo",
  "vMonsterGroupList",
  "vMoonList",
  "vRookieQuest",
  "iGlobalEnergy",
  "mRogueRecord",
  "mSimpleParam",
  mFightingUnit = {
    0,
    0,
    sdp.SdpMap(8, CmdFightingUnit),
    nil
  },
  iInitPower = {
    1,
    0,
    8,
    0
  },
  mFightingMonster = {
    2,
    0,
    sdp.SdpMap(8, CmdFightingMonster),
    nil
  },
  vBuffInfo = {
    3,
    0,
    sdp.SdpVector(CmdFightBuffInfo),
    nil
  },
  vMonsterGroupList = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  vMoonList = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  },
  vRookieQuest = {
    7,
    0,
    sdp.SdpVector(8),
    nil
  },
  iGlobalEnergy = {
    8,
    0,
    8,
    0
  },
  mRogueRecord = {
    9,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  },
  mSimpleParam = {
    10,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdFightPassthrough = sdp.SdpStruct("CmdFightPassthrough")
CmdFightPassthrough.Definition = {
  "mFightingHero",
  "vDeadHero",
  "stCommonPassthrough",
  mFightingHero = {
    0,
    0,
    sdp.SdpMap(8, CmdFightingHero),
    nil
  },
  vDeadHero = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  stCommonPassthrough = {
    2,
    0,
    CmdFightCommonPassthrough,
    nil
  }
}
CmdFightSystemInfo = sdp.SdpStruct("CmdFightSystemInfo")
CmdFightSystemInfo.Definition = {
  "iThreadId",
  "iDebugLogType",
  "iDebugLogSizeLimit",
  iThreadId = {
    0,
    0,
    8,
    0
  },
  iDebugLogType = {
    1,
    0,
    8,
    0
  },
  iDebugLogSizeLimit = {
    2,
    0,
    8,
    0
  }
}
CmdFightLegacyStageParam = sdp.SdpStruct("CmdFightLegacyStageParam")
CmdFightLegacyStageParam.Definition = {
  "iWarningNum",
  iWarningNum = {
    0,
    0,
    8,
    0
  }
}
CmdFightVerifyInput = sdp.SdpStruct("CmdFightVerifyInput")
CmdFightVerifyInput.Definition = {
  "iWorldID",
  "iAreaID",
  "iRandomNum",
  "iFightType",
  "iFightSubType",
  "stFormationInfo",
  "iFightUid",
  "stCommonPassthrough",
  "vFinishOpt",
  "stSystemInfo",
  "stLegacyStageParam",
  "iFightId",
  iWorldID = {
    1,
    0,
    8,
    0
  },
  iAreaID = {
    2,
    0,
    8,
    0
  },
  iRandomNum = {
    3,
    0,
    8,
    0
  },
  iFightType = {
    4,
    0,
    8,
    0
  },
  iFightSubType = {
    5,
    0,
    8,
    0
  },
  stFormationInfo = {
    6,
    0,
    CmdFormationInfo,
    nil
  },
  iFightUid = {
    9,
    0,
    10,
    "0"
  },
  stCommonPassthrough = {
    10,
    0,
    CmdFightCommonPassthrough,
    nil
  },
  vFinishOpt = {
    11,
    0,
    sdp.SdpVector(CmdFightRoleOpt),
    nil
  },
  stSystemInfo = {
    12,
    0,
    CmdFightSystemInfo,
    nil
  },
  stLegacyStageParam = {
    13,
    0,
    CmdFightLegacyStageParam,
    nil
  },
  iFightId = {
    14,
    0,
    8,
    0
  }
}
CmdFightVerifyDebugInfo = sdp.SdpStruct("CmdFightVerifyDebugInfo")
CmdFightVerifyDebugInfo.Definition = {
  "sError",
  "iErrorType",
  "sDebugInfo",
  "iRealCostTime",
  sError = {
    0,
    0,
    13,
    ""
  },
  iErrorType = {
    1,
    0,
    7,
    0
  },
  sDebugInfo = {
    2,
    0,
    13,
    ""
  },
  iRealCostTime = {
    3,
    0,
    8,
    0
  }
}
CmdFightVerifyOutput = sdp.SdpStruct("CmdFightVerifyOutput")
CmdFightVerifyOutput.Definition = {
  "iScore",
  "iFrameTime",
  "stDebugInfo",
  "stPassthrough",
  "bWin",
  iScore = {
    0,
    0,
    10,
    "0"
  },
  iFrameTime = {
    1,
    0,
    8,
    0
  },
  stDebugInfo = {
    2,
    0,
    CmdFightVerifyDebugInfo,
    nil
  },
  stPassthrough = {
    3,
    0,
    CmdFightPassthrough,
    nil
  },
  bWin = {
    4,
    0,
    1,
    false
  }
}
CmdFightReport = sdp.SdpStruct("CmdFightReport")
CmdFightReport.Definition = {
  "iFightUid",
  "iFightId",
  "sCSharpMd5",
  "iFightType",
  "iFightSubType",
  "iZoneId",
  "iRoleId",
  "iBeginTime",
  "sVersion",
  "stVerifyInput",
  "stVerifyOutput",
  "bClientErr",
  iFightUid = {
    0,
    0,
    10,
    "0"
  },
  iFightId = {
    1,
    0,
    10,
    "0"
  },
  sCSharpMd5 = {
    2,
    0,
    13,
    ""
  },
  iFightType = {
    3,
    0,
    8,
    0
  },
  iFightSubType = {
    4,
    0,
    8,
    0
  },
  iZoneId = {
    5,
    0,
    8,
    0
  },
  iRoleId = {
    6,
    0,
    10,
    "0"
  },
  iBeginTime = {
    7,
    0,
    8,
    0
  },
  sVersion = {
    8,
    0,
    13,
    ""
  },
  stVerifyInput = {
    9,
    0,
    CmdFightVerifyInput,
    nil
  },
  stVerifyOutput = {
    10,
    0,
    CmdFightVerifyOutput,
    nil
  },
  bClientErr = {
    11,
    0,
    1,
    false
  }
}
CmdFightReportOwnerInfo = sdp.SdpStruct("CmdFightReportOwnerInfo")
CmdFightReportOwnerInfo.Definition = {
  "iRoleId",
  "iAllianceId",
  "sAllianceName",
  "iAllianceBadge",
  iRoleId = {
    0,
    0,
    10,
    "0"
  },
  iAllianceId = {
    1,
    0,
    10,
    "0"
  },
  sAllianceName = {
    2,
    0,
    13,
    ""
  },
  iAllianceBadge = {
    3,
    0,
    8,
    0
  }
}
CmdRoleSimpleInfo = sdp.SdpStruct("CmdRoleSimpleInfo")
CmdRoleSimpleInfo.Definition = {
  "stRoleId",
  "sName",
  "iLevel",
  "sAlliance",
  "iAllianceId",
  "iCountryId",
  "iAllianceBadge",
  "sFacePath",
  "iGender",
  "bDisplayGender",
  "bDisplayVip",
  "iVipLevel",
  "sZoneName",
  "sFBFaceId",
  "sThisLoginChannel",
  "bAcceptFriend",
  "mSimpleData",
  "iLastLoginTime",
  "iLastLogoutTime",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  "iReplaceArenaPlaySeason",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  sAlliance = {
    4,
    0,
    13,
    ""
  },
  iAllianceId = {
    5,
    0,
    10,
    "0"
  },
  iCountryId = {
    6,
    0,
    8,
    0
  },
  iAllianceBadge = {
    7,
    0,
    8,
    0
  },
  sFacePath = {
    8,
    0,
    13,
    ""
  },
  iGender = {
    9,
    0,
    8,
    0
  },
  bDisplayGender = {
    10,
    0,
    1,
    false
  },
  bDisplayVip = {
    11,
    0,
    1,
    false
  },
  iVipLevel = {
    12,
    0,
    8,
    0
  },
  sZoneName = {
    13,
    0,
    13,
    ""
  },
  sFBFaceId = {
    14,
    0,
    13,
    ""
  },
  sThisLoginChannel = {
    15,
    0,
    13,
    ""
  },
  bAcceptFriend = {
    16,
    0,
    8,
    0
  },
  mSimpleData = {
    17,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iLastLoginTime = {
    18,
    0,
    8,
    0
  },
  iLastLogoutTime = {
    19,
    0,
    8,
    0
  },
  iHeadId = {
    20,
    0,
    8,
    0
  },
  iHeadFrameId = {
    21,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    22,
    0,
    8,
    0
  },
  iReplaceArenaPlaySeason = {
    23,
    0,
    8,
    0
  }
}
CmdRoleBusinessCard = sdp.SdpStruct("CmdRoleBusinessCard")
CmdRoleBusinessCard.Definition = {
  "stRoleId",
  "sName",
  "iLevel",
  "iExp",
  "sAllianceName",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  "iShowBackgroundId",
  "mCampHeroNum",
  "iPower",
  "vTopHero",
  "mmProgress",
  "sSignature",
  "iShowBackgroundExpireTime",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iExp = {
    3,
    0,
    8,
    0
  },
  sAllianceName = {
    4,
    0,
    13,
    ""
  },
  iHeadId = {
    5,
    0,
    8,
    0
  },
  iHeadFrameId = {
    6,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    7,
    0,
    8,
    0
  },
  iShowBackgroundId = {
    8,
    0,
    8,
    0
  },
  mCampHeroNum = {
    9,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iPower = {
    10,
    0,
    8,
    0
  },
  vTopHero = {
    11,
    0,
    sdp.SdpVector(CmdHeroBriefData),
    nil
  },
  mmProgress = {
    12,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  },
  sSignature = {
    13,
    0,
    13,
    ""
  },
  iShowBackgroundExpireTime = {
    14,
    0,
    8,
    0
  }
}
CmdAllianceApplyerData = sdp.SdpStruct("CmdAllianceApplyerData")
CmdAllianceApplyerData.Definition = {
  "stRoleId",
  "sRoleName",
  "iLevel",
  "iPower",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sRoleName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iPower = {
    3,
    0,
    8,
    0
  },
  iHeadId = {
    4,
    0,
    8,
    0
  },
  iHeadFrameId = {
    5,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    6,
    0,
    8,
    0
  }
}
CmdAllianceMemberActive = sdp.SdpStruct("CmdAllianceMemberActive")
CmdAllianceMemberActive.Definition = {
  "iTime",
  "iActive",
  iTime = {
    0,
    0,
    8,
    0
  },
  iActive = {
    1,
    0,
    8,
    0
  }
}
CmdAllianceMemberData = sdp.SdpStruct("CmdAllianceMemberData")
CmdAllianceMemberData.Definition = {
  "stRoleId",
  "sRoleName",
  "iLevel",
  "iPost",
  "iLastLogoutTime",
  "iJoinTime",
  "bOnline",
  "iCountryId",
  "iTotalActive",
  "iTodayActive",
  "iPower",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sRoleName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iPost = {
    3,
    0,
    8,
    0
  },
  iLastLogoutTime = {
    4,
    0,
    8,
    0
  },
  iJoinTime = {
    5,
    0,
    8,
    0
  },
  bOnline = {
    6,
    0,
    1,
    false
  },
  iCountryId = {
    7,
    0,
    8,
    0
  },
  iTotalActive = {
    8,
    0,
    8,
    0
  },
  iTodayActive = {
    9,
    0,
    8,
    0
  },
  iPower = {
    10,
    0,
    8,
    0
  },
  iHeadId = {
    11,
    0,
    8,
    0
  },
  iHeadFrameId = {
    12,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    13,
    0,
    8,
    0
  }
}
CmdAllianceBriefData = sdp.SdpStruct("CmdAllianceBriefData")
CmdAllianceBriefData.Definition = {
  "iAllianceId",
  "sName",
  "iCreateTime",
  "iLevel",
  "iCurrMemberCount",
  "iCountryId",
  "iLanguageId",
  "iBadgeId",
  "iJoinType",
  "iJoinLevel",
  "stMaster",
  "iTotalActive",
  "iSevenActive",
  "sRecruit",
  "iLastBattleRank",
  "iLastBattleRankCount",
  "iLastBattleRankTime",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iCreateTime = {
    2,
    0,
    8,
    0
  },
  iLevel = {
    3,
    0,
    8,
    0
  },
  iCurrMemberCount = {
    4,
    0,
    8,
    0
  },
  iCountryId = {
    5,
    0,
    8,
    0
  },
  iLanguageId = {
    6,
    0,
    8,
    0
  },
  iBadgeId = {
    7,
    0,
    8,
    0
  },
  iJoinType = {
    8,
    0,
    8,
    0
  },
  iJoinLevel = {
    9,
    0,
    8,
    0
  },
  stMaster = {
    10,
    0,
    PlayerIDType,
    nil
  },
  iTotalActive = {
    11,
    0,
    8,
    0
  },
  iSevenActive = {
    12,
    0,
    8,
    0
  },
  sRecruit = {
    13,
    0,
    13,
    ""
  },
  iLastBattleRank = {
    14,
    0,
    8,
    0
  },
  iLastBattleRankCount = {
    15,
    0,
    8,
    0
  },
  iLastBattleRankTime = {
    16,
    0,
    8,
    0
  }
}
CmdAllianceInviteUser = sdp.SdpStruct("CmdAllianceInviteUser")
CmdAllianceInviteUser.Definition = {
  "stRoleId",
  "sRoleName",
  "iLevel",
  "iPost",
  "iInviteTime",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sRoleName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iPost = {
    3,
    0,
    8,
    0
  },
  iInviteTime = {
    4,
    0,
    8,
    0
  },
  iHeadId = {
    5,
    0,
    8,
    0
  },
  iHeadFrameId = {
    6,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    7,
    0,
    8,
    0
  }
}
CmdAllianceInviteInfo = sdp.SdpStruct("CmdAllianceInviteInfo")
CmdAllianceInviteInfo.Definition = {
  "stBriefInfo",
  "stInviteUser",
  stBriefInfo = {
    0,
    0,
    CmdAllianceBriefData,
    nil
  },
  stInviteUser = {
    1,
    0,
    CmdAllianceInviteUser,
    nil
  }
}
CmdMailFightHero = sdp.SdpStruct("CmdMailFightHero")
CmdMailFightHero.Definition = {
  "iHeroId",
  "iBaseId",
  "iBreak",
  "iLevel",
  "iHPPercent",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iBreak = {
    2,
    0,
    8,
    0
  },
  iLevel = {
    3,
    0,
    8,
    0
  },
  iHPPercent = {
    4,
    0,
    8,
    0
  }
}
CmdMailFightSide = sdp.SdpStruct("CmdMailFightSide")
CmdMailFightSide.Definition = {
  "iRoleUid",
  "sName",
  "iLevel",
  "bWin",
  "vMailFightHero",
  "iType",
  "bIsMine",
  "iVipLevel",
  "iMineralVeinId",
  "stRewardItem",
  "bWorldBoss",
  "iPower",
  "iBuffPercent",
  "iTownAppearanceId",
  "iWorldBossEnumType",
  "bDisplayGender",
  "iShipId",
  "sFBFaceId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iRoleUid = {
    0,
    0,
    10,
    "0"
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  bWin = {
    3,
    0,
    8,
    0
  },
  vMailFightHero = {
    4,
    0,
    sdp.SdpVector(CmdMailFightHero),
    nil
  },
  iType = {
    5,
    0,
    8,
    0
  },
  bIsMine = {
    6,
    0,
    1,
    false
  },
  iVipLevel = {
    7,
    0,
    8,
    0
  },
  iMineralVeinId = {
    8,
    0,
    8,
    0
  },
  stRewardItem = {
    9,
    0,
    CmdIDNum,
    nil
  },
  bWorldBoss = {
    10,
    0,
    1,
    false
  },
  iPower = {
    11,
    0,
    8,
    0
  },
  iBuffPercent = {
    12,
    0,
    7,
    0
  },
  iTownAppearanceId = {
    13,
    0,
    8,
    0
  },
  iWorldBossEnumType = {
    14,
    0,
    8,
    0
  },
  bDisplayGender = {
    15,
    0,
    1,
    false
  },
  iShipId = {
    16,
    0,
    8,
    0
  },
  sFBFaceId = {
    17,
    0,
    13,
    ""
  },
  iHeadId = {
    18,
    0,
    8,
    0
  },
  iHeadFrameId = {
    19,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    20,
    0,
    8,
    0
  }
}
CmdMailFightReport = sdp.SdpStruct("CmdMailFightReport")
CmdMailFightReport.Definition = {
  "stAttackSide",
  "stDefendSide",
  "iFightReportId",
  "vItem",
  "vAttackSide",
  "bCrossBattle",
  stAttackSide = {
    0,
    0,
    CmdMailFightSide,
    nil
  },
  stDefendSide = {
    1,
    0,
    CmdMailFightSide,
    nil
  },
  iFightReportId = {
    2,
    0,
    10,
    "0"
  },
  vItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vAttackSide = {
    4,
    0,
    sdp.SdpVector(CmdMailFightSide),
    nil
  },
  bCrossBattle = {
    5,
    0,
    1,
    false
  }
}
CmdChatArenaBattleFightReport = sdp.SdpStruct("CmdChatArenaBattleFightReport")
CmdChatArenaBattleFightReport.Definition = {
  "iZoneId",
  "iReportId",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  iReportId = {
    1,
    0,
    10,
    "0"
  }
}
CmdChatInfo = sdp.SdpStruct("CmdChatInfo")
CmdChatInfo.Definition = {
  "iUid",
  "sName",
  "iChannel",
  "sMessage",
  "iTime",
  "iVipLevel",
  "sAlliance",
  "iTemplateId",
  "mParam",
  "iFightReportId",
  "iFightType",
  "iChatUid",
  "iCountryId",
  "bSys",
  "iAllianceId",
  "bDisplayVip",
  "stSharedRole",
  "stSharedAlliance",
  "stMailFightReport",
  "iValidEndTime",
  "vArenaBattleReportId",
  "iGroupId",
  "iRoleLanguageId",
  "sFacePath",
  "iPost",
  "iZoneId",
  "sZoneName",
  "iGender",
  "iRoomId",
  "iExcludeUid",
  "bDisplayGender",
  "bCrossBattle",
  "iLevel",
  "stShareHero",
  "iFightReportZoneId",
  "stToRoleId",
  "bSysMessage",
  "sFBFaceId",
  "iMaxPassStageId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iChannel = {
    2,
    0,
    8,
    0
  },
  sMessage = {
    3,
    0,
    13,
    ""
  },
  iTime = {
    4,
    0,
    8,
    0
  },
  iVipLevel = {
    6,
    0,
    8,
    0
  },
  sAlliance = {
    7,
    0,
    13,
    ""
  },
  iTemplateId = {
    8,
    0,
    8,
    0
  },
  mParam = {
    9,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iFightReportId = {
    10,
    0,
    10,
    "0"
  },
  iFightType = {
    11,
    0,
    8,
    0
  },
  iChatUid = {
    12,
    0,
    8,
    0
  },
  iCountryId = {
    13,
    0,
    8,
    0
  },
  bSys = {
    14,
    0,
    1,
    false
  },
  iAllianceId = {
    15,
    0,
    10,
    "0"
  },
  bDisplayVip = {
    16,
    0,
    1,
    false
  },
  stSharedRole = {
    17,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  stSharedAlliance = {
    18,
    0,
    CmdAllianceBriefData,
    nil
  },
  stMailFightReport = {
    19,
    0,
    CmdMailFightReport,
    nil
  },
  iValidEndTime = {
    20,
    0,
    8,
    0
  },
  vArenaBattleReportId = {
    21,
    0,
    sdp.SdpVector(CmdChatArenaBattleFightReport),
    nil
  },
  iGroupId = {
    22,
    0,
    10,
    "0"
  },
  iRoleLanguageId = {
    23,
    0,
    8,
    0
  },
  sFacePath = {
    24,
    0,
    13,
    ""
  },
  iPost = {
    25,
    0,
    8,
    0
  },
  iZoneId = {
    26,
    0,
    8,
    0
  },
  sZoneName = {
    27,
    0,
    13,
    ""
  },
  iGender = {
    28,
    0,
    8,
    0
  },
  iRoomId = {
    29,
    0,
    10,
    "0"
  },
  iExcludeUid = {
    30,
    0,
    10,
    "0"
  },
  bDisplayGender = {
    31,
    0,
    1,
    false
  },
  bCrossBattle = {
    32,
    0,
    1,
    false
  },
  iLevel = {
    33,
    0,
    8,
    0
  },
  stShareHero = {
    34,
    0,
    CmdHeroData,
    nil
  },
  iFightReportZoneId = {
    35,
    0,
    8,
    0
  },
  stToRoleId = {
    36,
    0,
    PlayerIDType,
    nil
  },
  bSysMessage = {
    37,
    0,
    1,
    false
  },
  sFBFaceId = {
    38,
    0,
    13,
    ""
  },
  iMaxPassStageId = {
    39,
    0,
    8,
    0
  },
  iHeadId = {
    40,
    0,
    8,
    0
  },
  iHeadFrameId = {
    41,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    42,
    0,
    8,
    0
  }
}
CmdChatGroup = sdp.SdpStruct("CmdChatGroup")
CmdChatGroup.Definition = {
  "iGroupId",
  "iCreateUid",
  "iCreateTime",
  "sName",
  "vMember",
  "vChat",
  "bOpenPush",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  iCreateUid = {
    1,
    0,
    10,
    "0"
  },
  iCreateTime = {
    2,
    0,
    8,
    0
  },
  sName = {
    3,
    0,
    13,
    ""
  },
  vMember = {
    4,
    0,
    sdp.SdpVector(CmdRoleSimpleInfo),
    nil
  },
  vChat = {
    5,
    0,
    sdp.SdpVector(CmdChatInfo),
    nil
  },
  bOpenPush = {
    6,
    0,
    1,
    false
  }
}
CmdSimpleHeroData = sdp.SdpStruct("CmdSimpleHeroData")
CmdSimpleHeroData.Definition = {
  "iHeroId",
  "iBaseId",
  "iLevel",
  "iBreak",
  "iPower",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  iBreak = {
    3,
    0,
    8,
    0
  },
  iPower = {
    4,
    0,
    8,
    0
  }
}
CmdRankRoleItem = sdp.SdpStruct("CmdRankRoleItem")
CmdRankRoleItem.Definition = {
  "iRank",
  "iRoleUid",
  "sName",
  "iLevel",
  "iCountryId",
  "iRankValue",
  "iAllianceId",
  "sAllianceName",
  "iZoneId",
  "bDisplayGender",
  "sFBFaceId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iRank = {
    0,
    0,
    8,
    0
  },
  iRoleUid = {
    1,
    0,
    10,
    "0"
  },
  sName = {
    2,
    0,
    13,
    ""
  },
  iLevel = {
    3,
    0,
    8,
    0
  },
  iCountryId = {
    4,
    0,
    8,
    0
  },
  iRankValue = {
    5,
    0,
    8,
    0
  },
  iAllianceId = {
    6,
    0,
    10,
    "0"
  },
  sAllianceName = {
    7,
    0,
    13,
    ""
  },
  iZoneId = {
    8,
    0,
    8,
    0
  },
  bDisplayGender = {
    9,
    0,
    1,
    false
  },
  sFBFaceId = {
    10,
    0,
    13,
    ""
  },
  iHeadId = {
    11,
    0,
    8,
    0
  },
  iHeadFrameId = {
    12,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    13,
    0,
    8,
    0
  }
}
CmdItemData = sdp.SdpStruct("CmdItemData")
CmdItemData.Definition = {
  "iItemUid",
  "iBaseId",
  "iNum",
  iItemUid = {
    0,
    0,
    10,
    "0"
  },
  iBaseId = {
    1,
    0,
    8,
    0
  },
  iNum = {
    2,
    0,
    8,
    0
  }
}
CmdActivityRankInfo = sdp.SdpStruct("CmdActivityRankInfo")
CmdActivityRankInfo.Definition = {
  "iUid",
  "sName",
  "iLevel",
  "bDisplayGender",
  "iValue",
  "iAllianceId",
  "iAllianceBadge",
  "sAllianceName",
  "iPost",
  "sFBFaceId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  bDisplayGender = {
    3,
    0,
    1,
    false
  },
  iValue = {
    4,
    0,
    8,
    0
  },
  iAllianceId = {
    5,
    0,
    10,
    "0"
  },
  iAllianceBadge = {
    6,
    0,
    8,
    0
  },
  sAllianceName = {
    7,
    0,
    13,
    ""
  },
  iPost = {
    8,
    0,
    8,
    0
  },
  sFBFaceId = {
    9,
    0,
    13,
    ""
  },
  iHeadId = {
    10,
    0,
    8,
    0
  },
  iHeadFrameId = {
    11,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    12,
    0,
    8,
    0
  }
}
CmdQuest = sdp.SdpStruct("CmdQuest")
CmdQuest.Definition = {
  "iId",
  "iType",
  "iState",
  "iAcceptTime",
  "vCondStep",
  iId = {
    0,
    0,
    8,
    0
  },
  iType = {
    1,
    0,
    8,
    0
  },
  iState = {
    2,
    0,
    8,
    0
  },
  iAcceptTime = {
    3,
    0,
    8,
    0
  },
  vCondStep = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdClientData = sdp.SdpStruct("CmdClientData")
CmdClientData.Definition = {
  "iExpireTime",
  "iActId",
  "sClientData",
  iExpireTime = {
    0,
    0,
    8,
    0
  },
  iActId = {
    1,
    0,
    8,
    0
  },
  sClientData = {
    2,
    0,
    13,
    ""
  }
}
CmdStrategyFormaiton = sdp.SdpStruct("CmdStrategyFormaiton")
CmdStrategyFormaiton.Definition = {
  "iCondition",
  "iAction",
  "iRestriction",
  "bOn",
  iCondition = {
    0,
    0,
    8,
    0
  },
  iAction = {
    1,
    0,
    8,
    0
  },
  iRestriction = {
    2,
    0,
    8,
    0
  },
  bOn = {
    3,
    0,
    1,
    false
  }
}
CmdStrategy = sdp.SdpStruct("CmdStrategy")
CmdStrategy.Definition = {
  "sName",
  "vFormaiton",
  sName = {
    0,
    0,
    13,
    ""
  },
  vFormaiton = {
    1,
    0,
    sdp.SdpVector(CmdStrategyFormaiton),
    nil
  }
}
CmdDeserializeIn = sdp.SdpStruct("CmdDeserializeIn")
CmdDeserializeIn.Definition = {
  "sLog",
  sLog = {
    0,
    0,
    13,
    ""
  }
}
CmdDeserializeOut = sdp.SdpStruct("CmdDeserializeOut")
CmdDeserializeOut.Definition = {
  "sLog",
  sLog = {
    0,
    0,
    13,
    ""
  }
}
CmdCirculationItem = sdp.SdpStruct("CmdCirculationItem")
CmdCirculationItem.Definition = {
  "iTypeID",
  "iLevel",
  "iExp",
  iTypeID = {
    0,
    0,
    8,
    0
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  iExp = {
    2,
    0,
    8,
    0
  }
}
CmdStageArrange = sdp.SdpStruct("CmdStageArrange")
CmdStageArrange.Definition = {
  "vHero",
  "vFormHero",
  "iTotalPower",
  vHero = {
    0,
    0,
    sdp.SdpVector(CmdHeroBriefData),
    nil
  },
  vFormHero = {
    1,
    0,
    sdp.SdpVector(CmdFormHero),
    nil
  },
  iTotalPower = {
    2,
    0,
    10,
    "0"
  }
}
CmdRoleArrange = sdp.SdpStruct("CmdRoleArrange")
CmdRoleArrange.Definition = {
  "stRoleInfo",
  "stStageArrange",
  stRoleInfo = {
    0,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  stStageArrange = {
    1,
    0,
    CmdStageArrange,
    nil
  }
}
CmdFriendInfo = sdp.SdpStruct("CmdFriendInfo")
CmdFriendInfo.Definition = {
  "iLevel",
  "sName",
  "iLoginTime",
  "iLogoutTime",
  "stRoleId",
  "sFBFaceId",
  "iCountryId",
  "iGender",
  "bDisplayGender",
  "iAllianceId",
  "sAllianceName",
  "iPower",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iLevel = {
    0,
    0,
    8,
    0
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLoginTime = {
    2,
    0,
    8,
    0
  },
  iLogoutTime = {
    3,
    0,
    8,
    0
  },
  stRoleId = {
    4,
    0,
    PlayerIDType,
    nil
  },
  sFBFaceId = {
    5,
    0,
    13,
    ""
  },
  iCountryId = {
    6,
    0,
    8,
    0
  },
  iGender = {
    7,
    0,
    8,
    0
  },
  bDisplayGender = {
    8,
    0,
    1,
    false
  },
  iAllianceId = {
    9,
    0,
    10,
    "0"
  },
  sAllianceName = {
    10,
    0,
    13,
    ""
  },
  iPower = {
    11,
    0,
    8,
    0
  },
  iHeadId = {
    12,
    0,
    8,
    0
  },
  iHeadFrameId = {
    13,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    14,
    0,
    8,
    0
  }
}
