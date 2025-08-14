local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActItemEmergencyShield_Status = sdp.SdpStruct("CmdActItemEmergencyShield_Status")
CmdActItemEmergencyShield_Status.Definition = {}
CmdActCfgItemEmergencyShield = sdp.SdpStruct("CmdActCfgItemEmergencyShield")
CmdActCfgItemEmergencyShield.Definition = {}
