local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameLamia")
require("ProtoComm")
require("ProtoGameItem")
require("ProtoGameHero")
require("ProtoGameQuest")
require("ProtoGameRole")
require("ProtoGameChat")
require("ProtoGameActBase")
require("ProtoGameStore")
require("ProtoGameBaseStore")
require("ProtoGameAlliance")
require("ProtoGameFriend")
require("ProtoGameAttract")
require("ProtoGameOriginalArena")
require("ProtoGameReplaceArena")
require("ProtoGameSoloRaid")
require("ProtoGameCastle")
require("ProtoGameRogue")
require("ProtoGameHunting")
module("MTTDProto")
CmdId_Push_Error = 20001
CmdId_Push_DailyRefresh = 20002
CmdId_Push_SetLevel = 20003
CmdId_Push_Warning = 20004
CmdId_Push_SetItem = 20005
CmdId_Push_SetHeroData = 20006
CmdId_Push_KickPlayer = 20007
CmdId_Push_NewMailNotify = 20008
CmdId_Push_Notice = 20009
CmdId_Push_DelNotice = 20010
CmdId_Push_Chat = 20011
CmdId_Push_Activity_Status = 20012
CmdId_Push_Activity_Remove = 20013
CmdId_Push_Activity_Change = 20014
CmdId_Push_Activity_Reload = 20015
CmdId_Push_IAPDelivery = 20016
CmdId_Push_TotalRecharge = 20017
CmdId_Push_Vip = 20018
CmdId_Push_TotalRechargeDiamond = 20019
CmdId_Push_AddictTime = 20020
CmdId_Push_SetSpecialItem = 20021
CmdId_Push_HeroList = 20022
CmdId_Push_DelHero = 20023
CmdId_Push_AddSameHero = 20024
CmdId_Push_Elva_Message = 20025
CmdId_Push_IAPMonitor = 20026
CmdId_Push_DelEquip = 20027
CmdId_Push_EquipList = 20028
CmdId_Push_SetQuestDataBatch = 20029
CmdId_Push_Notify_FBFace = 20030
CmdId_Push_NeedReload = 20031
CmdId_Push_GetEmoji = 20032
CmdId_Push_Activity_RemoveBatch = 20033
CmdId_Push_Activity_ChangeBatch = 20034
CmdId_Push_Hero_AddFashion = 20035
CmdId_Push_SetUniqueItem = 20036
CmdId_Push_UploadFlog = 20037
CmdId_Push_GM_DailyRefresh = 20038
CmdId_Push_ChatGroupLeave = 20050
CmdId_Push_ChatGroupNew = 20051
CmdId_Push_ChatGroupNewMember = 20052
CmdId_Push_ChatGroupRemove = 20053
CmdId_Push_ChatGroupSetName = 20054
CmdId_Push_ChatChange = 20055
CmdId_Push_Chat_PersonalAllMsg = 20056
CmdId_Push_Chat_GroupAllMsg = 20057
CmdId_Push_Chat_CreateNewPersonalChat = 20058
CmdId_Push_Chat_DelPersonalChat = 20059
CmdId_Push_Notify_Chat = 20060
CmdId_Push_Notify_PersonalChat = 20061
CmdId_Push_Notify_GroupEvent = 20062
CmdId_Push_Notify_AddGroupInfo = 20063
CmdId_Push_CrossChatGroup_Leave = 20064
CmdId_Push_CrossChatGroup_Dismiss = 20065
CmdId_Push_CrossChatGroup_Join = 20066
CmdId_Push_Friend_AddFriend = 20080
CmdId_Push_Friend_AddFriendRequest = 20081
CmdId_Push_Friend_DelFriend = 20082
CmdId_Push_Friend_RecieveHeart = 20083
CmdId_Push_HasNewFace = 20084
CmdId_Push_FriendOnline = 20085
CmdId_Push_FriendOffline = 20086
CmdId_Push_Alliance_SetDevelopment = 20100
CmdId_Push_Alliance_MemberLeave = 20101
CmdId_Push_Alliance_DelRoleApply = 20102
CmdId_Push_Alliance_MemberJoin = 20103
CmdId_Push_Alliance_BulletinChange = 20104
CmdId_Push_Alliance_ApplyListClear = 20105
CmdId_Push_Alliance_PostChange = 20106
CmdId_Push_Alliance_SettingChange = 20107
CmdId_Push_Alliance_Levelup = 20108
CmdId_Push_Alliance_Transfer = 20109
CmdId_Push_Alliance_Destroy = 20110
CmdId_Push_AllianceMemberOnline = 20111
CmdId_Push_AllianceMemberOffline = 20112
CmdId_Push_JoinAllianceCount = 20113
CmdId_Push_Alliance_AddApplyMember = 20114
CmdId_Push_Alliance_DelApplyMember = 20115
CmdId_Push_Notify_AllianceChat = 20116
CmdId_Push_Alliance_BeInvite = 20117
CmdId_Push_Alliance_SetMemberActive = 20118
CmdId_Push_Notify_AllianceConfirm = 20119
CmdId_Push_Alliance_AddNewRecieveCard = 20120
CmdId_Push_NotifyAllianceMail = 20121
CmdId_Push_SetAllianceMailSendNum = 20122
CmdId_Push_Alliance_SetTotalActive = 20123
CmdId_Push_AllianceBattle_NewRound = 20124
CmdId_Push_RoomEnter = 20201
CmdId_Push_RoomLeave = 20202
CmdId_Push_RoomInvite = 20203
CmdId_Push_RoomDiscard = 20204
CmdId_Push_RoomInviteResult = 20205
CmdId_Push_RoomKick = 20206
CmdId_Push_RoomChat = 20207
CmdId_Push_EnterMatch = 20208
CmdId_Push_EnterBattle = 20209
CmdId_Push_BeginMultiFightTest = 20210
CmdId_Push_SystemOpen = 20301
CmdId_Push_AfkLevel = 20302
CmdId_Push_DungeonChapterMop = 20303
CmdId_Push_PassStage = 20304
CmdId_Push_SurveyStatus = 20305
CmdId_Push_FormPower = 20306
CmdId_Push_InheritLevel = 20307
CmdId_Push_StageTimes = 20308
CmdId_Push_FightingStage = 20309
CmdId_Push_OriginalArenaMineInfo = 20310
CmdId_Push_HeroAttract = 20311
CmdId_Push_LegacyData = 20312
CmdId_Push_Quest_AchieveScore = 20313
CmdId_Push_Castle_StatueLevel = 20314
CmdId_Push_ReplaceArena_BattleEndUpdate = 20317
CmdId_Push_ReplaceArena_RankChange = 20318
CmdId_Push_ReplaceArena_NotifySeasonReward = 20319
CmdId_Push_Lamia_Quest = 20320
CmdId_Push_Lamia_Stage = 20321
CmdId_Push_InheritGrid = 20322
CmdId_Push_Castle_AddPlaceStory = 20323
CmdId_Push_Castle_AddDispatch = 20324
CmdId_Push_Rogue_FinishChallenge = 20325
CmdId_Push_Hunting_Boss = 20326
CmdId_Push_Alliance_Battle_Boss = 20327
CmdId_Push_Hunting_RankUpdate = 20328
CmdId_Push_NewGift = 20330
CmdId_Push_LegacyStage = 20331
CmdId_Push_BaseStoreMonthlyCard = 20630
CmdId_Push_BaseStoreMonthlyCardReward = 20631
CmdId_Push_BaseStoreChapter = 20632
CmdId_Push_BaseStoreChapterReward = 20633
CmdId_Push_Notify_OriginalArenaReward = 20634
CmdId_Push_SoloRaid_FinishRaid = 20635
CmdId_Push_SoloRaid_CurRaid = 20636
CmdId_Push_Notify_SoloRaidReward = 20637
CmdId_Push_NewActivityPickupGift = 20638
CmdId_Push_SoloRaid_RankUpdate = 20639
CmdId_Push_NewRankTarget = 20640
CmdId_Push_Notify_HuntingRankReward = 20641
KickReason_RepeatedLogin = 0
KickReason_ClientNewVersion = 1
KickReason_BanLogin = 2
KickReason_OnlyRecharge = 3
KickReason_Maintain = 4
KickReason_Addict = 5
CmdOriginalArenaRewardType_Daily = 1
CmdOriginalArenaRewardType_Season = 2
Cmd_Push_Error = sdp.SdpStruct("Cmd_Push_Error")
Cmd_Push_Error.Definition = {
  "mParam",
  mParam = {
    0,
    0,
    sdp.SdpMap(13, 13),
    nil
  }
}
Cmd_Push_DailyRefresh = sdp.SdpStruct("Cmd_Push_DailyRefresh")
Cmd_Push_DailyRefresh.Definition = {
  "bWeekChange",
  bWeekChange = {
    0,
    0,
    1,
    false
  }
}
Cmd_Push_SetLevel = sdp.SdpStruct("Cmd_Push_SetLevel")
Cmd_Push_SetLevel.Definition = {
  "iLevel",
  "vItem",
  iLevel = {
    0,
    0,
    8,
    0
  },
  vItem = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Push_Warning = sdp.SdpStruct("Cmd_Push_Warning")
Cmd_Push_Warning.Definition = {
  "iErrorCode",
  iErrorCode = {
    0,
    0,
    7,
    0
  }
}
Cmd_Push_SetItem = sdp.SdpStruct("Cmd_Push_SetItem")
Cmd_Push_SetItem.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdItemData),
    nil
  }
}
Cmd_Push_SetQuestDataBatch = sdp.SdpStruct("Cmd_Push_SetQuestDataBatch")
Cmd_Push_SetQuestDataBatch.Definition = {
  "vCmdQuestInfo",
  "iMainGroup",
  vCmdQuestInfo = {
    0,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  iMainGroup = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_KickPlayer = sdp.SdpStruct("Cmd_Push_KickPlayer")
Cmd_Push_KickPlayer.Definition = {
  "iReason",
  iReason = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_NewMailNotify = sdp.SdpStruct("Cmd_Push_NewMailNotify")
Cmd_Push_NewMailNotify.Definition = {
  "iMailId",
  "iType",
  "iTemplateId",
  "sTitle",
  "mTitleParam",
  iMailId = {
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
  iTemplateId = {
    2,
    0,
    8,
    0
  },
  sTitle = {
    3,
    0,
    13,
    ""
  },
  mTitleParam = {
    4,
    0,
    sdp.SdpMap(13, 13),
    nil
  }
}
Cmd_Push_Notice = sdp.SdpStruct("Cmd_Push_Notice")
Cmd_Push_Notice.Definition = {
  "vNoticeData",
  vNoticeData = {
    0,
    0,
    sdp.SdpVector(CmdNoticeData),
    nil
  }
}
Cmd_Push_DelNotice = sdp.SdpStruct("Cmd_Push_DelNotice")
Cmd_Push_DelNotice.Definition = {
  "vDel",
  vDel = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_Chat = sdp.SdpStruct("Cmd_Push_Chat")
Cmd_Push_Chat.Definition = {
  "stChatInfo",
  stChatInfo = {
    0,
    0,
    CmdChatInfo,
    nil
  }
}
Cmd_Push_Activity_Status = sdp.SdpStruct("Cmd_Push_Activity_Status")
Cmd_Push_Activity_Status.Definition = {
  "iActivityId",
  "sStatusDataSdp",
  "iPushVersion",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  sStatusDataSdp = {
    1,
    0,
    13,
    ""
  },
  iPushVersion = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Activity_Remove = sdp.SdpStruct("Cmd_Push_Activity_Remove")
Cmd_Push_Activity_Remove.Definition = {
  "iActivityId",
  "iPushVersion",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iPushVersion = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Activity_Change = sdp.SdpStruct("Cmd_Push_Activity_Change")
Cmd_Push_Activity_Change.Definition = {
  "iActivityId",
  "stActivityData",
  "iPushVersion",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  stActivityData = {
    1,
    0,
    CmdActivityData,
    nil
  },
  iPushVersion = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Alliance_MemberLeave = sdp.SdpStruct("Cmd_Push_Alliance_MemberLeave")
Cmd_Push_Alliance_MemberLeave.Definition = {
  "stRoleId",
  "iAllianceId",
  "bKick",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iAllianceId = {
    1,
    0,
    10,
    "0"
  },
  bKick = {
    2,
    0,
    1,
    false
  }
}
Cmd_Push_Activity_Reload = sdp.SdpStruct("Cmd_Push_Activity_Reload")
Cmd_Push_Activity_Reload.Definition = {}
Cmd_Push_Activity_RemoveBatch = sdp.SdpStruct("Cmd_Push_Activity_RemoveBatch")
Cmd_Push_Activity_RemoveBatch.Definition = {
  "vActivityId",
  "iPushVersion",
  vActivityId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iPushVersion = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Activity_ChangeBatch = sdp.SdpStruct("Cmd_Push_Activity_ChangeBatch")
Cmd_Push_Activity_ChangeBatch.Definition = {
  "mActivityData",
  "iPushVersion",
  mActivityData = {
    0,
    0,
    sdp.SdpMap(8, CmdActivityData),
    nil
  },
  iPushVersion = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Notify_FBFace = sdp.SdpStruct("Cmd_Push_Notify_FBFace")
Cmd_Push_Notify_FBFace.Definition = {
  "sFBFace",
  sFBFace = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Push_NeedReload = sdp.SdpStruct("Cmd_Push_NeedReload")
Cmd_Push_NeedReload.Definition = {}
Cmd_Push_GetEmoji = sdp.SdpStruct("Cmd_Push_GetEmoji")
Cmd_Push_GetEmoji.Definition = {
  "vEmojiId",
  vEmojiId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_ChatChange = sdp.SdpStruct("Cmd_Push_ChatChange")
Cmd_Push_ChatChange.Definition = {
  "stChatInfo",
  stChatInfo = {
    0,
    0,
    CmdChatInfo,
    nil
  }
}
Cmd_Push_AddictTime = sdp.SdpStruct("Cmd_Push_AddictTime")
Cmd_Push_AddictTime.Definition = {
  "iOnlineTime",
  "iIncomePercent",
  iOnlineTime = {
    0,
    0,
    8,
    0
  },
  iIncomePercent = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_SetSpecialItem = sdp.SdpStruct("Cmd_Push_SetSpecialItem")
Cmd_Push_SetSpecialItem.Definition = {
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
Cmd_Push_SetHeroData = sdp.SdpStruct("Cmd_Push_SetHeroData")
Cmd_Push_SetHeroData.Definition = {
  "stCmdHeroData",
  stCmdHeroData = {
    0,
    0,
    CmdHeroData,
    nil
  }
}
Cmd_Push_HeroList = sdp.SdpStruct("Cmd_Push_HeroList")
Cmd_Push_HeroList.Definition = {
  "vHeroData",
  vHeroData = {
    0,
    0,
    sdp.SdpVector(CmdHeroData),
    nil
  }
}
Cmd_Push_DelHero = sdp.SdpStruct("Cmd_Push_DelHero")
Cmd_Push_DelHero.Definition = {
  "vHeroId",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_AddSameHero = sdp.SdpStruct("Cmd_Push_AddSameHero")
Cmd_Push_AddSameHero.Definition = {
  "iHeroId",
  "iBaseId",
  "stItem",
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
  stItem = {
    2,
    0,
    CmdIDNum,
    nil
  }
}
Cmd_Push_Elva_Message = sdp.SdpStruct("Cmd_Push_Elva_Message")
Cmd_Push_Elva_Message.Definition = {}
Cmd_Push_IAPMonitor = sdp.SdpStruct("Cmd_Push_IAPMonitor")
Cmd_Push_IAPMonitor.Definition = {
  "sProductId",
  "stIAPMonitor",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  stIAPMonitor = {
    1,
    0,
    CmdStoreIAPMonitor,
    nil
  }
}
Cmd_Push_Chat_PersonalAllMsg = sdp.SdpStruct("Cmd_Push_Chat_PersonalAllMsg")
Cmd_Push_Chat_PersonalAllMsg.Definition = {
  "vMsg",
  vMsg = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Push_Chat_GroupAllMsg = sdp.SdpStruct("Cmd_Push_Chat_GroupAllMsg")
Cmd_Push_Chat_GroupAllMsg.Definition = {
  "iGroupId",
  "iMsgSeq",
  "iEventSeq",
  "vMsg",
  "vEvent",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iMsgSeq = {
    1,
    0,
    8,
    0
  },
  iEventSeq = {
    2,
    0,
    8,
    0
  },
  vMsg = {
    3,
    0,
    sdp.SdpVector(13),
    nil
  },
  vEvent = {
    4,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Push_Notify_Chat = sdp.SdpStruct("Cmd_Push_Notify_Chat")
Cmd_Push_Notify_Chat.Definition = {
  "stChatInfo",
  "iChatLanguage",
  "iChatTime",
  stChatInfo = {
    0,
    0,
    PlayerChatInfo,
    nil
  },
  iChatLanguage = {
    1,
    0,
    8,
    0
  },
  iChatTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Notify_PersonalChat = sdp.SdpStruct("Cmd_Push_Notify_PersonalChat")
Cmd_Push_Notify_PersonalChat.Definition = {
  "stChatInfo",
  "stFromRoleId",
  stChatInfo = {
    0,
    0,
    PersonalChatInfo,
    nil
  },
  stFromRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_Notify_GroupEvent = sdp.SdpStruct("Cmd_Push_Notify_GroupEvent")
Cmd_Push_Notify_GroupEvent.Definition = {
  "iGroupId",
  "iEventTime",
  "iEventType",
  "stAskerId",
  "vChangeMembers",
  "sParam1",
  "iSeq",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  iEventTime = {
    1,
    0,
    8,
    0
  },
  iEventType = {
    2,
    0,
    8,
    0
  },
  stAskerId = {
    3,
    0,
    _G.MTTDProto.PlayerIDType,
    nil
  },
  vChangeMembers = {
    4,
    0,
    sdp.SdpVector(_G.MTTDProto.PlayerIDType),
    nil
  },
  sParam1 = {
    5,
    0,
    13,
    ""
  },
  iSeq = {
    6,
    0,
    10,
    "0"
  }
}
Cmd_Push_Notify_AddGroupInfo = sdp.SdpStruct("Cmd_Push_Notify_AddGroupInfo")
Cmd_Push_Notify_AddGroupInfo.Definition = {
  "stGroupInfo",
  stGroupInfo = {
    0,
    0,
    ChatGroupInfo,
    nil
  }
}
Cmd_Push_CrossChatGroup_Leave = sdp.SdpStruct("Cmd_Push_CrossChatGroup_Leave")
Cmd_Push_CrossChatGroup_Leave.Definition = {
  "iGroupId",
  "stPlayer",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  stPlayer = {
    1,
    0,
    _G.MTTDProto.PlayerIDType,
    nil
  }
}
Cmd_Push_CrossChatGroup_Dismiss = sdp.SdpStruct("Cmd_Push_CrossChatGroup_Dismiss")
Cmd_Push_CrossChatGroup_Dismiss.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_CrossChatGroup_Join = sdp.SdpStruct("Cmd_Push_CrossChatGroup_Join")
Cmd_Push_CrossChatGroup_Join.Definition = {
  "stGroupInfo",
  stGroupInfo = {
    0,
    0,
    GroupChatInfo,
    nil
  }
}
Cmd_Push_Friend_AddFriend = sdp.SdpStruct("Cmd_Push_Friend_AddFriend")
Cmd_Push_Friend_AddFriend.Definition = {
  "stFriendInfo",
  "iCurFriendNum",
  stFriendInfo = {
    0,
    0,
    CmdFriendInfo,
    nil
  },
  iCurFriendNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Friend_AddFriendRequest = sdp.SdpStruct("Cmd_Push_Friend_AddFriendRequest")
Cmd_Push_Friend_AddFriendRequest.Definition = {
  "stRequestInfo",
  stRequestInfo = {
    0,
    0,
    CmdFriendInfo,
    nil
  }
}
Cmd_Push_Friend_DelFriend = sdp.SdpStruct("Cmd_Push_Friend_DelFriend")
Cmd_Push_Friend_DelFriend.Definition = {
  "iRoleUid",
  "stRoleId",
  iRoleUid = {
    0,
    0,
    10,
    "0"
  },
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_Friend_RecieveHeart = sdp.SdpStruct("Cmd_Push_Friend_RecieveHeart")
Cmd_Push_Friend_RecieveHeart.Definition = {
  "iRoleUid",
  "stRoleId",
  iRoleUid = {
    0,
    0,
    10,
    "0"
  },
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_HasNewFace = sdp.SdpStruct("Cmd_Push_HasNewFace")
Cmd_Push_HasNewFace.Definition = {
  "vNewFace",
  "vAllFace",
  vNewFace = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vAllFace = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_Alliance_MemberJoin = sdp.SdpStruct("Cmd_Push_Alliance_MemberJoin")
Cmd_Push_Alliance_MemberJoin.Definition = {
  "stMemberData",
  "iAllianceId",
  "sAllianceName",
  stMemberData = {
    0,
    0,
    CmdAllianceMemberData,
    nil
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
  }
}
Cmd_Push_Alliance_BulletinChange = sdp.SdpStruct("Cmd_Push_Alliance_BulletinChange")
Cmd_Push_Alliance_BulletinChange.Definition = {
  "sBulletin",
  sBulletin = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Push_Alliance_ApplyListClear = sdp.SdpStruct("Cmd_Push_Alliance_ApplyListClear")
Cmd_Push_Alliance_ApplyListClear.Definition = {
  "vApplyList",
  vApplyList = {
    0,
    0,
    sdp.SdpVector(CmdAllianceApplyerData),
    nil
  }
}
Cmd_Push_Alliance_PostChange = sdp.SdpStruct("Cmd_Push_Alliance_PostChange")
Cmd_Push_Alliance_PostChange.Definition = {
  "stRoleId",
  "iPost",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iPost = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Alliance_SettingChange = sdp.SdpStruct("Cmd_Push_Alliance_SettingChange")
Cmd_Push_Alliance_SettingChange.Definition = {
  "vChangeSettingsType",
  "sName",
  "iBadgeId",
  "iJoinType",
  "iJoinLevel",
  "iLanguageId",
  "sRecruit",
  "sBulletin",
  vChangeSettingsType = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iBadgeId = {
    2,
    0,
    8,
    0
  },
  iJoinType = {
    3,
    0,
    8,
    0
  },
  iJoinLevel = {
    4,
    0,
    8,
    0
  },
  iLanguageId = {
    5,
    0,
    8,
    0
  },
  sRecruit = {
    6,
    0,
    13,
    ""
  },
  sBulletin = {
    7,
    0,
    13,
    ""
  }
}
Cmd_Push_IAPDelivery = sdp.SdpStruct("Cmd_Push_IAPDelivery")
Cmd_Push_IAPDelivery.Definition = {
  "sProductId",
  "iLastTotalRecharge",
  "iCurrentTotalRecharge",
  "vItem",
  "iSubProductId",
  "iReceiptType",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iLastTotalRecharge = {
    1,
    0,
    8,
    0
  },
  iCurrentTotalRecharge = {
    2,
    0,
    8,
    0
  },
  vItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iSubProductId = {
    4,
    0,
    8,
    0
  },
  iReceiptType = {
    5,
    0,
    8,
    0
  }
}
Cmd_Push_TotalRecharge = sdp.SdpStruct("Cmd_Push_TotalRecharge")
Cmd_Push_TotalRecharge.Definition = {
  "iTotalRecharge",
  "iDailyRMBRecharge",
  "iTodayRechargeNum",
  iTotalRecharge = {
    0,
    0,
    8,
    0
  },
  iDailyRMBRecharge = {
    1,
    0,
    8,
    0
  },
  iTodayRechargeNum = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Vip = sdp.SdpStruct("Cmd_Push_Vip")
Cmd_Push_Vip.Definition = {
  "iVipLevel",
  "iVipExp",
  "iTotalVipLevel",
  "iFreeVipExp",
  iVipLevel = {
    0,
    0,
    8,
    0
  },
  iVipExp = {
    1,
    0,
    8,
    0
  },
  iTotalVipLevel = {
    2,
    0,
    8,
    0
  },
  iFreeVipExp = {
    3,
    0,
    8,
    0
  }
}
Cmd_Push_TotalRechargeDiamond = sdp.SdpStruct("Cmd_Push_TotalRechargeDiamond")
Cmd_Push_TotalRechargeDiamond.Definition = {
  "iTotalRechargeDiamond",
  iTotalRechargeDiamond = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_ChatGroupLeave = sdp.SdpStruct("Cmd_Push_ChatGroupLeave")
Cmd_Push_ChatGroupLeave.Definition = {
  "iGroupId",
  "vUid",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  vUid = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Push_ChatGroupNew = sdp.SdpStruct("Cmd_Push_ChatGroupNew")
Cmd_Push_ChatGroupNew.Definition = {
  "stGroup",
  stGroup = {
    0,
    0,
    CmdChatGroup,
    nil
  }
}
Cmd_Push_ChatGroupNewMember = sdp.SdpStruct("Cmd_Push_ChatGroupNewMember")
Cmd_Push_ChatGroupNewMember.Definition = {
  "iGroupId",
  "vNewMember",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  vNewMember = {
    1,
    0,
    sdp.SdpVector(CmdRoleSimpleInfo),
    nil
  }
}
Cmd_Push_ChatGroupRemove = sdp.SdpStruct("Cmd_Push_ChatGroupRemove")
Cmd_Push_ChatGroupRemove.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_ChatGroupSetName = sdp.SdpStruct("Cmd_Push_ChatGroupSetName")
Cmd_Push_ChatGroupSetName.Definition = {
  "iGroupId",
  "sName",
  iGroupId = {
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
  }
}
Cmd_Push_Alliance_Transfer = sdp.SdpStruct("Cmd_Push_Alliance_Transfer")
Cmd_Push_Alliance_Transfer.Definition = {
  "stOldMaster",
  "stNewMaster",
  "bAuto",
  "iOldMasterPost",
  stOldMaster = {
    0,
    0,
    PlayerIDType,
    nil
  },
  stNewMaster = {
    1,
    0,
    PlayerIDType,
    nil
  },
  bAuto = {
    2,
    0,
    1,
    false
  },
  iOldMasterPost = {
    3,
    0,
    8,
    0
  }
}
Cmd_Push_Alliance_Destroy = sdp.SdpStruct("Cmd_Push_Alliance_Destroy")
Cmd_Push_Alliance_Destroy.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_AllianceMemberOnline = sdp.SdpStruct("Cmd_Push_AllianceMemberOnline")
Cmd_Push_AllianceMemberOnline.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_AllianceMemberOffline = sdp.SdpStruct("Cmd_Push_AllianceMemberOffline")
Cmd_Push_AllianceMemberOffline.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_Alliance_Levelup = sdp.SdpStruct("Cmd_Push_Alliance_Levelup")
Cmd_Push_Alliance_Levelup.Definition = {
  "iCurrLevel",
  iCurrLevel = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_JoinAllianceCount = sdp.SdpStruct("Cmd_Push_JoinAllianceCount")
Cmd_Push_JoinAllianceCount.Definition = {
  "iJoinAllianceCount",
  "iLastLeaveAllianceTime",
  iJoinAllianceCount = {
    0,
    0,
    8,
    0
  },
  iLastLeaveAllianceTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Alliance_SetDevelopment = sdp.SdpStruct("Cmd_Push_Alliance_SetDevelopment")
Cmd_Push_Alliance_SetDevelopment.Definition = {
  "iCurrDevelopment",
  iCurrDevelopment = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_FriendOnline = sdp.SdpStruct("Cmd_Push_FriendOnline")
Cmd_Push_FriendOnline.Definition = {
  "iRoleUid",
  "stRoleId",
  iRoleUid = {
    0,
    0,
    10,
    "0"
  },
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_FriendOffline = sdp.SdpStruct("Cmd_Push_FriendOffline")
Cmd_Push_FriendOffline.Definition = {
  "iRoleUid",
  "stRoleId",
  iRoleUid = {
    0,
    0,
    10,
    "0"
  },
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_Alliance_AddApplyMember = sdp.SdpStruct("Cmd_Push_Alliance_AddApplyMember")
Cmd_Push_Alliance_AddApplyMember.Definition = {
  "stRoleData",
  stRoleData = {
    0,
    0,
    CmdAllianceApplyerData,
    nil
  }
}
Cmd_Push_Alliance_DelApplyMember = sdp.SdpStruct("Cmd_Push_Alliance_DelApplyMember")
Cmd_Push_Alliance_DelApplyMember.Definition = {
  "stRoleId",
  "bHaveNewApply",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  bHaveNewApply = {
    1,
    0,
    1,
    false
  }
}
Cmd_Push_Notify_AllianceChat = sdp.SdpStruct("Cmd_Push_Notify_AllianceChat")
Cmd_Push_Notify_AllianceChat.Definition = {
  "stChatInfo",
  stChatInfo = {
    0,
    0,
    AllianceChatInfo,
    nil
  }
}
Cmd_Push_Alliance_BeInvite = sdp.SdpStruct("Cmd_Push_Alliance_BeInvite")
Cmd_Push_Alliance_BeInvite.Definition = {
  "iAllianceId",
  "stFromRole",
  "iPost",
  "iInviteTime",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  stFromRole = {
    1,
    0,
    PlayerIDType,
    nil
  },
  iPost = {
    2,
    0,
    8,
    0
  },
  iInviteTime = {
    3,
    0,
    8,
    0
  }
}
Cmd_Push_Alliance_SetMemberActive = sdp.SdpStruct("Cmd_Push_Alliance_SetMemberActive")
Cmd_Push_Alliance_SetMemberActive.Definition = {
  "stRoleId",
  "iAllianceActive",
  "iActive",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iAllianceActive = {
    1,
    0,
    8,
    0
  },
  iActive = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Chat_CreateNewPersonalChat = sdp.SdpStruct("Cmd_Push_Chat_CreateNewPersonalChat")
Cmd_Push_Chat_CreateNewPersonalChat.Definition = {
  "stPersonalChat",
  stPersonalChat = {
    0,
    0,
    CmdPersonalChatInitData,
    nil
  }
}
Cmd_Push_Chat_DelPersonalChat = sdp.SdpStruct("Cmd_Push_Chat_DelPersonalChat")
Cmd_Push_Chat_DelPersonalChat.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_Alliance_DelRoleApply = sdp.SdpStruct("Cmd_Push_Alliance_DelRoleApply")
Cmd_Push_Alliance_DelRoleApply.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_Notify_AllianceConfirm = sdp.SdpStruct("Cmd_Push_Notify_AllianceConfirm")
Cmd_Push_Notify_AllianceConfirm.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_Alliance_AddNewRecieveCard = sdp.SdpStruct("Cmd_Push_Alliance_AddNewRecieveCard")
Cmd_Push_Alliance_AddNewRecieveCard.Definition = {}
Cmd_Push_DelEquip = sdp.SdpStruct("Cmd_Push_DelEquip")
Cmd_Push_DelEquip.Definition = {
  "vEquipUid",
  vEquipUid = {
    0,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Push_EquipList = sdp.SdpStruct("Cmd_Push_EquipList")
Cmd_Push_EquipList.Definition = {
  "vEquipList",
  vEquipList = {
    0,
    0,
    sdp.SdpVector(CmdEquip),
    nil
  }
}
Cmd_Push_Alliance_SetTotalActive = sdp.SdpStruct("Cmd_Push_Alliance_SetTotalActive")
Cmd_Push_Alliance_SetTotalActive.Definition = {
  "iTotalActive",
  iTotalActive = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_NotifyAllianceMail = sdp.SdpStruct("Cmd_Push_NotifyAllianceMail")
Cmd_Push_NotifyAllianceMail.Definition = {
  "sContent",
  "sSenderName",
  "stSender",
  "bSys",
  "iTemplateId",
  "mTemplateParam",
  "vItems",
  sContent = {
    0,
    0,
    13,
    ""
  },
  sSenderName = {
    1,
    0,
    13,
    ""
  },
  stSender = {
    2,
    0,
    PlayerIDType,
    nil
  },
  bSys = {
    3,
    0,
    1,
    false
  },
  iTemplateId = {
    4,
    0,
    8,
    0
  },
  mTemplateParam = {
    5,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  vItems = {
    6,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Push_SetAllianceMailSendNum = sdp.SdpStruct("Cmd_Push_SetAllianceMailSendNum")
Cmd_Push_SetAllianceMailSendNum.Definition = {
  "iMailSendNum",
  iMailSendNum = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_RoomEnter = sdp.SdpStruct("Cmd_Push_RoomEnter")
Cmd_Push_RoomEnter.Definition = {
  "stPlayer",
  "stRoom",
  stPlayer = {
    0,
    0,
    PlayerIDType,
    nil
  },
  stRoom = {
    1,
    0,
    RoomInfo,
    nil
  }
}
Cmd_Push_RoomLeave = sdp.SdpStruct("Cmd_Push_RoomLeave")
Cmd_Push_RoomLeave.Definition = {
  "stPlayer",
  "stRoom",
  "sLeaveName",
  stPlayer = {
    0,
    0,
    PlayerIDType,
    nil
  },
  stRoom = {
    1,
    0,
    RoomInfo,
    nil
  },
  sLeaveName = {
    2,
    0,
    13,
    ""
  }
}
Cmd_Push_RoomInvite = sdp.SdpStruct("Cmd_Push_RoomInvite")
Cmd_Push_RoomInvite.Definition = {
  "iMatchType",
  "sName",
  "iRoomId",
  "iRet",
  iMatchType = {
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
  iRoomId = {
    2,
    0,
    10,
    "0"
  },
  iRet = {
    3,
    0,
    8,
    0
  }
}
Cmd_Push_RoomInviteResult = sdp.SdpStruct("Cmd_Push_RoomInviteResult")
Cmd_Push_RoomInviteResult.Definition = {
  "iRet",
  "sName",
  iRet = {
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
  }
}
Cmd_Push_RoomDiscard = sdp.SdpStruct("Cmd_Push_RoomDiscard")
Cmd_Push_RoomDiscard.Definition = {
  "iRoomId",
  iRoomId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Push_RoomKick = sdp.SdpStruct("Cmd_Push_RoomKick")
Cmd_Push_RoomKick.Definition = {
  "iRoomId",
  "stPlayer",
  iRoomId = {
    0,
    0,
    10,
    "0"
  },
  stPlayer = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Push_RoomChat = sdp.SdpStruct("Cmd_Push_RoomChat")
Cmd_Push_RoomChat.Definition = {
  "sSenderName",
  "sMessage",
  sSenderName = {
    0,
    0,
    13,
    ""
  },
  sMessage = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Push_EnterMatch = sdp.SdpStruct("Cmd_Push_EnterMatch")
Cmd_Push_EnterMatch.Definition = {
  "iMatchType",
  iMatchType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_EnterBattle = sdp.SdpStruct("Cmd_Push_EnterBattle")
Cmd_Push_EnterBattle.Definition = {
  "iRet",
  "iBattleUid",
  "sBattleIp",
  "iBattlePort",
  "sBattleProxy",
  "iProxyId",
  "iProxyPing",
  "sBattleConn",
  "iBattleServerId",
  "iMatchType",
  iRet = {
    0,
    0,
    8,
    0
  },
  iBattleUid = {
    1,
    0,
    10,
    "0"
  },
  sBattleIp = {
    2,
    0,
    13,
    ""
  },
  iBattlePort = {
    3,
    0,
    8,
    0
  },
  sBattleProxy = {
    4,
    0,
    13,
    ""
  },
  iProxyId = {
    5,
    0,
    8,
    0
  },
  iProxyPing = {
    6,
    0,
    8,
    0
  },
  sBattleConn = {
    7,
    0,
    13,
    ""
  },
  iBattleServerId = {
    8,
    0,
    8,
    0
  },
  iMatchType = {
    9,
    0,
    8,
    0
  }
}
Cmd_Push_BeginMultiFightTest = sdp.SdpStruct("Cmd_Push_BeginMultiFightTest")
Cmd_Push_BeginMultiFightTest.Definition = {
  "stMultiFightTestInfo",
  "stInput",
  stMultiFightTestInfo = {
    0,
    0,
    CmdMultiFightTestInfo,
    nil
  },
  stInput = {
    1,
    0,
    CmdFightVerifyInput,
    nil
  }
}
Cmd_Push_SystemOpen = sdp.SdpStruct("Cmd_Push_SystemOpen")
Cmd_Push_SystemOpen.Definition = {
  "vSystemId",
  vSystemId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_AfkLevel = sdp.SdpStruct("Cmd_Push_AfkLevel")
Cmd_Push_AfkLevel.Definition = {
  "iAfkLevel",
  "iAfkExp",
  iAfkLevel = {
    0,
    0,
    8,
    0
  },
  iAfkExp = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_DungeonChapterMop = sdp.SdpStruct("Cmd_Push_DungeonChapterMop")
Cmd_Push_DungeonChapterMop.Definition = {
  "iTimes",
  "mRotationLevelSubType",
  iTimes = {
    0,
    0,
    8,
    0
  },
  mRotationLevelSubType = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Push_PassStage = sdp.SdpStruct("Cmd_Push_PassStage")
Cmd_Push_PassStage.Definition = {
  "iStageType",
  "iStageSubType",
  "iStageId",
  "iFirstFinishTime",
  "iFinishNum",
  "iLastPassStageId",
  "iScore",
  "iTopScore",
  "iDamage",
  "iTopDamage",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageSubType = {
    1,
    0,
    8,
    0
  },
  iStageId = {
    2,
    0,
    8,
    0
  },
  iFirstFinishTime = {
    3,
    0,
    8,
    0
  },
  iFinishNum = {
    4,
    0,
    8,
    0
  },
  iLastPassStageId = {
    5,
    0,
    8,
    0
  },
  iScore = {
    6,
    0,
    8,
    0
  },
  iTopScore = {
    7,
    0,
    8,
    0
  },
  iDamage = {
    8,
    0,
    8,
    0
  },
  iTopDamage = {
    9,
    0,
    8,
    0
  }
}
Cmd_Push_SurveyStatus = sdp.SdpStruct("Cmd_Push_SurveyStatus")
Cmd_Push_SurveyStatus.Definition = {
  "iActivityId",
  "iIndexId",
  "iStatus",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
    1,
    0,
    8,
    0
  },
  iStatus = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_FormPower = sdp.SdpStruct("Cmd_Push_FormPower")
Cmd_Push_FormPower.Definition = {
  "mPresetPower",
  "mFormPower",
  mPresetPower = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mFormPower = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  }
}
Cmd_Push_InheritLevel = sdp.SdpStruct("Cmd_Push_InheritLevel")
Cmd_Push_InheritLevel.Definition = {
  "iLevel",
  "vMainHero",
  "bEvolve",
  iLevel = {
    0,
    0,
    8,
    0
  },
  vMainHero = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  bEvolve = {
    2,
    0,
    1,
    false
  }
}
Cmd_Push_StageTimes = sdp.SdpStruct("Cmd_Push_StageTimes")
Cmd_Push_StageTimes.Definition = {
  "iType",
  "iSubType",
  "iTimes",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  iTimes = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_FightingStage = sdp.SdpStruct("Cmd_Push_FightingStage")
Cmd_Push_FightingStage.Definition = {
  "iStageType",
  "iSubType",
  "iStageId",
  "iCurArea",
  "stPassthrough",
  "vFinishArea",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  iStageId = {
    2,
    0,
    8,
    0
  },
  iCurArea = {
    3,
    0,
    8,
    0
  },
  stPassthrough = {
    4,
    0,
    CmdFightPassthrough,
    nil
  },
  vFinishArea = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_OriginalArenaMineInfo = sdp.SdpStruct("Cmd_Push_OriginalArenaMineInfo")
Cmd_Push_OriginalArenaMineInfo.Definition = {
  "iSeasonId",
  "iGroupId",
  "iRank",
  "iScore",
  "iOldRank",
  "iOldScore",
  "iTicketFreeCount",
  iSeasonId = {
    0,
    0,
    8,
    0
  },
  iGroupId = {
    1,
    0,
    8,
    0
  },
  iRank = {
    2,
    0,
    8,
    0
  },
  iScore = {
    3,
    0,
    8,
    0
  },
  iOldRank = {
    4,
    0,
    8,
    0
  },
  iOldScore = {
    5,
    0,
    8,
    0
  },
  iTicketFreeCount = {
    6,
    0,
    8,
    0
  }
}
Cmd_Push_Notify_OriginalArenaReward = sdp.SdpStruct("Cmd_Push_Notify_OriginalArenaReward")
Cmd_Push_Notify_OriginalArenaReward.Definition = {
  "iType",
  "iSeasonId",
  "iGroupId",
  "vRewardItem",
  iType = {
    0,
    0,
    8,
    0
  },
  iSeasonId = {
    1,
    0,
    8,
    0
  },
  iGroupId = {
    2,
    0,
    8,
    0
  },
  vRewardItem = {
    3,
    0,
    sdp.SdpVector(CmdOriginalArenaRewardItem),
    nil
  }
}
Cmd_Push_Notify_SoloRaidReward = sdp.SdpStruct("Cmd_Push_Notify_SoloRaidReward")
Cmd_Push_Notify_SoloRaidReward.Definition = {
  "sRewardData",
  sRewardData = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Push_HeroAttract = sdp.SdpStruct("Cmd_Push_HeroAttract")
Cmd_Push_HeroAttract.Definition = {
  "stHeroAttract",
  stHeroAttract = {
    0,
    0,
    CmdHeroAttract,
    nil
  }
}
Cmd_Push_LegacyData = sdp.SdpStruct("Cmd_Push_LegacyData")
Cmd_Push_LegacyData.Definition = {
  "stLegacy",
  stLegacy = {
    0,
    0,
    CmdLegacy,
    nil
  }
}
Cmd_Push_Quest_AchieveScore = sdp.SdpStruct("Cmd_Push_Quest_AchieveScore")
Cmd_Push_Quest_AchieveScore.Definition = {
  "iScore",
  "iAddScore",
  "iQuestType",
  iScore = {
    0,
    0,
    8,
    0
  },
  iAddScore = {
    1,
    0,
    8,
    0
  },
  iQuestType = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_Castle_StatueLevel = sdp.SdpStruct("Cmd_Push_Castle_StatueLevel")
Cmd_Push_Castle_StatueLevel.Definition = {
  "iOldLevel",
  "iNewLevel",
  iOldLevel = {
    0,
    0,
    8,
    0
  },
  iNewLevel = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Lamia_Quest = sdp.SdpStruct("Cmd_Push_Lamia_Quest")
Cmd_Push_Lamia_Quest.Definition = {
  "iActId",
  "vQuest",
  iActId = {
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
  }
}
Cmd_Push_Lamia_Stage = sdp.SdpStruct("Cmd_Push_Lamia_Stage")
Cmd_Push_Lamia_Stage.Definition = {
  "iActId",
  "iSubActId",
  "stStage",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  },
  stStage = {
    2,
    0,
    LamiaStage,
    nil
  }
}
Cmd_Push_BaseStoreMonthlyCard = sdp.SdpStruct("Cmd_Push_BaseStoreMonthlyCard")
Cmd_Push_BaseStoreMonthlyCard.Definition = {
  "stMonthlyCard",
  stMonthlyCard = {
    0,
    0,
    CmdBaseStoreMonthlyCard,
    nil
  }
}
Cmd_Push_BaseStoreMonthlyCardRewardData = sdp.SdpStruct("Cmd_Push_BaseStoreMonthlyCardRewardData")
Cmd_Push_BaseStoreMonthlyCardRewardData.Definition = {
  "iCardId",
  "vReward",
  "iExpireTime",
  iCardId = {
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
  iExpireTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_BaseStoreMonthlyCardReward = sdp.SdpStruct("Cmd_Push_BaseStoreMonthlyCardReward")
Cmd_Push_BaseStoreMonthlyCardReward.Definition = {
  "vMonthlyCardReward",
  vMonthlyCardReward = {
    0,
    0,
    sdp.SdpVector(Cmd_Push_BaseStoreMonthlyCardRewardData),
    nil
  }
}
Cmd_Push_BaseStoreChapter = sdp.SdpStruct("Cmd_Push_BaseStoreChapter")
Cmd_Push_BaseStoreChapter.Definition = {
  "stChapter",
  stChapter = {
    0,
    0,
    CmdBaseStoreChapter,
    nil
  }
}
Cmd_Push_BaseStoreChapterReward = sdp.SdpStruct("Cmd_Push_BaseStoreChapterReward")
Cmd_Push_BaseStoreChapterReward.Definition = {
  "vFreeReward",
  "vPayReward",
  vFreeReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vPayReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Push_NewGift = sdp.SdpStruct("Cmd_Push_NewGift")
Cmd_Push_NewGift.Definition = {
  "iActivityID",
  "iGroupIndex",
  "vGiftIndex",
  "iExpireTime",
  "iSubProductID",
  "iStoreType",
  "iTriggerParam",
  "iTotalRecharge",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGroupIndex = {
    1,
    0,
    8,
    0
  },
  vGiftIndex = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iExpireTime = {
    3,
    0,
    8,
    0
  },
  iSubProductID = {
    4,
    0,
    8,
    0
  },
  iStoreType = {
    5,
    0,
    8,
    0
  },
  iTriggerParam = {
    6,
    0,
    8,
    0
  },
  iTotalRecharge = {
    7,
    0,
    8,
    0
  }
}
Cmd_Push_InheritGrid = sdp.SdpStruct("Cmd_Push_InheritGrid")
Cmd_Push_InheritGrid.Definition = {
  "mGrid",
  mGrid = {
    0,
    0,
    sdp.SdpMap(8, CmdInheritGrid),
    nil
  }
}
Cmd_Push_ReplaceArena_BattleEndUpdate = sdp.SdpStruct("Cmd_Push_ReplaceArena_BattleEndUpdate")
Cmd_Push_ReplaceArena_BattleEndUpdate.Definition = {
  "iRet",
  "iRank",
  "iOldRank",
  "vResult",
  "iFreeFightTimes",
  "stEnemyId",
  "stAfk",
  "iReplaceArenaPlaySeason",
  iRet = {
    0,
    0,
    8,
    0
  },
  iRank = {
    1,
    0,
    8,
    0
  },
  iOldRank = {
    2,
    0,
    8,
    0
  },
  vResult = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iFreeFightTimes = {
    4,
    0,
    8,
    0
  },
  stEnemyId = {
    5,
    0,
    PlayerIDType,
    nil
  },
  stAfk = {
    6,
    0,
    CmdReplaceArenaAfk,
    nil
  },
  iReplaceArenaPlaySeason = {
    7,
    0,
    8,
    0
  }
}
Cmd_Push_ReplaceArena_RankChange = sdp.SdpStruct("Cmd_Push_ReplaceArena_RankChange")
Cmd_Push_ReplaceArena_RankChange.Definition = {
  "iRank",
  "iOldRank",
  "stEnemyId",
  "bWin",
  "stAfk",
  iRank = {
    0,
    0,
    8,
    0
  },
  iOldRank = {
    1,
    0,
    8,
    0
  },
  stEnemyId = {
    2,
    0,
    PlayerIDType,
    nil
  },
  bWin = {
    3,
    0,
    1,
    false
  },
  stAfk = {
    4,
    0,
    CmdReplaceArenaAfk,
    nil
  }
}
Cmd_Push_ReplaceArena_NotifySeasonReward = sdp.SdpStruct("Cmd_Push_ReplaceArena_NotifySeasonReward")
Cmd_Push_ReplaceArena_NotifySeasonReward.Definition = {
  "iSeasonId",
  "iGroupId",
  "vReward",
  iSeasonId = {
    0,
    0,
    8,
    0
  },
  iGroupId = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdReplaceArenaSeasonReward),
    nil
  }
}
Cmd_Push_Castle_AddPlaceStory = sdp.SdpStruct("Cmd_Push_Castle_AddPlaceStory")
Cmd_Push_Castle_AddPlaceStory.Definition = {
  "mAddStory",
  mAddStory = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Push_SoloRaid_FinishRaid = sdp.SdpStruct("Cmd_Push_SoloRaid_FinishRaid")
Cmd_Push_SoloRaid_FinishRaid.Definition = {
  "stSoloRaid",
  "bPass",
  "bFirstPass",
  "vReward",
  "iNormalTimes",
  "iHardTimes",
  stSoloRaid = {
    0,
    0,
    CmdSoloRaid,
    nil
  },
  bPass = {
    1,
    0,
    1,
    false
  },
  bFirstPass = {
    2,
    0,
    1,
    false
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iNormalTimes = {
    4,
    0,
    8,
    0
  },
  iHardTimes = {
    5,
    0,
    8,
    0
  }
}
Cmd_Push_SoloRaid_CurRaid = sdp.SdpStruct("Cmd_Push_SoloRaid_CurRaid")
Cmd_Push_SoloRaid_CurRaid.Definition = {
  "stCurRaid",
  stCurRaid = {
    0,
    0,
    CmdSoloRaidChallenge,
    nil
  }
}
Cmd_Push_SoloRaid_RankUpdate = sdp.SdpStruct("Cmd_Push_SoloRaid_RankUpdate")
Cmd_Push_SoloRaid_RankUpdate.Definition = {
  "iActivityId",
  "iDamage",
  "iOldRank",
  "iNewRank",
  "iRankSize",
  "iRaidId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iDamage = {
    1,
    0,
    10,
    "0"
  },
  iOldRank = {
    2,
    0,
    8,
    0
  },
  iNewRank = {
    3,
    0,
    8,
    0
  },
  iRankSize = {
    4,
    0,
    8,
    0
  },
  iRaidId = {
    5,
    0,
    8,
    0
  }
}
Cmd_Push_LegacyStage = sdp.SdpStruct("Cmd_Push_LegacyStage")
Cmd_Push_LegacyStage.Definition = {
  "vGameLevelId",
  vGameLevelId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Push_Hero_AddFashion = sdp.SdpStruct("Cmd_Push_Hero_AddFashion")
Cmd_Push_Hero_AddFashion.Definition = {
  "iFashionId",
  "bSame",
  iFashionId = {
    0,
    0,
    8,
    0
  },
  bSame = {
    1,
    0,
    1,
    false
  }
}
Cmd_Push_Castle_AddDispatch = sdp.SdpStruct("Cmd_Push_Castle_AddDispatch")
Cmd_Push_Castle_AddDispatch.Definition = {
  "mEvent",
  mEvent = {
    0,
    0,
    sdp.SdpMap(8, CmdDispatchEvent),
    nil
  }
}
Cmd_Push_SetUniqueItem = sdp.SdpStruct("Cmd_Push_SetUniqueItem")
Cmd_Push_SetUniqueItem.Definition = {
  "iItemId",
  "iExpireTime",
  "bDelete",
  iItemId = {
    0,
    0,
    8,
    0
  },
  iExpireTime = {
    1,
    0,
    8,
    0
  },
  bDelete = {
    2,
    0,
    1,
    false
  }
}
Cmd_Push_NewActivityPickupGift = sdp.SdpStruct("Cmd_Push_NewActivityPickupGift")
Cmd_Push_NewActivityPickupGift.Definition = {
  "iActivityId",
  "iGiftId",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iGiftId = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Push_AllianceBattle_NewRound = sdp.SdpStruct("Cmd_Push_AllianceBattle_NewRound")
Cmd_Push_AllianceBattle_NewRound.Definition = {
  "iActivityId",
  "iBattleId",
  "iRound",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBattleId = {
    1,
    0,
    8,
    0
  },
  iRound = {
    2,
    0,
    8,
    0
  }
}
Cmd_Push_UploadFlog = sdp.SdpStruct("Cmd_Push_UploadFlog")
Cmd_Push_UploadFlog.Definition = {
  "iLogLevel",
  iLogLevel = {
    0,
    0,
    8,
    0
  }
}
Cmd_Push_GM_DailyRefresh = sdp.SdpStruct("Cmd_Push_GM_DailyRefresh")
Cmd_Push_GM_DailyRefresh.Definition = {}
Cmd_Push_NewRankTarget = sdp.SdpStruct("Cmd_Push_NewRankTarget")
Cmd_Push_NewRankTarget.Definition = {
  "iRankType",
  "iTargetId",
  iRankType = {
    0,
    0,
    8,
    0
  },
  iTargetId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Push_Rogue_FinishChallenge = sdp.SdpStruct("Cmd_Push_Rogue_FinishChallenge")
Cmd_Push_Rogue_FinishChallenge.Definition = {
  "iStageId",
  "iLevelId",
  "stStage",
  "iCurStage",
  "vNewHandbook",
  "iScore",
  "iRewardLevel",
  "iDailyReward",
  "bPass",
  "bFirstPass",
  iStageId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  },
  stStage = {
    2,
    0,
    CmdRogueStage,
    nil
  },
  iCurStage = {
    3,
    0,
    8,
    0
  },
  vNewHandbook = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  iScore = {
    5,
    0,
    8,
    0
  },
  iRewardLevel = {
    6,
    0,
    8,
    0
  },
  iDailyReward = {
    7,
    0,
    8,
    0
  },
  bPass = {
    8,
    0,
    1,
    false
  },
  bFirstPass = {
    9,
    0,
    1,
    false
  }
}
Cmd_Push_Hunting_Boss = sdp.SdpStruct("Cmd_Push_Hunting_Boss")
Cmd_Push_Hunting_Boss.Definition = {
  "iActivityId",
  "iBossId",
  "iDamage",
  "iCurDamage",
  "stBoss",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBossId = {
    1,
    0,
    8,
    0
  },
  iDamage = {
    2,
    0,
    10,
    "0"
  },
  iCurDamage = {
    3,
    0,
    10,
    "0"
  },
  stBoss = {
    4,
    0,
    CmdHuntingBoss,
    nil
  }
}
Cmd_Push_Alliance_Battle_Boss = sdp.SdpStruct("Cmd_Push_Alliance_Battle_Boss")
Cmd_Push_Alliance_Battle_Boss.Definition = {
  "iActivityId",
  "iRound",
  "iBossId",
  "iDamage",
  "iRealDamage",
  "iBossHp",
  "bKill",
  "iChallengeTimes",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iRound = {
    1,
    0,
    8,
    0
  },
  iBossId = {
    2,
    0,
    8,
    0
  },
  iDamage = {
    3,
    0,
    10,
    "0"
  },
  iRealDamage = {
    4,
    0,
    10,
    "0"
  },
  iBossHp = {
    5,
    0,
    10,
    "0"
  },
  bKill = {
    6,
    0,
    1,
    false
  },
  iChallengeTimes = {
    7,
    0,
    8,
    0
  }
}
Cmd_Push_Notify_HuntingRankReward = sdp.SdpStruct("Cmd_Push_Notify_HuntingRankReward")
Cmd_Push_Notify_HuntingRankReward.Definition = {
  "sRewardData",
  sRewardData = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Push_Hunting_RankUpdate = sdp.SdpStruct("Cmd_Push_Hunting_RankUpdate")
Cmd_Push_Hunting_RankUpdate.Definition = {
  "iActivityId",
  "iGroupId",
  "iBossId",
  "iDamage",
  "iNewRank",
  "iRankSize",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iGroupId = {
    1,
    0,
    8,
    0
  },
  iBossId = {
    2,
    0,
    8,
    0
  },
  iDamage = {
    3,
    0,
    8,
    0
  },
  iNewRank = {
    4,
    0,
    8,
    0
  },
  iRankSize = {
    5,
    0,
    8,
    0
  }
}
