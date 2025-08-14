local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdActCDKeyExchange_Status = sdp.SdpStruct("CmdActCDKeyExchange_Status")
CmdActCDKeyExchange_Status.Definition = {}
