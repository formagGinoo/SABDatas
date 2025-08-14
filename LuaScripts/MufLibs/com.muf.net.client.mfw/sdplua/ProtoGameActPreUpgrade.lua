local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdActPreUpgrade_Status = sdp.SdpStruct("CmdActPreUpgrade_Status")
CmdActPreUpgrade_Status.Definition = {
  "sCurrentVersion",
  "sTargetVersion",
  "sResPatchURL",
  "iCdnVersion",
  sCurrentVersion = {
    0,
    0,
    13,
    ""
  },
  sTargetVersion = {
    1,
    0,
    13,
    ""
  },
  sResPatchURL = {
    2,
    0,
    13,
    ""
  },
  iCdnVersion = {
    3,
    0,
    8,
    0
  }
}
