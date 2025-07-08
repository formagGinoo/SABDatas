local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Legacy_GetList_CS = 18051
CmdId_Legacy_GetList_SC = 18052
CmdId_Legacy_Upgrade_CS = 18053
CmdId_Legacy_Upgrade_SC = 18054
CmdId_Legacy_Install_CS = 18055
CmdId_Legacy_Install_SC = 18056
CmdId_Legacy_Uninstall_CS = 18057
CmdId_Legacy_Uninstall_SC = 18058
CmdId_Legacy_Swap_CS = 18059
CmdId_Legacy_Swap_SC = 18060
CmdId_Legacy_InstallBatch_CS = 18061
CmdId_Legacy_InstallBatch_SC = 18062
Cmd_Legacy_GetList_CS = sdp.SdpStruct("Cmd_Legacy_GetList_CS")
Cmd_Legacy_GetList_CS.Definition = {}
Cmd_Legacy_GetList_SC = sdp.SdpStruct("Cmd_Legacy_GetList_SC")
Cmd_Legacy_GetList_SC.Definition = {
  "mCmdLegacy",
  mCmdLegacy = {
    0,
    0,
    sdp.SdpMap(8, CmdLegacy),
    nil
  }
}
Cmd_Legacy_Upgrade_CS = sdp.SdpStruct("Cmd_Legacy_Upgrade_CS")
Cmd_Legacy_Upgrade_CS.Definition = {
  "iLegacyId",
  iLegacyId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Legacy_Upgrade_SC = sdp.SdpStruct("Cmd_Legacy_Upgrade_SC")
Cmd_Legacy_Upgrade_SC.Definition = {
  "iLegacyId",
  iLegacyId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Legacy_Install_CS = sdp.SdpStruct("Cmd_Legacy_Install_CS")
Cmd_Legacy_Install_CS.Definition = {
  "iHeroId",
  "iLegacyId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLegacyId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_Install_SC = sdp.SdpStruct("Cmd_Legacy_Install_SC")
Cmd_Legacy_Install_SC.Definition = {
  "iHeroId",
  "iLegacyId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLegacyId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_InstallBatch_CS = sdp.SdpStruct("Cmd_Legacy_InstallBatch_CS")
Cmd_Legacy_InstallBatch_CS.Definition = {
  "vHeroId",
  "iLegacyId",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iLegacyId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_InstallBatch_SC = sdp.SdpStruct("Cmd_Legacy_InstallBatch_SC")
Cmd_Legacy_InstallBatch_SC.Definition = {
  "vHeroId",
  "iLegacyId",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iLegacyId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_Uninstall_CS = sdp.SdpStruct("Cmd_Legacy_Uninstall_CS")
Cmd_Legacy_Uninstall_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Legacy_Uninstall_SC = sdp.SdpStruct("Cmd_Legacy_Uninstall_SC")
Cmd_Legacy_Uninstall_SC.Definition = {
  "iHeroId",
  "iLegacyId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLegacyId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_Swap_CS = sdp.SdpStruct("Cmd_Legacy_Swap_CS")
Cmd_Legacy_Swap_CS.Definition = {
  "iSrcHeroId",
  "iDstHeroId",
  iSrcHeroId = {
    0,
    0,
    8,
    0
  },
  iDstHeroId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Legacy_Swap_SC = sdp.SdpStruct("Cmd_Legacy_Swap_SC")
Cmd_Legacy_Swap_SC.Definition = {
  "iSrcHeroId",
  "iDstHeroId",
  iSrcHeroId = {
    0,
    0,
    8,
    0
  },
  iDstHeroId = {
    1,
    0,
    8,
    0
  }
}
