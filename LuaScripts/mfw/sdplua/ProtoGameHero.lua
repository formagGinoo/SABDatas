local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Hero_GetList_CS = 10401
CmdId_Hero_GetList_SC = 10402
CmdId_Hero_LevelUp_CS = 10403
CmdId_Hero_LevelUp_SC = 10404
CmdId_Hero_InstallEquipBatch_CS = 10405
CmdId_Hero_InstallEquipBatch_SC = 10406
CmdId_Hero_UninstallAllEquip_CS = 10407
CmdId_Hero_UninstallAllEquip_SC = 10408
CmdId_Hero_InstallEquip_CS = 10409
CmdId_Hero_InstallEquip_SC = 10410
CmdId_Hero_UninstallEquip_CS = 10411
CmdId_Hero_UninstallEquip_SC = 10412
CmdId_Hero_SwapEquip_CS = 10413
CmdId_Hero_SwapEquip_SC = 10414
CmdId_Hero_ResetLevel_CS = 10415
CmdId_Hero_ResetLevel_SC = 10416
CmdId_Hero_Break_CS = 10417
CmdId_Hero_Break_SC = 10418
CmdId_Hero_SkillLevelUp_CS = 10419
CmdId_Hero_SkillLevelUp_SC = 10420
CmdId_Hero_SetHeroLove_CS = 10421
CmdId_Hero_SetHeroLove_SC = 10422
CmdId_Hero_SetFashion_CS = 10423
CmdId_Hero_SetFashion_SC = 10424
CmdId_Hero_SkillReset_CS = 10425
CmdId_Hero_SkillReset_SC = 10426
CmdId_Form_GetForm_CS = 10430
CmdId_Form_GetForm_SC = 10431
CmdId_Form_SetForm_CS = 10432
CmdId_Form_SetForm_SC = 10433
CmdId_Form_SetFormStar_CS = 10434
CmdId_Form_SetFormStar_SC = 10435
CmdId_Form_GetPreset_CS = 10436
CmdId_Form_GetPreset_SC = 10437
CmdId_Form_SetPreset_CS = 10438
CmdId_Form_SetPreset_SC = 10439
CmdId_Form_SetMutexForm_CS = 10440
CmdId_Form_SetMutexForm_SC = 10441
CmdId_Form_GetMultiForm_CS = 10442
CmdId_Form_GetMultiForm_SC = 10443
CmdId_Form_SetFormCard_CS = 10444
CmdId_Form_SetFormCard_SC = 10445
CmdId_Inherit_GetData_CS = 10450
CmdId_Inherit_GetData_SC = 10451
CmdId_Inherit_AddHero_CS = 10452
CmdId_Inherit_AddHero_SC = 10453
CmdId_Inherit_DelHero_CS = 10454
CmdId_Inherit_DelHero_SC = 10455
CmdId_Inherit_UnlockGrid_CS = 10456
CmdId_Inherit_UnlockGrid_SC = 10457
CmdId_Inherit_ResetGrid_CS = 10458
CmdId_Inherit_ResetGrid_SC = 10459
CmdId_Inherit_Evolve_CS = 10460
CmdId_Inherit_Evolve_SC = 10461
CmdId_Inherit_LevelUp_CS = 10462
CmdId_Inherit_LevelUp_SC = 10463
Cmd_Hero_GetList_CS = sdp.SdpStruct("Cmd_Hero_GetList_CS")
Cmd_Hero_GetList_CS.Definition = {}
Cmd_Hero_GetList_SC = sdp.SdpStruct("Cmd_Hero_GetList_SC")
Cmd_Hero_GetList_SC.Definition = {
  "vHeroList",
  "mHasFashion",
  vHeroList = {
    0,
    0,
    sdp.SdpVector(CmdHeroData),
    nil
  },
  mHasFashion = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Hero_LevelUp_CS = sdp.SdpStruct("Cmd_Hero_LevelUp_CS")
Cmd_Hero_LevelUp_CS.Definition = {
  "iHeroId",
  "iNum",
  iHeroId = {
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
  }
}
Cmd_Hero_LevelUp_SC = sdp.SdpStruct("Cmd_Hero_LevelUp_SC")
Cmd_Hero_LevelUp_SC.Definition = {}
Cmd_Hero_InstallEquipBatch_CS = sdp.SdpStruct("Cmd_Hero_InstallEquipBatch_CS")
Cmd_Hero_InstallEquipBatch_CS.Definition = {
  "iHeroId",
  "mEquip",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  mEquip = {
    1,
    0,
    sdp.SdpMap(8, 10),
    nil
  }
}
Cmd_Hero_InstallEquipBatch_SC = sdp.SdpStruct("Cmd_Hero_InstallEquipBatch_SC")
Cmd_Hero_InstallEquipBatch_SC.Definition = {
  "iHeroId",
  "mEquip",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  mEquip = {
    1,
    0,
    sdp.SdpMap(8, 10),
    nil
  }
}
Cmd_Hero_UninstallAllEquip_CS = sdp.SdpStruct("Cmd_Hero_UninstallAllEquip_CS")
Cmd_Hero_UninstallAllEquip_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Hero_UninstallAllEquip_SC = sdp.SdpStruct("Cmd_Hero_UninstallAllEquip_SC")
Cmd_Hero_UninstallAllEquip_SC.Definition = {}
Cmd_Hero_InstallEquip_CS = sdp.SdpStruct("Cmd_Hero_InstallEquip_CS")
Cmd_Hero_InstallEquip_CS.Definition = {
  "iHeroId",
  "iPos",
  "iEquipUid",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  },
  iEquipUid = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Hero_InstallEquip_SC = sdp.SdpStruct("Cmd_Hero_InstallEquip_SC")
Cmd_Hero_InstallEquip_SC.Definition = {
  "iHeroId",
  "iPos",
  "iEquipUid",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  },
  iEquipUid = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Hero_UninstallEquip_CS = sdp.SdpStruct("Cmd_Hero_UninstallEquip_CS")
Cmd_Hero_UninstallEquip_CS.Definition = {
  "iHeroId",
  "iPos",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  }
}
Cmd_Hero_UninstallEquip_SC = sdp.SdpStruct("Cmd_Hero_UninstallEquip_SC")
Cmd_Hero_UninstallEquip_SC.Definition = {}
Cmd_Hero_SwapEquip_CS = sdp.SdpStruct("Cmd_Hero_SwapEquip_CS")
Cmd_Hero_SwapEquip_CS.Definition = {
  "iSrcHeroId",
  "iDstHeroId",
  "iPos",
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
  },
  iPos = {
    2,
    0,
    8,
    0
  }
}
Cmd_Hero_SwapEquip_SC = sdp.SdpStruct("Cmd_Hero_SwapEquip_SC")
Cmd_Hero_SwapEquip_SC.Definition = {}
Cmd_Form_GetForm_CS = sdp.SdpStruct("Cmd_Form_GetForm_CS")
Cmd_Form_GetForm_CS.Definition = {
  "iFightType",
  "iFightSubType",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  }
}
Cmd_Form_GetForm_SC = sdp.SdpStruct("Cmd_Form_GetForm_SC")
Cmd_Form_GetForm_SC.Definition = {
  "stForm",
  stForm = {
    0,
    0,
    CmdForm,
    nil
  }
}
Cmd_Form_SetForm_CS = sdp.SdpStruct("Cmd_Form_SetForm_CS")
Cmd_Form_SetForm_CS.Definition = {
  "iType",
  "iSubType",
  "vHero",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(CmdFormHero),
    nil
  }
}
Cmd_Form_SetForm_SC = sdp.SdpStruct("Cmd_Form_SetForm_SC")
Cmd_Form_SetForm_SC.Definition = {
  "iType",
  "iSubType",
  "stForm",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  stForm = {
    2,
    0,
    CmdForm,
    nil
  }
}
Cmd_Form_SetFormStar_CS = sdp.SdpStruct("Cmd_Form_SetFormStar_CS")
Cmd_Form_SetFormStar_CS.Definition = {
  "iType",
  "iSubType",
  "vStarUp",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  vStarUp = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_SetFormStar_SC = sdp.SdpStruct("Cmd_Form_SetFormStar_SC")
Cmd_Form_SetFormStar_SC.Definition = {
  "iType",
  "iSubType",
  "vStarUp",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  vStarUp = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_SetFormCard_CS = sdp.SdpStruct("Cmd_Form_SetFormCard_CS")
Cmd_Form_SetFormCard_CS.Definition = {
  "iType",
  "iSubType",
  "vHeroID",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  vHeroID = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_SetFormCard_SC = sdp.SdpStruct("Cmd_Form_SetFormCard_SC")
Cmd_Form_SetFormCard_SC.Definition = {
  "iType",
  "iSubType",
  "vHeroID",
  iType = {
    0,
    0,
    8,
    0
  },
  iSubType = {
    1,
    0,
    8,
    0
  },
  vHeroID = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_GetPreset_CS = sdp.SdpStruct("Cmd_Form_GetPreset_CS")
Cmd_Form_GetPreset_CS.Definition = {}
Cmd_Form_GetPreset_SC = sdp.SdpStruct("Cmd_Form_GetPreset_SC")
Cmd_Form_GetPreset_SC.Definition = {
  "mPreset",
  mPreset = {
    0,
    0,
    sdp.SdpMap(8, CmdFormPreset),
    nil
  }
}
Cmd_Form_SetPreset_CS = sdp.SdpStruct("Cmd_Form_SetPreset_CS")
Cmd_Form_SetPreset_CS.Definition = {
  "iPresetId",
  "vHeroId",
  iPresetId = {
    0,
    0,
    8,
    0
  },
  vHeroId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_SetPreset_SC = sdp.SdpStruct("Cmd_Form_SetPreset_SC")
Cmd_Form_SetPreset_SC.Definition = {
  "iPresetId",
  "stPreset",
  iPresetId = {
    0,
    0,
    8,
    0
  },
  stPreset = {
    1,
    0,
    CmdFormPreset,
    nil
  }
}
Cmd_Form_SetMutexForm_CS = sdp.SdpStruct("Cmd_Form_SetMutexForm_CS")
Cmd_Form_SetMutexForm_CS.Definition = {
  "iType",
  "mSubTypeForm",
  iType = {
    0,
    0,
    8,
    0
  },
  mSubTypeForm = {
    1,
    0,
    sdp.SdpMap(8, CmdForm),
    nil
  }
}
Cmd_Form_SetMutexForm_SC = sdp.SdpStruct("Cmd_Form_SetMutexForm_SC")
Cmd_Form_SetMutexForm_SC.Definition = {
  "iType",
  "mSubTypeForm",
  iType = {
    0,
    0,
    8,
    0
  },
  mSubTypeForm = {
    1,
    0,
    sdp.SdpMap(8, CmdForm),
    nil
  }
}
Cmd_Form_GetMultiForm_CS = sdp.SdpStruct("Cmd_Form_GetMultiForm_CS")
Cmd_Form_GetMultiForm_CS.Definition = {
  "iType",
  "vSubType",
  iType = {
    0,
    0,
    8,
    0
  },
  vSubType = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Form_GetMultiForm_SC = sdp.SdpStruct("Cmd_Form_GetMultiForm_SC")
Cmd_Form_GetMultiForm_SC.Definition = {
  "iType",
  "mSubTypeForm",
  iType = {
    0,
    0,
    8,
    0
  },
  mSubTypeForm = {
    1,
    0,
    sdp.SdpMap(8, CmdForm),
    nil
  }
}
Cmd_Hero_ResetLevel_CS = sdp.SdpStruct("Cmd_Hero_ResetLevel_CS")
Cmd_Hero_ResetLevel_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Hero_ResetLevel_SC = sdp.SdpStruct("Cmd_Hero_ResetLevel_SC")
Cmd_Hero_ResetLevel_SC.Definition = {
  "iHeroId",
  "iLevel",
  "vItem",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  vItem = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Hero_Break_CS = sdp.SdpStruct("Cmd_Hero_Break_CS")
Cmd_Hero_Break_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Hero_Break_SC = sdp.SdpStruct("Cmd_Hero_Break_SC")
Cmd_Hero_Break_SC.Definition = {
  "iHeroId",
  "iBreak",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBreak = {
    1,
    0,
    8,
    0
  }
}
Cmd_Hero_SkillLevelUp_CS = sdp.SdpStruct("Cmd_Hero_SkillLevelUp_CS")
Cmd_Hero_SkillLevelUp_CS.Definition = {
  "iHeroId",
  "iSkillId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iSkillId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Hero_SkillLevelUp_SC = sdp.SdpStruct("Cmd_Hero_SkillLevelUp_SC")
Cmd_Hero_SkillLevelUp_SC.Definition = {
  "iHeroId",
  "iSkillId",
  "iLevel",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iSkillId = {
    1,
    0,
    8,
    0
  },
  iLevel = {
    2,
    0,
    8,
    0
  }
}
Cmd_Hero_SkillReset_CS = sdp.SdpStruct("Cmd_Hero_SkillReset_CS")
Cmd_Hero_SkillReset_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Hero_SkillReset_SC = sdp.SdpStruct("Cmd_Hero_SkillReset_SC")
Cmd_Hero_SkillReset_SC.Definition = {
  "iHeroId",
  "vItem",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  vItem = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Hero_SetHeroLove_CS = sdp.SdpStruct("Cmd_Hero_SetHeroLove_CS")
Cmd_Hero_SetHeroLove_CS.Definition = {
  "iHeroId",
  "bLove",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  bLove = {
    1,
    0,
    1,
    false
  }
}
Cmd_Hero_SetHeroLove_SC = sdp.SdpStruct("Cmd_Hero_SetHeroLove_SC")
Cmd_Hero_SetHeroLove_SC.Definition = {
  "iHeroId",
  "bLove",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  bLove = {
    1,
    0,
    1,
    false
  }
}
CmdInheritGrid = sdp.SdpStruct("CmdInheritGrid")
CmdInheritGrid.Definition = {
  "iHeroId",
  "iCdTime",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iCdTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Inherit_GetData_CS = sdp.SdpStruct("Cmd_Inherit_GetData_CS")
Cmd_Inherit_GetData_CS.Definition = {}
Cmd_Inherit_GetData_SC = sdp.SdpStruct("Cmd_Inherit_GetData_SC")
Cmd_Inherit_GetData_SC.Definition = {
  "iLevel",
  "vMainHero",
  "vGrid",
  "bEvolve",
  iLevel = {
    0,
    0,
    8,
    0
  },
  vMainHero = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vGrid = {
    2,
    0,
    sdp.SdpVector(CmdInheritGrid),
    nil
  },
  bEvolve = {
    3,
    0,
    1,
    false
  }
}
Cmd_Inherit_AddHero_CS = sdp.SdpStruct("Cmd_Inherit_AddHero_CS")
Cmd_Inherit_AddHero_CS.Definition = {
  "iHeroId",
  "iPos",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  }
}
Cmd_Inherit_AddHero_SC = sdp.SdpStruct("Cmd_Inherit_AddHero_SC")
Cmd_Inherit_AddHero_SC.Definition = {
  "iHeroId",
  "iPos",
  "stGrid",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iPos = {
    1,
    0,
    8,
    0
  },
  stGrid = {
    2,
    0,
    CmdInheritGrid,
    nil
  }
}
Cmd_Inherit_DelHero_CS = sdp.SdpStruct("Cmd_Inherit_DelHero_CS")
Cmd_Inherit_DelHero_CS.Definition = {
  "iPos",
  iPos = {
    0,
    0,
    8,
    0
  }
}
Cmd_Inherit_DelHero_SC = sdp.SdpStruct("Cmd_Inherit_DelHero_SC")
Cmd_Inherit_DelHero_SC.Definition = {
  "iPos",
  "iHeroId",
  "stGrid",
  iPos = {
    0,
    0,
    8,
    0
  },
  iHeroId = {
    1,
    0,
    8,
    0
  },
  stGrid = {
    2,
    0,
    CmdInheritGrid,
    nil
  }
}
Cmd_Inherit_UnlockGrid_CS = sdp.SdpStruct("Cmd_Inherit_UnlockGrid_CS")
Cmd_Inherit_UnlockGrid_CS.Definition = {}
Cmd_Inherit_UnlockGrid_SC = sdp.SdpStruct("Cmd_Inherit_UnlockGrid_SC")
Cmd_Inherit_UnlockGrid_SC.Definition = {
  "iPos",
  "stGrid",
  iPos = {
    0,
    0,
    8,
    0
  },
  stGrid = {
    1,
    0,
    CmdInheritGrid,
    nil
  }
}
Cmd_Inherit_ResetGrid_CS = sdp.SdpStruct("Cmd_Inherit_ResetGrid_CS")
Cmd_Inherit_ResetGrid_CS.Definition = {
  "iPos",
  iPos = {
    0,
    0,
    8,
    0
  }
}
Cmd_Inherit_ResetGrid_SC = sdp.SdpStruct("Cmd_Inherit_ResetGrid_SC")
Cmd_Inherit_ResetGrid_SC.Definition = {
  "iPos",
  "stGrid",
  iPos = {
    0,
    0,
    8,
    0
  },
  stGrid = {
    1,
    0,
    CmdInheritGrid,
    nil
  }
}
Cmd_Hero_SetFashion_CS = sdp.SdpStruct("Cmd_Hero_SetFashion_CS")
Cmd_Hero_SetFashion_CS.Definition = {
  "iHeroId",
  "iFashionId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iFashionId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Hero_SetFashion_SC = sdp.SdpStruct("Cmd_Hero_SetFashion_SC")
Cmd_Hero_SetFashion_SC.Definition = {
  "iHeroId",
  "iFashionId",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iFashionId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Inherit_Evolve_CS = sdp.SdpStruct("Cmd_Inherit_Evolve_CS")
Cmd_Inherit_Evolve_CS.Definition = {}
Cmd_Inherit_Evolve_SC = sdp.SdpStruct("Cmd_Inherit_Evolve_SC")
Cmd_Inherit_Evolve_SC.Definition = {
  "bEvolve",
  bEvolve = {
    0,
    0,
    1,
    false
  }
}
Cmd_Inherit_LevelUp_CS = sdp.SdpStruct("Cmd_Inherit_LevelUp_CS")
Cmd_Inherit_LevelUp_CS.Definition = {
  "iNum",
  iNum = {
    0,
    0,
    8,
    0
  }
}
Cmd_Inherit_LevelUp_SC = sdp.SdpStruct("Cmd_Inherit_LevelUp_SC")
Cmd_Inherit_LevelUp_SC.Definition = {
  "iOldLevel",
  "iNewLevel",
  iOldLevel = {
    0,
    0,
    8,
    0
  },
  iNewLevel = {
    1,
    0,
    8,
    0
  }
}
