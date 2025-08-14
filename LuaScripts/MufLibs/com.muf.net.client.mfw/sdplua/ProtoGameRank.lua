local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Rank_GetList_CS = 11301
CmdId_Rank_GetList_SC = 11302
CmdId_Rank_GetRank_CS = 11303
CmdId_Rank_GetRank_SC = 11304
CmdId_Rank_GetRole_CS = 11305
CmdId_Rank_GetRole_SC = 11306
CmdId_Rank_DrawTargetReward_CS = 11307
CmdId_Rank_DrawTargetReward_SC = 11308
CmdId_Rank_GetTargetRank_CS = 11309
CmdId_Rank_GetTargetRank_SC = 11310
CmdRankType_MainStage = 1001
CmdRankType_MainHardStage = 1002
CmdRankType_HeroCamp1 = 2001
CmdRankType_HeroCamp2 = 2002
CmdRankType_HeroCamp3 = 2003
CmdRankType_HeroCamp4 = 2004
CmdRankType_TowerStageMain = 3001
CmdRankType_TowerStageTribe1 = 3002
CmdRankType_TowerStageTribe2 = 3003
CmdRankType_TowerStageTribe3 = 3004
CmdRankType_TowerStageTribe4 = 3005
Cmd_Rank_GetList_CS = sdp.SdpStruct("Cmd_Rank_GetList_CS")
Cmd_Rank_GetList_CS.Definition = {}
Cmd_Rank_GetList_SC = sdp.SdpStruct("Cmd_Rank_GetList_SC")
Cmd_Rank_GetList_SC.Definition = {
  "mRankTopRole",
  "mvDrawnTargetReward",
  "mCollectRankNum",
  "mmTargetRankTopRole",
  mRankTopRole = {
    0,
    0,
    sdp.SdpMap(8, CmdRankRoleItem),
    nil
  },
  mvDrawnTargetReward = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  },
  mCollectRankNum = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mmTargetRankTopRole = {
    3,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, CmdRankRoleItem)),
    nil
  }
}
Cmd_Rank_GetRank_CS = sdp.SdpStruct("Cmd_Rank_GetRank_CS")
Cmd_Rank_GetRank_CS.Definition = {
  "iRankType",
  iRankType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Rank_GetRank_SC = sdp.SdpStruct("Cmd_Rank_GetRank_SC")
Cmd_Rank_GetRank_SC.Definition = {
  "vRankRole",
  "iSelfValue",
  vRankRole = {
    0,
    0,
    sdp.SdpVector(CmdRankRoleItem),
    nil
  },
  iSelfValue = {
    1,
    0,
    8,
    0
  }
}
Cmd_Rank_GetRole_CS = sdp.SdpStruct("Cmd_Rank_GetRole_CS")
Cmd_Rank_GetRole_CS.Definition = {
  "iRankType",
  "iRoleId",
  iRankType = {
    0,
    0,
    8,
    0
  },
  iRoleId = {
    1,
    0,
    10,
    "0"
  }
}
Cmd_Rank_GetRole_SC = sdp.SdpStruct("Cmd_Rank_GetRole_SC")
Cmd_Rank_GetRole_SC.Definition = {
  "iPower",
  "vHero",
  iPower = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(CmdHeroBriefData),
    nil
  }
}
Cmd_Rank_DrawTargetReward_CS = sdp.SdpStruct("Cmd_Rank_DrawTargetReward_CS")
Cmd_Rank_DrawTargetReward_CS.Definition = {
  "iRankType",
  "vTargetId",
  iRankType = {
    0,
    0,
    8,
    0
  },
  vTargetId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Rank_DrawTargetReward_SC = sdp.SdpStruct("Cmd_Rank_DrawTargetReward_SC")
Cmd_Rank_DrawTargetReward_SC.Definition = {
  "vReward",
  "mvDrawnTargetReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  mvDrawnTargetReward = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  }
}
Cmd_Rank_GetTargetRank_CS = sdp.SdpStruct("Cmd_Rank_GetTargetRank_CS")
Cmd_Rank_GetTargetRank_CS.Definition = {
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
Cmd_Rank_GetTargetRank_SC = sdp.SdpStruct("Cmd_Rank_GetTargetRank_SC")
Cmd_Rank_GetTargetRank_SC.Definition = {
  "vRankRole",
  vRankRole = {
    0,
    0,
    sdp.SdpVector(CmdRankRoleItem),
    nil
  }
}
