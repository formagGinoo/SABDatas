local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActRefund_Status = sdp.SdpStruct("CmdActRefund_Status")
CmdActRefund_Status.Definition = {}
CmdActCfgRefundRefundGoods = sdp.SdpStruct("CmdActCfgRefundRefundGoods")
CmdActCfgRefundRefundGoods.Definition = {
  "iIndex",
  "sProductId",
  "iSubProductId",
  "iDiamond",
  iIndex = {
    0,
    0,
    8,
    0
  },
  sProductId = {
    1,
    0,
    13,
    ""
  },
  iSubProductId = {
    2,
    0,
    8,
    0
  },
  iDiamond = {
    3,
    0,
    8,
    0
  }
}
CmdActCommonCfgRefund = sdp.SdpStruct("CmdActCommonCfgRefund")
CmdActCommonCfgRefund.Definition = {
  "iBanRefund",
  "iBanTemplateId",
  "iDelayBanTime",
  "iRefundDay",
  "iRefundTimes",
  "iRefundCondition",
  "iNegativeDiamond",
  "iNegativeDiamondTemplateId",
  "mBan",
  "mRefundGoods",
  iBanRefund = {
    0,
    0,
    8,
    0
  },
  iBanTemplateId = {
    1,
    0,
    8,
    0
  },
  iDelayBanTime = {
    2,
    0,
    8,
    0
  },
  iRefundDay = {
    3,
    0,
    8,
    0
  },
  iRefundTimes = {
    4,
    0,
    8,
    0
  },
  iRefundCondition = {
    5,
    0,
    8,
    0
  },
  iNegativeDiamond = {
    6,
    0,
    8,
    0
  },
  iNegativeDiamondTemplateId = {
    7,
    0,
    8,
    0
  },
  mBan = {
    8,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mRefundGoods = {
    9,
    0,
    sdp.SdpMap(8, CmdActCfgRefundRefundGoods),
    nil
  }
}
CmdActCfgRefund = sdp.SdpStruct("CmdActCfgRefund")
CmdActCfgRefund.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgRefund,
    nil
  }
}
