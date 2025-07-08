local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_ReplaceArena_GetInit_CS = 12401
CmdId_ReplaceArena_GetInit_SC = 12402
CmdId_ReplaceArena_RefreshEnemy_CS = 12403
CmdId_ReplaceArena_RefreshEnemy_SC = 12404
CmdId_ReplaceArena_GetEnemyDetail_CS = 12405
CmdId_ReplaceArena_GetEnemyDetail_SC = 12406
CmdId_ReplaceArena_GetRankList_CS = 12407
CmdId_ReplaceArena_GetRankList_SC = 12408
CmdId_ReplaceArena_BuyTicket_CS = 12409
CmdId_ReplaceArena_BuyTicket_SC = 12410
CmdId_ReplaceArena_SeeAfk_CS = 12411
CmdId_ReplaceArena_SeeAfk_SC = 12412
CmdId_ReplaceArena_TakeAfk_CS = 12413
CmdId_ReplaceArena_TakeAfk_SC = 12414
CmdId_ReplaceArena_GetBattleRecord_CS = 12415
CmdId_ReplaceArena_GetBattleRecord_SC = 12416
ReplaceArenaRankType_GradeRank = 1
ReplaceArenaRankType_ScoreRank = 2
CmdReplaceArenaMineInfo = sdp.SdpStruct("CmdReplaceArenaMineInfo")
CmdReplaceArenaMineInfo.Definition = {
  "iSeasonId",
  "iGroupId",
  "iRegroupIndex",
  "iGradeRank",
  "iFreeFightTimes",
  "iLastRefreshTime",
  "iReplaceArenaPlaySeason",
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
  iRegroupIndex = {
    2,
    0,
    8,
    0
  },
  iGradeRank = {
    3,
    0,
    8,
    0
  },
  iFreeFightTimes = {
    4,
    0,
    8,
    0
  },
  iLastRefreshTime = {
    5,
    0,
    8,
    0
  },
  iReplaceArenaPlaySeason = {
    6,
    0,
    8,
    0
  }
}
CmdReplaceArenaForm = sdp.SdpStruct("CmdReplaceArenaForm")
CmdReplaceArenaForm.Definition = {
  "mCmdHero",
  "stForm",
  mCmdHero = {
    0,
    0,
    sdp.SdpMap(8, _G.MTTDProto.CmdHeroData),
    nil
  },
  stForm = {
    1,
    0,
    _G.MTTDProto.CmdForm,
    nil
  }
}
CmdReplaceArenaEnemyDetail = sdp.SdpStruct("CmdReplaceArenaEnemyDetail")
CmdReplaceArenaEnemyDetail.Definition = {
  "stRoleSimple",
  "mBattleForm",
  stRoleSimple = {
    0,
    0,
    _G.MTTDProto.CmdRoleSimpleInfo,
    nil
  },
  mBattleForm = {
    1,
    0,
    sdp.SdpMap(8, CmdReplaceArenaForm),
    nil
  }
}
CmdReplaceArenaRankItem = sdp.SdpStruct("CmdReplaceArenaRankItem")
CmdReplaceArenaRankItem.Definition = {
  "stRoleSimple",
  "iRank",
  "iScore",
  stRoleSimple = {
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
CmdReplaceArenaAfkRecord = sdp.SdpStruct("CmdReplaceArenaAfkRecord")
CmdReplaceArenaAfkRecord.Definition = {
  "iGrade",
  "iStartTime",
  "iEndTime",
  iGrade = {
    0,
    0,
    8,
    0
  },
  iStartTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  }
}
CmdReplaceArenaAfk = sdp.SdpStruct("CmdReplaceArenaAfk")
CmdReplaceArenaAfk.Definition = {
  "iRank",
  "iTakeRewardTime",
  "iLastCalcTime",
  "mReward",
  "vRecord",
  iRank = {
    0,
    0,
    8,
    0
  },
  iTakeRewardTime = {
    1,
    0,
    8,
    0
  },
  iLastCalcTime = {
    2,
    0,
    8,
    0
  },
  mReward = {
    3,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vRecord = {
    4,
    0,
    sdp.SdpVector(CmdReplaceArenaAfkRecord),
    nil
  }
}
CmdReplaceArenaBattleRecord = sdp.SdpStruct("CmdReplaceArenaBattleRecord")
CmdReplaceArenaBattleRecord.Definition = {
  "iTime",
  "stEnemySimple",
  "iRank",
  "iOldRank",
  "bWin",
  "bAttack",
  iTime = {
    0,
    0,
    8,
    0
  },
  stEnemySimple = {
    1,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  iRank = {
    2,
    0,
    8,
    0
  },
  iOldRank = {
    3,
    0,
    8,
    0
  },
  bWin = {
    4,
    0,
    1,
    false
  },
  bAttack = {
    5,
    0,
    1,
    false
  }
}
CmdReplaceArenaSeasonReward = sdp.SdpStruct("CmdReplaceArenaSeasonReward")
CmdReplaceArenaSeasonReward.Definition = {
  "stRoleId",
  "iRank",
  "iScore",
  "mLeftAfk",
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
  mLeftAfk = {
    3,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_ReplaceArena_GetInit_CS = sdp.SdpStruct("Cmd_ReplaceArena_GetInit_CS")
Cmd_ReplaceArena_GetInit_CS.Definition = {}
Cmd_ReplaceArena_GetInit_SC = sdp.SdpStruct("Cmd_ReplaceArena_GetInit_SC")
Cmd_ReplaceArena_GetInit_SC.Definition = {
  "stMine",
  "mEnemy",
  "stAfk",
  stMine = {
    0,
    0,
    CmdReplaceArenaMineInfo,
    nil
  },
  mEnemy = {
    1,
    0,
    sdp.SdpMap(8, CmdReplaceArenaRankItem),
    nil
  },
  stAfk = {
    2,
    0,
    CmdReplaceArenaAfk,
    nil
  }
}
Cmd_ReplaceArena_RefreshEnemy_CS = sdp.SdpStruct("Cmd_ReplaceArena_RefreshEnemy_CS")
Cmd_ReplaceArena_RefreshEnemy_CS.Definition = {}
Cmd_ReplaceArena_RefreshEnemy_SC = sdp.SdpStruct("Cmd_ReplaceArena_RefreshEnemy_SC")
Cmd_ReplaceArena_RefreshEnemy_SC.Definition = {
  "iLastRefreshTime",
  "mEnemy",
  iLastRefreshTime = {
    0,
    0,
    8,
    0
  },
  mEnemy = {
    1,
    0,
    sdp.SdpMap(8, CmdReplaceArenaRankItem),
    nil
  }
}
Cmd_ReplaceArena_GetEnemyDetail_CS = sdp.SdpStruct("Cmd_ReplaceArena_GetEnemyDetail_CS")
Cmd_ReplaceArena_GetEnemyDetail_CS.Definition = {
  "iEnemyIndex",
  iEnemyIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_ReplaceArena_GetEnemyDetail_SC = sdp.SdpStruct("Cmd_ReplaceArena_GetEnemyDetail_SC")
Cmd_ReplaceArena_GetEnemyDetail_SC.Definition = {
  "stEnemyDetail",
  stEnemyDetail = {
    0,
    0,
    CmdReplaceArenaEnemyDetail,
    nil
  }
}
Cmd_ReplaceArena_GetRankList_CS = sdp.SdpStruct("Cmd_ReplaceArena_GetRankList_CS")
Cmd_ReplaceArena_GetRankList_CS.Definition = {
  "iRankType",
  "iBeginRank",
  "iEndRank",
  iRankType = {
    0,
    0,
    8,
    0
  },
  iBeginRank = {
    1,
    0,
    8,
    0
  },
  iEndRank = {
    2,
    0,
    8,
    0
  }
}
Cmd_ReplaceArena_GetRankList_SC = sdp.SdpStruct("Cmd_ReplaceArena_GetRankList_SC")
Cmd_ReplaceArena_GetRankList_SC.Definition = {
  "iRankType",
  "vRankList",
  "iMyRank",
  "iMyScore",
  iRankType = {
    0,
    0,
    8,
    0
  },
  vRankList = {
    1,
    0,
    sdp.SdpVector(CmdReplaceArenaRankItem),
    nil
  },
  iMyRank = {
    2,
    0,
    8,
    0
  },
  iMyScore = {
    3,
    0,
    8,
    0
  }
}
Cmd_ReplaceArena_BuyTicket_CS = sdp.SdpStruct("Cmd_ReplaceArena_BuyTicket_CS")
Cmd_ReplaceArena_BuyTicket_CS.Definition = {}
Cmd_ReplaceArena_BuyTicket_SC = sdp.SdpStruct("Cmd_ReplaceArena_BuyTicket_SC")
Cmd_ReplaceArena_BuyTicket_SC.Definition = {}
Cmd_ReplaceArena_SeeAfk_CS = sdp.SdpStruct("Cmd_ReplaceArena_SeeAfk_CS")
Cmd_ReplaceArena_SeeAfk_CS.Definition = {}
Cmd_ReplaceArena_SeeAfk_SC = sdp.SdpStruct("Cmd_ReplaceArena_SeeAfk_SC")
Cmd_ReplaceArena_SeeAfk_SC.Definition = {
  "stAfk",
  stAfk = {
    0,
    0,
    CmdReplaceArenaAfk,
    nil
  }
}
Cmd_ReplaceArena_TakeAfk_CS = sdp.SdpStruct("Cmd_ReplaceArena_TakeAfk_CS")
Cmd_ReplaceArena_TakeAfk_CS.Definition = {}
Cmd_ReplaceArena_TakeAfk_SC = sdp.SdpStruct("Cmd_ReplaceArena_TakeAfk_SC")
Cmd_ReplaceArena_TakeAfk_SC.Definition = {
  "stAfk",
  "vReward",
  stAfk = {
    0,
    0,
    CmdReplaceArenaAfk,
    nil
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_ReplaceArena_GetBattleRecord_CS = sdp.SdpStruct("Cmd_ReplaceArena_GetBattleRecord_CS")
Cmd_ReplaceArena_GetBattleRecord_CS.Definition = {}
Cmd_ReplaceArena_GetBattleRecord_SC = sdp.SdpStruct("Cmd_ReplaceArena_GetBattleRecord_SC")
Cmd_ReplaceArena_GetBattleRecord_SC.Definition = {
  "vBattleRecord",
  vBattleRecord = {
    0,
    0,
    sdp.SdpVector(CmdReplaceArenaBattleRecord),
    nil
  }
}
