local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Store_IAP_Deliver_Apple_CS = 11901
CmdId_Store_IAP_Deliver_Apple_SC = 11902
CmdId_Store_IAP_Deliver_Google_CS = 11903
CmdId_Store_IAP_Deliver_Google_SC = 11904
CmdId_Store_Request_IAPBuy_CS = 11905
CmdId_Store_Request_IAPBuy_SC = 11906
CmdId_Store_Trace_IAPBuy_CS = 11907
CmdId_Store_Trace_IAPBuy_SC = 11908
CmdId_Store_IAP_Deliver_Welfare_CS = 11909
CmdId_Store_IAP_Deliver_Welfare_SC = 11910
CmdId_Store_IAP_Deliver_DMM_CS = 11911
CmdId_Store_IAP_Deliver_DMM_SC = 11912
CmdId_Store_WeGame_Session_Start_CS = 11913
CmdId_Store_WeGame_Session_Start_SC = 11914
IAPReceiptType_Apple = 1
IAPReceiptType_Google = 2
IAPReceiptType_MSDK = 3
IAPReceiptType_QuickSDK = 4
IAPReceiptType_QuickGame = 5
IAPReceiptType_Welfare = 6
IAPReceiptType_Mobapay = 7
IAPReceiptType_DMM = 8
IAPReceiptType_WeGame = 9
IAPReceiptType_Max = IAPReceiptType_WeGame + 1
IAPStoreType_BaseStore = 1
IAPStoreType_ActPayStore = 2
IAPStoreType_ActBattlePass = 3
IAPStoreType_ActPickupGift = 4
IAPStoreType_ActPushGift = 5
IAPStoreType_ActEmergencyGift = 6
IAPStoreType_ActSignGift = 7
IAPStoreType_Max = IAPStoreType_ActSignGift + 1
IAPDmmReceiptStatus_Unknown = 0
IAPDmmReceiptStatus_New = 1
IAPDmmReceiptStatus_Delivered = 2
IAPDmmReceiptStatus_Processing = 3
IAPDmmReceiptStatus_Failed = 4
Cmd_Store_IAP_Deliver_Apple_CS = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Apple_CS")
Cmd_Store_IAP_Deliver_Apple_CS.Definition = {
  "sReceipt",
  "iZoneId",
  "iUid",
  "sTraceProductId",
  "sTraceFlowId",
  "sReportPrice",
  "iProductSubId",
  sReceipt = {
    0,
    0,
    13,
    ""
  },
  iZoneId = {
    1,
    0,
    8,
    0
  },
  iUid = {
    2,
    0,
    10,
    "0"
  },
  sTraceProductId = {
    10,
    0,
    13,
    ""
  },
  sTraceFlowId = {
    11,
    0,
    13,
    ""
  },
  sReportPrice = {
    12,
    0,
    13,
    ""
  },
  iProductSubId = {
    13,
    0,
    8,
    0
  }
}
Cmd_Store_IAP_Deliver_Apple_SC = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Apple_SC")
Cmd_Store_IAP_Deliver_Apple_SC.Definition = {
  "bDuplicate",
  bDuplicate = {
    0,
    0,
    1,
    false
  }
}
Cmd_Store_IAP_Deliver_Google_CS = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Google_CS")
Cmd_Store_IAP_Deliver_Google_CS.Definition = {
  "iResponseCode",
  "sPurchaseData",
  "sSignature",
  "iZoneId",
  "iUid",
  "sTraceProductId",
  "sTraceFlowId",
  "sReportPrice",
  iResponseCode = {
    0,
    0,
    7,
    0
  },
  sPurchaseData = {
    1,
    0,
    13,
    ""
  },
  sSignature = {
    2,
    0,
    13,
    ""
  },
  iZoneId = {
    3,
    0,
    8,
    0
  },
  iUid = {
    4,
    0,
    10,
    "0"
  },
  sTraceProductId = {
    10,
    0,
    13,
    ""
  },
  sTraceFlowId = {
    11,
    0,
    13,
    ""
  },
  sReportPrice = {
    12,
    0,
    13,
    ""
  }
}
Cmd_Store_IAP_Deliver_Google_SC = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Google_SC")
Cmd_Store_IAP_Deliver_Google_SC.Definition = {
  "bDuplicate",
  bDuplicate = {
    0,
    0,
    1,
    false
  }
}
CmdStoreIAPMonitor = sdp.SdpStruct("CmdStoreIAPMonitor")
CmdStoreIAPMonitor.Definition = {
  "iDayNum",
  "iWeekNum",
  "iMonthNum",
  iDayNum = {
    0,
    0,
    8,
    0
  },
  iWeekNum = {
    1,
    0,
    8,
    0
  },
  iMonthNum = {
    2,
    0,
    8,
    0
  }
}
Cmd_Store_Request_IAPBuy_CS = sdp.SdpStruct("Cmd_Store_Request_IAPBuy_CS")
Cmd_Store_Request_IAPBuy_CS.Definition = {
  "sProductId",
  "iProductSubId",
  "iReceiptType",
  "iStoreType",
  "sStoreParam",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iProductSubId = {
    1,
    0,
    8,
    0
  },
  iReceiptType = {
    2,
    0,
    8,
    0
  },
  iStoreType = {
    3,
    0,
    8,
    0
  },
  sStoreParam = {
    4,
    0,
    13,
    ""
  }
}
Cmd_Store_Request_IAPBuy_SC = sdp.SdpStruct("Cmd_Store_Request_IAPBuy_SC")
Cmd_Store_Request_IAPBuy_SC.Definition = {
  "sTraceFlowId",
  "bWarnPay",
  sTraceFlowId = {
    0,
    0,
    13,
    ""
  },
  bWarnPay = {
    1,
    0,
    1,
    false
  }
}
Cmd_Store_Trace_IAPBuy_CS = sdp.SdpStruct("Cmd_Store_Trace_IAPBuy_CS")
Cmd_Store_Trace_IAPBuy_CS.Definition = {
  "sProductId",
  "iReceiptType",
  "sFlowId",
  "sStatus",
  "sReportPrice",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iReceiptType = {
    1,
    0,
    8,
    0
  },
  sFlowId = {
    2,
    0,
    13,
    ""
  },
  sStatus = {
    3,
    0,
    13,
    ""
  },
  sReportPrice = {
    4,
    0,
    13,
    ""
  }
}
Cmd_Store_Trace_IAPBuy_SC = sdp.SdpStruct("Cmd_Store_Trace_IAPBuy_SC")
Cmd_Store_Trace_IAPBuy_SC.Definition = {}
Cmd_Store_IAP_Deliver_Welfare_CS = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Welfare_CS")
Cmd_Store_IAP_Deliver_Welfare_CS.Definition = {
  "sProductId",
  "iProductSubId",
  "iStoreType",
  "sStoreParam",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iProductSubId = {
    1,
    0,
    8,
    0
  },
  iStoreType = {
    2,
    0,
    8,
    0
  },
  sStoreParam = {
    3,
    0,
    13,
    ""
  }
}
Cmd_Store_IAP_Deliver_Welfare_SC = sdp.SdpStruct("Cmd_Store_IAP_Deliver_Welfare_SC")
Cmd_Store_IAP_Deliver_Welfare_SC.Definition = {}
Cmd_Store_IAP_Deliver_DMM_CS = sdp.SdpStruct("Cmd_Store_IAP_Deliver_DMM_CS")
Cmd_Store_IAP_Deliver_DMM_CS.Definition = {
  "sPurchaseToken",
  "sOrderId",
  "sProductId",
  "iPrice",
  "iPriceAmountMicros",
  "sPriceCurrencyCode",
  "iQuantity",
  "iPurchaseTime",
  "iPurchaseState",
  "sInAppPurchaseData",
  "sInAppDataSignature",
  "iZoneId",
  "iUid",
  sPurchaseToken = {
    0,
    0,
    13,
    ""
  },
  sOrderId = {
    1,
    0,
    13,
    ""
  },
  sProductId = {
    2,
    0,
    13,
    ""
  },
  iPrice = {
    3,
    0,
    13,
    ""
  },
  iPriceAmountMicros = {
    4,
    0,
    10,
    "0"
  },
  sPriceCurrencyCode = {
    5,
    0,
    13,
    ""
  },
  iQuantity = {
    6,
    0,
    8,
    0
  },
  iPurchaseTime = {
    7,
    0,
    8,
    0
  },
  iPurchaseState = {
    8,
    0,
    8,
    0
  },
  sInAppPurchaseData = {
    10,
    0,
    13,
    ""
  },
  sInAppDataSignature = {
    11,
    0,
    13,
    ""
  },
  iZoneId = {
    12,
    0,
    8,
    0
  },
  iUid = {
    13,
    0,
    10,
    "0"
  }
}
Cmd_Store_IAP_Deliver_DMM_SC = sdp.SdpStruct("Cmd_Store_IAP_Deliver_DMM_SC")
Cmd_Store_IAP_Deliver_DMM_SC.Definition = {
  "sPurchaseToken",
  "sOrderId",
  "sProductId",
  "iReceiptStatus",
  sPurchaseToken = {
    0,
    0,
    13,
    ""
  },
  sOrderId = {
    1,
    0,
    13,
    ""
  },
  sProductId = {
    2,
    0,
    13,
    ""
  },
  iReceiptStatus = {
    3,
    0,
    8,
    0
  }
}
WeGameProductInfo = sdp.SdpStruct("WeGameProductInfo")
WeGameProductInfo.Definition = {
  "sProductClassId",
  "iProductCount",
  "sProductPrice",
  "sProductName",
  "sProductIconUrl",
  "sProductDescription",
  sProductClassId = {
    0,
    0,
    13,
    ""
  },
  iProductCount = {
    1,
    0,
    8,
    0
  },
  sProductPrice = {
    2,
    0,
    13,
    ""
  },
  sProductName = {
    3,
    0,
    13,
    ""
  },
  sProductIconUrl = {
    4,
    0,
    13,
    ""
  },
  sProductDescription = {
    5,
    0,
    13,
    ""
  }
}
Cmd_Store_WeGame_Session_Start_CS = sdp.SdpStruct("Cmd_Store_WeGame_Session_Start_CS")
Cmd_Store_WeGame_Session_Start_CS.Definition = {
  "sProductId",
  "iProductSubId",
  "iStoreType",
  "sStoreParam",
  "sRailId",
  "iNeedAultLimit",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iProductSubId = {
    1,
    0,
    8,
    0
  },
  iStoreType = {
    2,
    0,
    8,
    0
  },
  sStoreParam = {
    3,
    0,
    13,
    ""
  },
  sRailId = {
    4,
    0,
    13,
    ""
  },
  iNeedAultLimit = {
    6,
    0,
    8,
    0
  }
}
Cmd_Store_WeGame_Session_Start_SC = sdp.SdpStruct("Cmd_Store_WeGame_Session_Start_SC")
Cmd_Store_WeGame_Session_Start_SC.Definition = {
  "sRailOrderId",
  "sRailGameId",
  "sRailId",
  sRailOrderId = {
    0,
    0,
    13,
    ""
  },
  sRailGameId = {
    1,
    0,
    13,
    ""
  },
  sRailId = {
    2,
    0,
    13,
    ""
  }
}
