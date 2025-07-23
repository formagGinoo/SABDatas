local Job_Startup_FetchMoreServerData_Impl = {}
local tempJobNode
local maxWaitTime = 12

local function CheckFetchMoreServerDataJobNodeSuccess(param)
  local length = table.getn(Job_Startup_FetchMoreServerData_Impl.m_handelList)
  if length == 0 then
    local jobNode = tempJobNode
    Job_Startup_FetchMoreServerData_Impl.DealTimer()
    jobNode.Status = JobStatus.Success
  end
end

local NetSessionIns = CS.com.muf.net.client.mfw.NetSession.Instance

function Job_Startup_FetchMoreServerData_Impl.ResetHandelList()
  if table.getn(Job_Startup_FetchMoreServerData_Impl.m_handelList) > 0 then
    for _, handler in pairs(Job_Startup_FetchMoreServerData_Impl.m_handelList) do
      NetSessionIns:RemoveListenByHandler(handler)
    end
  end
  Job_Startup_FetchMoreServerData_Impl.m_handelList = {}
end

function Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerData(jobNode)
  Job_Startup_FetchMoreServerData_Impl.DealRequestEnum()
  Job_Startup_FetchMoreServerData_Impl.ResetHandelList()
  ReportManager:ReportLoginProcess("FetchMoreServerData", "Start")
  Job_Startup_FetchMoreServerData_Impl.StartTimer()
  tempJobNode = jobNode
  for messageId, manager in pairs(Job_Startup_FetchMoreServerData_Impl.Request) do
    local handleId = NetSessionIns:Listen(-messageId, function(msg)
      if msg then
        Job_Startup_FetchMoreServerData_Impl.Request[messageId] = nil
        if Job_Startup_FetchMoreServerData_Impl.m_handelList[messageId] then
          NetSessionIns:RemoveListenByHandler(Job_Startup_FetchMoreServerData_Impl.m_handelList[messageId])
          Job_Startup_FetchMoreServerData_Impl.m_handelList[messageId] = nil
        end
        CheckFetchMoreServerDataJobNodeSuccess()
        if msg.rspcode and msg.rspcode ~= 0 and manager and manager.OnInitMustFail then
          manager:initMustFail(messageId, msg)
        end
      end
    end)
    Job_Startup_FetchMoreServerData_Impl.m_handelList[messageId] = handleId
  end
  GameManager:OnInitMustRequestInFetchMore()
end

function Job_Startup_FetchMoreServerData_Impl.StartTimer(jobNode)
  Job_Startup_FetchMoreServerData_Impl.DealTimer()
  Job_Startup_FetchMoreServerData_Impl.timer = TimeService:SetTimer(maxWaitTime, 1, function()
    local openTime = TimeUtil:GetServerTimeS()
    local str = "OpenTime" .. tostring(openTime)
    local lastCSIdList = ""
    for messageId, manager in pairs(Job_Startup_FetchMoreServerData_Impl.Request) do
      lastCSIdList = lastCSIdList .. tostring(messageId) .. "_"
    end
    local userId = tostring(RoleManager:GetUID()) or ""
    local serverId = tostring(UserDataManager:GetZoneID()) or ""
    local userInfo = "UId: " .. tostring(userId) .. "ZoneId : " .. tostring(serverId)
    local finStr = str .. "_" .. lastCSIdList .. "_" .. userInfo
    local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_login_process)
    stReportData.Job_name = "FetchMoreServerDataError"
    stReportData.Job_detail = finStr
    CS.ReportService.Instance:Report(stReportData)
    CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      bLockBack = 2,
      btnNum = 1,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end)
end

function Job_Startup_FetchMoreServerData_Impl.DealRequestEnum(jobNode)
  Job_Startup_FetchMoreServerData_Impl.Request = {
    [MTTDProto.CmdId_Act_GetList_SC] = ActivityManager,
    [MTTDProto.CmdId_Lamia_GetList_SC] = HeroActivityManager,
    [MTTDProto.CmdId_Friend_GetInit_SC] = FriendManager,
    [MTTDProto.CmdId_Chat_GetShieldList_SC] = FriendManager,
    [MTTDProto.CmdId_Rank_GetList_SC] = GlobalRankManager,
    [MTTDProto.CmdId_Castle_GetDispatch_SC] = CastleDispatchManager,
    [MTTDProto.CmdId_Alliance_GetInit_SC] = GuildManager,
    [MTTDProto.CmdId_Afk_GetData_SC] = HangUpManager,
    [MTTDProto.CmdId_Rogue_GetData_SC] = RogueStageManager,
    [MTTDProto.CmdId_Shop_GetShopList_SC] = ShopManager
  }
end

function Job_Startup_FetchMoreServerData_Impl.DealTimer()
  if Job_Startup_FetchMoreServerData_Impl.timer then
    TimeService:KillTimer(Job_Startup_FetchMoreServerData_Impl.timer)
    Job_Startup_FetchMoreServerData_Impl.timer = nil
  end
end

function Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataSuccess(jobNode)
end

function Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataFailed(jobNode)
end

function Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataTimeOut(jobNode)
end

function Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataDispose(jobNode)
end

return Job_Startup_FetchMoreServerData_Impl
