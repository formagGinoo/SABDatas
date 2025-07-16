local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdActPersonalChatWeb_Status = sdp.SdpStruct("CmdActPersonalChatWeb_Status")
CmdActPersonalChatWeb_Status.Definition = {
  "iLastShareTime",
  iLastShareTime = {
    0,
    0,
    10,
    "0"
  }
}
