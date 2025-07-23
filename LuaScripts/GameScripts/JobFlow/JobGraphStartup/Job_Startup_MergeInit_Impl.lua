local Job_Startup_MergeInit_Impl = {}

function Job_Startup_MergeInit_Impl.RequestMergeInit(jobNode)
  ReportManager:ReportLoginProcess("MergeInit", "Start")
  local reqMsgMust = MTTDProto.Cmd_Merge_GetInitMust_CS()
  RPCS():Merge_GetInitMust(reqMsgMust, function(sc, msg)
    ReportManager:ReportLoginProcess("MergeInit", "Success")
    ItemManager:OnItemGetListSC(sc.stItem)
    LevelManager:OnStageGetListSCMerge(sc.mStage)
    EquipManager:OnEquipGetListSC(sc.stEquip)
    GuideManager:OnGuideGetListSC(sc.stGuide)
    AttractManager:OnGetAttractInitSC(sc.stAttract)
    HeroManager:OnHeroGetListSC(sc.stHero)
    HeroManager:OnHeroGetPresetSC(sc.stFormPreset)
    ClientDataManager:OnClientDataGetDataSC(sc.stClientData)
    TaskManager:OnTaskGetInitSC(sc.stQuestInit)
    TaskManager:OnDailyTaskSC(sc.mQuest[TaskManager.TaskType.Daily])
    TaskManager:OnWeeklyTaskSC(sc.mQuest[TaskManager.TaskType.Weekly])
    TaskManager:OnMainTaskSC(sc.mQuest[TaskManager.TaskType.MainTask])
    TaskManager:OnChapterProgressTaskSC(sc.mQuest[TaskManager.TaskType.ChapterProgress])
    TaskManager:OnAchievementTaskSC(sc.mQuest[TaskManager.TaskType.Achievement])
    TaskManager:OnRogueAchievementTaskSC(sc.mQuest[TaskManager.TaskType.RogueAchievement])
    DownloadManager:OnTaskGetListSC(sc.mQuest[MTTDProto.QuestType_Resource])
    InheritManager:OnGetInheritDataSC(sc.stInherit)
    StargazingManager:OnGetStarRoomSC(sc.stStarRoom)
    AncientManager:OnReqAncientGetDataSC(sc.stAncient)
    GameManager:OnAfterFreshData()
    GameManager:initNetwork()
    jobNode.Status = JobStatus.Success
  end, function(msg)
    ReportManager:ReportLoginProcess("MergeInit", "Failed")
    log.info("--- game merge init failed : ", msg.rspcode, " ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
        Job_Startup_MergeInit_Impl.RequestMergeInit(jobNode)
      end,
      func2 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end, function(rec)
    ReportManager:ReportLoginProcess("MergeInit", "Timeout")
    log.info("--- game merge init timeout ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
        Job_Startup_MergeInit_Impl.RequestMergeInit(jobNode)
      end,
      func2 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end, nil, nil, -1)
end

function Job_Startup_MergeInit_Impl.OnMergeInit(jobNode)
  Job_Startup_MergeInit_Impl.RequestMergeInit(jobNode)
  local reqMsg = MTTDProto.Cmd_Merge_GetInit_CS()
  RPCS():Merge_GetInit(reqMsg, function(sc, msg)
  end, nil, nil, nil, nil, -1)
end

function Job_Startup_MergeInit_Impl.OnMergeInitSuccess(jobNode)
end

function Job_Startup_MergeInit_Impl.OnMergeInitFailed(jobNode)
end

function Job_Startup_MergeInit_Impl.OnMergeInitTimeOut(jobNode)
end

function Job_Startup_MergeInit_Impl.OnMergeInitDispose(jobNode)
end

return Job_Startup_MergeInit_Impl
