local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Rogue_GetData_CS = 14351
CmdId_Rogue_GetData_SC = 14352
CmdId_Rogue_UnlockTech_CS = 14353
CmdId_Rogue_UnlockTech_SC = 14354
CmdId_Rogue_TakeReward_CS = 14355
CmdId_Rogue_TakeReward_SC = 14356
RogueTechEffect_HeroModify = 1
RogueTechEffect_InitGrid = 2
RogueTechEffect_FightHeroNum = 3
RogueTechEffect_UnlockItem = 4
RogueTechEffect_AddProperty = 5
RogueTechEffect_TempBag = 6
CmdRogueStage = sdp.SdpStruct("CmdRogueStage")
CmdRogueStage.Definition = {
  "iStageId",
  "iPassTimes",
  "iDailyLevel",
  "mDailyMonster",
  iStageId = {
    0,
    0,
    8,
    0
  },
  iPassTimes = {
    1,
    0,
    8,
    0
  },
  iDailyLevel = {
    2,
    0,
    8,
    0
  },
  mDailyMonster = {
    3,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  }
}
CmdRogue = sdp.SdpStruct("CmdRogue")
CmdRogue.Definition = {
  "mStage",
  "iDailyReward",
  "iTakenReward",
  "mTech",
  "mHandbook",
  "iCurStage",
  mStage = {
    0,
    0,
    sdp.SdpMap(8, CmdRogueStage),
    nil
  },
  iDailyReward = {
    1,
    0,
    8,
    0
  },
  iTakenReward = {
    2,
    0,
    8,
    0
  },
  mTech = {
    3,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mHandbook = {
    4,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iCurStage = {
    5,
    0,
    8,
    0
  }
}
Cmd_Rogue_GetData_CS = sdp.SdpStruct("Cmd_Rogue_GetData_CS")
Cmd_Rogue_GetData_CS.Definition = {}
Cmd_Rogue_GetData_SC = sdp.SdpStruct("Cmd_Rogue_GetData_SC")
Cmd_Rogue_GetData_SC.Definition = {
  "stRogue",
  stRogue = {
    0,
    0,
    CmdRogue,
    nil
  }
}
Cmd_Rogue_UnlockTech_CS = sdp.SdpStruct("Cmd_Rogue_UnlockTech_CS")
Cmd_Rogue_UnlockTech_CS.Definition = {
  "iTechId",
  iTechId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Rogue_UnlockTech_SC = sdp.SdpStruct("Cmd_Rogue_UnlockTech_SC")
Cmd_Rogue_UnlockTech_SC.Definition = {
  "iTechId",
  "iUnlockTime",
  iTechId = {
    0,
    0,
    8,
    0
  },
  iUnlockTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Rogue_TakeReward_CS = sdp.SdpStruct("Cmd_Rogue_TakeReward_CS")
Cmd_Rogue_TakeReward_CS.Definition = {}
Cmd_Rogue_TakeReward_SC = sdp.SdpStruct("Cmd_Rogue_TakeReward_SC")
Cmd_Rogue_TakeReward_SC.Definition = {
  "iTakenReward",
  "vReward",
  "vActivityReward",
  iTakenReward = {
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
  vActivityReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
