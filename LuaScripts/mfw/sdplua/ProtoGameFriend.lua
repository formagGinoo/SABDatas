local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_Friend_GetInit_CS = 17201
CmdId_Friend_GetInit_SC = 17202
CmdId_Friend_AddFriend_CS = 17203
CmdId_Friend_AddFriend_SC = 17204
CmdId_Friend_DelFriend_CS = 17205
CmdId_Friend_DelFriend_SC = 17206
CmdId_Friend_ConfirmFriendRequest_CS = 17207
CmdId_Friend_ConfirmFriendRequest_SC = 17208
CmdId_Friend_DelFriendRequest_CS = 17209
CmdId_Friend_DelFriendRequest_SC = 17210
CmdId_Friend_SendHeart_CS = 17211
CmdId_Friend_SendHeart_SC = 17212
CmdId_Friend_GatherHeart_CS = 17213
CmdId_Friend_GatherHeart_SC = 17214
CmdId_Friend_GatherAndSendAllHeart_CS = 17215
CmdId_Friend_GatherAndSendAllHeart_SC = 17216
CmdId_Friend_StartChallenge_CS = 17217
CmdId_Friend_StartChallenge_SC = 17218
CmdId_Friend_FinishChallenge_CS = 17219
CmdId_Friend_FinishChallenge_SC = 17220
CmdId_Friend_DelAllFriendRequest_CS = 17221
CmdId_Friend_DelAllFriendRequest_SC = 17222
CmdId_Friend_ConfirmAllFriendRequest_CS = 17223
CmdId_Friend_ConfirmAllFriendRequest_SC = 17224
CmdId_Friend_DelFriendBatch_CS = 17225
CmdId_Friend_DelFriendBatch_SC = 17226
CmdId_Friend_SearchRole_CS = 17227
CmdId_Friend_SearchRole_SC = 17228
CmdId_Friend_GetRecommend_CS = 17229
CmdId_Friend_GetRecommend_SC = 17230
CmdId_Friend_AddFriendBatch_CS = 17231
CmdId_Friend_AddFriendBatch_SC = 17232
Cmd_Friend_GetInit_CS = sdp.SdpStruct("Cmd_Friend_GetInit_CS")
Cmd_Friend_GetInit_CS.Definition = {}
Cmd_Friend_GetInit_SC = sdp.SdpStruct("Cmd_Friend_GetInit_SC")
Cmd_Friend_GetInit_SC.Definition = {
  "vFriend",
  "vFriendRequest",
  "iDailyTakeHeartNum",
  "vFriendHeartSend",
  "vFriendHeartRecieveUntake",
  "vFriendHeartRecieveTake",
  vFriend = {
    0,
    0,
    sdp.SdpVector(CmdFriendInfo),
    nil
  },
  vFriendRequest = {
    3,
    0,
    sdp.SdpVector(CmdFriendInfo),
    nil
  },
  iDailyTakeHeartNum = {
    5,
    0,
    8,
    0
  },
  vFriendHeartSend = {
    6,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  vFriendHeartRecieveUntake = {
    8,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  vFriendHeartRecieveTake = {
    9,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
Cmd_Friend_AddFriend_CS = sdp.SdpStruct("Cmd_Friend_AddFriend_CS")
Cmd_Friend_AddFriend_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_AddFriend_SC = sdp.SdpStruct("Cmd_Friend_AddFriend_SC")
Cmd_Friend_AddFriend_SC.Definition = {}
Cmd_Friend_DelFriend_CS = sdp.SdpStruct("Cmd_Friend_DelFriend_CS")
Cmd_Friend_DelFriend_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_DelFriend_SC = sdp.SdpStruct("Cmd_Friend_DelFriend_SC")
Cmd_Friend_DelFriend_SC.Definition = {}
Cmd_Friend_ConfirmFriendRequest_CS = sdp.SdpStruct("Cmd_Friend_ConfirmFriendRequest_CS")
Cmd_Friend_ConfirmFriendRequest_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_ConfirmFriendRequest_SC = sdp.SdpStruct("Cmd_Friend_ConfirmFriendRequest_SC")
Cmd_Friend_ConfirmFriendRequest_SC.Definition = {}
Cmd_Friend_DelFriendRequest_CS = sdp.SdpStruct("Cmd_Friend_DelFriendRequest_CS")
Cmd_Friend_DelFriendRequest_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_DelFriendRequest_SC = sdp.SdpStruct("Cmd_Friend_DelFriendRequest_SC")
Cmd_Friend_DelFriendRequest_SC.Definition = {}
Cmd_Friend_SendHeart_CS = sdp.SdpStruct("Cmd_Friend_SendHeart_CS")
Cmd_Friend_SendHeart_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_SendHeart_SC = sdp.SdpStruct("Cmd_Friend_SendHeart_SC")
Cmd_Friend_SendHeart_SC.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_GatherHeart_CS = sdp.SdpStruct("Cmd_Friend_GatherHeart_CS")
Cmd_Friend_GatherHeart_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_GatherHeart_SC = sdp.SdpStruct("Cmd_Friend_GatherHeart_SC")
Cmd_Friend_GatherHeart_SC.Definition = {}
Cmd_Friend_GatherAndSendAllHeart_CS = sdp.SdpStruct("Cmd_Friend_GatherAndSendAllHeart_CS")
Cmd_Friend_GatherAndSendAllHeart_CS.Definition = {}
Cmd_Friend_GatherAndSendAllHeart_SC = sdp.SdpStruct("Cmd_Friend_GatherAndSendAllHeart_SC")
Cmd_Friend_GatherAndSendAllHeart_SC.Definition = {
  "iDailyTakeHeartNum",
  "vFriendHeartRecieveUntake",
  "vFriendHeartRecieveTake",
  iDailyTakeHeartNum = {
    1,
    0,
    8,
    0
  },
  vFriendHeartRecieveUntake = {
    3,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  vFriendHeartRecieveTake = {
    4,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
Cmd_Friend_StartChallenge_CS = sdp.SdpStruct("Cmd_Friend_StartChallenge_CS")
Cmd_Friend_StartChallenge_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_StartChallenge_SC = sdp.SdpStruct("Cmd_Friend_StartChallenge_SC")
Cmd_Friend_StartChallenge_SC.Definition = {}
Cmd_Friend_FinishChallenge_CS = sdp.SdpStruct("Cmd_Friend_FinishChallenge_CS")
Cmd_Friend_FinishChallenge_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_FinishChallenge_SC = sdp.SdpStruct("Cmd_Friend_FinishChallenge_SC")
Cmd_Friend_FinishChallenge_SC.Definition = {
  "stFinishChallengeInfoSC",
  "stFightReport",
  "stRoleId",
  stFinishChallengeInfoSC = {
    1,
    0,
    CmdFinishChallengeInfoSC,
    nil
  },
  stFightReport = {
    2,
    0,
    CmdFightReport,
    nil
  },
  stRoleId = {
    3,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Friend_DelAllFriendRequest_CS = sdp.SdpStruct("Cmd_Friend_DelAllFriendRequest_CS")
Cmd_Friend_DelAllFriendRequest_CS.Definition = {}
Cmd_Friend_DelAllFriendRequest_SC = sdp.SdpStruct("Cmd_Friend_DelAllFriendRequest_SC")
Cmd_Friend_DelAllFriendRequest_SC.Definition = {}
Cmd_Friend_ConfirmAllFriendRequest_CS = sdp.SdpStruct("Cmd_Friend_ConfirmAllFriendRequest_CS")
Cmd_Friend_ConfirmAllFriendRequest_CS.Definition = {}
Cmd_Friend_ConfirmAllFriendRequest_SC = sdp.SdpStruct("Cmd_Friend_ConfirmAllFriendRequest_SC")
Cmd_Friend_ConfirmAllFriendRequest_SC.Definition = {
  "iAddNum",
  iAddNum = {
    0,
    0,
    8,
    0
  }
}
Cmd_Friend_DelFriendBatch_CS = sdp.SdpStruct("Cmd_Friend_DelFriendBatch_CS")
Cmd_Friend_DelFriendBatch_CS.Definition = {
  "vRoleId",
  vRoleId = {
    0,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
Cmd_Friend_DelFriendBatch_SC = sdp.SdpStruct("Cmd_Friend_DelFriendBatch_SC")
Cmd_Friend_DelFriendBatch_SC.Definition = {}
Cmd_Friend_SearchRole_CS = sdp.SdpStruct("Cmd_Friend_SearchRole_CS")
Cmd_Friend_SearchRole_CS.Definition = {
  "iRoleId",
  iRoleId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Friend_SearchRole_SC = sdp.SdpStruct("Cmd_Friend_SearchRole_SC")
Cmd_Friend_SearchRole_SC.Definition = {
  "vRole",
  vRole = {
    0,
    0,
    sdp.SdpVector(CmdFriendInfo),
    nil
  }
}
Cmd_Friend_GetRecommend_CS = sdp.SdpStruct("Cmd_Friend_GetRecommend_CS")
Cmd_Friend_GetRecommend_CS.Definition = {}
Cmd_Friend_GetRecommend_SC = sdp.SdpStruct("Cmd_Friend_GetRecommend_SC")
Cmd_Friend_GetRecommend_SC.Definition = {
  "vRecommendFriend",
  vRecommendFriend = {
    0,
    0,
    sdp.SdpVector(CmdFriendInfo),
    nil
  }
}
Cmd_Friend_AddFriendBatch_CS = sdp.SdpStruct("Cmd_Friend_AddFriendBatch_CS")
Cmd_Friend_AddFriendBatch_CS.Definition = {
  "vRoleId",
  vRoleId = {
    0,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
Cmd_Friend_AddFriendBatch_SC = sdp.SdpStruct("Cmd_Friend_AddFriendBatch_SC")
Cmd_Friend_AddFriendBatch_SC.Definition = {
  "vAddRoleId",
  vAddRoleId = {
    0,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
