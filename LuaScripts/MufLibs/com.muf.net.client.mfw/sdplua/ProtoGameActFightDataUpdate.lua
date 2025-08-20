local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActFightDataUpdate_Status = sdp.SdpStruct("CmdActFightDataUpdate_Status")
CmdActFightDataUpdate_Status.Definition = {}
CmdActCfgFightDataUpdatepdateData = sdp.SdpStruct("CmdActCfgFightDataUpdatepdateData")
CmdActCfgFightDataUpdatepdateData.Definition = {
  "time",
  "vMonsterId",
  "vCharacterId",
  time = {
    0,
    0,
    8,
    0
  },
  vMonsterId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vCharacterId = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActClientCfgFightDataUpdate = sdp.SdpStruct("CmdActClientCfgFightDataUpdate")
CmdActClientCfgFightDataUpdate.Definition = {
  "updateData",
  updateData = {
    0,
    0,
    sdp.SdpVector(CmdActCfgFightDataUpdatepdateData),
    nil
  }
}
CmdActCfgFightDataUpdate = sdp.SdpStruct("CmdActCfgFightDataUpdate")
CmdActCfgFightDataUpdate.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgFightDataUpdate,
    nil
  }
}
