local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActHeroSkillReset_Status = sdp.SdpStruct("CmdActHeroSkillReset_Status")
CmdActHeroSkillReset_Status.Definition = {}
CmdActCfgHeroSkillReset = sdp.SdpStruct("CmdActCfgHeroSkillReset")
CmdActCfgHeroSkillReset.Definition = {}
