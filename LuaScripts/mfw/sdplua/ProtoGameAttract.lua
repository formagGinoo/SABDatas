local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Attract_GetAttract_CS = 10901
CmdId_Attract_GetAttract_SC = 10902
CmdId_Attract_TouchHero_CS = 10903
CmdId_Attract_TouchHero_SC = 10904
CmdId_Attract_TakeStoryReward_CS = 10905
CmdId_Attract_TakeStoryReward_SC = 10906
CmdId_Attract_SendGift_CS = 10907
CmdId_Attract_SendGift_SC = 10908
CmdId_Attract_SeeStory_CS = 10909
CmdId_Attract_SeeStory_SC = 10910
CmdId_Attract_SetCouncilHero_CS = 10911
CmdId_Attract_SetCouncilHero_SC = 10912
CmdId_Attract_StartCouncil_CS = 10913
CmdId_Attract_StartCouncil_SC = 10914
CmdId_Attract_EndCouncil_CS = 10915
CmdId_Attract_EndCouncil_SC = 10916
CmdId_Attract_SetLetter_CS = 10917
CmdId_Attract_SetLetter_SC = 10918
AttractArchiveType_Archive = 1
AttractArchiveType_Story = 2
AttractArchiveType_Letter = 3
LetterDialogueType_Reply = 2
CouncilOpinionType_Agree = 1
CouncilOpinionType_Neutral = 2
CouncilOpinionType_Disagree = 3
CouncilHeroResultType_Same = 1
CouncilHeroResultType_NotSame = 2
CouncilHeroResultType_Critical = 3
CouncilHeroResultType_None = 4
CmdLetter = sdp.SdpStruct("CmdLetter")
CmdLetter.Definition = {
  "iLetterId",
  "iArchiveId",
  "iCurStep",
  "vReply",
  "vRewardStep",
  "iStartTime",
  iLetterId = {
    0,
    0,
    8,
    0
  },
  iArchiveId = {
    1,
    0,
    8,
    0
  },
  iCurStep = {
    2,
    0,
    8,
    0
  },
  vReply = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  vRewardStep = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  iStartTime = {
    5,
    0,
    8,
    0
  }
}
CmdHeroAttract = sdp.SdpStruct("CmdHeroAttract")
CmdHeroAttract.Definition = {
  "iHeroId",
  "iAttractExp",
  "vRewardStory",
  "vSendGift",
  "vSawStory",
  "iTouchTimes",
  "mLetter",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iAttractExp = {
    1,
    0,
    8,
    0
  },
  vRewardStory = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vSendGift = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  vSawStory = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  iTouchTimes = {
    5,
    0,
    8,
    0
  },
  mLetter = {
    6,
    0,
    sdp.SdpMap(8, CmdLetter),
    nil
  }
}
CmdCouncil = sdp.SdpStruct("CmdCouncil")
CmdCouncil.Definition = {
  "vDailyIssue",
  "iChosenIssue",
  "vFinishIssue",
  "vHero",
  "iStartTime",
  vDailyIssue = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iChosenIssue = {
    1,
    0,
    8,
    0
  },
  vFinishIssue = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vHero = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iStartTime = {
    4,
    0,
    8,
    0
  }
}
CmdAllAttract = sdp.SdpStruct("CmdAllAttract")
CmdAllAttract.Definition = {
  "mHeroAttract",
  "stCouncil",
  mHeroAttract = {
    0,
    0,
    sdp.SdpMap(8, CmdHeroAttract),
    nil
  },
  stCouncil = {
    1,
    0,
    CmdCouncil,
    nil
  }
}
Cmd_Attract_GetAttract_CS = sdp.SdpStruct("Cmd_Attract_GetAttract_CS")
Cmd_Attract_GetAttract_CS.Definition = {}
Cmd_Attract_GetAttract_SC = sdp.SdpStruct("Cmd_Attract_GetAttract_SC")
Cmd_Attract_GetAttract_SC.Definition = {
  "stAttract",
  "iTotalTimes",
  stAttract = {
    0,
    0,
    CmdAllAttract,
    nil
  },
  iTotalTimes = {
    1,
    0,
    8,
    0
  }
}
Cmd_Attract_TouchHero_CS = sdp.SdpStruct("Cmd_Attract_TouchHero_CS")
Cmd_Attract_TouchHero_CS.Definition = {
  "iHeroId",
  "iTimes",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iTimes = {
    1,
    0,
    8,
    0
  }
}
Cmd_Attract_TouchHero_SC = sdp.SdpStruct("Cmd_Attract_TouchHero_SC")
Cmd_Attract_TouchHero_SC.Definition = {
  "iHeroId",
  "iTimes",
  "bRankChange",
  "iTotalTimes",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iTimes = {
    1,
    0,
    8,
    0
  },
  bRankChange = {
    2,
    0,
    1,
    false
  },
  iTotalTimes = {
    3,
    0,
    8,
    0
  }
}
Cmd_Attract_TakeStoryReward_CS = sdp.SdpStruct("Cmd_Attract_TakeStoryReward_CS")
Cmd_Attract_TakeStoryReward_CS.Definition = {
  "iHeroId",
  "iStoryId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iStoryId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Attract_TakeStoryReward_SC = sdp.SdpStruct("Cmd_Attract_TakeStoryReward_SC")
Cmd_Attract_TakeStoryReward_SC.Definition = {
  "iHeroId",
  "iStoryId",
  "vReward",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iStoryId = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Attract_SendGift_CS = sdp.SdpStruct("Cmd_Attract_SendGift_CS")
Cmd_Attract_SendGift_CS.Definition = {
  "iHeroId",
  "vGift",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  vGift = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Attract_SendGift_SC = sdp.SdpStruct("Cmd_Attract_SendGift_SC")
Cmd_Attract_SendGift_SC.Definition = {
  "iHeroId",
  "bRankChange",
  "iAddExp",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  bRankChange = {
    1,
    0,
    1,
    false
  },
  iAddExp = {
    2,
    0,
    8,
    0
  }
}
Cmd_Attract_SeeStory_CS = sdp.SdpStruct("Cmd_Attract_SeeStory_CS")
Cmd_Attract_SeeStory_CS.Definition = {
  "iHeroId",
  "iStoryId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iStoryId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Attract_SeeStory_SC = sdp.SdpStruct("Cmd_Attract_SeeStory_SC")
Cmd_Attract_SeeStory_SC.Definition = {
  "iHeroId",
  "iStoryId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iStoryId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Attract_SetCouncilHero_CS = sdp.SdpStruct("Cmd_Attract_SetCouncilHero_CS")
Cmd_Attract_SetCouncilHero_CS.Definition = {
  "vHeroId",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Attract_SetCouncilHero_SC = sdp.SdpStruct("Cmd_Attract_SetCouncilHero_SC")
Cmd_Attract_SetCouncilHero_SC.Definition = {
  "vHeroId",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Attract_StartCouncil_CS = sdp.SdpStruct("Cmd_Attract_StartCouncil_CS")
Cmd_Attract_StartCouncil_CS.Definition = {}
Cmd_Attract_StartCouncil_SC = sdp.SdpStruct("Cmd_Attract_StartCouncil_SC")
Cmd_Attract_StartCouncil_SC.Definition = {
  "iStartTime",
  iStartTime = {
    0,
    0,
    8,
    0
  }
}
Cmd_Attract_EndCouncil_CS = sdp.SdpStruct("Cmd_Attract_EndCouncil_CS")
Cmd_Attract_EndCouncil_CS.Definition = {
  "iIssue",
  "iOpinion",
  iIssue = {
    0,
    0,
    8,
    0
  },
  iOpinion = {
    1,
    0,
    8,
    0
  }
}
CmdCouncilHeroResult = sdp.SdpStruct("CmdCouncilHeroResult")
CmdCouncilHeroResult.Definition = {
  "iHeroId",
  "iAddExp",
  "iAttractExp",
  "iResultType",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iAddExp = {
    1,
    0,
    8,
    0
  },
  iAttractExp = {
    2,
    0,
    8,
    0
  },
  iResultType = {
    3,
    0,
    8,
    0
  }
}
Cmd_Attract_EndCouncil_SC = sdp.SdpStruct("Cmd_Attract_EndCouncil_SC")
Cmd_Attract_EndCouncil_SC.Definition = {
  "iIssue",
  "iOpinion",
  "vHeroResult",
  iIssue = {
    0,
    0,
    8,
    0
  },
  iOpinion = {
    1,
    0,
    8,
    0
  },
  vHeroResult = {
    2,
    0,
    sdp.SdpVector(CmdCouncilHeroResult),
    nil
  }
}
Cmd_Attract_SetLetter_CS = sdp.SdpStruct("Cmd_Attract_SetLetter_CS")
Cmd_Attract_SetLetter_CS.Definition = {
  "iHeroId",
  "iLetterId",
  "iCurStep",
  "vNewReply",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLetterId = {
    1,
    0,
    8,
    0
  },
  iCurStep = {
    2,
    0,
    8,
    0
  },
  vNewReply = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Attract_SetLetter_SC = sdp.SdpStruct("Cmd_Attract_SetLetter_SC")
Cmd_Attract_SetLetter_SC.Definition = {
  "iHeroId",
  "iLetterId",
  "stLetter",
  "vReward",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLetterId = {
    1,
    0,
    8,
    0
  },
  stLetter = {
    2,
    0,
    CmdLetter,
    nil
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
