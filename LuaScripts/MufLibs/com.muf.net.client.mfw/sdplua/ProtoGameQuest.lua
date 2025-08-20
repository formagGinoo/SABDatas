local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Quest_GetList_CS = 10501
CmdId_Quest_GetList_SC = 10502
CmdId_Quest_TakeReward_CS = 10503
CmdId_Quest_TakeReward_SC = 10504
CmdId_Quest_TakeMainGroupReward_CS = 10505
CmdId_Quest_TakeMainGroupReward_SC = 10506
CmdId_Quest_TakeActiveReward_CS = 10507
CmdId_Quest_TakeActiveReward_SC = 10508
CmdId_Quest_FinishResourceQuest_CS = 10509
CmdId_Quest_FinishResourceQuest_SC = 10510
CmdId_Quest_TakeAchieveReward_CS = 10511
CmdId_Quest_TakeAchieveReward_SC = 10512
CmdId_Quest_GetInit_CS = 10513
CmdId_Quest_GetInit_SC = 10514
QuestType_Daily = 1
QuestType_Weekly = 2
QuestType_Main = 3
QuestType_Achievement = 4
QuestType_ChapterProgress = 5
QuestType_RogueAchieve = 6
QuestType_Resource = 99
QuestType_ActivityBegin = 10000
QuestState_Doing = 1
QuestState_Finish = 2
QuestState_Over = 3
QuestUnlockCond_RoleLevel = 1
QuestUnlockCond_PassStage = 2
QuestUnlockCond_FinishQuest = 3
QuestCond_LoginGameDay = 1
QuestCond_Login = 2
QuestCond_RoleLevel = 3
QuestCond_LoginGameDayOne = 4
QuestCond_JoinAlliance = 5
QuestCond_HeroAddBreak = 101
QuestCond_HeroBreakNum = 102
QuestCond_HeroBreakTo = 103
QuestCond_HeroSkillLevelUp = 104
QuestCond_HeroSkillLevelTo = 105
QuestCond_HeroLevelUp = 106
QuestCond_HeroLevelTo = 107
QuestCond_ResetHeroLevel = 108
QuestCond_HeroListAttractTo = 110
QuestCond_HeroListOneSkillLevelTo = 111
QuestCond_HeroListTwoSkillLevelTo = 112
QuestCond_HeroListThreeSkillLevelTo = 113
QuestCond_HeroListDoOriginalArena = 114
QuestCond_HeroListLegacyInstalled = 115
QuestCond_HeroListDoCouncil = 116
QuestCond_HeroListBreakTo = 117
QuestCond_InstallEquipCount = 121
QuestCond_EquipLevelUp = 122
QuestCond_EquipLevelTo = 123
QuestCond_InstallEquip = 124
QuestCond_EquipOverload = 125
QuestCond_EquipReOverload = 126
QuestCond_EquipReOverloadLevel = 127
QuestCond_HeroAttractRankNum = 131
QuestCond_HeroAttractTouch = 132
QuestCond_HeroAttractSendGift = 133
QuestCond_HeroAttractRankUp = 134
QuestCond_LegacyLevel = 150
QuestCond_LegacyUpgrade = 151
QuestCond_LegacyInstalledNum = 152
QuestCond_StartLegacyStage = 153
QuestCond_Dispatch = 160
QuestCond_Council = 161
QuestCond_DispatchTotal = 162
QuestCond_CouncilTotal = 163
QuestCond_PassRogue = 171
QuestCond_StartRogue = 172
QuestCond_RogueGetItem = 173
QuestCond_RogueKillMonster = 174
QuestCond_RogueUnlockHandbook = 175
QuestCond_RogueUnlockTech = 176
QuestCond_RoguePassTimes = 177
QuestCond_LetterFight = 181
QuestCond_LetterSubmitItem = 182
QuestCond_MainChapterProgress = 200
QuestCond_EnterArena = 201
QuestCond_WinArena = 202
QuestCond_EnterStage = 203
QuestCond_PassStage = 204
QuestCond_StagePassed = 205
QuestCond_GoblinMaxScore = 211
QuestCond_GoblinScore = 212
QuestCond_PassHeroCamp = 221
QuestCond_PassHeroStar = 222
QuestCond_ReplaceArena = 231
QuestCond_ReplaceArenaWin = 232
QuestCond_OriginalArenaPlayTimesDay = 240
QuestCond_OriginalArenaPlayTimes = 241
QuestCond_ReplaceArenaPlayTimesDay = 242
QuestCond_ReplaceArenaPlayTimes = 243
QuestCond_Gacha = 301
QuestCond_GachaHeroQuality = 302
QuestCond_AddHeroQuality = 303
QuestCond_AddHero = 304
QuestCond_GachaTimes = 305
QuestCond_InheritLevel = 401
QuestCond_InheritHeroNum = 402
QuestCond_ShopBuy = 403
QuestCond_SetName = 404
QuestCond_SubItem = 405
QuestCond_TakeAfkReward = 406
QuestCond_TakeAfkInstant = 407
QuestCond_FriendPoint = 408
QuestCond_TaskGetScore = 409
QuestCond_LamiaFinishQuest = 501
QuestCond_LamiaMiniGame = 502
QuestCond_LamiaMiniGameScore = 503
QuestCond_PassGuide = 601
QuestCond_Recharge = 900
QuestCond_RechargePrice = 901
QuestCond_RookieOnlineTime = 902
QuestCond_RookieDefeatTime = 903
QuestCond_VipLevel = QuestCond_RookieDefeatTime + 1
QuestCond_BindAccount = QuestCond_VipLevel + 1
Cmd_Quest_GetList_CS = sdp.SdpStruct("Cmd_Quest_GetList_CS")
Cmd_Quest_GetList_CS.Definition = {
  "iQuestType",
  iQuestType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Quest_GetList_SC = sdp.SdpStruct("Cmd_Quest_GetList_SC")
Cmd_Quest_GetList_SC.Definition = {
  "iQuestType",
  "vQuest",
  "vOver",
  "iTakenActiveReward",
  iQuestType = {
    0,
    0,
    8,
    0
  },
  vQuest = {
    1,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  vOver = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iTakenActiveReward = {
    3,
    0,
    8,
    0
  }
}
Cmd_Quest_GetInit_CS = sdp.SdpStruct("Cmd_Quest_GetInit_CS")
Cmd_Quest_GetInit_CS.Definition = {}
Cmd_Quest_GetInit_SC = sdp.SdpStruct("Cmd_Quest_GetInit_SC")
Cmd_Quest_GetInit_SC.Definition = {
  "iMainGroup",
  "vOverMainGroup",
  "iAchieveScore",
  "vTakenAchieveReward",
  "iRogueAchieveScore",
  "vTakenRogueAchieveReward",
  iMainGroup = {
    0,
    0,
    8,
    0
  },
  vOverMainGroup = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iAchieveScore = {
    2,
    0,
    8,
    0
  },
  vTakenAchieveReward = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iRogueAchieveScore = {
    4,
    0,
    8,
    0
  },
  vTakenRogueAchieveReward = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Quest_TakeReward_CS = sdp.SdpStruct("Cmd_Quest_TakeReward_CS")
Cmd_Quest_TakeReward_CS.Definition = {
  "iQuestType",
  "vQuestId",
  iQuestType = {
    0,
    0,
    8,
    0
  },
  vQuestId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Quest_TakeReward_SC = sdp.SdpStruct("Cmd_Quest_TakeReward_SC")
Cmd_Quest_TakeReward_SC.Definition = {
  "iQuestType",
  "vQuestId",
  "vReward",
  "vActiveReward",
  iQuestType = {
    0,
    0,
    8,
    0
  },
  vQuestId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vActiveReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Quest_TakeMainGroupReward_CS = sdp.SdpStruct("Cmd_Quest_TakeMainGroupReward_CS")
Cmd_Quest_TakeMainGroupReward_CS.Definition = {}
Cmd_Quest_TakeMainGroupReward_SC = sdp.SdpStruct("Cmd_Quest_TakeMainGroupReward_SC")
Cmd_Quest_TakeMainGroupReward_SC.Definition = {
  "iNewMainGroup",
  "vReward",
  "iOldMainGroup",
  iNewMainGroup = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iOldMainGroup = {
    2,
    0,
    8,
    0
  }
}
Cmd_Quest_TakeActiveReward_CS = sdp.SdpStruct("Cmd_Quest_TakeActiveReward_CS")
Cmd_Quest_TakeActiveReward_CS.Definition = {
  "iQuestType",
  iQuestType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Quest_TakeActiveReward_SC = sdp.SdpStruct("Cmd_Quest_TakeActiveReward_SC")
Cmd_Quest_TakeActiveReward_SC.Definition = {
  "iQuestType",
  "vReward",
  iQuestType = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Quest_FinishResourceQuest_CS = sdp.SdpStruct("Cmd_Quest_FinishResourceQuest_CS")
Cmd_Quest_FinishResourceQuest_CS.Definition = {
  "iQuestId",
  iQuestId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Quest_FinishResourceQuest_SC = sdp.SdpStruct("Cmd_Quest_FinishResourceQuest_SC")
Cmd_Quest_FinishResourceQuest_SC.Definition = {
  "iQuestId",
  iQuestId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Quest_TakeAchieveReward_CS = sdp.SdpStruct("Cmd_Quest_TakeAchieveReward_CS")
Cmd_Quest_TakeAchieveReward_CS.Definition = {
  "iRewardId",
  "vQuestId",
  "iQuestType",
  iRewardId = {
    0,
    0,
    8,
    0
  },
  vQuestId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iQuestType = {
    2,
    0,
    8,
    0
  }
}
Cmd_Quest_TakeAchieveReward_SC = sdp.SdpStruct("Cmd_Quest_TakeAchieveReward_SC")
Cmd_Quest_TakeAchieveReward_SC.Definition = {
  "iRewardId",
  "vReward",
  "iQuestType",
  iRewardId = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iQuestType = {
    2,
    0,
    8,
    0
  }
}
