local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
ActCfgNewDirectPushGiftType_Null = 0
ActCfgNewDirectPushGiftType_Battle = 1
ActCfgNewDirectPushGiftType_Tower = 2
ActCfgNewDirectPushGiftType_RoleLevel = 3
ActCfgNewDirectPushGiftType_InheritLevel = 4
ActCfgNewDirectPushGiftType_AKX = 5
ActCfgNewDirectPushGiftType_CampTower = 6
ActCfgNewDirectPushGiftType_ActBoss = 7
ActCfgNewDirectPushGiftType_BattleBoss = 8
ActCfgNewDirectPushGiftType_EndlessDungeon = 9
ActCfgNewDirectPushGiftType_TimeArena = 10
ActCfgNewDirectPushGiftType_GlobalArena = 12
ActCfgNewDirectPushGiftType_BlueRoute = 13
ActCfgNewDirectPushGiftType_StarLife = 14
ActCfgNewDirectPushGiftType_SeasonLineMain = 15
ActCfgNewDirectPushGiftType_SeasonLineSub = 16
ActCfgNewDirectPushGiftType_SeasonLineGod = 17
ActCfgNewDirectPushGiftType_RichJourneyUnlock = 18
ActCfgNewDirectPushGiftType_RichJourneySightHot = 19
ActCfgNewDirectPushGiftType_RabbitGirl = 21
ActCfgNewDirectPushGiftType_ClaradeCo = 22
ActCfgNewDirectPushGiftType_AncientArea = 23
ActCfgNewDirectPushGiftType_GloryEvolution = 24
ActCfgNewDirectPushGiftType_GM = 25
ActCfgNewDirectPushGiftType_MAX = ActCfgNewDirectPushGiftType_GM + 1
CmdActNewDirectPushGift = sdp.SdpStruct("CmdActNewDirectPushGift")
CmdActNewDirectPushGift.Definition = {
  "sProductId",
  "iProductSubId",
  "iGiftEndTime",
  "iLeftBuyTimes",
  "sDiscount",
  "sHeroBackground",
  "iGiftType",
  "iCondId",
  "sBuyReason",
  "bDirectPop",
  "iGiftId",
  "vItem",
  "bNewStyle",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iProductSubId = {
    1,
    0,
    8,
    0
  },
  iGiftEndTime = {
    2,
    0,
    8,
    0
  },
  iLeftBuyTimes = {
    3,
    0,
    8,
    0
  },
  sDiscount = {
    4,
    0,
    13,
    ""
  },
  sHeroBackground = {
    5,
    0,
    13,
    ""
  },
  iGiftType = {
    6,
    0,
    8,
    0
  },
  iCondId = {
    7,
    0,
    8,
    0
  },
  sBuyReason = {
    8,
    0,
    13,
    ""
  },
  bDirectPop = {
    9,
    0,
    1,
    false
  },
  iGiftId = {
    10,
    0,
    8,
    0
  },
  vItem = {
    11,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  bNewStyle = {
    12,
    0,
    1,
    false
  }
}
CmdActNewDirectPushGift_Status = sdp.SdpStruct("CmdActNewDirectPushGift_Status")
CmdActNewDirectPushGift_Status.Definition = {
  "vAllGift",
  vAllGift = {
    0,
    0,
    sdp.SdpVector(CmdActNewDirectPushGift),
    nil
  }
}
