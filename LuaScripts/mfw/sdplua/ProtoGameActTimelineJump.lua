local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_TimelineJump_GetReward_CS = 60561
CmdId_Act_TimelineJump_GetReward_SC = 60562
CmdActTimelineJump_Status = sdp.SdpStruct("CmdActTimelineJump_Status")
CmdActTimelineJump_Status.Definition = {
  "bIsRewarded",
  bIsRewarded = {
    0,
    0,
    1,
    false
  }
}
CmdActClientCfgTimelineJump = sdp.SdpStruct("CmdActClientCfgTimelineJump")
CmdActClientCfgTimelineJump.Definition = {
  "sTimelineName",
  sTimelineName = {
    0,
    0,
    13,
    ""
  }
}
CmdActCommonCfgTimelineJump = sdp.SdpStruct("CmdActCommonCfgTimelineJump")
CmdActCommonCfgTimelineJump.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdActCfgTimelineJump = sdp.SdpStruct("CmdActCfgTimelineJump")
CmdActCfgTimelineJump.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgTimelineJump,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgTimelineJump,
    nil
  }
}
Cmd_Act_TimelineJump_GetReward_CS = sdp.SdpStruct("Cmd_Act_TimelineJump_GetReward_CS")
Cmd_Act_TimelineJump_GetReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_TimelineJump_GetReward_SC = sdp.SdpStruct("Cmd_Act_TimelineJump_GetReward_SC")
Cmd_Act_TimelineJump_GetReward_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
