local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Ancient_GetData_CS = 11101
CmdId_Ancient_GetData_SC = 11102
CmdId_Ancient_ChangeHero_CS = 11103
CmdId_Ancient_ChangeHero_SC = 11104
CmdId_Ancient_TakeQuestAward_CS = 11105
CmdId_Ancient_TakeQuestAward_SC = 11106
CmdId_Ancient_RefreshQuest_CS = 11107
CmdId_Ancient_RefreshQuest_SC = 11108
CmdId_Ancient_AddEnergy_CS = 11109
CmdId_Ancient_AddEnergy_SC = 11110
CmdId_Ancient_SummonHero_CS = 11111
CmdId_Ancient_SummonHero_SC = 11112
AncientHeroType_Normal = 0
CmdAncientHero = sdp.SdpStruct("CmdAncientHero")
CmdAncientHero.Definition = {
  "iHeroId",
  "iCurEnergy",
  "iSummonTimes",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iCurEnergy = {
    1,
    0,
    8,
    0
  },
  iSummonTimes = {
    2,
    0,
    8,
    0
  }
}
CmdAncient = sdp.SdpStruct("CmdAncient")
CmdAncient.Definition = {
  "iCurHero",
  "mSummonHero",
  "vQuest",
  "iRefreshTimes",
  iCurHero = {
    0,
    0,
    8,
    0
  },
  mSummonHero = {
    1,
    0,
    sdp.SdpMap(8, CmdAncientHero),
    nil
  },
  vQuest = {
    2,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  iRefreshTimes = {
    3,
    0,
    8,
    0
  }
}
Cmd_Ancient_GetData_CS = sdp.SdpStruct("Cmd_Ancient_GetData_CS")
Cmd_Ancient_GetData_CS.Definition = {}
Cmd_Ancient_GetData_SC = sdp.SdpStruct("Cmd_Ancient_GetData_SC")
Cmd_Ancient_GetData_SC.Definition = {
  "stAncient",
  stAncient = {
    0,
    0,
    CmdAncient,
    nil
  }
}
Cmd_Ancient_ChangeHero_CS = sdp.SdpStruct("Cmd_Ancient_ChangeHero_CS")
Cmd_Ancient_ChangeHero_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Ancient_ChangeHero_SC = sdp.SdpStruct("Cmd_Ancient_ChangeHero_SC")
Cmd_Ancient_ChangeHero_SC.Definition = {
  "iHeroId",
  "stHero",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  stHero = {
    1,
    0,
    CmdAncientHero,
    nil
  }
}
Cmd_Ancient_TakeQuestAward_CS = sdp.SdpStruct("Cmd_Ancient_TakeQuestAward_CS")
Cmd_Ancient_TakeQuestAward_CS.Definition = {
  "vQuestId",
  vQuestId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Ancient_TakeQuestAward_SC = sdp.SdpStruct("Cmd_Ancient_TakeQuestAward_SC")
Cmd_Ancient_TakeQuestAward_SC.Definition = {
  "vQuestId",
  "vItem",
  vQuestId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vItem = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Ancient_RefreshQuest_CS = sdp.SdpStruct("Cmd_Ancient_RefreshQuest_CS")
Cmd_Ancient_RefreshQuest_CS.Definition = {}
Cmd_Ancient_RefreshQuest_SC = sdp.SdpStruct("Cmd_Ancient_RefreshQuest_SC")
Cmd_Ancient_RefreshQuest_SC.Definition = {
  "vQuest",
  vQuest = {
    0,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  }
}
Cmd_Ancient_AddEnergy_CS = sdp.SdpStruct("Cmd_Ancient_AddEnergy_CS")
Cmd_Ancient_AddEnergy_CS.Definition = {
  "iAddEnergy",
  iAddEnergy = {
    0,
    0,
    8,
    0
  }
}
Cmd_Ancient_AddEnergy_SC = sdp.SdpStruct("Cmd_Ancient_AddEnergy_SC")
Cmd_Ancient_AddEnergy_SC.Definition = {
  "iAddEnergy",
  "iCurEnergy",
  iAddEnergy = {
    0,
    0,
    8,
    0
  },
  iCurEnergy = {
    1,
    0,
    8,
    0
  }
}
Cmd_Ancient_SummonHero_CS = sdp.SdpStruct("Cmd_Ancient_SummonHero_CS")
Cmd_Ancient_SummonHero_CS.Definition = {}
Cmd_Ancient_SummonHero_SC = sdp.SdpStruct("Cmd_Ancient_SummonHero_SC")
Cmd_Ancient_SummonHero_SC.Definition = {
  "iHeroId",
  "stHero",
  "iCurHero",
  "vItem",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  stHero = {
    1,
    0,
    CmdAncientHero,
    nil
  },
  iCurHero = {
    2,
    0,
    8,
    0
  },
  vItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
