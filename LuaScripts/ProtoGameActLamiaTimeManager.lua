local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActLamiaTimeManager_Status = sdp.SdpStruct("CmdActLamiaTimeManager_Status")
CmdActLamiaTimeManager_Status.Definition = {}
CmdActCfgLamiaTimeManagerActLamiaLevelCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerActLamiaLevelCfg")
CmdActCfgLamiaTimeManagerActLamiaLevelCfg.Definition = {
  "iLevelId",
  "iOpenTime",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iOpenTime = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgLamiaTimeManagerActivitySubCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerActivitySubCfg")
CmdActCfgLamiaTimeManagerActivitySubCfg.Definition = {
  "iSubActId",
  "iBeginTime",
  "iEndTime",
  iSubActId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgLamiaTimeManagerGachaCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerGachaCfg")
CmdActCfgLamiaTimeManagerGachaCfg.Definition = {
  "iLevelId",
  "iBeginTime",
  "iEndTime",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgLamiaTimeManagerMiniGameCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerMiniGameCfg")
CmdActCfgLamiaTimeManagerMiniGameCfg.Definition = {
  "iGameId",
  "iOpenTime",
  iGameId = {
    0,
    0,
    8,
    0
  },
  iOpenTime = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgLamiaTimeManagerShopCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerShopCfg")
CmdActCfgLamiaTimeManagerShopCfg.Definition = {
  "iShopId",
  "iBeginTime",
  "iEndTime",
  iShopId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgLamiaTimeManagerShopGoodsCfg = sdp.SdpStruct("CmdActCfgLamiaTimeManagerShopGoodsCfg")
CmdActCfgLamiaTimeManagerShopGoodsCfg.Definition = {
  "iGroupId",
  "iGoodsId",
  "iConditionTime",
  "iShowTime",
  "iEndTime",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iGoodsId = {
    1,
    0,
    8,
    0
  },
  iConditionTime = {
    2,
    0,
    8,
    0
  },
  iShowTime = {
    3,
    0,
    8,
    0
  },
  iEndTime = {
    4,
    0,
    8,
    0
  }
}
CmdActCommonCfgLamiaTimeManager = sdp.SdpStruct("CmdActCommonCfgLamiaTimeManager")
CmdActCommonCfgLamiaTimeManager.Definition = {
  "iLamiaId",
  "iDisable",
  "iOpenTime",
  "iCloseTime",
  "mActivitySubCfg",
  "mActLamiaLevelCfg",
  "mGachaCfg",
  "mShopCfg",
  "mShopGoodsCfg",
  "mMiniGameCfg",
  iLamiaId = {
    0,
    0,
    8,
    0
  },
  iDisable = {
    1,
    0,
    8,
    0
  },
  iOpenTime = {
    2,
    0,
    8,
    0
  },
  iCloseTime = {
    3,
    0,
    8,
    0
  },
  mActivitySubCfg = {
    4,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerActivitySubCfg),
    nil
  },
  mActLamiaLevelCfg = {
    5,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerActLamiaLevelCfg),
    nil
  },
  mGachaCfg = {
    6,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerGachaCfg),
    nil
  },
  mShopCfg = {
    7,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerShopCfg),
    nil
  },
  mShopGoodsCfg = {
    8,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerShopGoodsCfg),
    nil
  },
  mMiniGameCfg = {
    9,
    0,
    sdp.SdpMap(8, CmdActCfgLamiaTimeManagerMiniGameCfg),
    nil
  }
}
CmdActCfgLamiaTimeManager = sdp.SdpStruct("CmdActCfgLamiaTimeManager")
CmdActCfgLamiaTimeManager.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgLamiaTimeManager,
    nil
  }
}
