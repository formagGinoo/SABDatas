local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActABTest_Status = sdp.SdpStruct("CmdActABTest_Status")
CmdActABTest_Status.Definition = {}
CmdActCfgABTestABTest = sdp.SdpStruct("CmdActCfgABTestABTest")
CmdActCfgABTestABTest.Definition = {
  "iABTestID",
  "iABTestType",
  "iABTestPercentForB",
  "iABTestPercentForC",
  iABTestID = {
    0,
    0,
    8,
    0
  },
  iABTestType = {
    1,
    0,
    8,
    0
  },
  iABTestPercentForB = {
    2,
    0,
    8,
    0
  },
  iABTestPercentForC = {
    3,
    0,
    8,
    0
  }
}
CmdActCfgABTestABTestConfig = sdp.SdpStruct("CmdActCfgABTestABTestConfig")
CmdActCfgABTestABTestConfig.Definition = {
  "mABTest",
  mABTest = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgABTestABTest),
    nil
  }
}
CmdActCommonCfgABTest = sdp.SdpStruct("CmdActCommonCfgABTest")
CmdActCommonCfgABTest.Definition = {
  "stABTestConfig",
  stABTestConfig = {
    0,
    0,
    CmdActCfgABTestABTestConfig,
    nil
  }
}
CmdActCfgABTest = sdp.SdpStruct("CmdActCfgABTest")
CmdActCfgABTest.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgABTest,
    nil
  }
}
