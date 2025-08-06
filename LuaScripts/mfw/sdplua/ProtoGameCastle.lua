local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Castle_GetDispatch_CS = 12201
CmdId_Castle_GetDispatch_SC = 12202
CmdId_Castle_DoDispatch_CS = 12203
CmdId_Castle_DoDispatch_SC = 12204
CmdId_Castle_RefreshDispatch_CS = 12205
CmdId_Castle_RefreshDispatch_SC = 12206
CmdId_Castle_CancelDispatch_CS = 12207
CmdId_Castle_CancelDispatch_SC = 12208
CmdId_Castle_TakeDispatchReward_CS = 12209
CmdId_Castle_TakeDispatchReward_SC = 12210
CmdId_Castle_GetExplore_CS = 12211
CmdId_Castle_GetExplore_SC = 12212
CmdId_Castle_TakeClueReward_CS = 12213
CmdId_Castle_TakeClueReward_SC = 12214
CmdId_Castle_TakeStoryReward_CS = 12217
CmdId_Castle_TakeStoryReward_SC = 12218
CmdId_Castle_GetStatue_CS = 12219
CmdId_Castle_GetStatue_SC = 12220
CmdId_Castle_TakeStatueReward_CS = 12221
CmdId_Castle_TakeStatueReward_SC = 12222
CmdId_Castle_GetStarRoom_CS = 12223
CmdId_Castle_GetStarRoom_SC = 12224
CmdId_Castle_UnlockConstella_CS = 12225
CmdId_Castle_UnlockConstella_SC = 12226
CmdId_Castle_SeeStar_CS = 12227
CmdId_Castle_SeeStar_SC = 12228
CmdId_Castle_GetPlace_CS = 12229
CmdId_Castle_GetPlace_SC = 12230
CmdId_Castle_UnlockKeyPlace_CS = 12231
CmdId_Castle_UnlockKeyPlace_SC = 12232
CmdId_Castle_DoPlaceStory_CS = 12233
CmdId_Castle_DoPlaceStory_SC = 12234
CmdId_Castle_TakeChapterReward_CS = 12235
CmdId_Castle_TakeChapterReward_SC = 12236
StatueEffect_UnlockAllReceive = 1
StatueEffect_UnlockAutoDispatch = 2
StatueEffect_UnlockFastDispatch = 3
StatueEffect_DispatchLocation = 4
StatueEffect_TodayAttractMaxTouch = 5
StatueEffect_StaminaMaxCount = 6
StatueEffect_ShopNormalFreeResetMaxCount = 7
StatueEffect_PVPFreeCount = 8
StatueEffect_TodayCouncilHallAttractNum = 9
StarEffect_AfkReward = 1
StarEffect_DispatchLevel = 2
StarEffect_DungeonExtraReward = 3
StarEffect_InheritUnlockGrid = 4
CastlePlaceUnlockType_Open = 1
CastlePlaceUnlockType_Key = 2
CastlePlaceUnlockType_System = 3
CmdDispatchEvent = sdp.SdpStruct("CmdDispatchEvent")
CmdDispatchEvent.Definition = {
  "iGroupId",
  "iEventId",
  "iRefreshTime",
  "iStartTime",
  "iRewardTime",
  "vHero",
  "iFirstStartTime",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iEventId = {
    1,
    0,
    8,
    0
  },
  iRefreshTime = {
    2,
    0,
    8,
    0
  },
  iStartTime = {
    3,
    0,
    8,
    0
  },
  iRewardTime = {
    4,
    0,
    8,
    0
  },
  vHero = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  },
  iFirstStartTime = {
    6,
    0,
    8,
    0
  }
}
Cmd_Castle_GetDispatch_CS = sdp.SdpStruct("Cmd_Castle_GetDispatch_CS")
Cmd_Castle_GetDispatch_CS.Definition = {}
Cmd_Castle_GetDispatch_SC = sdp.SdpStruct("Cmd_Castle_GetDispatch_SC")
Cmd_Castle_GetDispatch_SC.Definition = {
  "mEvent",
  mEvent = {
    0,
    0,
    sdp.SdpMap(8, CmdDispatchEvent),
    nil
  }
}
Cmd_Castle_DoDispatch_CS = sdp.SdpStruct("Cmd_Castle_DoDispatch_CS")
Cmd_Castle_DoDispatch_CS.Definition = {
  "mLocationHero",
  mLocationHero = {
    0,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  }
}
Cmd_Castle_DoDispatch_SC = sdp.SdpStruct("Cmd_Castle_DoDispatch_SC")
Cmd_Castle_DoDispatch_SC.Definition = {
  "mEvent",
  mEvent = {
    0,
    0,
    sdp.SdpMap(8, CmdDispatchEvent),
    nil
  }
}
Cmd_Castle_RefreshDispatch_CS = sdp.SdpStruct("Cmd_Castle_RefreshDispatch_CS")
Cmd_Castle_RefreshDispatch_CS.Definition = {}
Cmd_Castle_RefreshDispatch_SC = sdp.SdpStruct("Cmd_Castle_RefreshDispatch_SC")
Cmd_Castle_RefreshDispatch_SC.Definition = {
  "mEvent",
  mEvent = {
    0,
    0,
    sdp.SdpMap(8, CmdDispatchEvent),
    nil
  }
}
Cmd_Castle_CancelDispatch_CS = sdp.SdpStruct("Cmd_Castle_CancelDispatch_CS")
Cmd_Castle_CancelDispatch_CS.Definition = {
  "iLocation",
  iLocation = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_CancelDispatch_SC = sdp.SdpStruct("Cmd_Castle_CancelDispatch_SC")
Cmd_Castle_CancelDispatch_SC.Definition = {
  "iLocation",
  "stEvent",
  iLocation = {
    0,
    0,
    8,
    0
  },
  stEvent = {
    1,
    0,
    CmdDispatchEvent,
    nil
  }
}
Cmd_Castle_TakeDispatchReward_CS = sdp.SdpStruct("Cmd_Castle_TakeDispatchReward_CS")
Cmd_Castle_TakeDispatchReward_CS.Definition = {
  "vLocation",
  vLocation = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Castle_TakeDispatchReward_SC = sdp.SdpStruct("Cmd_Castle_TakeDispatchReward_SC")
Cmd_Castle_TakeDispatchReward_SC.Definition = {
  "mEvent",
  "vReward",
  mEvent = {
    0,
    0,
    sdp.SdpMap(8, CmdDispatchEvent),
    nil
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdLostStory = sdp.SdpStruct("CmdLostStory")
CmdLostStory.Definition = {
  "iStoryId",
  "vSectionId",
  "iRewardTime",
  iStoryId = {
    0,
    0,
    8,
    0
  },
  vSectionId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iRewardTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Castle_GetExplore_CS = sdp.SdpStruct("Cmd_Castle_GetExplore_CS")
Cmd_Castle_GetExplore_CS.Definition = {}
Cmd_Castle_GetExplore_SC = sdp.SdpStruct("Cmd_Castle_GetExplore_SC")
Cmd_Castle_GetExplore_SC.Definition = {
  "mClue",
  "mStory",
  "vChapterReward",
  mClue = {
    0,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  },
  mStory = {
    1,
    0,
    sdp.SdpMap(8, CmdLostStory),
    nil
  },
  vChapterReward = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Castle_TakeClueReward_CS = sdp.SdpStruct("Cmd_Castle_TakeClueReward_CS")
Cmd_Castle_TakeClueReward_CS.Definition = {
  "iChapterId",
  "iClueId",
  iChapterId = {
    0,
    0,
    8,
    0
  },
  iClueId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Castle_TakeClueReward_SC = sdp.SdpStruct("Cmd_Castle_TakeClueReward_SC")
Cmd_Castle_TakeClueReward_SC.Definition = {
  "iChapterId",
  "iClueId",
  "vReward",
  "stRewardStory",
  iChapterId = {
    0,
    0,
    8,
    0
  },
  iClueId = {
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
  },
  stRewardStory = {
    3,
    0,
    CmdLostStory,
    nil
  }
}
Cmd_Castle_TakeStoryReward_CS = sdp.SdpStruct("Cmd_Castle_TakeStoryReward_CS")
Cmd_Castle_TakeStoryReward_CS.Definition = {
  "iStoryId",
  iStoryId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_TakeStoryReward_SC = sdp.SdpStruct("Cmd_Castle_TakeStoryReward_SC")
Cmd_Castle_TakeStoryReward_SC.Definition = {
  "iStoryId",
  "vReward",
  iStoryId = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Castle_TakeChapterReward_CS = sdp.SdpStruct("Cmd_Castle_TakeChapterReward_CS")
Cmd_Castle_TakeChapterReward_CS.Definition = {
  "iChapterId",
  iChapterId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_TakeChapterReward_SC = sdp.SdpStruct("Cmd_Castle_TakeChapterReward_SC")
Cmd_Castle_TakeChapterReward_SC.Definition = {
  "iChapterId",
  "vReward",
  iChapterId = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Castle_GetStatue_CS = sdp.SdpStruct("Cmd_Castle_GetStatue_CS")
Cmd_Castle_GetStatue_CS.Definition = {}
Cmd_Castle_GetStatue_SC = sdp.SdpStruct("Cmd_Castle_GetStatue_SC")
Cmd_Castle_GetStatue_SC.Definition = {
  "iLevel",
  "iRewardLevel",
  iLevel = {
    0,
    0,
    8,
    0
  },
  iRewardLevel = {
    1,
    0,
    8,
    0
  }
}
Cmd_Castle_TakeStatueReward_CS = sdp.SdpStruct("Cmd_Castle_TakeStatueReward_CS")
Cmd_Castle_TakeStatueReward_CS.Definition = {}
Cmd_Castle_TakeStatueReward_SC = sdp.SdpStruct("Cmd_Castle_TakeStatueReward_SC")
Cmd_Castle_TakeStatueReward_SC.Definition = {
  "iLevel",
  "vReward",
  iLevel = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdConstella = sdp.SdpStruct("CmdConstella")
CmdConstella.Definition = {
  "mUnlockStar",
  mUnlockStar = {
    0,
    0,
    sdp.SdpMap(8, sdp.SdpVector(8)),
    nil
  }
}
Cmd_Castle_GetStarRoom_CS = sdp.SdpStruct("Cmd_Castle_GetStarRoom_CS")
Cmd_Castle_GetStarRoom_CS.Definition = {}
Cmd_Castle_GetStarRoom_SC = sdp.SdpStruct("Cmd_Castle_GetStarRoom_SC")
Cmd_Castle_GetStarRoom_SC.Definition = {
  "mConstella",
  mConstella = {
    0,
    0,
    sdp.SdpMap(8, CmdConstella),
    nil
  }
}
Cmd_Castle_UnlockConstella_CS = sdp.SdpStruct("Cmd_Castle_UnlockConstella_CS")
Cmd_Castle_UnlockConstella_CS.Definition = {
  "iConstellaId",
  iConstellaId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_UnlockConstella_SC = sdp.SdpStruct("Cmd_Castle_UnlockConstella_SC")
Cmd_Castle_UnlockConstella_SC.Definition = {
  "iConstellaId",
  iConstellaId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_SeeStar_CS = sdp.SdpStruct("Cmd_Castle_SeeStar_CS")
Cmd_Castle_SeeStar_CS.Definition = {
  "iConstellaId",
  "iStarId",
  "vHero",
  iConstellaId = {
    0,
    0,
    8,
    0
  },
  iStarId = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Castle_SeeStar_SC = sdp.SdpStruct("Cmd_Castle_SeeStar_SC")
Cmd_Castle_SeeStar_SC.Definition = {
  "iConstellaId",
  "iStarId",
  "vHero",
  iConstellaId = {
    0,
    0,
    8,
    0
  },
  iStarId = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Castle_GetPlace_CS = sdp.SdpStruct("Cmd_Castle_GetPlace_CS")
Cmd_Castle_GetPlace_CS.Definition = {}
Cmd_Castle_GetPlace_SC = sdp.SdpStruct("Cmd_Castle_GetPlace_SC")
Cmd_Castle_GetPlace_SC.Definition = {
  "vUnlockPlace",
  "mWaitStory",
  "iStoryTimes",
  "mFinishedStory",
  vUnlockPlace = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  mWaitStory = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iStoryTimes = {
    2,
    0,
    8,
    0
  },
  mFinishedStory = {
    3,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Castle_UnlockKeyPlace_CS = sdp.SdpStruct("Cmd_Castle_UnlockKeyPlace_CS")
Cmd_Castle_UnlockKeyPlace_CS.Definition = {
  "iPlaceId",
  iPlaceId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_UnlockKeyPlace_SC = sdp.SdpStruct("Cmd_Castle_UnlockKeyPlace_SC")
Cmd_Castle_UnlockKeyPlace_SC.Definition = {
  "iPlaceId",
  iPlaceId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Castle_DoPlaceStory_CS = sdp.SdpStruct("Cmd_Castle_DoPlaceStory_CS")
Cmd_Castle_DoPlaceStory_CS.Definition = {
  "iStoryId",
  "bSkip",
  iStoryId = {
    0,
    0,
    8,
    0
  },
  bSkip = {
    1,
    0,
    1,
    false
  }
}
Cmd_Castle_DoPlaceStory_SC = sdp.SdpStruct("Cmd_Castle_DoPlaceStory_SC")
Cmd_Castle_DoPlaceStory_SC.Definition = {
  "iStoryId",
  "iStoryTimes",
  "vReward",
  iStoryId = {
    0,
    0,
    8,
    0
  },
  iStoryTimes = {
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
