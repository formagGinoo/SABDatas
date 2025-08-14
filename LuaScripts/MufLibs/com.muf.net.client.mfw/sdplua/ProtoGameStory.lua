local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Story_Init_CS = 10301
CmdId_Story_Init_SC = 10302
Cmd_Story_Init_CS = sdp.SdpStruct("Cmd_Story_Init_CS")
Cmd_Story_Init_CS.Definition = {}
Cmd_Story_Init_SC = sdp.SdpStruct("Cmd_Story_Init_SC")
Cmd_Story_Init_SC.Definition = {
  "vStory",
  vStory = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
