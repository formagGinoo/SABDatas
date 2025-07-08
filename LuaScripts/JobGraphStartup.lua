local JobGraphStartup = class("JobGraphStartup")
local Job_Startup_Finished_Impl = require("JobFlow/JobGraphStartup/Job_Startup_Finished_Impl")
local Job_Startup_InitConfigFirst_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitConfigFirst_Impl")
local Job_Startup_InitDownloadResource_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitDownloadResource_Impl")
local Job_Startup_InitConfig_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitConfig_Impl")
local Job_Startup_CheckPreRes_Impl = require("JobFlow/JobGraphStartup/Job_Startup_CheckPreRes_Impl")
local Job_Startup_InitNetwork_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitNetwork_Impl")
local Job_Startup_InitWwise_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitWwise_Impl")
local Job_Startup_InitMSDK_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitMSDK_Impl")
local Job_Startup_InitNetworkGame_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitNetworkGame_Impl")
local Job_Startup_DownloadAllResource_Impl = require("JobFlow/JobGraphStartup/Job_Startup_DownloadAllResource_Impl")
local Job_Startup_MergeInit_Impl = require("JobFlow/JobGraphStartup/Job_Startup_MergeInit_Impl")
local Job_Startup_DownloadNecessaryResource_Impl = require("JobFlow/JobGraphStartup/Job_Startup_DownloadNecessaryResource_Impl")
local Job_Startup_InitGSDK_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitGSDK_Impl")
local Job_Startup_InitTGRPAddRes_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitTGRPAddRes_Impl")
local Job_Startup_IniIapManager_Impl = require("JobFlow/JobGraphStartup/Job_Startup_IniIapManager_Impl")
local Job_Startup_CheckNetwork_Impl = require("JobFlow/JobGraphStartup/Job_Startup_CheckNetwork_Impl")
local Job_Startup_CheckAccountState_Impl = require("JobFlow/JobGraphStartup/Job_Startup_CheckAccountState_Impl")
local Job_Startup_FetchMoreServerData_Impl = require("JobFlow/JobGraphStartup/Job_Startup_FetchMoreServerData_Impl")
local Job_Startup_DataAnonym_Impl = require("JobFlow/JobGraphStartup/Job_Startup_DataAnonym_Impl")
local Job_Startup_InitUsercentrics_Impl = require("JobFlow/JobGraphStartup/Job_Startup_InitUsercentrics_Impl")
JobGraphStartup.s_instance = nil

function JobGraphStartup:ctor()
  self.m_builded = false
  self.m_csGraph = nil
end

function JobGraphStartup.Instance()
  if JobGraphStartup.s_instance == nil then
    JobGraphStartup.s_instance = JobGraphStartup.new()
    JobGraphStartup.s_instance:BuildGraph()
    if __JobGraphs == nil then
      __JobGraphs = {}
    end
    __JobGraphs.JobGraphStartup = JobGraphStartup.s_instance
  end
  return JobGraphStartup.s_instance
end

function JobGraphStartup:BuildGraph()
  if not self.m_builded then
    self.m_csGraph = JobGraphBase.CreateGraph()
    local csg = self.m_csGraph
    local jn = null
    local en = null
    local an = null
    en = EntryNode.CreateNode()
    csg:AddNode(en)
    csg:SetEntry(en)
    en.X = -1544
    en.Y = -456
    jn = JobNode.CreateNode("Finished", 0, 5, false, Job_Startup_Finished_Impl.OnFinished, Job_Startup_Finished_Impl.OnFinishedSuccess, Job_Startup_Finished_Impl.OnFinishedFailed, Job_Startup_Finished_Impl.OnFinishedTimeOut, Job_Startup_Finished_Impl.OnFinishedDispose)
    csg:AddNode(jn)
    jn.X = -1224
    jn.Y = 568
    jn = JobNode.CreateNode("InitConfigFirst", 0, 5, false, Job_Startup_InitConfigFirst_Impl.OnInitConfigFirst, Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstSuccess, Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstFailed, Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstTimeOut, Job_Startup_InitConfigFirst_Impl.OnInitConfigFirstDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = -456
    jn = JobNode.CreateNode("InitDownloadResource", 0, 1, false, Job_Startup_InitDownloadResource_Impl.OnInitDownloadResource, Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceSuccess, Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceFailed, Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceTimeOut, Job_Startup_InitDownloadResource_Impl.OnInitDownloadResourceDispose)
    csg:AddNode(jn)
    jn.X = -824
    jn.Y = -456
    jn = JobNode.CreateNode("InitConfig", 0, 10, false, Job_Startup_InitConfig_Impl.OnInitConfig, Job_Startup_InitConfig_Impl.OnInitConfigSuccess, Job_Startup_InitConfig_Impl.OnInitConfigFailed, Job_Startup_InitConfig_Impl.OnInitConfigTimeOut, Job_Startup_InitConfig_Impl.OnInitConfigDispose)
    csg:AddNode(jn)
    jn.X = 376
    jn.Y = 56
    jn = JobNode.CreateNode("CheckPreRes", 0, 1, false, Job_Startup_CheckPreRes_Impl.OnCheckPreRes, Job_Startup_CheckPreRes_Impl.OnCheckPreResSuccess, Job_Startup_CheckPreRes_Impl.OnCheckPreResFailed, Job_Startup_CheckPreRes_Impl.OnCheckPreResTimeOut, Job_Startup_CheckPreRes_Impl.OnCheckPreResDispose)
    csg:AddNode(jn)
    jn.X = -408
    jn.Y = -456
    jn = JobNode.CreateNode("InitNetwork", 0, 20, false, Job_Startup_InitNetwork_Impl.OnInitNetwork, Job_Startup_InitNetwork_Impl.OnInitNetworkSuccess, Job_Startup_InitNetwork_Impl.OnInitNetworkFailed, Job_Startup_InitNetwork_Impl.OnInitNetworkTimeOut, Job_Startup_InitNetwork_Impl.OnInitNetworkDispose)
    csg:AddNode(jn)
    jn.X = -1224
    jn.Y = 56
    jn = JobNode.CreateNode("InitWwise", 0, 1, false, Job_Startup_InitWwise_Impl.OnInitWwise, Job_Startup_InitWwise_Impl.OnInitWwiseSuccess, Job_Startup_InitWwise_Impl.OnInitWwiseFailed, Job_Startup_InitWwise_Impl.OnInitWwiseTimeOut, Job_Startup_InitWwise_Impl.OnInitWwiseDispose)
    csg:AddNode(jn)
    jn.X = -1224
    jn.Y = -456
    jn = JobNode.CreateNode("InitMSDK", 0, 20, false, Job_Startup_InitMSDK_Impl.OnInitMSDK, Job_Startup_InitMSDK_Impl.OnInitMSDKSuccess, Job_Startup_InitMSDK_Impl.OnInitMSDKFailed, Job_Startup_InitMSDK_Impl.OnInitMSDKTimeOut, Job_Startup_InitMSDK_Impl.OnInitMSDKDispose)
    csg:AddNode(jn)
    jn.X = -424
    jn.Y = -200
    jn = JobNode.CreateNode("InitNetworkGame", 0, 20, false, Job_Startup_InitNetworkGame_Impl.OnInitNetworkGame, Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameSuccess, Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameFailed, Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameTimeOut, Job_Startup_InitNetworkGame_Impl.OnInitNetworkGameDispose)
    csg:AddNode(jn)
    jn.X = -408
    jn.Y = 56
    jn = JobNode.CreateNode("DownloadAllResource", 0, 5, false, Job_Startup_DownloadAllResource_Impl.OnDownloadAllResource, Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceSuccess, Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceFailed, Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceTimeOut, Job_Startup_DownloadAllResource_Impl.OnDownloadAllResourceDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = 312
    jn = JobNode.CreateNode("MergeInit", 0, 5, false, Job_Startup_MergeInit_Impl.OnMergeInit, Job_Startup_MergeInit_Impl.OnMergeInitSuccess, Job_Startup_MergeInit_Impl.OnMergeInitFailed, Job_Startup_MergeInit_Impl.OnMergeInitTimeOut, Job_Startup_MergeInit_Impl.OnMergeInitDispose)
    csg:AddNode(jn)
    jn.X = -1224
    jn.Y = 312
    jn = JobNode.CreateNode("DownloadNecessaryResource", 0, 5, false, Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResource, Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceSuccess, Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceFailed, Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceTimeOut, Job_Startup_DownloadNecessaryResource_Impl.OnDownloadNecessaryResourceDispose)
    csg:AddNode(jn)
    jn.X = -408
    jn.Y = 312
    jn = JobNode.CreateNode("InitGSDK", 0, 20, false, Job_Startup_InitGSDK_Impl.OnInitGSDK, Job_Startup_InitGSDK_Impl.OnInitGSDKSuccess, Job_Startup_InitGSDK_Impl.OnInitGSDKFailed, Job_Startup_InitGSDK_Impl.OnInitGSDKTimeOut, Job_Startup_InitGSDK_Impl.OnInitGSDKDispose)
    csg:AddNode(jn)
    jn.X = 408
    jn.Y = -200
    jn = JobNode.CreateNode("InitTGRPAddRes", 0, 5, false, Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddRes, Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResSuccess, Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResFailed, Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResTimeOut, Job_Startup_InitTGRPAddRes_Impl.OnInitTGRPAddResDispose)
    csg:AddNode(jn)
    jn.X = -824
    jn.Y = 56
    jn = JobNode.CreateNode("IniIapManager", 0, 5, false, Job_Startup_IniIapManager_Impl.OnIniIapManager, Job_Startup_IniIapManager_Impl.OnIniIapManagerSuccess, Job_Startup_IniIapManager_Impl.OnIniIapManagerFailed, Job_Startup_IniIapManager_Impl.OnIniIapManagerTimeOut, Job_Startup_IniIapManager_Impl.OnIniIapManagerDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = 56
    jn = JobNode.CreateNode("CheckNetwork", 0, 1, false, Job_Startup_CheckNetwork_Impl.OnCheckNetwork, Job_Startup_CheckNetwork_Impl.OnCheckNetworkSuccess, Job_Startup_CheckNetwork_Impl.OnCheckNetworkFailed, Job_Startup_CheckNetwork_Impl.OnCheckNetworkTimeOut, Job_Startup_CheckNetwork_Impl.OnCheckNetworkDispose)
    csg:AddNode(jn)
    jn.X = -1224
    jn.Y = -200
    jn = JobNode.CreateNode("CheckAccountState", 0, 5, false, Job_Startup_CheckAccountState_Impl.OnCheckAccountState, Job_Startup_CheckAccountState_Impl.OnCheckAccountStateSuccess, Job_Startup_CheckAccountState_Impl.OnCheckAccountStateFailed, Job_Startup_CheckAccountState_Impl.OnCheckAccountStateTimeOut, Job_Startup_CheckAccountState_Impl.OnCheckAccountStateDispose)
    csg:AddNode(jn)
    jn.X = 392
    jn.Y = 312
    jn = JobNode.CreateNode("FetchMoreServerData", 0, 5, false, Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerData, Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataSuccess, Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataFailed, Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataTimeOut, Job_Startup_FetchMoreServerData_Impl.OnFetchMoreServerDataDispose)
    csg:AddNode(jn)
    jn.X = -824
    jn.Y = 312
    jn = JobNode.CreateNode("DataAnonym", 0, 5, false, Job_Startup_DataAnonym_Impl.OnDataAnonym, Job_Startup_DataAnonym_Impl.OnDataAnonymSuccess, Job_Startup_DataAnonym_Impl.OnDataAnonymFailed, Job_Startup_DataAnonym_Impl.OnDataAnonymTimeOut, Job_Startup_DataAnonym_Impl.OnDataAnonymDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = -200
    jn = JobNode.CreateNode("InitUsercentrics", 0, 20, false, Job_Startup_InitUsercentrics_Impl.OnInitUsercentrics, Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsSuccess, Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsFailed, Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsTimeOut, Job_Startup_InitUsercentrics_Impl.OnInitUsercentricsDispose)
    csg:AddNode(jn)
    jn.X = -824
    jn.Y = -200
    csg:GetNode(1):AddTrigger(csg:GetNode(17))
    csg:GetNode(2):AddTrigger(csg:GetNode(5))
    csg:GetNode(3):AddTrigger(csg:GetNode(7))
    csg:GetNode(4):AddTrigger(csg:GetNode(15))
    csg:GetNode(5):AddTrigger(csg:GetNode(3))
    csg:GetNode(6):AddTrigger(csg:GetNode(13))
    csg:GetNode(7):AddTrigger(csg:GetNode(0))
    csg:GetNode(8):AddTrigger(csg:GetNode(20))
    csg:GetNode(9):AddTrigger(csg:GetNode(14))
    csg:GetNode(10):AddTrigger(csg:GetNode(12))
    csg:GetNode(11):AddTrigger(csg:GetNode(4))
    csg:GetNode(12):AddTrigger(csg:GetNode(18))
    csg:GetNode(13):AddTrigger(csg:GetNode(19))
    csg:GetNode(14):AddTrigger(csg:GetNode(6))
    csg:GetNode(15):AddTrigger(csg:GetNode(9))
    csg:GetNode(16):AddTrigger(csg:GetNode(2))
    csg:GetNode(17):AddTrigger(csg:GetNode(10))
    csg:GetNode(18):AddTrigger(csg:GetNode(11))
    csg:GetNode(19):AddTrigger(csg:GetNode(8))
    csg:GetNode(20):AddTrigger(csg:GetNode(16))
    self.m_builded = true
  end
end

function JobGraphStartup:Reset()
  if self.m_csGraph ~= nil then
    self.m_csGraph:Reset()
  end
end

function JobGraphStartup:Run(callback)
  if self.m_csGraph ~= nil then
    self.m_csGraph:Run(callback)
  end
end

function JobGraphStartup:OnGUI()
  if self.m_csGraph ~= nil then
    self.m_csGraph:OnGUI()
  end
end

function JobGraphStartup:GetJobProgress()
  if self.m_csGraph ~= nil then
    return self.m_csGraph:GetJobProgress()
  end
  return 0
end

function JobGraphStartup:Dispose()
  if __JobGraphs ~= nil then
    __JobGraphs.JobGraphStartup = nil
  end
  JobGraphStartup.s_instance = nil
  if self.m_csGraph ~= nil then
    return self.m_csGraph:Dispose()
  end
  self.m_csGraph = nil
end

return JobGraphStartup
