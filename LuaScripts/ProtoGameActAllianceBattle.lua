local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActAllianceBattle_Status = sdp.SdpStruct("CmdActAllianceBattle_Status")
CmdActAllianceBattle_Status.Definition = {}
CmdActCommonCfgAllianceBattle = sdp.SdpStruct("CmdActCommonCfgAllianceBattle")
CmdActCommonCfgAllianceBattle.Definition = {
  "iBattleId",
  "iSettleTime",
  iBattleId = {
    0,
    0,
    8,
    0
  },
  iSettleTime = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgAllianceBattle = sdp.SdpStruct("CmdActCfgAllianceBattle")
CmdActCfgAllianceBattle.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    0,
    0,
    CmdActCommonCfgAllianceBattle,
    nil
  }
}
