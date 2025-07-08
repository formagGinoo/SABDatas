local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Net_Connect_CS = 10001
CmdId_Net_Connect_SC = 10002
CmdId_Net_DisConnect_CS = 10003
CmdId_Net_DisConnect_SC = 10004
CmdId_Net_Idle_CS = 10005
CmdId_Net_Idle_SC = 10006
CmdId_Net_Exchange_SessionKey_CS = 10007
CmdId_Net_Exchange_SessionKey_SC = 10008
CmdId_Net_SetSkeyExpireTime_CS = 10009
CmdId_Net_SetSkeyExpireTime_SC = 10010
CmdId_Net_NotifyPush_CS = 10011
CmdId_Net_NotifyPush_SC = 10012
CmdId_Net_Echo_CS = 10013
CmdId_Net_Echo_SC = 10014
CmdId_Net_TestStart_CS = 10015
CmdId_Net_TestFrameUp_CS = 10016
CmdId_Net_TestFrameDown_SC = 10017
CmdId_Net_TestStop_CS = 10018
CmdId_Net_Ping_CS = 10019
CmdId_Net_Ping_SC = 10020
Cmd_Net_Connect_CS = sdp.SdpStruct("Cmd_Net_Connect_CS")
Cmd_Net_Connect_CS.Definition = {
  "iAccountId",
  "sSessionKey",
  "iZoneId",
  "iReconnectNum",
  "sClientVersion",
  "iActivityPushVersion",
  "iOSType",
  "sProxyAddr",
  "iEchoTimeMS",
  "sClientIp",
  "sChannel",
  "sDeviceId",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  sSessionKey = {
    1,
    0,
    13,
    ""
  },
  iZoneId = {
    2,
    0,
    8,
    0
  },
  iReconnectNum = {
    3,
    0,
    8,
    0
  },
  sClientVersion = {
    4,
    0,
    13,
    ""
  },
  iActivityPushVersion = {
    5,
    0,
    8,
    0
  },
  iOSType = {
    6,
    0,
    8,
    0
  },
  sProxyAddr = {
    7,
    0,
    13,
    ""
  },
  iEchoTimeMS = {
    8,
    0,
    8,
    0
  },
  sClientIp = {
    9,
    0,
    13,
    ""
  },
  sChannel = {
    10,
    0,
    13,
    ""
  },
  sDeviceId = {
    11,
    0,
    13,
    ""
  }
}
Cmd_Net_Connect_SC = sdp.SdpStruct("Cmd_Net_Connect_SC")
Cmd_Net_Connect_SC.Definition = {
  "sNewSessionKey",
  "iExchangeInterval",
  sNewSessionKey = {
    0,
    0,
    13,
    ""
  },
  iExchangeInterval = {
    1,
    0,
    8,
    0
  }
}
Cmd_Net_DisConnect_CS = sdp.SdpStruct("Cmd_Net_DisConnect_CS")
Cmd_Net_DisConnect_CS.Definition = {}
Cmd_Net_DisConnect_SC = sdp.SdpStruct("Cmd_Net_DisConnect_SC")
Cmd_Net_DisConnect_SC.Definition = {}
Cmd_Net_Idle_CS = sdp.SdpStruct("Cmd_Net_Idle_CS")
Cmd_Net_Idle_CS.Definition = {}
Cmd_Net_Idle_SC = sdp.SdpStruct("Cmd_Net_Idle_SC")
Cmd_Net_Idle_SC.Definition = {}
Cmd_Net_Exchange_SessionKey_CS = sdp.SdpStruct("Cmd_Net_Exchange_SessionKey_CS")
Cmd_Net_Exchange_SessionKey_CS.Definition = {}
Cmd_Net_Exchange_SessionKey_SC = sdp.SdpStruct("Cmd_Net_Exchange_SessionKey_SC")
Cmd_Net_Exchange_SessionKey_SC.Definition = {
  "sNewSessionKey",
  sNewSessionKey = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Net_SetSkeyExpireTime_CS = sdp.SdpStruct("Cmd_Net_SetSkeyExpireTime_CS")
Cmd_Net_SetSkeyExpireTime_CS.Definition = {
  "iExpireTime",
  iExpireTime = {
    0,
    0,
    8,
    0
  }
}
Cmd_Net_SetSkeyExpireTime_SC = sdp.SdpStruct("Cmd_Net_SetSkeyExpireTime_SC")
Cmd_Net_SetSkeyExpireTime_SC.Definition = {}
Cmd_Net_NotifyPush_CS = sdp.SdpStruct("Cmd_Net_NotifyPush_CS")
Cmd_Net_NotifyPush_CS.Definition = {
  "iPushSeqId",
  iPushSeqId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Net_NotifyPush_SC = sdp.SdpStruct("Cmd_Net_NotifyPush_SC")
Cmd_Net_NotifyPush_SC.Definition = {}
Cmd_Net_Echo_CS = sdp.SdpStruct("Cmd_Net_Echo_CS")
Cmd_Net_Echo_CS.Definition = {
  "iTimeStampMS",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Net_Echo_SC = sdp.SdpStruct("Cmd_Net_Echo_SC")
Cmd_Net_Echo_SC.Definition = {
  "iTimeStampMS",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Net_TestStart_CS = sdp.SdpStruct("Cmd_Net_TestStart_CS")
Cmd_Net_TestStart_CS.Definition = {}
Cmd_Net_TestFrameUp_CS = sdp.SdpStruct("Cmd_Net_TestFrameUp_CS")
Cmd_Net_TestFrameUp_CS.Definition = {
  "iFrameId",
  "sData",
  iFrameId = {
    0,
    0,
    8,
    0
  },
  sData = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Net_TestFrameDown_SC = sdp.SdpStruct("Cmd_Net_TestFrameDown_SC")
Cmd_Net_TestFrameDown_SC.Definition = {
  "iFrameId",
  "vData",
  iFrameId = {
    0,
    0,
    8,
    0
  },
  vData = {
    1,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Net_TestStop_CS = sdp.SdpStruct("Cmd_Net_TestStop_CS")
Cmd_Net_TestStop_CS.Definition = {}
Cmd_Net_Ping_CS = sdp.SdpStruct("Cmd_Net_Ping_CS")
Cmd_Net_Ping_CS.Definition = {
  "iTimeStampMS",
  "iPingSeq",
  "iCurIndex",
  "iRoleId",
  "iZoneId",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  },
  iPingSeq = {
    1,
    0,
    10,
    "0"
  },
  iCurIndex = {
    2,
    0,
    10,
    "0"
  },
  iRoleId = {
    3,
    0,
    10,
    "0"
  },
  iZoneId = {
    4,
    0,
    8,
    0
  }
}
Cmd_Net_Ping_SC = sdp.SdpStruct("Cmd_Net_Ping_SC")
Cmd_Net_Ping_SC.Definition = {
  "iTimeStampMS",
  "iPingSeq",
  "iCurIndex",
  "iRecvCnt",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  },
  iPingSeq = {
    1,
    0,
    10,
    "0"
  },
  iCurIndex = {
    2,
    0,
    10,
    "0"
  },
  iRecvCnt = {
    3,
    0,
    10,
    "0"
  }
}
