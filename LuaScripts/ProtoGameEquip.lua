local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Equip_GetList_CS = 18001
CmdId_Equip_GetList_SC = 18002
CmdId_Equip_AddExp_CS = 18003
CmdId_Equip_AddExp_SC = 18004
CmdId_Equip_Overload_CS = 18005
CmdId_Equip_Overload_SC = 18006
CmdId_Equip_SetEffectLock_CS = 18007
CmdId_Equip_SetEffectLock_SC = 18008
CmdId_Equip_ReOverload_CS = 18009
CmdId_Equip_ReOverload_SC = 18010
CmdId_Equip_SaveReOverload_CS = 18011
CmdId_Equip_SaveReOverload_SC = 18012
EquipQuality_T1 = 1
EquipQuality_T2 = 2
EquipQuality_T3 = 3
EquipQuality_T4 = 4
EquipQuality_T5 = 5
EquipQuality_T6 = 6
EquipQuality_T7 = 7
EquipQuality_T8 = 8
EquipQuality_T9 = 9
EquipQuality_T10 = 10
Cmd_Equip_GetList_CS = sdp.SdpStruct("Cmd_Equip_GetList_CS")
Cmd_Equip_GetList_CS.Definition = {}
Cmd_Equip_GetList_SC = sdp.SdpStruct("Cmd_Equip_GetList_SC")
Cmd_Equip_GetList_SC.Definition = {
  "mCmdEquips",
  mCmdEquips = {
    0,
    0,
    sdp.SdpMap(10, CmdEquip),
    nil
  }
}
Cmd_Equip_AddExp_CS = sdp.SdpStruct("Cmd_Equip_AddExp_CS")
Cmd_Equip_AddExp_CS.Definition = {
  "iEquipUid",
  "vUseItem",
  "vUseEquip",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  vUseItem = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vUseEquip = {
    2,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Equip_AddExp_SC = sdp.SdpStruct("Cmd_Equip_AddExp_SC")
Cmd_Equip_AddExp_SC.Definition = {
  "iEquipUid",
  "iLevel",
  "iExp",
  "vReturnItem",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  iExp = {
    2,
    0,
    8,
    0
  },
  vReturnItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Equip_Overload_CS = sdp.SdpStruct("Cmd_Equip_Overload_CS")
Cmd_Equip_Overload_CS.Definition = {
  "iEquipUid",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Equip_Overload_SC = sdp.SdpStruct("Cmd_Equip_Overload_SC")
Cmd_Equip_Overload_SC.Definition = {
  "iEquipUid",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Equip_SetEffectLock_CS = sdp.SdpStruct("Cmd_Equip_SetEffectLock_CS")
Cmd_Equip_SetEffectLock_CS.Definition = {
  "iEquipUid",
  "iSlot",
  "bLock",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  iSlot = {
    1,
    0,
    8,
    0
  },
  bLock = {
    2,
    0,
    1,
    false
  }
}
Cmd_Equip_SetEffectLock_SC = sdp.SdpStruct("Cmd_Equip_SetEffectLock_SC")
Cmd_Equip_SetEffectLock_SC.Definition = {
  "iEquipUid",
  "iSlot",
  "bLock",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  iSlot = {
    1,
    0,
    8,
    0
  },
  bLock = {
    2,
    0,
    1,
    false
  }
}
Cmd_Equip_ReOverload_CS = sdp.SdpStruct("Cmd_Equip_ReOverload_CS")
Cmd_Equip_ReOverload_CS.Definition = {
  "iEquipUid",
  "bLevel",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  bLevel = {
    1,
    0,
    1,
    false
  }
}
Cmd_Equip_ReOverload_SC = sdp.SdpStruct("Cmd_Equip_ReOverload_SC")
Cmd_Equip_ReOverload_SC.Definition = {
  "iEquipUid",
  "bLevel",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  bLevel = {
    1,
    0,
    1,
    false
  }
}
Cmd_Equip_SaveReOverload_CS = sdp.SdpStruct("Cmd_Equip_SaveReOverload_CS")
Cmd_Equip_SaveReOverload_CS.Definition = {
  "iEquipUid",
  "bSave",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  bSave = {
    1,
    0,
    1,
    false
  }
}
Cmd_Equip_SaveReOverload_SC = sdp.SdpStruct("Cmd_Equip_SaveReOverload_SC")
Cmd_Equip_SaveReOverload_SC.Definition = {
  "iEquipUid",
  "bSave",
  iEquipUid = {
    0,
    0,
    10,
    "0"
  },
  bSave = {
    1,
    0,
    1,
    false
  }
}
