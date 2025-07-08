local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoComm")
module("MTTDProto")
CmdId_Room_Create_CS = 10800
CmdId_Room_Create_SC = 10801
CmdId_Room_Enter_CS = 10802
CmdId_Room_Enter_SC = 10803
CmdId_Room_Leave_CS = 10804
CmdId_Room_Leave_SC = 10805
CmdId_Room_Invite_CS = 10806
CmdId_Room_Invite_SC = 10807
CmdId_Room_GetInfo_CS = 10808
CmdId_Room_GetInfo_SC = 10809
CmdId_Room_Kick_CS = 10810
CmdId_Room_Kick_SC = 10811
CmdId_Room_Chat_CS = 10812
CmdId_Room_Chat_SC = 10813
CmdId_Room_ChangePos_CS = 10816
CmdId_Room_ChangePos_SC = 10817
CmdId_Room_InviteReject_CS = 10818
CmdId_Room_InviteReject_SC = 10819
Cmd_Room_Create_CS = sdp.SdpStruct("Cmd_Room_Create_CS")
Cmd_Room_Create_CS.Definition = {
  "iMatchType",
  iMatchType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Room_Create_SC = sdp.SdpStruct("Cmd_Room_Create_SC")
Cmd_Room_Create_SC.Definition = {
  "stRoom",
  stRoom = {
    0,
    0,
    RoomInfo,
    nil
  }
}
Cmd_Room_Invite_CS = sdp.SdpStruct("Cmd_Room_Invite_CS")
Cmd_Room_Invite_CS.Definition = {
  "stPlayer",
  stPlayer = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Room_Invite_SC = sdp.SdpStruct("Cmd_Room_Invite_SC")
Cmd_Room_Invite_SC.Definition = {
  "iRet",
  iRet = {
    0,
    0,
    8,
    0
  }
}
Cmd_Room_Enter_CS = sdp.SdpStruct("Cmd_Room_Enter_CS")
Cmd_Room_Enter_CS.Definition = {
  "iRoomId",
  "iMatchType",
  iRoomId = {
    0,
    0,
    10,
    "0"
  },
  iMatchType = {
    1,
    0,
    8,
    0
  }
}
Cmd_Room_Enter_SC = sdp.SdpStruct("Cmd_Room_Enter_SC")
Cmd_Room_Enter_SC.Definition = {
  "iRet",
  "stRoom",
  iRet = {
    0,
    0,
    8,
    0
  },
  stRoom = {
    1,
    0,
    RoomInfo,
    nil
  }
}
Cmd_Room_Leave_CS = sdp.SdpStruct("Cmd_Room_Leave_CS")
Cmd_Room_Leave_CS.Definition = {}
Cmd_Room_Leave_SC = sdp.SdpStruct("Cmd_Room_Leave_SC")
Cmd_Room_Leave_SC.Definition = {
  "iRet",
  iRet = {
    0,
    0,
    8,
    0
  }
}
Cmd_Room_GetInfo_CS = sdp.SdpStruct("Cmd_Room_GetInfo_CS")
Cmd_Room_GetInfo_CS.Definition = {}
Cmd_Room_GetInfo_SC = sdp.SdpStruct("Cmd_Room_GetInfo_SC")
Cmd_Room_GetInfo_SC.Definition = {
  "stRoom",
  stRoom = {
    0,
    0,
    RoomInfo,
    nil
  }
}
Cmd_Room_Kick_CS = sdp.SdpStruct("Cmd_Room_Kick_CS")
Cmd_Room_Kick_CS.Definition = {
  "stPlayer",
  stPlayer = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Room_Kick_SC = sdp.SdpStruct("Cmd_Room_Kick_SC")
Cmd_Room_Kick_SC.Definition = {
  "iRet",
  "stRoom",
  iRet = {
    0,
    0,
    8,
    0
  },
  stRoom = {
    1,
    0,
    RoomInfo,
    nil
  }
}
Cmd_Room_Chat_CS = sdp.SdpStruct("Cmd_Room_Chat_CS")
Cmd_Room_Chat_CS.Definition = {
  "sMessage",
  sMessage = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Room_Chat_SC = sdp.SdpStruct("Cmd_Room_Chat_SC")
Cmd_Room_Chat_SC.Definition = {
  "sMessage",
  "sSenderName",
  sMessage = {
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
  }
}
Cmd_Room_ChangePos_CS = sdp.SdpStruct("Cmd_Room_ChangePos_CS")
Cmd_Room_ChangePos_CS.Definition = {
  "iNewPos",
  iNewPos = {
    0,
    0,
    8,
    0
  }
}
Cmd_Room_ChangePos_SC = sdp.SdpStruct("Cmd_Room_ChangePos_SC")
Cmd_Room_ChangePos_SC.Definition = {
  "iNewPos",
  "stPlayer",
  iNewPos = {
    0,
    0,
    8,
    0
  },
  stPlayer = {
    1,
    0,
    RoomPlayerInfo,
    nil
  }
}
Cmd_Room_InviteReject_CS = sdp.SdpStruct("Cmd_Room_InviteReject_CS")
Cmd_Room_InviteReject_CS.Definition = {
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
Cmd_Room_InviteReject_SC = sdp.SdpStruct("Cmd_Room_InviteReject_SC")
Cmd_Room_InviteReject_SC.Definition = {}
