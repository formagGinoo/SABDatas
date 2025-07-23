local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameRole")
require("ProtoGameQuest")
require("ProtoGameGacha")
require("ProtoGameAlliance")
require("ProtoGameStage")
require("ProtoGameMail")
require("ProtoGameClientData")
require("ProtoGameItem")
require("ProtoGameHero")
require("ProtoGameEquip")
require("ProtoGameGuide")
require("ProtoGamePush")
require("ProtoGameAncient")
module("MTTDProto")
CmdId_Merge_GetInitMust_CS = 15601
CmdId_Merge_GetInitMust_SC = 15602
CmdId_Merge_GetInit_CS = 15603
CmdId_Merge_GetInit_SC = 15604
Cmd_Merge_GetInitMust_CS = sdp.SdpStruct("Cmd_Merge_GetInitMust_CS")
Cmd_Merge_GetInitMust_CS.Definition = {}
Cmd_Merge_GetInitMust_SC = sdp.SdpStruct("Cmd_Merge_GetInitMust_SC")
Cmd_Merge_GetInitMust_SC.Definition = {
  "stNotice",
  "stItem",
  "stHero",
  "mQuest",
  "mStage",
  "stClientData",
  "stEquip",
  "stFormPreset",
  "stGuide",
  "stInherit",
  "stFighting",
  "stAttract",
  "stQuestInit",
  "stStarRoom",
  "stAncient",
  stNotice = {
    0,
    0,
    Cmd_Role_GetNotice_SC,
    nil
  },
  stItem = {
    1,
    0,
    Cmd_Item_GetList_SC,
    nil
  },
  stHero = {
    2,
    0,
    Cmd_Hero_GetList_SC,
    nil
  },
  mQuest = {
    3,
    0,
    sdp.SdpMap(8, Cmd_Quest_GetList_SC),
    nil
  },
  mStage = {
    4,
    0,
    sdp.SdpMap(8, Cmd_Stage_GetList_SC),
    nil
  },
  stClientData = {
    5,
    0,
    Cmd_ClientData_GetData_SC,
    nil
  },
  stEquip = {
    6,
    0,
    Cmd_Equip_GetList_SC,
    nil
  },
  stFormPreset = {
    7,
    0,
    Cmd_Form_GetPreset_SC,
    nil
  },
  stGuide = {
    8,
    0,
    Cmd_Guide_GetGuide_SC,
    nil
  },
  stInherit = {
    9,
    0,
    Cmd_Inherit_GetData_SC,
    nil
  },
  stFighting = {
    10,
    0,
    Cmd_Push_FightingStage,
    nil
  },
  stAttract = {
    11,
    0,
    Cmd_Attract_GetAttract_SC,
    nil
  },
  stQuestInit = {
    12,
    0,
    Cmd_Quest_GetInit_SC,
    nil
  },
  stStarRoom = {
    13,
    0,
    Cmd_Castle_GetStarRoom_SC,
    nil
  },
  stAncient = {
    14,
    0,
    Cmd_Ancient_GetData_SC,
    nil
  }
}
Cmd_Merge_GetInit_CS = sdp.SdpStruct("Cmd_Merge_GetInit_CS")
Cmd_Merge_GetInit_CS.Definition = {
  "stOtherProgress",
  stOtherProgress = {
    0,
    0,
    Cmd_Role_GetOtherProgress_CS,
    nil
  }
}
Cmd_Merge_GetInit_SC = sdp.SdpStruct("Cmd_Merge_GetInit_SC")
Cmd_Merge_GetInit_SC.Definition = {
  "stOtherProgress",
  stOtherProgress = {
    0,
    0,
    Cmd_Role_GetOtherProgress_SC,
    nil
  }
}
