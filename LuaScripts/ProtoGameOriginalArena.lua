local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_OriginalArena_GetInit_CS = 19051
CmdId_OriginalArena_GetInit_SC = 19052
CmdId_OriginalArena_RefreshEnemy_CS = 19053
CmdId_OriginalArena_RefreshEnemy_SC = 19054
CmdId_OriginalArena_GetEnemyDetail_CS = 19055
CmdId_OriginalArena_GetEnemyDetail_SC = 19056
CmdId_OriginalArena_RankList_CS = 19057
CmdId_OriginalArena_RankList_SC = 19058
CmdId_OriginalArena_TakeSeasonReward_CS = 19059
CmdId_OriginalArena_TakeSeasonReward_SC = 19060
CmdId_OriginalArena_GetArenaReport_CS = 19061
CmdId_OriginalArena_GetArenaReport_SC = 19062
CmdId_OriginalArena_BuyTicket_CS = 19063
CmdId_OriginalArena_BuyTicket_SC = 19064
GetProfileType_Init = 1
GetProfileType_RefreshEnemy = 2
OriginalArenaRewardType_Daily = 1
OriginalArenaRewardType_Season = 2
CmdOriginalArenaMineInfo = sdp.SdpStruct("CmdOriginalArenaMineInfo")
CmdOriginalArenaMineInfo.Definition = {
  "iSeasonId",
  "iGroupId",
  "iScore",
  "iRank",
  "iEndTime",
  "iTicketBuyCount",
  "iTicketFreeCount",
  "iLastRefreshTime",
  "iCurEndTime",
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
  iScore = {
    2,
    0,
    8,
    0
  },
  iRank = {
    3,
    0,
    8,
    0
  },
  iEndTime = {
    4,
    0,
    8,
    0
  },
  iTicketBuyCount = {
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
  },
  iLastRefreshTime = {
    7,
    0,
    8,
    0
  },
  iCurEndTime = {
    8,
    0,
    8,
    0
  }
}
CmdOriginalArenaEnemy = sdp.SdpStruct("CmdOriginalArenaEnemy")
CmdOriginalArenaEnemy.Definition = {
  "stRoleSimpleInfo",
  "iScore",
  stRoleSimpleInfo = {
    0,
    0,
    _G.MTTDProto.CmdRoleSimpleInfo,
    nil
  },
  iScore = {
    1,
    0,
    8,
    0
  }
}
CmdOriginalArenaRankItem = sdp.SdpStruct("CmdOriginalArenaRankItem")
CmdOriginalArenaRankItem.Definition = {
  "stRole",
  "iRank",
  "iScore",
  stRole = {
    0,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  iRank = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    8,
    0
  }
}
CmdOriginalArenaRewardItem = sdp.SdpStruct("CmdOriginalArenaRewardItem")
CmdOriginalArenaRewardItem.Definition = {
  "stRoleId",
  "iRank",
  "iScore",
  "iRankId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iRank = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    8,
    0
  },
  iRankId = {
    3,
    0,
    8,
    0
  }
}
CmdOriginalArenaFightRecord = sdp.SdpStruct("CmdOriginalArenaFightRecord")
CmdOriginalArenaFightRecord.Definition = {
  "stEnemy",
  "bIsAttacker",
  "bWin",
  "iMyOldScore",
  "iMyNewScore",
  "iEnemyOldScore",
  "iEnemyNewScore",
  "iMyOldRank",
  "iMyNewRank",
  "iEnemyOldRank",
  "iEnemyNewRank",
  "iTime",
  stEnemy = {
    0,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  bIsAttacker = {
    1,
    0,
    8,
    0
  },
  bWin = {
    2,
    0,
    8,
    0
  },
  iMyOldScore = {
    3,
    0,
    8,
    0
  },
  iMyNewScore = {
    4,
    0,
    8,
    0
  },
  iEnemyOldScore = {
    5,
    0,
    8,
    0
  },
  iEnemyNewScore = {
    6,
    0,
    8,
    0
  },
  iMyOldRank = {
    7,
    0,
    8,
    0
  },
  iMyNewRank = {
    8,
    0,
    8,
    0
  },
  iEnemyOldRank = {
    9,
    0,
    8,
    0
  },
  iEnemyNewRank = {
    10,
    0,
    8,
    0
  },
  iTime = {
    11,
    0,
    8,
    0
  }
}
CmdOriginalArenaEnemyDetail = sdp.SdpStruct("CmdOriginalArenaEnemyDetail")
CmdOriginalArenaEnemyDetail.Definition = {
  "stRoleSimpleInfo",
  "mCmdHero",
  "stForm",
  stRoleSimpleInfo = {
    0,
    0,
    _G.MTTDProto.CmdRoleSimpleInfo,
    nil
  },
  mCmdHero = {
    1,
    0,
    sdp.SdpMap(8, _G.MTTDProto.CmdHeroData),
    nil
  },
  stForm = {
    2,
    0,
    _G.MTTDProto.CmdForm,
    nil
  }
}
Cmd_OriginalArena_GetInit_CS = sdp.SdpStruct("Cmd_OriginalArena_GetInit_CS")
Cmd_OriginalArena_GetInit_CS.Definition = {}
Cmd_OriginalArena_GetInit_SC = sdp.SdpStruct("Cmd_OriginalArena_GetInit_SC")
Cmd_OriginalArena_GetInit_SC.Definition = {
  "stMine",
  "mEnemy",
  stMine = {
    0,
    0,
    CmdOriginalArenaMineInfo,
    nil
  },
  mEnemy = {
    1,
    0,
    sdp.SdpMap(8, CmdOriginalArenaEnemy),
    nil
  }
}
Cmd_OriginalArena_RefreshEnemy_CS = sdp.SdpStruct("Cmd_OriginalArena_RefreshEnemy_CS")
Cmd_OriginalArena_RefreshEnemy_CS.Definition = {
  "bFreeRefresh",
  bFreeRefresh = {
    0,
    0,
    1,
    false
  }
}
Cmd_OriginalArena_RefreshEnemy_SC = sdp.SdpStruct("Cmd_OriginalArena_RefreshEnemy_SC")
Cmd_OriginalArena_RefreshEnemy_SC.Definition = {
  "mEnemy",
  "iLastRefreshTime",
  mEnemy = {
    0,
    0,
    sdp.SdpMap(8, CmdOriginalArenaEnemy),
    nil
  },
  iLastRefreshTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_OriginalArena_GetEnemyDetail_CS = sdp.SdpStruct("Cmd_OriginalArena_GetEnemyDetail_CS")
Cmd_OriginalArena_GetEnemyDetail_CS.Definition = {
  "iEnemyId",
  iEnemyId = {
    0,
    0,
    8,
    0
  }
}
Cmd_OriginalArena_GetEnemyDetail_SC = sdp.SdpStruct("Cmd_OriginalArena_GetEnemyDetail_SC")
Cmd_OriginalArena_GetEnemyDetail_SC.Definition = {
  "stEnemyDetail",
  stEnemyDetail = {
    0,
    0,
    CmdOriginalArenaEnemyDetail,
    nil
  }
}
Cmd_OriginalArena_RankList_CS = sdp.SdpStruct("Cmd_OriginalArena_RankList_CS")
Cmd_OriginalArena_RankList_CS.Definition = {
  "iBeginRank",
  "iEndRank",
  iBeginRank = {
    0,
    0,
    8,
    0
  },
  iEndRank = {
    1,
    0,
    8,
    0
  }
}
Cmd_OriginalArena_RankList_SC = sdp.SdpStruct("Cmd_OriginalArena_RankList_SC")
Cmd_OriginalArena_RankList_SC.Definition = {
  "vRankList",
  "iMyRank",
  "iMyScore",
  "iMyPower",
  vRankList = {
    0,
    0,
    sdp.SdpVector(CmdOriginalArenaRankItem),
    nil
  },
  iMyRank = {
    1,
    0,
    8,
    0
  },
  iMyScore = {
    2,
    0,
    8,
    0
  },
  iMyPower = {
    3,
    0,
    8,
    0
  }
}
Cmd_OriginalArena_TakeSeasonReward_CS = sdp.SdpStruct("Cmd_OriginalArena_TakeSeasonReward_CS")
Cmd_OriginalArena_TakeSeasonReward_CS.Definition = {}
Cmd_OriginalArena_TakeSeasonReward_SC = sdp.SdpStruct("Cmd_OriginalArena_TakeSeasonReward_SC")
Cmd_OriginalArena_TakeSeasonReward_SC.Definition = {
  "vRewards",
  vRewards = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_OriginalArena_GetArenaReport_CS = sdp.SdpStruct("Cmd_OriginalArena_GetArenaReport_CS")
Cmd_OriginalArena_GetArenaReport_CS.Definition = {}
Cmd_OriginalArena_GetArenaReport_SC = sdp.SdpStruct("Cmd_OriginalArena_GetArenaReport_SC")
Cmd_OriginalArena_GetArenaReport_SC.Definition = {
  "vRecord",
  vRecord = {
    0,
    0,
    sdp.SdpVector(CmdOriginalArenaFightRecord),
    nil
  }
}
Cmd_OriginalArena_BuyTicket_CS = sdp.SdpStruct("Cmd_OriginalArena_BuyTicket_CS")
Cmd_OriginalArena_BuyTicket_CS.Definition = {}
Cmd_OriginalArena_BuyTicket_SC = sdp.SdpStruct("Cmd_OriginalArena_BuyTicket_SC")
Cmd_OriginalArena_BuyTicket_SC.Definition = {
  "iTicketBuyCount",
  iTicketBuyCount = {
    0,
    0,
    8,
    0
  }
}
