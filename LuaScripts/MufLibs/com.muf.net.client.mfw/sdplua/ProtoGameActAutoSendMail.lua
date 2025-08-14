local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActAutoSendMail_Status = sdp.SdpStruct("CmdActAutoSendMail_Status")
CmdActAutoSendMail_Status.Definition = {}
CmdActCfgAutoSendMail = sdp.SdpStruct("CmdActCfgAutoSendMail")
CmdActCfgAutoSendMail.Definition = {}
