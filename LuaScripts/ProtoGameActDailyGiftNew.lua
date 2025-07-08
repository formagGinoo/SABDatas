local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_DailyGiftNew_BuyFreeGift_CS = 57901
CmdId_Act_DailyGiftNew_BuyFreeGift_SC = 57902
CmdId_Act_DailyGiftNew_RefreshSelect_CS = 57903
CmdId_Act_DailyGiftNew_RefreshSelect_SC = 57904
CmdDailyGiftNewProduct = sdp.SdpStruct("CmdDailyGiftNewProduct")
CmdDailyGiftNewProduct.Definition = {
  "iSubIndex",
  "iNum",
  "bManual",
  iSubIndex = {
    0,
    0,
    8,
    0
  },
  iNum = {
    1,
    0,
    8,
    0
  },
  bManual = {
    2,
    0,
    1,
    false
  }
}
CmdActDailyGiftNew_Status = sdp.SdpStruct("CmdActDailyGiftNew_Status")
CmdActDailyGiftNew_Status.Definition = {
  "mProducts",
  "vSelectGift",
  "iRefreshTimes",
  mProducts = {
    0,
    0,
    sdp.SdpMap(8, CmdDailyGiftNewProduct),
    nil
  },
  vSelectGift = {
    1,
    0,
    sdp.SdpVector(CmdDailyGiftNewProduct),
    nil
  },
  iRefreshTimes = {
    2,
    0,
    8,
    0
  }
}
Cmd_Act_DailyGiftNew_BuyFreeGift_CS = sdp.SdpStruct("Cmd_Act_DailyGiftNew_BuyFreeGift_CS")
Cmd_Act_DailyGiftNew_BuyFreeGift_CS.Definition = {
  "iActivityId",
  "iIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_DailyGiftNew_BuyFreeGift_SC = sdp.SdpStruct("Cmd_Act_DailyGiftNew_BuyFreeGift_SC")
Cmd_Act_DailyGiftNew_BuyFreeGift_SC.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_DailyGiftNew_RefreshSelect_CS = sdp.SdpStruct("Cmd_Act_DailyGiftNew_RefreshSelect_CS")
Cmd_Act_DailyGiftNew_RefreshSelect_CS.Definition = {
  "iActivityId",
  "iIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_DailyGiftNew_RefreshSelect_SC = sdp.SdpStruct("Cmd_Act_DailyGiftNew_RefreshSelect_SC")
Cmd_Act_DailyGiftNew_RefreshSelect_SC.Definition = {}
