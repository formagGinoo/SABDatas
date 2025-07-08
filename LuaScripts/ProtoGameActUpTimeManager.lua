local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActUpTimeManager_Status = sdp.SdpStruct("CmdActUpTimeManager_Status")
CmdActUpTimeManager_Status.Definition = {}
CmdActCfgUpTimeManagerBackground = sdp.SdpStruct("CmdActCfgUpTimeManagerBackground")
CmdActCfgUpTimeManagerBackground.Definition = {
  "iBackgroundId",
  "iUnlockTime",
  "iShield",
  iBackgroundId = {
    0,
    0,
    8,
    0
  },
  iUnlockTime = {
    1,
    0,
    8,
    0
  },
  iShield = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgUpTimeManagerHeadFrame = sdp.SdpStruct("CmdActCfgUpTimeManagerHeadFrame")
CmdActCfgUpTimeManagerHeadFrame.Definition = {
  "iHeadFrameId",
  "iUnlockTime",
  "iShield",
  iHeadFrameId = {
    0,
    0,
    8,
    0
  },
  iUnlockTime = {
    1,
    0,
    8,
    0
  },
  iShield = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgUpTimeManagerHero = sdp.SdpStruct("CmdActCfgUpTimeManagerHero")
CmdActCfgUpTimeManagerHero.Definition = {
  "iHeroId",
  "iUnlockTime",
  "iShield",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iUnlockTime = {
    1,
    0,
    8,
    0
  },
  iShield = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgUpTimeManagerPlayerHead = sdp.SdpStruct("CmdActCfgUpTimeManagerPlayerHead")
CmdActCfgUpTimeManagerPlayerHead.Definition = {
  "iPlayerHeadId",
  "iUnlockTime",
  "iShield",
  iPlayerHeadId = {
    0,
    0,
    8,
    0
  },
  iUnlockTime = {
    1,
    0,
    8,
    0
  },
  iShield = {
    2,
    0,
    8,
    0
  }
}
CmdActClientCfgUpTimeManager = sdp.SdpStruct("CmdActClientCfgUpTimeManager")
CmdActClientCfgUpTimeManager.Definition = {
  "mHero",
  "mBackground",
  "mPlayerHead",
  "mHeadFrame",
  mHero = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgUpTimeManagerHero),
    nil
  },
  mBackground = {
    1,
    0,
    sdp.SdpMap(8, CmdActCfgUpTimeManagerBackground),
    nil
  },
  mPlayerHead = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgUpTimeManagerPlayerHead),
    nil
  },
  mHeadFrame = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgUpTimeManagerHeadFrame),
    nil
  }
}
CmdActCfgUpTimeManager = sdp.SdpStruct("CmdActCfgUpTimeManager")
CmdActCfgUpTimeManager.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgUpTimeManager,
    nil
  }
}
