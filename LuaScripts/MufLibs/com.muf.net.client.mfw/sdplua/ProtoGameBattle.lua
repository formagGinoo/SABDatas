local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoComm")
module("MTTDProto")
CmdId_Battle_StartMatch_CS = 19001
CmdId_Battle_StartMatch_SC = 19002
CmdId_Battle_QuitMatch_CS = 19005
CmdId_Battle_QuitMatch_SC = 19006
CmdId_Battle_MatchInfo_CS = 19009
CmdId_Battle_MatchInfo_SC = 19010
CmdId_Battle_ReconnectFailed_CS = 19032
CmdId_Battle_ReconnectFailed_SC = 19033
CmdId_Battle_ReconnectInfo_CS = 19034
CmdId_Battle_ReconnectInfo_SC = 19035
CmdId_Battle_RecvEnterBattle_CS = 19048
CmdId_Battle_RecvEnterBattle_SC = 19049
EMIR_PlayerEnter = 1
EMIR_GetInfo = 2
EMIR_PlayerLeave = 3
EMIR_NotReady = 4
EMIR_LeaveRoom = 5
EMIR_MatchSuccess = 6
Cmd_Battle_StartMatch_CS = sdp.SdpStruct("Cmd_Battle_StartMatch_CS")
Cmd_Battle_StartMatch_CS.Definition = {
  "iMatchType",
  iMatchType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Battle_StartMatch_SC = sdp.SdpStruct("Cmd_Battle_StartMatch_SC")
Cmd_Battle_StartMatch_SC.Definition = {
  "iRet",
  "iPlayerNum",
  "iSelfElo",
  "iMatchType",
  "iMatchId",
  iRet = {
    0,
    0,
    8,
    0
  },
  iPlayerNum = {
    1,
    0,
    8,
    0
  },
  iSelfElo = {
    2,
    0,
    8,
    0
  },
  iMatchType = {
    3,
    0,
    8,
    0
  },
  iMatchId = {
    4,
    0,
    8,
    0
  }
}
Cmd_Battle_QuitMatch_CS = sdp.SdpStruct("Cmd_Battle_QuitMatch_CS")
Cmd_Battle_QuitMatch_CS.Definition = {}
Cmd_Battle_QuitMatch_SC = sdp.SdpStruct("Cmd_Battle_QuitMatch_SC")
Cmd_Battle_QuitMatch_SC.Definition = {}
Cmd_Battle_MatchInfo_CS = sdp.SdpStruct("Cmd_Battle_MatchInfo_CS")
Cmd_Battle_MatchInfo_CS.Definition = {}
Cmd_Battle_MatchInfo_SC = sdp.SdpStruct("Cmd_Battle_MatchInfo_SC")
Cmd_Battle_MatchInfo_SC.Definition = {
  "iMatchState",
  "iMatchTime",
  "iMatchType",
  iMatchState = {
    0,
    0,
    8,
    0
  },
  iMatchTime = {
    1,
    0,
    8,
    0
  },
  iMatchType = {
    2,
    0,
    8,
    0
  }
}
Cmd_Battle_ReconnectFailed_CS = sdp.SdpStruct("Cmd_Battle_ReconnectFailed_CS")
Cmd_Battle_ReconnectFailed_CS.Definition = {
  "iBattleUid",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Battle_ReconnectFailed_SC = sdp.SdpStruct("Cmd_Battle_ReconnectFailed_SC")
Cmd_Battle_ReconnectFailed_SC.Definition = {}
Cmd_Battle_ReconnectInfo_CS = sdp.SdpStruct("Cmd_Battle_ReconnectInfo_CS")
Cmd_Battle_ReconnectInfo_CS.Definition = {}
Cmd_Battle_ReconnectInfo_SC = sdp.SdpStruct("Cmd_Battle_ReconnectInfo_SC")
Cmd_Battle_ReconnectInfo_SC.Definition = {
  "iBattleUid",
  "sBattleIp",
  "iBattlePort",
  "sBattleProxy",
  "iProxyId",
  "iProxyPing",
  "sBattleConn",
  "iUdpPort",
  "iMatchType",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  },
  sBattleIp = {
    1,
    0,
    13,
    ""
  },
  iBattlePort = {
    2,
    0,
    8,
    0
  },
  sBattleProxy = {
    3,
    0,
    13,
    ""
  },
  iProxyId = {
    4,
    0,
    8,
    0
  },
  iProxyPing = {
    5,
    0,
    8,
    0
  },
  sBattleConn = {
    6,
    0,
    13,
    ""
  },
  iUdpPort = {
    7,
    0,
    8,
    0
  },
  iMatchType = {
    8,
    0,
    8,
    0
  }
}
Cmd_Battle_RecvEnterBattle_CS = sdp.SdpStruct("Cmd_Battle_RecvEnterBattle_CS")
Cmd_Battle_RecvEnterBattle_CS.Definition = {
  "iBattleUid",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Battle_RecvEnterBattle_SC = sdp.SdpStruct("Cmd_Battle_RecvEnterBattle_SC")
Cmd_Battle_RecvEnterBattle_SC.Definition = {}
